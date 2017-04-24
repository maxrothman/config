# Always open sublime text in a new window
if [[ -e /Users/max/Applications/Sublime\ Text.app/Contents/SharedSupport/bin ]]; then
  export PATH=/Users/max/Applications/Sublime\ Text.app/Contents/SharedSupport/bin:"$PATH"
else
  export PATH=/Applications/Sublime\ Text.app/Contents/SharedSupport/bin:"$PATH"
fi
alias subl='subl -n'
