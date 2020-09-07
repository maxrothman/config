on run argv
	set wf to load script POSIX path of ((path to me as text) & "::") & "workflow.scpt"
	set wf to wf's new_workflow("com.sztoltz.evernote")
	
	set sArgv to argv as text
	set text item delimiters to "||"
	set sParam to text item 2 of sArgv
	set sArgv to text item 1 of sArgv
	set text item delimiters to ""
	
	if sParam is "1" then
		wf's set_value("rm_note", sArgv)
		tell application id "com.runningwithcrayons.Alfred-3"
			«event alfrSear» "📆: "
		end tell
	else if sParam is "2" then
		set l_Date to {"Today", "Tomorrow", "In a week", "2 days", "3 days", "30 days"}
		if sArgv = "" then
			repeat with sCur in l_Date
				add_ of wf given u:sCur, a:sCur, t:sCur, s:"", AC:"", i:"rm.png", ty:"", M:{}, Tc:"", Lt:"", V:1
			end repeat
		else
			repeat with sCur in l_Date
				if sCur contains sArgv then
					add_ of wf given u:sCur, a:sCur, t:sCur, s:"", AC:"", i:"rm.png", ty:"", M:{}, Tc:"", Lt:"", V:1
				end if
			end repeat
			if wf's get_results() = {} then
				set sCur to get_date(sArgv)
				if sCur = "(date not valid)" then
					add_ of wf given u:"", a:"", t:"Date: " & sCur, s:"", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:0
					add_ of wf given u:"", a:"", t:"Examples: 4/5/14 or 4/5/14 at 2:00 or 5 days", s:"", AC:"", i:"arrow.png", ty:"", M:{}, Tc:"", Lt:"", V:0
				else
					add_ of wf given u:"", a:sArgv, t:"Date: " & sCur, s:"", AC:"", i:"rm.png", ty:"", M:{}, Tc:"", Lt:"", V:1
				end if
			end if
		end if
		return wf's to_xml("")
	else if sParam is "3" then
		set sNote to wf's get_value("rm_note")
		-- parse date
		if sArgv = "today" then
			set dDate to (current date)
		else if sArgv contains "Today" and sArgv contains ":" then
			try
				set dDate to rt(sArgv, "Today", (date string of (current date) as string))
				set dDate to rt(dDate, " at", "")
				set dDate to date (dDate)
			on error
				return "Date format not accepted"
			end try
		else if sArgv = "tomorrow" then
			set dDate to (current date) + 1 * days
		else if sArgv contains "tomorrow" and sArgv contains ":" then
			try
				set dDate to (current date) + 1 * days
				set dDate to date string of dDate
				set dDate to rt(sArgv, "tomorrow", dDate)
				set dDate to rt(dDate, " at", "")
				set dDate to date (dDate)
			on error
				return "Date format not accepted"
			end try
		else if sArgv is "Next Week" or sArgv is "in a week" then
			set dDate to (current date) + 7 * days
		else if sArgv contains "week" and sArgv contains ":" then
			try
				set dDate to (current date) + 7 * days
				set dDate to date string of dDate
				set sTemp to rt(sArgv, "next week", dDate)
				set sTemp to rt(sTemp, "in a week", dDate)
				set sTemp to rt(sTemp, " at", "")
				set dDate to date (sTemp)
			on error
				return "Date format not accepted"
			end try
		else if sArgv contains "/" or sArgv contains "-" or sArgv contains "." then
			try
				set sTmp to rt(sArgv, " at", "")
				set dDate to date (sTmp)
			on error
				return "Date format not accepted"
			end try
		else if sArgv contains " day" then
			set {TID, text item delimiters} to {text item delimiters, " days"}
			if isNumber(text item 1 of sArgv) then
				set iDays to text item 1 of sArgv as integer
				set text item delimiters to TID
				set dDate to (current date) + iDays * days
			else
				set text item delimiters to TID
				return "Date format not accepted"
			end if
		else
			return "Date format not accepted"
		end if
		
		tell application id "com.evernote.Evernote"
			set _selectedNote to find note sNote
			set reminder done time of _selectedNote to missing value
			set reminder time of _selectedNote to missing value
			set reminder time of _selectedNote to dDate
			synchronize
		end tell
		
		return "Reminder set to " & dDate
		
	else if sParam is "4" then -- set to DONE		
		set sLocId to sArgv
		tell application id "com.evernote.Evernote"
			set _selectedNote to find note sLocId
			set reminder done time of _selectedNote to current date
		end tell
		tell application id "com.runningwithcrayons.Alfred-3" to «event alfrSear» "enr "
		return "Reminder Status: DONE"
	end if
end run

on get_date(_Str)
	if _Str is "tomorrow" then
		return _Str
	else if _Str contains "tomorrow" and _Str contains ":" then
		try
			set dDate to (current date) + 1 * days
			set dDate to date string of dDate
			set dDate to rt(_Str, "tomorrow", dDate)
			set dDate to rt(dDate, " at", "")
			set dDate to date (dDate)
			return _Str
		on error
			return "(date not valid)"
		end try
	else if _Str is "today" then
		return _Str
	else if _Str contains "Today" and _Str contains ":" then
		try
			set dDate to rt(_Str, "Today", (date string of (current date) as string))
			set dDate to rt(dDate, " at", "")
			set dDate to date (dDate)
			return _Str
		on error
			return "(date not valid)"
		end try
	else if _Str is "in a week" or _Str is "next week" then
		return _Str
	else if _Str contains "week" and _Str contains ":" then
		try
			set dDate to (current date) + 7 * days
			set dDate to date string of dDate
			set sTemp to rt(_Str, "next week", dDate)
			set sTemp to rt(sTemp, "in a week", dDate)
			set sTemp to rt(sTemp, " at", "")
			set dDate to date (sTemp)
			return _Str
		on error
			return "(date not valid)"
		end try
	else if _Str contains "/" or _Str contains "-" or _Str contains "." then
		try
			set sTmp to rt(_Str, " at", "")
			set sTmp to date (sTmp)
			return _Str
		on error
			return "(date not valid)"
		end try
	else if _Str contains " day" then
		set _Str to rt(_Str, "in ", "")
		set text item delimiters to " day"
		if isNumber(item 1 of _Str) then
			set text item delimiters to ""
			return _Str
		else
			set text item delimiters to ""
			return "(date not valid)"
		end if
	else
		return "(date not valid)"
	end if
end get_date

on get_date_ORI(_Str)
	if _Str contains "/" or _Str contains "-" or _Str contains "." then
		try
			set sTmp to date (_Str)
			return _Str
		on error
			return "Type a date e.g. 4/5/13 or 4/5/14 at 2:00 or 5 days"
		end try
	else if _Str contains " days" then
		set {TID, text item delimiters} to {text item delimiters, " days"}
		if isNumber(item 1 of _Str) then
			set text item delimiters to TID
			return _Str
		else
			set text item delimiters to TID
			return "Type a date e.g. 4/5/13 or 4/5/14 at 2:00 or 5 days"
		end if
	else
		return "Type a date e.g. 4/5/13 or 4/5/14 at 2:00 or 5 days"
	end if
end get_date_ORI

on isNumber(_Str)
	try
		set _Str to _Str as integer
		return true
	on error
		return false
	end try
end isNumber
on cPathExists(thePath)
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
end cPathExists
-- replace
on rt(_Str, _del, _add)
	try
		set text item delimiters to _del
		set _Str to _Str's text items
		set text item delimiters to _add
		tell _Str to set _Str to item 1 & ({""} & rest)
		set text item delimiters to ""
		return _Str as string
	on error
		return _Str as string
	end try
end rt
