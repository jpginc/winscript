/* This program was written by Joshua Graham joshua.graham@jpgautomation.com
 * www.jpgautomation.com
 * Anyone may use any part of this code for any non-malicious purpose
 * with or without referencing me. There is No Warranty 
 */
 ;Do not move or remove the following line!
 winscriptExistingShortcuts := "remove,update,Add,|main,recompiler,default,test,"
 
#SingleInstance force
if not A_IsAdmin
{	Run *RunAs "%A_ScriptFullPath%" 
	ExitApp
}
gosub main
return
;JPGIncWinscriptFlag Start main
main:
{	winscriptDisplay := new OnScreen(winscriptExistingShortcuts)
	return 
}

#If
;Capslock + Esc exits the program
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
	winscriptDisplay.show(new default(winscriptDisplay))
	return
}
;if you click the mouse then your not using keyboard shortcuts so enter insert mode
~LButton::
~RButton::
~MButton::
{	winscriptDisplay.mouseClick()
	return
}
~Esc::
{	winscriptDisplay.esc()
	return
}


/* A class to handle displaying text and choices on the screen
 */
class OnScreen
{	ignoreMouseClick := false
	ignoreEsc := false
	selectionOffput := 5
	choiceOffput := 10
	existingShortcuts := ""
	
	__New(existingShortcuts)
	{	Gui splash: new
		Gui splash: Color, White
		height := A_Screenheight - 150
		width := A_ScreenWidth - 200
		Gui splash: font, s18 bold cYellow, TimesNewRoman 
		;for the message
		Gui splash: add, text, x1 y2 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x2 y1 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x3 y2 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x2 y3 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x2 y2 Center BackgroundTrans cGreen h%height% w%width%
		;for input
		Gui splash: add, text, x1 yp+52 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x2 yp-1 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x3 yp+1 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x2 yp+1 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x2 yp-1 Center BackgroundTrans cGreen h%height% w%width%
		;for the selections
		Gui splash: add, text, x49 yp+52 BackgroundTrans h%height% w%width%
		Gui splash: add, text, x50 yp-1 BackgroundTrans h%height% w%width%
		Gui splash: add, text, x51 yp+1 BackgroundTrans h%height% w%width%
		Gui splash: add, text, x50 yp+1 BackgroundTrans h%height% w%width%
		Gui splash: add, text, x50 yp-1 BackgroundTrans cGreen h%height% w%width%
		shortcutArray := StrSplit(existingShortcuts, "|")
		this.existingShortcuts := shortcutArray[1]
		this.hiddenShortcuts := shortcutArray[2]
		return this
	}
	
	getShortcuts() 
	{	return this.existingShortcuts
	}
	
	getAllShortcuts()
	{	return this.existingShortcuts "," this.hiddenShortcuts
	}
	
	validShortcut(newShortcut)
	{	IfInString, newShortcut, `,
		{	return false
		}
		existingShortcuts := this.existingShortcuts
		hiddenShortcuts := this.hiddenShortcuts
		IfInString, existingShortcuts, % newShortcut ","
		{	return false
		}
		IfInString,hiddenShortcuts, % newShortcut ","
		{	return false
		}
		return true
	}
	mouseClick()
	{	if(this.ignoreMouseClick)
		{	return
		}
		IfWinExist, WinscriptSplash
		{	send {esc}
		}

		return this.hide()
	}
	
	esc()
	{	if(this.ignoreEsc)
		{	return
		}
		return this.hide()
	}
	
	hide()
	{	global WinscriptMode
		WinscriptMode := ""
		Gui splash: hide
		return
	}
	
	display(message, params*)
	{	if(params.maxIndex())
		{	this.ignoreMouseClick := params[1]
			this.ignoreEsc := params.maxIndex() > 1 ? params[2] : false
		}
		;clear the previous choices
		loop, 5
		{	GuiControl, splash:text, % "static" A_index + this.selectionOffput, 
			GuiControl, splash:text, % "static" A_index + this.choiceOffput, 
		}
		Loop, 5
		{	GuiControl, splash:text, static%A_index%, % message
		}
		Gui splash: +lastfound +disabled -Caption +AlwaysOnTop -SysMenu 
		WinSet, TransColor, white
		Gui splash: show, NoActivate y120, WinscriptSplash
		return
	}
	
	/*
	 * clear the display
	 */
	clear()
	{	this.hide()
		return
	}
	/*
	 * Gets input from the user.
	 * usage: 
	 * getInput(message to display [, array of choices = [], ignore mouse click = false])
	 */
	getInput(message, params*)
	{	;you cannot ignore the escape key when getting input
		this.ignoreEsc := false
		this.ignoreMouseClick := false
		choices := ""
		selection := ""
		oneChar := ""
		if(params.maxIndex())
		{	this.ignoreMouseClick := params.maxIndex() > 1 ? params[2] : false
			choices := this.arrayToString(params[1])
		}
		Loop, 5
		{	GuiControl, splash:text, static%A_index%, % message
		}
		Gui splash: +lastfound +disabled -Caption +AlwaysOnTop -SysMenu 
		WinSet, TransColor, white
		Gui splash: show, NoActivate y120, WinscriptSplash
		
		;get the input
		while true
		{	loop, 5
			{	GuiControl, splash:text, % "static" A_index + this.selectionOffput, % selection
				GuiControl, splash:text, % "static" A_index + this.choiceOffput, % choices
			}
			if((oneChar := this.getNextChar()) == "cancelled")
			{	choices := "cancelled`n"
				break
			} else if(oneChar == "end")
			{	break
			} else if(oneChar == "backspace")
			{	StringTrimRight, selection, selection, 1
			} else
			{	selection .= oneChar
			}
			choices := this.filterChoices(params[1], selection)
		}
		this.hide()
		;get the input
		return choices == "" ? selection : SubStr(choices, 1, InStr(choices, "`n") - 1)
	}
	
	/* Eventually I want to make this intelegent
	 * now it sorts a given array of strings by how similar they are to the given string filter
	 */
	filterChoices(choices, filter)
	{	sortedChoices := object()
		returnString := ""
		filterChars := StrSplit(filter)
		for key, choice in choices
		{	score := 0
			reward := 1
			bonus := 0
			for index, char in filterChars
			{	if((found := InStr(choice, char)))
				{	if(found == 1 && index == 1)
					{	;the first char in the filter matches the first char of the choice
						bonus := 2
					}
					if(found == index)
					{	bonus *= 2
					}
					;the more consecutive matching chars the higher the score
					score += (reward *= 2) + bonus
				} else
				{	reward := 1
					bonus := 1
				}	
			}
			while(sortedChoices.hasKey(score))
			{ ;increment score until there is a free spot
				score++
			}
			sortedChoices.Insert(score, choice)
		}
		while((temp := sortedChoices.remove(sortedChoices.maxIndex())) != "")
		{	
			returnString .= temp "`n"
		}
		return returnString
	}
	/* Gets one character from the user 
	 * returns "cancelled" if the escape key is pressed 
	 * returns "end" if return was pressed
	 * takes a string and returns that string with the next character appeneded to it
	 */
	getNextChar()
	{	input, oneChar, L1,{Esc}{BackSpace}{enter}
		if(ErrorLevel == "EndKey:Backspace")
		{ 	return "backspace"
		} else if(ErrorLevel == "EndKey:Escape")
		{	return "cancelled"
		}
		if(InStr(errorLevel, "EndKey:"))
		{	return "end"
		}
		return oneChar
	}
	arrayToString(theArray)
	{	theString := ""
		for key, aString in theArray
		{	theString .= aString "`n"
		}
		return theString
	}	
}
;JPGIncWinscriptFlag End main
;JPGIncWinscriptFlag Start recompiler
class recompiler
{

    beforeFlag := ";JPGIncWinscriptFlag Start "
    afterFlag := ";JPGIncWinscriptFlag End "
    
    __New(args*)
    {   return this
    }
    
    getRunningCode() 
    {
        if(A_IsCompiled) 
        {
        ;not yet implemented
        } else 
        {
            FileRead, fullScript, % A_ScriptFullPath
        }
        return fullScript
    }
    
    /*
     * Simply appends the given file to the main script without adding a sortcut
     * @param filename
     *  the full path of the file to include OR the name of the file in the %A_scriptdir%\Addons folder
     * @param shortcutName
     *  the name of the shortcut. If blank a shortcut is not added and the file is simply appended to the running code
     */
    doAdd(name, newCode, addShortcut) 
    {   runningCode := this.getSource()
        if(this.joinCode(name, newCode, runningCode, addShortcut)) 
        {   MsgBox, 4, JPGInc Warning, Warning adding this file will overwite existing code`nDo you want to continue?
            IfMsgBox, no 
            {   ;this.fullScript has been changed....
                return
            }
        }
		return this.recompile(runningCode)
    }
    
    /*
     * Edit's existingCode to include newCode in between beforeflag and afterflag optionally updating the defaultShortcutList := "..." to include name ","
     * returns false if the code was added without removing existing code
     * returns true existing code was updated
     */
    joinCode(name, newCode, ByRef existingCode, addShortcut) 
    {	if(theStart := RegExMatch(existingCode, "`am)^" this.escapeRegex(this.beforeFlag name) "$")) 
        {
            ;we need to replace the existing code
            theEnd := RegExMatch(existingCode, "P`am)^" this.escapeRegex(this.afterFlag name) "$", length)
            existingCode := SubStr(existingCode, 1, theStart - 1) SubStr(existingCode, theEnd + length)
        }
        if(! theStart) 
        {   delim := addShortcut ? "|" : ""
			;need to add the shortcut
            existingCode := RegExReplace(existingCode, "`am)""(.*)" this.escapeRegex(delim) "(.*)""", """$1" this.escapeDollars(name) "," delim "$2""", notNeeded, 1)
        }
        
        ;append the new code with flags
        existingCode .= this.beforeFlag name "`n" newCode "`n" this.afterFlag name "`n"
        return theStart != 0
    }
    
    /*
     * removes from the start flag of 'name' to the endflag (inclusive) from 'existingCode'
     * returns 0 if successful
     * returns 1 if unsuccessful
     */
    splitCode(name, ByRef existingCode)
    {   if(theStart := RegExMatch(existingCode, "`am)^" this.escapeRegex(this.beforeFlag name) "$")) 
        {	theEnd := RegExMatch(existingCode, "P`am)^" this.escapeRegex(this.afterFlag name) "$", length)
            existingCode := SubStr(existingCode, 1, theStart - 1) SubStr(existingCode, theEnd + length)
            existingCode := RegExReplace(existingCode, "m)""(.*)" this.escapeRegex(name) ",", """$1", notNeeded, 1)
            return 0
        }
        return 1
    }

    /*
     * Appends the given file to the main script also adding it to the shortcut list
     */
    addShortcut(name, newCode) 
    {
        return this.doAdd(name, newCode, true)
    }
    
    add(name, newCode) 
    {
        return this.doAdd(name, newCode, false)
    }
    
    /*
     * Removes the code snipit from the main file
     */
    remove(name, update := false) {
        existingCode := this.getSource()
        if(this.splitCode(name, existingCode))
        {   MsgBox, , JPGInc Error, Error code segment not found in the currently running code!
            return 
        }
        return this.recompile(existingCode)
    }
    
    /* 
     * Updates an existing code snipit within the file
	 * Not yet implemented
     */
    update(name, newCode) 
    {	existingCode := this.getSource()
        if(this.splitCode(name, existingCode))
        {   MsgBox, 4, JPGInc Warning, Warning existing code was not found (or removed) do you wish to continue?
			IfMsgBox No
			{	return
			}
		}
		this.joinCode(name, newCode, existingCode, true)
		return this.recompile(existingCode)
    }
    
    /*
     * Checks if the given code will compile
     * returns 0 if the code compiles without any problems
     * returns the compilation errors otherwise
     */
    checkCodeSyntax(code) 
    {
        FileDelete, JPGIncTempFile.ahk
        FileDelete, errorlog.txt

        FileAppend, % "exitapp`n" code, JPGIncTempFile.ahk
        RunWait, %A_AhkPath% /ErrorStdOut JPGIncTempFile.ahk > errorlog.txt
        FileDelete, JPGIncTempFile.ahk

        FileRead, errorlog, errorlog.txt
        if(errorlog)
        {   return errorlog
        }
        return false
    }
    
    /*
     * returns the code of the currently running script
     */
    getSource() 
    {
        if(A_IsCompiled) 
        {
            ;not yet implemented
        } else 
        {
            FileRead, fullScript, % A_ScriptFullPath
        }
        return fullScript
    }
    
    recompile(newCode) 
    {	if(A_IsCompiled) 
        {	return
            ;not implemented
        } else 
        {	FileMove, % A_scriptfullpath, % a_scriptfullpath ".backup", 1
            FileAppend, % newCode, % A_scriptfullpath
            Reload
            Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
			WinClose, ahk_class #32770
			FileMove, % A_ScriptFullPath, % A_ScriptFullPath ".failed", 1
			FileMove, % A_scriptfullpath ".backup", % a_scriptfullpath, 1
            MsgBox, 4, JPGInc ERROR, ERROR The script could not be reloaded. Would you like to open it for editing?
            IfMsgBox, Yes 
            {   Run, % "edit """ A_scriptfullpath ".failed""", , UseErrorLevel
				if(errorlevel)
				{	run, % "notepad """ A_scriptfullpath ".failed"""
				}
            }
            return
        }
    }

	doMatch(haystack, needle)
	{	return RegExMatch(haystack, "`am)^" needle "$")
	}
	
	escapeRegex(theString) 
	{	return "\Q" theString "\E"
	}
	
	escapeDollars(theString)
	{	StringReplace, theString, theString, $, $$, all
		return theString
	}
}
;JPGIncWinscriptFlag End recompiler
;JPGIncWinscriptFlag Start default
class default
{	__New(controller)
	{	global WinscriptMode
		shortcutList := controller.getShortcuts()
		className := controller.getInput("Select script to run", StrSplit(shortcutList, ","))
		if(className == "cancelled")
		{	return
		}
		WinscriptMode := className
		if(IsObject(%className%))
		{	new %className%(controller)
		} else if(IsFunc(className))
		{	%className%()
		} else if(IsLabel(className))
		{	gosub, %className%
		}
		return this
	}
}
;JPGIncWinscriptFlag End default

;JPGIncWinscriptFlag Start remove
class remove
{	__new(controller)
	{	while(true)
		{	toRemove := controller.getInput("Select a code segment to remove", StrSplit(controller.getShortcuts(), ","))
			if(toRemove == "cancelled")
			{	return
			}
			if(! controller.validShortcut(newShortcut))
			{	MsgBox, 4, Warning, Are you sure you wish to remove the shortcut %toRemove%?
				IfMsgBox, No
				{	return
				}
				r := new recompiler()
				r.remove(toRemove)
			} else
			{	MsgBox, , Error, Error that shortcut does not exist
			}
		}
		return this
	}
}
;JPGIncWinscriptFlag End remove



;JPGIncWinscriptFlag Start update
class update
{	__new(controller)
	{	while(true)
		{	toUpdate := controller.getInput("Select a code segment to update", StrSplit(controller.getShortcuts(), ","))
			if(toUpdate == "cancelled")
			{	return
			}
			if(! controller.validShortcut(newShortcut))
			{	IfExist, % A_scriptdir "\Addons\" toUpdate ".ahk"
				{	FileRead, newCode, % A_ScriptDir "\Addons\" toUpdate ".ahk"
				} else
				{	controller.display("Select the file to load", ignoreMouseClicks := true)
					FileSelectFile, dir, 12 ,% A_ScriptDir "\Addons"
					if(errorlevel)
					{	return ;the user cancelled
					}
					FileRead, newCode, % dir
				}
				if(! newCode)
				{	MsgBox, , Error, Error file could not be read or was empty
					return
				}
				MsgBox, 4, Warning, Are you sure you wish to update the shortcut %toUpdate%?
				IfMsgBox, No
				{	return
				}
				r := new recompiler()
				r.update(toUpdate, newCode)
			} else
			{	MsgBox, , Error, Error that shortcut does not exist
			}
		}
		return this
	}
}
;JPGIncWinscriptFlag End update
;JPGIncWinscriptFlag Start Add
class add
{	__new(controller)
	{	while(true)
		{	newShortcut := controller.getInput("Type a shortcut name.")
			if(newShortcut == "cancelled")
			{	return
			}
			if(! controller.validShortcut(newShortcut))
			{	MsgBox, , Error, Error that shortcut is already in use
			} else
			{	IfExist, % A_scriptdir "\Addons\" newShortcut ".ahk"
				{	FileRead, newCode, % A_ScriptDir "\Addons\" newShortcut ".ahk"
				} else
				{	controller.display("Select the file to load", ignoreMouseClicks := true)
					FileSelectFile, dir, 12 ,% A_ScriptDir "\Addons"
					if(errorlevel)
					{	controller.clear()
						return ;the user cancelled
					}
					FileRead, newCode, % dir
				}
				if(! newCode)
				{	MsgBox, , Error, Error file could not be read or was empty
					return
				}
				recomp := new recompiler(controller)
				MsgBox, 4, JPGInc, Would you like to add this shortcut to the default shortcut list?
				IfMsgBox Yes
				{	recomp.addShortcut(newShortcut, newCode)
				} else 
				{	recomp.add(newShortcut, newCode)
				}	
				return
			}
		}
			
	}
}
;JPGIncWinscriptFlag End Add



;JPGIncWinscriptFlag Start test
test()
{
MsgBox test
return	
}
;JPGIncWinscriptFlag End test
