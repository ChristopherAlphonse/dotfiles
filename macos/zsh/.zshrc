
# --------------------------------------------------
# Interactive Shell Only
# --------------------------------------------------
[[ -o interactive ]] || return

# --------------------------------------------------
# Environment & PATH
# --------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="simple"
plugins=(git)

export EDITOR=code
export VISUAL=code
export CLICOLOR=1

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/opt/homebrew/bin:$PATH"

# --------------------------------------------------
# Powerlevel10k Instant Prompt
# --------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --------------------------------------------------
# Homebrew
# --------------------------------------------------
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --------------------------------------------------
# Zinit Setup
# --------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Theme
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit light MichaelAquilina/zsh-you-should-use

# OMZ snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# --------------------------------------------------
# Completion
# --------------------------------------------------
autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:*' fzf-preview 'ls --color $realpath'

# --------------------------------------------------
# History
# --------------------------------------------------
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# --------------------------------------------------
# Shell Behavior
# --------------------------------------------------
setopt NO_BEEP
stty -ixon 2>/dev/null

# --------------------------------------------------
# fzf & zoxide
# --------------------------------------------------
command -v fzf >/dev/null && eval "$(fzf --zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

# --------------------------------------------------
# Aliases
# --------------------------------------------------

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias bd='cd "$OLDPWD"'
alias mkdir='mkdir -p'

# Clear
alias cls='clear'
alias c='clear'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gw='git switch'

# Safer file ops
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'

# LS
alias ls='ls -aFhG'
alias la='ls -Alh'
alias ll='ls -Fls'
alias lt='ls -ltrh'

# Search
alias h='history | grep'
alias p='ps aux | grep'
alias f='find . | grep'

# Utilities
alias tree='tree -CAhF --dirsfirst'
alias diskspace='du -S | sort -n -r | more'
alias mountedinfo='df -hT'
alias topcpu='/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10'
alias grep='/usr/bin/grep --color=auto'
alias vi='nvim'
alias vim='nvim'
alias bat='batcat'
alias kssh='kitty +kitten ssh'

# --------------------------------------------------
# Functions
# --------------------------------------------------

mkdirg() {
  mkdir -p "$1" && cd "$1"
}

up() {
  local n=${1:-1}
  cd "$(printf '../%.0s' $(seq 1 $n))"
}

reload() {
  echo "Reloading zsh configuration..."
  source ~/.zshrc
  echo "Configuration reloaded successfully!"
}

gcom() {
  git add .
  git commit -m "$1"
}

lazyg() {
  git add .
  git commit -m "$1"
  git push
}

# --------------------------------------------------
# format: run whatever formatters apply to the current project
# --------------------------------------------------
# parallelism). Ceiling: silently no-ops for formatters not listed below.
# Upgrade path: add a case/tool here, or swap to a single `pre-commit run
# --all-files` once every repo adopts it.
format() {
  local ran=0

  if [[ -f .pre-commit-config.yaml ]] && command -v pre-commit >/dev/null; then
    echo "==> pre-commit"
    pre-commit run --all-files
    ran=1
  fi

  if command -v terraform >/dev/null && { [[ -n "$(find . -maxdepth 3 -name '*.tf' -print -quit 2>/dev/null)" ]]; }; then
    echo "==> terraform fmt"
    terraform fmt -recursive
    ran=1
  fi

  if command -v dotnet >/dev/null; then
    local sln csproj
    sln="$(find . -maxdepth 3 -name '*.sln' -print -quit 2>/dev/null)"
    if [[ -n "$sln" ]]; then
      echo "==> dotnet format ($sln)"
      dotnet format "$sln"
      ran=1
    else
      for csproj in $(find . -maxdepth 3 -name '*.csproj' 2>/dev/null); do
        echo "==> dotnet format ($csproj)"
        dotnet format "$csproj"
        ran=1
      done
    fi
  fi

  if [[ -f package.json ]] && command -v npx >/dev/null && npx --no-install prettier -v >/dev/null 2>&1; then
    echo "==> prettier"
    npx --no-install prettier --write .
    ran=1
  fi

  if command -v ruff >/dev/null && { [[ -f pyproject.toml ]] || [[ -n "$(find . -maxdepth 3 -name '*.py' -print -quit 2>/dev/null)" ]]; }; then
    echo "==> ruff format"
    ruff format .
    ran=1
  elif command -v black >/dev/null && { [[ -f pyproject.toml ]] || [[ -n "$(find . -maxdepth 3 -name '*.py' -print -quit 2>/dev/null)" ]]; }; then
    echo "==> black"
    black .
    ran=1
  fi

  if command -v gofmt >/dev/null && [[ -n "$(find . -maxdepth 3 -name '*.go' -print -quit 2>/dev/null)" ]]; then
    echo "==> gofmt"
    gofmt -w .
    ran=1
  fi

  if (( ! ran )); then
    echo "format: no known formatter applies to $(pwd)"
  fi
}

# --------------------------------------------------
# runtests: run whatever test runners apply to the current project
# --------------------------------------------------
# Named runtests, not test: a `test` function would shadow the zsh builtin.
# runners not listed below. Upgrade path: add a tool here.
runtests() {
  local ran=0 failed=0

  if command -v terraform >/dev/null && [[ -n "$(find . -maxdepth 3 -name '*.tftest.hcl' -print -quit 2>/dev/null)" ]]; then
    echo "==> terraform test"
    terraform test || failed=1
    ran=1
  fi

  if command -v dotnet >/dev/null; then
    local sln csproj
    sln="$(find . -maxdepth 3 -name '*.sln' -print -quit 2>/dev/null)"
    if [[ -n "$sln" ]]; then
      echo "==> dotnet test ($sln)"
      dotnet test "$sln" || failed=1
      ran=1
    else
      for csproj in ${(f)"$(find . -maxdepth 3 -name '*.csproj' -exec grep -l 'Microsoft.NET.Test.Sdk' {} + 2>/dev/null)"}; do
        echo "==> dotnet test ($csproj)"
        dotnet test "$csproj" || failed=1
        ran=1
      done
    fi
  fi

  if [[ -f package.json ]] && command -v npm >/dev/null && [[ "$(npm pkg get scripts.test 2>/dev/null)" != "{}" ]]; then
    echo "==> npm test"
    npm test || failed=1
    ran=1
  fi

  # Only files pytest collects by default; a pyproject.toml alone may be just uv tooling.
  if [[ -n "$(find . -maxdepth 3 \( -name node_modules -o -name .venv -o -name .worktrees \) -prune -o \( -name 'test_*.py' -o -name '*_test.py' \) -print -quit 2>/dev/null)" ]]; then
    if [[ -f uv.lock ]] && command -v uv >/dev/null; then
      echo "==> uv run pytest"
      uv run pytest || failed=1
      ran=1
    elif command -v pytest >/dev/null; then
      echo "==> pytest"
      pytest || failed=1
      ran=1
    fi
  fi

  if command -v go >/dev/null && [[ -f go.mod ]]; then
    echo "==> go test"
    go test ./... || failed=1
    ran=1
  fi

  if (( ! ran )); then
    echo "runtests: no known test runner applies to $(pwd)"
  fi
  return $failed
}


update-all-repos() {
  find . -type d -name ".git" | while read gitdir; do
    repo=$(dirname "$gitdir")
    echo "Updating $repo"
    (cd "$repo" && git pull origin main)
  done
}

alias kiro='kiro-cli --v3'
alias krio='kiro-cli --v3'
alias source-shell='source ~/.zshrc'
alias ss='source ~/.zshrc && cls'

# --------------------------------------------------
# Load Oh My Zsh & Powerlevel10k config
# --------------------------------------------------
source $ZSH/oh-my-zsh.sh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# --------------------------------------------------
# asdf version manager
# --------------------------------------------------
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# --------------------------------------------------
# curl timing breakdown
# Source - https://stackoverflow.com/a/47944496
# Posted by Konstantin, modified by community. See post 'Timeline' for change history
# Retrieved 2026-03-02, License - CC BY-SA 3.0
# --------------------------------------------------
curl_time() {
    curl -so /dev/null -w "\
   namelookup:  %{time_namelookup}s\n\
      connect:  %{time_connect}s\n\
   appconnect:  %{time_appconnect}s\n\
  pretransfer:  %{time_pretransfer}s\n\
     redirect:  %{time_redirect}s\n\
starttransfer:  %{time_starttransfer}s\n\
        idle:  %{time_idle}s\n\
-------------------------\n\
        total:  %{time_total}s\n" "$@"
}

# bun completions
[ -s "/Users/christopheralphonse/.oh-my-zsh/completions/_bun" ] && source "/Users/christopheralphonse/.oh-my-zsh/completions/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# AWS: check CLI login (optional profile arg)
alias awsCheck=~/Desktop/dotfiles/shared/aws/aws-check-login.sh
