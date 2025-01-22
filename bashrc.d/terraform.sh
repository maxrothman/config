if [ -f "$HOMEBREW_PREFIX"/bin/terraform ]; then
    complete -C "$HOMEBREW_PREFIX"/bin/terraform terraform
fi
