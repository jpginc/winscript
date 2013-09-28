/* This is the template to use when creating a new addon for Winscript
 */
class NewName
{	
	/* This will be called when your shortcut is run. Put any code that you want to run
	 * automatically here
	 */
	__New(controller)
	{	ignoreMouseClicks := false
		ignoreEsc := true
		MsgBox, % controller.getInput("get input from the user")
		msgbox, % controller.getInput("get a choice from the array", ["hello", "ohello", "how", "are", "your"], ignoreMouseClicks)
		return this
	}
	
	toString()
	{	return "a string"
	}
}

/* Put your hotkeys/string below here
 * If you use more #if statements include the WinscriptMode == "newName" in them
 * eg change #IfWinActive, notepad
 * to #if (WinscriptMode == "newName" && winActive("notepad")
 */
#If InStr(WinscriptMode, "newName,")