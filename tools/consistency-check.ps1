<#
.SYNOPSIS
  Repo consistency + privacy checker - catches self-contradiction / drift / leaks mechanically.

.DESCRIPTION
  The guard that keeps this skill's "self-contradiction" risk near zero. Run after every edit.
  READ-ONLY: changes no file; emits a report + exit code (CI / pre-commit friendly).
  Bug classes it catches (all actually happened in this repo):
    1. Privacy leak    (company data / real multiplier-tag / instance name / Obsidian wikilink)
    2. Known stale/wrong string (a corrected menu path leaking back in)
    3. Broken internal link  ( ](file.md) target missing )
    4. Version mismatch  (skill.md version vs CHANGELOG top)
    5. Invented-column candidate (UPPER_SNAKE token absent from schema-map, single file - WARN)

  ASCII-only by design so Windows PowerShell 5.1 parses it regardless of file encoding/BOM.

.PARAMETER RepoRoot
  Repo root. Default: the script's parent folder.

.EXAMPLE
  .\consistency-check.ps1
  .\consistency-check.ps1 -RepoRoot "C:\path\to\repo"
#>
[CmdletBinding()]
param([string]$RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path $PSScriptRoot -Parent }
if (-not (Test-Path "$RepoRoot\skill.md")) { Write-Error "skill.md not found under: $RepoRoot"; exit 2 }

$refDir  = Join-Path $RepoRoot 'reference'
$toolDir = Join-Path $RepoRoot 'tools'
$mdFiles = @(Get-ChildItem $refDir -Filter *.md) + @(Get-Item "$RepoRoot\skill.md") + @(Get-ChildItem $RepoRoot -Filter *.md) + @(Get-ChildItem $toolDir -Filter *.md)
$mdFiles = $mdFiles | Sort-Object FullName -Unique
$fail = 0; $warn = 0
function Say($s){ Write-Output $s }
function Hit($file,$ln,$txt){ "   [{0}:{1}] {2}" -f (Split-Path $file -Leaf), $ln, ($txt.Trim()) }

# --- 1) PRIVACY / COMPANY-DATA LEAK (HARD FAIL) ---
Say "== 1) Privacy / company data =="
# Only GENERIC patterns may live in this script - it ships publicly. Install-specific
# patterns (instance name, real multiplier, internal project tag, ...) go in
# tools\private-patterns.local.txt (gitignored; one regex per line, '#' = comment).
# Template: private-patterns.sample.txt. Scans *.md AND tools\*.ps1 (incl. this file).
$privPatterns = @('\[\[')
$localPat = Join-Path $PSScriptRoot 'private-patterns.local.txt'
if (Test-Path $localPat) {
  $extra = @(Get-Content $localPat | Where-Object { $_.Trim() -and $_ -notmatch '^\s*#' })
  $privPatterns += $extra
  Say (" (+{0} private pattern(s) from private-patterns.local.txt)" -f $extra.Count)
} else {
  Say " (no private-patterns.local.txt - generic patterns only; expected on public clones)"
}
$privScan = @($mdFiles) + @(Get-ChildItem $toolDir -Filter *.ps1)
$privHits = @()
foreach ($f in $privScan) {
  foreach ($p in $privPatterns) {
    Select-String -Path $f.FullName -Pattern $p 2>$null | ForEach-Object { $privHits += (Hit $f.FullName $_.LineNumber $_.Line) }
  }
}
if ($privHits.Count -gt 0) { $fail++; Say " [FAIL] privacy pattern found:"; $privHits | ForEach-Object { Say $_ } }
else { Say " [OK] clean" }

# --- 2) KNOWN STALE / WRONG STRING (HARD FAIL) ---
Say "== 2) Known stale/wrong string =="
$stale = @{ 'Fatura Yerleri > Al' = "reprice path corrected -> 'Fatura Ayarlari > Alis Faturasi'" }
$staleHits = @()
foreach ($f in $mdFiles) {
  foreach ($k in $stale.Keys) {
    Select-String -Path $f.FullName -Pattern $k -SimpleMatch 2>$null | ForEach-Object {
      $staleHits += (Hit $f.FullName $_.LineNumber ($_.Line + "  <" + $stale[$k] + ">"))
    }
  }
}
if ($staleHits.Count -gt 0) { $fail++; Say " [FAIL] stale/wrong string:"; $staleHits | ForEach-Object { Say $_ } }
else { Say " [OK] no known-wrong string" }

# --- 3) BROKEN INTERNAL LINK (HARD FAIL) ---
Say "== 3) Broken internal link =="
$existing = @{}
$mdFiles | ForEach-Object { $existing[$_.Name] = $true }
$brokenLinks = @()
$linkRe = [regex]'\]\(([A-Za-z0-9_\-]+\.md)'
foreach ($f in $mdFiles) {
  $txt = Get-Content $f.FullName -Raw
  foreach ($m in $linkRe.Matches($txt)) {
    $tgt = $m.Groups[1].Value
    if (-not $existing.ContainsKey($tgt)) { $brokenLinks += ("   {0} -> {1} (TARGET MISSING)" -f (Split-Path $f.FullName -Leaf), $tgt) }
  }
}
if ($brokenLinks.Count -gt 0) { $fail++; Say " [FAIL] broken link:"; ($brokenLinks | Sort-Object -Unique) | ForEach-Object { Say $_ } }
else { Say " [OK] all internal links resolve" }

# --- 4) VERSION MISMATCH (HARD FAIL) ---
Say "== 4) Version match (skill.md vs CHANGELOG) =="
$skillM = Select-String -Path "$RepoRoot\skill.md" -Pattern '^version:\s*([0-9]+\.[0-9]+\.[0-9]+)' 2>$null | Select-Object -First 1
$chgM   = Select-String -Path "$RepoRoot\CHANGELOG.md" -Pattern '^##\s*\[([0-9]+\.[0-9]+\.[0-9]+)\]' 2>$null | Select-Object -First 1
$skillVer = if ($skillM) { $skillM.Matches.Groups[1].Value } else { '?' }
$chgVer   = if ($chgM)   { $chgM.Matches.Groups[1].Value }   else { '?' }
if ($skillVer -ne '?' -and $skillVer -eq $chgVer) { Say " [OK] version matches: $skillVer" }
else { $fail++; Say " [FAIL] skill.md=$skillVer, CHANGELOG=$chgVer" }

# --- 5) INVENTED-COLUMN CANDIDATE (SOFT WARN) ---
Say "== 5) Invented-column candidate (warn; not in schema-map) =="
$schemaTxt = Get-Content "$refDir\schema-map.md" -Raw
$allow = 'COLUMN_NAME|DATA_TYPE|IS_NULLABLE|TABLE_NAME|TABLE_TYPE|ORDINAL_POSITION|CHARACTER_MAXIMUM_LENGTH|DB_ID|DB_NAME|OBJECT_NAME|IO_STATS|GEN_ID|MAKINE_ID|TABLO_ADI|WOLVOX8_|_ANALIZ|_WOLVOX|_GMUHASEBE|_IKAYNAK'
$tokRe = [regex]'\b[A-Z][A-Z0-9]*(_[A-Z0-9]+)+\b'
$seen = @{}
foreach ($f in ($mdFiles | Where-Object { $_.Name -ne 'schema-map.md' })) {
  $txt = Get-Content $f.FullName -Raw
  $txt = [regex]::Replace($txt, '<[A-Z_][A-Z0-9_]*>', ' ')   # tani sorgu placeholder'larini ele (kolon iddiasi degil)
  foreach ($m in $tokRe.Matches($txt)) {
    $tok = $m.Value
    if ($tok -match $allow) { continue }
    if ($schemaTxt -match ('\b' + [regex]::Escape($tok) + '\b')) { continue }
    if (-not $seen.ContainsKey($tok)) { $seen[$tok] = @{} }
    $seen[$tok][$f.Name] = $true
  }
}
$suspect = $seen.GetEnumerator() | Where-Object { $_.Value.Keys.Count -eq 1 } | Sort-Object Key
if ($suspect) {
  $warn = $suspect.Count
  Say " [WARN] tokens not in schema-map, in a single file (eyeball - most are legit):"
  $suspect | ForEach-Object { Say ("   {0,-28} {1}" -f $_.Key, (($_.Value.Keys) -join ',')) }
} else { Say " [OK] no suspect column tokens" }

# --- SUMMARY ---
Say ""
Say "==================== SUMMARY ===================="
Say (" files: {0}  .  HARD FAIL: {1}  .  WARN(cols): {2}" -f $mdFiles.Count, $fail, $warn)
if ($fail -gt 0) { Say " RESULT: [FAIL] inconsistency present - fix it."; exit 1 }
else { Say " RESULT: [PASS] (warnings are informational)."; exit 0 }
