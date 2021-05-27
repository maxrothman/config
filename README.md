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
* Follow the instructions in `manual.md`
* Follow the instructions in `Alfred.alfredpreferences/README.md`
* Follow the instructions in the README in `automator/`

## Short-term Todo
* [ ] Install clojure lang def for source-highlight
  * See
    https://github.com/clojure-cookbook/clojure-cookbook/blob/master/script/asciidoc/bootstrap.sh
    for installation instructions, use lang def from
    https://gist.github.com/alandipert/265810/
  * Also: where does /usr/local/bin/src-hilite-lesspipe.sh come from? I have a custom one in ~/.bin
* [ ] fix/sync quick-look extensions (don't work on Catalina)

## Long-term Todo
* Build a better timer alfred workflow with not shitty sounds
* [ ] Investigate https://github.com/python-mario/mario as a more featureful and better-maintained replacement for pythonpy
  * Or just use babashka?
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

## Troubleshooting bash prompt performance problems
My bashrc setup is complex enough that performance can be an issue. This repo contains a few tools
for troubleshooting such issues:
* Run `__bashrc_bench=1 bash -i` to time the evaluation of each file in `bashrc.d/`
* To troubleshoot performance issues within a file:
  * Add the following lines to the file:
    ```bash
    # At the very top
    PS4='+ $(date "+%s.%N")\011 '
    exec 3>&2 2>/tmp/bashstart.$$.log
    set -x

    ...

    # At the very bottom
    set +x
    exec 2>&3 3>&-
    ```
  * Source the instrumented file. This will create a file `/tmp/bashstart.XXXX.log`, where `XXXX` is
    the PID of the process.
  * Some of the logged lines in the bashstart file contain newlines, which interferes with the next
    step. Edit the file to collapse those into single lines or simply remove the extra lines. Once
    you're done, every line should look something like this:
    ```
    ++++ 1606154722.825342000	 __git_merge_strategies=
    ```
  * Run `bin/bash-format-perf < bashstart.XXXX.log > formatted.log` to change the absolute
    timestamps in the perf log into relative timings
  * To find the most expensive lines, you might want to edit `formatted.log` to remove the `+`s and
    run `sort -n` on it.


### References
* https://danpker.com/posts/2020/faster-bash-startup/
* https://work.lisk.in/2020/11/20/even-faster-bash-startup.html
* https://stackoverflow.com/questions/5014823/how-to-profile-a-bash-shell-script-slow-startup/20855353
