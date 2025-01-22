#!/usr/bin/env bash
set -euo pipefail

# Deploy this repo onto this computer

# Location of the config repo
# This magic gets the location of the current script
configdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo 'Deploying bashrc.d...'
if [[ ! -e ~/.bashrc.d && -L ~/.bashrc.d ]]; then
  ln -s "$configdir"/bashrc.d ~/.bashrc.d
elif [[ -L ~/.bashrc.d && "$(readlink ~/.bashrc.d)" == "$configdir"/bashrc.d ]]; then
  :   #it's already synced
else
  echo "Refusing to overwrite ~/.bashrc.d, already exists or is a different symlink! Resolve differences then rerun this script."
  exit 1
fi

echo 'Deploying dotfiles...'
dot_loc="$configdir"/dotfiles
problems=false
find "$dot_loc" -type f -print0 | while IFS= read -r -d '' f; do
  #Ignore ignoreable files
  if git --git-dir "$configdir"/.git check-ignore "$f"; then
    continue
  fi

  base_name="${f#"$dot_loc"}"  # Remove the prefix leaving the bare filename/path
  base_name="${base_name#/}"   # Remove leading slash

  if [[ ! -f ~/."${base_name}" ]]; then
    # If it's a directory, add the parents
    if [[ "$base_name" == */* ]]; then
      mkdir -p ~/."$(dirname $base_name)"
    fi
    
    echo "Deploying ~/.${base_name}"
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
if [[ ! -e ~/.bin && -L ~/.bin ]]; then
  ln -s "$configdir"/bin ~/.bin
elif [[ -L ~/.bin && "$(readlink ~/.bin)" == "$configdir"/bin ]]; then
  :   #it's already synced
else
  echo "Refusing to overwrite ~/.bin, already exists or is a different symlink! Resolve differences then rerun this script."
  exit 1
fi

echo "Deploying git hooks..."
# Mac's default ln has no -T
if [[ ! -e ~/repos/.git-hooks && -L ~/repos/.git-hooks ]]; then
  ln -s "$configdir"/git-hooks ~/repos/.git-hooks
elif [[ -L ~/.bashrc.d && "$(readlink ~/.bashrc.d)" == "$configdir"/bashrc.d ]]; then
  :   #it's already synced
else
  echo "Refusing to overwrite ~/repos/.git-hooks, already exists or is a different symlink! Resolve differences then rerun this script."
  exit 1
fi

echo "Deploying joyride script..."
jrdir=~/.config/joyride/scripts
if [ ! -d "$jrdir" ]; then
  mkdir -p "$jrdir"
fi
if [ ! -e "$jrdir"/user_activate.cljs && -L "$jrdir"/user_activate.cljs ]; then
  ln -s "$configdir"/misc-stuff/user_activate.cljs "$jrdir"/user_activate.cljs
elif [[ -L "$jrdir"/user_activate.cljs && "$(readlink "$jrdir"/user_activate.cljs)" == "$configdir"/misc-stuff/user_activate.cljs ]]; then
  :    # already synced
else
  echo "Refusing to overwrite ${jrdir}/user_activate.cljs, already exists or is a different symlink! Resolve differences then rerun this script."
fi
