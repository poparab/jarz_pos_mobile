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

$workflowName = 'Android Release'
$githubRepo = $null
$classifierScriptPath = Join-Path $PSScriptRoot 'classify_mobile_release.ps1'

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

    $previousNativeErrorPreference = $PSNativeCommandUseErrorActionPreference
    $PSNativeCommandUseErrorActionPreference = $false
    try {
        $output = & $CommandName @Arguments 2>&1
    }
    finally {
        $PSNativeCommandUseErrorActionPreference = $previousNativeErrorPreference
    }

    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "$CommandName $($Arguments -join ' ') failed ($exitCode)`n$($output -join "`n")"
    }

    return ($output -join "`n").TrimEnd()
}

function Invoke-Git {
    param([string[]]$Arguments)

    return Invoke-ToolText -CommandName 'git' -Arguments (@('-c', 'http.version=HTTP/1.1', '-C', $MobileRepoPath) + $Arguments)
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

function Get-ChangedPathsForCommit([string]$Sha) {
    $output = Invoke-Git -Arguments @('show', '--pretty=format:', '--name-only', $Sha)
    return @(
        $output -split "`r?`n" |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            ForEach-Object { $_.Trim() }
    )
}

function Invoke-MobileClassifier([string[]]$Paths) {
    $output = & $classifierScriptPath -RepoPath $MobileRepoPath -ChangedPath $Paths -Format Env 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "classify_mobile_release.ps1 failed ($exitCode)`n$($output -join "`n")"
    }

    $map = @{}
    foreach ($line in ($output -join "`n") -split "`r?`n") {
        if ($line -match '^(?<key>[A-Z0-9_]+)=(?<value>.*)$') {
            $map[$Matches['key']] = $Matches['value']
        }
    }

    return $map
}

function Find-WorkflowRun {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EventName,

        [Parameter(Mandatory = $true)]
        [string]$HeadSha,

        [string]$ExpectedTitle
    )

    $runs = Invoke-GhJson -Arguments @(
        'run', 'list',
        '--workflow', $workflowName,
        '--branch', 'main',
        '--limit', '20',
        '--json', 'databaseId,displayTitle,event,headSha,status,conclusion,url,createdAt'
    )

    $runList = @($runs)
    if (-not $runList -or $runList.Count -eq 0) {
        return $null
    }

    $matchingRuns = @(
        $runList |
            Where-Object {
                $_.event -eq $EventName -and
                $_.headSha -eq $HeadSha -and
                ([string]::IsNullOrWhiteSpace($ExpectedTitle) -or $_.displayTitle -like "*$ExpectedTitle*")
            } |
            Sort-Object -Property databaseId -Descending
    )

    if ($matchingRuns.Count -eq 0) {
        return $null
    }

    return $matchingRuns[0]
}

function Get-WorkflowRunState([string]$RunId) {
    return Invoke-GhJson -Arguments @(
        'run', 'view', $RunId,
        '--json', 'status,conclusion,url,displayTitle,headSha,workflowName'
    )
}

function Get-ExpectedRunTitle([string]$EventName, [string]$ResolvedReleaseType) {
    if ($EventName -eq 'workflow_dispatch') {
        return $ResolvedReleaseType
    }

    return $null
}

Test-CommandAvailable 'git'
Test-CommandAvailable 'gh'

if (-not (Test-Path $MobileRepoPath)) {
    throw "Mobile repo not found at $MobileRepoPath"
}

if (-not (Test-Path $classifierScriptPath)) {
    throw "Mobile release classifier not found at $classifierScriptPath"
}

$githubRepo = Get-GitHubRepoSlug

if (-not $CommitSha) {
    $CommitSha = (Invoke-Git -Arguments @('rev-parse', 'HEAD')).Trim()
}

$originMainHead = Get-OriginMainHead
if ($CommitSha -ne $originMainHead) {
    throw "Commit $CommitSha is not the current origin/main head ($originMainHead). Push main before waiting for the Android release workflow."
}

$classifier = Invoke-MobileClassifier -Paths (Get-ChangedPathsForCommit $CommitSha)
$classifiedType = $classifier['MOBILE_RELEASE_TYPE']
$classifiedReason = $classifier['MOBILE_RELEASE_REASON']

$effectiveReleaseType = switch ($ReleaseType) {
    'auto' {
        if ($classifiedType -eq 'shorebird_patch') {
            'patch'
        }
        elseif ($classifiedType -eq 'none') {
            'none'
        }
        else {
            'apk'
        }
    }
    default { $ReleaseType }
}

if ($effectiveReleaseType -eq 'none') {
    Write-Info 'Classifier reports no mobile runtime changes. Skipping Android release workflow wait.'
    Write-Output 'ANDROID_RELEASE_ACTION=skipped'
    exit 0
}

$config = switch ($Environment) {
    'staging' {
        @{
            EventName = 'push'
            TriggerWorkflow = $false
            SummaryLabel = 'staging'
        }
    }
    'production' {
        @{
            EventName = 'workflow_dispatch'
            TriggerWorkflow = $true
            SummaryLabel = 'production'
        }
    }
}

Write-Host ''
Write-Info "Watching Android release workflow for $($config.SummaryLabel)"
Write-Info "Release type: $effectiveReleaseType"
Write-Info "Classifier: $classifiedReason"
Write-Info "Commit: $CommitSha"
Write-Host ''

$run = $null
if ($config.TriggerWorkflow) {
    if (-not $ForceTrigger) {
            $run = Find-WorkflowRun -EventName $config.EventName -HeadSha $CommitSha -ExpectedTitle (Get-ExpectedRunTitle -EventName $config.EventName -ResolvedReleaseType $effectiveReleaseType)
        if ($run) {
            Write-Info "Reusing existing workflow run $($run.databaseId) for this commit"
            Write-Info "Run URL: $($run.url)"
            Write-Host ''
        }
    }

    if (-not $run) {
        Write-Step 'Triggering Android release workflow...'
        $workflowArgs = @('workflow', 'run', $workflowName, '--ref', 'main')
        $workflowArgs += @('-f', "environment=$Environment")
        $workflowArgs += @('-f', "release_type=$effectiveReleaseType")
        if ($ReleaseNotes) {
            $workflowArgs += @('-f', "release_notes=$ReleaseNotes")
        }

        Invoke-Gh -Arguments $workflowArgs | Out-Null
        Write-Info 'Workflow dispatch submitted'
        Write-Host ''
    }
}

$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
$discoveryDeadline = (Get-Date).AddSeconds($RunDiscoveryGraceSeconds)

Write-Step 'Waiting for matching GitHub Actions run...'
while (-not $run) {
    if ((Get-Date) -ge $deadline) {
        throw "Timed out after $TimeoutMinutes minutes waiting for the Android release workflow run to appear."
    }

    if ($SkipIfNoRun -and (Get-Date) -ge $discoveryDeadline) {
        Write-Info 'No matching Android release workflow run was found for this commit. Skipping wait.'
        Write-Output 'ANDROID_RELEASE_ACTION=skipped'
        exit 0
    }

    $run = Find-WorkflowRun -EventName $config.EventName -HeadSha $CommitSha -ExpectedTitle (Get-ExpectedRunTitle -EventName $config.EventName -ResolvedReleaseType $effectiveReleaseType)
    if (-not $run) {
        Start-Sleep -Seconds $PollSeconds
    }
}

Write-Info "Found workflow run $($run.databaseId)"
Write-Info "Run URL: $($run.url)"
Write-Host ''

$lastStatus = ''
while ($true) {
    if ((Get-Date) -ge $deadline) {
        throw "Timed out after $TimeoutMinutes minutes waiting for the Android release workflow to finish."
    }

    $state = Get-WorkflowRunState -RunId "$($run.databaseId)"
    $statusSummary = if ($state.status -eq 'completed') {
        "$($state.status)/$($state.conclusion)"
    }
    else {
        $state.status
    }

    if ($statusSummary -ne $lastStatus) {
        Write-Info "Android release workflow status: $statusSummary"
        $lastStatus = $statusSummary
    }

    if ($state.status -eq 'completed') {
        Write-Host ''
        if ($state.conclusion -ne 'success') {
            throw "Android release workflow failed. See $($state.url)"
        }

        Write-Info 'Android release workflow completed successfully'
        Write-Info "Run URL: $($state.url)"
        Write-Output 'ANDROID_RELEASE_ACTION=completed'
        Write-Host ''
        break
    }

    Start-Sleep -Seconds $PollSeconds
}