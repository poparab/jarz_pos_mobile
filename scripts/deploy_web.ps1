param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('staging', 'production')]
    [string]$Environment,

    [switch]$PlanOnly,
    [switch]$ForceDeploy,
    [string]$SshKeyPath
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$workspaceRoot = Split-Path -Parent $repoRoot
if (-not $SshKeyPath) {
    $SshKeyPath = Join-Path $workspaceRoot 'ERPNext-stg.pem'
}

$remoteWebDir = '/home/ubuntu/pos-web/web'
$remoteMetaPath = "$remoteWebDir/release-metadata.json"

if (-not (Test-Path $SshKeyPath)) {
    throw "SSH key not found at $SshKeyPath"
}

$config = switch ($Environment) {
    'staging' {
        @{
            ServerIp = '13.36.219.136'
            PosUrl = 'https://erpstg.orderjarz.com/pos/'
        }
    }
    'production' {
        @{
            ServerIp = '13.36.132.13'
            PosUrl = 'https://erp.orderjarz.com/pos/'
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

function Invoke-Git {
    param([string[]]$Arguments)

    $output = & git -C $repoRoot @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "git -C $repoRoot $($Arguments -join ' ') failed ($exitCode)`n$($output -join "`n")"
    }

    return ($output -join "`n").TrimEnd()
}

function Test-WebRuntimeImpact([string[]]$Paths) {
    foreach ($path in $Paths) {
        if (
            $path.StartsWith('assets/') -or
            $path.StartsWith('lib/') -or
            $path.StartsWith('tool/') -or
            $path.StartsWith('web/') -or
            $path.StartsWith('server-config/pos-web/') -or
            $path -eq '.env.prod' -or
            $path -eq '.env.staging' -or
            $path -eq 'l10n.yaml' -or
            $path -eq 'pubspec.yaml' -or
            $path -eq 'pubspec.lock' -or
            $path -eq 'scripts/build_release.bat' -or
            $path -eq 'scripts/build_release.sh'
        ) {
            return $true
        }
    }

    return $false
}

function Get-RepoHead {
    return (Invoke-Git -Arguments @('rev-parse', 'HEAD')).Trim()
}

function Get-RemoteReleaseMetadata {
    $raw = Invoke-Remote "test -f $remoteMetaPath && cat $remoteMetaPath" -IgnoreExitCode
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return $null
    }

    try {
        return $raw | ConvertFrom-Json
    }
    catch {
        Write-Warn 'Remote web release metadata is not valid JSON; treating web as out of date.'
        return $null
    }
}

function Get-RemoteMainHash {
    return (Invoke-Remote "test -f $remoteWebDir/main.dart.js && sha256sum $remoteWebDir/main.dart.js | cut -d ' ' -f1" -IgnoreExitCode).Trim().ToLowerInvariant()
}

function Test-WebDeployRequired {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LocalHead,

        [Parameter(Mandatory = $false)]
        $RemoteMetadata
    )

    if ($ForceDeploy) {
        return @{
            Required = $true
            Reason = 'force-deploy'
        }
    }

    if (-not $RemoteMetadata -or -not $RemoteMetadata.commit_sha) {
        return @{
            Required = $true
            Reason = 'missing-remote-metadata'
        }
    }

    $remoteCommit = "$($RemoteMetadata.commit_sha)".Trim()
    if ($remoteCommit -eq $LocalHead -and "$($RemoteMetadata.environment)" -eq $Environment) {
        return @{
            Required = $false
            Reason = 'same-commit-already-deployed'
        }
    }

    & git -C $repoRoot cat-file -e "$remoteCommit^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0) {
        return @{
            Required = $true
            Reason = 'remote-commit-not-present-locally'
        }
    }

    $diffOutput = Invoke-Git -Arguments @('diff', '--name-only', $remoteCommit, $LocalHead)
    $paths = @()
    if (-not [string]::IsNullOrWhiteSpace($diffOutput)) {
        $paths = @($diffOutput -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    }

    if (-not (Test-WebRuntimeImpact $paths)) {
        return @{
            Required = $false
            Reason = 'no-web-impacting-paths-since-last-web-deploy'
        }
    }

    return @{
        Required = $true
        Reason = 'web-impacting-paths-changed'
    }
}

Write-Host ''
Write-Info "============================================"
Write-Info "  Deploying Web to $($Environment.ToUpperInvariant())"
Write-Info "============================================"
Write-Host ''

Write-Step "Checking web host $($config.ServerIp)..."
$null = Invoke-Remote 'echo ok'
Write-Info 'SSH connected'
Write-Host ''

$localHead = Get-RepoHead
$remoteMetadata = Get-RemoteReleaseMetadata
$webDecision = Test-WebDeployRequired -LocalHead $localHead -RemoteMetadata $remoteMetadata

if ($PlanOnly) {
    Write-Step 'Web deploy plan'
    Write-Info "local_head=$localHead"
    if ($remoteMetadata) {
        Write-Info "remote_web_commit=$($remoteMetadata.commit_sha)"
        Write-Info "remote_web_environment=$($remoteMetadata.environment)"
    }
    else {
        Write-Info 'remote_web_commit=unknown'
    }
    Write-Info "web_reason=$($webDecision.Reason)"
    Write-Output "WEB_DEPLOY_REQUIRED=$($webDecision.Required.ToString().ToLowerInvariant())"
    exit 0
}

if (-not $webDecision.Required) {
    Write-Info "Skipping web deploy: $($webDecision.Reason)"
    Write-Host ''
    exit 0
}

Write-Step 'Building Flutter web release...'
$buildStdoutPath = [System.IO.Path]::GetTempFileName()
$buildStderrPath = [System.IO.Path]::GetTempFileName()
try {
    $buildProcess = Start-Process -FilePath 'cmd.exe' `
        -ArgumentList '/c', """$repoRoot\scripts\build_release.bat"" $Environment web" `
        -WorkingDirectory $repoRoot `
        -NoNewWindow `
        -Wait `
        -PassThru `
        -RedirectStandardOutput $buildStdoutPath `
        -RedirectStandardError $buildStderrPath

    $buildOutput = @()
    if (Test-Path $buildStdoutPath) {
        $buildOutput += Get-Content -Path $buildStdoutPath
    }
    if (Test-Path $buildStderrPath) {
        $buildOutput += Get-Content -Path $buildStderrPath
    }

    if ($buildProcess.ExitCode -ne 0) {
        throw "Flutter web build failed ($($buildProcess.ExitCode))`n$($buildOutput -join "`n")"
    }

    if ($buildOutput) {
        $buildOutput | ForEach-Object { Write-Host $_ }
    }
}
finally {
    Remove-Item -Path $buildStdoutPath, $buildStderrPath -ErrorAction SilentlyContinue
}
Write-Host ''

$localMainPath = Join-Path $repoRoot 'build\web\main.dart.js'
if (-not (Test-Path $localMainPath)) {
    throw "Web build output not found at $localMainPath"
}

$localHash = (Get-FileHash $localMainPath -Algorithm SHA256).Hash.ToLowerInvariant()
$releaseMetadata = [ordered]@{
    commit_sha = $localHead
    environment = $Environment
    generated_at_utc = (Get-Date).ToUniversalTime().ToString('o')
    main_dart_js_sha256 = $localHash
}
$localMetaPath = Join-Path $repoRoot 'build\web\release-metadata.json'
$releaseMetadata | ConvertTo-Json | Set-Content -Path $localMetaPath -Encoding UTF8

Write-Step 'Uploading web bundle to server...'
$null = Invoke-Remote "rm -rf $remoteWebDir ; mkdir -p $remoteWebDir"
& scp -o StrictHostKeyChecking=no -i $SshKeyPath -r "$repoRoot\build\web\*" "${sshTarget}:$remoteWebDir/" 2>&1 | ForEach-Object { Write-Host $_ }
if ($LASTEXITCODE -ne 0) {
    throw 'Web bundle upload failed'
}
Write-Host ''

Write-Step 'Rebuilding pos-web container...'
$null = Invoke-Remote "docker ps -aq --filter name=pos-web | xargs -r docker rm -f >/dev/null 2>&1 || true ; cd /home/ubuntu/pos-web && docker compose up -d --build --no-deps pos-web >/dev/null 2>&1 || docker-compose up -d --build --no-deps pos-web >/dev/null 2>&1"
Write-Info 'pos-web restarted'
Write-Host ''

Write-Step 'Verifying deployed web artifact...'
$remoteHash = Get-RemoteMainHash
if (-not $remoteHash) {
    throw 'Could not read remote main.dart.js hash after web deploy'
}
if ($remoteHash -ne $localHash) {
    throw "Remote web hash mismatch. local=$localHash remote=$remoteHash"
}
$httpResponse = Invoke-WebRequest -UseBasicParsing -Uri $config.PosUrl -TimeoutSec 60
Write-Info "Local main.dart.js hash: $localHash"
Write-Info "Remote main.dart.js hash: $remoteHash"
Write-Info "POS web HTTP status: $($httpResponse.StatusCode)"
Write-Host ''