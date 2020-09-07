on run argv
	set wf to load script POSIX path of ((path to me as text) & "::") & "workflow.scpt"
	set wf to wf's new_workflow("com.sztoltz.evernote")
	
	set sArgv to argv as text
	set text item delimiters to {"||"}
	set sParam to text item 2 of sArgv
	set sArgv to text item 1 of sArgv
	set text item delimiters to ""
	if sParam is "f" then
		set sSW to wf's get_value("search")
		if sSW is "" then set sSW to "Manual"
		add_ of wf given u:"", a:"search" & tab & "Manual", t:"Search Wildcard: Manual", s:"Partial queries requires an asterisk (faster)", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:1
		add_ of wf given u:"", a:"search" & tab & "Automatic", t:"Search Wildcard: Automatic", s:"Search partial queries (slower)", AC:"", i:"", ty:"", M:{}, Tc:"", Lt:"", V:1
		add_ of wf given u:"", a:"", t:"Current is " & sSW, s:"", AC:"", i:"arrow.png", ty:"", M:{}, Tc:"", Lt:"", V:0
		return wf's to_xml("")
	else
		set text item delimiters to {tab}
		set sData to text item 2 of sArgv
		set sArgv to text item 1 of sArgv
		set text item delimiters to ""
		wf's set_value("search", sData)
		wf's set_value("pref_step", "")
		tell application id "com.runningwithcrayons.Alfred-3" to «event alfrSear» "ens "
		return "Search Wildcard: " & sData
	end if
end run
