#!/usr/bin/env bash
set -euo pipefail

# Deploy this repo onto this computer

# Location of the config repo
# This magic gets the location of the current script
configdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

deploy() {
  local source="$1" dest="$2"

  #Ignore ignoreable files
  if git --git-dir "$configdir"/.git check-ignore "$source"; then
    return
  fi

  echo -n "Deploying $(basename "$source")..."
  # Mac's default ln has no -T
  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    # Create parents if they don't already exist
    if [[ "$dest" == */* ]]; then
      mkdir -p "$(dirname $dest)"
    fi
    ln -s "$source" "$dest"
    echo "Created $dest"
  elif [[ -L "$dest" && "$(readlink "$dest")" == "$source" ]]; then
    echo
    :    # already synced
  else
    echo
    echo "Refusing to overwrite $dest, already exists or is a different symlink! Resolve differences then rerun this script."
    return 1
  fi
}

deploy "$configdir"/bashrc.d ~/.bashrc.d

for f in "$configdir"/dotfiles/*; do
  deploy "$f" ~/."$(basename "$f")"
done

deploy "$configdir"/bin ~/.bin
deploy "$configdir"/git-hooks ~/repos/.git-hooks

jrdir=~/.config/joyride/scripts
for f in "$configdir"/misc-stuff/joyride/scripts/*; do
  deploy "$f" "$jrdir/$(basename "$f")"
done

deploy "$configdir"/misc-stuff/ignore ~/.config/git/ignore

deploy "$configdir"/misc-stuff/deps.edn ~/.clojure/deps.edn
