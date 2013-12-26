class Controller
{	display := new OnScreen(this)
	context := ""
	shortcuts := ""
	codeSegments := ""
	allShortcuts := ""
	
	__new(shortcuts, codeSegments)
	{	this.shortcuts := StrSplit(shortcuts, ",")
		this.codeSegments := StrSplit(codeSegments, ",")
		this.allShortcuts := StrSplit(shortcuts "," codeSegments, ",")
		return this
	}
	
	enterScriptMode()
	{	this.context := "shortcutLauncher"
		shortcutLauncher(this)
		return
	}
	mouseClick()
	{	this.display.mouseClick()
		return
	}
	esc()
	{	this.display.esc()
		return
	}
	showMessage(message, params*)
	{	return this.display.showMessage(message, params)
	}
	clearDisplay()
	{	return this.display.hide()
	}
	getChoice(choices, message := "", params*)
	{	return this.display.getChoice(choices, message, params)
	}
	getInput(message, params*)
	{	return this.display.getInput(message, params)
	}
	setContext(newContext)
	{	this.context := newContext
		return
	}
	getContext()
	{	return this.context
	}
	getShortcuts()
	{	return this.shortcuts
	}
	getCodeSegments()
	{	return this.codeSegments
	}
	getAllShortcuts()
	{	return this.allShortcuts
	}
	isValidShortcut(newShortcut)
	{	if(newShortcut == "")
		{	return false
		}
		IfInString, newShortcut, `,
		{	return false
		}
		return ! (this.shortcutExists(newShortcut) || this.codeSegmentExists(newShortcut))
	}
	shortcutExists(newShortcut)
	{	newShortcut := trim(newShortcut)
		if(newShortcut == "")
		{	return false
		}
		IfInString, newShortcut, `,
		{	return false
		}
		return this.inArray(this.shortcuts, newShortcut)
	}
	codeSegmentExists(newShortcut)
	{	newShortcut := trim(newShortcut)
		if(newShortcut == "")
		{	return false
		}
		IfInString, newShortcut, `,
		{	return false
		}
		return this.inArray(this.codeSegments, newShortcut)
	}
	codeOrShortcutExists(shortcut)
	{	return this.inArray(this.shortcuts, shortcut) || this.inArray(this.codeSegments, shortcut)
	}
	inArray(array, item)
	{	for key, val in array
		{	if(val == item)
			{	return true
			}
		}
		return false
	}
	edit(filename)
	{	Run, edit "%filename%", , UseErrorLevel
		if(errorlevel)
		{	run, notepad "%filename%"
		}
		return
	}
}
