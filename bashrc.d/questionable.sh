# Move /usr/local/bin before /usr/bin, /usr/sbin/, and /sbin so user executables
# can replace system ones.
# Uses Mac's default sed (since gnu-sed might not be in the path yet)
#
# TODO: is this still necessary? It was there for coreutils, but that's in coreutils.sh.
#
# if grep -q '/usr/local/bin' <<< "$PATH"; then
#   export PATH=`echo "$PATH" | sed -E 's|(.*):/usr/local/bin(.*)|/usr/local/bin:\1\2|'`
# fi