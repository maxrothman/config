#!/usr/bin/env bash
set -euo pipefail

# Deploy this repo onto this computer

# Location of the config repo
# This magic gets the location of the current script
configdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo 'Deploying bashrc.d...'
if [[ ! -e ~/.bashrc.d ]]; then
  ln -s "$configdir"/bashrc.d ~/.bashrc.d
elif [[ -L ~/.bashrc.d && "$(readlink ~/.bashrc.d)" == "$configdir"/bashrc.d ]]; then
  :   #it's already synced
else
  echo "Refusing to overwrite ~/.bashrc.d, already exists or is a different symlink! Resolve differences then rerun this script."
  exit 1
fi

echo 'Deploying dotfiles...'
dot_loc="$configdir"/dotfiles/
problems=false
find "$dot_loc" -type f -print0 | while IFS= read -r -d '' f; do
  #Ignore ignoreable files
  if git --git-dir "$configdir"/.git check-ignore "$f"; then
    continue
  fi

  base_name="${f#"$dot_loc"}"  # Remove the prefix leaving the bare filename/path
  if [[ ! -f ~/."${base_name}" ]]; then
    # If it's a directory, add the parents
    if [[ "$base_name" == */* ]]; then
      mkdir -p ~/."$(dirname $base_name)"
    fi
    
    ln -s "$f" ~/."${base_name}"
  elif [[ -L ~/."${base_name}" && "$(readlink ~/."${base_name}")" == "$f" ]]; then
    :   #it's already synced
  else
    echo "Refusing to overwrite ~/.${base_name}, already exists! Resolve differences then rerun this script."
    problems=true
  fi
done
$problems && exit 1

echo 'Deploying bin...'
if [[ ! -e ~/.bin ]]; then
  ln -s "$configdir"/bin ~/.bin
elif [[ -L ~/.bin && "$(readlink ~/.bin)" == "$configdir"/bin ]]; then
  :   #it's already synced
else
  echo "Refusing to overwrite ~/.bin, already exists or is a different symlink! Resolve differences then rerun this script."
  exit 1
fi

# Make bash-secure with proper git env vars
echo "Creating .bash-secure: a place for configs you don't want checked into the config repo."
if [[ ! -e ~/.bash-secure ]]; then
  echo 'Name? (e.g. Tom Tickle)'
  read -r -p '> ' gitname
  echo 'Email address? (e.g. tom@tickle.me)'
  read -r -p '> ' gitemail
  echo 'Deploying sample bash-secure'
  cat <<EOF > ~/.bash-secure
export GIT_AUTHOR_NAME="$gitname"
export GIT_AUTHOR_EMAIL="$gitemail"
export GIT_COMMITTER_NAME="$gitname"
export GIT_COMMITTER_EMAIL="$gitemail"

# Add things to this file that you don't want to check in to git
# For example:
# if [ -f some/other/script.sh ]; then
# source some/other/script.sh
# export some_variable="a value"
# fi

EOF
else
  echo "Not writing ~/.bash-secure, one already exists"
fi

echo "Deploying git hooks..."
ln -Ts "$configdir"/git-hooks ~/repos/.git-hooks

# Install brew packages and casks
brew bundle install --global
