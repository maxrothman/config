# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

wfdir=$PWD		#Get workflow directory

#Show documentation
#open ./docs/help.html 	#Not going to do this anymore until next significant release

##Build Eggtimer working folders in proper location
mkdir "$EGGPREFS"
mkdir "$EGGWD"
mkdir "$EGGWD"/running_timers
mkdir "$EGGWD"/running_autotimers
mkdir "$EGGWD"/running_alarms
mkdir "$EGGWD"/recent_timers
mkdir "$EGGWD"/last_completed_timer
mkdir "$EGGWD"/last_completed_autotimer
mkdir "$EGGWD"/last_completed_alarm
echo 9 > "$EGGPREFS"/snoozetimer.txt
echo "205" > "$EGGPREFS"/version
echo $wfdir > "$EGGPREFS"/eggwd.txt
cp -R scripts/login_check.workflow "$EGGPREFS"
rm -f "$EGGPREFS"/firstrun.log
rm -f "$EGGPREFS"/2.0beta4b_firstrun.log

#Register with Growl (if Growl exists and is running)
osascript <<EOD
tell application "System Events"
	set isRunning to (count of (every process whose bundle identifier is "com.Growl.GrowlHelperApp")) > 0
end tell

if isRunning then
	tell application id "com.Growl.GrowlHelperApp"
		
		-- Register with growl.
		register as application ¬
			"EggTimer for Alfred" all notifications {"Timer Completed", "Alarm Completed"} ¬
			default notifications {"Timer Completed", "Alarm Completed"} ¬
			icon of application "$wfdir/resources/DummyAppForGrowl.app"
	end tell
end if
EOD
