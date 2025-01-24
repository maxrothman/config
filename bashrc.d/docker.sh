# Handy docker aliases
if $(which -s docker); then
    alias dtmp='docker run -it --rm'
    alias dclean='docker system prune --volumes'
fi

# Bash completion
for p in /Applications/Docker.app/Contents/Resources/etc/*.bash-completion; do
  lname="$(basename "$p")"
  if ! [ -L "$HOMEBREW_PREFIX/etc/bash_completion.d/$lname" ]; then
    ln -s "$p" "$HOMEBREW_PREFIX/etc/bash_completion.d/$lname"
  fi
done
