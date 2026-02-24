
# [[ -o interactive ]] || return

# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="simple"
# plugins=(git)


# export PATH

# # --- Instant Prompt for Powerlevel10k ---
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# # --- Homebrew shell environment ---
# if [[ -f "/opt/homebrew/bin/brew" ]]; then
#   eval "$(/opt/homebrew/bin/brew shellenv)"
# fi

# # --- Zinit (plugin manager) setup ---
# ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# if [ ! -d "$ZINIT_HOME" ]; then
#   mkdir -p "$(dirname $ZINIT_HOME)"
#   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
# fi

# source "${ZINIT_HOME}/zinit.zsh"

# # Load powerlevel10k and plugins with zinit
# zinit ice depth=1; zinit light romkatv/powerlevel10k

# # Plugins
# zinit light zsh-users/zsh-syntax-highlighting
# zinit light zsh-users/zsh-completions
# zinit light zsh-users/zsh-autosuggestions
# zinit light Aloxaf/fzf-tab
# zinit light MichaelAquilina/zsh-you-should-use

# # Snippets
# zinit snippet OMZP::git
# zinit snippet OMZP::sudo
# zinit snippet OMZP::archlinux
# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx
# zinit snippet OMZP::command-not-found

# # Load completions
# autoload -Uz compinit && compinit
# setopt APPEND_HISTORY
# setopt SHARE_HISTORY
# setopt HIST_IGNORE_ALL_DUPS
# setopt HIST_IGNORE_SPACE
# setopt NO_BEEP

# # Source powerlevel10k configuration if it exists
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# # --- Aliases ---
# # Basic aliases
# alias Home='cd ~'
# alias home='cd ~'
# alias cd..='cd ..'
# alias ..='cd ..'
# alias ...='cd ../..'
# alias ....='cd ../../..'
# alias .....='cd ../../../..'
# export HISTSIZE=500
# export HISTFILESIZE=10000

# stty -ixon 2>/dev/null


# # Zsh completion setup
# autoload -Uz compinit
# compinit

# # better matching + menus
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# zstyle ':completion:*' menu select
# zstyle ':completion:*' verbose yes
# zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'


# alias gs='git status'
# alias gc='git commit'
# alias ga='git add'
# alias gp='git push'

# alias cls='clear'
# alias c='clear'

# alias cp='cp -i'
# alias mv='mv -i'
# alias rm='trash -v'
# alias mkdir='mkdir -p'
# alias rmd='/bin/rm --recursive --force --verbose '

# alias ps='ps auxf'
# alias ping='ping -c 10'
# alias less='less -R'

# # ls variants
# alias ls='ls -aFh --color=always'
# alias la='ls -Alh'       # show hidden files
# alias lx='ls -lXBh'      # sort by extension
# alias lk='ls -lSrh'      # sort by size
# alias lc='ls -lcrh'      # sort by change time
# alias lu='ls -lurh'      # sort by access time
# alias lr='ls -lRh'       # recursive
# alias lt='ls -ltrh'      # sort by date
# alias lm='ls -alh |more' # pipe through more
# alias lw='ls -xAh'       # wide listing format
# alias ll='ls -Fls'       # long listing format
# alias labc='ls -lap'     # alphabetical sort
# alias lf="ls -l | egrep -v '^d'" # files only
# alias ldir="ls -l | egrep '^d'"   # directories only

# # chmod shortcuts
# alias mx='chmod a+x'
# alias 000='chmod -R 000'
# alias 644='chmod -R 644'
# alias 666='chmod -R 666'
# alias 755='chmod -R 755'
# alias 777='chmod -R 777'

# # History and search aliases
# alias h="history | grep "
# alias p="ps aux | grep "
# alias f="find . | grep "
# alias checkcommand="type -t"
# alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
# alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# # System commands aliases
# alias openports='netstat -nape --inet'
# alias rebootsafe='sudo shutdown -r now'
# alias rebootforce='sudo shutdown -r -n now'

# # Disk and folder info
# alias diskspace="du -S | sort -n -r |more"
# alias folders='du -h --max-depth=1'
# alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
# alias tree='tree -CAhF --dirsfirst'
# alias treed='tree -CAFd'
# alias mountedinfo='df -hT'

# # Archive commands
# alias mktar='tar -cvf'
# alias mkbz2='tar -cvjf'
# alias mkgz='tar -cvzf'
# alias untar='tar -xvf'
# alias unbz2='tar -xvjf'
# alias ungz='tar -xvzf'

# # git
# alias gw='git switch '

# # Logs viewing
# alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# # Other useful aliases
# alias sha1='openssl sha1'
# alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'

# # Kitty ssh alias
# alias kssh="kitty +kitten ssh"

# # --- History settings ---
# HISTSIZE=5000
# HISTFILE=~/.zsh_history
# SAVEHIST=$HISTSIZE
# HISTDUP=erase
# setopt appendhistory
# setopt sharehistory
# setopt hist_ignore_space
# setopt hist_ignore_all_dups
# setopt hist_save_no_dups
# setopt hist_ignore_dups
# setopt hist_find_no_dups

# # --- Completion styling ---
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# zstyle ':completion:*' menu no
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
# zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# # --- fzf and zoxide initialization ---
# eval "$(fzf --zsh)"
# eval "$(zoxide init --cmd cd zsh)"

# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# _z_cd() {
#     cd "$@" || return "$?"

#     if [ "$_ZO_ECHO" = "1" ]; then
#         echo "$PWD"
#     fi
# }
# # z/zoxide wrapper functions and aliases
# z() {
#     if [ "$#" -eq 0 ]; then
#         _z_cd ~
#     elif [ "$#" -eq 1 ] && [ "$1" = '-' ]; then
#         if [ -n "$OLDPWD" ]; then
#             _z_cd "$OLDPWD"
#         else
#             echo 'zoxide: $OLDPWD is not set'
#             return 1
#         fi
#     else
#         _zoxide_result="$(zoxide query -- "$@")" && _z_cd "$_zoxide_result"
#     fi
# }

# zii() {
#     _zoxide_result="$(zoxide query -i -- "$@")" && _z_cd "$_zoxide_result"
# }

# alias za='zoxide add'
# alias zq='zoxide query'
# alias zqi='zii'
# alias zr='zoxide remove'
# alias bat="batcat"
# if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
#   source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# fi


# if [ -f /opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh ]; then
#   source /opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh
# fi


# if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
#   source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# fi

# export EDITOR=code
# export VISUAL=code
# alias vi='nvim'
# alias vim='nvim'


# export CLICOLOR=1
# alias ls='ls -aFhG'
# alias grep='/usr/bin/grep --color=auto'

# export LESS_TERMCAP_mb=$'\E[01;31m'
# export LESS_TERMCAP_md=$'\E[01;31m'
# export LESS_TERMCAP_me=$'\E[0m'
# export LESS_TERMCAP_so=$'\E[01;44;33m'
# export LESS_TERMCAP_us=$'\E[01;32m'


# alias cp='cp -i'
# alias mv='mv -i'
# alias rm='trash -v'
# alias mkdir='mkdir -p'
# alias cls='clear'


# alias bd='cd "$OLDPWD"'

# alias la='ls -Alh'
# alias ll='ls -Fls'
# alias lt='ls -ltrh'

# alias h='history | grep'
# alias p='ps aux | grep'
# alias f='find . | grep'


# edit () {
#   if command -v nano >/dev/null; then
#     code "$@"
#   else
#     nvim "$@"
#   fi
# }

# sedit () {
#   sudo edit "$@"
# }

# unzip () {
#   for archive in "$@"; do
#     [[ -f "$archive" ]] || continue
#     case "$archive" in
#       *.tar.gz|*.tgz) tar xvzf "$archive" ;;
#       *.tar.bz2) tar xvjf "$archive" ;;
#       *.zip) unzip "$archive" ;;
#       *.gz) gunzip "$archive" ;;
#       *.tar) tar xvf "$archive" ;;
#       *.7z) 7z x "$archive" ;;
#       *) echo "Cannot extract $archive" ;;
#     esac
#   done
# }

# mkdirg () {
#   mkdir -p "$1" && cd "$1"
# }

# up () {
#   local n=${1:-1}
#   cd "$(printf '../%.0s' $(seq 1 $n))"
# }


# gcom () {
#   git add .
#   git commit -m "$1"
# }

# lazyg () {
#   git add .
#   git commit -m "$1"
#   git push
# }
# reload() {
#     echo "Reloading zsh configuration..."
#     source ~/.zshrc
#     echo "Configuration reloaded successfully!"
# }

# if command -v zoxide >/dev/null 2>&1; then
#   eval "$(zoxide init zsh)"
# fi

# if command -v starship >/dev/null 2>&1; then
#   eval "$(starship init zsh)"
# fi
# autoload -Uz compinit
# compinit

# export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"


# source $ZSH/oh-my-zsh.sh
# alias eztilt="/Users/christopheralphonse/src/eztilt/eztilt"
# alias run="/Users/christopheralphonse/src/eztilt/run"
# export EZCATER_REPOSITORY_PATH="$HOME/code/ezcater"
# export EZCATER_REPOSITORY_PATH="/Users/christopheralphonse/code/ezcater"
# export EZCATER_REPOSITORY_PATH="/Users/christopheralphonse/code/ezcater"
# export PATH="/Users/christopheralphonse/.asdf/shims:/Users/christopheralphonse/.local/bin:/Users/christopheralphonse/.cargo/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/homebrew/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
# alias eztilt="/Users/christopheralphonse/code/ezcater/eztilt/eztilt"
# alias run="/Users/christopheralphonse/code/ezcater/eztilt/run"
# export DOCKER_DEFAULT_PLATFORM=linux/amd64
# EZTILT_TOOL_VERSIONS="/Users/christopheralphonse/code/ezcater/eztilt/.tool-versions"

# # Append kubectl-oidc_login from ~/.tool-versions to eztilt .tool-versions (no repo edit needed long-term)
# _dev-backend-ensure-oidc() {
#   local line
#   line=$(grep 'kubectl-oidc_login' ~/.tool-versions 2>/dev/null)
#   if [[ -n "$line" ]] && ! grep -q 'kubectl-oidc_login' "$EZTILT_TOOL_VERSIONS" 2>/dev/null; then
#     echo "$line" >> "$EZTILT_TOOL_VERSIONS"
#   fi
# }

# dev-backend() {
#   _dev-backend-ensure-oidc
#   eztilt down || true
#   eztilt use store-complete
#   EZ_RAILS_DEV_DATA=partial EZ_RAILS_VECTOR_DEV_DATA=partial eztilt up backend
# }

# dev-down() {
#   eztilt down
#   [[ -f "$EZTILT_TOOL_VERSIONS" ]] && sed -i '' '/kubectl-oidc_login/d' "$EZTILT_TOOL_VERSIONS"
# }

# dev-frontend() {
#   cd ~/code/ezcater/store-next || return
#   yarn start
# }
# . "$(brew --prefix asdf)/libexec/asdf.sh"
# export DOCKER_API_VERSION=1.44

# update-all-repos(){
#   find . -type d -name ".git" | while read gitdir; do
#   repo=$(dirname "$gitdir")
#   echo "Updating $repo"
#   (cd "$repo" && git pull origin main)
# done
# }
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
# EzCater / EzTilt Dev Workflow
# --------------------------------------------------

export EZCATER_REPOSITORY_PATH="$HOME/code/ezcater"
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export DOCKER_API_VERSION=1.44

alias eztilt="$EZCATER_REPOSITORY_PATH/eztilt/eztilt"
alias run="$EZCATER_REPOSITORY_PATH/eztilt/run"

EZTILT_TOOL_VERSIONS="$EZCATER_REPOSITORY_PATH/eztilt/.tool-versions"

_dev-backend-ensure-oidc() {
  local line
  line=$(grep 'kubectl-oidc_login' ~/.tool-versions 2>/dev/null)
  if [[ -n "$line" ]] && ! grep -q 'kubectl-oidc_login' "$EZTILT_TOOL_VERSIONS" 2>/dev/null; then
    echo "$line" >> "$EZTILT_TOOL_VERSIONS"
  fi
}

dev-backend() {
  _dev-backend-ensure-oidc
  eztilt down || true
  eztilt use store-complete
  EZ_RAILS_DEV_DATA=partial EZ_RAILS_VECTOR_DEV_DATA=partial eztilt up backend
}

dev-down() {
  eztilt down
  [[ -f "$EZTILT_TOOL_VERSIONS" ]] && sed -i '' '/kubectl-oidc_login/d' "$EZTILT_TOOL_VERSIONS"
}

dev-frontend() {
  cd ~/code/ezcater/store-next || return
  yarn start
}

update-all-repos() {
  find . -type d -name ".git" | while read gitdir; do
    repo=$(dirname "$gitdir")
    echo "Updating $repo"
    (cd "$repo" && git pull origin main)
  done
}

# --------------------------------------------------
# Load Oh My Zsh & Powerlevel10k config
# --------------------------------------------------
source $ZSH/oh-my-zsh.sh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
