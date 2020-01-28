Adapted from [Josh Brobst](https://stackoverflow.com/a/49662680) on Stack Overflow

# Usage

1. `#include` this script. This creates two object declarations, WindowChangeDetector and Debug_Gui.
2. Create a new instance of a WindowChangeDetector. This takes two parameters:
    1. A declared AHK function that will be the callback for when a window changes
    2. An optional boolean `debug` that controls whether a window will be created for logging debug messages.
3. ~[optional] if `debug == True`, log debugging messages to the debug window by calling the instance method `debug(msg)`~ Not working, see [limitations](#Known-limitations)

Example:

```autohotkey
#include %A_ScriptDir%\ahk-detect_window_change\onWindowChange.ahk
changeDetector := new WindowChangeDetector("msgboxActiveWindow", True)
msgboxActiveWindow(){
    global changeDetector
    WinGetActiveTitle, ThisWindow
    changeDetector.debug("Active: '" ThisWindow "'")
    msgbox % ThisWindow
}
```

Adds two global objects to script:

* WindowChangeDetector object declaration
* Debug_Gui object declaration

[Causes the including script to become](https://www.autohotkey.com/docs/commands/OnMessage.htm#Remarks):

* persistent
* single-instance

# Known limitations

Code run by the callback does not have access to the instance variables, so using the debugging window fails. Use a msgbox to confirm the callback works.
