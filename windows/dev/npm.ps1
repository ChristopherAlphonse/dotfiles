#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Node and NPM setup script for Windows

.DESCRIPTION
    Sets up Node.js and NPM development environment on Windows including:
    - Node.js installation
    - Global NPM packages installation

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

function Install-NodeEnvironment {
    Write-Step "Setting up Node.js development environment..."

    $nodeInstaller = "$env:TEMP\node-lts.msi"
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi" -OutFile $nodeInstaller
    if (Test-Path $nodeInstaller) {
        Start-Process msiexec.exe -Wait -ArgumentList "/i `"$nodeInstaller`" /quiet /norestart"
        Remove-Item $nodeInstaller
    } else {
        Write-Error "Node.js installer not found at $nodeInstaller"
        return
    }

    Update-Environment

    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Error "npm is not installed or not available in PATH."
        return
    }

    $nodePackages = @("typescript", "ts-node", "prettier", "eslint", "npm-check-updates", "yarn", "nodemon")

    foreach ($package in $nodePackages) {
        Write-Host "Installing $package globally..." -ForegroundColor Yellow
        npm install -g $package
    }

    Write-Success "Node.js and global NPM packages installed successfully!"
}

function Main {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        Install-NodeEnvironment

        Write-Step "Applying final configurations..."

        $sw.Stop()
        Write-Success "Setup completed in $([math]::Round($sw.Elapsed.TotalMinutes, 2)) minutes!"
    }
    catch {
        Write-Error "An error occurred during setup: $_"
    }
}

Main
