# Activate fuzzyfinder
# <https://github.com/junegunn/fzf>

if [ -f ~/.fzf.bash ]; then
  source ~/.fzf.bash
  export FZF_COMPLETION_TRIGGER='*'
fi

# fzf + jq live query hack
export PATH="$PATH:~/.bin/jqp"
