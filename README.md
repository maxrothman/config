# config
A repository for various pieces of workstation setup: dotfiles, configs, extensions, etc.

## Contents
* Alfred.alfredpreferences: Alfred plugins. See the README therein for details.
* bashrc.d: All executable files in here will be sourced by ~/.bashrc. Each file is
  self-explanatory. This directory will be symlinked to ~/.bashrc.d.
* bin: executables that are used by code in bashrc.d. This directory will be
  symlinked to ~/.bin
* dotfiles: configuration files that various applications expect to be in ~/. Each
  file will be hardlinked to ~/.$FILE (e.g. bashrc -> ~/.bashrc).
* iTerm: iTerm configuration files.
* Karabiner: Karabiner configs. Currently used to remap volume buttons on my external keyboard.
* misc-scripts: Scripts that should be run or acted on once.
* stylish: CSS themes for the Stylish Chrome plugin
* manual.md: stuff to manually install
* deploy.sh: a script for automatically deploying the parts of this repo that can be automated.
* automator: add buttons to Finder that open apps via Apple automator

## Setup instructions:
* Clone this repo somewhere
* Install brew: <http://brew.sh/>
* Run deploy.sh
* Install the
  [Stylus Chrome plugin](https://chrome.google.com/webstore/detail/stylus/clngdbkpkpeebahjckkjfobafhncgmne?hl=en)
  and follow the instructions in `Stylus/README.md`
* Follow the instructions in `Alfred.alfredpreferences/README.md`
* Follow the instructions in the README in automator/
* Run all the scripts in misc-scripts
* Manual iTerm setup:
  * In iTerm, go to Preferences > General > Preferences and set "Load preferences from a custom folder or URL"
    to the location of the `iTerm` directory in this repo.
  * Some stuff for iTerm may not be saved in config, particularly keybindings. Check for the following and add if necessary:
    * In Profiles>Default>Keys, set "Left option key acts as" to +Esc
    * In Profiles>Default>Keys, change ⌥→ to "Send Escape Sequence" and "f"
    * In Profiles>Default>Keys, change ⌥← to "Send Escape Sequence" and "b"
    * In the menu, run "Install shell integration"
* In the Chrome menu bar, select Chrome>Warn before quitting
* Open Chrome developer tools, go to Settings, and under appearance, select "Dark theme"
* Open System Preferences > Trackpad and uncheck "Swipe between pages", then change
  "Swipe between full-screen apps" to "three fingers". This disables the annoying
  swipe-for-back behavior in Chrome and restores the easier 3-finger swipe gesture
  for switching workspaces.
* Change the login shell
  * In System Preferences>Users & Groups, unlock then right click on your user and select "Advanced Options"
  * Change "Login shell" to `/usr/local/bin/bash`
* In System Preferences>Keyboard>Shortcuts, disable all of the shortcuts involving ctrl. A bunch of them are used by VSCode, but Apple decided it'd be better to use them for switching spaces.

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
* Add Stylish css (Chrome)
* .jq
* .vimrc
* .virtualenvwrapperrc
* python packages
* iTerm (Preferences>General>Load preferences from custom folder or URL)
* .gitconfig
* bash config

## Short-term Todo
* [x] Add new stuff (bettertouchtool for instance)
* [x] sync new git hooks setup
* [x] sync pgcli config
* [x] Update installation instructions for github dark style (use usercss) and other stylus config
* [x] Add vscode finder automator script
* [ ] Sync vscode settings: like with sublime, using symlinks screws up reloading. Maybe use hardlinks?
* [x] Remove sublime text

## Long-term Todo
* [ ] Make all bash use strict mode and all function variables local
* [ ] check for package upgrades 1/day
* [x] Look into replacing brew-packages.sh with a Brewfile? See brew bundle --help for details
* [ ] https://github.com/clvv/fasd (or one of the other tools linked therein) might have better tab completion than autojump
* [ ] Remove virtualenvwrapperrc since the newest release has a lazy script
* [ ] custom jupyter color scheme? Or use vscode jupyter notebook integration
* [ ] ipython-sql
* [ ] separate out python packages:
  * [ ] pgcli et al with pipsi
  * [ ] "scratch" venv with jupyter, boto, etc.
  * [ ] what to do with pudb?
* [ ] iTerm2 custom title script

## Deprecated todos
* Sublime likes to reformat the prefs and remove comments. Find a workaround?
  * Maybe gitattributes and textconv: http://t-a-w.blogspot.com/2016/05/sensible-git-diff-for-json-files.html
* Find vscode plugins to:
  * remove matching brackets
  * split selection on words (rather than lines)
* For macbooks with force touch, set force threshold to "Firm" in System Preferences, then run `defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold 1` to make force touch a little lighter
  * Maybe figure out what some of the other keys do like `ActuateDedents`
* Distribute modified Ansible package
