# --- PATH setup ---
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
export PATH="/usr/local/pgsql/bin:$PATH"

export PATH

# --- Instant Prompt for Powerlevel10k ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Homebrew shell environment ---
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Zinit (plugin manager) setup ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Load powerlevel10k and plugins with zinit
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light MichaelAquilina/zsh-you-should-use

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

# Source powerlevel10k configuration if it exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Aliases ---
# Basic aliases
alias Home='cd ~'
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias bd='cd "$OLDPWD"'
alias dealer-dw='cd /Users/calphonse/Desktop/cargurus/cg-main/cargurus-site-static/packages/dealer-dashboard-web'
alias dealer-ws='cd /Users/calphonse/Desktop/cargurus/cg-main/cargurus-site-static/packages/cargurus-wholesale-offer-service'
alias cg-main='cd /Users/calphonse/cargurus/cg-main'
alias cargurus='cd /Users/calphonse/cargurus'
alias dealer-be='cd /Users/calphonse/cargurus/dealer-browser-extension'
alias dealer-ui='cd /Users/calphonse/cargurus/dealer-dashboard-ui'
alias gitupmain='git fetch origin && git rebase origin/main'


alias gs='git status'
alias gc='git commit'
alias ga='git add'
alias gp='git push'

alias cls='clear'
alias c='clear'

alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias rmd='/bin/rm --recursive --force --verbose '

alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'

# ls variants
alias ls='ls -aFh --color=always'
alias la='ls -Alh'       # show hidden files
alias lx='ls -lXBh'      # sort by extension
alias lk='ls -lSrh'      # sort by size
alias lc='ls -lcrh'      # sort by change time
alias lu='ls -lurh'      # sort by access time
alias lr='ls -lRh'       # recursive
alias lt='ls -ltrh'      # sort by date
alias lm='ls -alh |more' # pipe through more
alias lw='ls -xAh'       # wide listing format
alias ll='ls -Fls'       # long listing format
alias labc='ls -lap'     # alphabetical sort
alias lf="ls -l | egrep -v '^d'" # files only
alias ldir="ls -l | egrep '^d'"   # directories only

# chmod shortcuts
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# History and search aliases
alias h="history | grep "
alias p="ps aux | grep "
alias f="find . | grep "
alias checkcommand="type -t"
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# System commands aliases
alias openports='netstat -nape --inet'
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Disk and folder info
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Archive commands
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# git
alias gw='git switch '

# Logs viewing
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# Other useful aliases
alias sha1='openssl sha1'
alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'

# Kitty ssh alias
alias kssh="kitty +kitten ssh"

# --- History settings ---
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# --- Completion styling ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# --- fzf and zoxide initialization ---
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

_z_cd() {
    cd "$@" || return "$?"

    if [ "$_ZO_ECHO" = "1" ]; then
        echo "$PWD"
    fi
}
# z/zoxide wrapper functions and aliases
z() {
    if [ "$#" -eq 0 ]; then
        _z_cd ~
    elif [ "$#" -eq 1 ] && [ "$1" = '-' ]; then
        if [ -n "$OLDPWD" ]; then
            _z_cd "$OLDPWD"
        else
            echo 'zoxide: $OLDPWD is not set'
            return 1
        fi
    else
        _zoxide_result="$(zoxide query -- "$@")" && _z_cd "$_zoxide_result"
    fi
}

zii() {
    _zoxide_result="$(zoxide query -i -- "$@")" && _z_cd "$_zoxide_result"
}

alias za='zoxide add'
alias zq='zoxide query'
alias zqi='zii'
alias zr='zoxide remove'
alias bat="batcat"

# --- git commit helpers ---
gcom() {
    git add .
    git commit -m "$1"
}

lazyg() {
    git add .
    git commit -m "$1"
    git push
}

# --- Shell reload function ---
reload() {
    echo "Reloading zsh configuration..."
    source ~/.zshrc
    echo "Configuration reloaded successfully!"
}

# Aliases for reloading configuration
alias refresh='reload'
alias rl='reload'
alias src='source ~/.zshrc'

# --- NVM (Node Version Manager) setup ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/calphonse/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
