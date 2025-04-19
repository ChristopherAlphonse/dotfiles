#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Development environment setup script for Windows
.DESCRIPTION
    Sets up a complete development environment on Windows including:
    - Package managers (winget, scoop, chocolatey)
    - Development tools (Git, Node.js, Python, Java, etc.)
    - PowerShell modules and configuration
    - Terminal customization
    - VSCode with settings
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
        @{Id = "Git.Git"; Name = "Git"},
        @{Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal"},
        @{Id = "Microsoft.VisualStudioCode"; Name = "VS Code"},
        @{Id = "OpenJS.NodeJS.LTS"; Name = "Node.js LTS"},
        @{Id = "Oracle.JDK.24"; Name = "Java"},
        @{Id = "Python.Python.3.11"; Name = "Python"},
        @{Id = "Docker.DockerDesktop"; Name = "Docker Desktop"},
        @{Id = "Zoom.Zoom"; Name = "Zoom"},
        @{Id = "SlackTechnologies.Slack"; Name = "Slack"},
        @{Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh"},
        @{Id = "Microsoft.PowerToys"; Name = "PowerToys (Preview)"}
    )
    # ScoopPackages = @(
    #    "curl", "sudo", "jq", "bat", "ripgrep",
    #     "fzf", "zoxide", "carapace", "delta", "python",
    #    "7zip", "mongodb-compass ","mongosh ",
    #    "mongodb-database-tools","mongodb", "openssh", "curl"

    # )
    PowerShellModules = @(
        "PowerShellGet",
        "PSReadLine",
        "z",
        "PSFzf",
        "oh-my-posh",
        "Terminal-Icons"
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
        Write-Host "Please install App Installer from the Microsoft Store to get winget"
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

function Install-NerdFonts {
    Write-Step "Installing Nerd Fonts..."

    $fontList = @(
        "FiraCode",
        "FiraMono",
        "Meslo"
    )

    $tempDir = "$env:TEMP\nerd-fonts"
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
    New-Item -ItemType Directory -Path $tempDir | Out-Null

    foreach ($font in $fontList) {
        $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"
        $zipPath = "$tempDir\$font.zip"
        $extractPath = "$tempDir\$font"

        Write-Host "Downloading $font Nerd Font..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing

        Write-Host "Extracting $font..." -ForegroundColor Yellow
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

        Write-Host "Installing $font..." -ForegroundColor Yellow
        $fontFiles = Get-ChildItem -Path $extractPath -Include *.ttf -Recurse
        foreach ($file in $fontFiles) {
            Copy-Item $file.FullName -Destination "$env:WINDIR\Fonts" -Force
        }
    }

    Write-Success "Nerd Fonts installed! You may need to restart to see them in terminals/editors."
}

function Install-DevTools {
    Write-Step "Installing development tools..."

    foreach ($package in $CONFIG.WingetPackages) {
        Write-Host "Installing $($package.Name)..." -ForegroundColor Yellow
        winget install -e --id $package.Id --accept-package-agreements --accept-source-agreements
    }

    # scoop update
    # foreach ($package in $CONFIG.ScoopPackages) {
    #     Write-Host "Installing $package via Scoop..." -ForegroundColor Yellow
    #     scoop install $package
    # }
}

function Install-PowerShellModules {
    Write-Step "Setting up PowerShell modules..."

    foreach ($module in $CONFIG.PowerShellModules) {
        Write-Host "Installing $module..." -ForegroundColor Yellow
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    }
}

function Setup-DotFiles {
    Write-Step "Setting up dotfiles..."

     if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Git is not installed. Please install Git before proceeding."
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

function Install-NodeEnvironment {
    Write-Step "Setting up Node.js development environment..."

    $nodeInstaller = "$env:TEMP\node-lts.msi"
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi" -OutFile $nodeInstaller
    Start-Process msiexec.exe -Wait -ArgumentList "/i `"$nodeInstaller`" /quiet /norestart"
    Remove-Item $nodeInstaller
    Write-Output "Node.js installed."

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

    $nodePackages = @(
        "typescript",
        "ts-node",
        "prettier",
        "eslint",
        "npm-check-updates",
        "yarn",
        "nodemon"
    )

    foreach ($package in $nodePackages) {
        Write-Host "Installing $package globally..." -ForegroundColor Yellow
        npm install -g $package
    }
}

function Install-JavaEnvironment {
    Write-Step "Setting up Java development environment..."

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

    Write-Host "Installing Maven..." -ForegroundColor Yellow
    choco install maven -y
}





function Main {
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


        $jobs = @()


        Write-Step "Installing Git..."
        winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
        Update-Environment



        $jobs += Start-Job -ScriptBlock {
            . $using:PSCommandPath
            Install-NodeEnvironment
        }

        $jobs += Start-Job -ScriptBlock {
            . $using:PSCommandPath
            Install-JavaEnvironment
        }

        $jobs += Start-Job -ScriptBlock {
            . $using:PSCommandPath
            Install-NerdFonts
        }


        Setup-DotFiles


        Install-DevTools
        Install-PowerShellModules


        Write-Host "Waiting for parallel installations to complete..." -ForegroundColor Yellow
        $jobs | Wait-Job | Receive-Job

        Write-Step "Applying final configurations..."


        Update-Environment

        Write-Host "Installing VS Code extensions..." -ForegroundColor Yellow
        $vsCodeJobs = @(
            "ms-python.python",
            "ms-python.vscode-pylance",
            "vscjava.vscode-java-pack"
        ) | ForEach-Object {
            Start-Job -ScriptBlock {
                code --install-extension $using:_
            }
        }
        $vsCodeJobs | Wait-Job | Receive-Job

        $sw.Stop()
        Write-Success "Setup completed successfully in $([math]::Round($sw.Elapsed.TotalMinutes, 2)) minutes!"
        Write-Host "`nNext steps:" -ForegroundColor Yellow
        Write-Host "1. Restart your computer" -ForegroundColor Yellow
        Write-Host "2. Open Windows Terminal to see the new PowerShell profile" -ForegroundColor Yellow
        Write-Host "3. Open VS Code and let it sync settings" -ForegroundColor Yellow
    }
    catch {
        Write-Error "An error occurred during setup: $_"
        Write-Host "Please check the error message above and try again." -ForegroundColor Yellow
        Write-Host "Press 'S' to skip this step and continue, or any other key to exit..." -ForegroundColor Yellow
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
        if ($key -ne 'S' -and $key -ne 's') {
            exit 1
        }
    }
    finally {

        Get-Job | Remove-Job -Force
    }
}

Main
