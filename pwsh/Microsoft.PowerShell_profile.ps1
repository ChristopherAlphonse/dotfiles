
$komorebicProcess = Get-Process -Name "komorebi" -ErrorAction SilentlyContinue
if (-not $komorebicProcess) {
    try {
        Write-Host "Starting komorebi..." -ForegroundColor Green
        komorebic start
    }
    catch {
        Write-Warning "Failed to start komorebi: $($_.Exception.Message)"
    }
}
else {
    Write-Host "Komorebi is already running" -ForegroundColor Yellow
}

$debug = $false

# Define the path to the file that stores the last execution time
$timeFilePath = "$env:USERPROFILE\Documents\PowerShell\LastExecutionTime.txt"

# Define the update interval in days, set to -1 to always check
$updateInterval = [math]::truncate(365 /  2)

if ($debug) {
    Write-Host "#######################################" -ForegroundColor Red
    Write-Host "#           Debug mode enabled        #" -ForegroundColor Red
    Write-Host "#          ONLY FOR DEVELOPMENT       #" -ForegroundColor Red
    Write-Host "#                                     #" -ForegroundColor Red
    Write-Host "#       IF YOU ARE NOT DEVELOPING     #" -ForegroundColor Red
    Write-Host "#       JUST RUN \`Update-Profile\`     #" -ForegroundColor Red
    Write-Host "#        to discard all changes       #" -ForegroundColor Red
    Write-Host "#   and update to the latest profile  #" -ForegroundColor Red
    Write-Host "#               version               #" -ForegroundColor Red
    Write-Host "#######################################" -ForegroundColor Red
}



#opt-out of telemetry before doing anything, only if PowerShell is run as admin
if ([bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsSystem) {
    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
}

# Initial GitHub.com connectivity check with 1 second timeout
$global:canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1

# Import Modules and External Profiles
# Ensure Terminal-Icons module is installed before importing
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# fzf (Fuzzy Finder) Configuration
# Set fzf default options for better PowerShell integration
$env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --info=inline'
$env:FZF_DEFAULT_COMMAND = 'Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { !$_.PSIsContainer } | Select-Object -ExpandProperty FullName'

# fzf functions for PowerShell
function Invoke-FuzzyEdit {
    param([string]$Filter = "")
    $file = if ($Filter) { fzf --query $Filter } else { fzf }
    if ($file) {
        code $file
    }
}

function Invoke-FuzzyCd {
    param([string]$Filter = "")
    $dir = if ($Filter) { Get-ChildItem -Directory | Select-Object -ExpandProperty Name | fzf --query $Filter } else { Get-ChildItem -Directory | Select-Object -ExpandProperty Name | fzf }
    if ($dir) {
        Set-Location $dir
    }
}

function Invoke-FuzzyHistory {
    $command = Get-History | Select-Object -ExpandProperty CommandLine | fzf
    if ($command) {
        $command | Set-Clipboard
        Write-Host "Command copied to clipboard: $command" -ForegroundColor Green
    }
}

# fzf aliases moved to profile.d/aliases.ps1





# Check for Profile Updates
<#
.SYNOPSIS
Updates the PowerShell profile from the remote repository.
.DESCRIPTION
Downloads the latest version of the PowerShell profile from GitHub and updates the local copy if changes are detected.
.NOTES
Requires internet connectivity to GitHub.com
#>
function Update-Profile {
    try {
        $url = "https://raw.githubusercontent.com/ChristopherAlphonse/dotfiles/refs/heads/master/pwsh/Microsoft.PowerShell_profile.ps1"

        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else {
            Write-Host "Profile is up to date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Unable to check for `$profile updates: $_"
    } finally {
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}

# Check if not in debug mode AND (updateInterval is -1 OR file doesn't exist OR time difference is greater than the update interval)
if (-not $debug -and `
    ($updateInterval -eq -1 -or `
      -not (Test-Path $timeFilePath) -or `
      ((Get-Date) - [datetime]::ParseExact((Get-Content -Path $timeFilePath), 'yyyy-MM-dd', $null)).TotalDays -gt $updateInterval)) {

    Update-Profile
    $currentTime = Get-Date -Format 'yyyy-MM-dd'
    $currentTime | Out-File -FilePath $timeFilePath

} elseif (-not $debug) {
    Write-Warning "Profile update skipped. Last update check was within the last $updateInterval day(s)."
} else {
    Write-Warning "Skipping profile update check in debug mode"
}

<#
.SYNOPSIS
Updates PowerShell to the latest version.
.DESCRIPTION
Checks GitHub API for the latest PowerShell release and updates if a newer version is available.
.NOTES
Requires winget package manager and internet connectivity.
#>
function Update-PowerShell {
    try {
        Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
        $updateNeeded = $false
        $currentVersion = $PSVersionTable.PSVersion.ToString()
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
        if ($currentVersion -lt $latestVersion) {
            $updateNeeded = $true
        }

        if ($updateNeeded) {
            Write-Host "Updating PowerShell..." -ForegroundColor Yellow
            Start-Process powershell.exe -ArgumentList "-NoProfile -Command winget upgrade Microsoft.PowerShell --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
            Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else {
            Write-Host "Your PowerShell is up to date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to update PowerShell. Error: $_"
    }
}

# skip in debug mode
# Check if not in debug mode AND (updateInterval is -1 OR file doesn't exist OR time difference is greater than the update interval)
# if (-not $debug -and `
#     ($updateInterval -eq -1 -or `
#      -not (Test-Path $timeFilePath) -or `
#      ((Get-Date).Date - [datetime]::ParseExact((Get-Content -Path $timeFilePath), 'yyyy-MM-dd', $null).Date).TotalDays -gt $updateInterval)) {

#     Update-PowerShell
#     $currentTime = Get-Date -Format 'yyyy-MM-dd'
#     $currentTime | Out-File -FilePath $timeFilePath
#       } else {
#     Write-Warning "Skipping PowerShell update in debug mode"
# }

<#
.SYNOPSIS
Clears various Windows system caches.
.DESCRIPTION
Cleans Windows Prefetch, Temp folders, and IE cache to free up disk space.
.NOTES
Requires admin rights for some operations.
#>
function Clear-Cache {
    Write-Host "Clearing cache..." -ForegroundColor Cyan

    # Clear Windows Prefetch
    Write-Host "Clearing Windows Prefetch..." -ForegroundColor Yellow
    Remove-Item -Path "$env:SystemRoot\Prefetch\*" -Force -ErrorAction SilentlyContinue

    # Clear Windows Temp
    Write-Host "Clearing Windows Temp..." -ForegroundColor Yellow
    Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Clear User Temp
    Write-Host "Clearing User Temp..." -ForegroundColor Yellow
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Clear Internet Explorer Cache
    Write-Host "Clearing Internet Explorer Cache..." -ForegroundColor Yellow
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "Cache clearing completed." -ForegroundColor Green
}

# Admin Check and Prompt Customization
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
function prompt {
    if ($isAdmin) { "[" + (Get-Location) + "] # " } else { "[" + (Get-Location) + "] $ " }
}
$adminSuffix = if ($isAdmin) { " [ADMIN]" } else { "" }
$Host.UI.RawUI.WindowTitle = "PowerShell {0}$adminSuffix" -f $PSVersionTable.PSVersion.ToString()

<#
.SYNOPSIS
Tests if a command exists in the system.
.DESCRIPTION
Checks if a command is available in the current PowerShell session.
.PARAMETER command
The name of the command to check.
.OUTPUTS
Boolean. True if command exists, false otherwise.
#>
function Test-CommandExists {
    param($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

# Editor Configuration
$EDITOR = if (Test-CommandExists nvim) { 'nvim' }
          elseif (Test-CommandExists code) { 'code' }
          else { 'notepad' }
          # Quick Access to Editing the Profile
<#
.SYNOPSIS
Creates an empty file.
.DESCRIPTION
Creates a new empty file at the specified path.
.PARAMETER file
The path of the file to create.
#>
function touch($file) { "" | Out-File $file -Encoding ASCII }

<#
.SYNOPSIS
Fuzzy finds and opens files in VS Code.
.DESCRIPTION
Uses fzf for fuzzy file search and opens selected file in Visual Studio Code.
.NOTES
Requires fzf and bat to be installed.
#>
function ff {
    $file = fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"
    if ($file) {
        code $file
    }
}

<#
.SYNOPSIS
Gets the public IP address.
.DESCRIPTION
Retrieves the public IP address of the current machine using ifconfig.me.
.OUTPUTS
String. The public IP address.
#>
function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# Open WinUtil full-release
function winutil {
    irm https://christitus.com/win | iex
}

# System Utilities
function admin {
    if ($args.Count -gt 0) {
        $argList = $args -join ' '
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}

function uptime {
    try {
        # check powershell version
        if ($PSVersionTable.PSVersion.Major -eq 5) {
            $lastBoot = (Get-WmiObject win32_operatingsystem).LastBootUpTime
            $bootTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($lastBoot)
        } else {
            $lastBootStr = net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
            # check date format
            if ($lastBootStr -match '^\d{2}/\d{2}/\d{4}') {
                $dateFormat = 'dd/MM/yyyy'
            } elseif ($lastBootStr -match '^\d{2}-\d{2}-\d{4}') {
                $dateFormat = 'dd-MM-yyyy'
            } elseif ($lastBootStr -match '^\d{4}/\d{2}/\d{2}') {
                $dateFormat = 'yyyy/MM/dd'
            } elseif ($lastBootStr -match '^\d{4}-\d{2}-\d{2}') {
                $dateFormat = 'yyyy-MM-dd'
            } elseif ($lastBootStr -match '^\d{2}\.\d{2}\.\d{4}') {
                $dateFormat = 'dd.MM.yyyy'
            }

            # check time format
            if ($lastBootStr -match '\bAM\b' -or $lastBootStr -match '\bPM\b') {
                $timeFormat = 'h:mm:ss tt'
            } else {
                $timeFormat = 'HH:mm:ss'
            }

            $bootTime = [System.DateTime]::ParseExact($lastBootStr, "$dateFormat $timeFormat", [System.Globalization.CultureInfo]::InvariantCulture)
        }

        # Format the start time
        ### $formattedBootTime = $bootTime.ToString("dddd, MMMM dd, yyyy HH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture)
        $formattedBootTime = $bootTime.ToString("dddd, MMMM dd, yyyy HH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture) + " [$lastBootStr]"
        Write-Host "System started on: $formattedBootTime" -ForegroundColor DarkGray

        # calculate uptime
        $uptime = (Get-Date) - $bootTime

        # Uptime in days, hours, minutes, and seconds
        $days = $uptime.Days
        $hours = $uptime.Hours
        $minutes = $uptime.Minutes
        $seconds = $uptime.Seconds

        # Uptime output
        Write-Host ("Uptime: {0} days, {1} hours, {2} minutes, {3} seconds" -f $days, $hours, $minutes, $seconds) -ForegroundColor Blue


    } catch {
        Write-Error "An error occurred while retrieving system uptime."
    }
}

function reload-profile {
    & $profile
}

# Test (safe, commented): run this manually to verify the profile loads in a fresh pwsh process
# pwsh -NoProfile -Command ". $PROFILE; Write-Host 'Profile loaded OK'"

function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}

function df {
    get-volume
}



function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}


function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
    Get-Process $name
}

function head {
    param($Path, $n = 10)
    Get-Content $Path -Head $n
}

function tail {
    param($Path, $n = 10, [switch]$f = $false)
    Get-Content $Path -Tail $n -Wait:$f
}

# Quick File Creation
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name }

# Directory Management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }


function folder {param($name) mkdir  $name -Force; Set-Location $name }

function trash($path) {
    $fullPath = (Resolve-Path -Path $path).Path

    if (Test-Path $fullPath) {
        $item = Get-Item $fullPath

        if ($item.PSIsContainer) {
            # Handle directory
            $parentPath = $item.Parent.FullName
        } else {
            # Handle file
            $parentPath = $item.DirectoryName
        }

        $shell = New-Object -ComObject 'Shell.Application'
        $shellItem = $shell.NameSpace($parentPath).ParseName($item.Name)

        if ($item) {
            $shellItem.InvokeVerb('delete')
            Write-Host "Item '$fullPath' has been moved to the Recycle Bin."
        } else {
            Write-Host "Error: Could not find the item '$fullPath' to trash."
        }
    } else {
        Write-Host "Error: Item '$fullPath' does not exist."
    }
}

# Git helper functions moved to profile.d/git.ps1
<#
Note: all git helper functions (rebase-interactive, resolve-git-conflict, sync-git-branch,
gs, ga, gc, gp, gcl, gcom, lazyg, rebase-f, etc.) have been moved to:
	%c\Users\%USERNAME%\Documents\PowerShell\profile.d\git.ps1

Remove this comment and edit profile.d/git.ps1 to update the git helpers.
#>
function rebase-f {
<#
.SYNOPSIS
    Rebases one Git branch onto another with automatic switching and force-push.

.DESCRIPTION
    This function switches to the target branch to fetch the latest updates,
    then switches back to the feature branch and rebases it onto the target.
    If there are conflicts during rebase, the user is prompted to resolve them manually.
    After a successful rebase, the function force-pushes the rebased feature branch to the remote.

.PARAMETER t
    The target branch to rebase onto (e.g., 'main').

.PARAMETER f
    The feature branch to rebase (e.g., 'feature/login').

.EXAMPLE
    rebase-f -t main -f feature/login

    This will:
    - Switch to 'main'
    - Fetch latest changes
    - Switch to 'feature/login'
    - Rebase it onto 'main'
    - Force push the updated feature branch

.NOTES
    Useful for cleaning up commit history before merging a feature branch.
#>
    param(
        [Parameter(Mandatory = $true)]
        [string]$t,

        [Parameter(Mandatory = $true)]
        [string]$f
    )

    try {
        Write-Host "`n Switching to target branch '$t'..." -ForegroundColor Cyan
        git switch $t
        if ($LASTEXITCODE -ne 0) { throw "Could not switch to branch '$t'" }

        Write-Host "Fetching updates from remote..." -ForegroundColor Cyan
        git fetch
        if ($LASTEXITCODE -ne 0) { throw "Fetch failed." }

        Write-Host "Switching to feature branch '$f'..." -ForegroundColor Cyan
        git switch $f
        if ($LASTEXITCODE -ne 0) { throw "Could not switch to branch '$f'" }

        Write-Host "Rebasing '$f' onto '$t'..." -ForegroundColor Cyan
        git rebase $t

        while ($LASTEXITCODE -ne 0) {
            Write-Host "Rebase conflict detected. Please resolve conflicts and continue."
            pause
            git rebase --continue
        }

        Write-Host "Force-pushing rebased branch '$f'..." -ForegroundColor Cyan
        git push -f
        if ($LASTEXITCODE -ne 0) { throw "Force push failed." }

        Write-Host "`nBranch '$f' successfully rebased onto '$t' and force-pushed." -ForegroundColor Green
    } catch {
        Write-Error "`nError: $($_.Exception.Message)"
    }
}




function docs {
    $docs = if(([Environment]::GetFolderPath("MyDocuments"))) {([Environment]::GetFolderPath("MyDocuments"))} else {$HOME + "\Documents"}
    Set-Location -Path $docs
}

function dtop {
    $dtop = if ([Environment]::GetFolderPath("Desktop")) {[Environment]::GetFolderPath("Desktop")} else {$HOME + "\Documents"}
    Set-Location -Path $dtop
}

function k9 { Stop-Process -Name $args[0] }

function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

function g { __zoxide_z github }

function file-action {
<#
.SYNOPSIS
    Copies or moves a file based on the selected method.

.DESCRIPTION
    This function lets you specify a source path, a destination path, and a method (copy or move).
    It validates input and uses Copy-Item or Move-Item depending on the method.

.PARAMETER From
    The full path to the source file.

.PARAMETER To
    The destination path (directory or full filename).

.PARAMETER Method
    The action to perform: 'copy' or 'move'.

.EXAMPLE
    file-action -From "C:\Users\chris-desktop\.wezterm.lua" -To "." -Method copy

.EXAMPLE
    file-action -From "C:\Users\chris-desktop\.wezterm.lua" -To "." -Method move

.NOTES
    Git-style CLI helper. Shows destination using $PWD.
#>
    param(
        [Parameter(Mandatory = $true)]
        [string]$From,

        [Parameter(Mandatory = $true)]
        [string]$To,

        [Parameter(Mandatory = $true)]
        [ValidateSet("copy", "move")]
        [string]$Method
    )

    try {
        Write-Host "`nPerforming file action..." -ForegroundColor Cyan
        Write-Host "From:    $From" -ForegroundColor Yellow
        Write-Host "To:      $To" -ForegroundColor Yellow
        Write-Host "Method:  $Method" -ForegroundColor Yellow

        if (-not (Test-Path $From)) {
            throw "Source file does not exist: $From"
        }

        switch ($Method) {
            "copy" {
                Copy-Item -Path $From -Destination $To -Force
                Write-Host "`nFile successfully copied to: $($PWD.Path)\$To" -ForegroundColor Green
            }
            "move" {
                Move-Item -Path $From -Destination $To -Force
                Write-Host "`nFile successfully moved to: $($PWD.Path)\$To" -ForegroundColor Green
            }
        }
    } catch {
        Write-Error "`nError: $($_.Exception.Message)"
    }
}






function sysinfo { Get-ComputerInfo }

function flushNetwork {
    Write-Host "Starting full network reset...`n"

    try {

        ipconfig /flushdns
        Write-Host "ipconfig /flushdns completed."

        ipconfig /release
        Write-Host "ipconfig /release completed."


        ipconfig /renew
        Write-Host "ipconfig /renew completed."


        netsh int ip reset
        Write-Host "netsh int ip reset completed."


        netsh int ipv6 reset
        Write-Host "netsh int ipv6 reset completed."


        netsh winsock reset
        Write-Host "netsh winsock reset completed."


        netsh winhttp reset proxy
        Write-Host "netsh winhttp reset proxy completed."

        Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Restart-NetAdapter -Confirm:$false
        Write-Host "Active network adapters restarted."


        Restart-Service nlasvc -Force
        Write-Host "Network Location Awareness (nlasvc) restarted."


        Clear-DnsClientCache
        Write-Host "PowerShell DNS client cache cleared."


        Restart-Service dnscache -Force
        Write-Host "DNS Client (dnscache) service restarted."

        Write-Host "`nFull network reset completed successfully."
    }
    catch {
        Write-Error "An error occurred during network reset: $_"
    }
}


function cpy { Set-Clipboard $args[0] }

function pst { Get-Clipboard }

$PSReadLineOptions = @{
    EditMode = 'Windows'
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    Colors = @{
        Command = '#87CEEB'
        Parameter = '#98FB98'
        Operator = '#FFB6C1'
        Variable = '#DDA0DD'
        String = '#FFDAB9'
        Number = '#B0E0E6'
        Type = '#F0E68C'
        Comment = '#D3D3D3'
        Keyword = '#8367c7'
        Error = '#FF6347'
    }
    PredictionSource = 'History'
    PredictionViewStyle = 'ListView'
    BellStyle = 'None'
}
Set-PSReadLineOption @PSReadLineOptions

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    $hasSensitive = $sensitive | Where-Object { $line -match $_ }
    return ($null -eq $hasSensitive)
}

Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 20000

$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $customCompletions = @{
        'git' = @('status', 'add', 'commit', 'push', 'pull', 'clone', 'checkout')
        'npm' = @('install', 'start', 'run', 'test', 'build')
        'deno' = @('run', 'compile', 'bundle', 'test', 'lint', 'fmt', 'cache', 'info', 'doc', 'upgrade')
    }

    $command = $commandAst.CommandElements[0].Value
    if ($customCompletions.ContainsKey($command)) {
        $customCompletions[$command] | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
Register-ArgumentCompleter -Native -CommandName git, npm, deno -ScriptBlock $scriptblock

$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock

function Get-Theme {
    if (Test-Path -Path $PROFILE.CurrentUserAllHosts -PathType leaf) {
        $existingTheme = Select-String -Raw -Path $PROFILE.CurrentUserAllHosts -Pattern "oh-my-posh init pwsh --config"
        if ($null -ne $existingTheme) {
            Invoke-Expression $existingTheme
            return
        }
        oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/huvix.omp.json | Invoke-Expression
    } else {
        oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/huvix.omp.json | Invoke-Expression
    }
}

Get-Theme
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
} else {
    Write-Host "zoxide command not found. Attempting to install via winget..."
    try {
        winget install -e --id ajeetdsouza.zoxide
        Write-Host "zoxide installed successfully. Initializing..."
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
    } catch {
        Write-Error "Failed to install zoxide. Error: $_"
    }
}



if (Test-Path "$PSScriptRoot\custom.ps1") {
    Invoke-Expression -Command "& `"$PSScriptRoot\custom.ps1`""
}
Clear-Host


Import-Module PSReadLine -ErrorAction SilentlyContinue


Write-Host "$($PSStyle.Foreground.Yellow)Use 'Show-Help' to display help$($PSStyle.Reset)"


$profileD = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\profile.d"
if (-not (Test-Path $profileD)) {
    New-Item -ItemType Directory -Path $profileD -Force | Out-Null
}


$coreOrder = @('git.ps1','help.ps1','aliases.ps1')
foreach ($name in $coreOrder) {
    $path = Join-Path $profileD $name
    if (Test-Path $path) {
        try { . $path } catch { Write-Warning ("Failed to load {0}: {1}" -f $path, $_.Exception.Message) }
    }
}

Get-ChildItem -Path $profileD -Filter '*.ps1' | Where-Object { $coreOrder -notcontains $_.Name } | Sort-Object Name | ForEach-Object {
    try { . $_.FullName } catch { Write-Warning (("Failed to load {0}: {1}" -f $_.FullName, $_.Exception.Message)) }
}

$env:FZF_DEFAULT_OPTS = " --height 100% --layout reverse --border"
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
