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
problems=false
for f in "$configdir"/dotfiles/*; do
  #Ignore ignoreable files
  if git --git-dir "$configdir"/.git check-ignore "$f"; then
    continue
  fi

  base_name="$(basename "$f")"
  if [[ ! -e ~/."${base_name}" ]]; then
    ln -s "$f" ~/."${base_name}"
  elif [[ -L ~/."${base_name}" && "$(readlink ~/."${base_name}")" == "$f" ]]; then
    :   #it's already synced
  else
    echo "Refusing to overwrite ~/.${base_name}, already exists! Resolve differences then rerun this script."
    problems=true
  fi
done
$problems && exit 1

#LEFT OFF: ran brew script, ran deploy up to here. No other scripts.
echo 'Deploying bin...'
if [[ ! -e ~/.bin ]]; then
  ln -s "$configdir"/bin ~/.bin
elif [[ -L ~/.bin && "$(readlink ~/.bin)" == "$configdir"/bin ]]; then
  :   #it's already synced
else
  echo "Refusing to overwrite ~/.bin, already exists or is a different symlink! Resolve differences then rerun this script."
  exit 1
fi

echo 'Deploying Sublime configs'
problems=false
sublimepath=~/Library/"Application Support"/"Sublime Text 3"/
find "$configdir"/"Sublime Text" -type f -print0 | while read -d $'\0' f; do
  relpath="${f#"$configdir"/"Sublime Text/"}"    #get the path relative to the root
  
  #Ignore ignoreable files
  if git --git-dir "$configdir"/.git check-ignore "$f"; then
    continue
  elif [[ "$relpath" == 'packages.txt' ]]; then   #this is just the list of packages to install
    continue
  fi

  if [[ ! -e "$sublimepath"/"$relpath" ]]; then
    ln -s "$f" "$sublimepath"/"$relpath"
  elif [[ -L "$sublimepath"/"$relpath" && "$(readlink "$sublimepath"/"$relpath")" == "$f" ]]; then
    :   #it's already synced
  else
    echo "Refusing to overwrite $sublimepath/$relpath, already exists! Resolve differences then rerun this script."
    problems=true
  fi
done
$problems && exit 1

# Make bash-secure with proper git env vars
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