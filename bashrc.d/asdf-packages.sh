# npm completion > ~/.npm/completion
if [ -f ~/.npm/completion ]; then
  . ~/.npm/completion
fi

if [ -d "$HOMEBREW_PREFIX/opt/asdf" ]; then
  . "$HOMEBREW_PREFIX"/opt/asdf/bin/asdf
fi
