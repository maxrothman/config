# -- Prompt --
# Features:
#  - Shortened path
#    Examples:
#      - /movies -> movies
#      - /movies/starwars/characters/lukeskywalker -> /movies/.../characters/lukeskywalker
#
#  - Switches to "git mode" when in a git repo
#    e.g. myrepo +(master): -/subdir $
#          ^     ^   ^         ^
#          |     |   |         |
#      repo name | branch name |
#                |      path from top of repo
#         ahead of remote
# 
#    - Features:
#      - Shows repo name and branch name
#      - + if ahead of remote, - if behind, !! if local and remote have diverged, ^ if not yet pushed
#      - Branch name changes color to indicate status:
#        - Yellow if untracked changes
#        - Red if ready to commit
#        - Green if clean
#        - Red if in detached HEAD state
#      - Shows path relative to top of repo
# 
# NB: bash_colors.sh must be sourced before this (luckily it comes first alphabetically)

# TODO: perhaps shorten with __git_ps1? (provided by git-completion.sh)
# <https://github.com/git/git/blob/master/contrib/completion/git-completion.bash>

export SUDO_PS1="${Color_IWhite}${Color_On_Red}\u@\h: \W#${Color_NoColor} "

shorten_path () {
  #arg: path to shorten (defaults to $PWD)
  path="${1:-$PWD}"
  shortened=$(echo "${path/#$HOME/\~}" | awk -F "/" '
    {if (length($0) > 35)
      {if (NF>4)
        print $1 "/" $2 "/.../" $(NF-1) "/" $NF;
      else if (NF>3) 
        print $1 "/" $2 "/.../" $NF; 
      else 
        print $1 "/.../" $NF; 
    } else 
      print $0;}
  ')
  echo "${Color_BGreen}${shortened}${Color_NoColor}"
}

user_at_loc () {
  echo "${Color_BBlue}\u${Color_NoColor}@${Color_BPurple}\h${NoColor}"
}

git_prompt () {
  local git_branch r s symbol

  git_branch=$(git symbolic-ref HEAD 2>&1)
  r=$?
  if [ "$git_branch" = "fatal: ref HEAD is not a symbolic ref" ]; then 
    echo "${Color_Red}???${Color_NoColor} "
  
  elif [ $r -eq 0 ]; then
    git_branch="${git_branch#refs/heads/}"
    s=`git status`
    
    if [ "$(git rev-parse --abbrev-ref @)" != "$(git rev-parse --abbrev-ref @{u} | cut -d/ -f2-)" ]; then
      # The `cut` is to shave off the "origin/" prefix
      symbol="${Color_Yellow}^${Color_NoColor}"
    elif grep -q "ahead of" <<<"$s"; then
      symbol="+"
    elif grep -q "behind" <<<"$s"; then
      symbol="-"
    elif grep -q "diverged" <<<"$s"; then
      symbol='!!'
    fi

    if grep -q -E "Untracked files|not staged" <<<"$s"; then
      git_branch="${Color_Yellow}($git_branch)${Color_NoColor}"
    elif grep -q "Changes to be committed" <<<"$s"; then
      git_branch="${Color_Red}($git_branch)${Color_NoColor}"
    else
      git_branch="${Color_Green}($git_branch)${Color_NoColor}"
    fi
    
    [ -n "$git_branch" ] && echo "${Color_BYellow}${symbol}${Color_NoColor}${git_branch}"
  fi
}

git_branch () {
  toplevel=$(git rev-parse --show-toplevel)
  echo "${Color_BPurple}"$(basename "$toplevel")"${Color_NoColor}"
}

git_path () {
  toplevel="$(git rev-parse --show-toplevel)"
  shortened=-$([ "$toplevel" != "$PWD" ] && shorten_path "${PWD#$toplevel}")
  echo "${Color_BGreen}$shortened${Color_NoColor}"
}

# See https://gitlab.com/gnachman/iterm2/issues/5964
# set_prompt () {
iterm2_generate_ps1 () {
  gitstuff=$(git_prompt)
  if [ -n "$VIRTUAL_ENV" ]; then
    venv="${Color_Yellow}!${Color_NoColor} "
  else
    venv=""
  fi

  if [ -n "$gitstuff" ]; then
    prompt="$(git_branch) ${gitstuff}: $(git_path)"
  else
    prompt="$(user_at_loc): $(shorten_path)"
  fi
  export PS1="${venv}${prompt} ${Color_BBlue}\$${Color_NoColor} "
}

# if [ -n "$PROMPT_COMMAND" ]; then
#   PROMPT_COMMAND="$PROMPT_COMMAND; set_prompt"
# else
#   PROMPT_COMMAND="set_prompt"
# fi
