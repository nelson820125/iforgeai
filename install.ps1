#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Install iforgeAI AI development team to VS Code / GitHub Copilot and/or Trae IDE.

.DESCRIPTION
    Copies agents, skills, instructions, and prompts to your user-level
    configuration directory for GitHub Copilot (VS Code) and/or Trae IDE.

    Supports Windows, macOS, and Linux (requires PowerShell 7+ / pwsh).
    Agent files are updated with your actual skills directory path after copying.

    During the interactive session you will be asked which tool(s) to install:
      1. GitHub Copilot only  (default)
      2. Trae only
      3. Both

    For Trae, you will also be asked which edition:
      1. Trae CN  (default)
      2. Trae International

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

function Get-CopilotDefaultPaths {
    $homeDir = $HOME
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
        return [ordered]@{
            AgentsDir       = Join-Path $homeDir '.config/Code/User/agents'
            InstructionsDir = Join-Path $homeDir '.config/Code/User/instructions'
            PromptsDir      = Join-Path $homeDir '.config/Code/User/prompts'
            SkillsDir       = Join-Path $homeDir '.copilot/skills'
        }
    }
}

function Get-TraeDefaultPaths {
    param([string]$Edition)   # 'cn' or 'international'

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

$copilotDefaults = Get-CopilotDefaultPaths

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
# 2. Interactive setup
# -----------------------------------------------------------------

Write-Host ''
Show-IforgeaiLogo
Write-Host '  iforgeAI Installer' -ForegroundColor Cyan
Write-Host '  ------------------------------------------------------' -ForegroundColor DarkGray
Write-Host ''

# --- Language selection (determines source root) -----------------

Write-Host '  Step 1 of 3 · Language' -ForegroundColor Yellow
Write-Host ''
Write-Host '    1   English  (en-US)  [default]'
Write-Host '    2   Simplified Chinese  (zh-CN)'
Write-Host ''
$langChoice = Read-Host '  Select language [Enter = 1]'
if ($langChoice -eq '2') {
    $outputLang = 'zh-CN'
    $sourceRoot = Join-Path $PSScriptRoot 'zh-CN'
} else {
    $outputLang = 'en-US'
    $sourceRoot = $PSScriptRoot
}
Write-Host "  -> Language: $outputLang  |  Source: $sourceRoot" -ForegroundColor Green
Write-Host ''

# --- Tool selection ----------------------------------------------

Write-Host '  Step 2 of 3 · Tool(s) to install' -ForegroundColor Yellow
Write-Host ''
Write-Host '    1   GitHub Copilot (VS Code)  [default]'
Write-Host '    2   Trae'
Write-Host '    3   Both'
Write-Host ''
$toolChoice = Read-Host '  Select tool [Enter = 1]'
$installCopilot = $toolChoice -ne '2'
$installTrae    = $toolChoice -eq '2' -or $toolChoice -eq '3'
Write-Host "  -> Copilot: $installCopilot  |  Trae: $installTrae" -ForegroundColor Green
Write-Host ''

# --- Trae edition ------------------------------------------------

$traeEdition = 'cn'
if ($installTrae) {
    Write-Host '  Step 2b · Trae Edition' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '    1   Trae CN  (default)'
    Write-Host '    2   Trae International'
    Write-Host ''
    $editionChoice = Read-Host '  Select edition [Enter = 1]'
    $traeEdition   = if ($editionChoice -eq '2') { 'international' } else { 'cn' }
    $traeDefaults  = Get-TraeDefaultPaths -Edition $traeEdition
    Write-Host "  -> Trae edition: $traeEdition" -ForegroundColor Green
    Write-Host ''
}

# --- Path confirmation -------------------------------------------

Write-Host '  Step 3 of 3 · Confirm installation paths' -ForegroundColor Yellow
Write-Host '  Press Enter to accept each default, or type a new path to override.'
Write-Host ''

$copilotPaths = [ordered]@{}
$traePaths    = [ordered]@{}

if ($installCopilot) {
    Write-Host '  -- GitHub Copilot --' -ForegroundColor DarkGray
    $copilotLabels = [ordered]@{
        AgentsDir       = 'Copilot agents       '
        InstructionsDir = 'Copilot instructions '
        PromptsDir      = 'Copilot prompts      '
        SkillsDir       = 'Copilot skills       '
    }
    foreach ($key in $copilotDefaults.Keys) {
        $default = $copilotDefaults[$key]
        $label   = $copilotLabels[$key]
        Write-Host "  $label" -NoNewline -ForegroundColor Yellow
        Write-Host ": $default"
        $userInput = Read-Host "  Accept? [Enter] or type new path"
        $copilotPaths[$key] = if ($userInput.Trim() -eq '') { $default } else { $userInput.Trim() }
        Write-Host ''
    }
}

if ($installTrae) {
    Write-Host '  -- Trae --' -ForegroundColor DarkGray
    $traeLabels = [ordered]@{
        SkillsDir       = 'Trae skills          '
        InstructionsDir = 'Trae instructions    '
    }
    foreach ($key in $traeDefaults.Keys) {
        $default = $traeDefaults[$key]
        $label   = $traeLabels[$key]
        Write-Host "  $label" -NoNewline -ForegroundColor Yellow
        Write-Host ": $default"
        $userInput = Read-Host "  Accept? [Enter] or type new path"
        $traePaths[$key] = if ($userInput.Trim() -eq '') { $default } else { $userInput.Trim() }
        Write-Host ''
    }
}

# --- Summary -----------------------------------------------------

Write-Host '  Installation summary:' -ForegroundColor Cyan
Write-Host '  ------------------------------------------------------' -ForegroundColor DarkGray
Write-Host "    Language              : $outputLang"
if ($installCopilot) {
    foreach ($key in $copilotPaths.Keys) {
        Write-Host "    $($copilotLabels[$key]): $($copilotPaths[$key])"
    }
}
if ($installTrae) {
    foreach ($key in $traePaths.Keys) {
        Write-Host "    $($traeLabels[$key]): $($traePaths[$key])"
    }
}
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
    $skillsPath = $copilotPaths['SkillsDir'].Replace('\', '/')

    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $updated = $content -replace '\{\{INSTALL_SKILLS_PATH\}\}', $skillsPath

    if ($updated -ne $content) {
        Set-Content -Path $FilePath -Value $updated -Encoding UTF8 -NoNewline
        Write-Host "    PATH  $FilePath" -ForegroundColor DarkYellow
    }
}

$repoRoot = $PSScriptRoot

# -----------------------------------------------------------------
# 5. Install Copilot Skills
# -----------------------------------------------------------------

if ($installCopilot -and -not $SkipSkills) {
    Write-Host ''
    Write-Host '  [Copilot] Installing skills...' -ForegroundColor Cyan

    $skillsSourceDir = Join-Path (Join-Path $sourceRoot 'copilot') 'skills'
    $skillsTargetDir = $copilotPaths['SkillsDir']

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
# 6. Install Copilot Agents (with {{INSTALL_SKILLS_PATH}} substitution)
# -----------------------------------------------------------------

if ($installCopilot) {
    Write-Host ''
    Write-Host '  [Copilot] Installing agents...' -ForegroundColor Cyan

    $agentsSourceDir = Join-Path (Join-Path $sourceRoot 'copilot') 'agents'
    $agentsTargetDir = $copilotPaths['AgentsDir']

    Get-ChildItem -Path $agentsSourceDir -Filter '*.agent.md' | ForEach-Object {
        $dest = Join-Path $agentsTargetDir $_.Name
        Install-File -Source $_.FullName -Destination $dest

        if (-not $DryRun -and (Test-Path $dest)) {
            Update-SkillsPathInFile -FilePath $dest
        }
    }
}

# -----------------------------------------------------------------
# 7. Install Copilot Instructions
# -----------------------------------------------------------------

if ($installCopilot) {
    Write-Host ''
    Write-Host '  [Copilot] Installing instructions...' -ForegroundColor Cyan

    $instrSourceDir = Join-Path (Join-Path $sourceRoot 'copilot') 'instructions'
    $instrTargetDir = $copilotPaths['InstructionsDir']

    Get-ChildItem -Path $instrSourceDir -Filter '*.instructions.md' | ForEach-Object {
        $dest = Join-Path $instrTargetDir $_.Name
        Install-File -Source $_.FullName -Destination $dest
    }
}

# -----------------------------------------------------------------
# 8. Install Copilot Prompts
# -----------------------------------------------------------------

if ($installCopilot) {
    Write-Host ''
    Write-Host '  [Copilot] Installing prompts...' -ForegroundColor Cyan

    $promptsSourceDir = Join-Path (Join-Path $sourceRoot 'copilot') 'prompts'
    $promptsTargetDir = $copilotPaths['PromptsDir']

    Get-ChildItem -Path $promptsSourceDir -Filter '*.prompt.md' | ForEach-Object {
        $dest = Join-Path $promptsTargetDir $_.Name
        Install-File -Source $_.FullName -Destination $dest
    }
}

# -----------------------------------------------------------------
# 9. Install Trae Skills
# -----------------------------------------------------------------

if ($installTrae -and -not $SkipSkills) {
    Write-Host ''
    Write-Host '  [Trae] Installing skills...' -ForegroundColor Cyan

    # Base skills: from copilot/skills/ (same content, different destination)
    $traeSkillsSourceDir = Join-Path (Join-Path $sourceRoot 'copilot') 'skills'
    $traeSkillsTargetDir = $traePaths['SkillsDir']

    if (-not (Test-Path $traeSkillsSourceDir)) {
        Write-Host "  WARNING: skills source directory not found at $traeSkillsSourceDir" -ForegroundColor Yellow
    }
    else {
        Get-ChildItem -Path $traeSkillsSourceDir -Filter 'SKILL.md' -Recurse | ForEach-Object {
            $relativePath = $_.FullName.Substring($traeSkillsSourceDir.Length).TrimStart('\', '/')
            $dest = Join-Path $traeSkillsTargetDir $relativePath
            Install-File -Source $_.FullName -Destination $dest
        }
    }

    # Override digital-team with Trae-specific SKILL.md (contains /init-project)
    $traeDigitalTeamSource = Join-Path $repoRoot 'trae\skills\digital-team\SKILL.md'
    if ($outputLang -eq 'zh-CN') {
        $traeDigitalTeamSource = Join-Path $repoRoot 'zh-CN\trae\skills\digital-team\SKILL.md'
    }
    if (Test-Path $traeDigitalTeamSource) {
        $dest = Join-Path $traeSkillsTargetDir 'digital-team\SKILL.md'
        Install-File -Source $traeDigitalTeamSource -Destination $dest
        Write-Host "    NOTE  digital-team overridden with Trae-specific SKILL.md" -ForegroundColor DarkYellow
    }
    else {
        Write-Host "    WARN  Trae digital-team SKILL.md not found at $traeDigitalTeamSource" -ForegroundColor Yellow
    }
}

# -----------------------------------------------------------------
# 10. Install Trae Instructions
# -----------------------------------------------------------------

if ($installTrae) {
    Write-Host ''
    Write-Host '  [Trae] Installing instructions...' -ForegroundColor Cyan

    $traeInstrSourceDir = Join-Path (Join-Path $sourceRoot 'copilot') 'instructions'
    $traeInstrTargetDir = $traePaths['InstructionsDir']

    if (-not (Test-Path $traeInstrSourceDir)) {
        Write-Host "  WARNING: instructions source directory not found at $traeInstrSourceDir" -ForegroundColor Yellow
    }
    else {
        Get-ChildItem -Path $traeInstrSourceDir -Filter '*.instructions.md' | ForEach-Object {
            $dest = Join-Path $traeInstrTargetDir $_.Name
            Install-File -Source $_.FullName -Destination $dest
        }
    }
}

# -----------------------------------------------------------------
# 11. Register plugin location in VS Code settings (Copilot only)
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

if ($installCopilot) {
    Write-Host ''
    Write-Host '  [Copilot] Registering plugin location in VS Code settings...' -ForegroundColor Cyan

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
            $existingMatch = [regex]::Match($raw, '"chat\.pluginLocations"\s*:\s*\{[^}]*\}')

            if ($existingMatch.Success) {
                $backup = [ordered]@{ existed = $true; originalBlock = $existingMatch.Value } | ConvertTo-Json -Compress
                [System.IO.File]::WriteAllText($backupFile, $backup, [System.Text.UTF8Encoding]::new($false))

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
                $backup = [ordered]@{ existed = $false; originalBlock = $null } | ConvertTo-Json -Compress
                [System.IO.File]::WriteAllText($backupFile, $backup, [System.Text.UTF8Encoding]::new($false))

                $entry = ",`n  `"chat.pluginLocations`": {`n    `"$pluginKey`": true`n  }"
                $raw = $raw -replace '(\s*\}\s*)$', "$entry`n}"
                $raw = $raw -replace ',,', ','

                Write-Host "    OK    chat.pluginLocations -> $userDir" -ForegroundColor Green
                Write-Host "    INFO  Backup saved to $(Split-Path $backupFile -Leaf)" -ForegroundColor DarkYellow
            }

            [System.IO.File]::WriteAllText($settingsPath, $raw, [System.Text.UTF8Encoding]::new($false))
        }
    }
}

# -----------------------------------------------------------------
# 12. Done
# -----------------------------------------------------------------

Write-Host ''
Write-Host '  ------------------------------------------------------' -ForegroundColor DarkGray

if ($DryRun) {
    Write-Host '  [DRY RUN complete -- no files were written]' -ForegroundColor Magenta
}
else {
    Write-Host "  Installation complete.  $installed installed,  $skipped skipped." -ForegroundColor Green
    Write-Host ''
    if ($installCopilot) {
        Write-Host '  GitHub Copilot next steps:' -ForegroundColor Cyan
        Write-Host '    1. Reload VS Code:  Ctrl+Shift+P  ->  Developer: Reload Window'
        Write-Host '    2. Open a project workspace'
        Write-Host '    3. In Copilot Chat -> Agent mode -> select  digital-team'
        Write-Host '    4. Run /init-project to create the .ai/ structure'
        Write-Host "       Set  output_language: `"$outputLang`"  in the generated workflow-config.md"
        Write-Host ''
        Write-Host '  Tool permissions required:' -ForegroundColor Cyan
        Write-Host '    digital-team needs  Edit files  permission to write .ai/ artifacts directly.'
        Write-Host '    Without it, all documents will be printed to the Chat window (high context usage).'
        Write-Host ''
        Write-Host '    To grant permission:' -ForegroundColor Yellow
        Write-Host '      1. Open Copilot Chat panel in VS Code'
        Write-Host '      2. Click the Tools icon (left of the input box)'
        Write-Host '      3. Ensure "Edit files" is checked'
    }
    if ($installTrae) {
        Write-Host '  Trae next steps:' -ForegroundColor Cyan
        Write-Host '    1. Restart Trae IDE to load the installed skills'
        Write-Host '    2. Open a project workspace'
        Write-Host '    3. In Trae Chat, type  @digital-team  and use command  /init-project'
        Write-Host "       Set  output_language: `"$outputLang`"  when prompted"
    }
}

Write-Host ''
