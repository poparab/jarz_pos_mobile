$ErrorActionPreference = 'Stop'

$routerSource = Join-Path (Split-Path -Parent $PSScriptRoot) 'release_router.ps1'
$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile(
    $routerSource,
    [ref]$null,
    [ref]$parseErrors
)
if ($parseErrors.Count -gt 0) {
    throw "release_router.ps1 has parse errors: $($parseErrors -join '; ')"
}

$tempRoot = [System.IO.Path]::GetFullPath(
    (Join-Path ([System.IO.Path]::GetTempPath()) ("jarz-release-router-pin-test-" + [guid]::NewGuid().ToString('N')))
)
$systemTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
if (-not $tempRoot.StartsWith($systemTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to use unexpected test directory: $tempRoot"
}

function Initialize-TestRepo([string]$Path) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $Path 'README.txt') -Value 'release router test fixture' -Encoding Ascii
    & git -C $Path init -b main | Out-Null
    & git -C $Path add .
    & git -C $Path -c user.name='Jarz Test' -c user.email='jarz-test@example.invalid' commit -m 'test fixture' | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to initialize test repository: $Path"
    }
}

function Assert-LogLine([string[]]$Lines, [string]$Expected) {
    if ($Lines -notcontains $Expected) {
        throw "Missing log line '$Expected'. Actual: $($Lines -join ', ')"
    }
}

try {
    $mobileRepo = Join-Path $tempRoot 'mobile'
    $scriptsDir = Join-Path $mobileRepo 'scripts'
    $backendRepo = Join-Path $tempRoot 'backend'
    $wooRepo = Join-Path $tempRoot 'woo'
    New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
    Copy-Item -LiteralPath $routerSource -Destination (Join-Path $scriptsDir 'release_router.ps1')

    @'
param([string]$RepoPath, [string]$BaseRef, [string]$HeadRef = 'HEAD', [string]$Format = 'Text')
Write-Output 'MOBILE_RELEASE_TYPE=shorebird_patch'
Write-Output 'MOBILE_RELEASE_REASON=test fixture'
'@ | Set-Content -LiteralPath (Join-Path $scriptsDir 'classify_mobile_release.ps1') -Encoding Ascii

    @'
param([string]$Environment, [switch]$PlanOnly, [string]$Commit)
"backend|$Environment|$($PlanOnly.IsPresent)|$Commit" | Add-Content -LiteralPath $env:ROUTER_TEST_LOG -Encoding Ascii
if ($PlanOnly) { Write-Output 'DEPLOY_REQUIRED=true' }
'@ | Set-Content -LiteralPath (Join-Path $scriptsDir 'deploy_backend.ps1') -Encoding Ascii

    @'
param([string]$Environment, [switch]$PlanOnly, [string]$Commit)
"web|$Environment|$($PlanOnly.IsPresent)|$Commit" | Add-Content -LiteralPath $env:ROUTER_TEST_LOG -Encoding Ascii
if ($PlanOnly) { Write-Output 'WEB_DEPLOY_REQUIRED=true' }
'@ | Set-Content -LiteralPath (Join-Path $scriptsDir 'deploy_web.ps1') -Encoding Ascii

    @'
param(
    [string]$Environment,
    [string]$ReleaseType,
    [int]$TimeoutMinutes,
    [int]$PollSeconds,
    [int]$RunDiscoveryGraceSeconds,
    [string]$CommitSha,
    [string]$ReleaseNotes,
    [switch]$SkipIfNoRun
)
"android|$Environment|$ReleaseType|$CommitSha" | Add-Content -LiteralPath $env:ROUTER_TEST_LOG -Encoding Ascii
'@ | Set-Content -LiteralPath (Join-Path $scriptsDir 'watch_android_release.ps1') -Encoding Ascii

    Initialize-TestRepo $mobileRepo
    Initialize-TestRepo $backendRepo
    Initialize-TestRepo $wooRepo

    $backendCommit = '1111111111111111111111111111111111111111'
    $flutterCommit = '2222222222222222222222222222222222222222'
    $router = Join-Path $scriptsDir 'release_router.ps1'
    $env:ROUTER_TEST_LOG = Join-Path $tempRoot 'router.log'

    $releaseOutput = & powershell -NoProfile -ExecutionPolicy Bypass -File $router `
        -Environment production `
        -IncludeFirebase `
        -MobileReleaseType shorebird_patch `
        -BackendCommitSha $backendCommit `
        -FlutterCommitSha $flutterCommit `
        -BackendRepoPath $backendRepo `
        -WooRepoPath $wooRepo 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Router release fixture failed: $($releaseOutput -join [Environment]::NewLine)"
    }
    $releaseLines = @(Get-Content -LiteralPath $env:ROUTER_TEST_LOG)
    Assert-LogLine $releaseLines "backend|production|True|$backendCommit"
    Assert-LogLine $releaseLines "backend|production|False|$backendCommit"
    Assert-LogLine $releaseLines "web|production|True|$flutterCommit"
    Assert-LogLine $releaseLines "web|production|False|$flutterCommit"
    Assert-LogLine $releaseLines "android|production|shorebird_patch|$flutterCommit"

    $previousErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $conflictOutput = & powershell -NoProfile -ExecutionPolicy Bypass -File $router `
            -Environment staging `
            -PlanOnly `
            -CommitSha aaaaaaa `
            -FlutterCommitSha bbbbbbb `
            -BackendRepoPath $backendRepo `
            -WooRepoPath $wooRepo 2>&1
        $conflictExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorPreference
    }
    if ($conflictExitCode -eq 0 -or ($conflictOutput -join "`n") -notmatch 'conflicts with -FlutterCommitSha') {
        throw 'Conflicting legacy and explicit Flutter commit pins were not rejected.'
    }

    Write-Output 'PASS release_router forwards independent backend and Flutter commit pins.'
    Write-Output 'PASS release_router rejects conflicting Flutter commit aliases.'
}
finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
