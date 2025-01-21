# Handy docker aliases
if $(which -s docker); then
    alias dtmp='docker run -it --rm'
    alias dclean='docker system prune --volumes'
fi

# Bash completion
for p in "$HOMEBREW_PREFIX"/etc/bash_completion.d/*.bash-completion; do
  if ! [ -L "$p" ]; then
    ln -s /Applications/Docker.app/Contents/Resources/etc/"$(basename "$p" .docker-completion)"  "$p" 
  fi
done
