#!/usr/bin/env python3
# Run prefixed with `(set -o posix; set)`, which prints all vars (including colors)

#This is just slow. Maybe pygit2 is better?

from git import Repo
from pathlib import PurePath
from os import environ

def shorten_path(path, max_len=35):
  """
  Shortens `path` if it's longer than `max_len` characters. For example, with
  path="/Users/max/Applications/Sublime Text.app/Contents/SharedSupport/bin", returns
  "~/Applications/.../SharedSupport/bin". If `path` is shorter than `max_len`, then
  `path` will be returned unchanged.

  Args:
    path (str): a string representing a file path
    max_len (int): return a shortened path if it's longer than this
  """
  if len(path) > max_len:
    path = PurePath(path)
    if len(path.parts) > 4:
      return (PurePath(*path.parts[:2]) / '...' / PurePath(*path.parts[-2:])).as_posix()
    elif len(path.parts) > 3:
      return (PurePath(*path.parts[:2]) / '...' / path.parts[-1]).as_posix()
    else:
      return (PurePath(path.parts[0]) / '...' / path.parts[-1]).as_posix()
  else:
    return path


def git_prompt():
  repo = Repo('.', search_parent_directories=True)
  try:
    branch = repo.active_branch.name
  except TypeError:
    return environ['Color_Red'] + '???' + environ['Color_NoColor']

  # This magic gets all the unstaged changes
  unstaged = repo.index.diff(None)
  any_unstaged = any(list(unstaged.iter_change_type(t)) for t in unstaged.change_type)

  # This magic gets all the staged changes
  staged = repo.index.diff('HEAD')
  any_staged = any(list(staged.iter_change_type(t)) for t in staged.change_type)

  if repo.untracked_files or any_unstaged:
    branch_color = environ['Color_Yellow']
  elif any_staged:
    branch_color = environ['Color_Red']
  else:
    branch_color = environ['Color_Green']

  commits_behind = list(repo.iter_commits('{branch}..{branch}@{{u}}'.format(branch=branch)))
  commits_ahead = list(repo.iter_commits('{branch}@{{u}}..{branch}'.format(branch=branch)))
  if commits_ahead and commits_behind:
    symbol = '!!'
  elif commits_behind:
    symbol = '-'
  elif commits_ahead:
    symbol = '+'
  else:
    symbol = ''

  symbol_str = ''.join([environ['Color_BYellow'], symbol, environ['Color_NoColor']]) if symbol else ''

  return ''.join([symbol_str, branch_color, branch, environ['Color_NoColor']])


if __name__ == '__main__':
  print(git_prompt())