# Add syntax highlighting to less via gnu source-highlight
# See src-highlight-lesspipe for details

if [ -f ~/.bin/src-hilite-lesspipe.sh ]; then
  export LESSOPEN="| ~/.bin/src-hilite-lesspipe.sh %s"
  export LESS=' -R '

  # Extended source-highlight definitions. See src-hilite-lesspipe.sh for details.
  export SOURCE_HIGHLIGHT_BASH_EXT=".bashrc .profile"
fi