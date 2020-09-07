on run argv
	set wf to load script POSIX path of ((path to me as text) & "::") & "workflow.scpt"
	set wf to wf's new_workflow("com.sztoltz.evernote")
	set sArgv to argv as text
	if sArgv ends with "|-f|" then
		set text item delimiters to {"|-f|"}
		set sArgv to text item 1 of sArgv
		set text item delimiters to ""
		set sTemplateCMD to sArgv
		set sSubTemplate to ""
		
		if sArgv starts with "%" then
			set text item delimiters to {"%"}
			set sQuery to text item 2 of sArgv
			set text item delimiters to ""
			set matches to {}
			set iMax to 15 as integer
			
			tell application id "com.evernote.Evernote"
				if (notebook named "Templates" exists) then
					set matches to find notes "notebook:Templates " & sQuery & "*"
				else if (notebook named "Template" exists) then
					set matches to find notes "notebook:Template " & sQuery & "*"
				else
					set matches to find notes "intitle:" & sQuery & "*"
				end if
				--set sAcc to name of current account as string
			end tell
			--set sHome to (POSIX path of (path to home folder) as string)
			--set sSupp to (POSIX path of (path to application support folder) as string)
			--set text item delimiters to ""
			--set sSupp to text 2 thru (count sSupp) of sSupp as string
			if matches = {} then
				add_ of wf given U:"", A:"", T:"No results", S:"", AC:"", I:"", TY:"", M:{}, TC:"", LT:"", V:0
			else
				--set matches to get the reverse of matches
				set I to 0 as integer
				set iCount to (count matches)
				repeat with j from 1 to (count matches)
					if I = iMax then exit repeat
					tell application id "com.evernote.Evernote"
						set sTitle to title of (item j of matches) as text
						--set sLocID to local id of (item j of matches) as string
						set sLocID to note link of (item j of matches) as string
					end tell
					--set text item delimiters to {"/"}
					--set sLocID to last text item of sLocID as string
					--set text item delimiters to ""
					--set sFile to sHome & sSupp & "Evernote/accounts/Evernote/" & sAcc & "/content/" & sLocID & "/content.html" as string
					set sFile to sLocID
					--set sEnSnippt to sHome & sSupp & "Evernote/accounts/Evernote/" & sAcc & "/content/" & sLocID & "/snippet.png" as string
					--if cPathExists(sEnSnippt) then
					--	set sFile to sHome & sSupp & "Evernote/accounts/Evernote/" & sAcc & "/content/" & sLocID & "/quickLook.png" as string
					--end if
					add_ of wf given U:sTitle, A:sFile, T:sTitle, S:"", AC:sTitle, I:"icon2.png", TY:"file", M:{}, TC:"", LT:"", V:0
					set I to (I + 1) as integer
				end repeat
			end if
			return wf's to_xml("")
		end if
		
		add_ of wf given U:"", A:"template.|." & sTemplateCMD, T:"New Note from Template", S:"Optionally type the template name or % to list them", AC:"", I:"icon2.png", TY:"", M:{}, TC:"", LT:"", V:1
		
		set sLastTemplate to wf's get_value("last_template")
		if sLastTemplate is not "" then
			add_ of wf given U:"", A:"", T:"Last Used Template", S:sLastTemplate, AC:sLastTemplate, I:"icon2.png", TY:"", M:{}, TC:"", LT:"", V:0
		end if
		
		set sHelp to (POSIX path of ((do shell script "pwd") & "/Evernote Templates.html"))
		set lMods to {{"cmd", "Press Return Key to Open Help"}, {"alt", "Press Return Key to Open Help"}, {"ctrl", "Press Return Key to Open Help"}}
		add_ of wf given U:"", A:sHelp, T:"Help", S:"Learn about templates and advanced features", AC:"", I:"arrow.png", TY:"file", M:lMods, TC:"", LT:"", V:1
		return wf's to_xml("")
		
	else if sArgv ends with "|-t|" then
		set text item delimiters to {"|-t|"}
		set sArgv to text item 1 of sArgv
		set text item delimiters to ""
		(*
		set text item delimiters to {"/content/", "/content."}
		set sLocID to text item 2 of sArgv
		set text item delimiters to ""
		if sLocID contains "/quickLook.png" then
			set text item delimiters to {"/quickLook.png"}
			set sLocID to text item 1 of sLocID
			set text item delimiters to ""
		end if
		*)
		
		set _selectedNote to ""
		
		tell application id "com.evernote.Evernote"
			set _selectedNote to find note sLocID
			--set _Notes to get every note of every notebook where its local id ends with sLocID
			--repeat with _note in _Notes
			--	if length of _note is not 0 then
			--		set _selectedNote to item 1 of _note
			--		exit repeat
			--	end if
			--end repeat
		end tell
		
		if not (exists (_selectedNote)) then
			return "Template not found"
		else
			tell application id "com.evernote.Evernote" -- Evernote
				set sHTML to HTML content of _selectedNote
				set lTags to tags of _selectedNote
				set sNB to name of notebook of _selectedNote
				set sTitle to title of _selectedNote
			end tell
			
			(*
			if sTitle contains "(id_" then
				--remove template code
				set text item delimiters to {"(id_"}
				set sTitle to text item 1 of sTitle
				set text item delimiters to ""
			end if
			*)
			set sParsedTitle to cParseTitle(sTitle)
			set sTitle to item 1 of sParsedTitle
			
			tell application id "com.evernote.Evernote" -- Evernote
				set sNewTampleteNote to create note with html sHTML title sTitle tags lTags notebook sNB
				open note window with sNewTampleteNote
				do shell script "sleep 0.1"
				activate
				tell application "System Events" to set frontmost of process "Evernote" to true
			end tell
		end if
		return "Added new note from template"
	else
		set matches to {}
		set iMax to 20 as integer
		try
			tell application id "com.evernote.Evernote"
				set matches to find notes "intitle:" & sArgv
				set sAcc to name of current account as string
			end tell
			--set sHome to (POSIX path of (path to home folder) as string)
			--set sSupp to (POSIX path of (path to application support folder) as string)
			--set text item delimiters to ""
			--set sSupp to text 2 thru (count sSupp) of sSupp as string
			if matches = {} then
				add_ of wf given U:"", A:"", T:"No results", S:"", AC:"", I:"", TY:"", M:{}, TC:"", LT:"", V:0
			else
				--set matches to get the reverse of matches
				set I to 0 as integer
				set iCount to (count matches)
				repeat with j from 1 to (count matches)
					if I = iMax then exit repeat
					tell application id "com.evernote.Evernote"
						set sTitle to title of (item j of matches) as text
						set sLocID to note link of (item j of matches) as string
					end tell
					--set text item delimiters to {"/"}
					--set sLocID to last text item of sLocID as string
					--set text item delimiters to ""
					set sFile to sLocID --sHome & sSupp & "Evernote/accounts/Evernote/" & sAcc & "/content/" & sLocID & "/content.html" as string
					--set sEnSnippt to sHome & sSupp & "Evernote/accounts/Evernote/" & sAcc & "/content/" & sLocID & "/snippet.png" as string
					--if cPathExists(sEnSnippt) then
					--	set sFile to sHome & sSupp & "Evernote/accounts/Evernote/" & sAcc & "/content/" & sLocID & "/quickLook.png" as string
					--end if
					add_ of wf given U:sTitle, A:sFile, T:sTitle, S:"", AC:"", I:"icon2.png", TY:"file", M:{}, TC:"", LT:"", V:1
					set I to (I + 1) as integer
				end repeat
			end if
		end try
		return wf's to_xml("")
	end if
end run

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
