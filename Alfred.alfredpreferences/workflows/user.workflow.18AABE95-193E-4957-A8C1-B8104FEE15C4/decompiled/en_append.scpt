(*-- Libraries:
use scripting additions
use libqworkflow: script "q_workflow"

-- Map library identifiers into global namespace
property new_workflow_with_bundle: libqworkflow's new_workflow_with_bundle


DON'T EDIT THIS SCRIPT!
It requires Script Debugger 5 and q_workflow.scpt to be compiled again.
*)

on run argv
	--set wf to new_workflow_with_bundle("com.sztoltz.evernote")
	set wf to load script POSIX path of ((path to me as text) & "::") & "workflow.scpt"
	set wf to wf's new_workflow("com.sztoltz.evernote")
	set sArgv to argv as text
	set text item delimiters to "||"
	set sParam to text item 2 of sArgv
	set sArgv to text item 1 of sArgv
	set text item delimiters to ""
	
	if sArgv ends with "help.html" then
		do shell script "open " & (quoted form of (POSIX path of ((do shell script "pwd") & "/help.html")))
		return
	end if
	if sParam is "1" then
		wf's set_value("appendparam", sArgv)
		wf's set_value("adddate", "None")
		tell application id "com.runningwithcrayons.Alfred-3"
			«event alfrSear» "📄: "
		end tell
	else if sParam is "4" then
		wf's set_value("appendparam", sArgv)
		wf's set_value("adddate", "Default")
		tell application id "com.runningwithcrayons.Alfred-3"
			«event alfrSear» "📄: "
		end tell
	else if sParam is "2" then
		set matches to {}
		set iMax to 20 as integer
		try
			tell application id "com.evernote.Evernote"
				set matches to find notes "intitle:" & sArgv
				--set matches to find notes sArgv
				--set sAcc to name of current account as string
			end tell
			--set sHome to (POSIX path of (path to home folder) as string)
			--set sSupp to (POSIX path of (path to application support folder) as string)
			--set text item delimiters to ""
			--set sSupp to text 2 thru (count sSupp) of sSupp as string --
			if matches = {} then
				add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:0
			else
				--set matches to get the reverse of matches
				set i to 0 as integer
				set iCount to (count matches)
				repeat with j from 1 to (count matches)
					if i = iMax then exit repeat
					tell application id "com.evernote.Evernote"
						set sTitle to title of (item j of matches) as text
						--set sLocID to local id of (item j of matches) as text
						set sLocID to note link of (item j of matches) as text
					end tell
					(*
					set text item delimiters to {"/"}
					set sLocID to last text item of sLocID as string
					set text item delimiters to ""
					set sFile to sHome & sSupp & "Evernote/accounts/Evernote/" & sAcc & "/content/" & sLocID & "/content.html" as string
					set sEnSnippt to sHome & sSupp & "Evernote/accounts/Evernote/" & sAcc & "/content/" & sLocID & "/snippet.png" as string
					if cPathExists(sEnSnippt) then
						set sFile to sHome & sSupp & "Evernote/accounts/Evernote/" & sAcc & "/content/" & sLocID & "/quickLook.png" as string
					end if
					*)
					add_ of wf given u:sTitle, a:sLocID, t:sTitle, s:"", AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
					set i to (i + 1) as integer
				end repeat
			end if
		end try
		return wf's to_xml("")
	else if sParam is "3" then
		set sData to wf's get_value("appendparam")
		set sDt to wf's get_value("adddate")
		
		if sDt is "Default" then
			set sDt to (current date) as string
			set sDt to "---- " & sDt & " ----"
		else
			set sDt to ""
		end if
		if sData = "" then return "Error. Try again."
		set sTags to ""
		set lTags to {}
		set text item delimiters to {".|."}
		set sParam to text item 1 of sData as text
		set sText to text item 2 of sData as text
		set text item delimiters to ""
		
		set isTag to false
		set isRm to false
		set isTitle to false
		set sEnTags to ""
		set sEnReminder to ""
		set sEnTitle to ""
		-->>prepare
		set sText to rt(sText, "#@", "#|1|")
		set sText to rt(sText, "##", "#|2|")
		if sText contains "!" and sText contains " at " and sText contains ":" then
			set text item delimiters to {":"}
			set sH to the last item of text item 1 of sText
			set text item delimiters to ""
			if isNumber(sH) then
				set sArgvTmp to ""
				set isH to false
				repeat with sRef in sText
					set c to contents of sRef
					if c is ":" then
						if isH is false then
							set isH to true
							set sArgvTmp to sArgvTmp & ".h."
						else
							set sArgvTmp to sArgvTmp & c
						end if
					else
						set sArgvTmp to sArgvTmp & c
					end if
				end repeat
				set sText to sArgvTmp
			end if
		end if
		
		repeat with sRef in sText
			set c to contents of sRef
			if c is "#" then
				set isTag to true
				set isRm to false
				set isTitle to false
				if sEnTags is not "" then
					if sEnTags ends with " " then
						set text item delimiters to ""
						set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
					end if
					set sEnTags to sEnTags & ","
				end if
			else if c is "!" then
				set isTag to false
				set isRm to true
				set isTitle to false
			else if c is ":" then
				set isTag to false
				set isRm to false
				set isTitle to true
			else
				if isTag then set sEnTags to sEnTags & c
				if isRm then set sEnReminder to sEnReminder & c
				if isTitle then set sEnTitle to sEnTitle & c
			end if
		end repeat
		set sEnTags to rt(sEnTags, "|1|", "@")
		set sEnTags to rt(sEnTags, "|2|", "#")
		set sEnReminder to rt(sEnReminder, ".h.", ":")
		set text item delimiters to ""
		if sEnTags ends with " " then set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
		if sEnTitle ends with " " then set sEnTitle to text 1 thru ((count sEnTitle) - 1) of sEnTitle
		if sEnReminder ends with " " then set sEnReminder to text 1 thru ((count sEnReminder) - 1) of sEnReminder
		if sEnReminder is "(none)" then set sEnReminder to ""
		if sEnReminder is not "" then set sEnReminder to get_date(sEnReminder)
		if sEnReminder is "(date not valid)" then return "Error: Date format not accepted"
		
		-->> parse date
		if sEnReminder is not "" then
			if sEnReminder = "today" then
				set dDate to (current date)
			else if sEnReminder contains "Today" and sEnReminder contains ":" then
				try
					set dDate to rt(sEnReminder, "Today", (date string of (current date) as string))
					set dDate to rt(dDate, " at", "")
					set dDate to date (dDate)
				on error
					return "Date format not accepted"
				end try
			else if sEnReminder = "tomorrow" then
				set dDate to (current date) + 1 * days
			else if sEnReminder contains "tomorrow" and sEnReminder contains ":" then
				try
					set dDate to (current date) + 1 * days
					set dDate to date string of dDate
					set dDate to rt(sEnReminder, "tomorrow", dDate)
					set dDate to rt(dDate, " at", "")
					set dDate to date (dDate)
				on error
					return "Date format not accepted"
				end try
			else if sEnReminder is "Next Week" or sEnReminder is "in a week" then
				set dDate to (current date) + 7 * days
			else if sEnReminder contains "week" and sEnReminder contains ":" then
				try
					set dDate to (current date) + 7 * days
					set dDate to date string of dDate
					set sTemp to rt(sEnReminder, "next week", dDate)
					set sTemp to rt(sTemp, "in a week", dDate)
					set sTemp to rt(sTemp, " at", "")
					set dDate to date (sTemp)
				on error
					return "Date format not accepted"
				end try
			else if sEnReminder contains "/" or sEnReminder contains "-" or sEnReminder contains "." then
				try
					set sEnReminder to rt(sEnReminder, " at", "")
					set dDate to date (sEnReminder)
				on error
					return "Date format not accepted"
				end try
			else if sEnReminder contains " day" then
				set {TID, text item delimiters} to {text item delimiters, " days"}
				if isNumber(text item 1 of sEnReminder) then
					set iDays to text item 1 of sEnReminder as integer
					set text item delimiters to TID
					set dDate to (current date) + iDays * days
				else
					set text item delimiters to TID
					return "Date format not accepted"
				end if
			end if
		end if
		
		set sText to sEnTitle
		
		if sEnTags is not "" then
			set text item delimiters to {","}
			repeat with j from 1 to (count text items) of sEnTags
				--set sCur to wf's q_trim(text item j of sEnTags)
				set sCur to q_trim(text item j of sEnTags)
				set end of lTags to sCur
			end repeat
			set text item delimiters to ""
		else
			set lTags to {}
		end if
		
		tell application "System Events" to set appName to item 1 of (get name of processes whose frontmost is true)
		
		set sURL to ""
		try
			if appName = "Safari" then
				tell application "Safari"
					set sURL to (URL of current tab of window 1 as text)
				end tell
			else if appName = "Chrome" or appName = "Google Chrome" then
				tell application "Google Chrome"
					set sURL to (URL of active tab of window 1 as text)
				end tell
			else if appName = "Firefox" then
				set sPy to quoted form of (POSIX path of (POSIX file (POSIX path of ((path to me as text) & "::") & "urlfox.py")))
				set sURL to do shell script "python " & sPy
			end if
		on error
			set sURL to ""
		end try
		
		if sParam = "clip" then
			set sNote to get the clipboard
			if not sURL = "" then
				set sNote to sNote & return & return & sURL
			end if
		else if sParam = "clippng" then
			set sNote to ""
			set tempFolder to POSIX path of (path to temporary items) & "en_newnote_pic"
			try
				do shell script "mkdir " & quoted form of (tempFolder)
			on error
				try
					do shell script "rm -r " & quoted form of (tempFolder) & "/*"
				end try
			end try
			set tempFile to (POSIX file (tempFolder & "/enpic.png") as text)
			set myFile to (open for access tempFile with write permission)
			set eof myFile to 0
			write (the clipboard as «class PNGf») to myFile -- as whatever
			close access myFile
		else if sParam = "sel" then
			--delay 0.5
			do shell script "sleep 0.5"
			tell application "System Events"
				keystroke "c" using command down
			end tell
			do shell script "sleep 0.2"
			--delay 0.2
			set sNote to get the clipboard
			if not sURL = "" then
				set sNote to sNote & return & return & sURL
			end if
		else if sParam = "Alf_File" then
			return "Error. Can't append file."
		else if sParam = "file" then
			return "Error. Can't append file."
		else if sParam = "mail" then
			return "Error. Can't append message."
		else if sParam = "npf" or sParam = "file" then
			tell application "Finder" to set someSource to selection as alias list
			if someSource is {} then return "Select files in Finder first."
			set sNote to ""
		else
			if sText contains " /n " then
				set sNote to ""
				set text item delimiters to {" /n "}
				set lst_TypeText to text items of sText
				set text item delimiters to ""
				repeat with j from 1 to (count lst_TypeText)
					if j is (count lst_TypeText) then
						set sNote to sNote & item j of lst_TypeText
					else
						set sNote to sNote & item j of lst_TypeText & return
					end if
				end repeat
			else
				set sNote to sText
			end if
			if not sURL = "" then
				set sNote to sNote & return & return & sURL
			end if
		end if
		if not sDt = "" then set sNote to sDt & return & sNote
		set l_en_Tags to {}
		
		--if sArgv contains "/content/" then
		set sLocID to sArgv
		(*
			set text item delimiters to {"/content/", "/content."}
			set sLocID to text item 2 of sArgv
			set text item delimiters to ""
			if sLocID ends with "/quickLook.png" then
				set text item delimiters to {"/quickLook.png"}
				set sLocID to text item 1 of sLocID
				set text item delimiters to ""
			end if
			*)
		tell application id "com.evernote.Evernote"
			--return sLocID
			set _selectedNote to find note sLocID
			(*
			set _selectedNote to false
			set _Notes to get every note of every notebook where its local id contains sLocID
			repeat with _note in _Notes
				if length of _note is not 0 then
					set _selectedNote to item 1 of _note
					exit repeat
				end if
			end repeat
			*)
			if sParam is "npf" or sParam is "file" then
				tell _selectedNote to append text (return & return & sNote)
				repeat with sCur in someSource
					set theFile to sCur as alias
					set x to POSIX path of theFile
					tell _selectedNote to append attachment x
				end repeat
			else if sParam = "clippng" then
				set x to POSIX path of tempFile
				tell _selectedNote to append attachment x
				try
					do shell script "rm -r " & quoted form of (tempFolder)
				end try
			else
				try
					if sNote is not "" then tell _selectedNote to append text (return & return & sNote)
				on error
					return "error"
				end try
			end if
			if not lTags = {} then
				repeat with sCur in lTags
					if (not (tag named sCur exists)) then
						set s_en_Tag to make tag with properties {name:sCur}
						set end of l_en_Tags to s_en_Tag
					else
						set end of l_en_Tags to get tag named sCur
					end if
				end repeat
				if not l_en_Tags = {} then assign l_en_Tags to _selectedNote
			end if
			if sEnReminder is not "" then
				set reminder done time of _selectedNote to missing value
				set reminder time of _selectedNote to missing value
				set reminder time of _selectedNote to dDate
			end if
			synchronize
			if sParam is "npf" then
				return "File(s) appended to " & title of _selectedNote
			else if sParam is "clippng" then
				return "Image from Clipboard appended to " & title of _selectedNote
			else
				return "Text appended to " & title of _selectedNote
			end if
		end tell
		(*	
		else
			tell application id "com.evernote.Evernote"
				tell (find note sArgv) to append text (return & return & sNote)
				if not lTags = {} then
					repeat with sCur in lTags
						if (not (tag named sCur exists)) then
							set s_en_Tag to make tag with properties {name:sCur}
							set end of l_en_Tags to s_en_Tag
						else
							set end of l_en_Tags to get tag named sCur
						end if
					end repeat
					if not l_en_Tags = {} then assign l_en_Tags to (find note sArgv)
				end if
				if sEnReminder is not "" then
					set reminder done time of _selectedNote to missing value
					set reminder time of _selectedNote to missing value
					set reminder time of _selectedNote to dDate
				end if
				synchronize
				return "Text appended to " & title of (find note sArgv)
			end tell
		end if
		*)
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

on isNumber(_Str)
	try
		set _Str to _Str as integer
		return true
	on error
		return false
	end try
end isNumber

-- RT Replace Text
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
on q_trim(str)
	set text item delimiters to ""
	if class of str is not text or class of str is not string or str is missing value then return str
	if str is "" then return str
	repeat while str begins with " "
		try
			set str to items 2 thru -1 of str as text
		on error msg
			return ""
		end try
	end repeat
	repeat while str ends with " "
		try
			set str to items 1 thru -2 of str as text
		on error
			return ""
		end try
	end repeat
	return str
end q_trim
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
