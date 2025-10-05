#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Development Environment Setup Script v2.0

.DESCRIPTION
    This script sets up a complete development environment on Windows 10/11.
    It installs essential development tools, configures PowerShell, VS Code, Git, and more.

.PARAMETER Mode
    Installation mode: 'Full', 'Minimal', or 'Custom'. Default is 'Full'.

.PARAMETER SkipPackages
    Comma-separated list of package names to skip during installation.

.PARAMETER SkipExtensions
    Comma-separated list of VS Code extension names to skip during installation.

.PARAMETER Silent
    Run in silent mode with minimal user interaction. Default is $false.

.PARAMETER Force
    Force reinstall packages even if they're already installed. Default is $false.

.PARAMETER ConfigFile
    Path to custom configuration JSON file. Default uses built-in configuration.

.PARAMETER LogLevel
    Logging level: 'DEBUG', 'INFO', 'WARNING', 'ERROR'. Default is 'INFO'.

.EXAMPLE
    .\setup-v1.ps1
    Runs the complete development environment setup in full mode.

.EXAMPLE
    .\setup-v1.ps1 -Mode Minimal -Silent
    Runs minimal installation in silent mode.

.EXAMPLE
    .\setup-v1.ps1 -SkipPackages "Docker Desktop,Node.js" -SkipExtensions "GitLens,Prettier"
    Skips specific packages and extensions.

.EXAMPLE
    .\setup-v1.ps1 -ConfigFile "C:\MyConfig\custom-config.json" -LogLevel DEBUG
    Uses custom configuration file with debug logging.

.NOTES
    Author: Christopher Alphonse
    Last Updated: 2025-10-04
#>

param(
    [ValidateSet('Full', 'Minimal', 'Custom')]
    [string]$Mode = 'Full',
    
    [string]$SkipPackages = '',
    
    [string]$SkipExtensions = '',
    
    [switch]$Silent = $false,
    
    [switch]$Force = $false,
    
    [string]$ConfigFile = '',
    
    [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR')]
    [string]$LogLevel = 'INFO'
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

# ===============================
# Configuration Management
# ===============================

function Initialize-Configuration {
    # Parse command-line parameters
    $script:ScriptParams = @{
        Mode = $Mode
        SkipPackages = if ($SkipPackages) { $SkipPackages -split ',' | ForEach-Object { $_.Trim() } } else { @() }
        SkipExtensions = if ($SkipExtensions) { $SkipExtensions -split ',' | ForEach-Object { $_.Trim() } } else { @() }
        Silent = $Silent
        Force = $Force
        ConfigFile = $ConfigFile
        LogLevel = $LogLevel
    }
    
    # Load custom configuration if provided
    if ($script:ScriptParams.ConfigFile -and (Test-Path $script:ScriptParams.ConfigFile)) {
        try {
            $customConfig = Get-Content $script:ScriptParams.ConfigFile -Raw | ConvertFrom-Json
            Write-Host "✅ Loaded custom configuration from: $($script:ScriptParams.ConfigFile)" -ForegroundColor Green
            return $customConfig
        }
        catch {
            Write-Host "⚠️ Failed to load custom configuration: $_" -ForegroundColor Yellow
            Write-Host "Using default configuration instead." -ForegroundColor Yellow
        }
    }
    
    return $null
}

function Get-InstallationMode {
    param([string]$Mode)
    
    switch ($Mode) {
        'Minimal' {
            return @{
                Packages = @('Git', 'Visual Studio Code', 'PowerShell')
                Extensions = @('ms-vscode.powershell', 'ms-vscode.vscode-json')
                SkipDotfiles = $false
                SkipVSCodeExtensions = $false
            }
        }
        'Custom' {
            return @{
                Packages = $CONFIG.WingetPackages | Where-Object { $_.Name -notin $script:ScriptParams.SkipPackages }
                Extensions = $CONFIG.VSCodeExtensions | Where-Object { $_.Name -notin $script:ScriptParams.SkipExtensions }
                SkipDotfiles = $false
                SkipVSCodeExtensions = $false
            }
        }
        default { # 'Full'
            return @{
                Packages = $CONFIG.WingetPackages
                Extensions = $CONFIG.VSCodeExtensions
                SkipDotfiles = $false
                SkipVSCodeExtensions = $false
            }
        }
    }
}

$CONFIG = @{
    DotfilesRepo = "https://github.com/ChristopherAlphonse/dotfiles"
    Paths = @{
        Home = $env:USERPROFILE
        Documents = [Environment]::GetFolderPath("MyDocuments")
        LocalAppData = $env:LOCALAPPDATA
        PowerShellConfig = "$([Environment]::GetFolderPath('MyDocuments'))\PowerShell"
        VSCodeSettings = "$env:APPDATA\Code\User"
        LogDirectory = "$env:TEMP\dev-setup-logs"
    }

    PackageManagement = @{
        UseLatestVersions = $true
        UpdateCheck = $true
        ForceReinstall = $Force
        SkipIfInstalled = -not $Force
    }

    WingetPackages = @(
        @{
            Id = "Git.Git";
            Name = "Git";
            RequiresRestart = $false;
            Version = "latest";
            Description = "Distributed version control system"
            Category = "Development Tools"
        },
        @{
            Id = "Microsoft.WindowsTerminal";
            Name = "Windows Terminal";
            RequiresRestart = $false;
            Version = "latest";
            Description = "Modern terminal application for Windows"
            Category = "Terminal"
        },
        @{
            Id = "Microsoft.VisualStudioCode";
            Name = "VS Code";
            RequiresRestart = $false;
            Version = "latest";
            Description = "Source code editor with built-in Git support"
            Category = "Development Tools"
        },
        @{
            Id = "Python.Python.3.11";
            Name = "Python 3.11";
            RequiresRestart = $false;
            Version = "3.3";
            Description = "Python programming language"
            Category = "Programming Languages"
        },
        @{
            Id = "Docker.DockerDesktop";
            Name = "Docker Desktop";
            RequiresRestart = $true;
            Version = "latest";
            Description = "Containerization platform"
            Category = "Development Tools"
        },
        @{
            Id = "SlackTechnologies.Slack";
            Name = "Slack";
            RequiresRestart = $false;
            Version = "latest";
            Description = "Team communication platform"
            Category = "Communication"
        },
        @{
            Id = "JanDeDobbeleer.OhMyPosh";
            Name = "Oh My Posh";
            RequiresRestart = $false;
            Version = "latest";
            Description = "Prompt theme engine for PowerShell"
            Category = "Terminal"
        },
        @{
            Id = "Microsoft.PowerToys";
            Name = "PowerToys (Preview)";
            RequiresRestart = $false;
            Version = "latest";
            Description = "Windows system utilities for power users"
            Category = "System Tools"
        }
    )
    RestartRequiredApps = @()
    LogFile = ""
    MaxLogSize = 10MB
    MaxLogFiles = 5
    StateFile = ""
    BackupDirectory = ""
    VSCodeExtensions = @(
        @{ Id = "eamodio.gitlens"; Name = "GitLens" },
        @{ Id = "esbenp.prettier-vscode"; Name = "Prettier" },
        @{ Id = "ms-vscode.powershell"; Name = "PowerShell" },
        @{ Id = "ms-vscode.vscode-json"; Name = "JSON" },
        @{ Id = "ms-vscode.vscode-typescript-next"; Name = "TypeScript" },
        @{ Id = "ms-vscode.vscode-eslint"; Name = "ESLint" },
        @{ Id = "ms-vscode.remote-containers"; Name = "Dev Containers" },
        @{ Id = "ms-vscode.remote-wsl"; Name = "WSL" },
        @{ Id = "ms-vscode.vscode-github-actions"; Name = "GitHub Actions" },
        @{ Id = "ms-vscode.vscode-markdown"; Name = "Markdown" }
    )
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n" -NoNewline
    Write-Host "🔧 " -NoNewline -ForegroundColor Cyan
    Write-Host "$Message" -ForegroundColor White
    Write-Host "─" * 50 -ForegroundColor DarkCyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "$Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "$Message" -ForegroundColor Red
}

# ===============================
# Logging System Functions
# ===============================

function Initialize-Logging {
    Write-Host "Initializing logging system..." -ForegroundColor Cyan

    if (-not (Test-Path $CONFIG.Paths.LogDirectory)) {
        New-Item -ItemType Directory -Path $CONFIG.Paths.LogDirectory -Force | Out-Null
    }


    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $CONFIG.LogFile = Join-Path $CONFIG.Paths.LogDirectory "dev-setup-$timestamp.log"


    Remove-OldLogs


    Write-Log "INFO" "Development Environment Setup Started"
    Write-Log "INFO" "Script Version: 2.0"
    Write-Log "INFO" "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Log "INFO" "Windows Version: $([System.Environment]::OSVersion.VersionString)"
    Write-Log "INFO" "User: $([System.Environment]::UserName)"
    Write-Log "INFO" "Computer: $([System.Environment]::MachineName)"
    Write-Log "INFO" "Log File: $($CONFIG.LogFile)"
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("INFO", "WARNING", "ERROR", "DEBUG")]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [string]$Details = ""
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"

    if ($Details) {
        $logEntry += " | Details: $Details"
    }


    try {
        Add-Content -Path $CONFIG.LogFile -Value $logEntry -ErrorAction SilentlyContinue
    }
    catch {

        Write-Host " Failed to write to log: $_" -ForegroundColor Yellow
    }


    if ($Level -eq "DEBUG") {
        Write-Host "DEBUG: $Message" -ForegroundColor DarkGray
    }
}

function Remove-OldLogs {
    try {
        $logFiles = Get-ChildItem -Path $CONFIG.Paths.LogDirectory -Filter "dev-setup-*.log" | Sort-Object LastWriteTime -Descending

        if ($logFiles.Count -gt $CONFIG.MaxLogFiles) {
            $filesToDelete = $logFiles | Select-Object -Skip $CONFIG.MaxLogFiles
            foreach ($file in $filesToDelete) {
                Remove-Item $file.FullName -Force
                Write-Log "INFO" "Removed old log file: $($file.Name)"
            }
        }
    }
    catch {
        Write-Log "WARNING" "Failed to clean up old logs: $_"
    }
}

function Test-LogSize {
    try {
        if (Test-Path $CONFIG.LogFile) {
            $logSize = (Get-Item $CONFIG.LogFile).Length
            if ($logSize -gt $CONFIG.MaxLogSize) {
                Write-Log "INFO" "Log file size exceeded limit, archiving..."
                $archiveName = $CONFIG.LogFile -replace '\.log$', "-archive-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
                Move-Item $CONFIG.LogFile $archiveName
                Write-Log "INFO" "Log archived to: $archiveName"
            }
        }
    }
    catch {
        Write-Log "WARNING" "Failed to check log size: $_"
    }
}

# ===============================
# Rollback System Functions
# ===============================

function Initialize-RollbackSystem {
    Write-Log "INFO" "Initializing rollback system"


    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $CONFIG.BackupDirectory = Join-Path $env:TEMP "dev-setup-backup-$timestamp"
    $CONFIG.StateFile = Join-Path $CONFIG.BackupDirectory "installation-state.json"


    if (-not (Test-Path $CONFIG.BackupDirectory)) {
        New-Item -ItemType Directory -Path $CONFIG.BackupDirectory -Force | Out-Null
        Write-Log "DEBUG" "Created backup directory: $($CONFIG.BackupDirectory)"
    }


    $initialState = @{
        StartTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        InstalledPackages = @()
        CopiedFiles = @()
        CreatedDirectories = @()
        Status = "InProgress"
    }

    $initialState | ConvertTo-Json -Depth 3 | Out-File -FilePath $CONFIG.StateFile -Encoding UTF8
    Write-Log "INFO" "Rollback system initialized"
}

function Backup-ExistingConfigs {
    Write-Log "INFO" "Backing up existing configuration files"

    $backupResults = @{
        PowerShellProfile = $false
        PowerShellConfig = $false
        TerminalSettings = $false
        VSCodeSettings = $false
        GitConfig = $false
    }

    try {

        $profilePath = "$($CONFIG.Paths.PowerShellConfig)/Microsoft.PowerShell_profile.ps1"
        if (Test-Path $profilePath) {
            $backupPath = Join-Path $CONFIG.BackupDirectory "Microsoft.PowerShell_profile.ps1.backup"
            Copy-Item $profilePath $backupPath -Force
            $backupResults.PowerShellProfile = $true
            Write-Log "DEBUG" "Backed up PowerShell profile"
        }


        $configPath = "$($CONFIG.Paths.PowerShellConfig)/powershell.config.json"
        if (Test-Path $configPath) {
            $backupPath = Join-Path $CONFIG.BackupDirectory "powershell.config.json.backup"
            Copy-Item $configPath $backupPath -Force
            $backupResults.PowerShellConfig = $true
            Write-Log "DEBUG" "Backed up PowerShell config"
        }


        $terminalPath = "$($CONFIG.Paths.LocalAppData)\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        if (Test-Path $terminalPath) {
            $backupPath = Join-Path $CONFIG.BackupDirectory "terminal-settings.json.backup"
            Copy-Item $terminalPath $backupPath -Force
            $backupResults.TerminalSettings = $true
            Write-Log "DEBUG" "Backed up Terminal settings"
        }


        $vscodePath = "$($CONFIG.Paths.VSCodeSettings)/custom-vscode.css"
        if (Test-Path $vscodePath) {
            $backupPath = Join-Path $CONFIG.BackupDirectory "custom-vscode.css.backup"
            Copy-Item $vscodePath $backupPath -Force
            $backupResults.VSCodeSettings = $true
            Write-Log "DEBUG" "Backed up VS Code settings"
        }


        $gitPath = "$($CONFIG.Paths.Home)/.gitconfig"
        if (Test-Path $gitPath) {
            $backupPath = Join-Path $CONFIG.BackupDirectory ".gitconfig.backup"
            Copy-Item $gitPath $backupPath -Force
            $backupResults.GitConfig = $true
            Write-Log "DEBUG" "Backed up Git config"
        }

        Write-Log "INFO" "Configuration backup completed"
        return $backupResults
    }
    catch {
        Write-Log "ERROR" "Failed to backup existing configs" "Exception: $($_.Exception.Message)"
        return $backupResults
    }
}

function Update-InstallationState {
    param(
        [string]$Operation,
        [hashtable]$Data
    )

    try {
        if (Test-Path $CONFIG.StateFile) {
            $state = Get-Content $CONFIG.StateFile -Raw | ConvertFrom-Json

            switch ($Operation) {
                "PackageInstalled" {
                    $state.InstalledPackages += $Data
                    Write-Log "DEBUG" "Updated state: Package installed - $($Data.Name)"
                }
                "FileCopied" {
                    $state.CopiedFiles += $Data
                    Write-Log "DEBUG" "Updated state: File copied - $($Data.Destination)"
                }
                "DirectoryCreated" {
                    $state.CreatedDirectories += $Data
                    Write-Log "DEBUG" "Updated state: Directory created - $($Data.Path)"
                }
                "StatusComplete" {
                    $state.Status = "Complete"
                    $state.EndTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    Write-Log "INFO" "Updated state: Installation completed"
                }
                "StatusFailed" {
                    $state.Status = "Failed"
                    $state.EndTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $state.ErrorMessage = $Data.ErrorMessage
                    Write-Log "INFO" "Updated state: Installation failed"
                }
            }

            $state | ConvertTo-Json -Depth 3 | Out-File -FilePath $CONFIG.StateFile -Encoding UTF8
        }
    }
    catch {
        Write-Log "WARNING" "Failed to update installation state: $_"
    }
}

function Invoke-Rollback {
    Write-Host "`n🔄 Starting rollback process..." -ForegroundColor Yellow
    Write-Log "INFO" "Starting rollback process"

    try {
        if (-not (Test-Path $CONFIG.StateFile)) {
            Write-Host "❌ No installation state found. Cannot perform rollback." -ForegroundColor Red
            Write-Log "ERROR" "No installation state found for rollback"
            return $false
        }

        $state = Get-Content $CONFIG.StateFile -Raw | ConvertFrom-Json
        Write-Log "INFO" "Loaded installation state with $($state.InstalledPackages.Count) packages and $($state.CopiedFiles.Count) files"

        # Uninstall packages
        if ($state.InstalledPackages.Count -gt 0) {
            Write-Host "📦 Uninstalling packages..." -ForegroundColor Cyan
            foreach ($package in $state.InstalledPackages) {
                try {
                    Write-Host "  Removing $($package.Name)..." -ForegroundColor Yellow
                    $result = Start-Process -FilePath "winget" -ArgumentList "uninstall --id $($package.Id) --silent" -Wait -PassThru -NoNewWindow
                    if ($result.ExitCode -eq 0) {
                        Write-Host "  ✅ Removed $($package.Name)" -ForegroundColor Green
                        Write-Log "INFO" "Successfully uninstalled: $($package.Name)"
                    } else {
                        Write-Host "  ⚠️ Failed to remove $($package.Name)" -ForegroundColor Yellow
                        Write-Log "WARNING" "Failed to uninstall: $($package.Name)"
                    }
                }
                catch {
                    Write-Host "  ❌ Error removing $($package.Name): $_" -ForegroundColor Red
                    Write-Log "ERROR" "Error uninstalling $($package.Name): $_"
                }
            }
        }

        # Restore backed-up files
        if ($state.CopiedFiles.Count -gt 0) {
            Write-Host "📁 Restoring configuration files..." -ForegroundColor Cyan
            foreach ($file in $state.CopiedFiles) {
                try {
                    $backupPath = Join-Path $CONFIG.BackupDirectory "$(Split-Path -Leaf $file.Destination).backup"
                    if (Test-Path $backupPath) {
                        Copy-Item $backupPath $file.Destination -Force
                        Write-Host "  ✅ Restored $($file.Destination)" -ForegroundColor Green
                        Write-Log "INFO" "Restored file: $($file.Destination)"
                    } else {
                        # If no backup, remove the file
                        if (Test-Path $file.Destination) {
                            Remove-Item $file.Destination -Force
                            Write-Host "  🗑️ Removed $($file.Destination)" -ForegroundColor Yellow
                            Write-Log "INFO" "Removed file (no backup): $($file.Destination)"
                        }
                    }
                }
                catch {
                    Write-Host "  ❌ Error restoring $($file.Destination): $_" -ForegroundColor Red
                    Write-Log "ERROR" "Error restoring $($file.Destination): $_"
                }
            }
        }

        # Remove created directories
        if ($state.CreatedDirectories.Count -gt 0) {
            Write-Host "📂 Cleaning up created directories..." -ForegroundColor Cyan
            foreach ($dir in $state.CreatedDirectories) {
                try {
                    if (Test-Path $dir.Path) {
                        Remove-Item $dir.Path -Recurse -Force
                        Write-Host "  🗑️ Removed $($dir.Path)" -ForegroundColor Yellow
                        Write-Log "INFO" "Removed directory: $($dir.Path)"
                    }
                }
                catch {
                    Write-Host "  ❌ Error removing $($dir.Path): $_" -ForegroundColor Red
                    Write-Log "ERROR" "Error removing directory $($dir.Path): $_"
                }
            }
        }

        Write-Host "`n✅ Rollback completed!" -ForegroundColor Green
        Write-Log "INFO" "Rollback process completed successfully"
        return $true
    }
    catch {
        Write-Host "`n❌ Rollback failed: $_" -ForegroundColor Red
        Write-Log "ERROR" "Rollback process failed" "Exception: $($_.Exception.Message)"
        return $false
    }
}

function Show-RollbackPrompt {
    Write-Host "`n" -NoNewline
    Write-Host "═" * 60 -ForegroundColor Red
    Write-Host " Installation Failed" -ForegroundColor Red
    Write-Host "═" * 60 -ForegroundColor Red
    Write-Host "`nWould you like to rollback all changes? (Y/N): " -NoNewline -ForegroundColor Yellow

    $response = Read-Host
    if ($response -eq 'Y' -or $response -eq 'y') {
        Write-Log "INFO" "User chose to rollback changes"
        return Invoke-Rollback
    } else {
        Write-Log "INFO" "User chose not to rollback changes"
        Write-Host "`n⚠️ Changes will remain on your system." -ForegroundColor Yellow
        Write-Host "You can manually rollback using the state file: $($CONFIG.StateFile)" -ForegroundColor Cyan
        return $false
    }
}

# ===============================
# VS Code Extension Functions
# ===============================

function Test-VSCodeInstalled {
    try {
        $codeVersion = & code --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "DEBUG" "VS Code is installed: $($codeVersion[0])"
            return $true
        }
    }
    catch {
        Write-Log "DEBUG" "VS Code not found in PATH"
    }
    return $false
}

function Install-VSCodeExtensions {
    Write-Host "`n📦 Installing VS Code extensions..." -ForegroundColor Cyan
    Write-Log "INFO" "Starting VS Code extension installation"

    if (-not (Test-VSCodeInstalled)) {
        Write-Host "⚠️ VS Code is not installed or not in PATH. Skipping extension installation." -ForegroundColor Yellow
        Write-Log "WARNING" "VS Code not found, skipping extension installation"
        return $false
    }

    $installedExtensions = @()
    $failedExtensions = @()

    Write-Host "Installing $($CONFIG.VSCodeExtensions.Count) extensions..." -ForegroundColor White

    foreach ($extension in $CONFIG.VSCodeExtensions) {
        try {
            Write-Host "  Installing $($extension.Name)..." -ForegroundColor Yellow
            Write-Log "DEBUG" "Installing VS Code extension: $($extension.Name) ($($extension.Id))"

            $result = Start-Process -FilePath "code" -ArgumentList "--install-extension", $extension.Id, "--force" -Wait -PassThru -NoNewWindow

            if ($result.ExitCode -eq 0) {
                Write-Host "  ✅ Installed $($extension.Name)" -ForegroundColor Green
                $installedExtensions += $extension
                Write-Log "INFO" "Successfully installed VS Code extension: $($extension.Name)"

                # Update installation state
                Update-InstallationState -Operation "FileCopied" -Data @{
                    Source = "VS Code Marketplace"
                    Destination = "VS Code Extension: $($extension.Name)"
                    Description = "VS Code Extension: $($extension.Name)"
                    CopyTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
            } else {
                Write-Host "  ❌ Failed to install $($extension.Name)" -ForegroundColor Red
                $failedExtensions += $extension
                Write-Log "WARNING" "Failed to install VS Code extension: $($extension.Name)"
            }
        }
        catch {
            Write-Host "  ❌ Error installing $($extension.Name): $_" -ForegroundColor Red
            $failedExtensions += $extension
            Write-Log "ERROR" "Error installing VS Code extension $($extension.Name): $_"
        }
    }

    # Summary
    Write-Host "`n📊 VS Code Extensions Summary:" -ForegroundColor Cyan
    Write-Host "  ✅ Installed: $($installedExtensions.Count)/$($CONFIG.VSCodeExtensions.Count)" -ForegroundColor Green

    if ($failedExtensions.Count -gt 0) {
        Write-Host "  ❌ Failed:" -ForegroundColor Red
        $failedExtensions | ForEach-Object { Write-Host "    - $($_.Name)" -ForegroundColor Yellow }
        Write-Log "WARNING" "Failed to install $($failedExtensions.Count) VS Code extensions"
    }

    Write-Log "INFO" "VS Code extension installation completed: $($installedExtensions.Count)/$($CONFIG.VSCodeExtensions.Count) successful"
    return $installedExtensions.Count -gt 0
}

function Test-VSCodeExtensions {
    Write-Host "`n🔍 Verifying VS Code extensions..." -ForegroundColor Cyan
    Write-Log "INFO" "Verifying installed VS Code extensions"

    if (-not (Test-VSCodeInstalled)) {
        Write-Host "⚠️ VS Code is not available for verification." -ForegroundColor Yellow
        return $false
    }

    try {
        $installedExtensions = & code --list-extensions 2>$null
        $verifiedCount = 0

        foreach ($extension in $CONFIG.VSCodeExtensions) {
            if ($installedExtensions -contains $extension.Id) {
                Write-Host "  ✅ $($extension.Name)" -ForegroundColor Green
                $verifiedCount++
            } else {
                Write-Host "  ❌ $($extension.Name)" -ForegroundColor Red
            }
        }

        Write-Host "`n📊 Verification: $verifiedCount/$($CONFIG.VSCodeExtensions.Count) extensions confirmed" -ForegroundColor Cyan
        Write-Log "INFO" "VS Code extension verification: $verifiedCount/$($CONFIG.VSCodeExtensions.Count) confirmed"

        return $verifiedCount -eq $CONFIG.VSCodeExtensions.Count
    }
    catch {
        Write-Host "❌ Error verifying extensions: $_" -ForegroundColor Red
        Write-Log "ERROR" "Error verifying VS Code extensions: $_"
        return $false
    }
}

# ===============================
# Package Management Functions
# ===============================

function Test-PackageInstalled {
    param(
        [hashtable]$Package
    )

    try {
        $result = winget list --id $Package.Id --exact 2>$null
        if ($LASTEXITCODE -eq 0 -and $result -match $Package.Id) {
            Write-Log "DEBUG" "Package already installed: $($Package.Name)"
            return $true
        }
    }
    catch {
        Write-Log "DEBUG" "Error checking if package is installed: $($Package.Name)"
    }
    return $false
}

function Get-PackageVersion {
    param(
        [hashtable]$Package
    )

    try {
        $result = winget list --id $Package.Id --exact 2>$null
        if ($LASTEXITCODE -eq 0 -and $result -match $Package.Id) {
            # Extract version from winget output
            $versionMatch = $result | Select-String -Pattern "(\d+\.\d+\.\d+)" | Select-Object -First 1
            if ($versionMatch) {
                return $versionMatch.Matches[0].Value
            }
        }
    }
    catch {
        Write-Log "DEBUG" "Error getting package version: $($Package.Name)"
    }
    return "Unknown"
}

function Test-PackageUpdateAvailable {
    param(
        [hashtable]$Package
    )

    if (-not $CONFIG.PackageManagement.UpdateCheck) {
        return $false
    }

    try {
        $result = winget upgrade --id $Package.Id --exact --include-unknown 2>$null
        if ($LASTEXITCODE -eq 0 -and $result -match $Package.Id) {
            Write-Log "DEBUG" "Update available for: $($Package.Name)"
            return $true
        }
    }
    catch {
        Write-Log "DEBUG" "Error checking for updates: $($Package.Name)"
    }
    return $false
}

function Get-WingetInstallArguments {
    param(
        [hashtable]$Package
    )

    $arguments = @("install", "--id", $Package.Id, "--exact")

    # Add version if specified and not "latest"
    if ($Package.Version -and $Package.Version -ne "latest") {
        $arguments += "--version", $Package.Version
    }

    # Add source agreements
    $arguments += "--accept-package-agreements", "--accept-source-agreements"

    # Add silent flag
    $arguments += "--silent"

    # Add force reinstall if configured
    if ($CONFIG.PackageManagement.ForceReinstall) {
        $arguments += "--force"
    }

    return $arguments
}

function Install-SinglePackage {
    param(
        [hashtable]$Package
    )

    Write-Log "DEBUG" "Installing package: $($Package.Name) ($($Package.Id))"

    # Check if package is already installed
    if ($CONFIG.PackageManagement.SkipIfInstalled -and (Test-PackageInstalled -Package $Package)) {
        $currentVersion = Get-PackageVersion -Package $Package
        Write-Host "  ⏭️ Skipping $($Package.Name) (already installed: v$currentVersion)" -ForegroundColor Yellow
        Write-Log "INFO" "Skipped installation: $($Package.Name) (already installed: v$currentVersion)"

        # Check for updates
        if (Test-PackageUpdateAvailable -Package $Package) {
            Write-Host "  🔄 Update available for $($Package.Name)" -ForegroundColor Cyan
            Write-Log "INFO" "Update available for: $($Package.Name)"
        }

        return @{ Success = $true; Package = $Package; Skipped = $true; Version = $currentVersion }
    }

    # Check for updates if package is installed
    if ((Test-PackageInstalled -Package $Package) -and (Test-PackageUpdateAvailable -Package $Package)) {
        Write-Host "  🔄 Updating $($Package.Name)..." -ForegroundColor Cyan
        Write-Log "INFO" "Updating package: $($Package.Name)"
    } else {
        Write-Host "  📦 Installing $($Package.Name)..." -ForegroundColor Yellow
        Write-Log "INFO" "Installing package: $($Package.Name)"
    }

    try {
        $arguments = Get-WingetInstallArguments -Package $Package
        $result = Start-Process -FilePath "winget" -ArgumentList $arguments -Wait -PassThru -NoNewWindow

        if ($result.ExitCode -eq 0) {
            $installedVersion = Get-PackageVersion -Package $Package
            Write-Host "  ✅ Installed $($Package.Name) v$installedVersion" -ForegroundColor Green
            Write-Log "INFO" "Successfully installed: $($Package.Name) v$installedVersion"

            return @{
                Success = $true;
                Package = $Package;
                Version = $installedVersion;
                ExitCode = $result.ExitCode
            }
        } else {
            Write-Host "  ❌ Failed to install $($Package.Name) (Exit code: $($result.ExitCode))" -ForegroundColor Red
            Write-Log "ERROR" "Failed to install: $($Package.Name) (Exit code: $($result.ExitCode))"

            return @{
                Success = $false;
                Package = $Package;
                Error = "Exit code: $($result.ExitCode)";
                ExitCode = $result.ExitCode
            }
        }
    }
    catch {
        Write-Host "  ❌ Error installing $($Package.Name): $_" -ForegroundColor Red
        Write-Log "ERROR" "Error installing $($Package.Name): $_"

        return @{
            Success = $false;
            Package = $Package;
            Error = $_.Exception.Message
        }
    }
}

function Test-PackageFunctionality {
    param(
        [hashtable]$Package
    )

    Write-Log "DEBUG" "Testing functionality for: $($Package.Name)"

    # Define test commands for different packages
    $testCommands = @{
        "Git.Git" = @{ Command = "git --version"; ExpectedPattern = "git version" }
        "Microsoft.WindowsTerminal" = @{ Command = "wt --version"; ExpectedPattern = "Windows Terminal" }
        "Microsoft.VisualStudioCode" = @{ Command = "code --version"; ExpectedPattern = "\d+\.\d+\.\d+" }
        "Python.Python.3.11" = @{ Command = "python --version"; ExpectedPattern = "Python 3\.11" }
        "Docker.DockerDesktop" = @{ Command = "docker --version"; ExpectedPattern = "Docker version" }
        "SlackTechnologies.Slack" = @{ Command = "slack --version"; ExpectedPattern = "Slack" }
        "JanDeDobbeleer.OhMyPosh" = @{ Command = "oh-my-posh --version"; ExpectedPattern = "v\d+\.\d+\.\d+" }
        "Microsoft.PowerToys" = @{ Command = "powertoys --version"; ExpectedPattern = "PowerToys" }
    }

    $testConfig = $testCommands[$Package.Id]
    if (-not $testConfig) {
        Write-Log "DEBUG" "No test configuration for: $($Package.Name)"
        return @{ Success = $true; Message = "No test available" }
    }

    try {
        $output = Invoke-Expression $testConfig.Command 2>$null
        if ($output -and $output -match $testConfig.ExpectedPattern) {
            Write-Log "INFO" "Package functionality verified: $($Package.Name)"
            return @{ Success = $true; Message = "Functionality verified"; Output = $output }
        } else {
            Write-Log "WARNING" "Package functionality test failed: $($Package.Name)"
            return @{ Success = $false; Message = "Test failed"; Output = $output }
        }
    }
    catch {
        Write-Log "WARNING" "Package functionality test error: $($Package.Name) - $_"
        return @{ Success = $false; Message = "Test error: $_"; Output = $null }
    }
}

function Verify-InstalledPackages {
    Write-Host "`n🔍 Verifying installed packages..." -ForegroundColor Cyan
    Write-Log "INFO" "Starting package verification process"

    $verificationResults = @()
    $verifiedCount = 0

    foreach ($package in $CONFIG.WingetPackages) {
        Write-Host "  Testing $($package.Name)..." -ForegroundColor Yellow
        $result = Test-PackageFunctionality -Package $package

        if ($result.Success) {
            Write-Host "    ✅ $($package.Name) - $($result.Message)" -ForegroundColor Green
            $verifiedCount++
        } else {
            Write-Host "    ⚠️ $($package.Name) - $($result.Message)" -ForegroundColor Yellow
        }

        $verificationResults += @{
            Package = $package
            Success = $result.Success
            Message = $result.Message
            Output = $result.Output
        }
    }

    Write-Host "`n📊 Verification Results: $verifiedCount/$($CONFIG.WingetPackages.Count) packages verified" -ForegroundColor Cyan
    Write-Log "INFO" "Package verification completed: $verifiedCount/$($CONFIG.WingetPackages.Count) verified"

    return $verificationResults
}

function Show-PackageSummary {
    param(
        [array]$Results
    )

    Write-Host "`n" -NoNewline
    Write-Host "═" * 70 -ForegroundColor Cyan
    Write-Host " Package Installation Summary" -ForegroundColor Green
    Write-Host "═" * 70 -ForegroundColor Cyan

    $successful = $Results | Where-Object { $_.Success -eq $true }
    $failed = $Results | Where-Object { $_.Success -eq $false }
    $skipped = $Results | Where-Object { $_.Skipped -eq $true }

    Write-Host "`n📊 Installation Results:" -ForegroundColor White
    Write-Host "  ✅ Successful: $($successful.Count)" -ForegroundColor Green
    Write-Host "  ⏭️ Skipped: $($skipped.Count)" -ForegroundColor Yellow
    Write-Host "  ❌ Failed: $($failed.Count)" -ForegroundColor Red

    if ($successful.Count -gt 0) {
        Write-Host "`n📦 Successfully Installed:" -ForegroundColor Green
        foreach ($result in $successful) {
            $versionInfo = if ($result.Version) { " v$($result.Version)" } else { "" }
            Write-Host "  • $($result.Package.Name)$versionInfo" -ForegroundColor White
        }
    }

    if ($skipped.Count -gt 0) {
        Write-Host "`n⏭️ Skipped (Already Installed):" -ForegroundColor Yellow
        foreach ($result in $skipped) {
            $versionInfo = if ($result.Version) { " v$($result.Version)" } else { "" }
            Write-Host "  • $($result.Package.Name)$versionInfo" -ForegroundColor White
        }
    }

    if ($failed.Count -gt 0) {
        Write-Host "`n❌ Failed Installations:" -ForegroundColor Red
        foreach ($result in $failed) {
            Write-Host "  • $($result.Package.Name)" -ForegroundColor White
            if ($result.Error) {
                Write-Host "    Error: $($result.Error)" -ForegroundColor DarkRed
            }
        }
    }

    Write-Log "INFO" "Package installation summary: $($successful.Count) successful, $($skipped.Count) skipped, $($failed.Count) failed"
}

function Test-Command {
    param([string]$Command)
    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# ===============================
# Pre-flight Check Functions
# ===============================

function Test-SystemRequirements {
    Write-Host "`n🔍 Checking system requirements..." -ForegroundColor Cyan
    Write-Log "INFO" "Starting system requirements check"

    $results = @()

    # Check Windows Version
    $osVersion = [System.Environment]::OSVersion.Version
    $isWindows10Plus = ($osVersion.Major -ge 10)
    $results += @{
        Check = "Windows 10/11"
        Status = if ($isWindows10Plus) { "PASS" } else { "FAIL" }
        Details = "Detected: $([System.Environment]::OSVersion.VersionString)"
        Critical = $true
    }
    Write-Log "INFO" "Windows Version Check: $(if ($isWindows10Plus) { 'PASS' } else { 'FAIL' }) - $([System.Environment]::OSVersion.VersionString)"

    # Check PowerShell Version
    $psVersion = $PSVersionTable.PSVersion
    $isPowerShell5Plus = ($psVersion.Major -ge 5)
    $results += @{
        Check = "PowerShell 5.1+"
        Status = if ($isPowerShell5Plus) { "PASS" } else { "FAIL" }
        Details = "Version: $($psVersion.ToString())"
        Critical = $true
    }
    Write-Log "INFO" "PowerShell Version Check: $(if ($isPowerShell5Plus) { 'PASS' } else { 'FAIL' }) - $($psVersion.ToString())"

    # Check Disk Space
    $systemDrive = $env:SystemDrive
    $drive = Get-PSDrive -Name $systemDrive.Trim(':')
    $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
    $hasSufficientSpace = ($freeSpaceGB -ge 10)
    $results += @{
        Check = "Disk Space (10GB+)"
        Status = if ($hasSufficientSpace) { "PASS" } elseif ($freeSpaceGB -ge 5) { "WARN" } else { "FAIL" }
        Details = "Available: $freeSpaceGB GB on $systemDrive"
        Critical = $false
    }
    Write-Log "INFO" "Disk Space Check: Available $freeSpaceGB GB on $systemDrive"

    # Check if running in Windows Sandbox
    $isWindowsSandbox = Test-Path "C:\Users\WDAGUtilityAccount"
    $results += @{
        Check = "Not Windows Sandbox"
        Status = if (-not $isWindowsSandbox) { "PASS" } else { "WARN" }
        Details = if ($isWindowsSandbox) { "Running in Windows Sandbox - some features may not persist" } else { "Normal Windows environment" }
        Critical = $false
    }
    Write-Log "INFO" "Windows Sandbox Check: $(if (-not $isWindowsSandbox) { 'PASS' } else { 'WARN' })"

    # Check RAM
    $totalRAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $hasSufficientRAM = ($totalRAM -ge 8)
    $results += @{
        Check = "RAM (8GB+ recommended)"
        Status = if ($hasSufficientRAM) { "PASS" } else { "WARN" }
        Details = "Total: $totalRAM GB"
        Critical = $false
    }
    Write-Log "INFO" "RAM Check: Total $totalRAM GB"

    return $results
}

function Test-Prerequisites {
    Write-Host "`n🔍 Checking prerequisites..." -ForegroundColor Cyan
    Write-Log "INFO" "Starting prerequisites check"

    $results = @()

    # Check Internet Connection
    $hasInternet = $false
    try {
        $testConnection = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction Stop
        $hasInternet = $testConnection
    }
    catch {
        $hasInternet = $false
    }
    $results += @{
        Check = "Internet Connection"
        Status = if ($hasInternet) { "PASS" } else { "FAIL" }
        Details = if ($hasInternet) { "Connected" } else { "No connection detected" }
        Critical = $true
    }
    Write-Log "INFO" "Internet Connection Check: $(if ($hasInternet) { 'PASS' } else { 'FAIL' })"

    # Check Administrator Privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $results += @{
        Check = "Administrator Rights"
        Status = if ($isAdmin) { "PASS" } else { "FAIL" }
        Details = if ($isAdmin) { "Running as Administrator" } else { "Not running as Administrator" }
        Critical = $true
    }
    Write-Log "INFO" "Administrator Rights Check: $(if ($isAdmin) { 'PASS' } else { 'FAIL' })"

    # Check Execution Policy
    $executionPolicy = Get-ExecutionPolicy
    $policyAllowsScripts = ($executionPolicy -ne "Restricted")
    $results += @{
        Check = "Execution Policy"
        Status = if ($policyAllowsScripts) { "PASS" } else { "WARN" }
        Details = "Current: $executionPolicy"
        Critical = $false
    }
    Write-Log "INFO" "Execution Policy Check: $executionPolicy"

    # Check Write Permissions to Destination Folders
    $canWriteToProfile = Test-Path $CONFIG.Paths.PowerShellConfig -PathType Container -ErrorAction SilentlyContinue
    if (-not $canWriteToProfile) {
        try {
            New-Item -ItemType Directory -Path $CONFIG.Paths.PowerShellConfig -Force -ErrorAction Stop | Out-Null
            $canWriteToProfile = $true
        }
        catch {
            $canWriteToProfile = $false
        }
    }
    $results += @{
        Check = "Write Permissions"
        Status = if ($canWriteToProfile) { "PASS" } else { "FAIL" }
        Details = if ($canWriteToProfile) { "Can write to profile directory" } else { "Cannot write to profile directory" }
        Critical = $true
    }
    Write-Log "INFO" "Write Permissions Check: $(if ($canWriteToProfile) { 'PASS' } else { 'FAIL' })"

    # Check if Docker port (2375/2376) is available (if Docker will be installed)
    $dockerPackage = $CONFIG.WingetPackages | Where-Object { $_.Id -eq "Docker.DockerDesktop" }
    if ($dockerPackage) {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $portAvailable = -not $tcpClient.ConnectAsync("localhost", 2375).Wait(100)
            $tcpClient.Close()
        }
        catch {
            $portAvailable = $true
        }
        $results += @{
            Check = "Docker Port Available"
            Status = if ($portAvailable) { "PASS" } else { "WARN" }
            Details = if ($portAvailable) { "Port 2375 available" } else { "Port may be in use" }
            Critical = $false
        }
        Write-Log "INFO" "Docker Port Check: $(if ($portAvailable) { 'PASS' } else { 'WARN' })"
    }

    return $results
}

function Show-PreflightSummary {
    param(
        [array]$SystemResults,
        [array]$PrereqResults
    )

    $allResults = $SystemResults + $PrereqResults

    Write-Host "`n" -NoNewline
    Write-Host "═" * 70 -ForegroundColor Cyan
    Write-Host " Pre-flight Check Summary" -ForegroundColor Green
    Write-Host "═" * 70 -ForegroundColor Cyan
    Write-Host ""

    foreach ($result in $allResults) {
        $icon = switch ($result.Status) {
            "PASS" { "✅" }
            "WARN" { "⚠️" }
            "FAIL" { "❌" }
        }

        $color = switch ($result.Status) {
            "PASS" { "Green" }
            "WARN" { "Yellow" }
            "FAIL" { "Red" }
        }

        Write-Host "$icon " -NoNewline
        Write-Host "$($result.Check): " -NoNewline -ForegroundColor White
        Write-Host "$($result.Status)" -ForegroundColor $color
        Write-Host "   $($result.Details)" -ForegroundColor Gray
    }

    Write-Host "`n" -NoNewline
    Write-Host "─" * 70 -ForegroundColor Cyan

    # Count results
    $passCount = ($allResults | Where-Object { $_.Status -eq "PASS" }).Count
    $warnCount = ($allResults | Where-Object { $_.Status -eq "WARN" }).Count
    $failCount = ($allResults | Where-Object { $_.Status -eq "FAIL" }).Count

    Write-Host "Results: " -NoNewline
    Write-Host "$passCount passed" -ForegroundColor Green -NoNewline
    Write-Host ", " -NoNewline
    Write-Host "$warnCount warnings" -ForegroundColor Yellow -NoNewline
    Write-Host ", " -NoNewline
    Write-Host "$failCount failed" -ForegroundColor Red

    # Check for critical failures
    $criticalFailures = $allResults | Where-Object { $_.Status -eq "FAIL" -and $_.Critical }

    if ($criticalFailures.Count -gt 0) {
        Write-Host "`n❌ CRITICAL: Cannot proceed due to failed requirements:" -ForegroundColor Red
        foreach ($failure in $criticalFailures) {
            Write-Host "   - $($failure.Check): $($failure.Details)" -ForegroundColor Red
        }
        Write-Log "ERROR" "Pre-flight checks failed - $($criticalFailures.Count) critical failures"
        return $false
    }

    if ($warnCount -gt 0) {
        Write-Host "`n⚠️ Warnings detected. You can continue, but some features may not work optimally." -ForegroundColor Yellow
        Write-Host "Do you want to continue? (Y/N): " -NoNewline -ForegroundColor Yellow
        $response = Read-Host

        if ($response -ne 'Y' -and $response -ne 'y') {
            Write-Host "Setup cancelled by user." -ForegroundColor Yellow
            Write-Log "INFO" "Setup cancelled by user after warnings"
            return $false
        }
    }

    Write-Host "`n✅ Pre-flight checks passed! Ready to proceed." -ForegroundColor Green
    Write-Log "INFO" "Pre-flight checks passed"
    return $true
}

function Update-Environment {
    Write-Host "Refreshing environment variables..." -ForegroundColor Cyan
    Write-Log "INFO" "Refreshing environment variables and PATH"

    try {
        # Method 1: Update PATH from registry
        $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = "$machinePath;$userPath"
        Write-Log "DEBUG" "Updated PATH from registry"

        # Method 2: Update all environment variables
    foreach ($level in "Machine", "User") {
            $envVars = [Environment]::GetEnvironmentVariables($level)
            $envVars.GetEnumerator() | ForEach-Object {
            [Environment]::SetEnvironmentVariable($_.Name, $_.Value, "Process")
            }
            Write-Log "DEBUG" "Updated $($envVars.Count) environment variables from $level level"
        }

        # Method 3: Broadcast WM_SETTINGCHANGE to notify other processes
        if (-not ([System.Management.Automation.PSTypeName]'Win32.NativeMethods').Type) {
            Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @'
                [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
                public static extern IntPtr SendMessageTimeout(
                    IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
                    uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@
            Write-Log "DEBUG" "Added Win32.NativeMethods type for WM_SETTINGCHANGE"
        }

        $HWND_BROADCAST = [IntPtr]0xffff
        $WM_SETTINGCHANGE = 0x1a
        $result = [UIntPtr]::Zero
        [Win32.NativeMethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE,
            [UIntPtr]::Zero, "Environment", 2, 5000, [ref]$result) | Out-Null
        Write-Log "DEBUG" "Broadcasted WM_SETTINGCHANGE message"

        # Small delay to allow PATH to propagate
        Start-Sleep -Seconds 2

        Write-Success "Environment refreshed"
        Write-Log "INFO" "Environment refresh completed successfully"
    }
    catch {
        Write-Error "Failed to refresh environment: $_"
        Write-Log "ERROR" "Environment refresh failed" "Exception: $($_.Exception.Message)"
        throw
    }
}

function Install-GitFirst {
    Write-Step "Installing Git (required for setup)..."
    Write-Log "INFO" "Starting Git installation process"

    if (Test-Command "git") {
        $gitVersion = git --version 2>$null
        Write-Success "Git is already installed"
        Write-Log "INFO" "Git already installed: $gitVersion"
        return $true
    }

    try {
        Write-Host "Installing Git via winget..." -ForegroundColor Yellow
        Write-Log "INFO" "Installing Git using winget package manager"

        $gitInstall = Start-Process -FilePath "winget" -ArgumentList "install --id Git.Git --silent --accept-source-agreements --accept-package-agreements" -Wait -PassThru -NoNewWindow

        Write-Log "INFO" "Git installation completed with exit code: $($gitInstall.ExitCode)"

        if ($gitInstall.ExitCode -ne 0) {
            Write-Error "Git installation failed with exit code: $($gitInstall.ExitCode)"
            Write-Log "ERROR" "Git installation failed" "Exit code: $($gitInstall.ExitCode)"
            return $false
        }

        Write-Host "Git installed, refreshing environment..." -ForegroundColor Yellow
        Write-Log "INFO" "Git installation successful, refreshing environment"
        Update-Environment

        # Verify Git is now available (with retries)
        $maxRetries = 5
        $retryCount = 0

        Write-Log "INFO" "Verifying Git availability with $maxRetries retries"

        while ($retryCount -lt $maxRetries) {
            if (Test-Command "git") {
                $gitVersion = git --version 2>$null
                Write-Success "Git is now available!"
                Write-Host $gitVersion
                Write-Log "INFO" "Git verification successful: $gitVersion"
                return $true
            }

            $retryCount++
            Write-Host "Waiting for Git to be available (attempt $retryCount/$maxRetries)..." -ForegroundColor Yellow
            Write-Log "DEBUG" "Git verification attempt $retryCount/$maxRetries"
            Start-Sleep -Seconds 2
            Update-Environment
        }

        Write-Error "Git was installed but is not accessible in PATH"
        Write-Host "You may need to:" -ForegroundColor Yellow
        Write-Host "  1. Close and reopen PowerShell" -ForegroundColor Yellow
        Write-Host "  2. Or manually add Git to PATH" -ForegroundColor Yellow
        Write-Log "ERROR" "Git installation completed but not accessible in PATH after $maxRetries retries"
        return $false
    }
    catch {
        Write-Error "Error installing Git: $_"
        Write-Log "ERROR" "Git installation exception" "Exception: $($_.Exception.Message)"
        return $false
    }
}

function Install-PackageManager {
    Write-Step "Setting up package manager..."
    Write-Log "INFO" "Checking winget package manager"

    if (-not (Test-Command "winget")) {
        Write-Host "⚠️ Winget not found..." -ForegroundColor Yellow
        Write-Host "Please install App Installer from the Microsoft Store to get winget." -ForegroundColor Yellow
        Write-Log "WARNING" "Winget not found - App Installer required from Microsoft Store"
    }
    else {
        $wingetVersion = winget --version 2>$null
        Write-Success "Winget is available: $wingetVersion"
        Write-Log "INFO" "Winget available: $wingetVersion"
    }

    Write-Log "INFO" "Package manager setup completed - using winget only"
}




function Install-DevTools {
    Write-Step "Installing development tools..."
    Write-Log "INFO" "Starting installation of $($CONFIG.WingetPackages.Count) development tools"

    $installationResults = @()

    # Show package management configuration
    Write-Host "`n📋 Package Management Configuration:" -ForegroundColor Cyan
    Write-Host "  • Use Latest Versions: $($CONFIG.PackageManagement.UseLatestVersions)" -ForegroundColor White
    Write-Host "  • Update Check: $($CONFIG.PackageManagement.UpdateCheck)" -ForegroundColor White
    Write-Host "  • Skip If Installed: $($CONFIG.PackageManagement.SkipIfInstalled)" -ForegroundColor White
    Write-Host "  • Force Reinstall: $($CONFIG.PackageManagement.ForceReinstall)" -ForegroundColor White

    Write-Log "INFO" "Package management config: UseLatest=$($CONFIG.PackageManagement.UseLatestVersions), UpdateCheck=$($CONFIG.PackageManagement.UpdateCheck), SkipIfInstalled=$($CONFIG.PackageManagement.SkipIfInstalled)"

    # Install packages sequentially for better control and logging
    foreach ($package in $CONFIG.WingetPackages) {
        Write-Host "`n📦 Processing $($package.Name)..." -ForegroundColor Cyan
        Write-Log "INFO" "Processing package: $($package.Name) ($($package.Id))"

        $result = Install-SinglePackage -Package $package
        $installationResults += $result

        # Update installation state for successful installations
        if ($result.Success -and -not $result.Skipped) {
            Update-InstallationState -Operation "PackageInstalled" -Data @{
                Id = $result.Package.Id
                Name = $result.Package.Name
                Version = $result.Version
                RequiresRestart = $result.Package.RequiresRestart
                InstallTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }

            # Track restart-required apps
            if ($result.Package.RequiresRestart) {
                $CONFIG.RestartRequiredApps += $result.Package.Name
                Write-Log "INFO" "Package requires restart: $($result.Package.Name)"
            }
        }
    }

    # Display comprehensive summary
    Show-PackageSummary -Results $installationResults

    # Show restart requirements
    if ($CONFIG.RestartRequiredApps.Count -gt 0) {
        Write-Host "`n⚠️ RESTART REQUIRED for:" -ForegroundColor Yellow
        $CONFIG.RestartRequiredApps | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
        Write-Log "INFO" "Restart required for: $($CONFIG.RestartRequiredApps -join ', ')"
    }

    Write-Success "Development tools installation complete!"
    Write-Log "INFO" "Development tools installation process completed"
}

function Test-DotfilesStructure {
    param([string]$TempDir)

    Write-Host "🔍 Validating dotfiles repository structure..." -ForegroundColor Cyan

    $requiredFiles = @(
        "pwsh/Microsoft.PowerShell_profile.ps1",
        "pwsh/powershell.config.json",
        "pwsh/Terminal/setting.json",
        "vscode/vscode-settings-json-main/transparency.css",
        "git/.gitconfig"
    )

    $missingFiles = @()

    foreach ($file in $requiredFiles) {
        $fullPath = Join-Path $TempDir $file
        if (-not (Test-Path $fullPath)) {
            $missingFiles += $file
            Write-Host "  ❌ Missing: $file" -ForegroundColor Red
        }
        else {
            Write-Host "  ✅ Found: $file" -ForegroundColor Green
        }
    }

    if ($missingFiles.Count -gt 0) {
        Write-Host "`n❌ Repository structure validation failed!" -ForegroundColor Red
        Write-Host "Missing $($missingFiles.Count) required files" -ForegroundColor Yellow
        return $false
    }

    Write-Success "Repository structure validated!"
    return $true
}

function Copy-FileWithValidation {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description
    )

    try {
        if (-not (Test-Path $Source)) {
            Write-Host "  ⚠️ Skipping $Description - source file not found" -ForegroundColor Yellow
            return $false
        }

        # Create destination directory if needed
        $destDir = Split-Path -Parent $Destination
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        # Backup existing file
        if (Test-Path $Destination) {
            $backupPath = "$Destination.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item $Destination $backupPath -Force
            Write-Host "  📦 Backed up existing file to: $(Split-Path -Leaf $backupPath)" -ForegroundColor Cyan
        }

        Copy-Item $Source $Destination -Force

        # Verify copy
        if (Test-Path $Destination) {
            Write-Host "  ✅ Copied $Description" -ForegroundColor Green
            # Update installation state
            Update-InstallationState -Operation "FileCopied" -Data @{
                Source = $Source
                Destination = $Destination
                Description = $Description
                CopyTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            return $true
        }
        else {
            Write-Host "  ❌ Failed to verify $Description" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "  ❌ Error copying $Description : $_" -ForegroundColor Red
        return $false
    }
}

function Setup-DotFiles {
    Write-Step "Setting up dotfiles..."
    Write-Log "INFO" "Starting dotfiles setup process"

    if (-not (Test-Command "git")) {
        Write-Error "Git is not installed. Please install Git before proceeding."
        Write-Log "ERROR" "Git command not available for dotfiles setup"
        return $false
    }

    $tempDir = Join-Path $env:TEMP "dotfiles"
    Write-Log "DEBUG" "Using temporary directory: $tempDir"

    try {
        # Clean up existing temp directory
        if (Test-Path $tempDir) {
            Write-Host "Cleaning up existing temp directory..." -ForegroundColor Yellow
            Write-Log "DEBUG" "Cleaning up existing temp directory"
            Remove-Item -Recurse -Force $tempDir
        }

        Write-Host "Cloning dotfiles repository..." -ForegroundColor Cyan
        Write-Log "INFO" "Cloning dotfiles repository from: $($CONFIG.DotfilesRepo)"
        git clone $CONFIG.DotfilesRepo $tempDir 2>&1 | Out-Null

        if (-not (Test-Path $tempDir)) {
            Write-Error "Failed to clone dotfiles repository"
            Write-Log "ERROR" "Failed to clone dotfiles repository"
            return $false
        }

        Write-Log "INFO" "Successfully cloned dotfiles repository"

        # Validate repository structure
        if (-not (Test-DotfilesStructure -TempDir $tempDir)) {
            Write-Error "Repository structure is invalid. Aborting dotfiles setup."
            Write-Log "ERROR" "Repository structure validation failed"
            return $false
        }

        Write-Host "`n📝 Copying configuration files..." -ForegroundColor Cyan
        Write-Log "INFO" "Starting configuration file copy process"

        $copyResults = @()

        # PowerShell profile
        Write-Log "DEBUG" "Copying PowerShell profile"
        $copyResults += Copy-FileWithValidation `
            -Source "$tempDir/pwsh/Microsoft.PowerShell_profile.ps1" `
            -Destination "$($CONFIG.Paths.PowerShellConfig)/Microsoft.PowerShell_profile.ps1" `
            -Description "PowerShell profile"

        # PowerShell config
        Write-Log "DEBUG" "Copying PowerShell config"
        $copyResults += Copy-FileWithValidation `
            -Source "$tempDir/pwsh/powershell.config.json" `
            -Destination "$($CONFIG.Paths.PowerShellConfig)/powershell.config.json" `
            -Description "PowerShell config"

        # Windows Terminal settings
    $terminalSettingsPath = "$($CONFIG.Paths.LocalAppData)\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    if (Test-Path $terminalSettingsPath) {
            Write-Log "DEBUG" "Copying Windows Terminal settings"
            $copyResults += Copy-FileWithValidation `
                -Source "$tempDir/pwsh/Terminal/setting.json" `
                -Destination "$terminalSettingsPath/settings.json" `
                -Description "Windows Terminal settings"
        }
        else {
            Write-Host "  ⚠️ Windows Terminal not found, skipping settings" -ForegroundColor Yellow
            Write-Log "WARNING" "Windows Terminal not found, skipping settings"
        }

        # VS Code custom CSS
        Write-Log "DEBUG" "Copying VS Code custom CSS"
        $copyResults += Copy-FileWithValidation `
            -Source "$tempDir/vscode/vscode-settings-json-main/transparency.css" `
            -Destination "$($CONFIG.Paths.VSCodeSettings)/custom-vscode.css" `
            -Description "VS Code custom CSS"

        # Git config
        Write-Log "DEBUG" "Copying Git configuration"
        $copyResults += Copy-FileWithValidation `
            -Source "$tempDir/git/.gitconfig" `
            -Destination "$($CONFIG.Paths.Home)/.gitconfig" `
            -Description "Git configuration"

        # Summary
        $successCount = ($copyResults | Where-Object { $_ -eq $true }).Count
        $totalCount = $copyResults.Count

        Write-Host "`n📊 Configuration files: $successCount/$totalCount copied successfully" -ForegroundColor Cyan
        Write-Log "INFO" "Configuration files copy summary: $successCount/$totalCount successful"

        Write-Success "Dotfiles setup complete!"
        Write-Log "INFO" "Dotfiles setup completed successfully"
        return $true
    }
    catch {
        Write-Error "Error during dotfiles setup: $_"
        Write-Log "ERROR" "Dotfiles setup failed" "Exception: $($_.Exception.Message)"
        return $false
    }
    finally {
        # Cleanup temp directory
        if (Test-Path $tempDir) {
            Write-Host "🧹 Cleaning up temporary files..." -ForegroundColor Cyan
            Write-Log "DEBUG" "Cleaning up temporary directory"
            Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
        }
    }
}



# ===============================
# Pre-flight Validation Functions
# ===============================

function Test-SystemRequirements {
    Write-Log "INFO" "Running system requirements checks"

    $results = @{
        WindowsVersion = $false
        PowerShellVersion = $false
        DiskSpace = $false
        Sandbox = $false
    }

    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -ge 10) {
        $results.WindowsVersion = $true
        Write-Log "DEBUG" "Windows version check passed: $($osVersion.Major)"
    } else {
        Write-Log "WARNING" "Windows version check failed: $($osVersion.Major)"
    }

    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -ge 5) {
        $results.PowerShellVersion = $true
        Write-Log "DEBUG" "PowerShell version check passed: $($PSVersionTable.PSVersion.Major)"
    } else {
        Write-Log "WARNING" "PowerShell version check failed: $($PSVersionTable.PSVersion.Major)"
    }

    # Check disk space
    $drive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
    $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
    if ($freeSpaceGB -ge 10) {
        $results.DiskSpace = $true
        Write-Log "DEBUG" "Disk space check passed: $freeSpaceGB GB free"
    } else {
        Write-Log "WARNING" "Disk space check failed: $freeSpaceGB GB free (need 10GB)"
    }

    # Check if running in Windows Sandbox
    $sandbox = $env:USERNAME -eq "WDAGUtilityAccount"
    if (-not $sandbox) {
        $results.Sandbox = $true
        Write-Log "DEBUG" "Sandbox check passed: not running in Windows Sandbox"
    } else {
        Write-Log "WARNING" "Sandbox check failed: running in Windows Sandbox"
    }

    return $results
}

function Test-Prerequisites {
    Write-Log "INFO" "Running prerequisites checks"

    $results = @{
        InternetConnection = $false
        AdminPrivileges = $false
        ExecutionPolicy = $false
        WritePermissions = $false
    }

    # Check internet connection
    try {
        $testConnection = Test-Connection -ComputerName "github.com" -Count 1 -Quiet -TimeoutSeconds 5
        if ($testConnection) {
            $results.InternetConnection = $true
            Write-Log "DEBUG" "Internet connection check passed"
        } else {
            Write-Log "WARNING" "Internet connection check failed"
        }
    }
    catch {
        Write-Log "WARNING" "Internet connection check failed: $_"
    }

    # Check admin privileges
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $results.AdminPrivileges = $true
        Write-Log "DEBUG" "Admin privileges check passed"
    } else {
        Write-Log "WARNING" "Admin privileges check failed"
    }

    # Check execution policy
    $executionPolicy = Get-ExecutionPolicy
    if ($executionPolicy -in @("RemoteSigned", "Unrestricted", "Bypass")) {
        $results.ExecutionPolicy = $true
        Write-Log "DEBUG" "Execution policy check passed: $executionPolicy"
    } else {
        Write-Log "WARNING" "Execution policy check failed: $executionPolicy"
    }

    # Check write permissions
    try {
        $testPath = Join-Path $env:TEMP "dev-setup-test"
        New-Item -ItemType Directory -Path $testPath -Force | Out-Null
        Remove-Item -Path $testPath -Force
        $results.WritePermissions = $true
        Write-Log "DEBUG" "Write permissions check passed"
    }
    catch {
        Write-Log "WARNING" "Write permissions check failed: $_"
    }

    return $results
}

function Show-PreflightSummary {
    param(
        [hashtable]$SystemResults,
        [hashtable]$PrereqResults
    )

    Write-Host "`n" -NoNewline
    Write-Host "═" * 60 -ForegroundColor Cyan
    Write-Host " Pre-flight Checks" -ForegroundColor Green
    Write-Host "═" * 60 -ForegroundColor Cyan

    Write-Host "`nSystem Requirements:" -ForegroundColor White
    $systemChecks = @(
        @{ Name = "Windows 10/11"; Result = $SystemResults.WindowsVersion },
        @{ Name = "PowerShell 5.1+"; Result = $SystemResults.PowerShellVersion },
        @{ Name = "Disk Space (10GB+)"; Result = $SystemResults.DiskSpace },
        @{ Name = "Not in Sandbox"; Result = $SystemResults.Sandbox }
    )

    foreach ($check in $systemChecks) {
        $status = if ($check.Result) { "✅ PASS" } else { "❌ FAIL" }
        $color = if ($check.Result) { "Green" } else { "Red" }
        Write-Host "  $status $($check.Name)" -ForegroundColor $color
    }

    Write-Host "`nPrerequisites:" -ForegroundColor White
    $prereqChecks = @(
        @{ Name = "Internet Connection"; Result = $PrereqResults.InternetConnection },
        @{ Name = "Administrator Rights"; Result = $PrereqResults.AdminPrivileges },
        @{ Name = "Execution Policy"; Result = $PrereqResults.ExecutionPolicy },
        @{ Name = "Write Permissions"; Result = $PrereqResults.WritePermissions }
    )

    foreach ($check in $prereqChecks) {
        $status = if ($check.Result) { "✅ PASS" } else { "❌ FAIL" }
        $color = if ($check.Result) { "Green" } else { "Red" }
        Write-Host "  $status $($check.Name)" -ForegroundColor $color
    }

    $allPassed = ($SystemResults.Values + $PrereqResults.Values) -notcontains $false

    if (-not $allPassed) {
        Write-Host "`n⚠️ Some checks failed. Please address the issues above before continuing." -ForegroundColor Yellow
        Write-Log "WARNING" "Pre-flight checks failed - some requirements not met"
        return $false
    }

    Write-Host "`n✅ All pre-flight checks passed!" -ForegroundColor Green
    Write-Log "INFO" "All pre-flight checks passed successfully"
    return $true
}

function Main {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Host "`n" -NoNewline
    Write-Host "═" * 70 -ForegroundColor Cyan
    Write-Host " Development Environment Setup v2.0" -ForegroundColor Green
    Write-Host "═" * 70 -ForegroundColor Cyan

    Write-Host "`nThis script will set up your complete development environment." -ForegroundColor White
    Write-Host "Please ensure you have admin rights and an internet connection.`n" -ForegroundColor Yellow

    try {
        # Initialize logging system first
        Initialize-Logging
        Write-Success "Logging initialized: $($CONFIG.LogFile)"

        # Initialize rollback system
        Initialize-RollbackSystem
        Write-Success "Rollback system initialized: $($CONFIG.BackupDirectory)"

        # Backup existing configurations
        Backup-ExistingConfigs | Out-Null

        # Run pre-flight checks
        $systemResults = Test-SystemRequirements
        $prereqResults = Test-Prerequisites

        if (-not (Show-PreflightSummary -SystemResults $systemResults -PrereqResults $prereqResults)) {
            Write-Host "`nSetup aborted due to failed pre-flight checks." -ForegroundColor Red
            Write-Log "ERROR" "Setup aborted - pre-flight checks failed"
            Update-InstallationState -Operation "StatusFailed" -Data @{ ErrorMessage = "Pre-flight checks failed" }
            exit 1
        }

        Write-Host "`nPress any key to begin installation or Ctrl+C to cancel..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        Write-Log "INFO" "User confirmed - beginning installation"

        # Step 1: Install package managers
        Write-Log "INFO" "Step 1: Installing package managers"
        Install-PackageManager
        Update-Environment

        # Verify winget is available
        $retryCount = 0
        while (-not (Test-Command "winget") -and $retryCount -lt 5) {
            Write-Host "Waiting for winget to be available (attempt $($retryCount + 1)/5)..." -ForegroundColor Yellow
            Write-Log "DEBUG" "Waiting for winget availability (attempt $($retryCount + 1)/5)"
            Start-Sleep -Seconds 5
            Update-Environment
            $retryCount++
        }

        if (-not (Test-Command "winget")) {
            Write-Log "ERROR" "Winget not available after installation attempts"
            throw "Winget is not available after installation. Please restart PowerShell and try again."
        }

        Write-Log "INFO" "Winget is available and ready"

        # Step 2: Install Git first (required for dotfiles)
        Write-Log "INFO" "Step 2: Installing Git"
        if (-not (Install-GitFirst)) {
            Write-Host "`n⚠️ Git installation failed. Some features may not work." -ForegroundColor Yellow
            Write-Host "You can manually install Git and re-run this script." -ForegroundColor Yellow
            Write-Log "WARNING" "Git installation failed, continuing with limited functionality"
        }

        # Step 3: Setup dotfiles
        Write-Log "INFO" "Step 3: Setting up dotfiles"
        Setup-DotFiles

        # Step 4: Install development tools
        Write-Log "INFO" "Step 4: Installing development tools"
        Install-DevTools

        # Step 4.5: Verify installed packages
        Write-Log "INFO" "Step 4.5: Verifying installed packages"
        Verify-InstalledPackages | Out-Null

        # Step 5: Final environment refresh
        Write-Step "Applying final configurations..."
        Write-Log "INFO" "Step 5: Applying final configurations"
        Update-Environment

        # Step 6: VS Code extensions
        Write-Log "INFO" "Step 6: Installing VS Code extensions"
        Install-VSCodeExtensions

        # Verify VS Code extensions
        Test-VSCodeExtensions

        # Summary
        $sw.Stop()
        Write-Host "`n" -NoNewline
        Write-Host "═" * 70 -ForegroundColor Cyan
        Write-Host " Setup Complete! 🎉" -ForegroundColor Green
        Write-Host "═" * 70 -ForegroundColor Cyan

        Write-Host "`n⏱️ Total time: $([math]::Round($sw.Elapsed.TotalMinutes, 2)) minutes" -ForegroundColor Cyan
        Write-Host "📝 Log file: $($CONFIG.LogFile)" -ForegroundColor Cyan

        Write-Log "INFO" "Setup completed successfully in $([math]::Round($sw.Elapsed.TotalMinutes, 2)) minutes"
        Write-Log "INFO" "Total restart-required apps: $($CONFIG.RestartRequiredApps.Count)"

        if ($CONFIG.RestartRequiredApps.Count -gt 0) {
            Write-Host "`n⚠️ IMPORTANT: Computer restart required for:" -ForegroundColor Yellow
            $CONFIG.RestartRequiredApps | ForEach-Object {
                Write-Host "   - $_" -ForegroundColor Yellow
            }

            Write-Log "INFO" "Restart required for: $($CONFIG.RestartRequiredApps -join ', ')"

            Write-Host "`nWould you like to restart now? (Y/N): " -NoNewline -ForegroundColor Yellow
            $response = Read-Host

            if ($response -eq 'Y' -or $response -eq 'y') {
                Write-Host "Restarting computer in 10 seconds... Press Ctrl+C to cancel" -ForegroundColor Red
                Write-Log "INFO" "User chose to restart computer"
                Start-Sleep -Seconds 10
                Restart-Computer -Force
            }
            else {
                Write-Log "INFO" "User chose not to restart computer"
            }
        }

        Write-Host "`nNext steps:" -ForegroundColor Cyan
        Write-Host "  1. Restart your terminal to load new configurations" -ForegroundColor White
        Write-Host "  2. Open Windows Terminal to see the new PowerShell profile" -ForegroundColor White
        Write-Host "  3. Verify installations: git --version, code --version, docker --version" -ForegroundColor White
        Write-Host "  4. Configure Git with your name and email" -ForegroundColor White

        Write-Log "INFO" "Setup process completed successfully"
        Update-InstallationState -Operation "StatusComplete" -Data @{}
    }
    catch {
        Write-Host "`n" -NoNewline
        Write-Host "═" * 70 -ForegroundColor Red
        Write-Host " Setup Failed ❌" -ForegroundColor Red
        Write-Host "═" * 70 -ForegroundColor Red
        Write-Host "`nError: $_" -ForegroundColor Red
        Write-Host "`n📝 Check the log file for details: $($CONFIG.LogFile)" -ForegroundColor Yellow
        Write-Host "Please fix the issue and try again." -ForegroundColor Yellow

        Write-Log "ERROR" "Setup failed with exception" "Exception: $($_.Exception.Message)"
        Write-Log "ERROR" "Setup process terminated"

        # Update state and offer rollback
        Update-InstallationState -Operation "StatusFailed" -Data @{ ErrorMessage = $_.Exception.Message }

        # Offer rollback
        Show-RollbackPrompt
        exit 1
    }
    finally {
        # Test log size and archive if needed
        Test-LogSize
        Write-Log "INFO" "Script execution completed"
    }
}

Main
