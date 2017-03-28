# Virtualenv and virtualenvwrapper stuff

export WORKON_HOME=~/.virtualenvs
export PROJECT_HOME=~
export VIRTUAL_ENV_DISABLE_PROMPT=1


# If you dont' want to use the lazy loading below, uncomment the line below:
#source /usr/local/bin/virtualenvwrapper.sh

####################################################################### 
# Dynamically load virtualenvwrapper functions to reduce shell startup
# time.
#
# Copyright 2012 Aron Griffis <aron@arongriffis.com>
# Released under the GNU GPL v3
####################################################################### 

# Python virtualenvwrapper loads really slowly, so load it on demand.
if [[ $(type -t workon) != function ]]; then
  virtualenv_funcs=( workon deactivate mkvirtualenv )

  load_virtualenv() {
    # If these already exist, then virtualenvwrapper won't override them.
    unset -f "${virtualenv_funcs[@]}"

    # virtualenvwrapper doesn't load if PYTHONPATH is set, because the
    # virtualenv python doesn't have the right modules.
    declare _pp="$PYTHONPATH"
    unset PYTHONPATH

    # Attempt to load virtualenvwrapper from its many possible sources...
    _try_source() { [[ -f $1 ]] || return; source "$1"; return 0; }
    _try_source /usr/local/bin/virtualenvwrapper.sh || \
    _try_source /etc/bash_completion.d/virtualenvwrapper || \
    _try_source /usr/bin/virtualenvwrapper.sh 
    declare status=$?
    unset -f _try_source

    # Restore PYTHONPATH
    [[ -n $_pp ]] && export PYTHONPATH="$_pp"

    # Did loading work?
    if [[ $status != 0 || $(type -t "$1") != function ]]; then
      echo "Error loading virtualenvwrapper, sorry" >&2
      return $status
    fi

    # Chain-load the appropriate function
    "$@"
  }

  for v in "${virtualenv_funcs[@]}"; do
    eval "$v() { load_virtualenv $v \"\$@\"; }"
  done

  #Add completion, ripped from virtualenvwrapper.sh
  function virtualenvwrapper_show_workon_options {
    # NOTE: DO NOT use ls or cd here because colorized versions spew control
    #       characters into the output list.
    # echo seems a little faster than find, even with -depth 3.
    # Note that this is a little tricky, as there may be spaces in the path.
    #
    # 1. Look for environments by finding the activate scripts.
    #    Use a subshell so we can suppress the message printed
    #    by zsh if the glob pattern fails to match any files.
    #    This yields a single, space-separated line containing all matches.
    # 2. Replace the trailing newline with a space, so every
    #    possible env has a space following it.
    # 3. Strip the bindir/activate script suffix, replacing it with
    #    a slash, as that is an illegal character in a directory name.
    #    This yields a slash-separated list of possible env names.
    # 4. Replace each slash with a newline to show the output one name per line.
    # 5. Eliminate any lines with * on them because that means there
    #    were no envs.
    
    #so we don't need more of their functions, we'll just use cd here. If something breaks, we'll know why.
    (cd "$WORKON_HOME" && echo */bin/activate) 2>/dev/null \
        | command \tr "\n" " " \
        | command \sed "s|/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate |/|g" \
        | command \tr "/" "\n" \
        | command \sed "/^\s*$/d" \
        | (unset GREP_OPTIONS; command \egrep -v '^\*$') 2>/dev/null
  }
  _virtualenvs () {
      local cur="${COMP_WORDS[COMP_CWORD]}"
      COMPREPLY=( $(compgen -W "`virtualenvwrapper_show_workon_options`" -- ${cur}) )
  }
  complete -o default -o nospace -F _virtualenvs workon
fi
