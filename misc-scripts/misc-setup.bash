#!/usr/bin/env bash

#One-time setup tasks
#Requirements:
# - iTerm nightly build installed: <https://iterm2.com/downloads/nightly/#/section/home>

#Makes scrollwheel scroll in iTerm in buffers with vim/less/etc. (nightly builds only)
defaults write com.googlecode.iterm2 AlternateMouseScroll -bool true

#Get iTerm shell integration <https://iterm2.com/shell_integration.html>
curl -L https://iterm2.com/misc/bash_startup.in >> \
~/.iterm2_shell_integration.bash

#Switch the default Grab (screenshot) file format
defaults write com.apple.screencapture type jpg; killall SystemUIServer