on run argv
	set sArgv to argv as text
	set wf to load script POSIX path of ((path to me as text) & "::") & "workflow.scpt"
	set wf to wf's new_workflow("com.sztoltz.evernote")
	
	if sArgv ends with "|1|" then
		set text item delimiters to {"|1|"}
		set sNote to text item 1 of sArgv
		set text item delimiters to ""
		wf's set_value("act_append", sNote)
		tell application id "com.runningwithcrayons.Alfred-3" to «event alfrSear» "📎: "
	else if sArgv ends with "|2|" then
		set text item delimiters to {"|2|"}
		set sArgv to text item 1 of sArgv
		set text item delimiters to ""
		set matches to {}
		set isOnlyTitle to false
		
		--Prepare
		set sArgvOri to sArgv --for auto complete only
		set sArgv to rt(sArgv, "#@", "#|1|")
		set sArgv to rt(sArgv, "##", "#|2|")
		if sArgv contains "!" and sArgv contains " at " and sArgv contains ":" then
			set text item delimiters to {":"}
			set sH to the last item of text item 1 of sArgv
			set text item delimiters to ""
			if isNumber(sH) then
				set sArgvTmp to ""
				set isH to false
				repeat with sRef in sArgv
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
				set sArgv to sArgvTmp
			end if
		end if
		
		if sArgv ends with "#" then
			tell application id "com.evernote.Evernote" to set matches to name of every tag
			if matches = {} then
				add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			else
				repeat with J from 1 to (count matches)
					set sCur to item J of matches
					add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:sArgv & "" & sCur & " :", i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
					if J = 20 then exit repeat
				end repeat
			end if
			return wf's to_xml("")
		else if sArgv ends with "!" then
			set l_Date to {"Today", "Tomorrow", "In a week", "2 days", "3 days", "30 days"}
			repeat with sCur in l_Date
				add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:sArgv & "" & sCur & " :", i:"rm.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			end repeat
			return wf's to_xml("")
		end if
		if sArgv starts with "#" or sArgv starts with "!" then
			if sArgv does not contain ":" then
				set isTag to false
				set isRm to false
				set sEnTags to ""
				set sEnReminder to ""
				repeat with sRef in sArgv
					set c to contents of sRef
					if c is "#" then
						set isTag to true
						set isRm to false
						if sEnTags is not "" then
							set sEnTags to ""
						end if
					else if c is "!" then
						set isTag to false
						set isRm to true
					else
						if isTag then set sEnTags to sEnTags & c
						if isRm then set sEnReminder to sEnReminder & c
					end if
				end repeat
				set sEnTags to rt(sEnTags, "|1|", "@")
				set sEnTags to rt(sEnTags, "|2|", "#")
				set sEnReminder to rt(sEnReminder, ".h.", ":")
				try
					set text item delimiters to ""
					if sEnTags ends with " " then set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
					if sEnReminder ends with " " then set sEnReminder to text 1 thru ((count sEnReminder) - 1) of sEnReminder
				on error
					add_ of wf given u:"", a:"", t:"Select or type a valid entry", s:"", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:0
					return wf's to_xml("")
				end try
				if isTag is true then --list tags
					tell application id "com.evernote.Evernote" to set matches to name of every tag
					if matches = {} then
						add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
					else
						set iCTags to 0 as integer
						repeat with J from 1 to (count matches)
							set sCur to item J of matches
							if sCur contains sEnTags then
								set sAutoC to trim_line(sArgvOri, "#" & sEnTags, 1)
								set sAutoC to sAutoC & "#" & sCur
								add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:sAutoC & " :", i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
								set iCTags to iCTags + 1
							end if
							if iCTags = 20 then exit repeat
						end repeat
					end if
					if wf's get_results() is not {} then
						return wf's to_xml("")
					end if
				else if isRm is true then --list reminders
					set l_Date to {"Today", "Tomorrow", "In a week", "2 days", "3 days", "30 days"}
					repeat with sCur in l_Date
						if sCur contains sEnReminder then
							set sAutoC to trim_line(sArgvOri, "!" & sEnReminder, 1)
							set sAutoC to sAutoC & "!" & sCur
							add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:sAutoC & " :", i:"rm.png", ty:"", M:{}, Tc:"", Lt:"", V:0
						end if
					end repeat
					if wf's get_results() is not {} then
						return wf's to_xml("")
					end if
				end if
			end if
		else
			set isOnlyTitle to true
		end if
		
		--Finder
		set appName to ""
		set someSource to {}
		set sFinderT to ""
		tell application "System Events" to set appName to (item 1 of (get name of processes whose frontmost is true)) as string
		if appName is "Finder" then
			tell application "Finder" to set someSource to selection as alias list
			if someSource is not {} then
				set sFinderT to "Append " & (count someSource) & " File(s) Selected in Finder"
			end if
		end if
		
		set sArgv to rt(sArgv, "#@", "#|1|")
		set sArgv to rt(sArgv, "##", "#|2|")
		if sArgv contains "!" and sArgv contains " at " and sArgv contains ":" then
			set text item delimiters to {":"}
			set sH to the last item of text item 1 of sArgv
			set text item delimiters to ""
			if isNumber(sH) then
				set sArgvTmp to ""
				set isH to false
				repeat with sRef in sArgv
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
				set sArgv to sArgvTmp
			end if
		end if
		
		if item 1 of (get clipboard info) contains «class PNGf» then
			set sClipType to "clippng"
			set sTitleClipTitle to " (Image)"
		else
			try
				set sClipTXT to the clipboard as text
				set sClipType to "clip"
				set sTitleClipTitle to " (Text)"
			on error
				set sClipType to ""
				set sTitleClipTitle to ""
			end try
		end if
		
		if sArgv = "" then
			set sSubtitle to "Tags: (none) | Reminder: (none)"
			set sSubtitle2 to "Tags: (none) | Reminder: (none) | Note: (type the note)"
			if sClipType is not "" then
				add_ of wf given u:"clip", a:sClipType & ".|." & sArgv, t:"Append from Clipboard" & sTitleClipTitle, s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
			end if
			add_ of wf given u:"sel", a:"sel.|." & sArgv, t:"Append from Text Selection", s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
			add_ of wf given u:"note", a:"", t:"Type a Text to Append", s:sSubtitle2, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			if sFinderT is not "" then
				add_ of wf given u:"file", a:"file.|." & sArgv, t:sFinderT, s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
			end if
			set sHelp to (POSIX path of ((do shell script "pwd") & "/help.html"))
			set lMods to {{"cmd", "Press Return Key to Open Help"}, {"alt", "Press Return Key to Open Help"}, {"ctrl", "Press Return Key to Open Help"}}
			add_ of wf given u:"", a:sHelp, t:"Optional Syntax: #Tag !Reminder :Note", s:"E.g.: #Script #Alfred !Tomorrow :My Note", AC:"", i:"arrow.png", ty:"file", M:lMods, Tc:"", Lt:"", V:1
		else
			set isTag to false
			set isRm to false
			set isTitle to false
			set sEnTitle to "" --typed note
			set sEnTags to ""
			set sEnReminder to ""
			if isOnlyTitle is false then
				repeat with sRef in sArgv
					set c to contents of sRef
					if c is "#" then
						set isTitle to false
						set isTag to true
						set isRm to false
						if sEnTags is not "" then
							if sEnTags ends with " " then
								set text item delimiters to ""
								set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
							end if
							set sEnTags to sEnTags & ","
						end if
					else if c is "!" then
						set isTitle to false
						set isTag to false
						set isRm to true
					else if c is ":" then
						set isTitle to true
						set isTag to false
						set isRm to false
					else
						if isTag then set sEnTags to sEnTags & c
						if isRm then set sEnReminder to sEnReminder & c
						if isTitle then set sEnTitle to sEnTitle & c
					end if
				end repeat
			else
				set sEnTags to ""
				set sEnReminder to ""
				set sEnTitle to sArgv
				set sArgv to ":" & sArgv
			end if
			set sEnTags to rt(sEnTags, "|1|", "@")
			set sEnTags to rt(sEnTags, "|2|", "#")
			set sEnReminder to rt(sEnReminder, ".h.", ":")
			try
				set text item delimiters to ""
				if sEnTags ends with " " then set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
				if sEnReminder ends with " " then set sEnReminder to text 1 thru ((count sEnReminder) - 1) of sEnReminder
			on error
				add_ of wf given u:"", a:"", t:"Select or type a valid entry", s:"", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:0
				return wf's to_xml("")
			end try
			if sEnTags = "" then set sEnTags to "(none)"
			if sEnReminder = "" then
				set sEnReminder to "(none)"
			else
				set sEnReminder to get_date(sEnReminder)
			end if
			
			if isOnlyTitle is false then
				set sSubtitle to "Tags: " & sEnTags & " | Reminder: " & sEnReminder --& " | Note: " & sEnTitle
				if sClipType is not "" then
					add_ of wf given u:"clip", a:sClipType & ".|." & sArgv, t:"Append from Clipboard" & sTitleClipTitle, s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
				end if
				add_ of wf given u:"sel", a:"sel.|." & sArgv, t:"Append from Text Selection", s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
				if sEnTitle is "" then
					set sSubtitle2 to "Tags: " & sEnTags & " | Reminder: " & sEnReminder & " | Note: (type the note)"
					add_ of wf given u:"note", a:"", t:"Type a Text to Append", s:sSubtitle2, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:0
				else
					set sSubtitle2 to "Tags: " & sEnTags & " | Reminder: " & sEnReminder & " | Note: " & sEnTitle
					add_ of wf given u:"note", a:"new.|." & ":" & sArgv, t:"Type a Text to Append", s:sSubtitle2, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
				end if
				if sFinderT is not "" then
					add_ of wf given u:"file", a:"file.|." & sArgv, t:sFinderT, s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
				end if
			else
				set sSubtitle to "Tags: (none) | Reminder: (none)"
				if sClipType is not "" then
					add_ of wf given u:"clip", a:sClipType & ".|." & sArgv, t:"Append from Clipboard" & sTitleClipTitle, s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
				end if
				add_ of wf given u:"sel", a:"sel.|." & sArgv, t:"Append from Text Selection", s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
				if sEnTitle is "" then
					set sSubtitle2 to "Note: (type the note)"
					add_ of wf given u:"note", a:"", t:"Type a Text to Append", s:sSubtitle2, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:0
				else
					set sSubtitle2 to "Note: " & sEnTitle
					add_ of wf given u:"note", a:"new.|." & ":" & sArgv, t:"Type a Text to Append", s:sSubtitle2, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
				end if
				if sFinderT is not "" then
					add_ of wf given u:"file", a:"file.|." & sArgv, t:sFinderT, s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
				end if
			end if
		end if
		
		return wf's to_xml("")
		
	else --|3| or --|4|
		--new.|.::2015 v1 test|3|
		
		set isAddDate to false
		
		if sArgv ends with "|4|" then --append with date
			set text item delimiters to {"|4|"}
			set sArgv to text item 1 of sArgv
			set text item delimiters to ""
			set isAddDate to true
		else
			set text item delimiters to {"|3|"}
			set sArgv to text item 1 of sArgv
			set text item delimiters to ""
		end if
		
		set sLocId to wf's get_value("act_append")
		
		(*
		set text item delimiters to {"/content/", "/content."}
		set sLocId to text item 2 of sNoteA
		set text item delimiters to ""
		if sLocId contains "/quickLook.png" then
			set text item delimiters to {"/quickLook.png"}
			set sLocId to text item 1 of sLocId
			set text item delimiters to ""
		end if
		*)
		tell application id "com.evernote.Evernote"
			set _selectedNote to find note sLocId
		end tell
		
		set text item delimiters to {".|."}
		set sParam to text item 1 of sArgv
		set sText to text item 2 of sArgv
		set text item delimiters to ""
		set sTags to ""
		set lTags to {}
		
		set isTag to false
		set isRm to false
		set isTitle to false
		set sEnTags to ""
		set sEnReminder to ""
		set sEnTitle to ""
		--prepare
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
		try
			set text item delimiters to ""
			if sEnTags ends with " " then set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
			if sEnTitle ends with " " then set sEnTitle to text 1 thru ((count sEnTitle) - 1) of sEnTitle
			if sEnReminder ends with " " then set sEnReminder to text 1 thru ((count sEnReminder) - 1) of sEnReminder
		end try
		if sEnReminder is "(none)" then set sEnReminder to ""
		if sEnReminder is not "" then set sEnReminder to get_date(sEnReminder)
		if sEnReminder is "(date not valid)" then return "Error: Date format not accepted"
		
		-- parse date
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
			repeat with J from 1 to (count text items) of sEnTags
				--set sCur to wf's q_trim(text item J of sEnTags)
				set sCur to q_trim(text item J of sEnTags)
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
				tell application id "com.google.Chrome"
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
			--delay 0.2
			do shell script "sleep 0.2"
			set sNote to get the clipboard
			if not sURL = "" then
				set sNote to sNote & return & return & sURL
			end if
		else if sParam is "file" then
			tell application "Finder" to set someSource to selection as alias list
			if someSource is {} then return "Select files in Finder first."
			set sNote to ""
		else
			-- Type Note
			if sText contains " /n " then
				set sNote to ""
				set text item delimiters to {" /n "}
				set lst_TypeText to text items of sText
				set text item delimiters to ""
				repeat with J from 1 to (count lst_TypeText)
					if J is (count lst_TypeText) then
						set sNote to sNote & item J of lst_TypeText
					else
						set sNote to sNote & item J of lst_TypeText & return
					end if
				end repeat
			else
				set sNote to sText
			end if
			if not sURL = "" then
				set sNote to sNote & return & return & sURL
			end if
		end if
		
		if sNote is not "" then
			-->> append date
			--set sAD to wf's get_value("appenddate")
			--if sAD is missing value or sAD is "" then set sAD to "Off"
			--if sAD is "On" then
			if isAddDate is true then
				set sDt to (current date) as string
				set sDt to "---- " & sDt & " ----"
				set sNote to sDt & return & sNote
			end if
		end if
		
		set l_en_Tags to {}
		tell application id "com.evernote.Evernote"
			if sParam is "file" then
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
				if sNote is not "" then tell _selectedNote to append text (return & return & sNote)
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
			if sParam is "file" then
				return "File(s) appended to " & title of _selectedNote
			else if sParam is "clippng" then
				return "Image from Clipboard appended to " & title of _selectedNote
			else
				return "Text appended to " & title of _selectedNote
			end if
		end tell
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

-- Trim or cut or replace (beginning, end or both)
on trim_line(this_text, trim_chars, trim_indicator)
	-- 0 = beginning, 1 = end, 2 = both
	set text item delimiters to ""
	set x to the length of the trim_chars
	-- TRIM BEGINNING
	if the trim_indicator is in {0, 2} then
		repeat while this_text begins with the trim_chars
			try
				set this_text to characters (x + 1) thru -1 of this_text as string
			on error
				-- the text contains nothing but the trim characters
				return ""
			end try
		end repeat
	end if
	-- TRIM ENDING
	if the trim_indicator is in {1, 2} then
		repeat while this_text ends with the trim_chars
			try
				set this_text to characters 1 thru -(x + 1) of this_text as string
			on error
				-- the text contains nothing but the trim characters
				return ""
			end try
		end repeat
	end if
	return this_text
end trim_line

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
