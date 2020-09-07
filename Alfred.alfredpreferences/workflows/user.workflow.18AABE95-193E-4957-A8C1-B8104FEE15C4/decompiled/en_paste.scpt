on run argv
	set sArgv to argv as text
	
	if sArgv contains ".|." then
		-- show query in Evernote app
		return
	else
		tell application id "com.evernote.Evernote"
			set _selectedNote to find note sArgv
			if exists (_selectedNote) then
				set sENote to HTML content of _selectedNote
			else
				return "Note not found"
			end if
		end tell
		set sENote to do shell script "echo " & (quoted form of ("<!DOCTYPE HTML PUBLIC>" & sENote)) & space & "| textutil  -convert txt -prefixspaces 4 -stdin -stdout"
		--remove odd HTML/Evernote spacing
		set s to ""
		repeat with sRef in sENote
			set c to contents of sRef
			if c is " " then
				set s to s & " "
			else
				set s to s & c
			end if
		end repeat
		return s
	end if
end run
on q_path_exists(thePath)
	try
		if class of thePath is alias then return true
		if thePath contains ":" then
			alias thePath
			return true
		else if thePath contains "/" then
			POSIX file thePath as alias
			return true
		else
			return false
		end if
	on error
		return false
	end try
end q_path_exists
