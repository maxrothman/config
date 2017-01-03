# Command output caching tool

_command_cache_dir="$(mktemp -d)"
trap '\rm -rf "$_command_cache_dir"' EXIT
alias faketty='script -q /dev/null '    #required to make bash expand aliases in the command, note trailing space

cache() {
  help='  Usage: cache [-vfh] [--] COMMAND
  
    Caches STDOUT, STDERR, and exit code returned by COMMAND
    such that if "cache COMMAND" is called again, cache simply
    replays the cached values without running COMMAND.
  
    Caches are shell- and command-specific, meaning each shell has
    its own cache, and calling a command with different arguments
    counts as a new command for the cache. Interactive and non-interactive
    versions of commands are also cached separately.
  
    Options:
      -v    enable debug logging
      -f    flush the cache and store a new value for the current command
      -F    flush all caches. Must be run with no other arguments.
      -i    invalidate the cache for the current command without running the command
      -h    print this message and exit
  '

  # Argument parsing
  local verbose=0
  local flush=0
  local invalidate=0
  OPTIND=1
  while getopts 'vfFih' opt; do
    case "$opt" in
      v) verbose=1 ;;
      f) flush=1   ;;
      F) \rm -rf "$_command_cache_dir"/* ;;
      i) invalidate=1 ;;
      h) echo "$help"; return ;;
    esac
  done
  shift $((OPTIND-1))
  [[ "$1" = "--" ]] && shift

  # Some commands behave differently depending on whether STDOUT is another command
  # or not, so we have to cache interactive and non-interactive runs separately.
  [[ -t 1 ]] && local interactive='I-' || local interactive='NI-'

  # basically echo 'I-aws ec2 terminate-instances --id=i-12345678' | md5sum
  local key="$(md5sum <<<"${interactive}${@}" | cut -d' ' -f1)"
  local keyfile="${_command_cache_dir}/${key}"
  
  if [[ $invalidate == 1 ]]; then
    [[ $verbose == 1 ]] && echo "[cache] invalidating cache for \"$keyfile\"" >&2
    \rm -rf "$keyfile"*
    return 0
  fi

  if [[ -e "${keyfile}-exitcode" ]] && [[ $flush == 0 ]]; then
    [[ $verbose == 1 ]] && echo "[cache] cache hit for \"$key\"" >&2
  else
    [[ $verbose == 1 ]] && echo "[cache] cache miss for \"$key\"" >&2

    local interactive_cmd="$([[ "$interactive" == 'I-' ]] && echo 'faketty')"

    eval "${interactive_cmd} ${@}" > "${keyfile}-stdout" 2> "${keyfile}-stderr"
    echo "$?" > "${keyfile}-exitcode"
  fi

  [[ -e "${keyfile}-stdout" ]] && cat "${keyfile}-stdout"
  [[ -e "${keyfile}-stderr" ]] && cat "${keyfile}-stderr" >&2
  return $(cat "${keyfile}-exitcode")
}