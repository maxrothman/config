# Put /usr/local/bin in the path (it's not necessarily there by default)
if grep -q '/usr/local/bin' <<< "$PATH"; then
  :  #already in path
else
  export PATH=/usr/local/bin:"$PATH"
fi

#Outdated leaf packages (ones I installed, not including dependencies)
#TODO: might be obsolete now that I have brew bundle set up?
alias brew-outdated-leaves='cat <(brew outdated) <(brew leaves) | sort | uniq -d | grep -f - --color=never <(brew outdated -v)'
alias brew-upgrade-outdated-leaves='cat <(brew outdated) <(brew leaves) | sort | uniq -d | xargs brew upgrade'

# brew --prefix gets used a bunch of times below, and brew is sloooow.
brew_prefix="$(brew --prefix)"

#bash_completion
if [ -f $brew_prefix/etc/bash_completion ]; then
  . "$brew_prefix"/etc/bash_completion
fi


# Add coreutils and gnu-sed executables and manpages to the path at beginning 
# so they replace system ones.
# Assumes you've installed coreutils and gnu-sed via brew.

# The "proper" way to check whether a package is installed is to do:
# if [ -n $(brew ls --versions <PACKAGE>) ]; then do something; fi
# But "brew ls" is suuuper slow, so this is a faster but more fragile alternative.
if [ -d "$brew_prefix"/Cellar/coreutils ]; then
  export MANPATH="$brew_prefix/opt/coreutils/libexec/gnuman:$MANPATH"
  export PATH="$brew_prefix/opt/coreutils/libexec/gnubin:$PATH"

fi

if [ -d "$brew_prefix"/Cellar/grep ]; then
  export MANPATH="$brew_prefix/opt/grep/libexec/gnubin:$MANPATH"
  export PATH="$brew_prefix/opt/grep/libexec/gnubin:$PATH"
fi
  
if [ -d "$brew_prefix"/Cellar/gnu-sed ]; then
  export MANPATH="$brew_prefix/opt/gnu-sed/libexec/gnuman:$MANPATH"
  export PATH="$brew_prefix/opt/gnu-sed/libexec/gnubin:$PATH"
fi

if [ -d "$brew_prefix"/Cellar/grep ]; then
  export MANPATH="$brew_prefix/opt/grep/libexec/gnuman:$MANPATH"
  export PATH="$brew_prefix/opt/grep/libexec/gnubin:$PATH"
fi

if [ -d "$brew_prefix"/Cellar/findutils ]; then
    export PATH="$brew_prefix/opt/findutils/libexec/gnubin:$PATH"
    export MANPATH="$brew_prefix/opt/findutils/libexec/gnuman:$MANPATH"
fi

#autojump
if [ -f $brew_prefix/etc/autojump.sh ]; then
  . "$brew_prefix"/etc/autojump.sh
fi

# Add python2 to path: https://github.com/Homebrew/homebrew-core/issues/15746
# I think I don't need Python 2 anymore! Yay!
# if [ -d "$brew_prefix"/Cellar/python@2 ]; then
#   export PATH="$brew_prefix/opt/python@2/bin:$PATH"
# fi

# Add other man pages to the path (at the moment, just tqdm, but could be others)
export MANPATH="$brew_prefix/man:$MANPATH"
