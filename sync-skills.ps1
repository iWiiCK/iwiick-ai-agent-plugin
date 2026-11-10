<#
.SYNOPSIS
  Install this repository's skills into the global Devin skills directory.

.DESCRIPTION
  Use this when account-level plugin installation is unavailable (no Devin
  Cloud account, or `devin plugins install` refuses with "You must be logged
  in"). It gives the same skills on any machine via `git pull` + this script,
  instead of automatic account sync.

  The repository stores skills with flat names (`clean-code`) because a plugin
  namespaces them as `/iwiick:clean-code`. The global skills directory has no
  namespace, so this script writes them prefixed (`iwiick-clean-code`) and
  rewrites the `name:` frontmatter and every cross-reference to match.

  Idempotent: it replaces only the `iwiick-*` directories it manages and
  leaves any other global skills untouched.

.PARAMETER Prefix
  Directory and skill-name prefix. Defaults to `iwiick-`. Pass '' for no
  prefix (not recommended — risks collisions with third-party global skills).

.PARAMETER SkillsRoot
  Target directory. Defaults to the Windows global skills path.

.PARAMETER DryRun
  Report what would change without writing anything.

.EXAMPLE
  .\sync-skills.ps1
.EXAMPLE
  .\sync-skills.ps1 -DryRun
#>
[CmdletBinding()]
param(
  [string]$Prefix = 'iwiick-',
  [string]$SkillsRoot = (Join-Path $env:APPDATA 'devin\skills'),
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# Read and write through .NET so the behaviour is identical on Windows
# PowerShell 5.1 and PowerShell 7+. Get-Content/Set-Content differ between
# them: 5.1 reads as ANSI (mangling em dashes and arrows) and writes a UTF-8
# BOM, which a SKILL.md must not carry ahead of its frontmatter.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$source = Join-Path $PSScriptRoot 'skills'
if (-not (Test-Path $source)) {
  throw "No skills directory at $source - run this from the plugin repository root."
}

$skillDirs = Get-ChildItem -Path $source -Directory
if ($skillDirs.Count -eq 0) { throw "No skills found in $source." }

# Every skill name in the repo, longest first, so `clean-code` cannot partially
# match inside `clean-code-update` when rewriting cross-references.
$names = $skillDirs.Name | Sort-Object -Property Length -Descending

Write-Host "Source:  $source"
Write-Host "Target:  $SkillsRoot"
Write-Host "Prefix:  $(if ($Prefix) { $Prefix } else { '<none>' })"
Write-Host "Skills:  $($skillDirs.Count)"
if ($DryRun) { Write-Host "`n-- DRY RUN: nothing will be written --" -ForegroundColor Yellow }
Write-Host ''

if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null }

# Remove previously synced directories so a skill deleted upstream also
# disappears locally. Only ever touches this prefix.
if ($Prefix) {
  $stale = Get-ChildItem -Path $SkillsRoot -Directory -Filter "$Prefix*" -ErrorAction SilentlyContinue
  foreach ($dir in $stale) {
    Write-Host "  remove  $($dir.Name)"
    if (-not $DryRun) { Remove-Item -Recurse -Force $dir.FullName }
  }
}

foreach ($skill in $skillDirs) {
  $sourceFile = Join-Path $skill.FullName 'SKILL.md'
  if (-not (Test-Path $sourceFile)) {
    Write-Warning "  skip    $($skill.Name) - no SKILL.md"
    continue
  }

  $targetName = "$Prefix$($skill.Name)"
  $targetDir = Join-Path $SkillsRoot $targetName
  $content = [System.IO.File]::ReadAllText($sourceFile)

  if ($Prefix) {
    foreach ($name in $names) {
      # Cross-references, written as `skill-name` in backticks.
      $content = $content.Replace("``$name``", "``$Prefix$name``")
      # The frontmatter name field, anchored to its own line. The end-of-line
      # is matched with a lookahead so the CR of a CRLF file is not consumed,
      # which would otherwise leave this one line LF-terminated.
      $content = [regex]::Replace(
        $content,
        "(?m)^name:[ \t]*$([regex]::Escape($name))(?=[ \t]*\r?$)",
        "name: $Prefix$name"
      )
    }
  }

  # End with exactly one newline, so the output is stable and comparable with
  # `diff` regardless of how the source file happens to be terminated.
  $content = $content.TrimEnd("`r", "`n") + "`r`n"

  Write-Host "  write   $targetName"
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $targetDir 'SKILL.md'), $content, $utf8NoBom)
  }
}

Write-Host ''
if ($DryRun) {
  Write-Host 'Dry run complete. Re-run without -DryRun to apply.' -ForegroundColor Yellow
} else {
  Write-Host "Synced $($skillDirs.Count) skills to $SkillsRoot" -ForegroundColor Green
  Write-Host 'Verify with: devin skills list'
}
