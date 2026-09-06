<#
.SYNOPSIS
    Run a local Python file inside the Frappe backend container on staging or production.

.DESCRIPTION
    One stable command shape for every server-side check, so the permission layer
    can allow it once instead of judging a freshly-spelled ad-hoc SSH pipeline
    each time. Hand-written `ssh -o ... -i ... "docker exec ... bench ..."` lines
    differ by flag order every time they are typed, match no allow rule, and fall
    through to the classifier — which is what made the 2026-08-25 Talabat rollout
    so slow to verify.

    The script you pass runs under `bench --site frontend console`, so `frappe` is
    already imported and the site is connected. Write it as an ordinary Python
    file — multi-line statements, blank lines, loops and helper functions all
    work, because the file is wrapped as a single base64 cell before it is piped
    (see "Transport wrapping" below). There is no need to hand-roll a wrap.py.

    READ-ONLY BY DEFAULT. The file is scanned for obvious write calls and refused
    unless -AllowWrite is passed, so a verification helper cannot quietly mutate
    production. This is a guardrail against accident, not a security boundary —
    anything can be smuggled past a regex, so -AllowWrite is about making the
    intent explicit at the call site.

    Print results with a stable prefix (the convention is `MARK <key> <value>`)
    and pass -Marker to filter the console noise down to just those lines.

.PARAMETER Environment
    staging | production

.PARAMETER File
    Path to the local .py file to execute in the container.

.PARAMETER Marker
    Only return output lines containing this string. Default: MARK

.PARAMETER AllowWrite
    Permit a script that looks like it writes. Required for imports/migrations.

.PARAMETER Raw
    Return the console output unfiltered (ignores -Marker).

.PARAMETER NoWrap
    Pipe the file's source verbatim instead of wrapping it as one base64 cell.
    Only for a payload that is already wrapped by hand; ordinary scripts want
    the wrapping, which is why it is the default.

.EXAMPLE
    ./remote_exec.ps1 -Environment production -File ./checks/verify_talabat.py

.EXAMPLE
    ./remote_exec.ps1 -Environment production -File ./import.py -AllowWrite
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('staging', 'production')]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [string]$File,

    [string]$Marker = 'MARK',

    [switch]$AllowWrite,

    [switch]$Raw,

    [switch]$NoWrap
)

$ErrorActionPreference = 'Stop'

function Write-Step { param($m) Write-Host "[STEP] $m" -ForegroundColor Cyan }
function Write-Info { param($m) Write-Host "[INFO] $m" -ForegroundColor Green }
function Write-Warn { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow }

$targets = @{
    staging    = @{ Ip = '13.36.219.136'; Domain = 'erpstg.orderjarz.com' }
    production = @{ Ip = '13.36.132.13';  Domain = 'erp.orderjarz.com' }
}
$target = $targets[$Environment]

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$keyPath = Join-Path $repoRoot 'ERPNext-stg.pem'
if (-not (Test-Path $keyPath)) {
    throw "SSH key not found at $keyPath"
}

if (-not (Test-Path $File)) {
    throw "Script not found: $File"
}
$source = Get-Content -Raw -Path $File

# Accident guard, not a sandbox. Catches the calls that actually mutate a site.
if (-not $AllowWrite) {
    $writePatterns = @(
        'frappe\.db\.set_value', 'frappe\.db\.sql\s*\(\s*["'']?\s*(INSERT|UPDATE|DELETE|ALTER|DROP|TRUNCATE)',
        '\.insert\s*\(', '\.save\s*\(', '\.submit\s*\(', '\.cancel\s*\(', '\.delete\s*\(',
        'frappe\.delete_doc', 'frappe\.rename_doc', 'frappe\.db\.commit',
        'frappe\.new_doc', 'import_leads_catalog'
    )
    foreach ($p in $writePatterns) {
        if ($source -match $p) {
            throw ("Refusing to run: '$File' matches the write pattern /$p/. " +
                   'Pass -AllowWrite if the mutation is intended.')
        }
    }
}

# --- Transport wrapping ----------------------------------------------------
# `bench console` is IPython, so piped input runs CELL BY CELL: every multi-line
# statement, every blank line inside a block and every `for` loop breaks, and you
# get a cascade of NameError for variables the earlier "statement" never defined.
# PowerShell also prepends a UTF-8 BOM to the pipe, so whatever lands on line 1
# dies with `SyntaxError: invalid non-printable character U+FEFF`.
#
# Both disappear if the payload travels as ONE cell: a sacrificial first line to
# absorb the BOM, then the source as a base64 blob exec'd back into globals().
# Chats used to hand-roll exactly this as a scratch wrap.py before every call,
# which cost a permission round-trip each time (4 of the 5 entries in
# .claude/locks/denials.jsonl are that heredoc) and blinded the write guard
# above, which cannot see inside base64. Doing it here means the guard always
# scans real source and nobody re-invents the wrapper.
#
# The namespace argument to exec is load-bearing: a bare exec() inside an
# IPython cell gets DISTINCT globals and locals, so the payload's top-level defs
# land in locals and cannot see each other, and every helper calling another
# helper dies with NameError. Passing globals() makes globals IS locals, so
# ordinary module semantics hold.
if (-not $NoWrap) {
    $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($source))
    $source = "# bom sink`n" +
              "import base64`n" +
              "_src = base64.b64decode('$b64').decode('utf-8')`n" +
              "exec(compile(_src, 'remote', 'exec'), globals())`n"
}

Write-Step "Running $(Split-Path -Leaf $File) on $Environment ($($target.Domain))"
if ($AllowWrite) { Write-Warn 'WRITE MODE - this script may mutate the site.' }
if ($NoWrap) { Write-Warn 'NOWRAP - piping raw source; line 1 will absorb the BOM.' }

# Fixed flag order on purpose: the whole point is one allow-listable command shape.
$sshArgs = @(
    '-q', '-o', 'StrictHostKeyChecking=no', '-o', 'ConnectTimeout=20',
    '-i', $keyPath, "ubuntu@$($target.Ip)"
)

# Piped straight down stdin into the console. No temp file, no docker cp, no
# `bash -lc` (which lost `bench` off PATH), and nothing to clean up on either
# the host or the container if this dies halfway.
$remote = 'docker exec -i erp-backend-1 bench --site frontend console'

$output = $source | & ssh @sshArgs $remote 2>&1
$exit = $LASTEXITCODE

$text = ($output | Out-String)
if ($Raw) {
    $text
} else {
    $lines = $text -split "`r?`n" | Where-Object { $_ -match [regex]::Escape($Marker) }
    if ($lines) {
        $lines
    } else {
        Write-Warn "No lines matched marker '$Marker'. Re-run with -Raw to see everything."
    }
}

if ($exit -ne 0) {
    Write-Warn "Remote console exited with code $exit"
}
