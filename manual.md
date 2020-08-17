# Install these manually

## Mac configs
* Open System Preferences > Trackpad and uncheck "Swipe between pages", then change
  "Swipe between full-screen apps" to "three fingers". This disables the annoying
  swipe-for-back behavior in Chrome and restores the easier 3-finger swipe gesture
  for switching workspaces.
* Change the login shell
  * In System Preferences>Users & Groups, unlock then right click on your user and select "Advanced Options"
  * Change "Login shell" to `/usr/local/bin/bash`
* In System Preferences>Keyboard>Shortcuts, disable all of the shortcuts involving ctrl. A bunch of them are used by VSCode, but Apple decided it'd be better to use them for switching spaces.
* In System Preferences>Users & Groups>your user>Login Items, add the following:
  * BetterTouchTool
  * Alfred 4
  * Docker
  * LastPass
  * HyperSwitch
  * Itsycal
* In System Preferences>Keyboard>Text, uncheck "Correct spelling automatically and "Add period with double-space
* in System Preferences>Dock, un-check "Show recent applications in Dock"
* Right click on the dock and select "Turn Hiding On"

## Dash
Install the following docsets: Python3, Bash, Man pages, Docker, HTML, CSS, Javascript, Terraform,
SVG

## iTerm
* Go to Preferences > General > Preferences and set "Load preferences from a custom folder or URL"
  to the location of the `iTerm` directory in this repo.
* Some stuff for iTerm may not be saved in config, particularly keybindings. Check for the following and add if necessary:
  * In Keys>Key Bindings or Profiles>Default>Keys:
    * Set "Left option key acts as" to +Esc
    * Change ⌥→ to "Send Escape Sequence" and "f"
    * Change ⌥← to "Send Escape Sequence" and "b"
  * In the menu, run "Install shell integration"

## Chrome
* Install the following extensions:
  * UBlock Origin: does a better job at blocking paywalls than Adblock Plus
  * LastPass: obviously
  * Stylus: custom themes for webpages. Install all the ones in the "stylish" dir.
  * Event Merge for Google Calendar: visually merges identical events on multiple calendars
* In the Chrome menu bar, select Chrome>Warn before quitting
* Open Chrome developer tools, go to Settings, and under appearance, select "Dark theme"
* Follow the instructions in `Stylus/README.md` to set up custom styles

## VSCode
* Using the command palette, open "Preferences: Open Settings (JSON)" and replace its contents with the contents of `VSCode/settings.json`
* As above, open "Preferences: Open Keyboard Shortcuts (JSON)" and replace its contents with the contents of `VSCode/keybindings.json`
* Install the extensions in `VSCode/extensions.txt`

## Itsycal
* In Itsycal's preferences, in the area for "Datetime pattern", enter `E MMM d  h:mm a`
* Check "Hide icon"
* ⌘Click and drag the Itsycal item in the menu bar next to the normal time and date display
* In System Preferences>Date & Time>Clock, un-check "Show date and time in menu bar"

## BetterTouchTool
* Add the following keyboard shortcuts:
  * ⇧^⌥⌘→: Action: Move Left a Space
  * ⇧^⌥⌘←: Action: Move Right a Space
  
  These are "pressed" by USB Overdrive when the special keys on my Microsoft Natural Ergonomic
  4000 are pressed

## USB Overdrive
* Plug in the Microsoft Natural Ergonomic 4000 keyboard
* In System Preferences, open USB Overdrive
* Under "Any Other, Any Application" open the dropdown and select "Import Settings"
* Select `misc-scripts/Any Other, Any Application.overdriveSettings`

This wires up a bunch of special buttons on the keyboard:
* Back/Forward: move left/right a space
* Keypad =/(/): actually type the symbol in question
* Play/Pause/Next/Previous media buttons: perform the action in question
* Volume up/down/mute: perform the action in question
* Search: ⌘F
* Home: open ~
* Scroll wheel up/down: page up/down
