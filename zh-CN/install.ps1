#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Install iforgeAI AI development team to VS Code / GitHub Copilot.

.DESCRIPTION
    Copies agents, skills, instructions, and prompts to your user-level
    VS Code / GitHub Copilot configuration directory.

    Supports Windows, macOS, and Linux (requires PowerShell 7+ / pwsh).
    Agent files are updated with your actual skills directory path after copying.

.PARAMETER Force
    Overwrite existing files without prompting.

.PARAMETER SkipSkills
    Skip installing skills (if you manage them separately).

.PARAMETER DryRun
    Preview all operations without writing any files.

.EXAMPLE
    ./install.ps1
    ./install.ps1 -Force
    ./install.ps1 -DryRun
    ./install.ps1 -SkipSkills -Force
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$SkipSkills,
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
# 1. Platform detection -- calculate default paths
# -----------------------------------------------------------------

function Get-DefaultPaths {
    $homeDir = $HOME

    # Windows
    if ($IsWindows) {
        $appData = if ($env:APPDATA) { $env:APPDATA } else { Join-Path $homeDir 'AppData\Roaming' }
        return [ordered]@{
            AgentsDir       = Join-Path $appData  'Code\User\agents'
            InstructionsDir = Join-Path $appData  'Code\User\instructions'
            PromptsDir      = Join-Path $appData  'Code\User\prompts'
            SkillsDir       = Join-Path $homeDir  '.copilot\skills'
        }
    }
    elseif ($IsMacOS) {
        return [ordered]@{
            AgentsDir       = Join-Path $homeDir 'Library/Application Support/Code/User/agents'
            InstructionsDir = Join-Path $homeDir 'Library/Application Support/Code/User/instructions'
            PromptsDir      = Join-Path $homeDir 'Library/Application Support/Code/User/prompts'
            SkillsDir       = Join-Path $homeDir '.copilot/skills'
        }
    }
    else {
        # Linux
        return [ordered]@{
            AgentsDir       = Join-Path $homeDir '.config/Code/User/agents'
            InstructionsDir = Join-Path $homeDir '.config/Code/User/instructions'
            PromptsDir      = Join-Path $homeDir '.config/Code/User/prompts'
            SkillsDir       = Join-Path $homeDir '.copilot/skills'
        }
    }
}

$defaults = Get-DefaultPaths

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
# 2. Interactive path confirmation
# -----------------------------------------------------------------

Write-Host ''
Show-IforgeaiLogo
Write-Host '  iforgeAI Installer' -ForegroundColor Cyan
Write-Host '  ------------------------------------------------------' -ForegroundColor DarkGray
Write-Host '  The following directories will be used for installation.'
Write-Host '  Press Enter to accept each default, or type a new path to override.'
Write-Host ''

$paths = [ordered]@{}

$labels = [ordered]@{
    AgentsDir       = 'Copilot agents       '
    InstructionsDir = 'Copilot instructions '
    PromptsDir      = 'Copilot prompts      '
    SkillsDir       = 'Copilot skills       '
}

foreach ($key in $defaults.Keys) {
    $default = $defaults[$key]
    $label   = $labels[$key]

    Write-Host "  $label" -NoNewline -ForegroundColor Yellow
    Write-Host ": $default"
    $userInput = Read-Host "  Accept? [Enter] or type new path"
    $paths[$key] = if ($userInput.Trim() -eq '') { $default } else { $userInput.Trim() }
    Write-Host ''
}

# -----------------------------------------------------------------
# Language preference
# -----------------------------------------------------------------

Write-Host '  Output Language' -ForegroundColor Yellow
Write-Host '  Controls the default language of agent-generated deliverables (docs, requirements, architecture, etc.).'
Write-Host '  This can be changed at any time in your project''s  .ai/context/workflow-config.md'
Write-Host ''
Write-Host '    en-US   English (default)'
Write-Host '    zh-CN   Simplified Chinese  (or run  .\zh-CN\install.ps1  to install Chinese agents & skills)'
Write-Host ''
$langInput  = Read-Host '  Language code [Enter = en-US]'
$outputLang = if ([string]::IsNullOrWhiteSpace($langInput)) { 'en-US' } else { $langInput.Trim() }
Write-Host "  -> Output language: $outputLang" -ForegroundColor Green
Write-Host ''



Write-Host '  Installation summary:' -ForegroundColor Cyan
Write-Host '  ------------------------------------------------------' -ForegroundColor DarkGray
foreach ($key in $paths.Keys) {
    Write-Host "    $($labels[$key]): $($paths[$key])"
}
Write-Host "    Output language       : $outputLang"
Write-Host ''

if ($DryRun) {
    Write-Host '  [DRY RUN MODE] No files will be written.' -ForegroundColor Magenta
    Write-Host ''
}

if (-not $DryRun) {
    $confirm = Read-Host '  Proceed with installation? [Y/n]'
    if ($confirm -match '^[Nn]') {
        Write-Host '  Installation cancelled.' -ForegroundColor Yellow
        exit 0
    }
}

# -----------------------------------------------------------------
# 4. Helper functions
# -----------------------------------------------------------------

$installed = 0
$skipped   = 0

function Install-File {
    param(
        [string]$Source,
        [string]$Destination
    )

    $destDir = Split-Path $Destination -Parent

    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }

    if ((Test-Path $Destination) -and -not $Force) {
        Write-Host "    SKIP  $Destination" -ForegroundColor DarkGray
        $script:skipped++
        return
    }

    if ($DryRun) {
        Write-Host "    [DRY] $Source  ->  $Destination" -ForegroundColor Magenta
        return
    }

    Copy-Item -Path $Source -Destination $Destination -Force
    Write-Host "    OK    $Destination" -ForegroundColor Green
    $script:installed++
}

function Update-SkillsPathInFile {
    param([string]$FilePath)

    # Normalize to forward slashes -- works on all platforms and in #file: references
    $skillsPath = $paths['SkillsDir'].Replace('\', '/')

    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $updated = $content -replace '\{\{INSTALL_SKILLS_PATH\}\}', $skillsPath

    if ($updated -ne $content) {
        Set-Content -Path $FilePath -Value $updated -Encoding UTF8 -NoNewline
        Write-Host "    PATH  $FilePath" -ForegroundColor DarkYellow
    }
}

$repoRoot = $PSScriptRoot

# -----------------------------------------------------------------
# 5. Install Skills
# -----------------------------------------------------------------

if (-not $SkipSkills) {
    Write-Host ''
    Write-Host '  Installing skills...' -ForegroundColor Cyan

    $skillsSourceDir = Join-Path (Join-Path $repoRoot 'copilot') 'skills'
    $skillsTargetDir = $paths['SkillsDir']

    if (-not (Test-Path $skillsSourceDir)) {
        Write-Host "  WARNING: skills directory not found at $skillsSourceDir" -ForegroundColor Yellow
    }
    else {
        Get-ChildItem -Path $skillsSourceDir -Filter 'SKILL.md' -Recurse | ForEach-Object {
            $relativePath = $_.FullName.Substring($skillsSourceDir.Length).TrimStart('\', '/')
            $dest = Join-Path $skillsTargetDir $relativePath
            Install-File -Source $_.FullName -Destination $dest
        }
    }
}

# -----------------------------------------------------------------
# 6. Install Agents (with {{INSTALL_SKILLS_PATH}} substitution)
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  Installing agents...' -ForegroundColor Cyan

$agentsSourceDir = Join-Path (Join-Path $repoRoot 'copilot') 'agents'
$agentsTargetDir = $paths['AgentsDir']

Get-ChildItem -Path $agentsSourceDir -Filter '*.agent.md' | ForEach-Object {
    $dest = Join-Path $agentsTargetDir $_.Name
    Install-File -Source $_.FullName -Destination $dest

    if (-not $DryRun -and (Test-Path $dest)) {
        Update-SkillsPathInFile -FilePath $dest
    }
}

# -----------------------------------------------------------------
# 7. Install Instructions
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  Installing instructions...' -ForegroundColor Cyan

$instrSourceDir = Join-Path (Join-Path $repoRoot 'copilot') 'instructions'
$instrTargetDir = $paths['InstructionsDir']

Get-ChildItem -Path $instrSourceDir -Filter '*.instructions.md' | ForEach-Object {
    $dest = Join-Path $instrTargetDir $_.Name
    Install-File -Source $_.FullName -Destination $dest
}

# -----------------------------------------------------------------
# 8. Install Prompts
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  Installing prompts...' -ForegroundColor Cyan

$promptsSourceDir = Join-Path (Join-Path $repoRoot 'copilot') 'prompts'
$promptsTargetDir = $paths['PromptsDir']

Get-ChildItem -Path $promptsSourceDir -Filter '*.prompt.md' | ForEach-Object {
    $dest = Join-Path $promptsTargetDir $_.Name
    Install-File -Source $_.FullName -Destination $dest
}

# -----------------------------------------------------------------
# 9. Register plugin location in VS Code settings
#
#    VS Code discovers agents only from paths listed in
#    chat.pluginLocations. We add the User config dir so that
#    %APPDATA%\Code\User\agents\ (and instructions\, prompts\)
#    are visible to the Agent picker without any manual config.
# -----------------------------------------------------------------

function Get-VSCodeSettingsPath {
    if ($IsWindows) {
        $appData = if ($env:APPDATA) { $env:APPDATA } else { Join-Path $HOME 'AppData\Roaming' }
        return Join-Path $appData 'Code\User\settings.json'
    }
    elseif ($IsMacOS) {
        return Join-Path $HOME 'Library/Application Support/Code/User/settings.json'
    }
    else {
        return Join-Path $HOME '.config/Code/User/settings.json'
    }
}

function Get-VSCodeUserDir {
    if ($IsWindows) {
        $appData = if ($env:APPDATA) { $env:APPDATA } else { Join-Path $HOME 'AppData\Roaming' }
        return Join-Path $appData 'Code\User'
    }
    elseif ($IsMacOS) {
        return Join-Path $HOME 'Library/Application Support/Code/User'
    }
    else {
        return Join-Path $HOME '.config/Code/User'
    }
}

Write-Host ''
Write-Host '  Registering plugin location in VS Code settings...' -ForegroundColor Cyan

$settingsPath = Get-VSCodeSettingsPath
$userDir      = Get-VSCodeUserDir
$pluginKey    = $userDir.Replace('\', '\\')
$backupFile   = Join-Path $userDir '.iforgeai-settings-backup.json'

if ($DryRun) {
    Write-Host "    [DRY] Would register chat.pluginLocations in VS Code settings." -ForegroundColor Magenta
}
elseif (-not (Test-Path $settingsPath)) {
    Write-Host "    SKIP  settings.json not found at $settingsPath" -ForegroundColor Yellow
}
else {
    $raw = [System.IO.File]::ReadAllText($settingsPath, [System.Text.Encoding]::UTF8)

    if ($raw -match [regex]::Escape($pluginKey)) {
        Write-Host "    SKIP  chat.pluginLocations already contains the path." -ForegroundColor DarkGray
    }
    else {
        # Check whether chat.pluginLocations already exists (with other entries)
        $existingMatch = [regex]::Match($raw, '"chat\.pluginLocations"\s*:\s*\{[^}]*\}')

        if ($existingMatch.Success) {
            # Backup the original block so uninstall can restore it exactly
            $backup = [ordered]@{ existed = $true; originalBlock = $existingMatch.Value } | ConvertTo-Json -Compress
            [System.IO.File]::WriteAllText($backupFile, $backup, [System.Text.UTF8Encoding]::new($false))

            # Insert our path before the closing } of the existing block
            $originalBlock = $existingMatch.Value
            $lastBrace     = $originalBlock.LastIndexOf('}')
            $beforeBrace   = $originalBlock.Substring(0, $lastBrace).TrimEnd()
            if ($beforeBrace -notmatch ',\s*$') { $beforeBrace += ',' }
            $updatedBlock  = $beforeBrace + "`n    `"$pluginKey`": true`n  }"
            $raw = $raw.Replace($existingMatch.Value, $updatedBlock)

            Write-Host "    OK    Added path to existing chat.pluginLocations" -ForegroundColor Green
            Write-Host "    INFO  Backup saved to $(Split-Path $backupFile -Leaf)" -ForegroundColor DarkYellow
        }
        else {
            # chat.pluginLocations did not exist -- record that so uninstall removes it entirely
            $backup = [ordered]@{ existed = $false; originalBlock = $null } | ConvertTo-Json -Compress
            [System.IO.File]::WriteAllText($backupFile, $backup, [System.Text.UTF8Encoding]::new($false))

            # Append before the final closing brace
            $entry = ",`n  `"chat.pluginLocations`": {`n    `"$pluginKey`": true`n  }"
            $raw = $raw -replace '(\s*\}\s*)$', "$entry`n}"
            $raw = $raw -replace ',,', ','

            Write-Host "    OK    chat.pluginLocations -> $userDir" -ForegroundColor Green
            Write-Host "    INFO  Backup saved to $(Split-Path $backupFile -Leaf)" -ForegroundColor DarkYellow
        }

        [System.IO.File]::WriteAllText($settingsPath, $raw, [System.Text.UTF8Encoding]::new($false))
    }
}

# -----------------------------------------------------------------
# 10. Done
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  ------------------------------------------------------' -ForegroundColor DarkGray

if ($DryRun) {
    Write-Host '  [DRY RUN complete -- no files were written]' -ForegroundColor Magenta
}
else {
    Write-Host "  Installation complete.  $installed installed,  $skipped skipped." -ForegroundColor Green
    Write-Host ''
    Write-Host '  Next steps:' -ForegroundColor Cyan
    Write-Host '    1. Reload VS Code:  Ctrl+Shift+P  ->  Developer: Reload Window'
    Write-Host '    2. Open a project workspace'
    Write-Host '    3. Run /init-project in GitHub Copilot Chat to create the .ai/ structure'
    Write-Host "       In the generated .ai/context/workflow-config.md, set:  output_language: \"$outputLang\""
    Write-Host "       Run /init-project in Copilot Chat to configure db_approach and design_approach per project."
    Write-Host '    4. In Copilot Chat -> Agent mode -> select  digital-team  to start the workflow'
    if ($outputLang -eq 'zh-CN') {
        Write-Host ''
        Write-Host '  Tip: You selected zh-CN. For Chinese agent & skill files, run  .\zh-CN\install.ps1  instead.' -ForegroundColor Yellow
    }
    Write-Host ''
    Write-Host '  Tool permissions required:' -ForegroundColor Cyan
    Write-Host '    digital-team needs  Edit files  permission to write .ai/ artifacts directly.'
    Write-Host '    Without it, all documents will be printed to the Chat window (high context usage).'
    Write-Host ''
    Write-Host '    To grant permission:' -ForegroundColor Yellow
    Write-Host '      1. Open Copilot Chat panel in VS Code'
    Write-Host '      2. Click the Tools icon (left of the input box)'
    Write-Host '      3. Ensure "Edit files" is checked'
    Write-Host '      4. digital-team will auto-detect permission on each startup and guide you if missing'
}

Write-Host ''
