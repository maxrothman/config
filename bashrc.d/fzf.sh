# Activate fuzzyfinder
# <https://github.com/junegunn/fzf>

if [ -f ~/.fzf.bash ]; then
  source ~/.fzf.bash
  export FZF_COMPLETION_TRIGGER='*'
fi

export PATH="$PATH:~/.bin/jqp"
