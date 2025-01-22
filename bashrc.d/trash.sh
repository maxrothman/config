# Alias `rm` to `trash` <http://hasseg.org/trash/>
# Yeah, yeah, I know this is a "Bad Idea" but I've been burned too many times.
# If you really want to delete something, you can just use `\rm`.

if [ -f "$HOMEBREW_PREFIX"/opt/trash/bin/trash ]; then
  export PATH="$HOMEBREW_PREFIX/opt/trash/bin:$PATH"
  alias rm=trash
fi