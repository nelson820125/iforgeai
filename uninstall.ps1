#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Uninstall jordium-forgeai from VS Code / GitHub Copilot.

.DESCRIPTION
    Removes all agents, skills, instructions, and prompts installed by
    install.ps1, and restores VS Code settings.json to its pre-install
    state: if chat.pluginLocations existed before forgeai was installed,
    the original value is restored; otherwise the key is removed entirely.

    Supports Windows, macOS, and Linux.

.PARAMETER DryRun
    Preview all operations without deleting anything.

.EXAMPLE
    ./uninstall.ps1
    ./uninstall.ps1 -DryRun
#>

[CmdletBinding()]
param(
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Polyfill automatic variables absent in Windows PowerShell 5.x
if (-not (Get-Variable -Name 'IsWindows' -ErrorAction SilentlyContinue)) {
    $IsWindows = $env:OS -eq 'Windows_NT'
    $IsMacOS   = $false
    $IsLinux   = $false
}

# -----------------------------------------------------------------
# 1. Resolve paths
# -----------------------------------------------------------------

function Get-InstallPaths {
    $homeDir = $HOME

    if ($IsWindows) {
        $appData = if ($env:APPDATA) { $env:APPDATA } else { Join-Path $homeDir 'AppData\Roaming' }
        return [ordered]@{
            AgentsDir       = Join-Path $appData 'Code\User\agents'
            InstructionsDir = Join-Path $appData 'Code\User\instructions'
            PromptsDir      = Join-Path $appData 'Code\User\prompts'
            SkillsDir       = Join-Path $homeDir '.copilot\skills'
            SettingsFile    = Join-Path $appData 'Code\User\settings.json'
            UserDir         = Join-Path $appData 'Code\User'
        }
    }
    elseif ($IsMacOS) {
        $userBase = Join-Path $homeDir 'Library/Application Support/Code/User'
        return [ordered]@{
            AgentsDir       = Join-Path $userBase 'agents'
            InstructionsDir = Join-Path $userBase 'instructions'
            PromptsDir      = Join-Path $userBase 'prompts'
            SkillsDir       = Join-Path $homeDir '.copilot/skills'
            SettingsFile    = Join-Path $userBase 'settings.json'
            UserDir         = $userBase
        }
    }
    else {
        $userBase = Join-Path $homeDir '.config/Code/User'
        return [ordered]@{
            AgentsDir       = Join-Path $userBase 'agents'
            InstructionsDir = Join-Path $userBase 'instructions'
            PromptsDir      = Join-Path $userBase 'prompts'
            SkillsDir       = Join-Path $homeDir '.copilot/skills'
            SettingsFile    = Join-Path $userBase 'settings.json'
            UserDir         = $userBase
        }
    }
}

$paths = Get-InstallPaths

# -----------------------------------------------------------------
# 2. Files installed by install.ps1 (derived from copilot/ source)
# -----------------------------------------------------------------

$agentFiles = @(
    'architect.agent.md'
    'dba-designer.agent.md'
    'digital-team.agent.md'
    'dotnet-engineer.agent.md'
    'frontend-engineer.agent.md'
    'pm.agent.md'
    'project-manager.agent.md'
    'qa-engineer.agent.md'
    'ui-designer.agent.md'
)

$instructionFiles = @(
    'coding-standards-dotnet.instructions.md'
    'coding-standards-frontend.instructions.md'
    'output-standards.instructions.md'
)

$promptFiles = @(
    'new-project-init.prompt.md'
)

# Skill subdirectories (each contains SKILL.md)
$skillDirs = @(
    'architect'
    'dba-designer'
    'dotnet-engineer'
    'frontend-engineer'
    'product-manager'
    'project-manager'
    'quality-assurance-engineer'
    'ui-designer'
)

# -----------------------------------------------------------------
# 3. Helper
# -----------------------------------------------------------------

$removed  = 0
$notFound = 0

function Remove-InstalledFile {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        Write-Host "    SKIP  $Path (not found)" -ForegroundColor DarkGray
        $script:notFound++
        return
    }

    if ($DryRun) {
        Write-Host "    [DRY] Would remove: $Path" -ForegroundColor Magenta
        return
    }

    Remove-Item -Path $Path -Force
    Write-Host "    OK    $Path" -ForegroundColor Green
    $script:removed++
}

function Remove-DirIfEmpty {
    param([string]$Path)
    if (-not $DryRun -and (Test-Path $Path)) {
        $items = Get-ChildItem $Path -ErrorAction SilentlyContinue
        if (-not $items) {
            Remove-Item $Path -Force
            Write-Host "    OK    (empty dir removed) $Path" -ForegroundColor DarkYellow
        }
    }
}

# -----------------------------------------------------------------
# 4. Summary
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  jordium-forgeai Uninstaller' -ForegroundColor Cyan
Write-Host '  ------------------------------------------------------' -ForegroundColor DarkGray
Write-Host "    Agents dir    : $($paths['AgentsDir'])"
Write-Host "    Instructions  : $($paths['InstructionsDir'])"
Write-Host "    Prompts       : $($paths['PromptsDir'])"
Write-Host "    Skills        : $($paths['SkillsDir'])"
Write-Host "    Settings      : $($paths['SettingsFile'])"
Write-Host ''

if ($DryRun) {
    Write-Host '  [DRY RUN MODE] No files will be deleted.' -ForegroundColor Magenta
    Write-Host ''
}
else {
    $confirm = Read-Host '  This will delete all forgeai agents, skills, instructions, and prompts. Continue? [y/N]'
    if ($confirm -notmatch '^[Yy]') {
        Write-Host '  Uninstall cancelled.' -ForegroundColor Yellow
        exit 0
    }
}

# -----------------------------------------------------------------
# 5. Remove agents
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  Removing agents...' -ForegroundColor Cyan

foreach ($file in $agentFiles) {
    Remove-InstalledFile -Path (Join-Path $paths['AgentsDir'] $file)
}
Remove-DirIfEmpty -Path $paths['AgentsDir']

# -----------------------------------------------------------------
# 6. Remove instructions
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  Removing instructions...' -ForegroundColor Cyan

foreach ($file in $instructionFiles) {
    Remove-InstalledFile -Path (Join-Path $paths['InstructionsDir'] $file)
}
Remove-DirIfEmpty -Path $paths['InstructionsDir']

# -----------------------------------------------------------------
# 7. Remove prompts
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  Removing prompts...' -ForegroundColor Cyan

foreach ($file in $promptFiles) {
    Remove-InstalledFile -Path (Join-Path $paths['PromptsDir'] $file)
}
Remove-DirIfEmpty -Path $paths['PromptsDir']

# -----------------------------------------------------------------
# 8. Remove skills
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  Removing skills...' -ForegroundColor Cyan

foreach ($dir in $skillDirs) {
    $skillFile = Join-Path (Join-Path $paths['SkillsDir'] $dir) 'SKILL.md'
    Remove-InstalledFile -Path $skillFile
    Remove-DirIfEmpty -Path (Join-Path $paths['SkillsDir'] $dir)
}
Remove-DirIfEmpty -Path $paths['SkillsDir']

# -----------------------------------------------------------------
# 9. Restore VS Code settings.json to pre-install state
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  Restoring VS Code settings...' -ForegroundColor Cyan

$settingsFile = $paths['SettingsFile']
$userDir      = $paths['UserDir']
$backupFile   = Join-Path $userDir '.forgeai-settings-backup.json'
$pluginKey    = $userDir.Replace('\', '\\')

if (-not (Test-Path $settingsFile)) {
    Write-Host "    SKIP  settings.json not found at $settingsFile" -ForegroundColor DarkGray
}
elseif ($DryRun) {
    if (Test-Path $backupFile) {
        $backup = Get-Content $backupFile -Raw | ConvertFrom-Json
        if ($backup.existed) {
            Write-Host '    [DRY] Would RESTORE original chat.pluginLocations (had other entries before install)' -ForegroundColor Magenta
        }
        else {
            Write-Host '    [DRY] Would REMOVE chat.pluginLocations (was added fresh by forgeai)' -ForegroundColor Magenta
        }
    }
    else {
        Write-Host '    [DRY] Would remove chat.pluginLocations from settings.json (no backup found)' -ForegroundColor Magenta
    }
}
else {
    $raw = [System.IO.File]::ReadAllText($settingsFile, [System.Text.Encoding]::UTF8)

    if ($raw -notmatch 'chat\.pluginLocations') {
        Write-Host '    SKIP  chat.pluginLocations not present in settings.json' -ForegroundColor DarkGray
    }
    else {
        if (Test-Path $backupFile) {
            $backup = Get-Content $backupFile -Raw | ConvertFrom-Json

            if ($backup.existed) {
                # chat.pluginLocations existed before install -- restore the original block
                $currentMatch = [regex]::Match($raw, '"chat\.pluginLocations"\s*:\s*\{[^}]*\}')
                if ($currentMatch.Success) {
                    $raw = $raw.Replace($currentMatch.Value, $backup.originalBlock)
                    [System.IO.File]::WriteAllText($settingsFile, $raw, [System.Text.UTF8Encoding]::new($false))
                    Write-Host '    OK    Restored original chat.pluginLocations' -ForegroundColor Green
                }
                else {
                    Write-Host '    WARN  Could not locate chat.pluginLocations block to restore' -ForegroundColor Yellow
                }
            }
            else {
                # chat.pluginLocations did not exist before install -- remove it entirely
                $cleaned = $raw -replace ',\s*"chat\.pluginLocations"\s*:\s*\{[^}]*\}', ''
                $cleaned = $cleaned -replace '"chat\.pluginLocations"\s*:\s*\{[^}]*\}\s*,?', ''
                $cleaned = $cleaned -replace ',(\s*\})', '$1'
                [System.IO.File]::WriteAllText($settingsFile, $cleaned, [System.Text.UTF8Encoding]::new($false))
                Write-Host '    OK    Removed chat.pluginLocations from settings.json' -ForegroundColor Green
            }

            Remove-Item $backupFile -Force
            Write-Host "    OK    Removed backup file $(Split-Path $backupFile -Leaf)" -ForegroundColor Green
        }
        else {
            # No backup file -- fall back to removing the entire block, warn the user
            Write-Host '    WARN  No backup file found; removing entire chat.pluginLocations block' -ForegroundColor Yellow
            $cleaned = $raw -replace ',\s*"chat\.pluginLocations"\s*:\s*\{[^}]*\}', ''
            $cleaned = $cleaned -replace '"chat\.pluginLocations"\s*:\s*\{[^}]*\}\s*,?', ''
            $cleaned = $cleaned -replace ',(\s*\})', '$1'
            [System.IO.File]::WriteAllText($settingsFile, $cleaned, [System.Text.UTF8Encoding]::new($false))
            Write-Host '    OK    Removed chat.pluginLocations from settings.json' -ForegroundColor Green
        }
    }
}

# -----------------------------------------------------------------
# 10. Done
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  ------------------------------------------------------' -ForegroundColor DarkGray

if ($DryRun) {
    Write-Host '  [DRY RUN complete -- no files were deleted]' -ForegroundColor Magenta
}
else {
    Write-Host "  Uninstall complete.  $removed removed,  $notFound already absent." -ForegroundColor Green
    Write-Host ''
    Write-Host '  Reload VS Code to apply:  Ctrl+Shift+P  ->  Developer: Reload Window' -ForegroundColor Cyan
}

Write-Host ''
