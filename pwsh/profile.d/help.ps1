

function Help-Command {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $commandDocs = @{
        "resolve-git-conflict" = @{
            Description = "Guides you through resolving merge conflicts interactively."
            Example = "fix-merge"
        }
        "sync-git-branch" = @{
            Description = "Syncs your current branch with 'main' or 'master', including stashing and reapplying changes."
            Example = "gsync"
        }
        "rebase-interactive" = @{
            Description = "Starts an interactive rebase for the last N commits."
            Example = "rebase 3"
        }
        "Show-Help" = @{
            Description = "Displays a list of all available custom PowerShell functions."
            Example = "Show-Help"
        }
        "rebase-f" = @{
            Description = "Rebases a feature branch onto a target branch and force-pushes the result."
            Example     = "rebase-f -t main -f my-feature-branch"
        }

    }

    if ($commandDocs.ContainsKey($Name)) {
        $info = $commandDocs[$Name]
        Write-Host "`n$($PSStyle.Foreground.Green)$Name`n$($PSStyle.Reset)------------------------"
        Write-Host "$($PSStyle.Foreground.Yellow)Description:$($PSStyle.Reset) $($info.Description)"
        Write-Host "$($PSStyle.Foreground.Yellow)Example:    $($PSStyle.Reset) $($info.Example)`n"
    } else {
        Write-Host "$($PSStyle.Foreground.Red)No help found for '$Name'.$($PSStyle.Reset)"
    }
}

function Show-Help {
    $helpText = @"
$($PSStyle.Foreground.Cyan)PowerShell Profile Help$($PSStyle.Reset)
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)

$($PSStyle.Foreground.Green)Profile Management:$($PSStyle.Reset)
Update-Profile$($PSStyle.Reset) - Updates PowerShell profile from the remote repository
Update-PowerShell$($PSStyle.Reset) - Updates PowerShell to the latest version
Edit-Profile (ep)$($PSStyle.Reset) - Opens profile in default editor
reload-profile$($PSStyle.Reset) - Reloads the current PowerShell profile

$($PSStyle.Foreground.Green)File Operations:$($PSStyle.Reset)
touch <file>$($PSStyle.Reset) - Creates an empty file
ff$($PSStyle.Reset) - Fuzzy finds files and opens in VS Code
folder <name>$($PSStyle.Reset) - Creates a new directory with specified name and changes to it
nf <name>$($PSStyle.Reset) - Creates a new file with specified name
unzip <file>$($PSStyle.Reset) - Extracts zip file to current directory
hb <file>$($PSStyle.Reset) - Uploads file content to hastebin and returns URL
mkcd <dir>$($PSStyle.Reset) - Creates and changes to a new directory
trash <path>$($PSStyle.Reset) - Moves file/folder to recycle bin
file-action <from> <to> <method>$($PSStyle.Reset) - Copies or moves a file based on the selected method

$($PSStyle.Foreground.Green)Git Operations:$($PSStyle.Reset)
sync-git-branch (gsync)$($PSStyle.Reset) - Syncs current branch with main/master
resolve-git-conflict (fix-merge)$($PSStyle.Reset) - Interactive merge conflict resolver
gs$($PSStyle.Reset) - Shows git status
ga$($PSStyle.Reset) - Stages all changes (git add .)
gc <message>$($PSStyle.Reset) - Commits with message
gp$($PSStyle.Reset) - Pushes to remote
g$($PSStyle.Reset) - Changes to GitHub directory
gcl <url>$($PSStyle.Reset) - Clones a repository
gcom <message>$($PSStyle.Reset) - Adds all changes and commits
lazyg <message>$($PSStyle.Reset) - Adds, commits, and pushes changes

$($PSStyle.Foreground.Green)System Operations:$($PSStyle.Reset)
Clear-Cache$($PSStyle.Reset) - Clears various Windows caches
Get-PubIP$($PSStyle.Reset) - Shows public IP address
winutil$($PSStyle.Reset) - Launches Windows utility toolkit
admin (su)$($PSStyle.Reset) - Runs command with admin privileges
uptime$($PSStyle.Reset) - Shows system uptime
sysinfo$($PSStyle.Reset) - Shows detailed system information
flushNetwork$($PSStyle.Reset) - Clears DNS cache, and network reset

$($PSStyle.Foreground.Green)Directory Navigation:$($PSStyle.Reset)
docs$($PSStyle.Reset) - Changes to Documents folder
dtop$($PSStyle.Reset) - Changes to Desktop folder
la$($PSStyle.Reset) - Lists all files with details
ll$($PSStyle.Reset) - Lists all files including hidden

$($PSStyle.Foreground.Green)Process Management:$($PSStyle.Reset)
k9 <name>$($PSStyle.Reset) - Stops process by name
pkill <name>$($PSStyle.Reset) - Stops process by name
pgrep <name>$($PSStyle.Reset) - Lists processes by name

$($PSStyle.Foreground.Green)File Content Operations:$($PSStyle.Reset)
grep <regex> [dir]$($PSStyle.Reset) - Searches for pattern in files
sed <file> <find> <replace>$($PSStyle.Reset) - Replaces text in file
head <path> [n]$($PSStyle.Reset) - Shows first n lines (default 10)
tail <path> [n] [-f]$($PSStyle.Reset) - Shows last n lines (default 10)

$($PSStyle.Foreground.Green)Clipboard Operations:$($PSStyle.Reset)
cpy <text>$($PSStyle.Reset) - Copies text to clipboard
pst$($PSStyle.Reset) - Pastes from clipboard

$($PSStyle.Foreground.Green)System Information:$($PSStyle.Reset)
which <name>$($PSStyle.Reset) - Shows command path
df$($PSStyle.Reset) - Shows volume information
export <name> <value>$($PSStyle.Reset) - Sets environment variable




Use '$($PSStyle.Foreground.Magenta)Show-Help$($PSStyle.Reset)' to display this help message again.
"@
Write-Host $helpText
}
