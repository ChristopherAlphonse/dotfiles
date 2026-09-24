

function rebase-interactive {
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

function resolve-git-conflict {
    if (-not (Test-Path .git)) {
        Write-Host "Error: Not a git repository" -ForegroundColor Red
        return
    }

    $conflictedFiles = git diff --name-only --diff-filter=U

    if (-not $conflictedFiles) {
        Write-Host "No merge conflicts found." -ForegroundColor Green
        return
    }

    Write-Host "Files with merge conflicts:" -ForegroundColor Yellow
    $index = 1
    $fileList = @()

    foreach ($file in $conflictedFiles) {
        Write-Host "$index`: $file" -ForegroundColor Cyan
        $fileList += $file
        $index++
    }

    do {
        $choice = Read-Host "`nEnter the number of the file to resolve (or 'q' to quit)"

        if ($choice -eq 'q') {
            return
        }

        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $fileList.Count) {
            $selectedFile = $fileList[$choice - 1]

            Write-Host "Opening $selectedFile in $EDITOR..." -ForegroundColor Yellow
            & $EDITOR $selectedFile

            $resolveChoice = Read-Host "Has the conflict been resolved? (y/n)"
            if ($resolveChoice -eq 'y') {
                git add $selectedFile
                Write-Host "File marked as resolved: $selectedFile" -ForegroundColor Green
            }
        } else {
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
        }

        $conflictedFiles = git diff --name-only --diff-filter=U
    } while ($conflictedFiles)

    Write-Host "`nAll conflicts have been resolved!" -ForegroundColor Green
    Write-Host "You can now continue with your merge by running 'git commit'" -ForegroundColor Yellow
}

function sync-git-branch {
    $currentBranch = git rev-parse --abbrev-ref HEAD

    if ($currentBranch -eq "main" -or $currentBranch -eq "master") {
        Write-Host "Already on main/master branch. Just pulling latest changes..." -ForegroundColor Yellow
        git pull
        return
    }

    Write-Host "Current branch: $currentBranch" -ForegroundColor Cyan
    Write-Host "Stashing any uncommitted changes..." -ForegroundColor Yellow
    git stash push -m "sync-git-branch automatic stash"

    Write-Host "Switching to main branch and pulling latest changes..." -ForegroundColor Yellow

    if (git branch --list main) {
        $branchToSync = "main"
    } elseif (git branch --list master) {
        $branchToSync = "master"
    } else {
        Write-Host "Error: Neither 'main' nor 'master' branches exist." -ForegroundColor Red
        return
    }

    Write-Host "Using '$branchToSync' as the base branch." -ForegroundColor Cyan

    git checkout $branchToSync
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Could not switch to $branchToSync branch" -ForegroundColor Red
        return
    }

    git pull
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Could not pull latest changes from $branchToSync" -ForegroundColor Red
        git checkout $currentBranch
        return
    }

    Write-Host "Switching back to $currentBranch..." -ForegroundColor Yellow
    git checkout $currentBranch

    $stashList = git stash list | Select-String "sync-git-branch automatic stash"
    if ($stashList) {
        Write-Host "Reapplying stashed changes..." -ForegroundColor Yellow
        git stash pop
    }

    Write-Host "Pushing changes to $currentBranch..." -ForegroundColor Yellow
    git push

    Write-Host "Branch synchronization complete!" -ForegroundColor Green
}

function gs { git status }
function ga { git add . }
function gc { param($m) git commit -m "$m" }
function gp { git push }
function gcl { param($url) git clone "$url" }
function gcom { param($args) git add .; git commit -m "$args" }
function lazyg { param($args) git add -p; git commit -m "$args"; git push }

# Shortcut to jump to GitHub workspace using zoxide (moved from main profile)
function g { __zoxide_z github }

function rebase-f {
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

# Short-hand for 'git switch <branch>'
function gsw { git switch @args }
