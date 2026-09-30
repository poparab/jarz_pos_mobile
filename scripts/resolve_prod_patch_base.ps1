#Requires -Version 5.1
<#
.SYNOPSIS
  Resolves the Shorebird release a PRODUCTION patch must target.

.DESCRIPTION
  A Shorebird patch reaches only devices running the release it was built
  against, so a production patch must target the build production phones run:
  the one /pos/download/ serves. download-metadata.json is written only by a
  production full_apk run that published the APK, verified the page, and raised
  the force-update floor to that build, so it names both the version and the
  run that produced it.

  This replaces inferring the base from `gh run list` + scraping that run's log.
  On 2026-09-30 the list call returned an older window of runs (its newest
  production full_apk was about two weeks old), so a patch built at 0293f72
  targeted 1.0.0+552 instead of 1.0.0+600 and Shorebird refused it for native
  diffs, after about 9 minutes of setup. Every read here is a single record
  (the page, one run by id), not a list, except the newer-run guard, where a
  stale list can only hide a newer run, never invent one.

  Writes `release_version=<v>` to $env:GITHUB_OUTPUT when running in Actions,
  and emits the version as the script's only pipeline output.

.PARAMETER RequestedVersion
  An explicit release_version. Blank or 'latest' means "resolve it". An
  explicit value is honoured as-is (deliberately patching an older base is
  legitimate), with a warning when it is not the build production runs.
#>
param(
    [string]$RequestedVersion = '',
    [string]$Repo = $(if ($env:GITHUB_REPOSITORY) { $env:GITHUB_REPOSITORY } else { 'poparab/jarz_pos_mobile' }),
    [string]$MetadataUrl = 'https://erp.orderjarz.com/pos/download/download-metadata.json',
    [string]$WorkflowFile = 'firebase-app-distribution.yml'
)

$ErrorActionPreference = 'Stop'
$inActions = -not [string]::IsNullOrWhiteSpace($env:GITHUB_ACTIONS)

function Write-Note([string]$Message) { Write-Host "[prod-patch-base] $Message" }

function Write-Warn([string]$Title, [string]$Message) {
    if ($inActions) { Write-Host "::warning title=$Title::$Message" } else { Write-Warning "$Title - $Message" }
}

function Invoke-GhApiJson([string]$Path) {
    $raw = & gh api $Path
    if ($LASTEXITCODE -ne 0) { throw "gh api $Path failed (exit $LASTEXITCODE)." }
    return (($raw | Out-String) | ConvertFrom-Json)
}

function Get-ServedBuild {
    $lastError = $null
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            # Cache-busting query: a CDN or nginx cache must not answer with the
            # page as it was before the last publish.
            $uri = $MetadataUrl
            if ($uri -match '^https?://') { $uri = "$($uri)?t=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())" }
            return Invoke-RestMethod -Uri $uri -TimeoutSec 30
        } catch {
            $lastError = $_
            if ($attempt -lt 3) { Start-Sleep -Seconds 10 }
        }
    }
    throw "Could not read $MetadataUrl after 3 attempts: $lastError"
}

$requested = "$RequestedVersion".Trim()
$explicit = $requested -and $requested -ne 'latest'

try {
    $served = Get-ServedBuild
} catch {
    if (-not $explicit) { throw }
    Write-Warn 'Production build unknown' "$($_.Exception.Message). Using release_version=$requested as given."
    if ($env:GITHUB_OUTPUT) { "release_version=$requested" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8 }
    return $requested
}

$servedVersion = "$($served.version)".Trim()
$servedRun = "$($served.source_run_id)".Trim()
$servedCommit = "$($served.commit)".Trim()
if ("$($served.environment)" -ne 'production' -or
    $servedVersion -notmatch '^\d+\.\d+\.\d+\+\d+$' -or
    $servedRun -notmatch '^\d+$') {
    throw "$MetadataUrl does not describe a production build (environment='$($served.environment)', version='$servedVersion', source_run_id='$servedRun')."
}
Write-Note "Production phones run $servedVersion (download page, run $servedRun, commit $servedCommit)."

if ($explicit) {
    if ($requested -ne $servedVersion) {
        Write-Warn 'Patching a non-current base' "release_version=$requested was requested, but production phones run $servedVersion. Only devices still on $requested will receive this patch."
    }
    if ($env:GITHUB_OUTPUT) { "release_version=$requested" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8 }
    return $requested
}

# The run the page names must be what the page says it is.
$run = Invoke-GhApiJson "repos/$Repo/actions/runs/$servedRun"
if ($run.conclusion -ne 'success' -or "$($run.display_title)" -notlike '* / production / full_apk / *') {
    throw "Download page names run $servedRun, which is not a successful production full_apk run (title '$($run.display_title)', conclusion '$($run.conclusion)')."
}
if ($servedCommit -and -not "$($run.head_sha)".StartsWith($servedCommit)) {
    throw "Download page says commit $servedCommit but run $servedRun built $($run.head_sha)."
}

# A successful production full_apk NEWER than the one the page serves means the
# page was rolled back or re-published by hand. Phones may be on either build,
# so which base to patch is a human decision: stop before the build, not after.
$recent = Invoke-GhApiJson "repos/$Repo/actions/workflows/$WorkflowFile/runs?event=workflow_dispatch&status=success&per_page=50"
$newer = @(
    @($recent.workflow_runs) |
        Where-Object { "$($_.display_title)" -like '* / production / full_apk / *' -and [int64]$_.id -gt [int64]$servedRun } |
        ForEach-Object { $_.id }
)
if ($newer.Count -gt 0) {
    throw ("Production full_apk run(s) $($newer -join ', ') succeeded after run $servedRun, which the download page still serves ($servedVersion). " +
        "Decide which build production phones run, then re-dispatch with release_version set explicitly.")
}

Write-Note "Production patch base: $servedVersion"
if ($env:GITHUB_OUTPUT) { "release_version=$servedVersion" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8 }
return $servedVersion
