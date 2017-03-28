# Launch a Mac notification using iTerm2's magic escape codes
# Usage: notify <message>
notify() {
  echo -ne "\e]9;${*}\007"
}