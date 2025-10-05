
Write-Host "`nFetching setup script from remote repository..."

$scriptUrl = "https://raw.githubusercontent.com/ChristopherAlphonse/dotfiles/refs/heads/master/setup-v1.ps1"
$tempPath = "$env:TEMP\dev-setup.ps1"

# Test network connectivity
function Test-NetworkConnection {
    param([string]$Url)

    try {
        $testConnection = Test-Connection -ComputerName "github.com" -Count 1 -Quiet -ErrorAction Stop
        if (-not $testConnection) {
            return $false
        }

        # Additional check: try to resolve DNS
        $null = [System.Net.Dns]::GetHostEntry("github.com")
        return $true
    }
    catch {
        Write-Host "❌ Network connectivity issue detected: $_" -ForegroundColor Red
        return $false
    }
}

# Cleanup function
function Remove-TempFiles {
    param([string]$FilePath)

    if (Test-Path $FilePath) {
        try {
            Remove-Item -Path $FilePath -Force -ErrorAction Stop
            Write-Host "✅ Cleaned up temporary files" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠️ Warning: Could not remove temp file: $_" -ForegroundColor Yellow
        }
    }
}

# Validate downloaded file
function Test-DownloadedScript {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        Write-Host "❌ Downloaded script file not found at: $FilePath" -ForegroundColor Red
        return $false
    }

    $fileInfo = Get-Item $FilePath
    if ($fileInfo.Length -eq 0) {
        Write-Host "❌ Downloaded script file is empty" -ForegroundColor Red
        return $false
    }

    Write-Host "✅ Script validated (Size: $([math]::Round($fileInfo.Length/1KB, 2)) KB)" -ForegroundColor Green
    return $true
}

# Check network connectivity first
Write-Host "`n🔍 Checking network connectivity..." -ForegroundColor Cyan
if (-not (Test-NetworkConnection -Url "github.com")) {
    Write-Host "`n❌ Cannot reach GitHub. Please check your internet connection." -ForegroundColor Red
    Write-Host "   - Verify you are connected to the internet" -ForegroundColor Yellow
    Write-Host "   - Check if GitHub.com is accessible in your browser" -ForegroundColor Yellow
    Write-Host "   - Verify firewall/proxy settings" -ForegroundColor Yellow
    Read-Host "`nPress Enter to exit"
    exit 1
}

Write-Host "✅ Network connectivity confirmed" -ForegroundColor Green

# Download script with retry logic
$maxRetries = 3
$retryCount = 0
$downloadSuccess = $false

while ($retryCount -lt $maxRetries -and -not $downloadSuccess) {
    try {
        if ($retryCount -gt 0) {
            Write-Host "`n🔄 Retry attempt $retryCount of $($maxRetries - 1)..." -ForegroundColor Yellow
            Start-Sleep -Seconds (2 * $retryCount) # Exponential backoff
        }

        # Loading progress
        for ($i = 0; $i -le 100; $i += 10) {
            Write-Progress -Activity "Downloading setup script" -Status "$i% complete" -PercentComplete $i
            Start-Sleep -Milliseconds 100
        }

        Invoke-WebRequest -Uri $scriptUrl -OutFile $tempPath -UseBasicParsing -ErrorAction Stop

        # Validate download
        if (Test-DownloadedScript -FilePath $tempPath) {
            $downloadSuccess = $true
            Write-Host "✅ Setup script downloaded successfully" -ForegroundColor Green
        }
        else {
            throw "Downloaded script validation failed"
        }
    }
    catch {
        $retryCount++
        Write-Host "❌ Download failed: $_" -ForegroundColor Red

        if ($retryCount -ge $maxRetries) {
            Write-Host "`n❌ Failed to download script after $maxRetries attempts" -ForegroundColor Red
            Write-Host "   Please check the following:" -ForegroundColor Yellow
            Write-Host "   1. URL is accessible: $scriptUrl" -ForegroundColor Yellow
            Write-Host "   2. GitHub is not experiencing issues" -ForegroundColor Yellow
            Write-Host "   3. Your antivirus/firewall is not blocking the download" -ForegroundColor Yellow
            Remove-TempFiles -FilePath $tempPath
            Read-Host "`nPress Enter to exit"
            exit 1
        }
    }
}


function Test-IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Host "`n[!] Administrator privileges are required to continue." -ForegroundColor Yellow
    Write-Host "[!] Please right-click PowerShell and choose 'Run as Administrator'." -ForegroundColor Red
    Write-Host "[x] Exiting setup..."
    Remove-TempFiles -FilePath $tempPath
    Read-Host "`nPress Enter to exit"
    exit 1
}

Write-Host "`n[+] Administrator privileges confirmed." -ForegroundColor Green
Write-Host "`n🚀 Launching setup script..." -ForegroundColor Cyan

try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    Write-Progress -Activity "Starting setup script" -Status "Launching..." -PercentComplete 100

    # Execute the downloaded script
    & $tempPath

    $exitCode = $LASTEXITCODE

    if ($exitCode -and $exitCode -ne 0) {
        Write-Host "`n⚠️ Setup script completed with warnings (Exit code: $exitCode)" -ForegroundColor Yellow
    }
    else {
        Write-Host "`n✅ Setup complete!" -ForegroundColor Green
    }
}
catch {
    Write-Host "`n❌ Error during setup script execution: $_" -ForegroundColor Red
    Write-Host "Check the error message above for details" -ForegroundColor Yellow
    $exitCode = 1
}
finally {
    # Always cleanup temp files
    Write-Host "`n🧹 Cleaning up..." -ForegroundColor Cyan
    Remove-TempFiles -FilePath $tempPath
}

Write-Host "`n" -NoNewline
Write-Host "═" * 70 -ForegroundColor Cyan
Write-Host " Bootstrap Process Complete" -ForegroundColor Green
Write-Host "═" * 70 -ForegroundColor Cyan

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Restart your terminal to load new configurations" -ForegroundColor White
Write-Host "  2. Verify installed tools: git --version, code --version" -ForegroundColor White
Write-Host "  3. Check your PowerShell profile for customizations" -ForegroundColor White

Read-Host "`nPress Enter to exit"
exit $exitCode
