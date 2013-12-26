class edit
{	__new(controller)
	{	while(true)
		{	toEdit := controller.getChoice(controller.getAllShortcuts(), "Select a code segment/shortcut to edit")
			if(toEdit == "cancelled")
			{	return
			}
			if(controller.codeOrShortcutExists(toEdit))
			{	IfNotExist, % A_ScriptDir "\Addons\" toEdit ".ahk"
				{	MsgBox, , JPGInc ERROR, ERROR file does not exists in the Addons folder.
					return
				}
				run, edit "%A_ScriptDir%\Addons\%toEdit%.ahk", , UseErrorLevel
				if(errorLevel)
				{	run, % "notepad """ A_ScriptDir "\Addons\" toEdit ".ahk"""
				}
				return
			} else
			{	MsgBox, , JPGInc ERROR, ERROR that shortcut does not exist!
			}
		}
	}
}