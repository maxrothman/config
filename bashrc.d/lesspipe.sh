# Add syntax highlighting to less via gnu source-highlight
# See src-highlight-lesspipe for details

ex="$(which highlight)"
if [ -x "$ex" ]; then
  export LESSOPEN="| $ex %s --out-format=xterm256 --style=leo"
  export LESS=' -R '
fi

