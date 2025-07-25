# EsportsTweakPack_Final.ps1
# Author: ChrisOS
# Purpose: Apply competitive-level system tweaks for Windows 11





<#
   ____ _   _ ____  ____  ___   ___  ____   ____
  / ___| | | |  _ \|  _ \|_ _| / _ \|  _ \ / ___|
 | |   | | | | | | | | | || | | | | | |_) | |
 | |___| |_| | |_| | |_| || | | |_| |  _ <| |___
  \____|\___/|____/|____/|___| \___/|_| \_\\____|
#>

# ===============================
# 🔒 1. Registry Backup
# ===============================
$backupPath = "C:\RegistryBackup\GamingTweaksBackup.reg"
if (-not (Test-Path "C:\RegistryBackup")) {
    New-Item -Path "C:\" -Name "RegistryBackup" -ItemType Directory | Out-Null
}
reg export "HKLM\SYSTEM\CurrentControlSet" $backupPath /y
Write-Output "✅ Registry backup created at $backupPath"

# ===============================
# ⚡ 2. Ultimate Performance Plan
# ===============================
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
Write-Output "✅ Ultimate Performance Power Plan enabled."

# ===============================
# 📺 3. Disable Fullscreen Optimizations + Game Bar
# ===============================
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 2
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0
Write-Output "✅ Fullscreen optimizations and Game DVR disabled."

# Remove Xbox Game Bar
Get-AppxPackage *Microsoft.XboxGamingOverlay* | Remove-AppxPackage -ErrorAction SilentlyContinue
Write-Output "✅ Xbox Game Bar removed."

# ===============================
# 🧠 4. Optimize Memory Management
# ===============================
$memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $memPath -Name "DisablePagingExecutive" -Value 1
Set-ItemProperty -Path $memPath -Name "LargeSystemCache" -Value 1
Write-Output "✅ Memory management optimized."

# ===============================
# 🌐 5. Disable Nagle’s Algorithm (Low Latency Network)
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
Write-Output "✅ Nagle’s Algorithm disabled."

# ===============================
# 🗑️ 6. Disable Startup Programs
# ===============================
Get-CimInstance Win32_StartupCommand | Where-Object {
    $_.Name -notlike "*Microsoft*" -and $_.Command -notlike "*Windows Defender*"
} | ForEach-Object {
    Write-Output "Disabling startup: $($_.Name)"
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $_.Name -ErrorAction SilentlyContinue
}
Write-Output "✅ Non-essential startup programs disabled."

# ===============================
# 👁️ 7. Optimize Visual Effects
# ===============================
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value 1
Write-Output "✅ Visual effects optimized."

# ===============================
# 🚫 8. Disable Non-Essential Services
# ===============================
$services = @("SysMain", "WSearch", "DiagTrack", "RetailDemo", "XblGameSave", "XboxNetApiSvc")
foreach ($service in $services) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled
        Write-Output "Disabled service: $service"
    }
}
Write-Output "✅ Non-essential services disabled."

# ===============================
# 🧠 9. Disable NDU (DPC Latency Fix)
# ===============================
Stop-Service -Name Ndu -Force -ErrorAction SilentlyContinue
Set-Service -Name Ndu -StartupType Disabled
Write-Output "✅ NDU disabled to reduce DPC latency."

# ===============================
# 🎮 10. Enable Hardware-Accelerated GPU Scheduling
# ===============================
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2
Write-Output "✅ Hardware-accelerated GPU scheduling enabled."

# ===============================
# ⏱️ 11. (Optional) Disable HPET via BCD
# ===============================
bcdedit /deletevalue useplatformclock > $null 2>&1
Write-Output "✅ HPET disabled (via BCDedit)."

# ===============================
# 🔁 12. Prompt for Restart
# ===============================
$restart = Read-Host "`nChanges applied successfully. Restart now? (Y/N)"
if ($restart -match "^[Yy]$") {
    Restart-Computer
}
