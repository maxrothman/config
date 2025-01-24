#!/usr/bin/env bash
set -euo pipefail

#One-time setup tasks

#Switch the default screenshot file format
defaults write com.apple.screencapture type jpg; killall SystemUIServer


# *****************
# *** IMPORTANT ***
# *****************
#
# Add the following to the top of /etc/shells:
# /usr/local/bin/bash (assuming that's where brew put it)
# That's assuming you want to change the system shell, which I haven't
# found the need to necessarily do

#Install fzf hooks
/usr/local/opt/fzf/install

#Install asdf plugins
asdf plugin add java
#Pick latest lts
#asdf install java latest:adoptopenjdk-21
#asdf global java adoptopenjdk-<whatever asdf list java says you installed>

asdf plugin add nodejs
asdf install nodejs latest
asdf global nodejs latest

#Enable touchid for sudo
echo 'auth sufficient pam_tid.so' > sudo_local
chmod 444 sudo_local
chown root:wheel sudo_local
sudo mv sudo_local /etc/pam.d/

# Visually highlight changes inside lines
# Normally these would go in the global .gitconfig, but they need to be
# in the local file so the path to git can be dynamic
cat <<EOF >~/.gitconfig.local
[pager]
log = $HOMEBREW_PREFIX/share/git-core/contrib/diff-highlight/diff-highlight | less
show = $HOMEBREW_PREFIX/share/git-core/contrib/diff-highlight/diff-highlight | less
diff = $HOMEBREW_PREFIX/share/git-core/contrib/diff-highlight/diff-highlight | less

[interactive]
diffFilter = $HOMEBREW_PREFIX/share/git-core/contrib/diff-highlight/diff-highlight
EOF
