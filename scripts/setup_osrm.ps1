<#
.SYNOPSIS
    Stand up (or update) the self-hosted OSRM routing service on a server.

.DESCRIPTION
    OSRM turns the visit planner's straight-line estimates into real driving
    distances. This script is the only supported way to install it, so the
    thing running on a server is always reproducible from the repo rather than
    hand-assembled over SSH.

    It does NOT preprocess. Building the dataset peaks around 4.7 GB of RAM,
    and both ERP servers have less than that in total — preprocessing beside a
    live stack is how you OOM production. The dataset is built in WSL by
    scripts/osrm/build_dataset.sh and this script ships the finished files.

    The service is deliberately NOT internet-facing. It joins the ERP docker
    network so `http://osrm:5000` resolves from erp-backend, all three
    queue/scheduler workers and jarz_courier, and from nowhere else. OSRM has
    no authentication of any kind; anyone who can reach it can run unlimited
    matrix queries.

.PARAMETER Environment
    staging | production

.PARAMETER Algorithm
    mld (default) or ch. Measured, not guessed — see build_dataset.sh output.

.PARAMETER Mmap
    Serve the dataset memory-mapped. Lower resident set, the kernel pages data
    in on demand and can evict it under pressure. The right trade on a box
    sharing RAM with an ERP stack.

.PARAMETER MemLimit
    Hard container memory ceiling, e.g. '1600m'. OSRM is the optional half of
    this system; the database is not.

.PARAMETER SkipUpload
    Reconfigure and restart without re-sending the dataset (it is ~1-2 GB).

.PARAMETER PlanOnly
    Report what would happen and change nothing.

.EXAMPLE
    ./setup_osrm.ps1 -Environment production -Algorithm mld -Mmap
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('staging', 'production')]
    [string]$Environment,

    [ValidateSet('mld', 'ch')]
    [string]$Algorithm = 'mld',

    [switch]$Mmap,

    [string]$Dataset = 'jarz-north',

    [string]$MemLimit = '1600m',

    [int]$MaxTableSize = 2000,

    [switch]$SkipUpload,
    [switch]$PlanOnly,

    [string]$SshKeyPath,

    # Where build_dataset.sh left the finished files, as a WSL path.
    [string]$WslDataDir = '$HOME/osrm-build'
)

$ErrorActionPreference = 'Stop'

$hosts = @{
    staging    = '13.36.219.136'
    production = '13.36.132.13'
}
$targetHost = $hosts[$Environment]
$sshTarget = "ubuntu@$targetHost"

$repoRoot = Split-Path -Parent $PSScriptRoot
$workspaceRoot = Split-Path -Parent $repoRoot
if (-not $SshKeyPath) {
    $SshKeyPath = Join-Path $workspaceRoot 'ERPNext-stg.pem'
}
if (-not (Test-Path $SshKeyPath)) {
    throw "SSH key not found at $SshKeyPath. Pass -SshKeyPath."
}

$remoteRoot = '/home/ubuntu/osrm'
$remoteData = "$remoteRoot/data"

function Write-Step($m) { Write-Host "`n[STEP] $m" -ForegroundColor Cyan }
function Write-Info($m) { Write-Host "[INFO] $m" -ForegroundColor Gray }
function Write-Warn($m) { Write-Host "[WARN] $m" -ForegroundColor Yellow }

function Invoke-Remote {
    param([Parameter(Mandatory = $true)][string]$Command, [switch]$IgnoreExitCode)
    # `2>&1` on the REMOTE side: without it, ordinary stderr chatter arrives on
    # ssh's stderr, PowerShell 5.1 wraps each line as a NativeCommandError and
    # $ErrorActionPreference='Stop' kills a step that actually succeeded.
    $output = ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=15 -i $SshKeyPath $sshTarget $Command 2>&1
    $code = $LASTEXITCODE
    if ($code -ne 0 -and -not $IgnoreExitCode) {
        throw "Remote command failed ($code): $Command`n$($output -join "`n")"
    }
    return ($output -join "`n").TrimEnd()
}

function Invoke-RemoteScript {
    <#
        Run a multi-line shell script on the server without fighting quoting.

        A command with nested quotes has to survive PowerShell, then ssh's
        argument handling, then the remote shell — and one of those layers
        always eats something. base64 is alphanumeric, so nothing can be eaten;
        this is the same trick remote_exec.ps1 and the bench-console helpers
        use, for the same reason.
    #>
    param([Parameter(Mandatory = $true)][string]$Script, [switch]$IgnoreExitCode)
    $encoded = [Convert]::ToBase64String(
        [Text.Encoding]::UTF8.GetBytes(($Script -replace "`r`n", "`n")))
    return Invoke-Remote "echo $encoded | base64 -d | bash" -IgnoreExitCode:$IgnoreExitCode
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  OSRM setup - $($Environment.ToUpper()) ($targetHost)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Step 'Verifying SSH...'
$null = Invoke-Remote 'echo ok'
Write-Info 'SSH connected'

Write-Step 'Checking the ERP docker network...'
$network = Invoke-Remote "docker network ls --format '{{.Name}}' | grep -E 'frappe_network|erp' | head -1" -IgnoreExitCode
if (-not $network) { throw 'Could not find the ERP docker network on this server.' }
Write-Info "network=$network"

Write-Step 'Checking headroom...'
# No awk in these remote one-liners: its braces and quotes have to survive
# PowerShell, ssh and the remote shell, and one of those layers always eats
# them. grep + split on this side is boring and works.
$mem = Invoke-Remote "free -m | grep '^Mem:'"
$parts = @(($mem -split '\s+') | Where-Object { $_ })
Write-Info "memory: total=$($parts[1])MB available=$($parts[6])MB"
$diskAvail = Invoke-Remote "df -BG / | tail -1 | tr -s ' ' | cut -d' ' -f4 | tr -d 'G'"
Write-Info "disk available: ${diskAvail}GB"
if ([int]$diskAvail -lt 6) { throw "Only ${diskAvail}GB free; the dataset needs several GB." }

# ---------------------------------------------------------------------------
# Which files does the server actually need?
#
# The build leaves ~2 GB, but `.ebg` and `.enw` are extract-time intermediates
# and `.osm.pbf` is the raw input. Shipping them would add ~350 MB to every
# upload for files osrm-routed never opens.
# ---------------------------------------------------------------------------
$excluded = @('*.osm.pbf', '*.osrm.ebg', '*.osrm.enw')
$excludeArgs = ($excluded | ForEach-Object { "--exclude='$_'" }) -join ' '

$mmapFlag = if ($Mmap) { '--mmap' } else { '' }

Write-Step 'Plan'
Write-Info "dataset=$Dataset algorithm=$Algorithm mmap=$($Mmap.IsPresent) mem_limit=$MemLimit"
Write-Info "remote_data=$remoteData"
Write-Info "excluded_from_upload=$($excluded -join ', ')"
if ($PlanOnly) { Write-Warn 'PlanOnly - nothing changed.'; exit 0 }

Write-Step 'Preparing the remote directory...'
$null = Invoke-Remote "mkdir -p '$remoteData' && chmod 755 '$remoteRoot' '$remoteData'"
Write-Info 'ready'

if (-not $SkipUpload) {
    Write-Step 'Uploading the dataset (streamed tar over ssh)...'
    # Run the upload FROM WSL: the files live in the WSL filesystem, and one
    # streamed tar beats scp-ing 20-odd files over 20-odd connections.
    # The key is copied to the WSL side because ssh refuses a key whose
    # permissions it cannot tighten on a 9p mount.
    $wslKey = '/tmp/.osrm_deploy_key'
    $winKey = (Resolve-Path $SshKeyPath).Path -replace '\\', '/' -replace '^([A-Za-z]):', '/mnt/$1'
    # The drive letter must be LOWER case: /mnt/C does not exist under WSL's
    # default automount, so an upper-case one fails with a bare "No such file".
    $winKey = '/mnt/' + $winKey.Substring(5, 1).ToLower() + $winKey.Substring(6)

    $uploadCmd = @"
set -euo pipefail
cp '$winKey' $wslKey && chmod 600 $wslKey
cd $WslDataDir
# osrm-extract/partition/customize run as root inside the container, so some
# artifacts land root-owned and tar cannot read them as the WSL user.
sudo chown -R "`$(id -u):`$(id -g)" . 2>/dev/null || true
FILES=`$(ls -1 ${Dataset}.osrm* 2>/dev/null | grep -v -E '\.(ebg|enw)`$' || true)
if [ -z "`$FILES" ]; then echo "NO DATASET FILES for ${Dataset} in $WslDataDir" >&2; exit 1; fi
echo "shipping `$(echo "`$FILES" | wc -l) files, `$(du -ch `$FILES | tail -1 | cut -f1)"
tar cf - `$FILES | gzip -1 | ssh -o StrictHostKeyChecking=no -o LogLevel=ERROR -i $wslKey $sshTarget 'cat > /tmp/osrm-data.tgz'
rm -f $wslKey
echo UPLOAD_OK
"@
    # Written to a file and run as `bash <file>`, NOT passed to `bash -c`:
    # PowerShell splits a multi-line string into one argument per line when it
    # hands it to a native command, so the remote shell only ever saw line 1
    # and died on "unexpected end of file".
    $uploadScript = Join-Path ([IO.Path]::GetTempPath()) 'jarz_osrm_upload.sh'
    [IO.File]::WriteAllText($uploadScript, ($uploadCmd -replace "`r`n", "`n"))
    $uploadScriptWsl = ($uploadScript -replace '\\', '/' -replace '^([A-Za-z]):', '/mnt/$1')
    $uploadScriptWsl = '/mnt/' + $uploadScriptWsl.Substring(5, 1).ToLower() + $uploadScriptWsl.Substring(6)

    # Windows PowerShell 5.1 wraps every native stderr line as a
    # NativeCommandError, and $ErrorActionPreference='Stop' then kills a
    # transfer that is merely being chatty (ssh's "Permanently added ... to
    # the list of known hosts" is enough). Success is judged by the UPLOAD_OK
    # marker below, not by the absence of stderr.
    $previousEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $uploadOut = wsl -d Ubuntu-24.04 -- bash $uploadScriptWsl 2>&1
    $ErrorActionPreference = $previousEap
    Remove-Item $uploadScript -ErrorAction SilentlyContinue
    $uploadOut | Where-Object { $_ -match 'shipping|UPLOAD_OK|NO DATASET|error' } | ForEach-Object { Write-Info $_ }
    if (($uploadOut -join "`n") -notmatch 'UPLOAD_OK') {
        throw "Dataset upload failed:`n$($uploadOut -join "`n")"
    }

    Write-Step 'Unpacking on the server...'
    $null = Invoke-Remote "cd '$remoteData' && tar xzf /tmp/osrm-data.tgz && rm -f /tmp/osrm-data.tgz && ls -1 | wc -l"
    $count = Invoke-Remote "ls -1 '$remoteData' | wc -l"
    $size = Invoke-Remote "du -sh '$remoteData' | cut -f1"
    Write-Info "unpacked: $count files, $size"
}

Write-Step 'Writing compose + env...'
$composeLocal = Join-Path $PSScriptRoot 'osrm/docker-compose.yml'
if (-not (Test-Path $composeLocal)) { throw "Missing $composeLocal" }
& scp -o StrictHostKeyChecking=no -i $SshKeyPath $composeLocal "${sshTarget}:$remoteRoot/docker-compose.yml" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'compose upload failed' }

$envBody = @"
OSRM_ALGORITHM=$Algorithm
OSRM_MMAP_FLAG=$mmapFlag
OSRM_DATASET=$Dataset
OSRM_DATA_DIR=$remoteData
OSRM_MEM_LIMIT=$MemLimit
OSRM_MAX_TABLE=$MaxTableSize
ERP_NETWORK=$network
"@
$envEncoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($envBody))
$null = Invoke-Remote "echo '$envEncoded' | base64 -d > '$remoteRoot/.env' && cat '$remoteRoot/.env'"
Write-Info 'compose + env written'

Write-Step 'Starting OSRM...'
$null = Invoke-Remote "cd '$remoteRoot' && (docker compose up -d --remove-orphans 2>&1 || docker-compose up -d --remove-orphans 2>&1)"
Write-Info 'container started'

Write-Step 'Waiting for it to answer...'
# Asks the real question: is OSRM up, does it have data at this spot, and can
# the ERP backend container reach it on the shared docker network. Sent
# base64-encoded so no quoting layer can mangle it.
$probeScript = @'
docker exec erp-backend-1 python -c "
import urllib.request as u
try:
    body = u.urlopen('http://osrm:5000/route/v1/driving/31.2357,30.0444;31.2197,30.0614?overview=false', timeout=8).read().decode()
    print('OSRM_OK' if '\"code\":\"Ok\"' in body else 'OSRM_BAD ' + body[:120])
except Exception as exc:
    print('OSRM_DOWN', type(exc).__name__, exc)
"
'@
$ok = $false
for ($i = 1; $i -le 30; $i++) {
    $out = Invoke-RemoteScript $probeScript -IgnoreExitCode
    if ($out -match 'OSRM_OK') { $ok = $true; break }
    Start-Sleep -Seconds 5
}
if (-not $ok) {
    Write-Warn 'OSRM did not answer from inside the ERP network. Last 20 log lines:'
    Invoke-Remote "docker logs osrm 2>&1 | tail -20" -IgnoreExitCode | Write-Host
    throw 'OSRM failed its readiness probe.'
}
Write-Info 'OSRM answers on http://osrm:5000 from erp-backend-1'

# The script that installs the service also points the app at it. Leaving that
# to a human is how a server ends up running a routing engine nothing calls —
# silently, because the fallback works and nothing looks broken.
Write-Step 'Pointing Jarz POS Settings at the service...'
# Through `bench console` with a base64-encoded body: a bare `python -c` has no
# site context, and `bench execute` wants a dotted path rather than a snippet.
# This is the same shape remote_exec.ps1 uses, for the same reason.
$settingBody = @"
import frappe
frappe.db.set_single_value('Jarz POS Settings', 'visit_osrm_base_url', 'http://osrm:5000')
frappe.db.commit()
frappe.clear_cache()
print('CONFIGURED', frappe.db.get_single_value('Jarz POS Settings', 'visit_osrm_base_url'))
"@
$settingB64 = [Convert]::ToBase64String(
    [Text.Encoding]::UTF8.GetBytes(($settingBody -replace "`r`n", "`n")))
$configureScript = @"
cd /home/ubuntu
docker exec -i erp-backend-1 bash -lc "cd /home/frappe/frappe-bench && echo 'import base64; exec(base64.b64decode(\"$settingB64\").decode())' | bench --site frontend console" 2>&1 | grep -a CONFIGURED || true
"@
# stderr from bench is chatty; success is judged by the CONFIGURED marker.
$previousEap = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$configured = Invoke-RemoteScript $configureScript -IgnoreExitCode
$ErrorActionPreference = $previousEap
$configured -split "`n" | Where-Object { $_ -match 'CONFIGURED' } | ForEach-Object { Write-Info $_.Trim() }
if ($configured -notmatch 'http://osrm:5000') {
    Write-Warn 'Could not confirm the setting. Set Jarz POS Settings -> visit_osrm_base_url = http://osrm:5000 by hand.'
}

Write-Step 'Resident memory'
Invoke-Remote "docker stats --no-stream --format '  osrm mem={{.MemUsage}} cpu={{.CPUPerc}}' osrm" -IgnoreExitCode | Write-Host
$after = Invoke-Remote "free -m | grep '^Mem:'" -IgnoreExitCode
$ap = @(($after -split '\s+') | Where-Object { $_ })
Write-Host "  host: total=$($ap[1])MB available=$($ap[6])MB"

Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  OSRM is live on $Environment" -ForegroundColor Green
Write-Host "  Internal URL: http://osrm:5000  (not internet-facing)" -ForegroundColor Green
Write-Host "  Jarz POS Settings -> visit_osrm_base_url points at it." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
