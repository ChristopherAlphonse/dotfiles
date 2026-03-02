# --------------------------------------------------
# Interactive Shell Only
# --------------------------------------------------
[[ -o interactive ]] || return

# --------------------------------------------------
# Environment
# --------------------------------------------------
export EDITOR=code
export VISUAL=code
export CLICOLOR=1
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/opt/homebrew/bin:$PATH"

# --------------------------------------------------
# Homebrew (Apple Silicon safe)
# --------------------------------------------------
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --------------------------------------------------
# Zinit (Plugin Manager)
# --------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# --------------------------------------------------
# Theme (Powerlevel10k)
# --------------------------------------------------
zinit ice depth=1
zinit light romkatv/powerlevel10k

# --------------------------------------------------
# Essential Plugins Only
# --------------------------------------------------
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab

# --------------------------------------------------
# Completion
# --------------------------------------------------
autoload -Uz compinit
compinit -C

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':fzf-tab:complete:*' fzf-preview 'ls --color $realpath'

# --------------------------------------------------
# History (Clean + Fast)
# --------------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_save_no_dups

# --------------------------------------------------
# Shell Behavior
# --------------------------------------------------
setopt NO_BEEP
setopt AUTO_CD
setopt CORRECT
stty -ixon 2>/dev/null

# --------------------------------------------------
# fzf & zoxide
# --------------------------------------------------
command -v fzf >/dev/null && eval "$(fzf --zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# --------------------------------------------------
# Aliases
# --------------------------------------------------

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias bd='cd "$OLDPWD"'

# Clear
alias c='clear'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# Safer file ops
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# LS
alias ls='ls -aFhG'
alias ll='ls -lah'
alias lt='ls -ltrh'

# Search
alias h='history | grep'
alias f='find . | grep'

# Tools
alias grep='grep --color=auto'
alias vi='nvim'
alias vim='nvim'

# --------------------------------------------------
# Helper Functions
# --------------------------------------------------

mkdirg() {
  mkdir -p "$1" && cd "$1"
}

up() {
  local n=${1:-1}
  cd "$(printf '../%.0s' $(seq 1 $n))"
}

reload() {
  source ~/.zshrc
  echo "Reloaded ✓"
}

gcom() {
  git add . && git commit -m "$1"
}

update-all-repos() {
  find . -type d -name ".git" | while read gitdir; do
    repo=$(dirname "$gitdir")
    echo "Updating $repo"
    (cd "$repo" && git pull origin main)
  done
}

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


# --------------------------------------------------
# asdf (if installed)
# --------------------------------------------------
if command -v brew >/dev/null 2>&1; then
  ASDF_PATH="$(brew --prefix asdf 2>/dev/null)"
  [[ -n "$ASDF_PATH" ]] && . "$ASDF_PATH/libexec/asdf.sh"
fi

# --------------------------------------------------
# Load Powerlevel10k config (if exists)
# --------------------------------------------------
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
