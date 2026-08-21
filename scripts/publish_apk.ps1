<#
.SYNOPSIS
    Publishes the signed Android APK to the pos-web server so internal staff can install it
    from https://<host>/pos/download/ without a Firebase App Distribution account.

.DESCRIPTION
    Firebase App Distribution stays the primary channel (invite links, in-app update
    notifications). This script is the zero-account fallback: it takes the exact APK that CI
    built and distributed, publishes it next to the Flutter web build, and rebuilds the
    pos-web container so nginx serves it.

    Two server-side details drive the design:
      * pos-web/Dockerfile COPYs web/ into the image, so the container MUST be rebuilt after
        the file lands; dropping the APK on the host alone serves nothing.
      * deploy_web.ps1 wipes web/ before every upload, so the APK cannot live in web/ alone.
        The durable copy lives in /home/ubuntu/pos-web/downloads and is mirrored into
        web/download here, and again at the end of every web deploy.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\publish_apk.ps1 -Environment production
    Publishes the newest successful production full_apk build from GitHub Actions.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\publish_apk.ps1 -Environment staging -RunId 32481123362
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('staging', 'production')]
    [string]$Environment,

    # Specific Android Release run to publish. Defaults to the newest successful run for
    # this environment that produced an APK artifact.
    [string]$RunId,

    # Publish a local APK instead of a CI artifact (validation builds only).
    [string]$ApkPath,

    [string]$SshKeyPath,
    [switch]$PlanOnly
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$workspaceRoot = Split-Path -Parent $repoRoot
if (-not $SshKeyPath) {
    $SshKeyPath = Join-Path $workspaceRoot 'ERPNext-stg.pem'
}

$ghRepo = 'poparab/jarz_pos_mobile'
$remoteRoot = '/home/ubuntu/pos-web'
$remoteStoreDir = "$remoteRoot/downloads"
$remoteWebDir = "$remoteRoot/web"
$remoteServedDir = "$remoteWebDir/download"
$localPageTemplate = Join-Path $repoRoot 'scripts\pos-web\download-page.html'

$config = switch ($Environment) {
    'staging' {
        @{
            ServerIp = '13.36.219.136'
            BaseUrl  = 'https://erpstg.orderjarz.com'
            EnvLabel = 'Staging'
        }
    }
    'production' {
        @{
            ServerIp = '13.36.132.13'
            BaseUrl  = 'https://erp.orderjarz.com'
            EnvLabel = 'Production'
        }
    }
}

$apkFileName = "jarz-pos-$Environment-latest.apk"
$downloadUrl = "$($config.BaseUrl)/pos/download/"
$apkUrl = "$downloadUrl$apkFileName"
$sshTarget = "ubuntu@$($config.ServerIp)"

function Write-Info([string]$Message) { Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Step([string]$Message) { Write-Host "[STEP] $Message" -ForegroundColor Cyan }

function Invoke-Remote {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [switch]$IgnoreExitCode
    )

    $output = ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i $SshKeyPath $sshTarget $Command 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0 -and -not $IgnoreExitCode) {
        throw "Remote command failed ($exitCode): $Command`n$($output -join "`n")"
    }

    return ($output -join "`n").TrimEnd()
}

function Invoke-Scp {
    param(
        [Parameter(Mandatory = $true)][string]$LocalPath,
        [Parameter(Mandatory = $true)][string]$RemotePath
    )

    & scp -o StrictHostKeyChecking=no -i $SshKeyPath $LocalPath "${sshTarget}:$RemotePath" 2>&1 |
        ForEach-Object { Write-Host $_ }
    if ($LASTEXITCODE -ne 0) {
        throw "Upload failed: $LocalPath -> $RemotePath"
    }
}

function Invoke-Gh {
    param([string[]]$Arguments)

    $output = & gh @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "gh $($Arguments -join ' ') failed ($LASTEXITCODE)`n$($output -join "`n")"
    }

    return ($output -join "`n")
}

function Get-RunArtifacts {
    param([string]$Id)

    $raw = Invoke-Gh -Arguments @(
        'api', "repos/$ghRepo/actions/runs/$Id/artifacts",
        '--jq', '[.artifacts[] | {name, expired, size: .size_in_bytes}]'
    )

    return ($raw | ConvertFrom-Json)
}

# --- Preflight ---------------------------------------------------------------

if (-not (Test-Path $SshKeyPath)) {
    throw "SSH key not found at $SshKeyPath"
}
if (-not (Test-Path $localPageTemplate)) {
    throw "Download page template not found at $localPageTemplate"
}

Write-Step "Publishing the $($config.EnvLabel) APK to $($config.ServerIp)"
Write-Info "download_page=$downloadUrl"
Write-Info "apk_url=$apkUrl"
Write-Host ''

# --- Resolve the APK ---------------------------------------------------------

$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "jarz-apk-publish-$Environment"
$metadata = $null
$localApk = $null

if ($ApkPath) {
    if (-not (Test-Path $ApkPath)) {
        throw "APK not found at $ApkPath"
    }
    $localApk = (Resolve-Path $ApkPath).Path
    Write-Warn 'Publishing a local APK; prefer a CI artifact so the served build matches what Firebase distributed.'
    if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
}
else {
    Write-Step 'Resolving the APK artifact from GitHub Actions...'

    if (-not $RunId) {
        $runsRaw = Invoke-Gh -Arguments @(
            'run', 'list', '--repo', $ghRepo, '--workflow', 'Android Release',
            '--branch', 'main', '--limit', '40',
            '--json', 'databaseId,displayTitle,conclusion,createdAt'
        )
        $runs = $runsRaw | ConvertFrom-Json |
            Where-Object { $_.conclusion -eq 'success' -and $_.displayTitle -like "* / $Environment / *" }

        foreach ($run in $runs) {
            # A Shorebird patch run reports success but uploads no APK, so the artifact list
            # -- not the run title -- decides which run is publishable.
            $artifacts = Get-RunArtifacts -Id $run.databaseId
            $candidate = $artifacts |
                Where-Object { $_.name -like "$Environment-release-v*" -and -not $_.expired } |
                Select-Object -First 1
            if ($candidate) {
                $RunId = "$($run.databaseId)"
                Write-Info "run=$RunId ($($run.displayTitle), $($run.createdAt))"
                break
            }
        }

        if (-not $RunId) {
            throw "No successful $Environment run in the last 40 carries an unexpired APK artifact. GitHub keeps artifacts for 14 days -- dispatch a fresh full_apk build, or pass -ApkPath."
        }
    }

    $artifacts = Get-RunArtifacts -Id $RunId
    $apkArtifact = $artifacts | Where-Object { $_.name -like "$Environment-release-v*" } | Select-Object -First 1
    if (-not $apkArtifact) {
        throw "Run $RunId has no $Environment APK artifact (Shorebird patch runs do not produce one)."
    }
    if ($apkArtifact.expired) {
        throw "Artifact $($apkArtifact.name) has expired; dispatch a fresh full_apk build."
    }
    $metaArtifact = $artifacts |
        Where-Object { $_.name -like "$Environment-release-metadata-*" -and -not $_.expired } |
        Select-Object -First 1

    if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    Write-Info "artifact=$($apkArtifact.name)"
    $null = Invoke-Gh -Arguments @('run', 'download', $RunId, '--repo', $ghRepo, '-n', $apkArtifact.name, '-D', $tempDir)

    if ($metaArtifact) {
        $null = Invoke-Gh -Arguments @('run', 'download', $RunId, '--repo', $ghRepo, '-n', $metaArtifact.name, '-D', $tempDir)
        $metaFile = Get-ChildItem -Path $tempDir -Filter '*release-metadata.json' -Recurse -File | Select-Object -First 1
        if ($metaFile) {
            $metadata = Get-Content -Path $metaFile.FullName -Raw | ConvertFrom-Json
        }
    }

    $apkFile = Get-ChildItem -Path $tempDir -Filter '*.apk' -Recurse -File | Select-Object -First 1
    if (-not $apkFile) {
        throw "Downloaded artifact $($apkArtifact.name) contained no .apk"
    }
    $localApk = $apkFile.FullName
}

$apkItem = Get-Item $localApk
$localSha = (Get-FileHash $localApk -Algorithm SHA256).Hash.ToLowerInvariant()
$sizeMb = [math]::Round($apkItem.Length / 1MB, 1)

$version = 'unknown'
$buildNumber = 'unknown'
$commit = 'unknown'
if ($metadata) {
    $version = "$($metadata.version)"
    $buildNumber = "$($metadata.build_number)"
    if ($metadata.source -and $metadata.source.short_sha) { $commit = "$($metadata.source.short_sha)" }
}
elseif ($apkItem.Name -match 'jarz-pos-[a-z]+-v(?<version>.+)-(?<sha>[0-9a-f]{7})\.apk') {
    $version = $Matches['version']
    $commit = $Matches['sha']
    if ($version -match '\+(?<build>\d+)$') { $buildNumber = $Matches['build'] }
}

$publishedAtUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm')

Write-Host ''
Write-Info "apk=$($apkItem.Name)"
Write-Info "version=$version build=$buildNumber commit=$commit"
Write-Info "size=$sizeMb MB sha256=$localSha"
Write-Host ''

if ($PlanOnly) {
    Write-Warn 'PlanOnly: nothing was uploaded.'
    return
}

# --- Render the landing page -------------------------------------------------

Write-Step 'Rendering the download page...'
# -Encoding UTF8 is not optional: Windows PowerShell 5.1 reads a BOM-less file as ANSI,
# which turns the page's Arabic half into mojibake.
$page = Get-Content -Path $localPageTemplate -Raw -Encoding UTF8
$replacements = [ordered]@{
    '{{ENV_LABEL}}'    = "$($config.EnvLabel)"
    '{{VERSION}}'      = $version
    '{{BUILD_NUMBER}}' = $buildNumber
    '{{COMMIT}}'       = $commit
    '{{BUILT_AT}}'     = $publishedAtUtc
    '{{SIZE_MB}}'      = "$sizeMb"
    '{{SHA256}}'       = $localSha
    '{{APK_FILE}}'     = $apkFileName
}
foreach ($key in $replacements.Keys) {
    $page = $page.Replace($key, $replacements[$key])
}

$localPage = Join-Path $tempDir 'index.html'
# Set-Content -Encoding UTF8 would prepend a BOM on 5.1; write the bytes directly instead.
[System.IO.File]::WriteAllText($localPage, $page, (New-Object System.Text.UTF8Encoding($false)))

$downloadMetadata = [ordered]@{
    environment      = $Environment
    apk_file         = $apkFileName
    version          = $version
    build_number     = $buildNumber
    commit           = $commit
    sha256           = $localSha
    size_bytes       = $apkItem.Length
    source_run_id    = $RunId
    source_artifact  = $apkItem.Name
    published_at_utc = (Get-Date).ToUniversalTime().ToString('o')
}
$localMeta = Join-Path $tempDir 'download-metadata.json'
$downloadMetadata | ConvertTo-Json | Set-Content -Path $localMeta -Encoding UTF8

# --- Upload ------------------------------------------------------------------

Write-Step 'Uploading to the durable download store...'
$null = Invoke-Remote 'echo ok'
$null = Invoke-Remote "mkdir -p $remoteStoreDir"

# Upload under a temporary name and move it into place, so an interrupted transfer never
# leaves a truncated APK sitting behind a live download link.
Invoke-Scp -LocalPath $localApk -RemotePath "$remoteStoreDir/.upload.apk"
$null = Invoke-Remote "mv -f $remoteStoreDir/.upload.apk $remoteStoreDir/$apkFileName"
Invoke-Scp -LocalPath $localPage -RemotePath "$remoteStoreDir/index.html"
Invoke-Scp -LocalPath $localMeta -RemotePath "$remoteStoreDir/download-metadata.json"

# Drop APKs left by earlier naming schemes so the store holds exactly one build.
$null = Invoke-Remote "find $remoteStoreDir -maxdepth 1 -name '*.apk' ! -name '$apkFileName' -delete"

$remoteStoreSha = (Invoke-Remote "sha256sum $remoteStoreDir/$apkFileName | cut -d ' ' -f1").Trim().ToLowerInvariant()
if ($remoteStoreSha -ne $localSha) {
    throw "Uploaded APK hash mismatch: local=$localSha remote=$remoteStoreSha"
}
Write-Info 'upload verified'
Write-Host ''

Write-Step 'Mirroring into the served web directory...'
$null = Invoke-Remote "mkdir -p $remoteWebDir && rm -rf $remoteServedDir && mkdir -p $remoteServedDir && cp -a $remoteStoreDir/. $remoteServedDir/"
Write-Host ''

Write-Step 'Rebuilding pos-web container...'
# Required: the Dockerfile COPYs web/ into the image, so a file on the host is not served
# until the image is rebuilt.
$null = Invoke-Remote "docker ps -aq --filter name=pos-web | xargs -r docker rm -f >/dev/null 2>&1 || true ; cd $remoteRoot && docker compose up -d --build --no-deps pos-web >/dev/null 2>&1 || docker-compose up -d --build --no-deps pos-web >/dev/null 2>&1"
Write-Info 'pos-web restarted'
Write-Host ''

# --- Verify ------------------------------------------------------------------

# Windows PowerShell 5.1 can still default to an older protocol on some hosts.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Step 'Verifying the published download...'
$servedSha = (Invoke-Remote "sha256sum $remoteServedDir/$apkFileName | cut -d ' ' -f1").Trim().ToLowerInvariant()
if ($servedSha -ne $localSha) {
    throw "Served APK hash mismatch: local=$localSha served=$servedSha"
}

try {
    $head = Invoke-WebRequest -Uri $apkUrl -Method Head -UseBasicParsing -TimeoutSec 60
    $contentType = "$($head.Headers['Content-Type'])"
    $contentLength = "$($head.Headers['Content-Length'])"
    Write-Info "http_status=$($head.StatusCode) content_type=$contentType content_length=$contentLength"
    if ("$contentLength" -ne "$($apkItem.Length)") {
        Write-Warn "Served Content-Length ($contentLength) does not match the local APK ($($apkItem.Length))."
    }
    if ($contentType -notlike '*android.package-archive*') {
        Write-Warn "Unexpected Content-Type '$contentType'; confirm the nginx download block reached the server (scripts/pos-web/nginx.conf)."
    }
}
catch {
    Write-Warn "Could not verify $apkUrl over HTTPS: $($_.Exception.Message)"
    Write-Warn 'If this is the first publish, run deploy_web.ps1 once so the updated nginx.conf reaches the server.'
}

try {
    $pageHead = Invoke-WebRequest -Uri $downloadUrl -Method Head -UseBasicParsing -TimeoutSec 30
    Write-Info "page_status=$($pageHead.StatusCode)"
}
catch {
    Write-Warn "Could not verify the landing page at $downloadUrl -- $($_.Exception.Message)"
}

Write-Host ''
Write-Info "Published: $downloadUrl"
Write-Info "Direct APK: $apkUrl"
