param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('staging', 'production')]
    [string]$Environment,

    [switch]$PlanOnly,
    [switch]$AllowDirtyWorkingTree,
    [switch]$IncludeFirebase,
    [ValidateSet('auto', 'full_apk', 'shorebird_patch', 'none')]
    [string]$MobileReleaseType = 'auto',
    [string]$CommitSha,
    [string]$ReleaseNotes,
    [int]$FirebaseTimeoutMinutes = 45,
    [int]$FirebasePollSeconds = 10,
    [int]$FirebaseRunDiscoveryGraceSeconds = 60,
    [string]$BackendRepoPath,
    [string]$WooRepoPath,
    [switch]$SkipWeb
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$workspaceRoot = Split-Path -Parent $repoRoot
$erpRoot = Split-Path -Parent $workspaceRoot
if (-not $BackendRepoPath) {
    $BackendRepoPath = Join-Path $erpRoot 'frappe_docker\development\frappe-bench\apps\jarz_pos'
}
if (-not $WooRepoPath) {
    $WooRepoPath = Join-Path $erpRoot 'frappe_docker\development\frappe-bench\apps\jarz_woocommerce_integration'
}

$backendScriptPath = Join-Path $PSScriptRoot 'deploy_backend.ps1'
$webScriptPath = Join-Path $PSScriptRoot 'deploy_web.ps1'
$androidReleaseScriptPath = Join-Path $PSScriptRoot 'watch_android_release.ps1'
$mobileClassifierPath = Join-Path $PSScriptRoot 'classify_mobile_release.ps1'

function Write-Info([string]$Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn([string]$Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Step([string]$Message) {
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

function Test-CommandAvailable([string]$CommandName) {
    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        throw "$CommandName is required but was not found in PATH"
    }
}

function Invoke-GitText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryPath,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [switch]$IgnoreExitCode
    )

    $output = & git -C $RepositoryPath @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0 -and -not $IgnoreExitCode) {
        throw "git -C $RepositoryPath $($Arguments -join ' ') failed ($exitCode)`n$($output -join "`n")"
    }

    return ($output -join "`n").TrimEnd()
}

function Get-RepoStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryPath,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if (-not (Test-Path $RepositoryPath)) {
        return @{
            Label = $Label
            RepositoryPath = $RepositoryPath
            Exists = $false
            Dirty = $false
            Paths = @()
        }
    }

    $statusOutput = Invoke-GitText -RepositoryPath $RepositoryPath -Arguments @('status', '--porcelain')
    $paths = @()
    if (-not [string]::IsNullOrWhiteSpace($statusOutput)) {
        $paths = @(
            $statusOutput -split "`r?`n" |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            ForEach-Object {
                $line = $_
                if ($line.Length -gt 3) {
                    $pathPart = $line.Substring(3)
                    if ($pathPart -match ' -> ') {
                        $pathPart = ($pathPart -split ' -> ')[1]
                    }
                    $pathPart.Trim()
                }
            }
        )
    }

    return @{
        Label = $Label
        RepositoryPath = $RepositoryPath
        Exists = $true
        Dirty = $paths.Count -gt 0
        Paths = $paths
    }
}

function Test-MobileRuntimeImpact([string[]]$Paths) {
    foreach ($path in $Paths) {
        if (
            $path.StartsWith('android/') -or
            $path.StartsWith('assets/') -or
            $path.StartsWith('lib/') -or
            $path -eq '.env.prod' -or
            $path -eq '.env.staging' -or
            $path -eq 'l10n.yaml' -or
            $path -eq 'pubspec.yaml' -or
            $path -eq 'pubspec.lock' -or
            $path -eq 'shorebird.yaml' -or
            $path -eq 'scripts/build_release.bat' -or
            $path -eq 'scripts/build_release.sh' -or
            $path -eq 'tool/release_metadata.dart'
        ) {
            return $true
        }
    }

    return $false
}

function Test-WebRuntimeImpact([string[]]$Paths) {
    foreach ($path in $Paths) {
        if (
            $path.StartsWith('assets/') -or
            $path.StartsWith('lib/') -or
            $path.StartsWith('web/') -or
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

function Test-BackendRuntimeImpact([string[]]$Paths) {
    foreach ($path in $Paths) {
        if (
            $path.StartsWith('.github/') -or
            $path.StartsWith('documentation/') -or
            $path.StartsWith('docs/') -or
            $path.StartsWith('jarz_pos/tests/') -or
            $path -match '(^|/)README(\.|$)'
        ) {
            continue
        }

        return $true
    }

    return $false
}

function Invoke-PowerShellScript {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "powershell -File $ScriptPath $($Arguments -join ' ') failed ($exitCode)`n$($output -join "`n")"
    }

    return ($output -join "`n").TrimEnd()
}

function Get-KeyValueFromText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,

        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    $pattern = "(?m)^$([regex]::Escape($Key))=(.*)$"
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        return $null
    }

    return $match.Groups[1].Value.Trim()
}

function Invoke-MobileClassifier {
    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $mobileClassifierPath -RepoPath $repoRoot -Format Env 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "powershell -File $mobileClassifierPath failed ($exitCode)`n$($output -join "`n")"
    }

    $map = @{}
    foreach ($line in ($output -join "`n") -split "`r?`n") {
        if ($line -match '^(?<key>[A-Z0-9_]+)=(?<value>.*)$') {
            $map[$Matches['key']] = $Matches['value']
        }
    }

    return $map
}

Test-CommandAvailable 'git'
Test-CommandAvailable 'powershell'

foreach ($requiredPath in @($backendScriptPath, $webScriptPath, $androidReleaseScriptPath, $mobileClassifierPath, $repoRoot)) {
    if (-not (Test-Path $requiredPath)) {
        throw "Required path not found: $requiredPath"
    }
}

$mobileStatus = Get-RepoStatus -RepositoryPath $repoRoot -Label 'mobile'
$backendStatus = Get-RepoStatus -RepositoryPath $BackendRepoPath -Label 'backend'
$wooStatus = Get-RepoStatus -RepositoryPath $WooRepoPath -Label 'woo'

$mobileRuntimeDirty = Test-MobileRuntimeImpact $mobileStatus.Paths
$webRuntimeDirty = Test-WebRuntimeImpact $mobileStatus.Paths
$backendRuntimeDirty = (Test-BackendRuntimeImpact $backendStatus.Paths) -or (Test-BackendRuntimeImpact $wooStatus.Paths)
$anyDirty = $mobileStatus.Dirty -or $backendStatus.Dirty -or $wooStatus.Dirty
$mobileClassification = Invoke-MobileClassifier
$classifiedMobileType = $mobileClassification['MOBILE_RELEASE_TYPE']
$classifiedMobileReason = $mobileClassification['MOBILE_RELEASE_REASON']
$effectiveMobileType = switch ($MobileReleaseType) {
    'auto' { $classifiedMobileType }
    'full_apk' { 'full_apk' }
    'shorebird_patch' { 'shorebird_patch' }
    'none' { 'none' }
}

Write-Host ''
Write-Info "Smart release router: $Environment"
Write-Host ''

Write-Step 'Local repo safety check'
foreach ($status in @($mobileStatus, $backendStatus, $wooStatus)) {
    if (-not $status.Exists) {
        Write-Warn "$($status.Label): repo not found at $($status.RepositoryPath)"
        continue
    }

    $state = if ($status.Dirty) { 'dirty' } else { 'clean' }
    Write-Info "$($status.Label): $state"
    foreach ($path in $status.Paths | Select-Object -First 8) {
        Write-Host "        $path"
    }
}
Write-Host ''

if ($PlanOnly) {
    Write-Step 'Plan summary'
    Write-Info "mobile_runtime_changes=$($mobileRuntimeDirty.ToString().ToLowerInvariant())"
    Write-Info "mobile_release_type=$effectiveMobileType"
    Write-Info "mobile_release_reason=$classifiedMobileReason"
    Write-Info "web_runtime_changes=$($webRuntimeDirty.ToString().ToLowerInvariant())"
    Write-Info "backend_runtime_changes=$($backendRuntimeDirty.ToString().ToLowerInvariant())"
    Write-Info "release_blocked_by_dirty_worktree=$($anyDirty.ToString().ToLowerInvariant())"
    if ($effectiveMobileType -eq 'shorebird_patch') {
        Write-Info 'Android mobile release would use a Shorebird patch after devices have the Shorebird-enabled APK installed.'
    }
    elseif ($effectiveMobileType -eq 'full_apk') {
        Write-Info 'Android mobile release would use a full APK release path.'
    }
    elseif ($mobileRuntimeDirty) {
        Write-Info 'Android mobile release still requires explicit review.'
    }
    if ($webRuntimeDirty) {
        Write-Info 'Flutter web deploy would be relevant once changes are committed and pushed to GitHub.'
    }
    if ($backendRuntimeDirty) {
        Write-Info 'Backend deploy would be relevant once backend changes are committed and pushed to GitHub.'
    }
    if (-not $mobileRuntimeDirty -and -not $webRuntimeDirty -and -not $backendRuntimeDirty) {
        Write-Info 'No runtime-impacting local changes detected.'
    }
    Write-Host ''
    exit 0
}

if ($anyDirty -and -not $AllowDirtyWorkingTree) {
    throw 'Smart release router refused to execute because one or more repos have uncommitted changes. Commit and push first, or use -PlanOnly to inspect the plan safely.'
}

$backendPlanOutput = Invoke-PowerShellScript -ScriptPath $backendScriptPath -Arguments @('-Environment', $Environment, '-PlanOnly')
$backendDeployRequired = (Get-KeyValueFromText -Text $backendPlanOutput -Key 'DEPLOY_REQUIRED') -eq 'true'
$webDeployRequired = $false
if (-not $SkipWeb) {
    $webPlanOutput = Invoke-PowerShellScript -ScriptPath $webScriptPath -Arguments @('-Environment', $Environment, '-PlanOnly')
    $webDeployRequired = (Get-KeyValueFromText -Text $webPlanOutput -Key 'WEB_DEPLOY_REQUIRED') -eq 'true'
}

$androidReleaseShouldRun = $false
if ($Environment -eq 'staging' -and $effectiveMobileType -ne 'none') {
    $androidReleaseShouldRun = $true
}
elseif ($IncludeFirebase -and $effectiveMobileType -ne 'none') {
    $androidReleaseShouldRun = $true
}

Write-Step 'Execution plan'
Write-Info "backend_deploy_required=$($backendDeployRequired.ToString().ToLowerInvariant())"
Write-Info "web_deploy_required=$($webDeployRequired.ToString().ToLowerInvariant())"
Write-Info "mobile_release_type=$effectiveMobileType"
Write-Info "android_release_action=$(if ($androidReleaseShouldRun) { 'watch-or-trigger' } else { 'skip' })"
Write-Host ''

$releaseJobs = @()
if ($backendDeployRequired) {
    Write-Step 'Starting backend deploy in parallel...'
    $releaseJobs += Start-Job -Name 'backend-release' -ArgumentList $backendScriptPath, $Environment -ScriptBlock {
        param($scriptPath, $targetEnvironment)
        & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Environment $targetEnvironment 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Backend deploy failed with exit code $LASTEXITCODE"
        }
    }
}
else {
    Write-Info 'Skipping backend deploy; target server is already on the latest backend commits.'
}

if ($webDeployRequired) {
    Write-Step 'Starting Flutter web deploy in parallel...'
    $releaseJobs += Start-Job -Name 'web-release' -ArgumentList $webScriptPath, $Environment -ScriptBlock {
        param($scriptPath, $targetEnvironment)
        & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Environment $targetEnvironment 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Web deploy failed with exit code $LASTEXITCODE"
        }
    }
}
elseif (-not $SkipWeb) {
    Write-Info 'Skipping Flutter web deploy; target web app is already current or no web-impacting commit delta was detected.'
}
else {
    Write-Info 'Skipping Flutter web deploy because -SkipWeb was requested.'
}

if ($androidReleaseShouldRun) {
    $androidWatcherReleaseType = if ($Environment -eq 'staging') {
        'auto'
    }
    elseif ($effectiveMobileType -eq 'shorebird_patch') {
        'patch'
    }
    elseif ($effectiveMobileType -eq 'full_apk') {
        'apk'
    }
    else {
        'auto'
    }

    $androidReleaseArgs = @(
        '-Environment', $Environment,
        '-ReleaseType', $androidWatcherReleaseType,
        '-TimeoutMinutes', "$FirebaseTimeoutMinutes",
        '-PollSeconds', "$FirebasePollSeconds",
        '-RunDiscoveryGraceSeconds', "$FirebaseRunDiscoveryGraceSeconds"
    )
    if ($CommitSha) {
        $androidReleaseArgs += @('-CommitSha', $CommitSha)
    }
    if ($ReleaseNotes) {
        $androidReleaseArgs += @('-ReleaseNotes', $ReleaseNotes)
    }
    if ($Environment -eq 'staging') {
        $androidReleaseArgs += '-SkipIfNoRun'
    }

    Write-Step 'Watching Android release workflow...'
    $androidReleaseOutput = Invoke-PowerShellScript -ScriptPath $androidReleaseScriptPath -Arguments $androidReleaseArgs
    if ($androidReleaseOutput) {
        Write-Host $androidReleaseOutput
    }
}
else {
    Write-Info 'Skipping Android mobile release workflow for this run.'
}

if ($releaseJobs.Count -gt 0) {
    Write-Step 'Waiting for parallel release jobs to finish...'
    $null = Wait-Job -Job $releaseJobs
    foreach ($job in $releaseJobs) {
        $jobOutput = Receive-Job $job -Keep
        if ($jobOutput) {
            $jobOutput | ForEach-Object { Write-Host $_ }
        }
        if ($job.State -ne 'Completed') {
            Remove-Job $job | Out-Null
            throw "Release job '$($job.Name)' finished in state $($job.State)."
        }
        Remove-Job $job | Out-Null
    }
}

Write-Host ''
Write-Info 'Smart release router completed successfully'
Write-Host ''