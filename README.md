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

## Short-term Todo
* [ ] fix/sync quick-look extensions (don't work on Catalina)

## Long-term Todo
* [ ] Investigate https://github.com/python-mario/mario as a more featureful and better-maintained replacement for pythonpy
* [ ] Read vscode release notes and see if there's anything I should do differently
* [ ] Look into other vscode extensions and configs in other-peoples-vscode-extensions
* [ ] Make all bash script function variables local (can't use strict mode without changing my shell
  settings)
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
* [ ] Get lastpass working
  * Hotkey broken:
    * https://forums.lastpass.com/viewtopic.php?f=12&t=272815&start=20
    * https://forums.lastpass.com/viewtopic.php?f=12&t=349985&p=1192855&hilit=mac#p1192855
  * Hide from apps
* [ ] Retire fork of iterm2 shell integration: the patch has been merged (but the need for the hack is not: https://gitlab.com/gnachman/iterm2/issues/5964#note_284811201

## Deprecated todos
* Sublime likes to reformat the prefs and remove comments. Find a workaround?
  * Maybe gitattributes and textconv: http://t-a-w.blogspot.com/2016/05/sensible-git-diff-for-json-files.html
* Find vscode plugins to:
  * remove matching brackets
  * split selection on words (rather than lines)
* For macbooks with force touch, set force threshold to "Firm" in System Preferences, then run `defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold 1` to make force touch a little lighter
  * Maybe figure out what some of the other keys do like `ActuateDedents`
* Distribute modified Ansible package
