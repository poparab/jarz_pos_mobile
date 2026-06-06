param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('staging', 'production')]
    [string]$Environment,

    [switch]$PlanOnly,
    [switch]$SkipMigrate,
    [switch]$SkipBackup,
    [switch]$ForceReinstallApps,
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

$config = switch ($Environment) {
    'staging' {
        @{
            ServerIp = '13.36.219.136'
            Domain = 'erpstg.orderjarz.com'
            CustomApps = @('jarz_pos', 'jarz_woocommerce_integration')
            RequiresBackup = $false
        }
    }
    'production' {
        @{
            ServerIp = '13.36.132.13'
            Domain = 'erp.orderjarz.com'
            CustomApps = @('jarz_pos', 'jarz_woocommerce_integration', 'hrms')
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

$gitTargets = foreach ($appName in $config.CustomApps) {
    $gitTarget = Resolve-GitTarget $appName
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

    Write-Info "Pulling $($gitTarget.AppName) from $($gitTarget.RemoteName)/$($gitTarget.BranchName)"
    $pullOutput = Invoke-Remote "sudo GIT_SSH_COMMAND='$gitSshCommand' git -c safe.directory=$($gitTarget.AppPath) -C $($gitTarget.AppPath) pull --quiet $($gitTarget.RemoteName) $($gitTarget.BranchName)"
    if ($pullOutput) {
        Write-Host $pullOutput
    }

    $gitTarget.HeadAfter = (Invoke-Remote "sudo git -c safe.directory=$($gitTarget.AppPath) -C $($gitTarget.AppPath) rev-parse HEAD").Trim()
    $gitTarget.Changed = $gitTarget.HeadBefore -ne $gitTarget.HeadAfter
    $gitTarget.RequiresPipInstall = Test-AppRequiresEditableReinstall $gitTarget
    Write-Info "$($gitTarget.AppName) updated to $($gitTarget.HeadAfter)"

    if ($gitTarget.RequiresPipInstall) {
        Write-Info "$($gitTarget.AppName) queued for editable reinstall"
    }
}
Write-Host ''

$changedApps = @($gitTargets | Where-Object { $_.Changed })
$changedAppNames = @($changedApps | ForEach-Object { $_.AppName })

if ($changedAppNames.Count -eq 0) {
    Write-Info 'No custom app commits changed on the target server. Skipping reinstall, asset relink, migrate, cache clear, and service restart.'
    Write-Host ''
}
else {
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
    Write-Info 'Services restarted'
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