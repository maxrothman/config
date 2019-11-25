# Handy docker aliases
if $(which -s docker); then
    alias dtmp='docker run -it --rm'
    alias dclean='docker system prune --volumes'
fi
