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
WinscriptMode := ""
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
	display.show(new default(display))
	return
}
;if you click the mouse then your not using keyboard shortcuts so enter insert mode
~LButton::
~RButton::
~MButton::
{	display.mouseClick()
	return
}
~Esc::
{	display.esc()
	return
}


/* A class to handle displaying text and choices on the screen
 */
class OnScreen
{	ignoreMouseClick := false
	ignoreEsc := false
	selectionOffput := 5
	choiceOffput := 10
	__New()
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
		return this
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
		Loop, 5
		{	GuiControl, splash:text, static%A_index%, % message
		}
		Gui splash: +lastfound +disabled -Caption +AlwaysOnTop -SysMenu 
		WinSet, TransColor, white
		Gui splash: show, NoActivate y120, WinscriptSplash
		return
	}
	
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
		return choices == "" ? selection : SubStr(choices, 1, InStr(choices, "`n"))
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