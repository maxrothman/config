# Basic core stuff

# add timestamps to bash history
export HISTTIMEFORMAT='%F %T '

# Turn on colors
eval $(dircolors ~/.dircolors)
alias grep='grep --color'
alias ls='ls --color'

# Common ls aliases
alias ll='ls -lArth'
alias la='ls -A'

# For some reason, set completion-ignore-case on isn't working in my ~/.inputrc
bind 'set completion-ignore-case on'
