on run argv
	set wf to load script POSIX path of ((path to me as text) & "::") & "workflow.scpt"
	set wf to wf's new_workflow("com.sztoltz.evernote")
	set sArgv to argv as text
	set sTemplateCMD to sArgv
	set sSubtitle to ""
	set sSubtitle2 to ""
	set sSub3 to ""
	set sSub4 to ""
	set sSub5 to ""
	set sSub6 to ""
	set sSubTemplate to ""
	set sFromURL to ""
	set sFinderT to ""
	set sFinderTM to ""
	set sMailT to ""
	set sEnFinderTitle to ""
	set l_Sel to {}
	set someSource to {}
	set isOnlyTitle to false
	set isTypeNote to false
	set isMultFiles to false
	set sClipType to ""
	
	if sArgv starts with "typeennote:" then
		set text item delimiters to {"typeennote:"}
		set sArgv to text item 2 of sArgv
		set text item delimiters to ""
		set isTypeNote to true
	end if
	
	-->> prepare
	set sArgvOri to sArgv --for auto complete
	set sArgv to rt(sArgv, "#@", "#|1|")
	set sArgv to rt(sArgv, "##", "#|2|")
	set sArgv to rt(sArgv, "@@", "@|3|")
	set sArgv to rt(sArgv, "@#", "@|4|")
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
	--	
	
	if sArgv contains "@" then
		set text item delimiters to {"@"}
		set iC to count text items of sArgv
		set text item delimiters to ""
		if iC is greater than 2 then
			add_ of wf given u:"", a:"", t:"You can create a note in one notebook at time", s:"", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:0
			return wf's to_xml("")
		end if
	end if
	
	set matches to {}
	if sArgv ends with "@" then
		tell application id "com.evernote.Evernote" to set matches to name of every notebook
		if matches = {} then
			add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
		else
			repeat with sCur in matches
				add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:sArgv & "" & sCur & " :", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			end repeat
		end if
		return wf's to_xml("")
	else if sArgv ends with "#" then
		tell application id "com.evernote.Evernote" to set matches to name of every tag
		if matches = {} then
			add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
		else
			repeat with j from 1 to (count matches)
				set sCur to item j of matches
				add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:sArgv & "" & sCur & " :", i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
				if j = 20 then exit repeat
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
	
	if sArgv starts with "@" or sArgv starts with "#" or sArgv starts with "!" then
		if sArgv does not contain ":" then
			set isNB to false
			set isTag to false
			set isRm to false
			set isTitle to false
			set sEnNotebook to ""
			set sEnTags to ""
			set sEnReminder to ""
			set sEnTitle to ""
			repeat with sRef in sArgv
				set c to contents of sRef
				if c is "@" then
					set isNB to true
					set isTag to false
					set isRm to false
					set isTitle to false
				else if c is "#" then
					set isNB to false
					set isTag to true
					set isRm to false
					set isTitle to false
					if sEnTags is not "" then
						set sEnTags to ""
					end if
				else if c is "!" then
					set isNB to false
					set isTag to false
					set isRm to true
					set isTitle to false
				else
					if isNB then set sEnNotebook to sEnNotebook & c
					if isTag then set sEnTags to sEnTags & c
					if isRm then set sEnReminder to sEnReminder & c
					if isTitle then set sEnTitle to sEnTitle & c
				end if
			end repeat
			
			set sEnTags to rt(sEnTags, "|1|", "@")
			set sEnTags to rt(sEnTags, "|2|", "#")
			set sEnNotebook to rt(sEnNotebook, "|3|", "@")
			set sEnNotebook to rt(sEnNotebook, "|4|", "#")
			set sEnReminder to rt(sEnReminder, ".h.", ":")
			
			try
				set text item delimiters to ""
				if sEnNotebook ends with " " then set sEnNotebook to text 1 thru ((count sEnNotebook) - 1) of sEnNotebook
				if sEnTags ends with " " then set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
				if sEnTitle ends with " " then set sEnTitle to text 1 thru ((count sEnTitle) - 1) of sEnTitle
				if sEnReminder ends with " " then set sEnReminder to text 1 thru ((count sEnReminder) - 1) of sEnReminder
			on error
				add_ of wf given u:"", a:"", t:"Select or type a valid entry", s:"", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:0
				return wf's to_xml("")
			end try
			-->> here
			if isTag is true then --list tags
				tell application id "com.evernote.Evernote" to set matches to name of every tag
				if matches = {} then
					add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
				else
					set iCTags to 0 as integer
					repeat with j from 1 to (count matches)
						set sCur to item j of matches
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
			else if isNB is true then --list notebooks
				tell application id "com.evernote.Evernote" to set matches to name of every notebook
				if matches = {} then
					add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
				else
					repeat with j from 1 to (count matches)
						set sCur to item j of matches
						if sCur contains sEnNotebook then
							set sAutoC to trim_line(sArgvOri, "@" & sEnNotebook, 1)
							set sAutoC to sAutoC & "@" & sCur
							add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:sAutoC & " :", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
						end if
					end repeat
				end if
				if wf's get_results() is not {} then
					return wf's to_xml("")
				end if
			else if isRm is true then --list reminders
				set l_Date to {"Today", "Tomorrow", "In a week", "2 days", "3 days", "30 days"}
				repeat with sCur in l_Date
					if sCur contains sEnReminder then
						--set sAutoC to rt(sArgv, "!" & sEnReminder, "!" & sCur)
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
	
	tell application "System Events" to set appName to (item 1 of (get name of processes whose frontmost is true)) as string
	
	if appName is "Mail" then
		tell application "Mail"
			set l_Sel to selection
			if l_Sel is not {} then
				set sMCount to (count l_Sel) as string
				if (count l_Sel) > 1 then
					set sMailT to "New Notes from " & sMCount & " Messages Selected in Mail"
				else
					set sMailT to "New Note from the Message Selected in Mail"
				end if
			end if
		end tell
	else if appName is "Finder" then
		tell application "Finder"
			set someSource to selection as alias list
			if someSource is not {} then
				set sFCount to (count someSource) as string
				if (count someSource) > 1 then
					set isMultFiles to true
					--set sFinderT to "New Notes from " & sFCount & " Files Selected in Finder"
					set sFinderTM to sFCount & " New Notes from each File Selected in Finder"
					set sFinderT to "New Note with " & sFCount & " Files Selected in Finder"
				else
					set sFinderT to "New Note from the File Selected in Finder"
				end if
			end if
		end tell
	else if appName is "Safari" then
		set sFromURL to "New Note from Safari URL"
	else if appName = "Chrome" or appName = "Google Chrome" then
		set sFromURL to "New Note from Google Chrome URL"
	end if
	
	if sArgv = "" then
		if isTypeNote is false then
			set sSubtitle to "Notebook: (default) | Tags: (none) | Reminder: (none) | Title: (from note)"
			set sSubtitle2 to "Notebook: (default) | Tags: (none) | Reminder: (none) | Title: (from note)"
			set sSub4 to "Notebook: (default) | Tags: (none) | Reminder: (none) | Title: (from filename)"
			set sSub3 to "Notebook: (default) | Tags: (none) | Reminder: (none) | Title: (from filename)"
			set sSub5 to "Notebook: (default) | Tags: (none) | Reminder: (none) | Title: (from message)"
			set sSub6 to "Notebook: (default) | Tags: (none) | Title: (from URL)"
		else
			set sSubtitle2 to "Notebook: (default) | Tags: (none) | Reminder: (none) | Note: (type it)"
		end if
		set sEnNotebook to ""
		set sEnTags to ""
		set sEnReminder to ""
		set sEnTitle to sArgv
		set sArgv to ":" & sEnTitle
	else
		set isNB to false
		set isTag to false
		set isRm to false
		set isTitle to false
		set sEnNotebook to ""
		set sEnTags to ""
		set sEnReminder to ""
		set sEnTitle to ""
		if isOnlyTitle is false then
			repeat with sRef in sArgv
				set c to contents of sRef
				if c is "@" then
					set isNB to true
					set isTag to false
					set isRm to false
					set isTitle to false
				else if c is "#" then
					set isNB to false
					set isTag to true
					set isRm to false
					set isTitle to false
					if sEnTags is not "" then
						set text item delimiters to ""
						if sEnTags ends with " " then set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
						set sEnTags to sEnTags & ","
					end if
				else if c is "!" then
					set isNB to false
					set isTag to false
					set isRm to true
					set isTitle to false
				else if c is ":" then
					set isNB to false
					set isTag to false
					set isRm to false
					set isTitle to true
				else
					if isNB then set sEnNotebook to sEnNotebook & c
					if isTag then set sEnTags to sEnTags & c
					if isRm then set sEnReminder to sEnReminder & c
					if isTitle then set sEnTitle to sEnTitle & c
				end if
			end repeat
			
			-->>
			set sEnTags to rt(sEnTags, "|1|", "@")
			set sEnTags to rt(sEnTags, "|2|", "#")
			set sEnNotebook to rt(sEnNotebook, "|3|", "@")
			set sEnNotebook to rt(sEnNotebook, "|4|", "#")
			set sEnReminder to rt(sEnReminder, ".h.", ":")
			try
				set text item delimiters to ""
				if sEnNotebook ends with " " then set sEnNotebook to text 1 thru ((count sEnNotebook) - 1) of sEnNotebook
				if sEnTags ends with " " then set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
				if sEnTitle ends with " " then set sEnTitle to text 1 thru ((count sEnTitle) - 1) of sEnTitle
				if sEnReminder ends with " " then set sEnReminder to text 1 thru ((count sEnReminder) - 1) of sEnReminder
			end try
			set sEnFinderTitle to sEnTitle
			if sEnTitle = "" then
				set sEnTitle to "(from note)"
				set sEnFinderTitle to "(from filename)"
			end if
			if sEnNotebook = "" then set sEnNotebook to "(default)"
			if sEnTags = "" then set sEnTags to "(none)"
			if sEnReminder = "" then
				set sEnReminder to "(none)"
			else
				set sEnReminder to get_date(sEnReminder)
			end if
			
			if isTypeNote is false then
				set sSubtitle to "Notebook: " & sEnNotebook & " | Tags: " & sEnTags & " | Reminder: " & sEnReminder & " | Title: " & sEnTitle
				if sEnTitle contains " /n " then
					set text item delimiters to {" /n "}
					set sTyTi to text item 1 of sEnTitle
					set text item delimiters to ""
					try
						set sTyNo to text ((count sTyTi) + 5) thru (count of sEnTitle) of sEnTitle as string
					on error
						set sTyNo to ""
					end try
					set sSubtitle2 to "Notebook: " & sEnNotebook & " | Tags: " & sEnTags & " | Reminder: " & sEnReminder & " | Title: " & sTyTi & " | Note: " & sTyNo
				else
					set sSubtitle2 to "Notebook: " & sEnNotebook & " | Tags: " & sEnTags & " | Reminder: " & sEnReminder & " | Note: " & sEnTitle
				end if
				set sSub4 to "Notebook: " & sEnNotebook & " | Tags: " & sEnTags & " | Reminder: " & sEnReminder & " | Title: " & sEnFinderTitle
				set sSub3 to "Notebook: " & sEnNotebook & " | Tags: " & sEnTags & " | Reminder: " & sEnReminder & " | Title: (from filename)"
				set sSub5 to "Notebook: " & sEnNotebook & " | Tags: " & sEnTags & " | Reminder: " & sEnReminder & " | Title: (from message)"
				set sSub6 to "Notebook: " & sEnNotebook & " | Tags: " & sEnTags & " | Title: (from URL)"
			else
				if sEnTitle contains " /n " then
					set text item delimiters to {" /n "}
					set sTyTi to text item 1 of sEnTitle
					set text item delimiters to ""
					try
						set sTyNo to text ((count sTyTi) + 5) thru (count of sEnTitle) of sEnTitle as string
					on error
						set sTyNo to ""
					end try
					set sSubtitle2 to "Notebook: " & sEnNotebook & " | Tags: " & sEnTags & " | Reminder: " & sEnReminder & " | Title: " & sTyTi & " | Note: " & sTyNo
				else
					
					set sSubtitle2 to "Notebook: " & sEnNotebook & " | Tags: " & sEnTags & " | Reminder: " & sEnReminder & " | Note: " & sEnTitle
				end if
			end if
			
		else
			set sEnTitle to sArgv
			set sArgv to ":" & sArgv
			set sEnFinderTitle to sEnTitle
			if isTypeNote is false then
				set sSubtitle to "Title: " & sEnTitle
				if sEnTitle contains " /n " then
					set text item delimiters to {" /n "}
					set sTyTi to text item 1 of sEnTitle
					set text item delimiters to ""
					try
						set sTyNo to text ((count sTyTi) + 5) thru (count of sEnTitle) of sEnTitle as string
					on error
						set sTyNo to ""
					end try
					set sSubtitle2 to "Title: " & sTyTi & " | Note: " & sTyNo
				else
					set sSubtitle2 to "Note: " & sEnTitle
				end if
				set sSub4 to "Title: " & sEnFinderTitle
				set sSub3 to "Title: (title from filename)"
				set sSub5 to "Title: (title from message)"
				set sSub6 to "Title: (from URL)"
			else
				if sEnTitle contains " /n " then
					set text item delimiters to {" /n "}
					set sTyTi to text item 1 of sEnTitle
					set text item delimiters to ""
					try
						set sTyNo to text ((count sTyTi) + 5) thru (count of sEnTitle) of sEnTitle as string
					on error
						set sTyNo to ""
					end try
					set sSubtitle2 to "Title: " & sTyTi & " | Note: " & sTyNo
				else
					set sSubtitle2 to "Note: " & sEnTitle
				end if
			end if
			
		end if
	end if
	
	try
		if item 1 of (get clipboard info) contains «class PNGf» or item 1 of (get clipboard info) contains TIFF picture then
			set sClipType to "clippng"
			set sTitleClipTitle to " (Image)"
		else
			set sClipTXT to the clipboard as text
			set sClipType to "clip"
			set sTitleClipTitle to " (Text)"
		end if
	on error
		set sClipType to ""
		set sTitleClipTitle to ""
	end try
	
	if isTypeNote is false then
		
		add_ of wf given u:"selection", a:"sel.|." & sArgv, t:"New Note from Text Selection", s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
		if sClipType is not "" then
			add_ of wf given u:"clipboard", a:sClipType & ".|." & sArgv, t:"New Note from Clipboard" & sTitleClipTitle, s:sSubtitle, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
		end if
		if appName is "Finder" and someSource is not {} then
			if isMultFiles is true then
				add_ of wf given u:"npf", a:"npf.|." & sArgv, t:sFinderTM, s:sSub3, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
			end if
			add_ of wf given u:"file", a:"file.|." & sArgv, t:sFinderT, s:sSub4, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
		end if
		if appName is "Mail" and l_Sel is not {} then
			add_ of wf given u:"mail", a:"mail.|." & sArgv, t:sMailT, s:sSub5, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
		end if
		if appName is "Google Chrome" or appName is "Chrome" or appName is "Safari" then
			add_ of wf given u:"URL", a:"url.|." & sArgv, t:sFromURL, s:sSub6, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
		end if
		if sArgv is ":" then
			add_ of wf given u:"type", a:"", t:"Type a Note", s:sSubtitle2, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:0
		else
			add_ of wf given u:"type", a:"new.|." & sArgv, t:"Type a Note", s:sSubtitle2, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
		end if
	else
		if sArgv is ":" then
			add_ of wf given u:"note", a:"", t:"Type a Note", s:sSubtitle2, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:0
		else
			add_ of wf given u:"note", a:"new.|." & sArgv, t:"Type a Note", s:sSubtitle2, AC:"", i:"icon2.png", ty:"", M:{}, Tc:"", Lt:"", V:1
		end if
	end if
	
	set sHelp to (POSIX path of ((do shell script "pwd") & "/help.html"))
	set lMods to {{"cmd", "Press Return Key to Open Help"}, {"alt", "Press Return Key to Open Help"}, {"ctrl", "Press Return Key to Open Help"}}
	add_ of wf given u:"", a:sHelp, t:"Optional Syntax: @Notebook #Tag !Reminder :Note", s:"", AC:"", i:"arrow.png", ty:"file", M:lMods, Tc:"", Lt:"", V:1
	
	return wf's to_xml("")
	
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

-- Replace Text
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
