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
* Sublime Text: Sublime configuration files. Will be hardlinked to their appropriate locations.
* apps.md: apps to manually install
* deploy.sh: a script for automatically deploying the parts of this repo that can be automated.
* automator: add buttons to Finder that open apps via Apple automator

## Setup instructions:
* Install the apps in apps.md
* Follow the instructions in the README in automator/
* Run deploy.sh
* Update ~/.gitconfig with your name, email address, and optionally, where you'd like to store your hooks.
* Install brew: <http://brew.sh/>
* Run all the scripts in misc-scripts except pre-push
* Copy pre-push to where your hooksPath points in gitconfig
* Follow the instructions in Alfred.alfredpreferences/README.md
* TODO: karabiner
* Install the 
  [Stylish Chrome plugin](https://chrome.google.com/webstore/detail/stylish/fjnbnpbmkenffdnngjfgmeleoegfcffe?hl=en)
  and copy-paste the styles in stylish/ into it, using the matching paths noted in
  the file headers

##Complete
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

##Todo
* Remove virtualenvwrapperrc since the newest release has a lazy script
* Write manage script that reads locations, diffs things, warns, then hardlinks files into place
  * Should write a default ~/.bash-secure
* Distribute modified Ansible package
* Should prompt for:
  * gitconfig user.name and user.email
* Sublime plugin to split selection on words (rather than lines)
* Maybe rewrite prompt in python or something else for performance?
* Find sublime plugins to:
  * remove matching brackets
  * stop giving syntax errors for print(s, end=something) in python3
* check for package upgrades 1/day