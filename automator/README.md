# Automator workflows
This directory contains a few applescript automator workflow for OSX. They can be
added to Finder as buttons that open their particular app in the currently-navigated
directory.

## Installation (per script)
- Create a new "Application" in Automator
- Drag a "Run Applescript" action in
- Copy-paste the code in
- Save it as an "Application"
- Drag the application icon into the top bar of a Finder window while holding the "Cmd" key
- Profit!

### Bonus: change the icon
- Find the app the script opens and open "Get Info"
- Select the icon in the top-left and hit "cmd+c"
- Find the workflow app and open "Get Info"
- Select the icon in the top-left and hit "cmd+v"
