on run argv
	set wf to load script POSIX path of ((path to me as text) & "::") & "workflow.scpt"
	set wf to wf's new_workflow("com.sztoltz.evernote")
	
	set sArgv to argv as text
	
	if sArgv starts with "-o" then
		set text item delimiters to ""
		set sOpen to characters 1 thru 2 of sArgv as string
		set sArgv to text 3 thru (count sArgv) of sArgv
	else
		set sOpen to ""
	end if
	set lTags to {}
	set lst_MultFiles to {}
	set sNoteBook to ""
	set sCDate to ""
	set iCount to 0
	set sText to ""
	set isHTML to false
	-- scan
	set isNB to false
	set isTag to false
	set isRm to false
	set isTitle to false
	set sEnNotebook to ""
	set sEnTags to ""
	set sEnReminder to ""
	set sEnTitle to ""
	
	if sArgv ends with "help.html" then
		do shell script "open " & (quoted form of (POSIX path of ((do shell script "pwd") & "/help.html")))
		return
	else if sArgv ends with "Evernote Templates.html" then
		do shell script "open " & (quoted form of (POSIX path of ((do shell script "pwd") & "/Evernote Templates.html")))
		return
	else if sArgv = "New Note from Clipboard" or sArgv is "New: Text Clipboard" then
		set sParam to "clip"
	else if sArgv = "New Note from Clipboard (Image)" or sArgv is "New: Image Clipboard" then
		set sParam to "clippng"
	else if sArgv = "New Note from Text Selection" or sArgv is "New: Text Selection" then
		set sParam to "sel"
	else if sArgv = "New Note from Finder Selected Files" then
		set sParam to "file"
	else if sArgv = "New Note for each Finder Selected File" then
		set sParam to "npf"
	else if sArgv = "New Note from Mail Selected Messages" then
		set sParam to "mail"
	else if q_path_exists(sArgv) then
		set sParam to "Alf_File"
	else if sArgv contains tab then
		if sArgv starts with "-f" then --one note per file
			set isNotePerFile to true
			set text item delimiters to ""
			set sArgv to text 3 thru (count sArgv) of sArgv
		else
			set isNotePerFile to false
		end if
		set text item delimiters to tab
		repeat with i from 1 to the number of text items of sArgv
			set end of lst_MultFiles to POSIX file (text item i of sArgv) as alias
		end repeat
		set text item delimiters to ""
		set sParam to "Alf_MultFiles"
	else
		if sArgv is "Last Template" then
			set sLastTemplate to wf's get_value("last_template")
			if sLastTemplate is "" then
				tell application id "com.runningwithcrayons.Alfred-3" to «event alfrSear» "ennt "
				return "There is no last used template"
			else
				set sArgv to "template.|." & sLastTemplate
			end if
		end if
		
		set text item delimiters to {".|."}
		set sParam to text item 1 of sArgv as text
		set sText to text item 2 of sArgv as text
		set text item delimiters to ""
		
		if sText contains "|" then
			set text item delimiters to {"|"}
			set sLast_Template to text item 1 of sText as text
			set text item delimiters to ""
		else
			set sLast_Template to sText
		end if
		wf's set_value("last_template", sLast_Template)
		
		-->> template note
		if sParam is "template" then
			if sParam contains " |" then
				set text item delimiters to {" |"}
			else
				set text item delimiters to {"|"}
			end if
			set lElems to text items of sText
			set text item delimiters to ""
			
			if lElems is {} then
				--search templates
				tell application id "com.runningwithcrayons.Alfred-3"
					«event alfrSear» "📐: "
				end tell
				return
			else
				--find template by its name then create empty note and open it
				set _selectedNote to ""
				tell application id "com.evernote.Evernote"
					set _Notes to get every note of every notebook where its title contains (item 1 of lElems)
					repeat with _note in _Notes
						if length of _note is not 0 then
							set _selectedNote to item 1 of _note
							exit repeat
						end if
					end repeat
				end tell
				if _selectedNote is "" then
					return "Template not found"
				else
					tell application id "com.evernote.Evernote" -- Evernote
						set sHTML to HTML content of _selectedNote
						set lTags to tags of _selectedNote
						set sNB to name of notebook of _selectedNote
						set sTitle to title of _selectedNote
					end tell
					
					-->> parse template title
					set sParsedTitle to cParseTitle(sTitle)
					set sTitle to item 1 of sParsedTitle
					set sNBTemp to item 2 of sParsedTitle
					
					if sNB is "Template" or sNB is "Templates" then
						tell application id "com.evernote.Evernote" -- Evernote
							if (notebook named sNBTemp exists) then
								set sNB to sNBTemp
							else
								set sNB to ""
							end if
						end tell
					end if
					
					set isOpen to true
					
					if (count lElems) is greater than 1 then
						repeat with j from 2 to (count lElems)
							set sConst to "|" & ((j - 1) as text)
							set sHTML to rt(sHTML, sConst, item j of lElems)
						end repeat
						set isOpen to false
					end if
					
					if sHTML contains "{clipboard}" then
						try
							set sClipboard to get the clipboard as text
						on error
							set sClipboard to ""
						end try
						set sHTML to rt(sHTML, "{clipboard}", sClipboard)
						set isOpen to false
					end if
					if sHTML contains "{selection}" then
						try
							do shell script "sleep 0.5"
							tell application "System Events"
								keystroke "c" using command down
							end tell
							do shell script "sleep 0.2"
							set sSelection to get the clipboard as text
						on error
							set sSelection to ""
						end try
						set sHTML to rt(sHTML, "{selection}", sClipboard)
						set isOpen to false
					end if
					
					
					tell application id "com.evernote.Evernote" -- Evernote
						if sNB is "" then
							set sNewTampleteNote to create note with html sHTML title sTitle tags lTags
						else
							set sNewTampleteNote to create note with html sHTML title sTitle tags lTags notebook sNB
						end if
					end tell
					
					if isOpen is true then
						tell application id "com.evernote.Evernote" to open note window with sNewTampleteNote
						do shell script "sleep 0.1"
						activate
						tell application "System Events" to set frontmost of process "Evernote" to true
					end if
					
				end if
			end if
			return "Added new note from template"
		end if
		
		-- prepare
		set sText to rt(sText, "#@", "#|1|")
		set sText to rt(sText, "##", "#|2|")
		set sText to rt(sText, "@@", "@|3|")
		set sText to rt(sText, "@#", "@|4|")
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
		
		--scan
		repeat with sRef in sText
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
					if sEnTags ends with " " then
						set text item delimiters to ""
						set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
					end if
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
		
		-- prepare
		set sEnTags to rt(sEnTags, "|1|", "@")
		set sEnTags to rt(sEnTags, "|2|", "#")
		set sEnNotebook to rt(sEnNotebook, "|3|", "@")
		set sEnNotebook to rt(sEnNotebook, "|4|", "#")
		set sEnReminder to rt(sEnReminder, ".h.", ":")
		set text item delimiters to ""
		if sEnNotebook ends with " " then set sEnNotebook to text 1 thru ((count sEnNotebook) - 1) of sEnNotebook
		if sEnTags ends with " " then set sEnTags to text 1 thru ((count sEnTags) - 1) of sEnTags
		if sEnTitle ends with " " then set sEnTitle to text 1 thru ((count sEnTitle) - 1) of sEnTitle
		if sEnReminder ends with " " then set sEnReminder to text 1 thru ((count sEnReminder) - 1) of sEnReminder
		if sEnReminder is "(none)" then set sEnReminder to ""
		if sEnReminder is not "" then set sEnReminder to get_date(sEnReminder)
		if sEnReminder is "(date not valid)" then return "Error: Date format not accepted"
		
		--parse date
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
		
		set sNoteBook to sEnNotebook
		set sText to sEnTitle
		
		if sEnTags is not "" then
			set text item delimiters to {","}
			repeat with j from 1 to (count text items) of sEnTags
				set sCur to trim(text item j of sEnTags)
				set end of lTags to sCur
			end repeat
			set text item delimiters to ""
		else
			set lTags to {}
		end if
	end if
	
	tell application "System Events" to set appName to (item 1 of (get name of processes whose frontmost is true)) as string
	
	set sURL to ""
	try
		if appName = "Safari" then
			tell application "Safari"
				set sURL to (URL of current tab of window 1 as text)
			end tell
		else if appName = "Chrome" or appName = "Google Chrome" then
			set sURL to (run script POSIX file (POSIX path of ((POSIX file ((POSIX path of (path to me)) & "/..") as text) & "en_google.scpt" as text) as text)) as text
		else if appName = "Firefox" then
			set sPy to quoted form of (POSIX path of (POSIX file (POSIX path of ((path to me as text) & "::") & "urlfox.py")))
			set sURL to do shell script "python " & sPy
		end if
	on error
		set sURL to ""
	end try
	
	--create notebook
	if not sNoteBook = "" then
		tell application id "com.evernote.Evernote"
			if (not (notebook named sNoteBook exists)) then
				make notebook with properties {name:sNoteBook}
			else
				--check notebook name to make sure the correct case is passed to Evernote
				set sNoteBook to name of notebook named sNoteBook
			end if
		end tell
	end if
	
	if sParam = "clip" then
		wf's set_value("lastmenuitem", "Clipboard")
		set sApHtml to wf's get_value("adv_aphtml")
		set sNote to get the clipboard
		if sText = "" then
			set delimitedList to paragraphs of sNote
			set sTitle to item 1 of delimitedList as text
			set sTitle to trim(sTitle)
			set sTitle to MakeShort(sTitle) as text
		else
			set sTitle to sText
		end if
		
		if sApHtml is "On" then
			if appName is "Script Debugger" or appName is "AppleScript Editor" then
				set isHTML to true
				run script POSIX file (POSIX path of ((path to me as text) & "::") & "en_ashtml.scpt")
				do shell script "sleep 0.2"
				set sNote to get the clipboard
			end if
		end if
		
	else if sParam = "clippng" then
		wf's set_value("lastmenuitem", "Clipboard")
		if sText = "" then
			set sText to "Screenshot"
		else
			set sTitle to sText
		end if
		
		set tempFolder to POSIX path of (path to temporary items) & "en_newnote_pic"
		try
			do shell script "mkdir " & quoted form of (tempFolder)
		on error
			try
				do shell script "rm -r " & quoted form of (tempFolder) & "/*"
			end try
		end try
		
		set tempFile to (POSIX file (tempFolder & "/pic.png") as text)
		
		set myFile to (open for access tempFile with write permission)
		set eof myFile to 0
		write (the clipboard as «class PNGf») to myFile -- as whatever
		close access myFile
		
		set x to POSIX path of tempFile
		
		tell application id "com.evernote.Evernote"
			if lTags = {} then
				if sNoteBook = "" then
					set n to create note title sText from file x
				else
					try
						set n to create note title sText from file x notebook sNoteBook
					on error
						return "Error: notebook name is case sensitive."
					end try
				end if
			else
				if sNoteBook = "" then
					set n to create note title sText from file x tags lTags
				else
					try
						set n to create note title sText from file x tags lTags notebook sNoteBook
					on error
						return "Error: notebook name is case sensitive."
					end try
				end if
			end if
			if sEnReminder is not "" then
				set reminder done time of n to missing value
				set reminder time of n to missing value
				set reminder time of n to dDate
			end if
		end tell
		if n is missing value or n is "" then return "Feature is not compatible with Evernote from Mac App Store"
		tell application id "com.evernote.Evernote" to synchronize
		try
			do shell script "rm -r " & quoted form of (tempFolder)
		end try
		if sOpen is "-o" then
			tell application id "com.evernote.Evernote"
				open note window with n
				activate
				return
			end tell
		else
			return "Added new note from an image from clipboard"
		end if
		
	else if sParam = "url" then
		wf's set_value("lastmenuitem", "URL")
		tell application id "com.evernote.Evernote"
			if lTags = {} then
				if sNoteBook = "" then
					set n to create note from url sURL
				else
					try
						set n to create note from url sURL notebook sNoteBook
					on error
						return "Error: notebook name is case sensitive."
					end try
				end if
			else
				if sNoteBook = "" then
					set n to create note from url sURL tags lTags
				else
					try
						set n to create note from url sURL tags lTags notebook sNoteBook
					on error
						return "Error: notebook name is case sensitive."
					end try
				end if
			end if
			synchronize
		end tell
		return "Note should be available soon"
	else if sParam = "sel" then
		wf's set_value("lastmenuitem", "Selection")
		set sApHtml to wf's get_value("adv_aphtml")
		do shell script "sleep 0.5"
		tell application "System Events"
			keystroke "c" using command down
		end tell
		do shell script "sleep 0.2"
		set sNote to get the clipboard
		if sText = "" then
			set delimitedList to paragraphs of sNote
			set sTitle to item 1 of delimitedList as text
			set sTitle to trim(sTitle)
			set sTitle to MakeShort(sTitle) as text
		else
			set sTitle to sText
		end if
		
		if sApHtml is "On" then
			if appName is "Script Debugger" or appName is "AppleScript Editor" then
				set isHTML to true
				run script POSIX file (POSIX path of ((path to me as text) & "::") & "en_ashtml.scpt")
				do shell script "sleep 0.2"
				set sNote to get the clipboard
			end if
		end if
		
		if appName = "Mail" then
			tell application "Mail" to set sMailSel to selection as list
			if not sMailSel = {} then
				tell application "Mail"
					set sMail to item 1 of sMailSel
					if sText = "" then set sTitle to the subject of sMail
					set sURL to "message:%3c" & sMail's message id & "%3e"
					set sCDate to the date received of sMail
					set theHeader to the all headers of sMail
					set sNote to (paragraph 1 of theHeader & return & paragraph 2 of theHeader & return & paragraph 3 of theHeader & return & paragraph 4 of theHeader & return & return & sNote)
				end tell
			end if
		end if
	else if sParam = "Alf_File" then
		tell application "Finder"
			set theFile to POSIX file (sArgv) as alias
			set theTitle to name of theFile
			set sCDate to creation date of theFile
		end tell
		set x to POSIX path of sArgv
		tell application id "com.evernote.Evernote"
			set n to create note title theTitle from file x
			if n is missing value or n is "" then return "Feature is not compatible with Evernote from Mac App Store"
			set the creation date of n to sCDate
			synchronize
			return title of n
		end tell
	else if sParam = "Alf_MultFiles" then
		if isNotePerFile is false then
			set iC to (count lst_MultFiles) as string
			tell application id "com.evernote.Evernote"
				set n to create note title iC & " Files" with text return
			end tell
			repeat with sCur in lst_MultFiles
				tell application "Finder"
					set theTitle to name of sCur
					--set sCDate to creation date of sCur
				end tell
				set x to POSIX path of sCur
				tell application id "com.evernote.Evernote"
					tell n to append attachment x
				end tell
			end repeat
			if n is missing value or n is "" then return "Feature is not compatible with Evernote from Mac App Store"
			tell application id "com.evernote.Evernote"
				synchronize
			end tell
			return "Added a note with " & iC & " files"
		else
			repeat with sCur in lst_MultFiles
				tell application "Finder"
					set theTitle to name of sCur
					set sCDate to creation date of sCur
				end tell
				set x to POSIX path of sCur
				tell application id "com.evernote.Evernote"
					set n to create note title theTitle from file x
					try
						set the creation date of n to sCDate
					on error
						exit repeat
					end try
				end tell
			end repeat
			if n is missing value or n is "" then return "Feature is not compatible with Evernote from Mac App Store"
			tell application id "com.evernote.Evernote" to synchronize
			return "Added " & (count lst_MultFiles) & " notes"
		end if
	else if sParam = "npf" then
		wf's set_value("lastmenuitem", "each")
		tell application "Finder" to set someSource to selection as alias list
		if someSource = {} then
			return "Select a file in Finder first"
		else
			repeat with sCur in someSource
				tell application "Finder"
					set theFile to sCur as alias
					set theTitle to name of theFile
					set sCDate to creation date of sCur
				end tell
				set sText to theTitle
				set x to POSIX path of theFile
				tell application id "com.evernote.Evernote"
					if lTags = {} then
						if sNoteBook = "" then
							set n to create note title sText from file x
						else
							try
								set n to create note title sText from file x notebook sNoteBook
							on error
								return "Error: notebook name is case sensitive."
							end try
						end if
					else
						if sNoteBook = "" then
							set n to create note title sText from file x tags lTags
						else
							try
								set n to create note title sText from file x tags lTags notebook sNoteBook
							on error
								return "Error: notebook name is case sensitive."
							end try
						end if
					end if
					set the creation date of n to sCDate
					if sEnReminder is not "" then
						set reminder done time of n to missing value
						set reminder time of n to missing value
						set reminder time of n to dDate
					end if
				end tell
			end repeat
			tell application id "com.evernote.Evernote" to synchronize
			if sOpen is "-o" then
				tell application id "com.evernote.Evernote"
					open note window with n
					activate
					return
				end tell
			else
				return "Added " & (count someSource) & " notes"
				--return "Added a note from Finder with " & (count someSource) & " file(s)"
			end if
		end if
	else if sParam = "file" then
		wf's set_value("lastmenuitem", "Finder")
		tell application "Finder" to set someSource to selection as alias list
		if someSource = {} then
			return "Select a file in Finder first"
		else if (count someSource) is 1 then
			tell application "Finder"
				set theFile to item 1 of someSource as alias
				set theTitle to name of theFile
				set sCDate to creation date of theFile
			end tell
			if sText is "" then set sText to theTitle
			set x to POSIX path of theFile
			
			tell application id "com.evernote.Evernote"
				if lTags = {} then
					if sNoteBook = "" then
						set n to create note title sText from file x
					else
						try
							set n to create note title sText from file x notebook sNoteBook
						on error
							return "Error: notebook name is case sensitive."
						end try
					end if
				else
					if sNoteBook = "" then
						set n to create note title sText from file x tags lTags
					else
						try
							set n to create note title sText from file x tags lTags notebook sNoteBook
						on error
							return "Error: notebook name is case sensitive."
						end try
					end if
				end if
				if sEnReminder is not "" then
					set reminder done time of n to missing value
					set reminder time of n to missing value
					set reminder time of n to dDate
				end if
			end tell
			if n is missing value or n is "" then return "Feature is not compatible with Evernote from Mac App Store"
			tell application id "com.evernote.Evernote" to synchronize
			if sOpen is "-o" then
				tell application id "com.evernote.Evernote"
					open note window with n
					activate
					return
				end tell
			else
				return "Added a note from 1 file"
			end if
		else
			set iC to (count someSource) as string
			if sText is "" then set sText to iC & " Files"
			tell application id "com.evernote.Evernote"
				if lTags = {} then
					if sNoteBook = "" then
						set n to create note title sText with text return
					else
						try
							set n to create note title sText with text return notebook sNoteBook
						on error
							return "Error: notebook name is case sensitive."
						end try
					end if
				else
					if sNoteBook = "" then
						set n to create note title sText with text return tags lTags
					else
						try
							set n to create note title sText with text return tags lTags notebook sNoteBook
						on error
							return "Error: notebook name is case sensitive."
						end try
					end if
				end if
			end tell
			if n is missing value or n is "" then return "Feature is not compatible with Evernote from Mac App Store"
			repeat with sCur in someSource
				set x to POSIX path of sCur
				tell application id "com.evernote.Evernote"
					tell n to append attachment x
				end tell
			end repeat
			if sEnReminder is not "" then
				tell application id "com.evernote.Evernote"
					set reminder done time of n to missing value
					set reminder time of n to missing value
					set reminder time of n to dDate
				end tell
			end if
			tell application id "com.evernote.Evernote" to synchronize
			if sOpen is "-o" then
				tell application id "com.evernote.Evernote"
					open note window with n
					activate
					return
				end tell
			else
				return "Added a note from Finder with " & (count someSource) & " files"
			end if
		end if
	else if sParam = "mail" then
		wf's set_value("lastmenuitem", "Mail")
		tell application "Mail" to set theSelection to selection
		repeat with theMessage in theSelection
			tell application "Mail"
				set theMessageDate to the date received of theMessage
				set sTitle to the subject of the theMessage
				set theMessageContent to the content of theMessage
				set sURL to "message:%3c" & theMessage's message id & "%3e"
				set theHeader to the all headers of theMessage
			end tell
			set sNote to (paragraph 1 of theHeader & return & paragraph 2 of theHeader & return & paragraph 3 of theHeader & return & paragraph 4 of theHeader & return & return & theMessageContent)
			tell application id "com.evernote.Evernote"
				if lTags = {} then
					if sNoteBook = "" then
						set n to create note title sTitle with text sNote
					else
						try
							set n to create note title sTitle with text sNote notebook sNoteBook
						on error
							return "Error: notebook name is case sensitive."
						end try
					end if
				else
					if sNoteBook = "" then
						set n to create note title sTitle with text sNote tags lTags
					else
						try
							set n to create note title sTitle with text sNote tags lTags notebook sNoteBook
						on error
							return "Error: notebook name is case sensitive."
						end try
					end if
				end if
				set the source URL of n to sURL
				set the creation date of n to theMessageDate
				if sEnReminder is not "" then
					set reminder done time of n to missing value
					set reminder time of n to missing value
					set reminder time of n to dDate
				end if
				tell application "Mail"
					if theMessage's mail attachments is not {} then
						my SaveAttachements(theMessage, n)
					end if
				end tell
			end tell
		end repeat
		tell application id "com.evernote.Evernote" to synchronize
		if sOpen is "-o" then
			tell application id "com.evernote.Evernote"
				open note window with n
				activate
				return
			end tell
		else
			return "Added " & (count theSelection) & " notes from Mail"
		end if
	else
		-->>Type Note
		wf's set_value("lastmenuitem", "Type")
		set sNote to ""
		if sText contains " /n " then
			set text item delimiters to {" /n "}
			set lst_TypeText to text items of sText
			set text item delimiters to ""
			repeat with j from 1 to (count lst_TypeText)
				if j is 1 then
					set sTitle to item j of lst_TypeText
				else if j is (count lst_TypeText) then
					set sNote to sNote & item j of lst_TypeText
				else
					set sNote to sNote & item j of lst_TypeText & return
				end if
			end repeat
		else
			set sNote to sText
			set sTitle to sText
		end if
	end if
	
	if sTitle = "" then set sTitle to "Note from Alfred"
	
	tell application id "com.evernote.Evernote"
		if lTags = {} then
			if sNoteBook = "" then
				if isHTML then
					set n to create note title sTitle with html sNote
				else
					set n to create note title sTitle with text sNote
				end if
			else
				try
					if isHTML then
						set n to create note title sTitle with html sNote notebook sNoteBook
					else
						set n to create note title sTitle with text sNote notebook sNoteBook
					end if
				on error
					return "Error: notebook name is case sensitive."
				end try
			end if
		else
			if sNoteBook = "" then
				if isHTML then
					set n to create note title sTitle with html sNote tags lTags
				else
					set n to create note title sTitle with text sNote tags lTags
				end if
			else
				try
					if isHTML then
						set n to create note title sTitle with html sNote tags lTags notebook sNoteBook
					else
						set n to create note title sTitle with text sNote tags lTags notebook sNoteBook
					end if
				on error
					return "Error: notebook name is case sensitive."
				end try
			end if
		end if
		if not sURL = "" then set the source URL of n to sURL
		if sEnReminder is not "" then
			set reminder done time of n to missing value
			set reminder time of n to missing value
			set reminder time of n to dDate
		end if
		synchronize
		if sOpen is "-o" then
			open note window with n
			activate
			return
		else
			return title of n
		end if
	end tell
end run
on MakeShort(strg)
	if length of strg is less than 60 then
		set strg to strg
	else
		set text item delimiters to ""
		set strg to text 1 thru 60 of strg
		set strg to trim(strg) & "…"
	end if
	return strg
end MakeShort
on trim(strg)
	ignoring white space
		set left_counter to 1
		repeat with j from 1 to length of strg
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
		set right_counter to -1
		repeat with j from 1 to length of strg
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
	end ignoring
	return strg
end trim
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
	on error msg
		return false
	end try
end q_path_exists
on SaveAttachements(theMessage, n)
	set tempFolder to quoted form of (POSIX path of (path to temporary items) & "enworkflow")
	set tempFolder2 to (path to temporary items) & "enworkflow:" as string
	try
		do shell script "mkdir " & tempFolder
	on error
		try
			do shell script "rm -r " & tempFolder & "/*"
		end try
	end try
	set text item delimiters to ""
	tell application "Mail"
		set theAttachments to theMessage's mail attachments
		set attCount to 0
		repeat with theAttachment in theAttachments
			set theFileName to tempFolder2 & theAttachment's name
			try
				save theAttachment in file theFileName
			end try
			tell application id "com.evernote.Evernote"
				tell n to append attachment file theFileName
			end tell
		end repeat
	end tell
	try
		do shell script "rm -r " & tempFolder
	end try
end SaveAttachements

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

on cParseTitle(_title)
	set sTempTitle to _title
	try
		if sTempTitle contains "(notebook:" then
			set text item delimiters to {"(notebook:"}
			set sNB to the last text item of sTempTitle
			set sTitle to text item 1 of sTempTitle
			set text item delimiters to ""
			set sNB to text 1 thru ((count sNB) - 1) of sNB
			if sTitle is not "" then
				set sTitle to text 1 thru ((count sTempTitle) - (count ("(notebook:" & sNB & ")"))) of sTempTitle
				if sTitle ends with " " then set sTitle to text 1 thru ((count sTitle) - 1) of sTitle
			end if
		else if sTempTitle contains "[notebook:" then
			set text item delimiters to {"[notebook:"}
			set sNB to the last text item of sTempTitle
			set sTitle to text item 1 of sTempTitle
			set text item delimiters to ""
			set sNB to text 1 thru ((count sNB) - 1) of sNB
			if sTitle is not "" then
				set sTitle to text 1 thru ((count sTempTitle) - (count ("(notebook:" & sNB & "]"))) of sTempTitle
				if sTitle ends with " " then set sTitle to text 1 thru ((count sTitle) - 1) of sTitle
			end if
		else if sTempTitle contains "[" and sTempTitle contains "]" then
			set text item delimiters to {"[", "]"}
			set sNB to text item 2 of sTempTitle
			set sTitle to text item 1 of sTempTitle
			set text item delimiters to ""
			if sTitle ends with " " then set sTitle to text 1 thru ((count sTitle) - 1) of sTitle
		else if sTempTitle contains "(" and sTempTitle contains ")" then
			set text item delimiters to {"(", ")"}
			set sNB to text item 2 of sTempTitle
			set sTitle to text item 1 of sTempTitle
			set text item delimiters to ""
			if sTitle ends with " " then set sTitle to text 1 thru ((count sTitle) - 1) of sTitle
		else if sTempTitle contains "notebook:" then
			set text item delimiters to {"notebook:"}
			set sNB to the last text item of sTempTitle
			set sTitle to text item 1 of sTempTitle
			set text item delimiters to ""
			if sTitle is not "" then
				set sTitle to text 1 thru ((count sTempTitle) - (count ("notebook:" & sNB))) of sTempTitle
				if sTitle ends with " " then set sTitle to text 1 thru ((count sTitle) - 1) of sTitle
			end if
		else if sTempTitle contains "@@" then
			set text item delimiters to {"@@"}
			set sNB to the last text item of sTempTitle
			set sTitle to text item 1 of sTempTitle
			set text item delimiters to ""
			set sNB to "@" & sNB
			if sTitle ends with " " then set sTitle to text 1 thru ((count sTitle) - 1) of sTitle
		else if sTempTitle contains "@" then
			set text item delimiters to {"@"}
			set sNB to the last text item of sTempTitle
			set sTitle to text item 1 of sTempTitle
			set text item delimiters to ""
			if sTitle ends with " " then set sTitle to text 1 thru ((count sTitle) - 1) of sTitle
		else
			set sTitle to sTempTitle
			set sNB to ""
		end if
	on error
		set sTitle to sTempTitle
		set sNB to ""
	end try
	return {sTitle, sNB}
end cParseTitle
