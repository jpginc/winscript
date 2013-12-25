class add
{	__new(controller)
	{	while(true)
		{	newShortcut := controller.getInput("Type a shortcut name.")
			if(newShortcut == "cancelled")
			{	return
			}
			if(! controller.isValidShortcut(newShortcut))
			{	MsgBox, , Error, Error that shortcut is invalid or already in use
			} else
			{	IfExist, % A_scriptdir "\Addons\" newShortcut ".ahk"
				{	FileRead, newCode, % A_ScriptDir "\Addons\" newShortcut ".ahk"
				} else
				{	controller.showMessage("Select the file to load", ignoreMouseClicks := true)
					FileSelectFile, dir, 12 ,% A_ScriptDir "\Addons"
					if(errorlevel)
					{	controller.clearDisplay()
						return ;the user cancelled
					}
					controller.clearDisplay()
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
