# Put /usr/local/bin in the path (it's not necessarily there by default)
if grep -q '/usr/local/bin' <<< "$PATH"; then
  :  #already in path
else
  export PATH=/usr/local/bin:"$PATH"
fi

#Outdated leaf packages (ones I installed, not including dependencies)
alias brew-outdated-leaves='cat <(brew outdated) <(brew leaves) | sort | uniq -d | grep -f - --color=never <(brew outdated -v)'

#bash_completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi


# Add coreutils and gnu-sed executables and manpages to the path at beginning 
# so they replace system ones.
# Assumes you've installed coreutils and gnu-sed via brew.

if [ -n "$(brew ls --versions coreutils)" ]; then
  export MANPATH="`brew --prefix`/opt/coreutils/libexec/gnuman:$MANPATH"
  export PATH="`brew --prefix`/opt/coreutils/libexec/gnubin:$PATH"

fi
  
if [ -n "$(brew ls --versions gnu-sed)" ]; then
  export MANPATH="`brew --prefix`/opt/gnu-sed/libexec/gnuman:$MANPATH"
  export PATH="`brew --prefix`/opt/gnu-sed/libexec/gnubin:$PATH"
fi

#autojump
if [ -f $(brew --prefix)/etc/autojump.sh ]; then
  . $(brew --prefix)/etc/autojump.sh
fi
