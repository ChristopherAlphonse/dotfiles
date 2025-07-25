# EsportsTweakPack_Final.ps1
# Author: ChrisOS
# Purpose: Apply competitive-level system tweaks for Windows 11


        CCCCCCCCCCCCCHHHHHHHHH     HHHHHHHHHRRRRRRRRRRRRRRRRR   IIIIIIIIII   SSSSSSSSSSSSSSS           OOOOOOOOO        SSSSSSSSSSSSSSS
     CCC::::::::::::CH:::::::H     H:::::::HR::::::::::::::::R  I::::::::I SS:::::::::::::::S        OO:::::::::OO    SS:::::::::::::::S
   CC:::::::::::::::CH:::::::H     H:::::::HR::::::RRRRRR:::::R I::::::::IS:::::SSSSSS::::::S      OO:::::::::::::OO S:::::SSSSSS::::::S
  C:::::CCCCCCCC::::CHH::::::H     H::::::HHRR:::::R     R:::::RII::::::IIS:::::S     SSSSSSS     O:::::::OOO:::::::OS:::::S     SSSSSSS
 C:::::C       CCCCCC  H:::::H     H:::::H    R::::R     R:::::R  I::::I  S:::::S                 O::::::O   O::::::OS:::::S
C:::::C                H:::::H     H:::::H    R::::R     R:::::R  I::::I  S:::::S                 O:::::O     O:::::OS:::::S
C:::::C                H::::::HHHHH::::::H    R::::RRRRRR:::::R   I::::I   S::::SSSS              O:::::O     O:::::O S::::SSSS
C:::::C                H:::::::::::::::::H    R:::::::::::::RR    I::::I    SS::::::SSSSS         O:::::O     O:::::O  SS::::::SSSSS
C:::::C                H:::::::::::::::::H    R::::RRRRRR:::::R   I::::I      SSS::::::::SS       O:::::O     O:::::O    SSS::::::::SS
C:::::C                H::::::HHHHH::::::H    R::::R     R:::::R  I::::I         SSSSSS::::S      O:::::O     O:::::O       SSSSSS::::S
C:::::C                H:::::H     H:::::H    R::::R     R:::::R  I::::I              S:::::S     O:::::O     O:::::O            S:::::S
 C:::::C       CCCCCC  H:::::H     H:::::H    R::::R     R:::::R  I::::I              S:::::S     O::::::O   O::::::O            S:::::S
  C:::::CCCCCCCC::::CHH::::::H     H::::::HHRR:::::R     R:::::RII::::::IISSSSSSS     S:::::S     O:::::::OOO:::::::OSSSSSSS     S:::::S
   CC:::::::::::::::CH:::::::H     H:::::::HR::::::R     R:::::RI::::::::IS::::::SSSSSS:::::S      OO:::::::::::::OO S::::::SSSSSS:::::S
     CCC::::::::::::CH:::::::H     H:::::::HR::::::R     R:::::RI::::::::IS:::::::::::::::SS         OO:::::::::OO   S:::::::::::::::SS
        CCCCCCCCCCCCCHHHHHHHHH     HHHHHHHHHRRRRRRRR     RRRRRRRIIIIIIIIII SSSSSSSSSSSSSSS             OOOOOOOOO      SSSSSSSSSSSSSSS








# ===============================
# 1. Registry Backup
# ===============================
$backupPath = "C:\RegistryBackup\GamingTweaksBackup.reg"
if (-not (Test-Path "C:\RegistryBackup")) {
    New-Item -Path "C:\" -Name "RegistryBackup" -ItemType Directory | Out-Null
}
reg export "HKLM\SYSTEM\CurrentControlSet" $backupPath /y
Write-Output "Registry backup created at $backupPath"

# ===============================
# 2. Ultimate Performance Plan
# ===============================
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
Write-Output "Ultimate Performance Power Plan enabled."

# ===============================
# 3. Disable Fullscreen Optimizations + Game Bar
# ===============================
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 2
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0
Write-Output "Fullscreen optimizations and Game DVR disabled."

# Remove Xbox Game Bar
Get-AppxPackage *Microsoft.XboxGamingOverlay* | Remove-AppxPackage -ErrorAction SilentlyContinue
Write-Output "Xbox Game Bar removed."

# ===============================
# 4. Optimize Memory Management
# ===============================
$memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $memPath -Name "DisablePagingExecutive" -Value 1
Set-ItemProperty -Path $memPath -Name "LargeSystemCache" -Value 1
Write-Output " Memory management optimized."

# ===============================
# 5. Disable Nagle’s Algorithm (Low Latency Network)
# ===============================
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" }).IPAddress
$interfacePath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"

Get-ChildItem $interfacePath | ForEach-Object {
    $child = $_.PSChildName
    $props = Get-ItemProperty -Path "$interfacePath\$child" -ErrorAction SilentlyContinue
    if ($props.DhcpIPAddress -eq $ip) {
        Set-ItemProperty -Path "$interfacePath\$child" -Name "TcpAckFrequency" -Value 1 -Force
        Set-ItemProperty -Path "$interfacePath\$child" -Name "TCPNoDelay" -Value 1 -Force
    }
}
Write-Output " Nagle’s Algorithm disabled."

# ===============================
# 6. Disable Startup Programs
# ===============================
Get-CimInstance Win32_StartupCommand | Where-Object {
    $_.Name -notlike "*Microsoft*" -and $_.Command -notlike "*Windows Defender*"
} | ForEach-Object {
    Write-Output "Disabling startup: $($_.Name)"
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $_.Name -ErrorAction SilentlyContinue
}
Write-Output " Non-essential startup programs disabled."

# ===============================
# 7. Optimize Visual Effects
# ===============================
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value 1
Write-Output " Visual effects optimized."

# ===============================
# 8. Disable Non-Essential Services
# ===============================
$services = @("SysMain", "WSearch", "DiagTrack", "RetailDemo", "XblGameSave", "XboxNetApiSvc")
foreach ($service in $services) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled
        Write-Output "Disabled service: $service"
    }
}
Write-Output " Non-essential services disabled."

# ===============================
# 9. Disable NDU (DPC Latency Fix)
# ===============================
Stop-Service -Name Ndu -Force -ErrorAction SilentlyContinue
Set-Service -Name Ndu -StartupType Disabled
Write-Output " NDU disabled to reduce DPC latency."

# ===============================
# 10. Enable Hardware-Accelerated GPU Scheduling
# ===============================
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2
Write-Output " Hardware-accelerated GPU scheduling enabled."

# ===============================
# 11. (Optional) Disable HPET via BCD
# ===============================
bcdedit /deletevalue useplatformclock > $null 2>&1
Write-Output " HPET disabled (via BCDedit)."


# ===============================
# 12. Input Queue Sizes
# ===============================
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "This script requires administrative privileges. Please run PowerShell as Administrator."
    exit
}


$mouseRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\mouhid\Parameters"
$mouseRegKey = "MouseDataQueueSize"
$mouseValue = 12


$keyboardRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters"
$keyboardRegKey = "KeyboardDataQueueSize"
$keyboardValue = 12

try {

    if (-not (Test-Path $mouseRegPath)) {
        Write-Output "Registry path $mouseRegPath does not exist. Creating it..."
        New-Item -Path $mouseRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $mouseRegPath -Name $mouseRegKey -Value $mouseValue -Type DWord -Force
    Write-Output "Successfully set $mouseRegKey to $mouseValue."


    if (-not (Test-Path $keyboardRegPath)) {
        Write-Output "Registry path $keyboardRegPath does not exist. Creating it..."
        New-Item -Path $keyboardRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $keyboardRegPath -Name $keyboardRegKey -Value $keyboardValue -Type DWord -Force
    Write-Output "Successfully set $keyboardRegKey to $keyboardValue."

    Write-Output "Please restart your computer for the changes to take effect."
}
catch {
    Write-Error "Failed to set input queue sizes. Error: $_"
}
# ===============================
# 13. Prompt for Restart
# ===============================
$restart = Read-Host "`nChanges applied successfully. Restart now? (Y/N)"
if ($restart -match "^[Yy]$") {
    Restart-Computer
}
