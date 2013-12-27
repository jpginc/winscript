/* A class that is able to display a message and/or present a list of items 
 * for the user to select from
 */
class OnScreen
{	selectionOffput := 5
	choiceOffput := 10
	fillColor := "Yellow"
	;strokeColor := "Green"
	strokeColor := "Black"
	fontSize := 25
	ignoreMouseClick := false
	ignoreEsc := false
	controller := ""
	guiVisible := false
	waitingForInput := false
	visiblitySetting := 1
	/* 
	 * Creates a gui 
	 */
	__New(controller)
	{	Gui splash: new
		Gui splash: Color, White
		height := A_Screenheight - 150
		width := A_ScreenWidth - 200
		Gui splash: font, % "s" this.fontSize "bold c" this.strokeColor, TimesNewRoman 
		;for the message
		Gui splash: add, text, x1 y2 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x2 y1 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x3 y2 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x2 y3 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, % "x2 y2 Center BackgroundTrans c" this.fillColor " h" height " w" width
		;for input
		Gui splash: add, text, x1 yp+52 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x2 yp-1 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x3 yp+1 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, x2 yp+1 Center BackgroundTrans h%height% w%width%
		Gui splash: add, text, % "x2 yp-1 Center BackgroundTrans c" this.fillColor " h" height " w" width
		;for the selections
		Gui splash: add, text, x49 yp+52 BackgroundTrans h%height% w%width%
		Gui splash: add, text, x50 yp-1 BackgroundTrans h%height% w%width%
		Gui splash: add, text, x51 yp+1 BackgroundTrans h%height% w%width%
		Gui splash: add, text, x50 yp+1 BackgroundTrans h%height% w%width%
		Gui splash: add, text, % "x50 yp-1 BackgroundTrans c"  this.fillColor " h" height " w" width
		this.controller := controller
		return this
	}
	
	mouseClick()
	{	if(this.ignoreMouseClick)
		{	return
		}
		return this.hide()
	}
	
	esc()
	{	if(this.ignoreEsc)
		{	return
		}
		return this.hide()
	}
	
	display(message, choices, selection)
	{	if(params.maxIndex())
		{	this.ignoreMouseClick := params[1]
			this.ignoreEsc := params.maxIndex() > 1 ? params[2] : false
		}
		;the message
		Loop, % this.visiblitySetting
		{	GuiControl, splash:text, static%A_index%, % message
		}
		;the choices
		loop, % this.visiblitySetting
		{	GuiControl, splash:text, % "static" A_index + this.selectionOffput, % selection
			GuiControl, splash:text, % "static" A_index + this.choiceOffput, % choices
		}
		Gui splash: +lastfound +disabled -Caption +AlwaysOnTop -SysMenu +Owner
		WinSet, TransColor, white
		Gui splash: show, NoActivate y120, WinscriptSplash
		this.guiVisible := true
		return
	}
	
	/*
	 * clear the display
	 */
	hide()
	{	if(this.waitingForInput)
		{	Gui splash: +lastfound
			send {esc}
			return
		}
		if(this.guiVisible)
		{	this.display("","","")
			Gui splash: hide
			this.guiVisible := false
		}
		return
	}
	
	/*
	 * Sets whether or not a click/escape key will clear the screen or not
	 * @params[1] 
	 * 		true indicates ignoring mouse clicks
	 * @params[2]
	 *		true indicates ignoring the escape key
	 */
	setClearKeys(keys)
	{	this.ignoreMouseClick := keys.maxIndex() > 0 ? keys[1] : false
		this.ignoreEsc := keys.maxIndex() > 1 ? keys[2] : false
		return
	}
	
	/*
	 * Displays the given message. By default mouseclicks and the escape button 
	 * clear the message from the screen. Pass the optional arguments to override this behaviour.
	 * If you wish to clear the display yourself use the clear() function
	 * usage:
	 * showMessage(message to display[, array[1] = ignoreMouseClick, array[2] = ignoreEsc])
	 */
	showMessage(message, optionalArgs := "")
	{	this.setClearKeys(optionalArgs)
		this.display(message, "", "")
		return
	}
	/*
	 * Displays the given array of choices on the screen and gets input until the user selects
	 * one of the choices. By default mouseclicks clear the message from the screen. Pass the 
	 * optional arguments to override this behaviour. If you wish to clear the display yourself 
	 * use the clear() function
	 * usage:
	 * getChoices(array of Choices[, message to display = "", ignoreMouseClick = false])
	 */
	getChoice(origionalChoices, message := "", optionalArgs := "")
	{	this.setClearKeys(optionalArgs)
		;you cannot ignore the escape key when getting input
		this.ignoreEsc := false
		selection := ""
		oneChar := ""
		filteredChoices := origionalChoices
		;get the input
		while true
		{	this.display(message, this.arrayToString(filteredChoices), selection)
			oneChar := this.getNextChar()
			if(oneChar == "cancelled")
			{	this.hide()
				return "cancelled"
			} else if(oneChar == "end")
			{	break
			} else if(oneChar == "backspace")
			{	StringTrimRight, selection, selection, 1
				filteredChoices := this.filterChoices(origionalChoices, selection)
			} else if(oneChar == "tab")
			{	this.firstIsLast(filteredChoices, GetKeyState("shift", "P"))
			} else
			{	selection .= oneChar
				filteredChoices := this.filterChoices(origionalChoices, selection)
			}
		}
		this.hide()
		;get the input
		return filteredChoices.maxIndex() > 0 ? filteredChoices[1] : selection
	}
	/*
	 * Gets input from the user.
	 * usage: 
	 * getInput(message to display[, ignore mouse click = false])
	 */
	getInput(message, optionalArgs := "")
	{	this.setClearKeys(optionalArgs)
		;you cannot ignore the escape key when getting input
		this.ignoreEsc := false
		choices := ""
		selection := ""
		oneChar := ""
		
		;get the input
		while true
		{	this.display(message, choices, selection)
			oneChar := this.getNextChar()
			if(oneChar == "cancelled")
			{	selection := "cancelled"
				break
			} else if(oneChar == "end")
			{	break
			} else if(oneChar == "backspace")
			{	StringTrimRight, selection, selection, 1
			} else
			{	selection .= oneChar
			}
		}
		this.hide()
		return selection
	}
	
	/* Eventually I want to make this intelligent
	 * now it sorts a given array of strings by how similar they are to the given string filter
	 */
	filterChoices(choices, filter)
	{	if(filter == "")
		{	return choices
		}
		sortedChoices := object()
		returnArray := Object()
		;~ returnString := ""
		for key, choice in choices
		{	score := 0
			compareString := filter
			while(compareString)
			{	bonus := StrLen(compareString) * 2
				if(pos := RegExMatch(choice, escapeRegex(compareString)))
				{	score += bonus
					if(pos == 1)
					{	score += bonus
					}
				}
				if(pos := RegExMatch(choice, "i)" escapeRegex(compareString)))
				{	score += bonus
					if(pos == 1)
					{	score += bonus
					}
				}
				if(RegExMatch(choices, "\W" escapeRegex(compareString)))
				{	score += bonus
				}
				if(RegExMatch(choice, "i)^" escapeRegex(compareString) "$"))
				{	score *= 100
				}
				StringTrimLeft, compareString, compareString, 1
			}
			score *= 100
			while(sortedChoices.hasKey(score))
			{ ;increment score until there is a free spot
				score--
			}
			sortedChoices.Insert(score, choice)
		}
		
		while((highestScore := sortedChoices.remove(sortedChoices.maxIndex())) != "")
		{	returnArray.insert(highestScore)
		}
		return returnArray
	}
	
	/* Gets one character from the user 
	 * returns "cancelled" if the escape key is pressed 
	 * returns "end" if return was pressed
	 * takes a string and returns that string with the next character appeneded to it
	 */
	getNextChar()
	{	this.waitingForInput := true
		input, oneChar, L1,{Esc}{BackSpace}{enter}{tab}{Lalt}{RAlt}{Lctrl}{RCtrl}{LWin}{RWin}
		this.waitingForInput := false
		if(ErrorLevel == "EndKey:Backspace")
		{ 	return "backspace"
		} else if(ErrorLevel == "EndKey:Escape")
		{	return "cancelled"
		} else if(ErrorLevel == "EndKey:Tab")
		{	return "tab"
		} else if(ErrorLevel == "EndKey:Enter")
		{	return "end"
		} else if(InStr(errorLevel, "EndKey:"))
		{	StringReplace, keyName, ErrorLevel, EndKey:
			send {%keyName% down}
			KeyWait, % keyName
			return this.getNextChar()
		}
		return oneChar
	}
	firstIsLast(ByRef theArray, reverse)
	{	if(reverse)
		{	removed := theArray.remove(theArray.maxIndex())
			theArray.insert(theArray.minIndex() - 1, removed)
		} else
		{	removed := theArray.remove(theArray.minIndex())
			theArray.insert(theArray.maxIndex() + 1, removed)
		}
		return
	}
	arrayToString(theArray)
	{	theString := ""
		for key, aString in theArray
		{	if(trim(aString) == "")
			{	continue
			}
			theString .= aString "`n"
		}
		return theString
	}	
	toggleVisiblitySettings()
	{	if(this.visiblitySetting == 1)
		{	this.visiblitySetting := 5
			ToolTip, High visiblity menu turned ON
			GuiControlGet, message, splash:, static1
			GuiControlGet, input, splash:, % "static" this.choiceOffput + 1
			GuiControlGet, selection, splash:, % "static" this.selectionOffput + 1
			loop, 4
			{	GuiControl, splash:text, % "static" A_index + 1 +  this.selectionOffput, % selection
				GuiControl, splash:text, % "static" A_index + 1 +this.choiceOffput, % input
				GuiControl, splash:text, % "static" A_index + 1, % message
			}
			SetTimer, RemoveToolTip, Off
			SetTimer, removeTooltip, 2000
		} else
		{	this.visiblitySetting := 1
			loop, 4
			{	GuiControl, splash:text, % "static" A_index + 1 + this.selectionOffput,
				GuiControl, splash:text, % "static" A_index + 1 + this.choiceOffput,
				GuiControl, splash:text, % "static" A_index + 1, 
			}
			ToolTip, High visiblity menu turned OFF
			SetTimer, RemoveToolTip, Off
			SetTimer, removeTooltip, 2000
		}
		return
	}
}
removeTooltip:
{	SetTimer, RemoveToolTip, Off
	ToolTip
	return
}
