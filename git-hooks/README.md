# Git hooks

I've created this setup in order to be able to have some git hooks run for all repos, without losing
the ability to set up per-repo hooks. In addition, the ".d" approach allows me to give the hooks
semantic names, which makes it easier to figure out what they do.

## How it works

For each hook, there's a `<hook>` file and a `<hook>.d` directory. All user hooks you want to be run in all repos should go in the `.d` directory of the desired hook name. The entire structure is mirrored in each repo: if you want to have a pre-push hook run only in a specific repo, put it in `.git/hooks/<hookname>.d/<your-hook>`. The `<hook>` file in this directory (e.g. `pre-push`) first runs the global hooks, then the per-repo hooks.

This entire setup relies on `core.hooksPath` being set up properly, as it is in `dotfiles/gitconfig`.

NB: hooks are only run if they're executable. If your hook isn't being run, make sure it's executable!
