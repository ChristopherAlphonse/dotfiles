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
        LogDirectory = "$env:TEMP\dev-setup-logs"
    }
    WingetPackages = @(
        @{ Id = "Git.Git"; Name = "Git"; RequiresRestart = $false },
        @{ Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal"; RequiresRestart = $false },
        @{ Id = "Microsoft.VisualStudioCode"; Name = "VS Code"; RequiresRestart = $false },
        @{ Id = "Python.Python.3.11"; Name = "Python"; RequiresRestart = $false },
        @{ Id = "Docker.DockerDesktop"; Name = "Docker Desktop"; RequiresRestart = $true },
        @{ Id = "SlackTechnologies.Slack"; Name = "Slack"; RequiresRestart = $false },
        @{ Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh"; RequiresRestart = $false },
        @{ Id = "Microsoft.PowerToys"; Name = "PowerToys (Preview)"; RequiresRestart = $false }
    )
    RestartRequiredApps = @()  # Track apps that need restart
    LogFile = ""  # Will be set during initialization
    MaxLogSize = 10MB
    MaxLogFiles = 5
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

# ===============================
# Logging System Functions
# ===============================

function Initialize-Logging {
    Write-Host "Initializing logging system..." -ForegroundColor Cyan
    
    # Create log directory
    if (-not (Test-Path $CONFIG.Paths.LogDirectory)) {
        New-Item -ItemType Directory -Path $CONFIG.Paths.LogDirectory -Force | Out-Null
    }
    
    # Set log file path with timestamp
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $CONFIG.LogFile = Join-Path $CONFIG.Paths.LogDirectory "dev-setup-$timestamp.log"
    
    # Clean up old logs
    Remove-OldLogs
    
    # Log initialization
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
    
    # Write to log file
    try {
        Add-Content -Path $CONFIG.LogFile -Value $logEntry -ErrorAction SilentlyContinue
    }
    catch {
        # If logging fails, don't break the script
        Write-Host "⚠️ Failed to write to log: $_" -ForegroundColor Yellow
    }
    
    # Also write to console for DEBUG level
    if ($Level -eq "DEBUG") {
        Write-Host "🔍 DEBUG: $Message" -ForegroundColor DarkGray
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
    Write-Step "Setting up package managers..."
    Write-Log "INFO" "Checking and installing package managers"

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
    
    if (-not (Test-Command "choco")) {
        Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
        Write-Log "INFO" "Installing Chocolatey package manager"
        
        try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Write-Success "Chocolatey installed successfully"
            Write-Log "INFO" "Chocolatey installation completed"
        }
        catch {
            Write-Host "⚠️ Chocolatey installation failed: $_" -ForegroundColor Yellow
            Write-Log "WARNING" "Chocolatey installation failed" "$($_.Exception.Message)"
        }
    }
    else {
        $chocoVersion = choco --version 2>$null
        Write-Success "Chocolatey is already installed: $chocoVersion"
        Write-Log "INFO" "Chocolatey already installed: $chocoVersion"
    }
}




function Install-DevTools {
    Write-Step "Installing development tools in parallel..."
    Write-Log "INFO" "Starting parallel installation of $($CONFIG.WingetPackages.Count) development tools"

    $jobs = @()
    $failedPackages = @()
    
    foreach ($package in $CONFIG.WingetPackages) {
        Write-Log "DEBUG" "Starting installation job for: $($package.Name) ($($package.Id))"
        $jobs += Start-Job -ScriptBlock {
            param($pkg)
            try {
                $result = Start-Process -FilePath "winget" -ArgumentList "install -e --id $($pkg.Id) --accept-package-agreements --accept-source-agreements --silent" -Wait -PassThru -NoNewWindow
                
                if ($result.ExitCode -eq 0) {
                    Write-Output "[+] ✅ Installed $($pkg.Name)"
                    return @{ Success = $true; Package = $pkg }
                }
                else {
                    Write-Output "[x] ❌ Failed to install $($pkg.Name) (Exit code: $($result.ExitCode))"
                    return @{ Success = $false; Package = $pkg; Error = "Exit code: $($result.ExitCode)" }
                }
            }
            catch {
                Write-Output "[x] ❌ Failed to install $($pkg.Name): $_"
                return @{ Success = $false; Package = $pkg; Error = $_.Exception.Message }
            }
        } -ArgumentList $package
    }

    Write-Host "Waiting for parallel installations to complete..." -ForegroundColor Cyan
    Write-Log "INFO" "Waiting for $($jobs.Count) parallel installation jobs to complete"
    
    # Wait with timeout (10 minutes max)
    $timeout = 600
    $jobs | Wait-Job -Timeout $timeout | Out-Null

    foreach ($job in $jobs) {
        if ($job.State -eq 'Running') {
            Write-Host "⚠️ Job timed out, stopping..." -ForegroundColor Yellow
            Write-Log "WARNING" "Installation job timed out, stopping job"
            Stop-Job -Job $job
        }
        
        $output = Receive-Job -Job $job
        Write-Host $output
        
        # Log job results
        if ($output -and $output.Success) {
            Write-Log "INFO" "Successfully installed: $($output.Package.Name)"
            if ($output.Package.RequiresRestart) {
                Write-Log "INFO" "Package requires restart: $($output.Package.Name)"
            }
        }
        elseif ($output -and -not $output.Success) {
            Write-Log "ERROR" "Failed to install: $($output.Package.Name)" "Error: $($output.Error)"
        }
        
        # Track restart-required apps
        if ($output -and $output.Success -and $output.Package.RequiresRestart) {
            $CONFIG.RestartRequiredApps += $output.Package.Name
        }
        
        if ($output -and -not $output.Success) {
            $failedPackages += $output.Package.Name
        }
        
        Remove-Job -Job $job
    }

    # Display summary
    Write-Host "`n" -NoNewline
    Write-Host "═" * 60 -ForegroundColor Cyan
    Write-Host " Installation Summary" -ForegroundColor Green
    Write-Host "═" * 60 -ForegroundColor Cyan
    
    $successCount = $CONFIG.WingetPackages.Count - $failedPackages.Count
    Write-Host "✅ Successful: $successCount / $($CONFIG.WingetPackages.Count)" -ForegroundColor Green
    Write-Log "INFO" "Installation summary: $successCount/$($CONFIG.WingetPackages.Count) packages installed successfully"
    
    if ($failedPackages.Count -gt 0) {
        Write-Host "❌ Failed packages:" -ForegroundColor Red
        $failedPackages | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
        Write-Log "WARNING" "Failed packages: $($failedPackages -join ', ')"
    }
    
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
        
        # Run pre-flight checks
        $systemResults = Test-SystemRequirements
        $prereqResults = Test-Prerequisites
        
        if (-not (Show-PreflightSummary -SystemResults $systemResults -PrereqResults $prereqResults)) {
            Write-Host "`nSetup aborted due to failed pre-flight checks." -ForegroundColor Red
            Write-Log "ERROR" "Setup aborted - pre-flight checks failed"
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

        # Step 5: Final environment refresh
        Write-Step "Applying final configurations..."
        Write-Log "INFO" "Step 5: Applying final configurations"
        Update-Environment

        # Step 6: VS Code extensions (placeholder for now)
        Write-Host "`n📦 VS Code extensions..." -ForegroundColor Cyan
        Write-Host "  ℹ️ Install extensions manually via VS Code Extensions marketplace" -ForegroundColor Yellow
        Write-Host "  Recommended: GitLens, Prettier, PowerShell, GitHub Copilot" -ForegroundColor White
        Write-Log "INFO" "Step 6: VS Code extensions (manual installation recommended)"

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
        exit 1
    }
    finally {
        # Test log size and archive if needed
        Test-LogSize
        Write-Log "INFO" "Script execution completed"
    }
}

Main
