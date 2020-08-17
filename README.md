# config
A repository for various pieces of workstation setup: dotfiles, configs, extensions, etc.

## Contents
* Alfred.alfredpreferences: Alfred plugins. See the README therein for details.
* bashrc.d: All executable files in here will be sourced by ~/.bashrc. Each file is
  self-explanatory. This directory will be symlinked to ~/.bashrc.d.
* bin: executables that are used by code in bashrc.d. This directory will be
  symlinked to ~/.bin
* dotfiles: configuration files that various applications expect to be in ~/. Each
  file will be symlinked to ~/.$FILE (e.g. bashrc -> ~/.bashrc).
* iTerm: iTerm configuration files.
* Karabiner: Karabiner configs. Used to be for making volume buttons work on my external keyboard, but
  Mac seems to pick these up automatically now (see manual.md)
* misc-stuff: Files used once during setup.
* stylus: CSS themes for the Stylus Chrome plugin
* manual.md: stuff to manually install
* deploy.sh: a script for automatically deploying the parts of this repo that can be automated.
* automator: add buttons to Finder that open apps via Apple automator
* VSCode: VSCode configs and a list of extensions to install
* git-hooks: My flexible git-hooks setup that allows for multiple global and repo-local hooks of the
  same type. Mostly used to turn my pre-push hook on for all repos.

## Setup instructions:
* Clone this repo somewhere
* Install brew: <http://brew.sh/>
* Run `deploy.sh`
* Run `misc-scripts/misc-setup.bash`
* Follow the instructions in `Alfred.alfredpreferences/README.md`
* Follow the instructions in the README in `automator/`
* Follow the instructions in `manual.md`

## Complete
* brew packages
* .dircolors
* .bash-colors
* .inputrc
* pre-push
* alfred plugins
* src-hilite-lesspipe.sh
* misc-setup.bash
* installed apps
* Stylus css (Chrome)
* .jq
* .vimrc
* .virtualenvwrapperrc
* python packages
* iTerm (Preferences>General>Load preferences from custom folder or URL)
* .gitconfig
* bash config

## Short-term Todo
* [x] Sync vscode settings
  * Using symlinks screws up reloading. Maybe use hardlinks? Or just wait for...
  * Looks like there'll be an [official feature release](https://github.com/microsoft/vscode/labels/settings-sync) to solve    this in the next month or so. Just going to manually drop the files in and list the extensions for now
* [x] Add USB Overdrive config and move change space shortcuts from BTT to mac
* [ ] resync vscode settings
* [ ] Sync BTT settings
* [ ] Sync tunnelblick cask and alfred workflow
* [ ] Sync hammerspoon
* [ ] document https://chrome.google.com/webstore/detail/tab-to-windowpopup-keyboa/adbkphmimfcaeonicpmamfddbbnphikh?hl=en-GB
* [ ] document smooth scrolling on chrome
* [ ] document turning on rewrap's auto wrap
* [ ] fix/sync quick-look extensions (don't work on catalina)
* [ ] defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false (enable key repeat)

## Long-term Todo
* [ ] Investigate https://github.com/python-mario/mario as a more featureful and better-maintained replacement for pythonpy
* [ ] Read vscode release notes and see if there's anything I should do differently
* [ ] Look into other vscode extensions and configs in other-peoples-vscode-extensions
* [ ] Make all bash script function variables local
* [ ] check for package upgrades 1/day
* [ ] https://github.com/clvv/fasd (or one of the other tools linked therein) might have better tab completion than autojump
* [ ] Remove virtualenvwrapperrc since the newest release has a lazy script
* [ ] custom jupyter color scheme? Or use vscode jupyter notebook integration
* [ ] ipython-sql
* [ ] separate out python packages:
  * [ ] pgcli et al with pipsi
  * [ ] "scratch" venv with jupyter, boto, etc.
  * [ ] what to do with pudb?
* [ ] iTerm2 custom title script (on iterm-custom-titles branch)

## Deprecated todos
* Sublime likes to reformat the prefs and remove comments. Find a workaround?
  * Maybe gitattributes and textconv: http://t-a-w.blogspot.com/2016/05/sensible-git-diff-for-json-files.html
* Find vscode plugins to:
  * remove matching brackets
  * split selection on words (rather than lines)
* For macbooks with force touch, set force threshold to "Firm" in System Preferences, then run `defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold 1` to make force touch a little lighter
  * Maybe figure out what some of the other keys do like `ActuateDedents`
* Distribute modified Ansible package
