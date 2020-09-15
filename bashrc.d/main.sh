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

# If I'm using `file` than I want to know what a thing REALLY is, not about what it links to
alias file='file -h'

# Replace the built-in diff with the better colorized git version
alias diff='git diff --no-index'

export EDITOR=vim
