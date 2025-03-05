export PATH="/usr/local/pgsql/bin:$PATH"
export PATH=/Applications/Postgres.app/Contents/Versions/16/bin:$PATH



if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi


ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"


if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi


source "${ZINIT_HOME}/zinit.zsh"


zinit ice depth=1; zinit light romkatv/powerlevel10k

#plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

alias Home='cd ~'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias cls='clear'
alias h='history'
alias c='clear'
alias ls='ls --color'
alias be='bundle exec'

# History
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

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

alias eztilt="${EZCATER_REPOSITORY_PATH}/eztilt/eztilt"
alias run="${EZCATER_REPOSITORY_PATH}/eztilt/run"
plugins=(you-should-use)

source $ZSH/oh-my-zsh.sh
source ~/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source "/Users/chrisalphonse/.asdf/asdf.sh"

alias eztilt="/Users/chrisalphonse/code/ezcater/eztilt/eztilt"
alias run="/Users/chrisalphonse/code/ezcater/eztilt/run"

alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

alias lintts="yarn lint:tsc && yarn lint:tsc-strict && yarn lint:js && yarn fix:js && yarn lint:prettier && yarn fix:prettier"


export EZ_RAILS_DEV_DATA=partial
export EZ_RAILS_VECTOR_DEV_DATA=partial
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
