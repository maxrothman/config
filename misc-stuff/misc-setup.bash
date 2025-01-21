#!/usr/bin/env bash
set -euo pipefail

#One-time setup tasks

#Makes scrollwheel scroll in iTerm in buffers with vim/less/etc.
#TODO: test if this is necessary
#defaults write com.googlecode.iterm2 AlternateMouseScroll -bool true

#Switch the default Grab (screenshot) file format
#TODO: test if this works
#defaults write com.apple.screencapture type jpg; killall SystemUIServer


# *****************
# *** IMPORTANT ***
# *****************
#
# Add the following to the top of /etc/shells:
# /usr/local/bin/bash (assuming that's where brew put it)

#Symlink in docker completions
ln -s /Applications/Docker.app/Contents/Resources/etc/docker.bash-completion -t $(brew --prefix)/etc/bash_completion.d

#Install fzf hooks
/usr/local/opt/fzf/install

#Install asdf plugins
asdf plugin add java
asdf plugin add nodejs

#Enable touchid for sudo
echo 'auth sufficient pam_tid.so' > sudo_local
chmod 444 sudo_local
chown root:wheel sudo_local
sudo mv sudo_local /etc/pam.d/
