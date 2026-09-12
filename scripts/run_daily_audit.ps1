<#
.SYNOPSIS
    Run the daily operations / staff-conduct audit against staging or production.

.DESCRIPTION
    Wraps scripts/checks/daily_ops_audit.py in the one stable remote_exec.ps1
    command shape, strips the JZAUDIT transport marker, and writes a dated
    report. READ-ONLY: the payload only SELECTs, so it never needs -AllowWrite.

    Designed to be run unattended from Windows Task Scheduler at 04:05 local,
    covering the day that just ended. It always exits 0 so the scheduler does
    not flag a run that merely found problems; read $LASTEXITCODE only to tell a
    transport failure from a clean run.

.PARAMETER Environment
    staging | production. Default production.

.PARAMETER Days
    How many days back to audit. Default 1 (yesterday 00:00 to now).

.PARAMETER OutDir
    Where to write the dated report. Default C:\ERPNext\.audit-reports.

.PARAMETER Quiet
    Write the report file but do not echo it to the console.

.EXAMPLE
    ./run_daily_audit.ps1
    ./run_daily_audit.ps1 -Environment staging -Days 7
#>
[CmdletBinding()]
param(
    [ValidateSet('staging', 'production')]
    [string]$Environment = 'production',

    [ValidateRange(1, 120)]
    [int]$Days = 1,

    [string]$OutDir = 'C:\ERPNext\.audit-reports',

    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

# Findings quote Arabic JE remarks and the "->" in shift messages. Windows
# PowerShell 5.1 decodes a child process's stdout as the ANSI codepage unless
# told otherwise, which turns both into mojibake in the report.
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

$checkSrc = Join-Path $PSScriptRoot 'checks\daily_ops_audit.py'
if (-not (Test-Path $checkSrc)) { throw "Audit payload not found at $checkSrc" }

$remoteExec = Join-Path $PSScriptRoot 'remote_exec.ps1'
if (-not (Test-Path $remoteExec)) { throw "remote_exec.ps1 not found at $remoteExec" }

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force $OutDir | Out-Null }

# Materialise the payload with the requested window. Written without a BOM:
# remote_exec base64-wraps the file, and a BOM would ride into the cell.
$payload = Get-Content -Raw -Encoding UTF8 $checkSrc
$payload = $payload -replace '(?m)^AUDIT_DAYS = \d+', "AUDIT_DAYS = $Days"
$tmp = Join-Path $env:TEMP ("jz_daily_audit_{0}.py" -f (Get-Date -Format 'yyyyMMddHHmmss'))
[System.IO.File]::WriteAllText($tmp, $payload, (New-Object System.Text.UTF8Encoding($false)))

$stamp = Get-Date -Format 'yyyy-MM-dd'
$report = Join-Path $OutDir ("ops-audit-{0}-{1}.txt" -f $Environment, $stamp)

Write-Host "[STEP] auditing $Environment over the last $Days day(s)" -ForegroundColor Cyan

$raw = & $remoteExec -Environment $Environment -File $tmp -Marker 'JZAUDIT'
Remove-Item $tmp -Force -ErrorAction SilentlyContinue

$lines = @($raw | Where-Object { $_ -match 'JZAUDIT' } |
    ForEach-Object { ($_ -replace '^.*?JZAUDIT ', '').TrimEnd() })

if ($lines.Count -eq 0) {
    $body = @(
        "Jarz ops audit - $Environment - $stamp",
        "",
        "TRANSPORT FAILURE: the probe returned no JZAUDIT lines.",
        "Check SSH reachability and that the site is up, then re-run:",
        "  powershell -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Environment $Environment",
        "",
        "--- raw output ---"
    ) + $raw
    [System.IO.File]::WriteAllLines($report, $body, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "[WARN] no findings returned - see $report" -ForegroundColor Yellow
    exit 0
}

$high = @($lines | Where-Object { $_ -match '^ALERT HIGH ' }).Count
$med = @($lines | Where-Object { $_ -match '^ALERT MED ' }).Count
$low = @($lines | Where-Object { $_ -match '^ALERT LOW ' }).Count

$header = @(
    "Jarz ops audit - $Environment - generated $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    "Window: last $Days day(s).  HIGH=$high  MED=$med  LOW=$low",
    ("=" * 78),
    ""
)
$ordered = @($lines | Where-Object { $_ -match '^(window|SUMMARY)' }) +
           @($lines | Where-Object { $_ -match '^ALERT HIGH ' }) +
           @($lines | Where-Object { $_ -match '^ALERT MED ' }) +
           @($lines | Where-Object { $_ -match '^ALERT LOW ' }) +
           @("", "--- passing checks ---") +
           @($lines | Where-Object { $_ -match '^OK ' }) +
           @("", "--- detail ---") +
           @($lines | Where-Object { $_ -match '^\s+- ' })

[System.IO.File]::WriteAllLines($report, ($header + $ordered),
    (New-Object System.Text.UTF8Encoding($false)))

if (-not $Quiet) { $header + $ordered | ForEach-Object { Write-Host $_ } }
Write-Host "[INFO] report written to $report" -ForegroundColor Green
Write-Host "[INFO] HIGH=$high MED=$med LOW=$low" -ForegroundColor Green
exit 0
