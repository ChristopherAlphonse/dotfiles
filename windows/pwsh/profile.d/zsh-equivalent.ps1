# PowerShell equivalent of macos/zsh/.zshrc
# Skipped (zsh/macOS-only): oh-my-zsh, zinit, p10k, homebrew, compinit/zstyle, fzf-tab, trash/batcat aliases.
# Prompt (oh-my-posh), zoxide and fzf are handled by the main profile.

if ($Host.Name -ne 'ConsoleHost') { return }

# --------------------------------------------------
# Environment & PATH
# --------------------------------------------------
$env:EDITOR = 'code'
$env:VISUAL = 'code'

function Add-PathEntry([string]$Dir) {
    if ((Test-Path $Dir) -and (($env:PATH -split ';') -notcontains $Dir)) { $env:PATH = "$Dir;$env:PATH" }
}
Add-PathEntry "$HOME\.local\bin"
Add-PathEntry "$HOME\.cargo\bin"
$env:BUN_INSTALL = "$HOME\.bun"
Add-PathEntry "$env:BUN_INSTALL\bin"
Add-PathEntry "$(if ($env:ASDF_DATA_DIR) { $env:ASDF_DATA_DIR } else { "$HOME\.asdf" })\shims"

# --------------------------------------------------
# History / behavior (zsh-autosuggestions + syntax-highlighting + history setopts)
# --------------------------------------------------
if (Get-Module -ListAvailable PSReadLine) {
    Set-PSReadLineOption -MaximumHistoryCount 5000 -HistoryNoDuplicates:$true -HistorySearchCursorMovesToEnd -BellStyle None
    try { Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView -ErrorAction Stop } catch { }
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# --------------------------------------------------
# Aliases (built-in aliases that collide with zsh names are replaced, as zsh does)
# --------------------------------------------------
function Set-ForcedFunction([string]$Name, [scriptblock]$Body) {
    if (Test-Path "Alias:$Name") { Remove-Item "Alias:$Name" -Force -ErrorAction SilentlyContinue }
    Set-Item -Path "Function:global:$Name" -Value $Body
}

# Navigation
function global:.. { Set-Location .. }
function global:... { Set-Location ..\.. }
function global:.... { Set-Location ..\..\.. }
function global:bd { Set-Location - }
function global:mkdirg { param([Parameter(Mandatory)][string]$Path) New-Item -ItemType Directory -Force $Path | Out-Null; Set-Location $Path }
function global:up { param([int]$n = 1) Set-Location (('..\' * $n).TrimEnd('\')) }

# Clear
Set-ForcedFunction c { Clear-Host }

# Git (gc/gp collide with Get-Content/Get-ItemProperty aliases)
Set-ForcedFunction gs { git status @args }
Set-ForcedFunction ga { git add @args }
Set-ForcedFunction gc { git commit @args }
Set-ForcedFunction gp { git push @args }
Set-ForcedFunction gw { git switch @args }

# Search
function global:h { param([string]$Pattern) Get-History | Where-Object CommandLine -Match $Pattern }
function global:p { param([string]$Pattern) Get-Process | Where-Object ProcessName -Match $Pattern }
function global:f { param([string]$Pattern) Get-ChildItem -Recurse -ErrorAction SilentlyContinue | Where-Object FullName -Match $Pattern | Select-Object -ExpandProperty FullName }

# Utilities
function global:diskspace { Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{n='UsedGB';e={[math]::Round($_.Used/1GB,1)}}, @{n='FreeGB';e={[math]::Round($_.Free/1GB,1)}} }
function global:topcpu { Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 CPU, Id, ProcessName }
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-ForcedFunction vi { nvim @args }
    Set-ForcedFunction vim { nvim @args }
}
if (Get-Command kiro-cli -ErrorAction SilentlyContinue) {
    function global:kiro { kiro-cli --v3 @args }
    function global:krio { kiro-cli --v3 @args }
}

# --------------------------------------------------
# Functions
# --------------------------------------------------
function global:gcom { param([Parameter(Mandatory)][string]$Message) git add .; git commit -m $Message }
function global:lazyg { param([Parameter(Mandatory)][string]$Message) git add .; git commit -m $Message; git push }

function global:curl_time {
    curl.exe -so NUL -w "   namelookup:  %{time_namelookup}s`n      connect:  %{time_connect}s`n   appconnect:  %{time_appconnect}s`n  pretransfer:  %{time_pretransfer}s`n     redirect:  %{time_redirect}s`nstarttransfer:  %{time_starttransfer}s`n        idle:  %{time_idle}s`n-------------------------`n        total:  %{time_total}s`n" @args
}

function global:update-all-repos {
    Get-ChildItem -Directory -Recurse -Force -Filter .git -ErrorAction SilentlyContinue | ForEach-Object {
        $repo = $_.Parent.FullName
        Write-Host "Updating $repo"
        git -C $repo pull origin main
    }
}

function global:awsCheck {
    $script = Join-Path $HOME 'Desktop\dotfiles\shared\aws\aws-check-login.sh'
    if (Get-Command bash -ErrorAction SilentlyContinue) { bash $script @args } else { Write-Warning 'bash not found (install Git for Windows)' }
}

# format: run whatever formatters apply to the current project
function global:format {
    $ran = $false
    $has = { param($c) [bool](Get-Command $c -ErrorAction SilentlyContinue) }
    $find = { param($pat) Get-ChildItem -Recurse -Depth 3 -File -Filter $pat -ErrorAction SilentlyContinue | Where-Object FullName -NotMatch '\\(node_modules|\.venv|\.git)\\' }

    if ((Test-Path .pre-commit-config.yaml) -and (& $has pre-commit)) { Write-Host '==> pre-commit'; pre-commit run --all-files; $ran = $true }
    if ((& $has terraform) -and (& $find '*.tf' | Select-Object -First 1)) { Write-Host '==> terraform fmt'; terraform fmt -recursive; $ran = $true }
    if (& $has dotnet) {
        $sln = & $find '*.sln' | Select-Object -First 1
        if ($sln) { Write-Host "==> dotnet format ($($sln.FullName))"; dotnet format $sln.FullName; $ran = $true }
        else { foreach ($p in (& $find '*.csproj')) { Write-Host "==> dotnet format ($($p.FullName))"; dotnet format $p.FullName; $ran = $true } }
    }
    if ((Test-Path package.json) -and (& $has npx)) {
        npx --no-install prettier -v *> $null
        if ($LASTEXITCODE -eq 0) { Write-Host '==> prettier'; npx --no-install prettier --write .; $ran = $true }
    }
    $hasPy = (Test-Path pyproject.toml) -or (& $find '*.py' | Select-Object -First 1)
    if ((& $has ruff) -and $hasPy) { Write-Host '==> ruff format'; ruff format .; $ran = $true }
    elseif ((& $has black) -and $hasPy) { Write-Host '==> black'; black .; $ran = $true }
    if ((& $has gofmt) -and (& $find '*.go' | Select-Object -First 1)) { Write-Host '==> gofmt'; gofmt -w .; $ran = $true }

    if (-not $ran) { Write-Host "format: no known formatter applies to $(Get-Location)" }
}

# runtests: run whatever test runners apply to the current project
function global:runtests {
    $ran = $false; $failed = $false
    $has = { param($c) [bool](Get-Command $c -ErrorAction SilentlyContinue) }
    $find = { param($pat) Get-ChildItem -Recurse -Depth 3 -File -Filter $pat -ErrorAction SilentlyContinue | Where-Object FullName -NotMatch '\\(node_modules|\.venv|\.worktrees|\.git)\\' }

    if ((& $has terraform) -and (& $find '*.tftest.hcl' | Select-Object -First 1)) {
        Write-Host '==> terraform test'; terraform test; if ($LASTEXITCODE) { $failed = $true }; $ran = $true
    }
    if (& $has dotnet) {
        $sln = & $find '*.sln' | Select-Object -First 1
        if ($sln) { Write-Host "==> dotnet test ($($sln.FullName))"; dotnet test $sln.FullName; if ($LASTEXITCODE) { $failed = $true }; $ran = $true }
        else {
            foreach ($p in (& $find '*.csproj' | Where-Object { Select-String -Path $_.FullName -Pattern 'Microsoft.NET.Test.Sdk' -Quiet })) {
                Write-Host "==> dotnet test ($($p.FullName))"; dotnet test $p.FullName; if ($LASTEXITCODE) { $failed = $true }; $ran = $true
            }
        }
    }
    if ((Test-Path package.json) -and (& $has npm)) {
        $t = npm pkg get scripts.test 2>$null
        if ($t -and $t -ne '{}') { Write-Host '==> npm test'; npm test; if ($LASTEXITCODE) { $failed = $true }; $ran = $true }
    }
    if (((& $find 'test_*.py') + (& $find '*_test.py')) | Select-Object -First 1) {
        if ((Test-Path uv.lock) -and (& $has uv)) { Write-Host '==> uv run pytest'; uv run pytest; if ($LASTEXITCODE) { $failed = $true }; $ran = $true }
        elseif (& $has pytest) { Write-Host '==> pytest'; pytest; if ($LASTEXITCODE) { $failed = $true }; $ran = $true }
    }
    if ((& $has go) -and (Test-Path go.mod)) { Write-Host '==> go test'; go test ./...; if ($LASTEXITCODE) { $failed = $true }; $ran = $true }

    if (-not $ran) { Write-Host "runtests: no known test runner applies to $(Get-Location)" }
    if ($failed) { $global:LASTEXITCODE = 1 }
}
