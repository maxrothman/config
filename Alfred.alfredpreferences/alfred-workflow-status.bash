HELP="Shows Alfred workflow status in this directory
Outputs 3 columns of data: path, tracking status, and name

Path: the path to the workflow files, including the ID assigned to the 
workflow by Alfred. AFAIK, IDs are not universal, so uninstalling and
reinstalling the workflow might change this field.

Tracking status: whether or not this field is tracked by this git repo

Name: the name of the workflow

Usage:
  --help  show this message and exit"

[ "$1" = "--help" ] && echo "$HELP" && exit

printf '%30s %39s  %2s\n' 'Path' 'Tracked' 'Name'
for i in `find workflows -name info.plist`; do
  path="$(dirname $i)"
  tracked="$(git ls-files --error-unmatch $i &>/dev/null && echo yes || echo 'no')"
  name="$(/usr/libexec/PlistBuddy -c 'Print name' $i)"
  printf '%61s %8s  %s\n' "$path" "$tracked" "$name"
done
