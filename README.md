# config
A repository for various pieces of workstation setup: dotfiles, configs, extensions, etc.

## Contents
* bashrc.d: All executable files in here will be sourced by ~/.bashrc. Each file is
  self-explanatory. This directory will be symlinked to ~/.bashrc.d.
* bin: executables that are used by code in bashrc.d. This directory will be
  symlinked to ~/.bin
* dotfiles: configuration files that various applications expect to be in ~/. Each
  file will be symlinked to ~/.$FILE (e.g. bashrc -> ~/.bashrc).
* misc-stuff: Files used once during setup.
* manual.md: stuff to manually install
* deploy.sh: a script for automatically deploying the parts of this repo that can be automated.
* automator: add buttons to Finder that open apps via Apple automator
* VSCode: VSCode configs and a list of extensions to install
* git-hooks: My flexible git-hooks setup that allows for multiple global and repo-local hooks of the
  same type. Mostly used to turn my pre-push hook on for all repos.

## Setup instructions:
* Clone this repo somewhere
* Install brew: <http://brew.sh/>
* Run `deploy.sh` (idempotent)
* Run `misc-scripts/misc-setup.bash` (not idempotent)
* Install apps listed in `apps.md` as needed
* Follow the instructions in `manual.md`
* Follow the instructions in `Alfred.alfredpreferences/README.md`
* Follow the instructions in the README in `automator/`

## TODO
* go through misc-stuff

## Short-term Todo
* [ ] Install clojure lang def for source-highlight
  * See
    https://github.com/clojure-cookbook/clojure-cookbook/blob/master/script/asciidoc/bootstrap.sh
    for installation instructions, use lang def from
    https://gist.github.com/alandipert/265810/
  * Also: where does /usr/local/bin/src-hilite-lesspipe.sh come from? I have a custom one in ~/.bin

## Long-term Todo
* [ ] Look into other vscode extensions and configs in other-peoples-vscode-extensions
* [ ] https://github.com/clvv/fasd (or one of the other tools linked therein) might have better tab completion than autojump
* [ ] iTerm2 custom title script (on iterm-custom-titles branch)

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
