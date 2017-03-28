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
# Use hardlinks to avoid any issues where programs won't follow symlinks
problems=false
for f in "$configdir"/dotfiles/*; do
  #Ignore ignoreable files
  if git --git-dir "$configdir"/.git check-ignore "$f"; then
    continue
  fi

  base_name="$(basename "$f")"
  if [[ ! -e ~/."${base_name}" ]]; then
    ln "$f" ~/."${base_name}"
  elif [[ "$f" -ef ~/."${base_name}" ]]; then
    :   #it's already synced
  else
    echo "Refusing to overwrite ~/.${base_name}, already exists! Resolve differences then rerun this script."
    problems=true
  fi
done
$problems && exit 1

# Set values in gitconfig
echo 'The following two values will be added to your .gitconfig'
echo 'Name? (e.g. Tom Tickle)'
read -r -p '> ' gitname
echo 'Email address? (e.g. tom@tickle.me)'
read -r -p '> ' gitemail
sed -i "s/name = <UPDATE-ME>/name = $gitname/" ~/.gitconfig
sed -i "s/email = <UPDATE-ME>/email = $gitemail/" ~/.gitconfig

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
    ln "$f" "$sublimepath"/"$relpath"
  elif [[ "$f" -ef "$sublimepath"/"$relpath" ]]; then
    :   #it's already synced
  else
    echo "Refusing to overwrite $sublimepath/$relpath, already exists! Resolve differences then rerun this script."
    problems=true
  fi
done
$problems && exit 1

echo 'Deploying sample bash-secure'
cat <<EOF > ~/.bash-secure
# Add things to this file that you don't want to check in to git
# For example:
# if [ -f some/other/script.sh ]; then
# source some/other/script.sh
# export some_variable="a value"
# fi

EOF