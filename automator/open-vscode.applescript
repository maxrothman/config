on run {input, parameters}
	set appPath to path to application "Visual Studio Code"
	tell application "Finder"
		set dir_path to the target of the front window
		open dir_path using appPath
	end tell
end run