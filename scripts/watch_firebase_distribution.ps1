param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('staging', 'production')]
    [string]$Environment,

    [ValidateSet('auto', 'apk', 'patch')]
    [string]$ReleaseType = 'auto',

    [string]$CommitSha,
    [string]$ReleaseNotes,
    [int]$TimeoutMinutes = 45,
    [int]$PollSeconds = 10,
    [int]$RunDiscoveryGraceSeconds = 60,
    [switch]$SkipIfNoRun,
    [switch]$ForceTrigger,
    [string]$MobileRepoPath
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $MobileRepoPath) {
    $MobileRepoPath = $repoRoot
}

$workflowName = 'Firebase App Distribution'
$githubRepo = $null

function Write-Info([string]$Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Step([string]$Message) {
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

function Test-CommandAvailable([string]$CommandName) {
    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        throw "$CommandName is required but was not found in PATH"
    }
}

function Invoke-ToolText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandName,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & $CommandName @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "$CommandName $($Arguments -join ' ') failed ($exitCode)`n$($output -join "`n")"
    }

    return ($output -join "`n").TrimEnd()
}

function Invoke-Git {
    param([string[]]$Arguments)

    return Invoke-ToolText -CommandName 'git' -Arguments (@('-C', $MobileRepoPath) + $Arguments)
}

function Invoke-Gh {
    param([string[]]$Arguments)

    $previousPager = $env:GH_PAGER
    $env:GH_PAGER = 'cat'
    try {
        return Invoke-ToolText -CommandName 'gh' -Arguments (@('-R', $githubRepo) + $Arguments)
    }
    finally {
        $env:GH_PAGER = $previousPager
    }
}

function Invoke-GhJson {
    param([string[]]$Arguments)

    $raw = Invoke-Gh -Arguments $Arguments
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return $null
    }

    return $raw | ConvertFrom-Json
}

function Get-OriginMainHead {
    $lsRemote = (Invoke-Git -Arguments @('ls-remote', 'origin', 'refs/heads/main')).Trim()
    if (-not $lsRemote) {
        throw 'Could not resolve origin/main head from the mobile repo'
    }

    return ($lsRemote -split '\s+')[0]
}

function Get-GitHubRepoSlug {
    $remoteUrl = (Invoke-Git -Arguments @('remote', 'get-url', 'origin')).Trim()
    if (-not $remoteUrl) {
        throw 'Could not resolve origin remote URL from the mobile repo'
    }

    if ($remoteUrl -match 'github\.com[:/]+([^/]+)/(.+?)(?:\.git)?$') {
        return "$($Matches[1])/$($Matches[2])"
    }

    throw "Unsupported GitHub remote URL: $remoteUrl"
}

function Find-WorkflowRun {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EventName,

        [Parameter(Mandatory = $true)]
        [string]$HeadSha
        if (-not $MobileRepoPath) {
            $MobileRepoPath = Split-Path -Parent $PSScriptRoot
        }

        $scriptPath = Join-Path $PSScriptRoot 'watch_android_release.ps1'
        if (-not (Test-Path $scriptPath)) {
            throw "Android release watcher not found at $scriptPath"
        }

        $arguments = @(
            '-Environment', $Environment,
            '-ReleaseType', $ReleaseType,
            '-TimeoutMinutes', "$TimeoutMinutes",
            '-PollSeconds', "$PollSeconds",
            '-RunDiscoveryGraceSeconds', "$RunDiscoveryGraceSeconds",
            '-MobileRepoPath', $MobileRepoPath
        )

        if ($CommitSha) {
            $arguments += @('-CommitSha', $CommitSha)
        }
        if ($ReleaseNotes) {
            $arguments += @('-ReleaseNotes', $ReleaseNotes)
        }
        if ($SkipIfNoRun) {
            $arguments += '-SkipIfNoRun'
        }
        if ($ForceTrigger) {
            $arguments += '-ForceTrigger'
        }

        & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath @arguments
        exit $LASTEXITCODE