-- Tested using OSX 10.9.5, version of Sublime should be irrelevant.

on run {input, parameters}
  set appPath to path to application "Sublime Text"
  tell application "Finder"
    set dir_path to the target of the front window
    open dir_path using appPath
  end tell
end run
