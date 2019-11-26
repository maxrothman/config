# Launch a Mac notification using iTerm2's magic escape codes
# Usage: notify <message>
notify() {
  echo -ne "\e]9;${*}\007"
}

# Used in custom titles
function iterm2_print_user_vars() {
  local git_repo_path="$(git rev-parse --show-toplevel 2>/dev/null)"
  local r=$? 
  if [ $r -eq 0 ]; then
    iterm2_set_user_var git_repo_path "$git_repo_path"
  fi
}
