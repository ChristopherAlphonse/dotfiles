# Add Visual Studio Code (code) to PATH
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Append Visual Studio Code (code) to PATH in .bash_profile
cat << EOF >> ~/.bash_profile
# Add Visual Studio Code (code)
export PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
EOF

# Append aliases to .bashrc
cat << EOF >> ~/.bashrc
alias eztilt="\${EZCATER_REPOSITORY_PATH}/eztilt/eztilt"
alias run="\${EZCATER_REPOSITORY_PATH}/eztilt/run"
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias cls='clear'
alias h='history'
alias c='clear'
EOF



# Set EZCATER_REPOSITORY_PATH
export EZCATER_REPOSITORY_PATH='/Users/chrisalphonse/code/ezcater/eztilt'

# Add Visual Studio Code (code) to PATH
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

