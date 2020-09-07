on run argv
	set sArgv to argv as text
	
	if sArgv contains ".|." then
		set text item delimiters to {".|."}
		set sQuery to text item 2 of sArgv
		set text item delimiters to ""
		set sQuery to trim(sQuery)
		if sQuery ends with "-url" then
			return
			set text item delimiters to {"-url"}
			set sQuery to text item 1 of sQuery
			set text item delimiters to ""
		end if
		
		tell application id "com.evernote.Evernote"
			try
				set query string of window 1 to sQuery
			on error
				open collection window with query string sQuery
			end try
			activate
			set miniaturized of window 1 to false
			activate
			tell application "System Events" to set frontmost of process "Evernote" to true
		end tell
	else
		set isURL to false
		if sArgv ends with "-url" then
			set text item delimiters to {"-url"}
			set sArgv to text item 1 of sArgv
			set text item delimiters to ""
			set isURL to true
		end if
		
		tell application id "com.evernote.Evernote"
			set _selectedNote to find note sArgv
			if isURL then
				set sURL to source URL of _selectedNote
				if sURL is missing value then
					return "Note does not have a source URL"
				else
					tell application "Finder" to open location sURL
				end if
			else
				open note window with _selectedNote
				delay 0.1
				activate
				tell application "System Events" to set frontmost of process "Evernote" to true
			end if
		end tell
		return
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
-- trim txt
on trim(strg)
	ignoring white space
		-- do the left trim
		set left_counter to 1
		repeat with J from 1 to length of strg
			if " " = (character left_counter of strg) then
				set left_counter to left_counter + 1
			else
				exit repeat
			end if
		end repeat
		try
			set strg to text left_counter through -1 of strg
		on error
			set strg to ""
		end try
		-- end left trim
		
		-- do the right trim
		set right_counter to -1
		repeat with J from 1 to length of strg
			if " " = (character right_counter of strg) then
				set right_counter to right_counter - 1
			else
				exit repeat
			end if
		end repeat
		try
			set strg to text 1 through right_counter of strg
		on error
			set strg to ""
		end try
		-- end right trim
	end ignoring
	return strg
end trim

