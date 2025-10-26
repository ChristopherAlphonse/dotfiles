#!/bin/zsh
iatest=$(expr index "$-" i)

#######################################################
# SOURCED ALIAS'S AND SCRIPTS
#######################################################

# Source global definitions
if [ -f /etc/zshrc ]; then
    . /etc/zshrc
fi

#######################################################
# EXPORTS
#######################################################

# Disable the bell
if [[ $iatest -gt 0 ]]; then setopt NO_BEEP; fi

# Expand the history size
export HISTFILE=~/.zsh_history
export HISTFILESIZE=10000
export HISTSIZE=10000
export SAVEHIST=10000

# Don't put duplicate lines in the history and do not add lines that start with a space
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS

# Append to history instead of overwriting
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Set the default editor
export EDITOR=code
export VISUAL=code
alias pico='edit'
alias spico='sedit'
alias nano='edit'
alias snano='sedit'
alias vim='nvim'

# Replace batcat with cat on Fedora as batcat is not available as a RPM in any form
if command -v lsb_release > /dev/null 2>&1; then
    DISTRIBUTION=$(lsb_release -si)

    if [ "$DISTRIBUTION" = "Fedora" ]; then
        alias cat='bat'
    else
        alias cat='batcat'
    fi
fi

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#######################################################
# MACHINE SPECIFIC ALIAS'S
#######################################################

# Alias's for SSH
# alias SERVERNAME='ssh YOURWEBSITE.com -l USERNAME -p PORTNUMBERHERE'

# Alias's to change the directory
alias web='cd /var/www/html'


#######################################################
# GRAFANA ALIAS'S
#######################################################
alias node_exp='cd /home/chris-ubuntu/node_exporter'
alias prom_dir='cd /home/chris-ubuntu/prometheus'
alias grafana_dir='cd /home/chris-ubuntu/grafana'

# Service control functions
unalias grafana 2>/dev/null || true
unalias prometheus 2>/dev/null || true
unalias node_exporter 2>/dev/null || true

grafana() {
  case "$1" in
    start)
      sudo systemctl start grafana-server
      echo "✓ Grafana started"
      ;;
    stop)
      sudo systemctl stop grafana-server
      echo "✓ Grafana stopped"
      ;;
    restart)
      sudo systemctl restart grafana-server
      echo "✓ Grafana restarted"
      ;;
    status)
      sudo systemctl status grafana-server
      ;;
    *)
      echo "Usage: grafana {start|stop|restart|status}"
      ;;
  esac
}

prometheus() {
  case "$1" in
    start)
      nohup /home/chris-ubuntu/prometheus/prometheus --config.file=/home/chris-ubuntu/prometheus/prometheus.yml > /tmp/prometheus.log 2>&1 &
      echo "✓ Prometheus started (PID: $!)"
      ;;
    stop)
      pkill -f "/home/chris-ubuntu/prometheus/prometheus"
      echo "✓ Prometheus stopped"
      ;;
    restart)
      pkill -f "/home/chris-ubuntu/prometheus/prometheus"
      sleep 1
      nohup /home/chris-ubuntu/prometheus/prometheus --config.file=/home/chris-ubuntu/prometheus/prometheus.yml > /tmp/prometheus.log 2>&1 &
      echo "✓ Prometheus restarted (PID: $!)"
      ;;
    status)
      pgrep -f "/home/chris-ubuntu/prometheus/prometheus" && echo "✓ Prometheus is running" || echo "✗ Prometheus is NOT running"
      ;;
    *)
      echo "Usage: prometheus {start|stop|restart|status}"
      ;;
  esac
}

node_exporter() {
  case "$1" in
    start)
      nohup /home/chris-ubuntu/node_exporter/node_exporter > /tmp/node_exporter.log 2>&1 &
      echo "✓ Node Exporter started (PID: $!)"
      ;;
    stop)
      pkill -f "/home/chris-ubuntu/node_exporter/node_exporter"
      echo "✓ Node Exporter stopped"
      ;;
    restart)
      pkill -f "/home/chris-ubuntu/node_exporter/node_exporter"
      sleep 1
      nohup /home/chris-ubuntu/node_exporter/node_exporter > /tmp/node_exporter.log 2>&1 &
      echo "✓ Node Exporter restarted (PID: $!)"
      ;;
    status)
      pgrep -f "/home/chris-ubuntu/node_exporter/node_exporter" && echo "✓ Node Exporter is running" || echo "✗ Node Exporter is NOT running"
      ;;
    *)
      echo "Usage: node_exporter {start|stop|restart|status}"
      ;;
  esac
}






# grafana start      # Start Grafana (systemctl)
# grafana stop       # Stop Grafana
# grafana restart    # Restart Grafana
# grafana status     # Check Grafana status

# prometheus start   # Start Prometheus (runs in background)
# prometheus stop    # Stop Prometheus
# prometheus restart # Restart Prometheus
# prometheus status  # Check Prometheus status

# node_exporter start    # Start Node Exporter (runs in background)
# node_exporter stop     # Stop Node Exporter
# node_exporter restart  # Restart Node Exporter
# node_exporter status   # Check Node Exporter status

#######################################################
# GENERAL ALIAS'S
#######################################################

# Add an "alert" alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Edit this .zshrc file
alias ezrc='edit ~/.zshrc'

# alias to show the date
alias da='date "+%Y-%m-%d %A %T %Z"'

# Alias's to modified commands
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias c='clear'
alias apt-get='sudo apt-get'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'
alias vi='nvim'
alias svi='sudo vi'
alias vis='nvim "+set si"'

# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Remove a directory and all files
alias rmd='/bin/rm  --recursive --force --verbose '

# Alias's for multiple directory listing commands
alias la='ls -Alh' # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXBh' # sort by extension
alias lk='ls -lSrh' # sort by size
alias lc='ls -lcrh' # sort by change time
alias lu='ls -lurh' # sort by access time
alias lr='ls -lRh' # recursive ls
alias lt='ls -ltrh' # sort by date
alias lm='ls -alh |more' # pipe through 'more'
alias lw='ls -xAh' # wide listing format
alias ll='ls -Fls' # long listing format
alias labc='ls -lap' #alphabetical sort
alias lf="ls -l | egrep -v '^d'" # files only
alias ldir="ls -l | egrep '^d'" # directories only

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search command line history
alias h="history | grep "

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Search files in the current folder
alias f="find . | grep "

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"

# Show open ports
alias openports='netstat -nape --inet'

# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# SHA1
alias sha1='openssl sha1'

alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'

# KITTY - alias to be able to use kitty features when connecting to remote servers(e.g use tmux on remote server)
alias kssh="kitty +kitten ssh"

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

#######################################################
# SPECIAL FUNCTIONS
#######################################################

# Use the best version of pico installed
edit ()
{
    if [ "$(type -t jpico)" = "file" ]; then
        # Use JOE text editor http://joe-editor.sourceforge.net/
        jpico -nonotice -linums -nobackups "$@"
    elif [ "$(type -t nano)" = "file" ]; then
        nano -c "$@"
    elif [ "$(type -t pico)" = "file" ]; then
        pico "$@"
    else
        nvim "$@"
    fi
}

sedit ()
{
    if [ "$(type -t jpico)" = "file" ]; then
        # Use JOE text editor http://joe-editor.sourceforge.net/
        sudo jpico -nonotice -linums -nobackups "$@"
    elif [ "$(type -t nano)" = "file" ]; then
        sudo nano -c "$@"
    elif [ "$(type -t pico)" = "file" ]; then
        sudo pico "$@"
    else
        sudo nvim "$@"
    fi
}

# Extracts any archive(s) (if unp isn't installed)
extract () {
    for archive in "$@"; do
        if [ -f "$archive" ] ; then
            case $archive in
                *.tar.bz2)   tar xvjf $archive    ;;
                *.tar.gz)    tar xvzf $archive    ;;
                *.bz2)       bunzip2 $archive     ;;
                *.rar)       rar x $archive       ;;
                *.gz)        gunzip $archive      ;;
                *.tar)       tar xvf $archive     ;;
                *.tbz2)      tar xvjf $archive    ;;
                *.tgz)       tar xvzf $archive    ;;
                *.zip)       unzip $archive       ;;
                *.Z)         uncompress $archive  ;;
                *.7z)        7z x $archive        ;;
                *)           echo "don't know how to extract '$archive'..." ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Searches for text in all files in the current folder
ftext ()
{
    # -i case-insensitive
    # -I ignore binary files
    # -H causes filename to be printed
    # -r recursive search
    # -n causes line number to be printed
    # optional: -F treat search term as a literal, not a regular expression
    # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
    grep -iIHrn --color=always "$1" . | less -r
}

# Copy file with a progress bar
cpp()
{
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
    | awk '{
    count += $NF
    if (count % 10 == 0) {
        percent = count / total_size * 100
        printf "%3d%% [", percent
        for (i=0;i<=percent;i++)
            printf "="
            printf ">"
            for (i=percent;i<100;i++)
                printf " "
                printf "]\r"
            }
        }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Copy and go to the directory
cpg ()
{
    if [ -d "$2" ];then
        cp "$1" "$2" && cd "$2"
    else
        cp "$1" "$2"
    fi
}

# Move and go to the directory
mvg ()
{
    if [ -d "$2" ];then
        mv "$1" "$2" && cd "$2"
    else
        mv "$1" "$2"
    fi
}

# Create and go to the directory
mkdirg ()
{
    mkdir -p "$1"
    cd "$1"
}

# Goes up a specified number of directories  (i.e. up 4)
up ()
{
    local d=""
    limit=$1
    for ((i=1 ; i <= limit ; i++))
        do
            d=$d/..
        done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}

# Returns the last 2 fields of the working directory
pwdtail ()
{
    pwd|awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Show the current distribution
distribution ()
{
    local dtype
    # Assume unknown
    dtype="unknown"

    # First test against Fedora / RHEL / CentOS / generic Redhat derivative
    if [ -r /etc/rc.d/init.d/functions ]; then
        source /etc/rc.d/init.d/functions
        [ zz`type -t passed 2>/dev/null` == "zzfunction" ] && dtype="redhat"

    # Then test against SUSE (must be after Redhat,
    # I've seen rc.status on Ubuntu I think? TODO: Recheck that)
    elif [ -r /etc/rc.status ]; then
        source /etc/rc.status
        [ zz`type -t rc_reset 2>/dev/null` == "zzfunction" ] && dtype="suse"

    # Then test against Debian, Ubuntu and friends
    elif [ -r /lib/lsb/init-functions ]; then
        source /lib/lsb/init-functions
        [ zz`type -t log_begin_msg 2>/dev/null` == "zzfunction" ] && dtype="debian"

    # Then test against Gentoo
    elif [ -r /etc/init.d/functions.sh ]; then
        source /etc/init.d/functions.sh
        [ zz`type -t ebegin 2>/dev/null` == "zzfunction" ] && dtype="gentoo"

    # For Mandriva we currently just test if /etc/mandriva-release exists
    # and isn't empty (TODO: Find a better way :)
    elif [ -s /etc/mandriva-release ]; then
        dtype="mandriva"

    # For Slackware we currently just test if /etc/slackware-version exists
    elif [ -s /etc/slackware-version ]; then
        dtype="slackware"

    fi
    echo $dtype
}

# Show the current version of the operating system
ver ()
{
    local dtype
    dtype=$(distribution)

    if [ $dtype == "redhat" ]; then
        if [ -s /etc/redhat-release ]; then
            cat /etc/redhat-release && uname -a
        else
            cat /etc/issue && uname -a
        fi
    elif [ $dtype == "suse" ]; then
        cat /etc/SuSE-release
    elif [ $dtype == "debian" ]; then
        lsb_release -a
    elif [ $dtype == "gentoo" ]; then
        cat /etc/gentoo-release
    elif [ $dtype == "mandriva" ]; then
        cat /etc/mandriva-release
    elif [ $dtype == "slackware" ]; then
        cat /etc/slackware-version
    else
        if [ -s /etc/issue ]; then
            cat /etc/issue
        else
            echo "Error: Unknown distribution"
            exit 1
        fi
    fi
}

# Show current network information
netinfo ()
{
    echo "--------------- Network Information ---------------"
    /sbin/ifconfig | awk /'inet addr/ {print $2}'
    echo ""
    /sbin/ifconfig | awk /'Bcast/ {print $3}'
    echo ""
    /sbin/ifconfig | awk /'inet addr/ {print $4}'

    /sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
    echo "---------------------------------------------------"
}

# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip ()
{
    # Internal IP Lookup.
    if [ -e /sbin/ip ];
    then
        echo -n "Internal IP: " ; /sbin/ip addr show wlan0 | grep "inet " | awk -F: '{print $1}' | awk '{print $2}'
    else
        echo -n "Internal IP: " ; /sbin/ifconfig wlan0 | grep "inet " | awk -F: '{print $1} |' | awk '{print $2}'
    fi

    # External IP Lookup
    echo -n "External IP: " ; curl -s ifconfig.me
}

# View Apache logs
apachelog ()
{
    if [ -f /etc/httpd/conf/httpd.conf ]; then
        cd /var/log/httpd && ls -xAh && multitail --no-repeat -c -s 2 /var/log/httpd/*_log
    else
        cd /var/log/apache2 && ls -xAh && multitail --no-repeat -c -s 2 /var/log/apache2/*.log
    fi
}

# Edit the Apache configuration
apacheconfig ()
{
    if [ -f /etc/httpd/conf/httpd.conf ]; then
        sedit /etc/httpd/conf/httpd.conf
    elif [ -f /etc/apache2/apache2.conf ]; then
        sedit /etc/apache2/apache2.conf
    else
        echo "Error: Apache config file could not be found."
        echo "Searching for possible locations:"
        sudo updatedb && locate httpd.conf && locate apache2.conf
    fi
}

# Edit the PHP configuration file
phpconfig ()
{
    if [ -f /etc/php.ini ]; then
        sedit /etc/php.ini
    elif [ -f /etc/php/php.ini ]; then
        sedit /etc/php/php.ini
    elif [ -f /etc/php5/php.ini ]; then
        sedit /etc/php5/php.ini
    elif [ -f /usr/bin/php5/bin/php.ini ]; then
        sedit /usr/bin/php5/bin/php.ini
    elif [ -f /etc/php5/apache2/php.ini ]; then
        sedit /etc/php5/apache2/php.ini
    else
        echo "Error: php.ini file could not be found."
        echo "Searching for possible locations:"
        sudo updatedb && locate php.ini
    fi
}

# Edit the MySQL configuration file
mysqlconfig ()
{
    if [ -f /etc/my.cnf ]; then
        sedit /etc/my.cnf
    elif [ -f /etc/mysql/my.cnf ]; then
        sedit /etc/mysql/my.cnf
    elif [ -f /usr/local/etc/my.cnf ]; then
        sedit /usr/local/etc/my.cnf
    elif [ -f /usr/bin/mysql/my.cnf ]; then
        sedit /usr/bin/mysql/my.cnf
    elif [ -f ~/my.cnf ]; then
        sedit ~/my.cnf
    elif [ -f ~/.my.cnf ]; then
        sedit ~/.my.cnf
    else
        echo "Error: my.cnf file could not be found."
        echo "Searching for possible locations:"
        sudo updatedb && locate my.cnf
    fi
}

# For some reason, rot13 pops up everywhere
rot13 () {
    if [ $# -eq 0 ]; then
        tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    else
        echo $* | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    fi
}

# Trim leading and trailing spaces (for scripts)
trim()
{
    local var=$*
    var="${var#"${var%%[![:space:]]*}"}"  # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"  # remove trailing whitespace characters
    echo -n "$var"
}

# GitHub git functions
gcom() {
    git add .
    git commit -m "$1"
}

lazyg() {
    git add .
    git commit -m "$1"
    git push
}

#######################################################
# PATH ADDITIONS
#######################################################

export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin:/.local/share/flatpak/exports/bin"

#######################################################
# TOOL INITIALIZATIONS
#######################################################

# Initialize Starship prompt (install: curl -sS https://starship.rs/install.sh | sh)
if command -v starship > /dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Initialize zoxide (install: curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash)
if command -v zoxide > /dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Initialize autojump
if [ -f "/usr/share/autojump/autojump.zsh" ]; then
    . /usr/share/autojump/autojump.zsh
elif [ -f "/usr/share/autojump/autojump.sh" ]; then
    . /usr/share/autojump/autojump.sh
fi

# Bat alias
if command -v batcat > /dev/null 2>&1; then
    alias bat="batcat"
fi

# Enable zsh completion system
autoload -Uz compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Enable menu select for completion
zstyle ':completion:*' menu select

