on run argv
	set sURL to ""
	try
		tell application id "com.google.Chrome"
			set sURL to (URL of active tab of window 1 as text)
		end tell
	on error
		set sURL to ""
	end try
	return sURL
end run
