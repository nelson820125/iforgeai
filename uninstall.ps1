#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Uninstall iforgeAI from VS Code / GitHub Copilot and/or Trae IDE.

.DESCRIPTION
    Removes all agents, skills, instructions, and prompts installed by
    install.ps1, and restores VS Code settings.json to its pre-install state.

    During the interactive session you will be asked which tool(s) to uninstall:
      1. GitHub Copilot only  (default)
      2. Trae only
      3. Both

    For Trae, you will also be asked which edition:
      1. Trae CN  (default)
      2. Trae International

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

function Get-CopilotInstallPaths {
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

function Get-TraeInstallPaths {
    param([string]$Edition)

    $homeDir = $HOME
    $dirName = if ($Edition -eq 'cn') { '.trae-cn' } else { '.trae' }

    if ($IsWindows) {
        return [ordered]@{
            SkillsDir       = Join-Path $homeDir "$dirName\skills"
            InstructionsDir = Join-Path $homeDir "$dirName\instructions"
        }
    }
    elseif ($IsMacOS) {
        $appName = if ($Edition -eq 'cn') { 'trae-cn' } else { 'trae' }
        return [ordered]@{
            SkillsDir       = Join-Path $homeDir "Library/Application Support/$appName/skills"
            InstructionsDir = Join-Path $homeDir "Library/Application Support/$appName/instructions"
        }
    }
    else {
        return [ordered]@{
            SkillsDir       = Join-Path $homeDir "$dirName/skills"
            InstructionsDir = Join-Path $homeDir "$dirName/instructions"
        }
    }
}

function Show-IforgeaiLogo {
    $logo = @(
        ' ___ _____ ___  ____   ____ _____    _    ___ ',
        '|_ _|  ___/ _ \|  _ \ / ___| ____|  / \  |_ _|',
        ' | || |_ | | | | |_) | |  _|  _|   / _ \  | | ',
        ' | ||  _|| |_| |  _ <| |_| | |___ / ___ \ | | ',
        '|___|_|   \___/|_| \_\\____|_____/_/   \_\___|'
    )

    foreach ($line in $logo) {
        Write-Host $line -ForegroundColor Cyan
    }
}

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

function Get-SettingsBackupFile {
    param([string]$UserDir)

    # Keep the legacy backup filename for users upgrading from forgeai.
    $candidateFiles = @(
        (Join-Path $UserDir '.iforgeai-settings-backup.json'),
        (Join-Path $UserDir '.forgeai-settings-backup.json')
    )

    foreach ($candidate in $candidateFiles) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return $candidateFiles[0]
}

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
# 4. Interactive: tool selection
# -----------------------------------------------------------------

Write-Host ''
Show-IforgeaiLogo
Write-Host '  iforgeAI Uninstaller' -ForegroundColor Cyan
Write-Host '  ------------------------------------------------------' -ForegroundColor DarkGray
Write-Host ''
Write-Host '  Which tool(s) to uninstall?' -ForegroundColor Yellow
Write-Host '    1   GitHub Copilot only  [default]'
Write-Host '    2   Trae only'
Write-Host '    3   Both'
Write-Host ''
$toolChoice     = Read-Host '  Select [Enter = 1]'
$uninstallCopilot = $toolChoice -ne '2'
$uninstallTrae    = $toolChoice -eq '2' -or $toolChoice -eq '3'

$traeEdition = 'cn'
if ($uninstallTrae) {
    Write-Host ''
    Write-Host '  Trae Edition:' -ForegroundColor Yellow
    Write-Host '    1   Trae CN  [default]'
    Write-Host '    2   Trae International'
    Write-Host ''
    $editionChoice = Read-Host '  Select [Enter = 1]'
    $traeEdition   = if ($editionChoice -eq '2') { 'international' } else { 'cn' }
}

$copilotPaths = Get-CopilotInstallPaths
$traePaths    = if ($uninstallTrae) { Get-TraeInstallPaths -Edition $traeEdition } else { $null }

# --- Summary display
Write-Host ''
if ($uninstallCopilot) {
    Write-Host "    Copilot Agents dir    : $($copilotPaths['AgentsDir'])"
    Write-Host "    Copilot Instructions  : $($copilotPaths['InstructionsDir'])"
    Write-Host "    Copilot Prompts       : $($copilotPaths['PromptsDir'])"
    Write-Host "    Copilot Skills        : $($copilotPaths['SkillsDir'])"
    Write-Host "    VS Code Settings      : $($copilotPaths['SettingsFile'])"
}
if ($uninstallTrae) {
    Write-Host "    Trae Skills           : $($traePaths['SkillsDir'])"
    Write-Host "    Trae Instructions     : $($traePaths['InstructionsDir'])"
}
Write-Host ''

if ($DryRun) {
    Write-Host '  [DRY RUN MODE] No files will be deleted.' -ForegroundColor Magenta
    Write-Host ''
}
else {
    $confirm = Read-Host '  This will delete all selected iforgeAI files. Continue? [y/N]'
    if ($confirm -notmatch '^[Yy]') {
        Write-Host '  Uninstall cancelled.' -ForegroundColor Yellow
        exit 0
    }
}

# -----------------------------------------------------------------
# 5. Remove Copilot agents
# -----------------------------------------------------------------

if ($uninstallCopilot) {
    Write-Host ''
    Write-Host '  [Copilot] Removing agents...' -ForegroundColor Cyan

    foreach ($file in $agentFiles) {
        Remove-InstalledFile -Path (Join-Path $copilotPaths['AgentsDir'] $file)
    }
    Remove-DirIfEmpty -Path $copilotPaths['AgentsDir']
}

# -----------------------------------------------------------------
# 6. Remove Copilot instructions
# -----------------------------------------------------------------

if ($uninstallCopilot) {
    Write-Host ''
    Write-Host '  [Copilot] Removing instructions...' -ForegroundColor Cyan

    foreach ($file in $instructionFiles) {
        Remove-InstalledFile -Path (Join-Path $copilotPaths['InstructionsDir'] $file)
    }
    Remove-DirIfEmpty -Path $copilotPaths['InstructionsDir']
}

# -----------------------------------------------------------------
# 7. Remove Copilot prompts
# -----------------------------------------------------------------

if ($uninstallCopilot) {
    Write-Host ''
    Write-Host '  [Copilot] Removing prompts...' -ForegroundColor Cyan

    foreach ($file in $promptFiles) {
        Remove-InstalledFile -Path (Join-Path $copilotPaths['PromptsDir'] $file)
    }
    Remove-DirIfEmpty -Path $copilotPaths['PromptsDir']
}

# -----------------------------------------------------------------
# 8. Remove Copilot skills
# -----------------------------------------------------------------

if ($uninstallCopilot) {
    Write-Host ''
    Write-Host '  [Copilot] Removing skills...' -ForegroundColor Cyan

    foreach ($dir in $skillDirs) {
        $skillFile = Join-Path (Join-Path $copilotPaths['SkillsDir'] $dir) 'SKILL.md'
        Remove-InstalledFile -Path $skillFile
        Remove-DirIfEmpty -Path (Join-Path $copilotPaths['SkillsDir'] $dir)
    }
    Remove-DirIfEmpty -Path $copilotPaths['SkillsDir']
}

# -----------------------------------------------------------------
# 8b. Remove Trae skills
# -----------------------------------------------------------------

if ($uninstallTrae) {
    Write-Host ''
    Write-Host '  [Trae] Removing skills...' -ForegroundColor Cyan

    # Remove all skill subdirectories installed by iforgeai (same list as Copilot + digital-team)
    $traeSkillDirs = $skillDirs + @('digital-team')
    foreach ($dir in $traeSkillDirs) {
        $skillFile = Join-Path (Join-Path $traePaths['SkillsDir'] $dir) 'SKILL.md'
        Remove-InstalledFile -Path $skillFile
        Remove-DirIfEmpty -Path (Join-Path $traePaths['SkillsDir'] $dir)
    }
    Remove-DirIfEmpty -Path $traePaths['SkillsDir']
}

# -----------------------------------------------------------------
# 8c. Remove Trae instructions
# -----------------------------------------------------------------

if ($uninstallTrae) {
    Write-Host ''
    Write-Host '  [Trae] Removing instructions...' -ForegroundColor Cyan

    # Remove all coding-standards files installed for Trae
    $traeInstrFiles = @(
        'coding-standards-dotnet.instructions.md'
        'coding-standards-frontend.instructions.md'
        'coding-standards-java.instructions.md'
        'coding-standards-python.instructions.md'
        'output-standards.instructions.md'
    )
    foreach ($file in $traeInstrFiles) {
        Remove-InstalledFile -Path (Join-Path $traePaths['InstructionsDir'] $file)
    }
    Remove-DirIfEmpty -Path $traePaths['InstructionsDir']
}

# -----------------------------------------------------------------
# 9. Restore VS Code settings.json to pre-install state (Copilot only)
# -----------------------------------------------------------------

if ($uninstallCopilot) {
    Write-Host ''
    Write-Host '  [Copilot] Restoring VS Code settings...' -ForegroundColor Cyan

    $settingsFile = $copilotPaths['SettingsFile']
    $userDir      = $copilotPaths['UserDir']
    $backupFile   = Get-SettingsBackupFile -UserDir $userDir

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
                Write-Host '    [DRY] Would REMOVE chat.pluginLocations (was added fresh by iforgeAI)' -ForegroundColor Magenta
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
                Write-Host '    WARN  No backup file found; removing entire chat.pluginLocations block' -ForegroundColor Yellow
                $cleaned = $raw -replace ',\s*"chat\.pluginLocations"\s*:\s*\{[^}]*\}', ''
                $cleaned = $cleaned -replace '"chat\.pluginLocations"\s*:\s*\{[^}]*\}\s*,?', ''
                $cleaned = $cleaned -replace ',(\s*\})', '$1'
                [System.IO.File]::WriteAllText($settingsFile, $cleaned, [System.Text.UTF8Encoding]::new($false))
                Write-Host '    OK    Removed chat.pluginLocations from settings.json' -ForegroundColor Green
            }
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
    if ($uninstallCopilot) {
        Write-Host '  Reload VS Code to apply:  Ctrl+Shift+P  ->  Developer: Reload Window' -ForegroundColor Cyan
    }
    if ($uninstallTrae) {
        Write-Host '  Restart Trae IDE to apply the changes.' -ForegroundColor Cyan
    }
}

Write-Host ''
