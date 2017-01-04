#!/usr/bin/env/bash

#My extensions to the standard src-hilite-lesspipe.sh provided by gnu source-highlite
# <http://www.gnu.org/software/src-highlite/>
#
#Adds an environment variable SOURCE_HIGHLIGHT_BASH_EXT that defines additional specific files
# that should be highlighted as bash in less. See .bashrc for an example.
#
# Install: just stick it somewhere and point LESSPIPE at it (see bashrc.d/lesspipe.sh).
#   Don't overwrite where brew puts the default script or you'll end up fighting with it.

for source in "$@"; do
  case $source in
    *ChangeLog|*changelog) 
      source-highlight --failsafe -f esc --lang-def=changelog.lang --style-file=esc.style -i "$source" ;;
    *Makefile|*makefile) 
      source-highlight --failsafe -f esc --lang-def=makefile.lang --style-file=esc.style -i "$source" ;;
    *)
      if grep -q `basename $source` <<< $SOURCE_HIGHLIGHT_BASH_EXT; then
        source-highlight --failsafe -f esc --lang-def=sh.lang --style-file=esc.style -i "$source"
      else
        source-highlight --failsafe --infer-lang -f esc --style-file=esc.style -i "$source"
      fi
    ;;
  esac
done
