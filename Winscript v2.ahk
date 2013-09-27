/* This program was written by Joshua Graham joshua.graham@jpgautomation.com
 * www.jpgautomation.com
 * Anyone may use any part of this code for any non-malicious purpose
 * with or without referencing me. There is No Warranty 
 */
#SingleInstance force
if not A_IsAdmin
{	Run *RunAs "%A_ScriptFullPath%" 
	ExitApp
}
display := new OnScreen()
return
;Capslock + Esc always exits the program
~CapsLock & Esc::
~Esc & CapsLock::
{	SetCapsLockState, off
	ExitApp
}

;the default keys to enter 'script' mode are shift and capslock together
~shift & CapsLock::
~CapsLock & Shift::
{	KeyWait shift
	KeyWait capslock
	SetCapsLockState, off
	display.show(new NewName)
	return
}
;if you click the mouse then your not using keyboard shortcuts so enter insert mode
~LButton::
~RButton::
~MButton::
{	display.mouseClick()
	return
}


/* A class to handle displaying choices on the screen
 */
class OnScreen
{	objectHistory := Object()
	
	__New()
	{	Gui splash: new
		Gui splash: font, s18 bold, TimesNewRoman 
		Gui splash: Color, White
		height := A_Screenheight - 150
		width := A_ScreenWidth - 200
		Gui splash: add, text, Center h%height% w%width%, HELLO WORLD
		return this
	}
	mouseClick()
	{	if(this.objectHistory[this.objectHistory.maxIndex()].ignoreMouseClick())
		{	return
		}
		return this.hide()
	}
	hide()
	{	this.objectHistory := Object()
		Gui splash: hide
	}
	
	show(newObject)
	{	this.objectHistory.Insert(newObject)
		displayElements := newObject.getDisplayElements()
		description := displayElements[0]
		GuiControl, splash:text, static1, % description
		Gui splash: +lastfound +disabled -Caption +AlwaysOnTop -SysMenu 
		WinSet, TransColor, White 
		Gui splash: show, NoActivate y120
		return
	}
}

/* This is the template to use when creating a new addon for Winscript
 * Your addon can 
 *	1) Only have hotkeys/hotStrings. In this case 
 */
class NewName
{	

	/* This will be called when your shortcut is run. Put any code that you want to run
	 * automatically here
	 */
	__New()
	{	msgbox, , My Code, I want something to happen
		return this
	}
	
	/* By default, clicking the mouse will turn off any hotkeys you have specified and clear the display
	 */
	ignoreMouseClick()
	{	return false
	}
	
	/* If you have provided a list of choices to display on screen the selected choice will be returned 
	 * to this function
	 */
	onScreenCallback(selection, scriptManager)
	{	if(selection == "A callback")
		{	MsgBox, , My Code, You selected a callback!
		}
		if(selection == "Another script launcher")
		{	scriptManager.handle(selection)
		}
		return
	}
	
	/* When the script shortcut is chosen you can display a description (eg instructions) on the screen
	 * Additionally you can display a list of choices. The user will then be able to select one of these choices
	 * The selected choice will be returned to you via the onScreenCallback function
	 */
	getDisplayElements()
	{	;An array containing information on what to display when the script shorcut is run
		displayElements := Object()
		;A description to be displayed in the center of the screen
		description := "Press windows key + c to exit the program!"
		;An array of choices
		choices := object("A callback", "Another script launcher")
		displayElements.Insert(0, description, choices)
		return displayElements
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
#c::ExitApp