on run argv
	set wf to load script POSIX path of ((path to me as text) & "::") & "workflow.scpt"
	set wf to wf's new_workflow("com.sztoltz.evernote")
	set sArgv to argv as text
	set iMax to 10 as integer
	set matches to {}
	set sTask to ""
	set sSearchT to ""
	set isRM to false
	set isRec to false
	set isTD to false
	set isURL to false
	set sURL to ""
	set sKeyWord to ""
	
	if sArgv starts with "lastquery:" then
		set sKeyQ to wf's get_value("last_key")
		if sKeyQ is "" then set sKeyQ to "ens"
		set sLastQ to wf's get_value("last_query")
		if sLastQ is " " then set sLastQ to ""
		tell application id "com.runningwithcrayons.Alfred-3" to «event alfrSear» sKeyQ & " " & sLastQ
		if sLastQ is not "" then
			do shell script "sleep 0.5"
			tell application "System Events"
				key code 123 using {option down, shift down}
			end tell
		end if
		return
	end if
	
	--set sQL to wf's get_value("quicklook")
	set sWC to wf's get_value("search")
	
	if sWC is "Automatic" then
		set sWC to "*"
	else
		set sWC to ""
	end if
	
	if sArgv starts with "todo:" then
		set sKeyWord to "entodo"
		set text item delimiters to {"todo:"}
		set sSearchT to "todo:false "
		set sArgv to text item 2 of sArgv
		set text item delimiters to ""
		set isRM to true
		set isRec to true
		set isTD to true
	else if sArgv starts with "updated:" then
		set sKeyWord to "enrec"
		set text item delimiters to {"updated:"}
		set sSearchT to "updated:week-1 "
		set sArgv to text item 2 of sArgv
		set text item delimiters to ""
		set isRM to true
		set isRec to true
	else if sArgv starts with "reminder:" then
		set sKeyWord to "enr"
		set text item delimiters to {"reminder:"}
		set sSearchT to "reminderTime:* -reminderDoneTime:* "
		set sArgv to text item 2 of sArgv
		set text item delimiters to ""
		set isRM to true
	else if sArgv starts with "intitle:" then
		set sKeyWord to "ent"
		set text item delimiters to {"intitle:"}
		set sSearchT to "intitle:"
		set sArgv to text item 2 of sArgv
		set text item delimiters to ""
	else if sArgv starts with "url:" then
		set sKeyWord to "enu"
		set text item delimiters to {"url:"}
		set sSearchT to "sourceurl:* "
		set sArgv to text item 2 of sArgv
		set text item delimiters to ""
		set isURL to true
	end if
	
	-- save last search
	if sArgv contains "@" or sArgv contains "#" then
		if sArgv contains ":" then
			--save
			wf's set_value("last_key", sKeyWord)
			wf's set_value("last_query", sArgv)
		end if
	else
		--save
		wf's set_value("last_key", sKeyWord)
		wf's set_value("last_query", sArgv)
	end if
	
	
	-->> Alfred Preference - Hide result subtext
	try
		set isHideSubText to (system attribute "alfred_theme_subtext")
	on error
		set isHideSubText to false
	end try
	if isHideSubText is greater than 0 then set isHideSubText to true
	
	set sArgvOri to sArgv --for auto complete
	set sArgv to rt(sArgv, "#@", "#|1|")
	set sArgv to rt(sArgv, "##", "#|2|")
	set sArgv to rt(sArgv, "@@", "@|3|")
	set sArgv to rt(sArgv, "@#", "@|4|")
	
	if sArgv contains "@" then
		set text item delimiters to {"@"}
		set iC to count text items of sArgv
		set text item delimiters to ""
		if iC is greater than 2 then
			add_ of wf given u:"", a:"", t:"Search in only one notebook at time", s:"", AC:"", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			return wf's to_xml("")
		end if
	end if
	
	if sArgv ends with "@" and sArgv does not contain ":" then
		tell application id "com.evernote.Evernote" to set matches to name of every notebook
		if matches = {} then
			add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
		else
			repeat with sCur in matches
				add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:sArgv & "" & sCur & " :", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			end repeat
		end if
		return wf's to_xml("")
	else if sArgv ends with "#" and sArgv does not contain ":" then
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
	end if
	
	set isArgvTag to false
	set isArgvNB to false
	set isArgvQ to false
	set sArgvNB to ""
	set sArgvTags to ""
	set sArgvQ to ""
	set sLastTag to ""
	repeat with sRef in sArgv
		set c to contents of sRef
		if c is "@" then
			set isArgvNB to true
			set isArgvTag to false
			set isArgvQ to false
		else if c is "#" then
			set isArgvNB to false
			set isArgvTag to true
			set isArgvQ to false
			if sArgvTags is not "tag:" then set sArgvTags to sArgvTags & "tag:"
			if sLastTag is not "" then set sLastTag to ""
		else if c is ":" then
			set isArgvNB to false
			set isArgvTag to false
			set isArgvQ to true
		else
			if isArgvNB then set sArgvNB to sArgvNB & c
			if isArgvTag then
				set sArgvTags to sArgvTags & c
				set sLastTag to sLastTag & c
			end if
			if isArgvQ then set sArgvQ to sArgvQ & c
		end if
	end repeat
	set sArgvTags to rt(sArgvTags, "|1|", "@")
	set sArgvTags to rt(sArgvTags, "|2|", "#")
	set sLastTag to rt(sLastTag, "|1|", "@")
	set sLastTag to rt(sLastTag, "|2|", "#")
	set sArgvNB to rt(sArgvNB, "|3|", "@")
	set sArgvNB to rt(sArgvNB, "|4|", "#")
	try
		set text item delimiters to ""
		if sArgvNB ends with " " then set sArgvNB to text 1 thru ((count sArgvNB) - 1) of sArgvNB
		if sArgvTags ends with " " then set sArgvTags to text 1 thru ((count sArgvTags) - 1) of sArgvTags
		if sLastTag ends with " " then set sLastTag to text 1 thru ((count sLastTag) - 1) of sLastTag
		if sArgvQ ends with " " then set sArgvQ to text 1 thru ((count sArgvQ) - 1) of sArgvQ
	on error
		add_ of wf given u:"", a:"", t:"Select or type a valid entry", s:"", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:0
		return wf's to_xml("")
	end try
	
	set sQuotedNB to ""
	if sArgvNB is not "" then set sQuotedNB to "\"" & sArgvNB & "\""
	
	set sQuotedTags to ""
	set lQuotedTags to {}
	if sArgvTags is not "" then
		set text item delimiters to {"tag:"}
		repeat with i from 1 to count text items of sArgvTags
			if i is not 1 then
				set sCur to contents of text item i of sArgvTags
				set end of lQuotedTags to sCur
			end if
		end repeat
		set text item delimiters to ""
		repeat with sCur in lQuotedTags
			-->> trim
			--set sCur to wf's q_trim(sCur)
			set sCur to q_trim(sCur)
			set sQuotedTags to sQuotedTags & "tag:" & "\"" & sCur & "\"" & " "
		end repeat
	end if
	
	if sArgv contains "@" and sArgv contains "#" then
		-->>scan was here		
		if sArgv does not contain ":" then
			if isArgvTag is true then --list tags
				tell application id "com.evernote.Evernote" to set matches to name of every tag
				if matches = {} then
					add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
				else
					set iCTags to 0 as integer
					repeat with j from 1 to (count matches)
						set sCur to item j of matches
						if sCur contains sLastTag then
							set sAutoC to trim_line(sArgvOri, "#" & sLastTag, 1)
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
			else if isArgvNB is true then --list notebooks
				tell application id "com.evernote.Evernote" to set matches to name of every notebook
				if matches = {} then
					add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
				else
					repeat with j from 1 to (count matches)
						set sCur to item j of matches
						if sCur contains sArgvNB then
							set sAutoC to trim_line(sArgvOri, "@" & sArgvNB, 1)
							set sAutoC to sAutoC & "@" & sCur
							add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:sAutoC & " :", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
						end if
					end repeat
				end if
				if wf's get_results() is not {} then
					return wf's to_xml("")
				end if
			end if
		else
			-- search notes here with notebook + tags
			tell application id "com.evernote.Evernote"
				set matches to find notes "notebook:" & sQuotedNB & " " & sQuotedTags & " " & sSearchT & sArgvQ & sWC
			end tell
			if matches = {} then
				add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:0
			else
				--set matches to get the reverse of matches
				set i to 0 as integer
				set lstNotes to {}
				set iCount to (count matches)
				if iCount > iMax then
					set sSub to "Displaying " & iMax & " notes of " & iCount & " found"
				else
					set sSub to "Found " & iCount & " notes"
				end if
				-->> "Show in Evernote"
				set sShowInEN to setShowInENTitle(isHideSubText, iCount)
				if isRM is false then
					set lMods to {{"cmd", "Not Applicable"}, {"alt", "Not Applicable"}, {"ctrl", "Not Applicable"}, {"fn", "Not Applicable"}}
					add_ of wf given u:"", a:".|." & "notebook:" & sQuotedNB & " " & sQuotedTags & " " & sSearchT & sArgvQ & sWC, t:sShowInEN, s:sSub, AC:"", i:"", ty:"", M:lMods, Tc:"", Lt:"", V:1
					repeat with j from 1 to (count matches)
						if i = iMax then exit repeat
						tell application id "com.evernote.Evernote"
							set sTitle to title of (item j of matches) as text
							set sLocID to note link of (item j of matches) as string
							if isURL then set sURL to source URL of (item j of matches) as string
						end tell
						if isURL then set sURL to EN_URL(sURL)
						add_ of wf given u:"", a:sLocID, t:sTitle, s:sURL, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						set i to (i + 1) as integer
					end repeat
				else
					repeat with j from 1 to (count matches)
						tell application id "com.evernote.Evernote"
							set sTitle to title of (item j of matches) as text
							if isRec is false then
								set sDateSort to reminder time of (item j of matches)
							else
								set sDateSort to modification date of (item j of matches)
							end if
							set sTime to sDateSort as text
							set sLocID to note link of (item j of matches) as string
						end tell
						set end of lstNotes to get EN_date(sDateSort, sTime, sLocID, sTitle)
					end repeat
					-- sort
					set text item delimiters to {ASCII character 10}
					set lstNotes to lstNotes as string
					set lstNotes to paragraphs of (do shell script "echo " & quoted form of (lstNotes) & " | sort -n")
					set text item delimiters to ""
					--if isRec is true and isTD is false then set lstNotes to get the reverse of lstNotes
					-- menu items
					set iCount to (count lstNotes)
					set sSub to EN_sub(isTD, isRec, iCount, iMax)
					set sK to EN_ShowIn(sSearchT, sArgv, sWC)
					set lMods to {{"cmd", "Not Applicable"}, {"alt", "Not Applicable"}, {"ctrl", "Not Applicable"}, {"fn", "Not Applicable"}}
					add_ of wf given u:"", a:sK, t:sShowInEN, s:sSub, AC:"", i:"", ty:"", M:lMods, Tc:"", Lt:"", V:1
					repeat with i from 1 to (count lstNotes)
						if i = iMax then exit repeat
						set text item delimiters to ".|."
						set sFile to text item 2 of (item i of lstNotes)
						set sTitle to text item 3 of (item i of lstNotes)
						set sTime to text item 4 of (item i of lstNotes)
						set sOnlyTime to text item 5 of (item i of lstNotes)
						set text item delimiters to ""
						if isTD is true then
							add_ of wf given u:"", a:sFile, t:sTitle, s:"Last updated: " & sOnlyTime, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						else if isRec is true then
							add_ of wf given u:"", a:sFile, t:sTitle, s:"", AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						else
							add_ of wf given u:"", a:sFile, t:sTitle, s:sTime, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						end if
						set i to (i + 1) as integer
					end repeat
				end if
			end if
			return wf's to_xml("")
		end if
	end if
	
	if sArgv starts with "@" and sArgv does not start with "@*" then
		if sArgv does not contain ":" then --list notebooks
			tell application id "com.evernote.Evernote" to set matches to name of every notebook
			if matches = {} then
				add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			else
				repeat with sCur in matches
					if sCur contains sArgvNB then
						add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:"@" & sCur & " :", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
					end if
				end repeat
			end if
			if wf's get_results() = {} then
				add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			end if
			return wf's to_xml("")
		else
			tell application id "com.evernote.Evernote"
				set matches to find notes "notebook:" & sQuotedNB & " " & sSearchT & sArgvQ & sWC
			end tell
			if matches = {} then
				add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:0
			else
				--set matches to get the reverse of matches
				set i to 0 as integer
				set lstNotes to {}
				set iCount to (count matches)
				if iCount > iMax then
					set sSub to "Displaying " & iMax & " notes of " & iCount & " found"
				else
					set sSub to "Found " & iCount & " notes"
				end if
				-->> "Show in Evernote"
				set sShowInEN to setShowInENTitle(isHideSubText, iCount)
				if isRM is false then
					set lMods to {{"cmd", "Not Applicable"}, {"alt", "Not Applicable"}, {"ctrl", "Not Applicable"}, {"fn", "Not Applicable"}}
					add_ of wf given u:"", a:".|." & "notebook:" & sQuotedNB & " " & sSearchT & sArgvQ & sWC, t:sShowInEN, s:sSub, AC:"", i:"", ty:"", M:lMods, Tc:"", Lt:"", V:1
					repeat with j from 1 to (count matches)
						if i = iMax then exit repeat
						tell application id "com.evernote.Evernote"
							set sTitle to title of (item j of matches) as text
							set sLocID to note link of (item j of matches) as string
							if isURL then set sURL to source URL of (item j of matches) as string
						end tell
						if isURL then set sURL to EN_URL(sURL)
						add_ of wf given u:"", a:sLocID, t:sTitle, s:sURL, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						set i to (i + 1) as integer
					end repeat
				else
					repeat with j from 1 to (count matches)
						tell application id "com.evernote.Evernote"
							set sTitle to title of (item j of matches) as text
							if isRec is false then
								set sDateSort to reminder time of (item j of matches)
							else
								set sDateSort to modification date of (item j of matches)
							end if
							set sTime to sDateSort as text
							set sLocID to note link of (item j of matches) as string
						end tell
						set end of lstNotes to get EN_date(sDateSort, sTime, sLocID, sTitle)
					end repeat
					
					-- sort
					set text item delimiters to {ASCII character 10}
					set lstNotes to lstNotes as string
					set lstNotes to paragraphs of (do shell script "echo " & quoted form of (lstNotes) & " | sort -n")
					set text item delimiters to ""
					--if isRec is true and isTD is false then set lstNotes to get the reverse of lstNotes
					
					-- menu items
					set iCount to (count lstNotes)
					set sSub to EN_sub(isTD, isRec, iCount, iMax)
					set sK to EN_ShowIn(sSearchT, sArgv, sWC)
					set lMods to {{"cmd", "Not Applicable"}, {"alt", "Not Applicable"}, {"ctrl", "Not Applicable"}, {"fn", "Not Applicable"}}
					add_ of wf given u:"", a:sK, t:sShowInEN, s:sSub, AC:"", i:"", ty:"", M:lMods, Tc:"", Lt:"", V:1
					repeat with i from 1 to (count lstNotes)
						if i = iMax then exit repeat
						set text item delimiters to ".|."
						set sFile to text item 2 of (item i of lstNotes)
						set sTitle to text item 3 of (item i of lstNotes)
						set sTime to text item 4 of (item i of lstNotes)
						set sOnlyTime to text item 5 of (item i of lstNotes)
						set text item delimiters to ""
						if isTD is true then
							add_ of wf given u:"", a:sFile, t:sTitle, s:"Last updated: " & sOnlyTime, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						else if isRec is true then
							add_ of wf given u:"", a:sFile, t:sTitle, s:"", AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						else
							add_ of wf given u:"", a:sFile, t:sTitle, s:sTime, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						end if
						set i to (i + 1) as integer
					end repeat
				end if
			end if
		end if
	else if sArgv starts with "#" and sArgv does not start with "#*" then
		if sArgv does not contain ":" then --list tags
			tell application id "com.evernote.Evernote" to set matches to name of every tag
			if matches = {} then
				add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			else
				set iCTags to 0 as integer
				repeat with sCur in matches
					if sCur contains sLastTag then
						set sAutoC to trim_line(sArgvOri, "#" & sLastTag, 1)
						set sAutoC to sAutoC & "#" & sCur & " :"
						add_ of wf given u:sCur, a:"", t:sCur, s:"", AC:sAutoC, i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
						set iCTags to iCTags + 1
					end if
					if iCTags = 20 then exit repeat
				end repeat
			end if
			if wf's get_results() = {} then
				add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"tag.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			end if
			return wf's to_xml("")
		else
			tell application id "com.evernote.Evernote"
				--if sArgvQ is "" then
				--	set matches to find notes sQuotedTags
				--else
				set matches to find notes sQuotedTags & " " & sSearchT & sArgvQ & sWC
				--end if
			end tell
			if matches = {} then
				add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"note.png", ty:"", M:{}, Tc:"", Lt:"", V:0
			else
				--set matches to get the reverse of matches
				set i to 0 as integer
				set iCount to (count matches)
				set lstNotes to {}
				if iCount > iMax then
					set sSub to "Displaying " & iMax & " notes of " & iCount & " found"
				else
					set sSub to "Found " & iCount & " notes"
				end if
				-->> "Show in Evernote"
				set sShowInEN to setShowInENTitle(isHideSubText, iCount)
				if isRM is false then
					set lMods to {{"cmd", "Not Applicable"}, {"alt", "Not Applicable"}, {"ctrl", "Not Applicable"}, {"fn", "Not Applicable"}}
					add_ of wf given u:"", a:".|." & sQuotedTags & " " & sSearchT & sArgvQ & sWC, t:sShowInEN, s:sSub, AC:"", i:"", ty:"", M:lMods, Tc:"", Lt:"", V:1
					repeat with j from 1 to (count matches)
						if i = iMax then exit repeat
						tell application id "com.evernote.Evernote"
							set sTitle to title of (item j of matches) as text
							set sLocID to note link of (item j of matches) as string
							if isURL then set sURL to source URL of (item j of matches) as string
						end tell
						if isURL then set sURL to EN_URL(sURL)
						add_ of wf given u:"", a:sLocID, t:sTitle, s:sURL, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						set i to (i + 1) as integer
					end repeat
				else
					repeat with j from 1 to (count matches)
						tell application id "com.evernote.Evernote"
							set sTitle to title of (item j of matches) as text
							if isRec is false then
								set sDateSort to reminder time of (item j of matches)
							else
								set sDateSort to modification date of (item j of matches)
							end if
							set sTime to sDateSort as text
							set sLocID to note link of (item j of matches) as string
						end tell
						set end of lstNotes to get EN_date(sDateSort, sTime, sLocID, sTitle)
					end repeat
					
					-- sort
					set text item delimiters to {ASCII character 10}
					set lstNotes to lstNotes as string
					set lstNotes to paragraphs of (do shell script "echo " & quoted form of (lstNotes) & " | sort -n")
					set text item delimiters to ""
					--if isRec is true and isTD is false then set lstNotes to get the reverse of lstNotes
					
					-- menu items
					set iCount to (count lstNotes)
					set sSub to EN_sub(isTD, isRec, iCount, iMax)
					set sK to EN_ShowIn(sSearchT, sArgv, sWC)
					set lMods to {{"cmd", "Not Applicable"}, {"alt", "Not Applicable"}, {"ctrl", "Not Applicable"}, {"fn", "Not Applicable"}}
					add_ of wf given u:"", a:sK, t:sShowInEN, s:sSub, AC:"", i:"", ty:"", M:lMods, Tc:"", Lt:"", V:1
					repeat with i from 1 to (count lstNotes)
						if i = iMax then exit repeat
						set text item delimiters to ".|."
						set sFile to text item 2 of (item i of lstNotes)
						set sTitle to text item 3 of (item i of lstNotes)
						set sTime to text item 4 of (item i of lstNotes)
						set sOnlyTime to text item 5 of (item i of lstNotes)
						set text item delimiters to ""
						if isTD is true then
							add_ of wf given u:"", a:sFile, t:sTitle, s:"Last updated: " & sOnlyTime, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						else if isRec is true then
							add_ of wf given u:"", a:sFile, t:sTitle, s:"", AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						else
							add_ of wf given u:"", a:sFile, t:sTitle, s:sTime, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
						end if
						set i to (i + 1) as integer
					end repeat
				end if
			end if
		end if
	else
		tell application id "com.evernote.Evernote"
			set matches to find notes sSearchT & sArgv & sWC
		end tell
		if matches = {} then
			add_ of wf given u:"", a:"", t:"No results", s:"", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:0
		else
			--set matches to get the reverse of matches
			set i to 0 as integer
			set lstNotes to {}
			set iCount to (count matches)
			if iCount > iMax then
				set sSub to "Displaying " & iMax & " notes of " & iCount & " found"
			else
				set sSub to "Found " & iCount & " notes"
			end if
			-->> "Show in Evernote"
			set sShowInEN to setShowInENTitle(isHideSubText, iCount)
			if isRM is false then
				set lMods to {{"cmd", "Not Applicable"}, {"alt", "Not Applicable"}, {"ctrl", "Not Applicable"}, {"fn", "Not Applicable"}}
				add_ of wf given u:"", a:".|." & sSearchT & sArgv & sWC, t:sShowInEN, s:sSub, AC:"", i:"", ty:"", M:lMods, Tc:"", Lt:"", V:1
				repeat with j from 1 to (count matches)
					if i = iMax then exit repeat
					tell application id "com.evernote.Evernote"
						set sTitle to title of (item j of matches) as text
						set sLocID to note link of (item j of matches) as string
						if isURL then set sURL to source URL of (item j of matches) as string
					end tell
					if isURL then set sURL to EN_URL(sURL)
					add_ of wf given u:"", a:sLocID, t:sTitle, s:sURL, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
					set i to (i + 1) as integer
				end repeat
			else
				repeat with j from 1 to (count matches)
					tell application id "com.evernote.Evernote"
						set sTitle to title of (item j of matches) as text
						if isRec is false then
							set sDateSort to reminder time of (item j of matches)
						else
							set sDateSort to modification date of (item j of matches)
						end if
						set sTime to sDateSort as text
						set sLocID to note link of (item j of matches) as string
					end tell
					set end of lstNotes to get EN_date(sDateSort, sTime, sLocID, sTitle)
				end repeat
				
				-- sort
				set text item delimiters to {ASCII character 10}
				set lstNotes to lstNotes as string
				set lstNotes to paragraphs of (do shell script "echo " & quoted form of (lstNotes) & " | sort -n")
				set text item delimiters to ""
				--if isRec is true and isTD is false then set lstNotes to get the reverse of lstNotes
				
				-- menu items
				set iCount to (count lstNotes)
				set sSub to EN_sub(isTD, isRec, iCount, iMax)
				set sK to EN_ShowIn(sSearchT, sArgv, sWC)
				set lMods to {{"cmd", "Not Applicable"}, {"alt", "Not Applicable"}, {"ctrl", "Not Applicable"}, {"fn", "Not Applicable"}}
				add_ of wf given u:"", a:sK, t:sShowInEN, s:sSub, AC:"", i:"", ty:"", M:lMods, Tc:"", Lt:"", V:1
				repeat with i from 1 to (count lstNotes)
					if i = iMax then exit repeat
					set text item delimiters to ".|."
					set sFile to text item 2 of (item i of lstNotes)
					set sTitle to text item 3 of (item i of lstNotes)
					set sTime to text item 4 of (item i of lstNotes)
					set sOnlyTime to text item 5 of (item i of lstNotes)
					set text item delimiters to ""
					if isTD is true then
						add_ of wf given u:"", a:sFile, t:sTitle, s:"Last updated: " & sOnlyTime, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
					else if isRec is true then
						add_ of wf given u:"", a:sFile, t:sTitle, s:"", AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
					else
						add_ of wf given u:"", a:sFile, t:sTitle, s:sTime, AC:"", i:"icon2.png", ty:"file", M:{}, Tc:"", Lt:"", V:1
					end if
					set i to (i + 1) as integer
				end repeat
			end if
		end if
	end if
	return wf's to_xml("")
end run

on setShowInENTitle(_isSubtext, _ncount)
	
	try
		if _isSubtext then
			if _ncount is 1 then
				return "Show in Evernote (1 note)"
			else
				--return "Show all " & _ncount & " Notes in Evernote"
				return "Show in Evernote (" & _ncount & " notes)"
			end if
		else
			return "Show in Evernote"
		end if
	on error
		return "Show in Evernote"
	end try
	
end setShowInENTitle

on EN_URL(_URL)
	try
		if _URL contains "message:" then
			return "Message from Mail"
		else if _URL contains "//" or _URL contains "www." then
			set text item delimiters to {"http://", "https://", "www.", "/"}
			repeat with j from 1 to (count text items of _URL)
				set _Result to text item j of _URL
				if _Result is not "" then exit repeat
			end repeat
			set text item delimiters to ""
			return _Result
		else
			set text item delimiters to {"/"}
			set _Result to text item 1 of _URL
			set text item delimiters to ""
			return _Result
		end if
	on error
		return _URL
	end try
end EN_URL

on EN_ShowIn(_SearchIn, _Query, _Auto)
	set _Result to ""
	if _Query is "" then
		set text item delimiters to ""
		if _SearchIn ends with " " then set _SearchIn to text 1 thru ((count _SearchIn) - 1) of _SearchIn
		set _Result to ".|." & _SearchIn
	else
		set _Result to ".|." & _SearchIn & _Query & _Auto
	end if
	return _Result
end EN_ShowIn

on EN_sub(_isTD, _isRec, _iCount, _iMax)
	if _isTD is true then
		if _iCount > _iMax then
			set _sSub to "Displaying " & _iMax & " to-do notes of " & _iCount
		else
			set _sSub to "Found " & _iCount & " to-do note(s)"
		end if
	else if _isRec is true then
		if _iCount > _iMax then
			set _sSub to "Displaying " & _iMax & " notes of " & _iCount & " found since last week"
		else
			set _sSub to "Found " & _iCount & " notes since last week"
		end if
	else
		if _iCount > _iMax then
			set _sSub to "Displaying " & _iMax & " reminders of " & _iCount
		else
			set _sSub to "Found " & _iCount & " reminder(s)"
		end if
	end if
	return _sSub
end EN_sub

on EN_date(_Date, _Time, _File, _Title)
	set _OnlyTime to _Time
	if (current date) is greater than (_Date) then
		set _Time to "Overdue: " & _Time
	else
		set _Time to "Due: " & _Time
	end if
	set sy to (year of _Date as string)
	set sm to ((month of _Date as integer) as string)
	if (count sm) < 2 then set sm to "0" & sm
	set sd to (day of _Date as string)
	if (count sd) < 2 then set sd to "0" & sd
	set sDateHour to time string of _Date
	set text item delimiters to ":"
	set sHo to text item 1 of sDateHour
	set sMin to text item 2 of sDateHour
	set sSec to text item 3 of sDateHour
	set text item delimiters to ""
	set _Date to sy & sm & sd & sHo & sMin & sSec
	set _Result to _Date & ".|." & _File & ".|." & _Title & ".|." & _Time & ".|." & _OnlyTime
	return _Result
end EN_date

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
