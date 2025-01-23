if [ -x /opt/homebrew/bin/brew ]; then
  export BREW_EXEC=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then
  export BREW_EXEC=/usr/local/bin/brew
fi
eval "$($BREW_EXEC shellenv)"
# This sets HOMEBREW_PREFIX, puts homebrew-installed binaries into PATH, and some other stuff

#bash_completion
if [ -f $HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh ]; then
  . "$HOMEBREW_PREFIX"/etc/profile.d/bash_completion.sh
fi


# Add coreutils and gnu-sed executables and manpages to the path at beginning 
# so they replace system ones.
# Assumes you've installed coreutils and gnu-sed via brew.

# The "proper" way to check whether a package is installed is to do use
# [ -n $(brew ls --versions <PACKAGE>) ] or which <EXEC> && ...
# But both are much slow, so this is a faster but more fragile alternative.
if [ -d "$HOMEBREW_PREFIX"/Cellar/coreutils ]; then
  export MANPATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnuman:$MANPATH"
  export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"

fi

if [ -d "$HOMEBREW_PREFIX"/Cellar/grep ]; then
  export MANPATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$MANPATH"
  export PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
fi
  
if [ -d "$HOMEBREW_PREFIX"/Cellar/gnu-sed ]; then
  export MANPATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnuman:$MANPATH"
  export PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
fi

if [ -d "$HOMEBREW_PREFIX"/Cellar/grep ]; then
  export MANPATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnuman:$MANPATH"
  export PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
fi

if [ -d "$HOMEBREW_PREFIX"/Cellar/findutils ]; then
    export PATH="$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin:$PATH"
    export MANPATH="$HOMEBREW_PREFIX/opt/findutils/libexec/gnuman:$MANPATH"
fi

#autojump
if [ -f $HOMEBREW_PREFIX/etc/autojump.sh ]; then
  . "$HOMEBREW_PREFIX"/etc/autojump.sh
fi
