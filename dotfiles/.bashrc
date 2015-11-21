# Main bash user config file
# Assumes Mac OSX
# Requirements:
#   - Mac OSX
#   - Using brew <http://brew.sh> as your primary package manager
#   - iTerm2
# Location: ~/.bashrc

#add timestamps to bash history
export HISTTIMEFORMAT='%F %T '

#Turn on colors
alias grep='grep --color'
alias ls='ls --color'

#Common ls aliases
alias ll='ls -lArth'
alias la='ls -A'

#Launch a Mac notification
#Usage: notify <message>
#Requirements: iTerm2
notify() {
  echo -ne "\e]9;${*}\007"
}

#Handy git aliases
lastm() { git --no-pager log --merges -n1 --format='%H'; }
lastp() { git --no-pager rev-parse "@{u}"; }
alias gitcd='cd $(git rev-parse --show-toplevel)'
  

#-- Prompt --
#Features:
# - Shortened path
#   Examples:
#     - /movies -> movies
#     - /movies/starwars/characters/lukeskywalker -> /movies/.../characters/lukeskywalker
# - Switches to "git mode" when in a git repo
#   e.g. myrepo +(master): -/subdir $
#         ^     ^   ^         ^
#         |     |   |         |
#     repo name | branch name |
#               |      path from top of repo
#        ahead of remote
#
#   - Features:
#     - Shows repo name and branch name
#     - + if ahead of remote, - if behind, !! if local and remote have diverged
#     - Branch name changes color to indicate status:
#       - Yellow if untracked changes
#       - Red if ready to commit
#       - Green if clean
#       - Red if in detached HEAD state
#     - Shows path relative to top of repo
#
#TODO: perhaps shorten with __git_ps1? (provided by git-completion.sh)
#<https://github.com/git/git/blob/master/contrib/completion/git-completion.bash>

#Get color aliases (e.g. $Green, $BBlue, $Nocolor, etc.)
source ~/.bash-colors

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
  echo "${BGreen}${shortened}${NoColor}"
}

user_at_loc () {
  echo "${BBlue}\u${NoColor}@${BPurple}\h${NoColor}"
}

git_prompt () {
  git_branch=$(git symbolic-ref HEAD 2>&1)
  r=$?
  if [ "$git_branch" = "fatal: ref HEAD is not a symbolic ref" ]; then 
    echo "${Red}???${NoColor} "
  
  elif [ $r -eq 0 ]; then
    git_branch="${git_branch#refs/heads/}"
    s=`/usr/bin/git status`
    
    if grep -q "ahead of" <<<"$s"; then
      symbol="+"
    elif grep -q "behind" <<<"$s"; then
      symbol="-"
    elif grep -q "diverged" <<<"$s"; then
      symbol='!!'
    fi

    if grep -q "nothing to commit" <<<"$s"; then
      git_branch="${Green}($git_branch)${NoColor}"
    elif grep -q -E "Untracked files|not staged" <<<"$s"; then
      git_branch="${Yellow}($git_branch)${NoColor}"
    elif grep -q "Changes to be committed" <<<"$s"; then
      git_branch="${Red}($git_branch)${NoColor}"
    fi
    
    [ -n "$git_branch" ] && echo "${BYellow}${symbol}${NoColor}${git_branch}"
  fi
}

git_branch () {
  toplevel=$(git rev-parse --show-toplevel)
  echo "${BPurple}"$(basename "$toplevel")"${NoColor}"
}

git_path () {
  toplevel="$(git rev-parse --show-toplevel)"
  shortened=-$([ "$toplevel" != "$PWD" ] && shorten_path ${PWD#$toplevel})
  echo "${BGreen}$shortened${NoColor}"
}

set_prompt () {
  gitstuff=$(git_prompt)
  if [ -n "$VIRTUAL_ENV" ]; then
    venv="${Yellow}!${NoColor} "
  else
    venv=""
  fi

  if [ -n "$gitstuff" ]; then
    prompt="$(git_branch) $(git_prompt): $(git_path)"
  else
    prompt="$(user_at_loc): $(shorten_path)"
  fi
  export PS1="${venv}${prompt} ${BBlue}\$${NoColor} "
}

[ -n "$PROMPT_COMMAND" ] \ 
  && PROMPT_COMMAND="$PROMPT_COMMAND; set_prompt" \
  || PROMPT_COMMAND="set_prompt"

export SUDO_PS1="${IWhite}${On_Red}\u@\h: \W#${NoColor} "


#Include external stuff
source .bash-external