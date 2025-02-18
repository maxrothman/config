if [ -d "$HOMEBREW_PREFIX/opt/asdf" ]; then
  export PATH="{ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
  . <(asdf completion bash)
fi

# npm completion > ~/.npm/completion
if [ -f ~/.npm/completion ]; then
  . ~/.npm/completion
fi

