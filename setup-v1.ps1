#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Development environment setup script for Windows

.DESCRIPTION


.NOTES
    Author: Christopher Alphonse
    Last Updated: 2025-04-19
#>

$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

$CONFIG = @{
    DotfilesRepo = "https://github.com/ChristopherAlphonse/dotfiles"
    Paths = @{
        Home = $env:USERPROFILE
        Documents = [Environment]::GetFolderPath("MyDocuments")
        LocalAppData = $env:LOCALAPPDATA
        PowerShellConfig = "$([Environment]::GetFolderPath('MyDocuments'))\PowerShell"
        VSCodeSettings = "$env:APPDATA\Code\User"
    }
    WingetPackages = @(
        @{ Id = "Git.Git"; Name = "Git" },
        @{ Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal" },
        @{ Id = "Microsoft.VisualStudioCode"; Name = "VS Code" },
        @{ Id = "Python.Python.3.11"; Name = "Python" },
        @{ Id = "Docker.DockerDesktop"; Name = "Docker Desktop" },
        @{ Id = "SlackTechnologies.Slack"; Name = "Slack" },
        @{ Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh" },
        @{ Id = "Microsoft.PowerToys"; Name = "PowerToys (Preview)" }
    )
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "$Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "$Message" -ForegroundColor Red
}

function Test-Command {
    param([string]$Command)
    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

function Update-Environment {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    foreach ($level in "Machine", "User") {
        [Environment]::GetEnvironmentVariables($level).GetEnumerator() | ForEach-Object {
            [Environment]::SetEnvironmentVariable($_.Name, $_.Value, "Process")
        }
    }
}

function Install-PackageManager {
    Write-Step "Setting up package managers..."

    if (-not (Test-Command "winget")) {
        Write-Host "Installing winget..." -ForegroundColor Yellow
        Write-Host "Please install App Installer from the Microsoft Store to get winget."
    }

    if (-not (Test-Command "scoop")) {
        Write-Host "Installing Scoop..." -ForegroundColor Yellow
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    }

    if (-not (Test-Command "choco")) {
        Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
}




function Install-DevTools {
    Write-Step "Installing development tools in parallel..."

    $jobs = @()
    foreach ($package in $CONFIG.WingetPackages) {
        $jobs += Start-Job -ArgumentList $package -ScriptBlock {
            param($pkg)
            try {
                winget install -e --id $pkg.Id --accept-package-agreements --accept-source-agreements --silent
                Write-Output "[+] Installed $($pkg.Name)"
            }
            catch {
                Write-Output "[x] Failed to install $($pkg.Name): $_"
            }
        }
    }

    Write-Host "Waiting for parallel installations to complete..." -ForegroundColor Cyan
    $jobs | Wait-Job

    foreach ($job in $jobs) {
        $output = Receive-Job -Job $job
        Write-Host $output
        Remove-Job -Job $job
    }

    Write-Success "All development tools have been installed!"
}

function Setup-DotFiles {
    Write-Step "Setting up dotfiles..."

    if (-not (Test-Command "git")) {
        Write-Error "Git is not installed. Please install Git before proceeding."
        return
    }

    $tempDir = Join-Path $env:TEMP "dotfiles"
    if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }

    git clone $CONFIG.DotfilesRepo $tempDir

    $profilePath = $CONFIG.Paths.PowerShellConfig
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType Directory -Path $profilePath -Force
    }

    Copy-Item "$tempDir/pwsh/Microsoft.PowerShell_profile.ps1" "$profilePath/Microsoft.PowerShell_profile.ps1" -Force
    Copy-Item "$tempDir/pwsh/powershell.config.json" "$profilePath/powershell.config.json" -Force

    $terminalSettingsPath = "$($CONFIG.Paths.LocalAppData)\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    if (Test-Path $terminalSettingsPath) {
        Copy-Item "$tempDir/pwsh/Terminal/setting.json" "$terminalSettingsPath/settings.json" -Force
    }

    $vscodeSettingsPath = $CONFIG.Paths.VSCodeSettings
    if (-not (Test-Path $vscodeSettingsPath)) {
        New-Item -ItemType Directory -Path $vscodeSettingsPath -Force
    }
    Copy-Item "$tempDir/vscode/vscode-settings-json-main/custom-vscode.css" "$vscodeSettingsPath/custom-vscode.css" -Force

    Copy-Item "$tempDir/git/.gitconfig" "$($CONFIG.Paths.Home)/.gitconfig" -Force

    Remove-Item -Recurse -Force $tempDir
}



function Main {
    function Log-Output {
        param([string]$Message)
        Add-Content -Path "$env:TEMP\dev-setup.log" -Value "$(Get-Date) :: $Message"
    }

    $esc = [char]27
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Host "Starting development environment setup..." -ForegroundColor Cyan
    Write-Host "${esc}[44;37mThis script will set up your complete development environment.${esc}[0m"
    Write-Host "Please ensure you have admin rights and an internet connection." -ForegroundColor Yellow
    Write-Host "Press any key to continue or Ctrl+C to cancel..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    try {
        Install-PackageManager
        Update-Environment

        $retryCount = 0
        while (-not (Test-Command "winget") -and $retryCount -lt 5) {
            Start-Sleep -Seconds 5
            Update-Environment
            $retryCount++
        }

        if (-not (Test-Command "winget")) {
            throw "Winget is not available after installation. Please restart PowerShell and try again."
        }

        Write-Step "Installing Git..."
        winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
        Update-Environment

        Setup-DotFiles
        Install-NodeEnvironment
        Install-NerdFonts
        Install-DevTools

        Write-Step "Applying final configurations..."
        Update-Environment

        Write-Host "Installing VS Code extensions..." -ForegroundColor Yellow


        $sw.Stop()
        Write-Success "Setup completed successfully in $([math]::Round($sw.Elapsed.TotalMinutes, 2)) minutes!"
        Write-Host "`nNext steps:" -ForegroundColor Yellow
        Write-Host "1. Restart your computer"
        Write-Host "2. Open Windows Terminal to see the new PowerShell profile"
        Write-Host "3. Open VS Code and let it sync settings"
    }
    catch {
        Write-Error "An error occurred during setup: $_"
        Write-Host "Please check the error message above and try again." -ForegroundColor Yellow
    }
}

Main
