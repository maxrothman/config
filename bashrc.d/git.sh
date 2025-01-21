# Handy git aliases
lastm() { git --no-pager log --merges -n1 --format='%H'; }  #commits since last merge
lastp() { git --no-pager rev-parse "@{u}"; }                #commits since last push
alias gcd='cd $(git rev-parse --show-toplevel)'             #cd to top of repo

#common ancestor with master
gbase() { git merge-base $(git config --get myconfig.main-branch) @; }

#I'm so lazy I don't even want to type the space in git commands
#TODO: fix completion
command_not_found_handle() {
  if [ "${1:0:1}" = 'g' ]; then
    git ${1:1} ${@:2}
  else
    #Prevent infinite recursion. Luckily this applies only in this scope.
    unset -f command_not_found_handle
    $@
  fi
}

alias g=git

# gs conflicts with ghostscript. I never use ghostscript directly, so I'm fine
# with shadowing it
alias gs='git status'

# Visually highlight changes inside lines
# Normally these would go in .gitconfig, but they need to be here so the path to git can be dynamic
git config pager.log  "$BREW_PREFIX/share/git-core/contrib/diff-highlight/diff-highlight | less"
git config pager.show "$BREW_PREFIX/share/git-core/contrib/diff-highlight/diff-highlight | less"
git config pager.diff "$BREW_PREFIX/share/git-core/contrib/diff-highlight/diff-highlight | less"
git config interactive.diffFilter "$BREW_PREFIX/share/git-core/contrib/diff-highlight/diff-highlight"
