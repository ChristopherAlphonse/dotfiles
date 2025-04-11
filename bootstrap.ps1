
Write-Host "`nFetching setup script from remote repository..."

$scriptUrl = "https://raw.githubusercontent.com/ChristopherAlphonse/dotfiles/refs/heads/master/setup-v1.ps1"
$tempPath = "$env:TEMP\dev-setup.ps1"

# loading
for ($i = 0; $i -le 100; $i += 10) {
    Write-Progress -Activity "Downloading setup script" -Status "$i% complete" -PercentComplete $i
    Start-Sleep -Milliseconds 100
}

Invoke-WebRequest -Uri $scriptUrl -OutFile $tempPath -UseBasicParsing


function Test-IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Host "`n[!] Administrator privileges are required to continue." -ForegroundColor Yellow
    Write-Host "[!] Please right-click PowerShell and choose 'Run as Administrator'." -ForegroundColor Red
    Write-Host "[x] Exiting setup..."
} else {
    Write-Host "`n[+] Administrator privileges confirmed." -ForegroundColor Green
    Write-Progress -Activity "Starting setup script" -Status "Launching..." -PercentComplete 100
    powershell -ExecutionPolicy Bypass -File $tempPath
}


Write-Host "`nSession is idle. Press Ctrl+C to exit."
while ($true) {
    Start-Sleep -Seconds 60
}
