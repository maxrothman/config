# config
A repository for various pieces of workstation setup: dotfiles, configs, extensions, etc.

# WARNING: SUBLIME SETTINGS CURRENTLY DON'T SYNC. Apparently settings don't reload properly when the file is a symlink.

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
* Sublime Text: Sublime configuration files. Will be hardlinked to their appropriate locations.
* apps.md: apps to manually install
* deploy.sh: a script for automatically deploying the parts of this repo that can be automated.
* automator: add buttons to Finder that open apps via Apple automator

## Setup instructions:
* Clone this repo somewhere
* Install the apps in apps.md
  * For Alfred, iTerm, etc. where the config is in this repo, follow the instructions in their READMEs to use said config.
  * Some stuff for iTerm isn't saved in config, particularly keybindings. Add the following:
    * In Profiles>Default>Keys, set "Left option key acts as" to +Esc
    * In Profiles>Default>Keys, change ⌥→ to "Send Escape Sequence" and "f"
    * In Profiles>Default>Keys, change ⌥← to "Send Escape Sequence" and "b"
    * In the menu, run "Install shell integration"
  * Open Chrome, and in the menu bar, select Chrome>Warn before quitting
  * Open Chrome developer tools, go to Settings, and under appearance, select "Dark theme"
  * Open System Preferences > Trackpad and uncheck "Swipe between pages", then change
    "Swipe between full-screen apps" to "three fingers". This disables the annoying
    swipe-for-back behavior in Chrome and restores the easier 3-finger swipe gesture
    for switching workspaces.
* Install all the plugins in `Sublime Text/packages.txt`
* Follow the instructions in the README in automator/
* Install brew: <http://brew.sh/>
* Run all the scripts in misc-scripts except pre-push starting with brew-packages.bash
* Change the login shell
  * In System Preferences>Users & Groups, unlock then right click on your user and select "Advanced Options"
  * Change "Login shell" to `/usr/local/bin/bash`
* Run deploy.sh
* Copy pre-push to where your hooksPath points in gitconfig
* TODO: karabiner
* Install the 
  [Stylish Chrome plugin](https://chrome.google.com/webstore/detail/stylish/fjnbnpbmkenffdnngjfgmeleoegfcffe?hl=en)
  and copy-paste the styles in stylish/ into it, using the matching paths noted in
  the file headers
  * The stylish/README.md has more info on how to install these
* In System Preferences>Keyboard>Shortcuts, disable all of the shortcuts involving ctrl. A bunch of them are used by Sublime, but Apple decided it'd be better to use them for switching spaces.

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
* Upgrade all sublime packages
* Add sublime configs and custom color scheme
* .gitconfig
* bash config

## Todo
* Make all bash use strict mode and all function variables local
* Remove virtualenvwrapperrc since the newest release has a lazy script
* Distribute modified Ansible package
* Sublime plugin to split selection on words (rather than lines)
* Find sublime plugins to:
  * remove matching brackets
  * stop giving syntax errors for print(s, end=something) in python3
* check for package upgrades 1/day
* For macbooks with force touch, set force threshold to "Firm" in System Preferences, then run `defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold 1` to make force touch a little lighter
  * Maybe figure out what some of the other keys do like `ActuateDedents`
* Add new stuff (bettertouchtool for instance)
* Sublime likes to reformat the prefs and remove comments. Find a workaround?
  * Maybe gitattributes and textconv: http://t-a-w.blogspot.com/2016/05/sensible-git-diff-for-json-files.html
* Look into replacing brew-packages.sh with a Brewfile? See brew bundle --help for details
