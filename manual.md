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
  * Alfred 5
  * Docker
  * HyperSwitch
* In System Preferences>Keyboard>Text, uncheck "Correct spelling automatically and "Add period with double-space
* in System Preferences>Dock, un-check "Show recent applications in Dock"
* Right click on the dock and select "Turn Hiding On"
* Run `defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false` to
  enable key repeat (otherwise, long-press opens the the key's unicode options which I don't have
  much use for)
* Go to System Preferences > Accessibility > Zoom, check "Use scroll gesture with modifier keys to zoom"
* In the notes app, go to edit > spelling and grammar and uncheck correct spelling automatically (why isn't this a real preference???)
* Plug in the Microsoft Natural Ergonomic 4000 keyboard, then go to System
  Preferences > Keyboard. On the Keyboard tab, click "Modifier Keys...", and in
  the resulting modal, select the Microsoft keyboard from the dropdown and
  remap ⌥ to ⌘ and ⌘ to ⌥
* In Desktop & Dock:
  * Disable "Click wallpaper to reveal desktop"
  * Disable "Show suggested and recent apps in Dock"
  * Disable Stage Manager
  * Disable "Tiled windows have margins"
  * Disable "Automatically rearrange Spaces based on most recent use"

## Dash
Install the following docsets: Python3, Bash, Man pages, Docker, HTML, CSS, Javascript, Terraform,
Clojure, ClojureDocs

## Alfred
* Install the Dash workflow. It's ignored by my settings because it's self-modifying so it'd be
  different on every machine.
* In Features > Clipboard History, enable all the Clipboard History options

## iTerm
* Go to Preferences > General > Preferences and set "Load preferences from a custom folder or URL"
  to the location of the `iTerm` directory in this repo.
* Some stuff for iTerm may not be saved in config, particularly keybindings. Check for the following and add if necessary:
  * In Keys>Key Bindings or Profiles>Default>Keys:
    * Set "Left option key acts as" to +Esc
    * Change ⌥→ to "Send Escape Sequence" and "f"
    * Change ⌥← to "Send Escape Sequence" and "b"
  * In the menu, check "Load shell integration automatically"

## Chrome
* Install the following extensions:
  * UBlock Origin: does a better job at blocking paywalls than Adblock Plus
  * LastPass: obviously
  * [Smooth Key Scroll](https://chrome.google.com/webstore/detail/smooth-key-scroll/gphmhpfbknciemgfnfhjapilmcaecljh):
    Scroll more easily with keyboard shortcuts. Settings:
    * ↓: 17px
    * ⌥↓: 30px
    * ^↓: 1px
* In the Chrome menu bar, select Chrome>Warn before quitting
* Open Chrome developer tools, go to Settings, and under appearance, select "Dark theme"
* In Preferences > Passwords, turn off "Offer to save passwords" (I use lastpass)
* In the Evernote extension settings:
  * After clip: select "Automatically close clipper"
  * Uncheck "Related results"
  * Disable keyboard shortcuts
* Set default zoom to 110% (I have astygmatism)

## VSCode
* Install the extensions in `VSCode/extensions.txt`
* Run "Sync Settings: Open the repository settings" then put this in it:
  ```yml
  repository:
    type: file
    # path of the local directory to sync with, required
    path: ~/repos/config/VSCode/
  ```
* Run "Sync Settings: Download"

## BetterTouchTool
Synced BetterTouchTool config is stored in ~/.btt_autoload_preset.json and loaded on startup. It
will create/replace a preset named "Global". A few notes/caveats:
* The only documentation for this feature as far as I can tell is [this thread](https://community.folivora.ai/t/syncing-the-config-in-git/34840/4)
* BTT will not replace the "master" preset with the one in ~/.btt_autoload_preset.json, that's why a
  separate preset is used
* If you create a new trigger and want it to get synced, make sure to add it to the "Global" preset
* If you *don't* want a trigger to be synced add it to the master ("Default") preset

## USB Overdrive
* Plug in the Microsoft Natural Ergonomic 4000 keyboard
* In System Preferences, open USB Overdrive
* Under "Any Other, Any Application" open the dropdown and select "Import Settings"
* Select `misc-stuff/Any Other, Any Application.overdriveSettings`

This wires up a bunch of special buttons on the keyboard:
* Back/Forward: move left/right a space
* Keypad =/(/): actually type the symbol in question
* Play/Pause/Next/Previous media buttons: perform the action in question
* Volume up/down/mute: perform the action in question
* Search: ⌘F
* Home: open ~
* Scroll wheel up/down: page up/down

## Hyperswitch
* In "General":
  * Check "Run in background"
  * Set "Delay activation for" to 200ms
  * Check "Include windows from other screens"
* In "App Switcher":
  * Uncheck "Show window previews on the app switcher"
  * Uncheck "When activating an app without windows, try to open the default window"
* In "Appearance":
  * Check "the menu bar"
  * Uncheck "the Dock"
