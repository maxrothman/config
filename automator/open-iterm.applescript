-- Tested using OSX 10.9.5 and iTerm 2.9 nightly builds (though it'd probably work on 2.1)

on run {input, parameters}
  tell application "Finder"
    set dir_path to quoted form of (POSIX path of (the target of the front window as alias))
  end tell
  CD_to(dir_path)
end run

on CD_to(q)
  tell application "iTerm"
    create window with default profile
    tell current session of current window
      write text "cd " & q & "; clear"
    end tell
  end tell
end CD_to
