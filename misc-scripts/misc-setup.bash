#!/usr/bin/env bash

#One-time setup tasks

#Makes scrollwheel scroll in iTerm in buffers with vim/less/etc.
#TODO: test if this is necessary
#defaults write com.googlecode.iterm2 AlternateMouseScroll -bool true

#Switch the default Grab (screenshot) file format
#TODO: test if this works
#defaults write com.apple.screencapture type jpg; killall SystemUIServer