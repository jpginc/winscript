/* A class that is able to display text to and get input from the user
 * 
 * The display has two modes (which can be switched between using capslock+v
 * whenever the display is active) high visibility and normal. High visibility
 * uses 5 gui text elements to make the text displayed appear to have a border
 * and makes it readable on any background color (where as black text is difficult
 * to read on a black background)
 *
 * The alternate display modes were introduced because the display flickers when 
 * rendering all 5 text elements in high visibility mode.
 */
class JPGIncDisplay
{	;the number of gui elements before the first 'selection' gui elements
	selectionOffput := 5
	;the number of gui elements before the 'choice' gui elements
	choiceOffput := 10
	
	;The color of the display text
	fillColor := "Black"
	;the default color of normal visibility display
	regularFillColor := "Black"
	;the fill color of the high visiblity display
	highVisFillColor := "Black"
	;the outline color for high visibility display
	strokeColor := "Yellow"
	fontSize := 25
	;This value is changed whenever input is requested. Checking if this value has changed
	;will indicate if input was interrupted
	threadNumber := 1
	
	;whether to clear the display on a click
	ignoreMouseClick := false
	;whether to clear the display on the escape key
	ignoreEsc := false
	
	;an instance of the Controller class
	controller := ""
	
	;whether the gui is currently visible or not
	guiVisible := false
	;whether we are waiting for user input
	waitingForInput := false
	
	;the numer of gui elements to render. 1 for normal display 5 for high vis
	visiblitySetting := 5
	
	;the number of selectable items to display on the screen
	selectionCount := 15
	
	inputHandler := new input_class()
	
	/* initialises the class
	 * @param controller
	 * 		an instance of the Controller class
	 */
	__New(controller)
	{	this.initialiseGui()
		this.controller := controller
		return this
	}
	
	/*	Creates the display. There are three sections:
	 * 		message at the top, centered
	 *		input just below message, centered
	 *		choices below input left aligned
	 *	@param message
	 *		an optional string to display in the message section 
	 *	@param selection
	 *		optional string to display in the selection section
	 *	@param input
	 *		optional string to display in the input section
	 * 	@param doShow
	 *		optional boolean which indicates if the window should be shown immediately
	 */
	initialiseGui(message := "", selection := "", Input := "", doShow := false)
	{	if(this.visiblitySetting != 1)
		{	messageOutline := message
			inputOutline := Input
			selectionOutline := selection
		} else
		{	messageOutline := ""
			inputOutline := ""
			selectionOutline := ""
		}
		Gui splash: destroy
		Gui splash: new
		Gui splash: Color, White
		height := A_Screenheight - 150
		width := A_ScreenWidth - 200
		Gui splash: font, % "s" this.fontSize "bold c" this.strokeColor, TimesNewRoman 
		;for the message
		Gui splash: add, text, x1 y2 Center BackgroundTrans h%height% w%width%, % messageOutline
		Gui splash: add, text, x2 y1 Center BackgroundTrans h%height% w%width%, % messageOutline
		Gui splash: add, text, x3 y2 Center BackgroundTrans h%height% w%width%, % messageOutline
		Gui splash: add, text, x2 y3 Center BackgroundTrans h%height% w%width%, % messageOutline
		Gui splash: add, text, % "x2 y2 Center BackgroundTrans c" this.fillColor " h" height " w" width, % message
		;for input
		Gui splash: add, text, x1 yp+52 Center BackgroundTrans h%height% w%width%, % inputOutline
		Gui splash: add, text, x2 yp-1 Center BackgroundTrans h%height% w%width%, % inputOutline
		Gui splash: add, text, x3 yp+1 Center BackgroundTrans h%height% w%width%, % inputOutline
		Gui splash: add, text, x2 yp+1 Center BackgroundTrans h%height% w%width%, % inputOutline
		Gui splash: add, text, % "x2 yp-1 Center BackgroundTrans c" this.fillColor " h" height " w" width, % input
		;for the selections
		Gui splash: add, text, x49 yp+52 BackgroundTrans h%height% w%width%, % selectionOutline
		Gui splash: add, text, x50 yp-1 BackgroundTrans h%height% w%width%, % selectionOutline
		Gui splash: add, text, x51 yp+1 BackgroundTrans h%height% w%width%, % selectionOutline
		Gui splash: add, text, x50 yp+1 BackgroundTrans h%height% w%width%, % selectionOutline
		Gui splash: add, text, % "x50 yp-1 BackgroundTrans c"  this.fillColor " h" height " w" width, % selection
		
		if(doShow)
		{	Gui splash: +lastfound -Caption +AlwaysOnTop -SysMenu +Owner 
			WinSet, TransColor, white
			Gui splash: show, NoActivate y120, WinscriptSplash
			WinSet, Style, -0xC00000, WinscriptSplash
			WinSet, ExStyle, +0x20, WinscriptSplash
			WinSet, Style, -0x840000, WinscriptSplash
			this.guiVisible := true
		} else
		{	this.guiVisible := false
		}
		return
	}
	
	/*	If ignoreMouseClicks is set to true then this function does nothing
	 *	otherwise it clears the screen and cancels input
	 */
	mouseClick()
	{	if(this.ignoreMouseClick)
		{	return
		}
		return this.hide()
	}
	
	/*	If ignoreEsc is set to true then this function does nothing
	 *	otherwise it clears the screen and cancels input
	 */
	esc()
	{	if(this.ignoreEsc)
		{	return
		}
		return this.hide()
	}
	
	/* Sets the text to appear on the screen. 
	 * Sets the guiVisible variable to true
	 * @param message
	 *		A string for the message section
	 * @param choices
	 *		A string for the choices section
	 * @param selection
	 *		A string for the selection section
	 */
	display(message, choices, selection)
	{	Loop, % this.visiblitySetting
		{	GuiControl, splash:text, % "static" 6 - A_index, % message
			GuiControl, splash:text, % "static" 6 - A_index + this.selectionOffput, % selection
			GuiControl, splash:text, % "static" 6 - A_index + this.choiceOffput, % choices
		}
		Gui splash: +lastfound -Caption +AlwaysOnTop -SysMenu +Owner
		WinSet, TransColor, white
		Gui splash: show, NoActivate y120, WinscriptSplash
		WinSet, Style, -0xC00000, WinscriptSplash
		WinSet, ExStyle, +0x20, WinscriptSplash
		WinSet, Style, -0x840000, WinscriptSplash		
		this.guiVisible := true
		return
	}
	
	/*	If we are waiting for input then the input is canceled. The gui isn't hidden
	 * 	in this case because in the cancelation process the gui will be hidden anyway.
	 *	
	 *	If we aren't waiting for the input then the gui is simply hidden and guiVisible is set to false
	 *	
	 *	If neither is true then nothing happens
	 */
	hide()
	{	this.inputHandler.Cancel()
		if(this.guiVisible)
		{	
			this.display("","","")
			Gui splash: hide
			this.guiVisible := false
		}
		return
	}
	
	/*
	 * Sets whether or not a click/escape key will clear the screen or not
	 * @param keys 
	 * 		keys[1] true indicates ignoring mouse clicks
	 * 		keys[2] true indicates ignoring the escape key
	 */
	setClearKeys(keys)
	{	this.ignoreMouseClick := keys.maxIndex() > 0 ? keys[1] : false
		this.ignoreEsc := keys.maxIndex() > 1 ? keys[2] : false
		return
	}
	
	/*
	 * Displays the given message. By default mouseclicks and the escape button 
	 * clear the message from the screen. Pass the optional arguments to override this behaviour.
	 * If you wish to clear the display yourself use the hide() function
	 * @param message
	 *		the string to display
	 *	@param cancelSettings
	 * 		cancelSettings[1] true indicates ignoring mouse clicks
	 * 		cancelSettings[2] true indicates ignoring the escape key
	 */
	showMessage(message, cancelSettings := "")
	{	this.setClearKeys(cancelSettings)
		this.display(message, "", "")
		return
	}
	/*
	 * Displays the given array of choices on the screen and gets input until the user selects
	 * one of the choices. By default mouseclicks clear the message from the screen. Pass the 
	 * optional arguments to override this behaviour. If you wish to clear the display yourself 
	 * use the hide() function
	 *
	 * Please note that you cannot ignore the escape key when getting input from the user because
	 * the input function captures the escape key as an 'end input' flag
	 *
	 * @param origionalChoices
	 *		An array of choices to display to the user. 
	 * @param message
	 *		A string to display in the message section
	 * @param cancelSettings
	 * 		cancelSettings[1] true indicates ignoring mouse clicks
	 *
	 * @return value
	 *		One of the items of origionalChoices
	 */
	getChoice(origionalChoices, message := "", cancelSettings := "")
	{	this.setClearKeys(cancelSettings)
		this.threadNumber++
		selection := {"string": ""}
		oneChar := ""
		lastTab := 0
		filteredChoices := origionalChoices
		this.updateEdit("")
		;get the input
		while true
		{	
			this.display(message, this.arrayToString(filteredChoices, this.selectionCount), RegExReplace(selection.string, "`t"))
			selection := this.inputHandler.getCharacter(selection.string)
			if(selection.value == "cancelled")
			{	this.hide()
				return selection.value
			} else if(instr(selection.string, "`n"))
			{	break
			} else if(instr(selection.string, "`t", true, 0) != lastTab)
			{	
				lastTab := instr(selection.string, "`t", true, 0)
				this.firstIsLast(filteredChoices, GetKeyState("shift", "P"))
				continue
			}
			filteredChoices := this.filterChoices(origionalChoices, RegExReplace(selection.string, "`t"))
		}
		this.hide()
		;return the top element that is being displayed to the user
		return filteredChoices[filteredChoices.minIndex()]
	}
	
	updateEdit(newValue)
	{	GuiControl, splash:, Edit1, % newValue
		gui splash: +LastFound
		ControlSend, Edit1, {end}, A
		return
	}
	/*
	 * Gets a line of input from the user.
	 * @param message
	 * 		A string to display to the user
	 * @param cancelSettings
	 * 		cancelSettings[1] true indicates ignoring mouse clicks
	 * 		cancelSettings[2] true indicates ignoring the escape key
	 *
	 * @return value
	 *		The input
	 */
	getInput(message, cancelSettings := "")
	{	
		this.setClearKeys(cancelSettings)
		;required for the display method
		choices := ""
		;the input variable
		input := {"string": ""}
		this.updateEdit("")
		;get the input
		while true
		{	
			this.display(message, choices, input.string)
			input := this.inputHandler.getCharacter(input.string)
			if(input.value == "cancelled")
			{	
				input.string := input.value
				break
			} else if(instr(input.string, "`n"))
			{	
				break
			}
		}
		this.hide()
		return RegExReplace(input.string, "`n")
	}
	
	/*	Sorts an array of strings based on their similarity to a given string. 
	 *	the origional array is not modified
	 *	@param choices
	 *		An array of strings
	 * 	@param filter
	 *		A string
	 *
	 *	@return value
	 *		An array containing all the elements of choices but ordered by similarity to filter
	 */
	filterChoices(choices, filter)
	{	;If there is no filter then return choices unchanged
		if(filter == "")
		{	return choices
		}
		;an array to insert the strings into. A lower index indicates a closer relation to filter
		returnArray := object()
		
		for key, choice in choices
		{	;how similar the string is to filter
			score := 0
			
			compareStrings := StrSplit(filter, " ")
			loop % compareStrings.maxIndex()
			{	compareString := compareStrings[A_index]
			
				;the filter is trimmed from the left a character at a time. If the remaining 
				;filter matches some part of the choice string then the choices score is increased
				while(compareString)
				{	;Bigger string matches are worth more
					bonus := StrLen(compareString) * 2
					
					;Does the remaining filter exist within the choice string (case sensitive)
					if(pos := RegExMatch(choice, escapeRegex(compareString)))
					{	score += bonus
						;if it is at the start then double the score
						if(pos == 1)
						{	score += bonus
						}
					}
					
					;if it is not the same case?
					if(pos := RegExMatch(choice, "i)" escapeRegex(compareString)))
					{	score += bonus
						if(pos == 1)
						{	score += bonus
						}
					}
					
					;does it exist not at the start but as word within the choice?
					if(RegExMatch(choice, "\W" escapeRegex(compareString)))
					{	score += bonus
					}
					
					;if the string matches exactly then its score is bumped up 
					if(RegExMatch(choice, "i)^" escapeRegex(compareString) "$"))
					{	score *= 100
					}
					StringTrimLeft, compareString, compareString, 1
				}
			}
			
			;items with the same score are moved the the next lowest free index.
			;If the scores are too close together then the ordering is lost
			score *= -1000
			while(returnArray.hasKey(score))
			{ ;increment score until there is a free spot
				score++
			}
			returnArray.Insert(score, choice)
		}
		return returnArray
	}
	
	/*	Takes an array and either makes the first element the last or the opposite
	 *	this function changes the origional array
	 *	@param theArray
	 *		an array containing any type of element
	 *	@param reverse
	 *		A boolean. if true the last element is made the first
	 */
	firstIsLast(ByRef theArray, reverse, count := 1)
	{	if(reverse)
		{	
			removed := theArray.remove(theArray.maxIndex())
			theArray.insert(theArray.minIndex() - 1, removed)
		} else
		{	
			removed := theArray.remove(theArray.minIndex())
			theArray.insert(theArray.maxIndex() + 1, removed)
		}
		return
	}
	
	/*	Converts an array to a string
	 */
	arrayToString(theArray, count := false)
	{	theString := ""
		for key, aString in theArray
		{	if(trim(aString) == "")
			{	continue
			}
			theString .= aString "`n"
			if(count && count < A_index)
			{
				return theString theArray.maxIndex() - A_index " more"
			}
		}
		return theString
	}	
	
	/*	swaps between high vis and normal display modes
	 */
	toggleVisiblitySettings()
	{	SetTimer, RemoveToolTip, Off
		SetTimer, removeTooltip, 2000
		GuiControlGet, message, splash:, static5
		GuiControlGet, input, splash:, % "static" this.choiceOffput + 5
		GuiControlGet, selection, splash:, % "static" this.selectionOffput + 5
		if(this.visiblitySetting == 1)
		{	this.visiblitySetting := 5
			this.fillColor := this.highVisFillColor
			ToolTip, High visiblity menu turned ON
		} else
		{	this.visiblitySetting := 1
			this.fillColor := this.regularFillColor
			ToolTip, High visiblity menu turned OFF
		}
		this.initialiseGui(message, input, selection, true)
		return	
	}
}
splashguiclose:
{	globalController.clearDisplay()
	return
}
removeTooltip:
{	SetTimer, RemoveToolTip, Off
	ToolTip
	return
}
