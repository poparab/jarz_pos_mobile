param(
    [string]$RepoPath,
    [string[]]$ChangedPath = @(),
    [string]$BaseRef,
    [string]$HeadRef = 'HEAD',
    [ValidateSet('Text', 'Env')]
    [string]$Format = 'Text'
)

$ErrorActionPreference = 'Stop'

if (-not $RepoPath) {
    $RepoPath = Split-Path -Parent $PSScriptRoot
}

function Invoke-GitText {
    param([string[]]$Arguments)

    $output = & git -C $RepoPath @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "git -C $RepoPath $($Arguments -join ' ') failed ($exitCode)`n$($output -join "`n")"
    }

    return ($output -join "`n").TrimEnd()
}

function Normalize-Path([string]$Path) {
    $normalized = $Path.Trim().Trim('"') -replace '\\', '/'
    if ($normalized -match '^(.+) -> (.+)$') {
        $normalized = $Matches[2]
    }

    return $normalized.Trim()
}

function Get-ChangedPaths {
    if ($ChangedPath.Count -gt 0) {
        return @($ChangedPath | ForEach-Object { Normalize-Path $_ } | Where-Object { $_ })
    }

    if ($BaseRef) {
        $diffOutput = Invoke-GitText -Arguments @('diff', '--name-only', $BaseRef, $HeadRef)
        return @($diffOutput -split "`r?`n" | ForEach-Object { Normalize-Path $_ } | Where-Object { $_ })
    }

    $statusOutput = Invoke-GitText -Arguments @('status', '--porcelain')
    return @(
        $statusOutput -split "`r?`n" |
            Where-Object { $_ } |
            ForEach-Object {
                $path = if ($_.Length -gt 3) { $_.Substring(3) } else { $_ }
                Normalize-Path $path
            } |
            Where-Object { $_ }
    )
}

function Is-MobileRuntimePath([string]$Path) {
    return (
        $Path -like 'android/*' -or
        $Path -like 'assets/*' -or
        $Path -like 'lib/*' -or
        $Path -eq 'l10n.yaml' -or
        $Path -eq 'pubspec.yaml' -or
        $Path -eq 'pubspec.lock' -or
        $Path -eq 'shorebird.yaml' -or
        $Path -eq '.env.prod' -or
        $Path -eq '.env.staging'
    )
}

function Is-FullApkPath([string]$Path) {
    return (
        $Path -like 'android/*' -or
        $Path -like 'assets/*' -or
        $Path -eq 'pubspec.yaml' -or
        $Path -eq 'pubspec.lock' -or
        $Path -eq 'shorebird.yaml' -or
        $Path -eq '.env.prod' -or
        $Path -eq '.env.staging' -or
        $Path -eq 'l10n.yaml' -or
        $Path -like 'scripts/build_release.*' -or
        $Path -like 'scripts/shorebird_android.*' -or
        $Path -like 'tool/release_metadata.dart'
    )
}

function Is-PatchCandidatePath([string]$Path) {
    if ($Path -notlike 'lib/*.dart' -and $Path -notlike 'lib/**/*.dart') {
        return $false
    }

    return -not (
        $Path -eq 'lib/main.dart' -or
        $Path -like 'lib/src/core/*' -or
        $Path -like 'lib/src/data/*' -or
        $Path -like 'lib/src/domain/*' -or
        $Path -like 'lib/src/services/*'
    )
}

$paths = @(Get-ChangedPaths | Sort-Object -Unique)
$mobilePaths = @($paths | Where-Object { Is-MobileRuntimePath $_ })
$fullApkPaths = @($mobilePaths | Where-Object { Is-FullApkPath $_ })
$patchCandidatePaths = @($mobilePaths | Where-Object { Is-PatchCandidatePath $_ })
$unknownMobilePaths = @(
    $mobilePaths |
        Where-Object { ($fullApkPaths -notcontains $_) -and ($patchCandidatePaths -notcontains $_) }
)

if ($mobilePaths.Count -eq 0) {
    $releaseType = 'none'
    $reason = 'No Android runtime-impacting paths changed.'
}
elseif ($fullApkPaths.Count -gt 0) {
    $releaseType = 'full_apk'
    $reason = "Full APK required because these paths are not Shorebird patch-safe: $($fullApkPaths -join ', ')"
}
elseif ($unknownMobilePaths.Count -gt 0) {
    $releaseType = 'full_apk'
    $reason = "Full APK required because these mobile paths need manual safety review: $($unknownMobilePaths -join ', ')"
}
else {
    $releaseType = 'shorebird_patch'
    $reason = "Shorebird patch candidate: Dart-only changes in $($patchCandidatePaths -join ', ')"
}

if ($Format -eq 'Env') {
    Write-Output "MOBILE_RELEASE_TYPE=$releaseType"
    Write-Output "MOBILE_RELEASE_REASON=$reason"
    Write-Output "MOBILE_RELEASE_PATHS=$($mobilePaths -join ',')"
    exit 0
}

Write-Output "Mobile release type: $releaseType"
Write-Output "Reason: $reason"
if ($mobilePaths.Count -gt 0) {
    Write-Output 'Mobile paths:'
    $mobilePaths | ForEach-Object { Write-Output "  $_" }
}