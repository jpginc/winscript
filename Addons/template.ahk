;to help test
test := new newName()
;a csv of active script hotkeys
WinscriptMode := "newName,"
return

/* This is the template to use when creating a new addon for Winscript
 * Your addon can 
 *	1) Only have hotkeys/hotStrings. In this case 
 */
class NewName
{	
	;An array containing information on what to display when the script shorcut is run
	displayElements := Object()
	
	/* This will be called when your shortcut is run. Put any code that you want to run
	 * automatically here
	 */
	__New()
	{	
		return this
	}
	
	/* By default, clicking the mouse will cancel this script. Change false to true if
	 * You want to allow clicking in your script
	 */
	ignoreMouseClick()
	{	return false
	}
	
	/* If you have provided a list of choices the selection will be returned to this function
	 * 
	 */
	onScreenCallback(selection, scriptManager)
	{	return
	}
	
	/* When the script shortcut is chosen you can display a description (eg instructions) on the screen
	 * Additionally you can display a list of choices. The user will then be able to select one of these choices
	 * The selected choice will be returned to you via the onScreenCallback function
	 */
	getDisplayElements()
	{	;A description to be displayed in the center of the screen
		description := ""
		;An array of choices
		choices := object()
		return displayElements(0, description, choices)
	}

}

/* Put your hotkeys/string below here
 * If you use more #if statements include the WinscriptMode == "newName" in them
 * eg change #IfWinActive, notepad
 * to #if (WinscriptMode == "newName" && winActive("notepad")
 */
#If InStr(WinscriptMode, "newName,")
#c::ExitApp