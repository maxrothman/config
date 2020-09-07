on new_workflow(bundleid)
	script Workflow
		property class : "workflow"
		property _data : missing value
		property _results : missing value
		on run {bundleid}
			--set my _data to (POSIX path of (path to home folder)) & "Library/Application Support/Alfred 3/Workflow Data/" & (bundleid) & "/"
			set my _data to (system attribute "alfred_workflow_data")
			if not my q_path_exists(my _data) then do shell script "mkdir " & quoted form of (my _data)
			set my _results to {}
			return me
		end run
		on get_results()
			return my _results
		end get_results
		on add_ given U:_uid, A:_arg, T:_title, S:_sub, AC:_auto, I:_icon, TY:_type, M:_Mods, TC:_textcopy, LT:_largetype, V:_valid
			set end of (my _results) to {theUid:_uid, theArg:_arg, theTitle:_title, theSubtitle:_sub, theIcon:_icon, isValid:_valid, theAutocomplete:_auto, theType:_type, theMods:_Mods, theTextCopy:_textcopy, theLargeType:_largetype}
		end add_
		on to_xml(A)
			set A to my _results
			set tab2 to tab & tab
			set xml to "<?xml version=\"1.0\"?>" & return & "<items>" & return
			repeat with itemRef in A
				set r to contents of itemRef
				set xml to xml & tab & "<item"
				if (theUid of r) is not "" then set xml to xml & " uid=\"" & my q_encode(theUid of r) & "\""
				if isValid of r is 0 then set xml to xml & " valid=\"no\" autocomplete=\"" & my q_encode(theAutocomplete of r) & "\""
				set xml to xml & " type=\"" & (theType of r) & "\">" & return
				if (theArg of r) is "" then
					set xml to xml & tab2 & "<arg></arg>" & return
				else
					set xml to xml & tab2 & "<arg><![CDATA[" & (theArg of r) & "]]></arg>" & return
				end if
				set xml to xml & tab2 & "<title><![CDATA[" & (theTitle of r) & "]]></title>" & return
				repeat with j in theMods of r
					set xml to xml & tab2 & "<subtitle mod=\"" & item 1 of j & "\"><![CDATA[" & (item 2 of j) & "]]></subtitle>" & return
				end repeat
				if (theSubtitle of r) is "" then
					set xml to xml & tab2 & "<subtitle></subtitle>" & return
				else
					set xml to xml & tab2 & "<subtitle><![CDATA[" & (theSubtitle of r) & "]]></subtitle>" & return
				end if
				if (theTextCopy of r) is not "" then set xml to xml & tab2 & "<text type=\"copy\"><![CDATA[" & (theTextCopy of r) & "]]></text>" & return
				if (theLargeType of r) is not "" then set xml to xml & tab2 & "<text type=\"largetype\"><![CDATA[" & (theLargeType of r) & "]]></text>" & return
				set ic to (theIcon of r)
				if ic is not "" then
					if ic contains ":" then
						set xml to xml & tab2 & "<icon type=\"" & (items 1 thru 8 of ic) & "\"" & "><![CDATA[" & (items 10 thru -1 of ic) & "]]></icon>" & return
					else
						set xml to xml & tab2 & "<icon><![CDATA[" & ic & "]]></icon>" & return
					end if
				else
					set xml to xml & tab2 & "<icon>icon.png</icon>" & return
				end if
				set xml to xml & tab & "</item>" & return
			end repeat
			set xml to xml & "</items>"
			return xml
		end to_xml
		on set_value(A, b)
			if my q_path_exists(my _data & "settings.plist") is false then
				do shell script "defaults write " & quoted form of (my _data & "settings.plist") & space & "qW" & space & "1"
			end if
			tell application "System Events"
				set c to property list file (my _data & "settings.plist")
				make new property list item at end of property list items of contents of c with properties {kind:(class of b), name:A, value:b}
			end tell
		end set_value
		on get_value(A)
			try
				tell application "System Events"
					set b to property list file (my _data & "settings.plist")
					return value of property list item A of contents of b
				end tell
			on error
				return ""
			end try
		end get_value
		on write_file(A, b)
			set b to my _data & b
			try
				set f to open for access b with write permission
				set eof f to 0
				write A to f as «class utf8»
				close access f
			end try
		end write_file
		on read_file(A)
			set A to my _data & A
			try
				set f to open for access A
				set sz to get eof f
				close access f
				return read A as «class utf8»
			on error
				return ""
			end try
		end read_file
		on q_path_exists(thePath)
			try
				POSIX file thePath as alias
				return true
			on error
				return false
			end try
		end q_path_exists
		on q_file_exists(theFile)
			if my q_path_exists(theFile) then
				tell application "System Events"
					return (class of (disk item theFile) is file)
				end tell
			end if
			return false
		end q_file_exists
		on q_encode(str)
			set x to ""
			repeat with sRef in str
				set c to contents of sRef
				if c is in {"&", "'", "\"", "<", ">", tab} then
					if c is "&" then
						set x to x & "&amp;"
					else if c is "'" then
						set x to x & "&apos;"
					else if c is "\"" then
						set x to x & "&quot;"
					else if c is "<" then
						set x to x & "&lt;"
					else if c is ">" then
						set x to x & "&gt;"
					else if c is tab then
						set x to x & "&#009;"
					end if
				else
					set x to x & c
				end if
			end repeat
			return x
		end q_encode
	end script
	return run script Workflow with parameters {bundleid}
end new_workflow
