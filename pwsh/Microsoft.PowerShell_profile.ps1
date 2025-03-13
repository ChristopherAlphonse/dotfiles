Import-Module Terminal-Icons
Import-Module PSFzf


oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\sonicboom_dark.omp.json" | Invoke-Expression

[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

 function touch { param([string]$file); "" | Out-File $file -Encoding ASCII }


$modulesToLoad = @("posh-git", "PowerShellGet", "Terminal-Icons", "PSFzf")

foreach ($module in $modulesToLoad) {
    if (-not (Get-Module -Name $module -ListAvailable)) {
        Import-Module -Name $module -ErrorAction SilentlyContinue
    }
}

$env:FZF_DEFAULT_OPTS = " --height 100% --layout reverse --border"

function ff {
    $file = fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"
    if ($file) {
        code $file
    }
}

function Update-Packages {
    param (
        [switch]$Winget,
        [switch]$Chocolatey,
        [switch]$Pip
    )


    function Test-Command {
        param ($Command)
        $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
    }


    if ($Winget -or (-not $Chocolatey -and -not $Pip)) {
        if (Test-Command "winget") {
            Write-Host "Updating packages with Winget..."
            winget upgrade --all --silent
        } else {
            Write-Warning "Winget not found."
        }
    }


    if ($Chocolatey -or (-not $Winget -and -not $Pip)) {
        if (Test-Command "choco") {
            Write-Host "Updating packages with Chocolatey..."
            choco upgrade all -y
        } else {
            Write-Warning "Chocolatey not found."
        }
    }


    if ($Pip -or (-not $Winget -and -not $Chocolatey)) {
        if (Test-Command "pip") {
            Write-Host "Updating packages with Pip..."
            pip list --outdated --format=json | ConvertFrom-Json | ForEach-Object {
                pip install --upgrade $_.name
            }
        } else {
            Write-Warning "Pip not found."
        }
    }
}



$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"


function atob {
    param([string]$userInput)
    try {
        [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($userInput))
    } catch {
        Write-Error "Invalid Base64 string."
    }
}


Set-Alias -Name search -Value find-file
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name ls -Value Get-ChildItem



if (-not (Get-Module -Name PSFzf -ListAvailable)) {
    Install-Module -Name PSFzf -Force -ErrorAction SilentlyContinue
}
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'



function admin {
    Start-Process wt.exe -Verb RunAs
}


function lazyg {
    param([string]$commitMessage)
    git pull; git add .; git commit -m $commitMessage; git push
}

function gsw {
    param(
        [string]$branchName,
        [switch]$Create
    )
    try {
        $localBranch = git branch --list $branchName | ForEach-Object { $_.Trim() }
        $remoteBranch = git ls-remote --heads origin $branchName | ForEach-Object { $_.Trim() }

        if ($localBranch -or $remoteBranch) {
            if ($Create) {
                Write-Error "Branch '$branchName' already exists."
                return
            }
            git switch $branchName
        } else {
            if ($Create) {
                git switch -c $branchName
            } else {
                git switch --track origin/$branchName
            }
        }
    } catch {
        Write-Error "Error: $_"
    }
}



Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -HistoryNoDuplicates:$true
Set-PSReadLineOption -PredictionViewStyle ListView


function lazy-load-utilities {
    function unzip { param([string]$file); Expand-Archive -Path $file -DestinationPath $pwd -Force }

    function pkill { param([string]$name); Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process }

function rebase-f {
    param(
        [Parameter(Mandatory = $true)]
        [string]$t,

        [Parameter(Mandatory = $true)]
        [string]$f
    )

    try {

        git switch $t
        Write-Output "Switched to branch '$t'."


        git fetch
        Write-Output "Fetched updates from remote."


        git switch $f
        Write-Output "Switched to branch '$f'."


        git rebase $t
        Write-Output "Rebased '$f' onto '$t'."


        while ($LASTEXITCODE -ne 0) {
            Write-Host "Rebase conflict detected. Resolve conflicts, then run 'git rebase --continue'."
            pause
            git rebase --continue
        }


        git push -f
        Write-Output "Force-pushed branch '$f' to the remote."
    } catch {
        Write-Error "An error occurred: $_"
    }
}

function rebase-i{
    param(
        [Parameter(Mandatory = $true)]
        [int]$count
    )

    try {

        git rebase -i HEAD~$count
        Write-Output "Interactive rebase started for the last $count commits."
    } catch {
        Write-Error "An error occurred while attempting the interactive rebase: $_"
    }
}

Set-Alias -Name touch -Value New-Item
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name folder -Value mkdir
Set-Alias -Name g -Value git
Set-Alias -Name gs -Value "git status"
Set-Alias -Name ga -Value "git add"
Set-Alias -Name h -Value "Get-History"
Set-Alias -Name c -Value "Clear-Host"
Set-Alias -Name be -Value "bundle exec"
Set-Alias grep findstr

}
lazy-load-utilities

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
