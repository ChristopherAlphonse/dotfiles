#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Nerd Fonts installation script for Windows

.DESCRIPTION
    This script installs Nerd Fonts on Windows. It downloads the latest releases of specified fonts,
    extracts them, and installs them into the system fonts directory.

.NOTES
    Author: Christopher Alphonse
    Last Updated: 2025-04-19
#>

$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

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

function Update-Environment {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    foreach ($level in "Machine", "User") {
        [Environment]::GetEnvironmentVariables($level).GetEnumerator() | ForEach-Object {
            [Environment]::SetEnvironmentVariable($_.Name, $_.Value, "Process")
        }
    }
}


function Install-NerdFonts {
    Write-Step "Installing Nerd Fonts..."

    $fontList = @("FiraCode", "FiraMono", "Meslo")
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


function Main {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        Install-NerdFonts

        Write-Step "Applying final configurations..."

        $sw.Stop()
        Write-Success "Setup completed in $([math]::Round($sw.Elapsed.TotalMinutes, 2)) minutes!"
    }
    catch {
        Write-Error "An error occurred during setup: $_"
    }
}

Main
