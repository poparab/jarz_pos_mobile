param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('staging', 'production')]
    [string]$Environment,

    [switch]$PlanOnly,
    [switch]$SkipMigrate,
    [switch]$SkipBackup,
    [switch]$ForceReinstallApps,
    [switch]$ForceMigrate,
    [switch]$Yes,
    [string]$SshKeyPath
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$workspaceRoot = Split-Path -Parent $repoRoot
if (-not $SshKeyPath) {
    $SshKeyPath = Join-Path $workspaceRoot 'ERPNext-stg.pem'
}

$remoteDir = '/home/ubuntu/erpnext_docker'
$remoteAppsDir = '/var/lib/docker/volumes/erp_apps/_data'
$serviceNames = @('backend', 'queue-short', 'queue-long', 'scheduler')
$gitSshCommand = "ssh -i /home/ubuntu/.ssh/id_ed25519 -o UserKnownHostsFile=/home/ubuntu/.ssh/known_hosts -o StrictHostKeyChecking=accept-new"

if (-not (Test-Path $SshKeyPath)) {
    throw "SSH key not found at $SshKeyPath"
}

# Apps pulled on every deploy. This list is deliberately SHARED by staging and
# production: an app production pulls must be exercised on staging first, or its
# upstream commits reach production having never run anywhere else. Until
# 2026-07-15 staging's list omitted hrms while production's included it, so 24
# upstream frappe/hrms commits shipped straight to production — and any hrms
# schema change would have hit `bench migrate` for the first time on prod.
# Keep this single list; do not re-introduce a per-environment variant.
# jarz_courier MUST stay after jarz_pos: it declares required_apps = ["jarz_pos"]
# and `bench install-app` fails if a required app is not installed yet.
#
# An app listed here must be readable by the servers' /home/ubuntu/.ssh/id_ed25519.
# Listing one that is not makes Ensure-AppCloned fail on the clone, which aborts
# EVERY backend deploy including a POS hotfix — that happened on 2026-08-05 while
# jarz_courier was still a private repo the servers had no key for. Confirm with
# `git ls-remote` from the server before adding an app here.
# jarz_courier MUST stay after jarz_pos: it declares required_apps = ["jarz_pos"]
# and `bench install-app` fails if a required app is not yet installed.
#
# An app listed here must be readable by the servers' id_ed25519. Listing one that
# is not makes Ensure-AppCloned fail on the clone, which aborts EVERY backend
# deploy including a POS hotfix. Confirm with `git ls-remote` from the server
# before adding an app here.
$deployedApps = @('jarz_pos', 'jarz_woocommerce_integration', 'hrms', 'jarz_courier')

# Clone URLs for first-time bootstrap. Only consulted when an app in $deployedApps
# is genuinely absent from the server, so an app already on disk (hrms) needs no
# entry. An app that IS missing and has no entry here fails with a clear message
# instead of a cryptic `rev-parse` error out of Resolve-GitTarget.
#
# Order in $deployedApps is load-bearing for bootstrap: `bench install-app` fails
# if an app's `required_apps` are not installed yet, so a dependent app must be
# listed after the app it depends on.
$appRepos = @{
    'jarz_pos'                     = 'git@github.com:poparab/jarz_pos.git'
    'jarz_woocommerce_integration' = 'git@github.com:poparab/Woo_ERPNext.git'
    'jarz_courier'                 = 'git@github.com:poparab/jarz_courier.git'
}

$config = switch ($Environment) {
    'staging' {
        @{
            ServerIp = '13.36.219.136'
            Domain = 'erpstg.orderjarz.com'
            CustomApps = $deployedApps
            RequiresBackup = $false
        }
    }
    'production' {
        @{
            ServerIp = '13.36.132.13'
            Domain = 'erp.orderjarz.com'
            CustomApps = $deployedApps
            RequiresBackup = $true
        }
    }
}

$sshTarget = "ubuntu@$($config.ServerIp)"

function Write-Info([string]$Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn([string]$Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Step([string]$Message) {
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

function Invoke-Remote {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [switch]$IgnoreExitCode
    )

    $output = ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i $SshKeyPath $sshTarget $Command 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0 -and -not $IgnoreExitCode) {
        throw "Remote command failed ($exitCode): $Command`n$($output -join "`n")"
    }

    return ($output -join "`n").TrimEnd()
}

function ConvertTo-BashLiteral([string]$Value) {
    $singleQuote = [char]39
    $replacement = ([string]$singleQuote) + '"' + ([string]$singleQuote) + '"' + ([string]$singleQuote)
    return "$singleQuote" + ($Value -replace [regex]::Escape("$singleQuote"), $replacement) + "$singleQuote"
}

function Resolve-ContainerName([string]$ServiceName) {
    $containerName = (Invoke-Remote "docker ps --format '{{.Names}}' | grep -E 'erp[-_]$ServiceName[-_][0-9]+' | head -1").Trim()
    if (-not $containerName) {
        throw "Container for service '$ServiceName' not found"
    }

    return $containerName
}

function Resolve-GitTarget([string]$AppName) {
    $appPath = "$remoteAppsDir/$AppName"
    $branchName = (Invoke-Remote "sudo git -c safe.directory=$appPath -C $appPath rev-parse --abbrev-ref HEAD").Trim()
    $headBefore = (Invoke-Remote "sudo git -c safe.directory=$appPath -C $appPath rev-parse HEAD").Trim()
    $remoteNames = Invoke-Remote "sudo git -c safe.directory=$appPath -C $appPath remote"

    if ($remoteNames -match '(?m)^upstream$') {
        $remoteName = 'upstream'
    }
    elseif ($remoteNames -match '(?m)^origin$') {
        $remoteName = 'origin'
    }
    else {
        throw "No git remote found for $AppName at $appPath"
    }

    return @{
        AppName = $AppName
        AppPath = $appPath
        BranchName = $branchName
        RemoteName = $remoteName
        HeadBefore = $headBefore
        HeadAfter = $headBefore
        RemoteHead = $headBefore
        PendingUpdate = $false
        Changed = $false
        RequiresPipInstall = $false
    }
}

function Convert-GitHubRemoteToSsh($GitTarget) {
    $remoteUrl = (Invoke-Remote "sudo git -c safe.directory=$($GitTarget.AppPath) -C $($GitTarget.AppPath) remote get-url $($GitTarget.RemoteName)").Trim()
    if (-not $remoteUrl) {
        throw "Could not resolve remote URL for $($GitTarget.AppName)"
    }

    if ($remoteUrl -match '^https://github\.com/([^/]+)/(.+?)(?:\.git)?$') {
        $sshUrl = "git@github.com:$($Matches[1])/$($Matches[2]).git"
        Write-Info "Switching $($GitTarget.AppName) remote $($GitTarget.RemoteName) to SSH"
        Invoke-Remote "sudo git -c safe.directory=$($GitTarget.AppPath) -C $($GitTarget.AppPath) remote set-url $($GitTarget.RemoteName) $sshUrl" | Out-Null
        return $sshUrl
    }

    return $remoteUrl
}

function Get-RemoteBranchHead($GitTarget) {
    $lsRemote = (Invoke-Remote "sudo GIT_SSH_COMMAND='$gitSshCommand' git -c safe.directory=$($GitTarget.AppPath) -C $($GitTarget.AppPath) ls-remote $($GitTarget.RemoteName) refs/heads/$($GitTarget.BranchName)").Trim()
    if (-not $lsRemote) {
        throw "Could not resolve remote branch head for $($GitTarget.AppName)"
    }

    return ($lsRemote -split '\s+')[0]
}

function Assert-AppRepoIntegrity($GitTarget) {
    # The deploy trigger further down is `HeadBefore -ne RemoteHead`, read from the
    # app's on-disk git state. That is only a meaningful signal while THIS script is
    # the only thing that ever moves HEAD.
    #
    # It wasn't. Until 2026-07-15 the staging CI job
    # (jarz_pos/.github/workflows/backend-tests.yml) synced the branch under test with
    # `docker cp . <backend>:/home/frappe/frappe-bench/apps/jarz_pos/`. That container
    # path IS the live erp_apps volume, and `docker cp .` copies the runner's whole
    # checkout — `.git` included. So CI silently advanced on-disk HEAD to the tip of
    # main without ever pulling: every subsequent deploy computed PendingUpdate=false
    # and skipped pip/migrate/cache-clear/restart while reporting success. Because
    # gunicorn runs with --preload (the app is imported in the master and workers fork
    # from it), the new code sat on disk and was NOT being served until a restart.
    # Disk looked deployed, CI was green, and the running code was two commits stale.
    #
    # CI no longer copies .git. This guard is the regression detector: it fails the
    # deploy loudly if the live repo ever again looks like a CI checkout rather than a
    # deploy clone. A hard failure here is always preferable to the silent false-green.
    $fingerprints = @()

    $isShallow = (Invoke-Remote "sudo test -f $($GitTarget.AppPath)/.git/shallow && echo yes || echo no" -IgnoreExitCode).Trim()
    if ($isShallow -eq 'yes') {
        $fingerprints += 'shallow clone (.git/shallow present) — deploys clone with full history; actions/checkout uses fetch-depth 1'
    }

    $extraHeader = (Invoke-Remote "sudo git -c safe.directory=$($GitTarget.AppPath) -C $($GitTarget.AppPath) config --get-regexp '^http\..*\.extraheader' || true" -IgnoreExitCode).Trim()
    if ($extraHeader) {
        $fingerprints += 'git config carries an actions/checkout AUTHORIZATION extraheader — a CI token was written into the live volume'
    }

    # -uno: tracked files only. CI's restore intentionally leaves untracked leftovers
    # rather than risk a version-dependent `git clean -d` against the live volume, so
    # untracked files must not fail this guard. They are NOT entirely inert, though —
    # an untracked leftover blocks the pull outright once a later commit adds a tracked
    # file at the same path. The pull step handles that case by removing only the
    # colliding paths; see the comment there. A MODIFIED TRACKED file is the signal
    # this guard exists for: it means the deployed code on disk is not the deployed
    # commit, and a `git pull` below would fail anyway.
    #
    # --no-optional-locks is load-bearing, not a micro-optimisation: plain `git status`
    # REFRESHES .git/index as a side effect, and we run it under sudo, so it would
    # rewrite the index as root:root on every deploy. CI then execs git as `frappe`
    # (uid 1000) and its restore step would fail on the unwritable index — this guard
    # would quietly break the very CI job whose regressions it exists to catch.
    # GIT_OPTIONAL_LOCKS=0 makes status skip that write and stay genuinely read-only.
    $dirty = (Invoke-Remote "sudo git --no-optional-locks -c safe.directory=$($GitTarget.AppPath) -C $($GitTarget.AppPath) status --porcelain -uno" -IgnoreExitCode).Trim()
    if ($dirty) {
        $fingerprints += "tracked files differ from the deployed commit (a CI run left code behind, or someone edited the server by hand):`n$dirty"
    }

    if ($fingerprints.Count -eq 0) {
        return
    }

    $detail = ($fingerprints | ForEach-Object { "  - $_" }) -join "`n"
    throw @"
$($GitTarget.AppName) at $($GitTarget.AppPath) is not a clean deploy clone:
$detail

Something other than this script is writing to the live app volume, which makes the
'already at target commit' fast-path unsafe (see the 2026-07-15 false-green above).
Refusing to deploy rather than report a green over a stale runtime.

To repair the repo in place — run as the 'ubuntu' account, the only one with sudo
(the CI runner deliberately has none). All code still comes from GitHub; nothing here
hand-edits an application file:
  ssh -i <key> ubuntu@$($config.ServerIp)
  APP=$($GitTarget.AppPath)
  # Drop the CI token and actions/checkout's leftovers, restore full history.
  sudo git -c safe.directory=`$APP -C `$APP config --unset-all 'http.https://github.com/.extraheader' || true
  sudo git -c safe.directory=`$APP -C `$APP config --unset core.worktree || true
  sudo git -c safe.directory=`$APP -C `$APP config --unset gc.auto || true
  sudo git -c safe.directory=`$APP -C `$APP checkout -- .
  sudo GIT_SSH_COMMAND='$gitSshCommand' git -c safe.directory=`$APP -C `$APP fetch --unshallow $($GitTarget.RemoteName) || true
  # Re-own to uid 1000. This is REQUIRED, not cosmetic: the CI runner is uid 1001
  # (github-runner) and stamped that uid on every file it copied, but the backend
  # container execs as 'frappe' = uid 1000 = host 'ubuntu'. Until this runs, CI's
  # non-root sync cannot write here at all. hrms/woo are already 1000:1000 — match them.
  sudo chown -R ubuntu:ubuntu `$APP
Then re-run this deploy.
"@
}

function Test-AppRequiresEditableReinstall($GitTarget) {
    if ($ForceReinstallApps) {
        return $true
    }

    if (-not $GitTarget.Changed) {
        return $false
    }

    $metadataDiff = Invoke-Remote "sudo git -c safe.directory=$($GitTarget.AppPath) -C $($GitTarget.AppPath) diff --name-only $($GitTarget.HeadBefore) $($GitTarget.HeadAfter) -- pyproject.toml setup.py setup.cfg requirements.txt requirements" -IgnoreExitCode
    return -not [string]::IsNullOrWhiteSpace($metadataDiff)
}

function Install-EditableApps {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$AppNames,

        [Parameter(Mandatory = $true)]
        [hashtable]$ContainersByService
    )

    if (-not $AppNames -or $AppNames.Count -eq 0) {
        return
    }

    $editableArgs = ($AppNames | ForEach-Object { "-e apps/$_" }) -join ' '
    $containerNames = foreach ($serviceName in $serviceNames) {
        $ContainersByService[$serviceName]
    }
    $quotedContainers = ($containerNames | ForEach-Object { "'$_'" }) -join ' '

    # NOTE: pip output is intentionally NOT redirected to /dev/null. A failed dependency
    # install (e.g. a new runtime dep missing from requirements.txt) must surface in the
    # deploy log and fail the deploy — never silently skip and break the feature at runtime.
    $installScript = @"
set -euo pipefail
containers=($quotedContainers)
pids=()
for container in "`${containers[@]}"; do
  (
    echo "[pip] installing editable apps in `$container ..."
    docker exec -u root "`$container" bash -lc "cd /home/frappe/frappe-bench && /home/frappe/frappe-bench/env/bin/pip install $editableArgs" || { echo "[pip] FAILED in `$container" >&2; exit 1; }
  ) &
  pids+=("`$!")
done
fail=0
for pid in "`${pids[@]}"; do
  wait "`$pid" || fail=1
done
if [ "`$fail" -ne 0 ]; then
  echo "[pip] one or more editable installs failed" >&2
  exit 1
fi
"@

    Invoke-Remote ("bash -lc " + (ConvertTo-BashLiteral $installScript))
}

# ── First-install bootstrap ──────────────────────────────────────────────────
# Until 2026-08-05 this script had no `bench install-app` anywhere: the only
# --site calls were backup, migrate and clear-cache. `bench migrate` does NOT
# install an app that is absent from the site, so a newly added app was pulled
# and pip-installed and then silently did nothing — no DocTypes, no fixtures.
# jarz_observability is the standing example: present in the bench, in zero
# deploy scripts, absent from apps.txt, and it has never deployed.
#
# Worse, Resolve-GitTarget hard-throws on a missing clone, so merely naming a new
# app in $deployedApps broke EVERY backend deploy, including POS hotfixes. The
# bootstrap below therefore runs before the Resolve-GitTarget loop.
#
# Every step is guarded by an existence check, so this is a no-op on a healthy
# server and safe to run on every deploy.

function Test-AppCloned([string]$AppName) {
    $appPath = "$remoteAppsDir/$AppName"
    # sudo is required: /var/lib/docker/volumes is root-only, so an unprivileged
    # `test -d` cannot traverse it and reports every app as missing. That sends
    # healthy servers down the Ensure-AppCloned path, where `git clone` into the
    # existing non-empty directory exits non-zero and kills the deploy before it
    # reaches the pull. Every other volume access in this script uses sudo.
    $probe = Invoke-Remote "sudo test -d '$appPath/.git' && echo yes || echo no" -IgnoreExitCode
    return ($probe.Trim() -eq 'yes')
}

function Get-SiteInstalledApps([string]$BackendContainer) {
    $output = Invoke-Remote "docker exec $BackendContainer bench --site frontend list-apps" -IgnoreExitCode
    return @(
        $output -split "`r?`n" |
            ForEach-Object { ($_ -split '\s+')[0] } |
            Where-Object { $_ }
    )
}

function Ensure-AppCloned([string]$AppName) {
    $appPath = "$remoteAppsDir/$AppName"

    if (Test-AppCloned $AppName) {
        # Ownership is re-asserted on EVERY run, not just after a fresh clone.
        # `sudo git clone` produces root:root, and if anything interrupts the
        # bootstrap between the clone and the chown the app is left unusable —
        # the containers exec as uid 1000 (`ubuntu` on the host) and cannot write
        # it. Re-running would then skip the chown forever, because the clone now
        # exists. It is a cheap no-op when already correct.
        Invoke-Remote "sudo chown -R ubuntu:ubuntu $appPath" | Out-Null
        return $false
    }

    $repoUrl = $appRepos[$AppName]
    if (-not $repoUrl) {
        throw ("App '$AppName' is missing at $remoteAppsDir/$AppName and has no entry in " +
               "`$appRepos. Register its clone URL before adding it to `$deployedApps.")
    }

    Write-Step "Bootstrapping $AppName - cloning (first install)..."
    # --quiet is required, not cosmetic. git writes "Cloning into '...'" and its
    # progress meter to STDERR, and Invoke-Remote merges stderr with 2>&1. Under
    # Windows PowerShell 5.1 a native command's stderr becomes NativeCommandError
    # records, which $ErrorActionPreference='Stop' treats as fatal — so a
    # perfectly successful clone aborted the deploy mid-bootstrap, leaving the
    # repo on disk as root:root with no chown and no install.
    #
    # Full clone, never --depth: Assert-AppRepoIntegrity rejects shallow clones.
    Invoke-Remote "sudo GIT_SSH_COMMAND='$gitSshCommand' git clone --quiet $repoUrl $appPath" | Out-Null
    Invoke-Remote "sudo chown -R ubuntu:ubuntu $appPath" | Out-Null
    Write-Info "$AppName cloned"
    return $true
}

function Add-AppToBenchAppsTxt([string]$AppName, [string]$BackendContainer) {
    # bench only sees apps listed in sites/apps.txt. `bench get-app` maintains it;
    # a hand clone does not. Missing this line is precisely why an app can sit in
    # the bench forever without ever installing.
    $appsTxt = '/home/frappe/frappe-bench/sites/apps.txt'
    $inner = "grep -qxF '$AppName' $appsTxt || echo '$AppName' >> $appsTxt"
    $cmd = "docker exec -u root $BackendContainer bash -lc " + (ConvertTo-BashLiteral $inner)
    Invoke-Remote $cmd | Out-Null
}

# ── BOOTSTRAP-NOTES ──────────────────────────────────────────────────────────
# State of the jarz_courier first install as of 2026-08-05, and the order the
# steps must succeed in. On staging it is cloned at
# /var/lib/docker/volumes/erp_apps/_data/jarz_courier (uid 1000, full clone) but
# NOT yet pip-installed, so `bench install-app` still fails with
# ModuleNotFoundError. It has been removed from sites/apps.txt again — leaving a
# name there that Python cannot import makes `bench list-apps` print a traceback
# to stderr, which this script's Invoke-Remote turns into a fatal
# NativeCommandError and takes every deploy down with it.
#
# Remaining step, to run once and confirm before re-adding jarz_courier to
# $deployedApps:
#
#   docker exec -u root <backend> /home/frappe/frappe-bench/env/bin/pip \
#       install -e /home/frappe/frappe-bench/apps/jarz_courier
#   docker exec <backend> /home/frappe/frappe-bench/env/bin/python \
#       -c "import jarz_courier"      # must succeed before going further
#
# Then re-add it to $deployedApps and deploy: the bootstrap re-adds apps.txt,
# installs into all four service envs and runs `bench install-app`.
#
# Order is load-bearing throughout: clone -> chown -> pip install -> apps.txt ->
# install-app. Every earlier attempt failed by reaching a later step with an
# earlier one incomplete.
function Invoke-AppBootstrap {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$AppNames,

        [Parameter(Mandatory = $true)]
        [string]$BackendContainer,

        [Parameter(Mandatory = $true)]
        [hashtable]$ContainersByService,

        [switch]$ReportOnly
    )

    $missingClones = @($AppNames | Where-Object { -not (Test-AppCloned $_) })
    $installedApps = Get-SiteInstalledApps $BackendContainer
    # Checked for EVERY app on every deploy, not just freshly cloned ones: an app
    # can be on disk and pip-installed yet still absent from the site.
    $missingOnSite = @($AppNames | Where-Object { $installedApps -notcontains $_ })

    if ($ReportOnly) {
        foreach ($appName in $missingClones) {
            Write-Warn "$appName - would CLONE (not present on server)"
        }
        foreach ($appName in $missingOnSite) {
            Write-Warn "$appName - would INSTALL on site frontend"
        }
        if (-not $missingClones -and -not $missingOnSite) {
            Write-Info 'Bootstrap: all apps cloned and installed on site'
        }
        return
    }

    if (-not $missingClones -and -not $missingOnSite) {
        return
    }

    foreach ($appName in $AppNames) {
        [void](Ensure-AppCloned $appName)
    }

    # Prepare EVERY app that is not yet on the site, not just the ones cloned in
    # THIS run.
    #
    # Keying off "did I just clone it" assumes the bootstrap always completes,
    # and it does not: an interrupted run leaves the repo on disk, so the next
    # run sees it as already-cloned, skips apps.txt and the editable install, and
    # then `bench install-app` dies with
    #     ModuleNotFoundError: No module named '<app>'
    # because the package was never put on the Python path. Each step is
    # individually guarded, so redoing them is a cheap no-op.
    $needsPrep = @($missingOnSite)
    if ($needsPrep.Count -gt 0) {
        foreach ($appName in $needsPrep) {
            Add-AppToBenchAppsTxt $appName $BackendContainer
        }
        Write-Step "Installing into the Python env: $($needsPrep -join ', ')"
        # Deliberately NOT Install-EditableApps here. That function builds one
        # `bash -lc` script using `set -euo pipefail` and backgrounded jobs, and
        # it fails on this server with "bash: line 1: set: pipefail" — it only
        # ever fires when pyproject/requirements actually change, so that path
        # has evidently never run. Fixing it is its own change with its own
        # verification; the bootstrap must not depend on it.
        #
        # One plain docker exec per container instead: slower, but each has its
        # own exit code and its own error, and pip is already idempotent.
        foreach ($appName in $needsPrep) {
            foreach ($serviceName in $serviceNames) {
                $container = $ContainersByService[$serviceName]
                # `2>&1` is appended so the REMOTE shell merges the streams before
                # ssh ever writes them. Without it pip's routine warnings (e.g.
                # "Ignoring invalid distribution ...") arrive on ssh's stderr,
                # Windows PowerShell 5.1 wraps each line as a NativeCommandError,
                # and $ErrorActionPreference='Stop' kills the deploy on a pip run
                # that actually succeeded — leaving the app installed in the env
                # but never installed on the site. Exit codes still propagate, so
                # a real failure is still caught.
                Invoke-Remote ("docker exec -u root $container " +
                    "/home/frappe/frappe-bench/env/bin/pip install -q -e " +
                    "/home/frappe/frappe-bench/apps/$appName 2>&1") | Out-Null
            }
            Write-Info "$appName installed into all service envs"
        }
    }

    foreach ($appName in $AppNames) {
        if ($installedApps -contains $appName) {
            continue
        }
        Write-Step "Installing $appName on site frontend (first install)..."
        Invoke-Remote "docker exec $BackendContainer bench --site frontend install-app $appName" | Out-Null
        Write-Info "$appName installed on site"
    }
}

function Get-RemoteHttpCode {
    $output = ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i $SshKeyPath $sshTarget "curl -s -o /dev/null -w '%{http_code}' https://$($config.Domain) 2>/dev/null || echo 000" 2>$null
    return (($output -join "`n").Trim() -split "`r?`n")[-1]
}

Write-Host ''
Write-Info "============================================"
Write-Info "  Deploying to $($Environment.ToUpperInvariant()) ($($config.Domain))"
Write-Info "============================================"
Write-Host ''

if ($Environment -eq 'production' -and -not $Yes -and -not $PlanOnly) {
    Write-Warn 'You are about to deploy to PRODUCTION.'
    Write-Warn "Server: $($config.ServerIp) ($($config.Domain))"
    $confirmation = Read-Host 'Type yes to continue'
    if ($confirmation -ne 'yes') {
        Write-Info 'Deployment cancelled.'
        exit 0
    }
    Write-Host ''
}

Write-Step "Verifying SSH connection to $($config.ServerIp)..."
$null = Invoke-Remote 'echo ok'
Write-Info 'SSH connected'
Write-Host ''

$backendContainer = Resolve-ContainerName 'backend'
$frontendContainer = Resolve-ContainerName 'frontend'
$serviceContainers = @{}
foreach ($serviceName in $serviceNames) {
    $serviceContainers[$serviceName] = Resolve-ContainerName $serviceName
}

Write-Info "Backend container: $backendContainer"
Write-Info "Frontend container: $frontendContainer"
Write-Host ''

# MUST run before the Resolve-GitTarget loop below: that loop calls `git rev-parse`
# on every app path and hard-throws if the clone is absent, which would break this
# deploy and every other one until the app was cloned by hand.
Write-Step 'Checking app bootstrap state...'
Invoke-AppBootstrap `
    -AppNames $config.CustomApps `
    -BackendContainer $backendContainer `
    -ContainersByService $serviceContainers `
    -ReportOnly:$PlanOnly
Write-Host ''

$gitTargets = foreach ($appName in $config.CustomApps) {
    # Under -PlanOnly the bootstrap above only REPORTS what it would do, so an
    # app awaiting first install is still absent from disk. Resolve-GitTarget
    # runs `git rev-parse` against its path and hard-throws on a missing
    # directory, which crashed the plan immediately after correctly announcing
    # "would CLONE". A plan must never fail on the thing it just planned.
    #
    # Skipped only in report mode: a real deploy has already cloned the app by
    # the time control reaches here, so it resolves normally and keeps the full
    # integrity check.
    if ($PlanOnly -and -not (Test-AppCloned $appName)) {
        Write-Info "$appName - skipping git plan; pending first-install bootstrap"
        continue
    }

    $gitTarget = Resolve-GitTarget $appName
    Assert-AppRepoIntegrity $gitTarget
    $remoteUrl = Convert-GitHubRemoteToSsh $gitTarget
    $gitTarget.RemoteUrl = $remoteUrl
    $gitTarget.RemoteHead = Get-RemoteBranchHead $gitTarget
    $gitTarget.PendingUpdate = $gitTarget.HeadBefore -ne $gitTarget.RemoteHead
    $gitTarget
}

$appsNeedingUpdate = @($gitTargets | Where-Object { $_.PendingUpdate })
$deployRequired = $appsNeedingUpdate.Count -gt 0

if ($PlanOnly) {
    Write-Step 'Backend deploy plan'
    foreach ($gitTarget in $gitTargets) {
        $status = if ($gitTarget.PendingUpdate) { 'update-required' } else { 'current' }
        Write-Info "$($gitTarget.AppName): $status"
        Write-Host "        current: $($gitTarget.HeadBefore)"
        Write-Host "        target : $($gitTarget.RemoteHead)"
    }
    Write-Host ''
    Write-Output "DEPLOY_REQUIRED=$($deployRequired.ToString().ToLowerInvariant())"
    Write-Output "UPDATED_APPS=$((@($appsNeedingUpdate | ForEach-Object { $_.AppName }) -join ','))"
    exit 0
}

if ($config.RequiresBackup -and -not $SkipBackup -and $deployRequired) {
    Write-Step 'Taking production backup before deployment...'
    $backupOutput = Invoke-Remote "docker exec $backendContainer bench --site frontend backup --with-files"
    if ($backupOutput) {
        $backupOutput -split "`r?`n" | Select-Object -Last 3 | ForEach-Object { Write-Host $_ }
    }
    Write-Info 'Backup complete'
    Write-Host ''
}
elseif ($config.RequiresBackup -and $deployRequired) {
    Write-Step 'Skipping production backup (--SkipBackup)'
    Write-Host ''
}

Write-Step 'Pulling latest code for custom apps...'
foreach ($gitTarget in $gitTargets) {
    Write-Info "Using remote URL: $($gitTarget.RemoteUrl)"
    if (-not $gitTarget.PendingUpdate) {
        Write-Info "$($gitTarget.AppName) already at target commit $($gitTarget.HeadBefore)"
        continue
    }

    # Clear CI's untracked leftovers before pulling, but ONLY where they collide.
    #
    # backend-tests.yml runs on the self-hosted staging-docker runner and syncs the
    # branch under test straight into this live volume, then restores with
    # `git checkout -- .` — which only restores TRACKED files. Anything new in the
    # tested commit survives as an untracked leftover. That is genuinely inert until a
    # release adds a tracked file at the same path: `git pull` then aborts with
    # "untracked working tree files would be overwritten by merge" and the deploy dies
    # at the pull. f851371 hit exactly this — its new tests/test_v16_query_compat.py
    # collided with the copy CI had already left behind. It recurs on any release that
    # adds a file, because CI tests that commit against this volume first.
    #
    # Delete only untracked paths the incoming commit ADDS. That is provably
    # convergent: the pull writes the authoritative version at that exact path a
    # second later. Deliberately not `git clean` — this is a live volume and a broad
    # clean could take out anything else living here. --exclude-standard is correct:
    # ignored files are overwritten by merge without complaint and never block a pull.
    Invoke-Remote "sudo GIT_SSH_COMMAND='$gitSshCommand' git -c safe.directory=$($gitTarget.AppPath) -C $($gitTarget.AppPath) fetch --quiet $($gitTarget.RemoteName) $($gitTarget.BranchName)" | Out-Null

    $splitLines = { param($text) ($text -split "`r?`n") | ForEach-Object { $_.Trim() } | Where-Object { $_ } }
    $addedPaths = & $splitLines (Invoke-Remote "sudo git -c safe.directory=$($gitTarget.AppPath) -C $($gitTarget.AppPath) diff --diff-filter=A --name-only HEAD FETCH_HEAD" -IgnoreExitCode)
    $untrackedPaths = & $splitLines (Invoke-Remote "sudo git -c safe.directory=$($gitTarget.AppPath) -C $($gitTarget.AppPath) ls-files --others --exclude-standard" -IgnoreExitCode)

    $collisions = @($addedPaths | Where-Object { $untrackedPaths -contains $_ })
    if ($collisions.Count -gt 0) {
        Write-Info "Removing $($collisions.Count) untracked file(s) colliding with paths added by the incoming commit (CI leftovers):"
        $collisions | ForEach-Object { Write-Info "  - $_" }
        $quotedPaths = ($collisions | ForEach-Object { "'$($gitTarget.AppPath)/$_'" }) -join ' '
        Invoke-Remote "sudo rm -f $quotedPaths" | Out-Null
    }

    Write-Info "Pulling $($gitTarget.AppName) from $($gitTarget.RemoteName)/$($gitTarget.BranchName)"
    $pullOutput = Invoke-Remote "sudo GIT_SSH_COMMAND='$gitSshCommand' git -c safe.directory=$($gitTarget.AppPath) -C $($gitTarget.AppPath) pull --quiet $($gitTarget.RemoteName) $($gitTarget.BranchName)"
    if ($pullOutput) {
        Write-Host $pullOutput
    }

    $gitTarget.HeadAfter = (Invoke-Remote "sudo git -c safe.directory=$($gitTarget.AppPath) -C $($gitTarget.AppPath) rev-parse HEAD").Trim()
    $gitTarget.Changed = $gitTarget.HeadBefore -ne $gitTarget.HeadAfter
    $gitTarget.RequiresPipInstall = Test-AppRequiresEditableReinstall $gitTarget
    Write-Info "$($gitTarget.AppName) updated to $($gitTarget.HeadAfter)"

    # Normalise ownership to uid 1000 after every pull. The pull runs under sudo
    # (unavoidable — /var/lib/docker/volumes is only traversable by root), so every
    # file it rewrites lands as root:root. Nothing noticed while the deploy was the
    # only writer, but staging's CI execs as 'frappe' (uid 1000 = host 'ubuntu') and
    # cannot write root-owned files, so an un-normalised pull would break the test
    # gate on exactly the files a release just changed. The stray root-owned file on
    # the woo volume is a fossil of this. Idempotent, and cheap next to the pull.
    Invoke-Remote "sudo chown -R ubuntu:ubuntu $($gitTarget.AppPath)" | Out-Null

    if ($gitTarget.RequiresPipInstall) {
        Write-Info "$($gitTarget.AppName) queued for editable reinstall"
    }
}
Write-Host ''

$changedApps = @($gitTargets | Where-Object { $_.Changed })
$changedAppNames = @($changedApps | ForEach-Object { $_.AppName })

if ($changedAppNames.Count -eq 0 -and -not $ForceMigrate) {
    Write-Info 'No custom app commits changed on the target server. Skipping reinstall, asset relink, migrate, cache clear, and service restart.'
    Write-Host ''
}
else {
    if ($changedAppNames.Count -eq 0) {
        Write-Info 'No custom app commits changed, but -ForceMigrate was set: running migrate, cache clear, and service restart (e.g. fixture/schema changes already on the server but not yet migrated).'
        Write-Host ''
    }
    Write-Step 'Installing custom apps in backend and workers...'
    $appsNeedingInstall = @($gitTargets | Where-Object { $_.RequiresPipInstall } | ForEach-Object { $_.AppName })
    if ($appsNeedingInstall.Count -gt 0) {
        Install-EditableApps -AppNames $appsNeedingInstall -ContainersByService $serviceContainers
        foreach ($serviceName in $serviceNames) {
            $containerName = $serviceContainers[$serviceName]
            Write-Info "Installed $($appsNeedingInstall -join ', ') in $containerName"
        }
    }
    else {
        Write-Info 'Skipping editable reinstall; no dependency metadata changes detected. Use -ForceReinstallApps to override.'
    }
    Write-Host ''

    if ($changedAppNames -contains 'jarz_pos') {
        Write-Step 'Linking jarz_pos desk assets...'
        foreach ($assetContainer in @($backendContainer, $frontendContainer)) {
            $null = Invoke-Remote "docker exec -u root $assetContainer bash -lc 'mkdir -p /home/frappe/frappe-bench/sites/assets && ln -sfn /home/frappe/frappe-bench/apps/jarz_pos/jarz_pos/public /home/frappe/frappe-bench/sites/assets/jarz_pos'"
        }
        Write-Info 'Desk asset links refreshed'
        Write-Host ''
    }

    if (-not $SkipMigrate) {
        Write-Step 'Running bench migrate...'
        $null = Invoke-Remote "docker exec $backendContainer bench --site frontend migrate"
        Write-Info 'Migration complete'
    }
    else {
        Write-Step 'Skipping migration (--SkipMigrate)'
    }
    Write-Host ''

    Write-Step 'Clearing cache and restarting services...'
    Invoke-Remote "docker exec $backendContainer bench --site frontend clear-cache" | Out-Null
    Invoke-Remote "cd $remoteDir && docker compose restart backend queue-short queue-long scheduler >/dev/null 2>&1 || docker-compose restart backend queue-short queue-long scheduler >/dev/null 2>&1" | Out-Null
    # Restart the frontend nginx AFTER the backend is back up so it re-resolves the
    # backend's (possibly new) Docker network IP. Without this, nginx keeps the old
    # upstream IP cached and every edge/API request returns 502 (connect refused)
    # until the frontend is manually restarted. See the 2026-07-11 prod incident.
    Invoke-Remote "cd $remoteDir && docker compose restart frontend >/dev/null 2>&1 || docker-compose restart frontend >/dev/null 2>&1" | Out-Null
    Write-Info 'Services restarted (incl. frontend nginx)'
    Write-Host ''
}

Write-Step 'Checking deployed commit heads...'
foreach ($gitTarget in $gitTargets) {
    $headCommit = (Invoke-Remote "sudo git -c safe.directory=$($gitTarget.AppPath) -C $($gitTarget.AppPath) rev-parse HEAD").Trim()
    Write-Info "$($gitTarget.AppName): $headCommit"
}
Write-Host ''

Write-Step 'Running health check...'
$httpCode = '000'
for ($attempt = 1; $attempt -le 3; $attempt++) {
    $httpCode = Get-RemoteHttpCode
    if ($httpCode -in @('200', '301', '302')) {
        break
    }

    if ($attempt -lt 3) {
        Write-Warn "Health check returned HTTP $httpCode on attempt $attempt. Retrying..."
        Start-Sleep -Seconds 5
    }
}

Write-Host ''
Write-Info '============================================'
if ($httpCode -in @('200', '301', '302')) {
    Write-Info 'Deployment completed successfully'
    Write-Info "URL: https://$($config.Domain)"
    Write-Info "HTTP Status: $httpCode"
}
else {
    Write-Warn "Site returned HTTP $httpCode after restart. Containers may still be warming up."
    $containerStatus = Invoke-Remote "docker ps --format 'table {{.Names}}`t{{.Status}}' | grep -E 'erp-(backend|queue-short|queue-long|scheduler)-1|erp_(backend|queue-short|queue-long|scheduler)_1'" -IgnoreExitCode
    if ($containerStatus) {
        Write-Host $containerStatus
    }
}
Write-Info '============================================'
Write-Host ''