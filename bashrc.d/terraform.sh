if [ -f "$BREW_PREFIX"/bin/terraform ]; then
    complete -C "$BREW_PREFIX"/bin/terraform terraform
fi
