#!/usr/bin/env bash

#Installs all brew packages
packages=(
#   homebrew/boneyard/apg # Secure password generator. Removed from formulas?
  autojump                                   # cd on steroids: <https://github.com/wting/autojump>
  bash                                       # Update to latest
  bash-completion                            # Basic tab completion
  coreutils                                  # Make Mac more Linux-y
  cowsay                                     # Moo
  fzf                                        # fuzzyfinder: https://github.com/junegunn/fzf
  git                                        # Update to newest on older systems
  gnu-sed                                    # BSD sed is weird (on Mac)
  gpatch
  "homebrew/dupes/grep --with-default-names" # BSD grep is also weird (on Mac)
  htop-osx                                   # Gotta have htop
  jq                                         # JSON parsing tool: <https://stedolan.github.io/jq/>
  nmap                                       # Mac really doesn't ship with this?!
  pip-completion                             # Bash completion for pip
  pstree                                     # Gives you something like ps f on linux since there's no f on mac
  python                                     # Update to 2.7.10 which fixes major SSL flaws
  python3                                    # If only this were default
  rename                                     # Mass file renaming
  sl                                         # Choo choo!
  source-highlight                           # For `less` syntax highlighting
  telnet                                     # Not part of coreutils for some reason
  the_silver_searcher                        # provides ag for fast recursive searches
  tig                                        # git curses client
  trash                                      # rm-like command that moves things to the trash (I may be a monster, but I'm a cautious monster)
  tree                                       # Tree view of file structures
  watch                                      # Gotta have watch
  wget                                       # Mac really doesn't ship with this?!
)

for package in "${packages[@]}"; do
  brew install $package
done

#Install fzf hooks
/usr/local/opt/fzf/install
