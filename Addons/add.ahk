/* This function merges a new code segment into the running code.
 * The user is prompted for a shortcut name which must not be
 * the same as an already merged code segment. 
 * 
 * The code segment may be added as a new 'shortcut' in which case
 * a shortcut is added to the default shortcut list. If a file exists
 * in the Addons folder with the same name as the shortcut then it is
 * used otherwise the user is prompted to select a file. 
 * 
 * After the code segment is added the script is reloaded
 * @param controller
 *		An instance of the Controller class
 */
add(controller)
{	while(true)
	{	;get the name of the new code segment
		newShortcut := controller.getInput("Type a shortcut name.")
		if(newShortcut == "cancelled")
		{	return
		}
		;make sure the name is valid
		if(! controller.isValidShortcut(newShortcut))
		{	MsgBox, , JPGInc ERROR, Error that shortcut is invalid or already in use
		} else
		{	;load the code
			IfExist, % A_scriptdir "\Addons\" newShortcut ".ahk"
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
			{	MsgBox, , JPGInc ERROR, Error file could not be read or was empty
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