/*
 * This class handles loading, adding and updating the script
 */
class JPGIncScriptIncluder
{
	controller := ""
	
	__new(controller)
	{
		this.controller := controller
		return this
	}
	
	add() 
	{
		if(newShortcut := this.getShortcutName("Type a shortcut name."))
		{	
			if(fileLocation := this.getFileLocation(newShortcut))
			{
				codeReader := new JPGIncCodeReader(fileLocation)
				newCode := this.codeReader.readCode()
				if(! newCode)
				{	
					MsgBox, , JPGInc ERROR, Error file could not be read or was empty
					return
				}
				
				recomp := new JPGIncRecompiler(controller)
				MsgBox, 4, JPGInc, Would you like to add this shortcut to the default shortcut list?
				IfMsgBox Yes
				{	recomp.addShortcut(newShortcut, newCode)
				} else 
				{	recomp.add(newShortcut, newCode)
				}	
				return
			}
		}
		return
	}
	
	getShortcutName(message) 
	{
		while, true
		{
			;get the name of the new code segment
			newShortcut := this.controller.getInput(message)
			if(newShortcut == "cancelled")
			{	
				return
			}
			;make sure the name is valid
			if(controller.isValidShortcut(newShortcut))
			{	
				return newShortcut
			} 
			MsgBox, , JPGInc ERROR, Error that shortcut is invalid or already in use
		}
	}
	
	getFileLocation(newShortcut) 
	{
		IfExist, % A_scriptdir "\Addons\" newShortcut ".ahk"
		{	
			return A_ScriptDir "\Addons\" newShortcut ".ahk"
		} else if(FileExist(A_scriptdir "\Addons\" newShortcut "\" newShortcut ".ahk"))
		{
			return A_ScriptDir "\Addons\" newShortcut "\" newShortcut ".ahk"
		}
		return this._selectFileLocation()
	}
	
	_selectFileLocation()
	{
		this.controller.showMessage("Select the file to load", ignoreMouseClicks := true)
		
		FileSelectFile, dir, 3 ,% A_ScriptDir "\Addons"
		if(errorlevel)
		{	
			this.controller.clearDisplay()
			return ;the user cancelled
		}
		this.controller.clearDisplay()
		return RegExReplace(dir, "\R")		
	}
	
	update()
	{
		if(toUpdate := this.getShortcutName("Select a code segment to update"))
		{	
			if(this.controller.codeOrShortcutExists(toUpdate))
			{	
				if(fileLocation := this.getFileLocation(toUpdate))
				{
					codeReader := new JPGIncCodeReader(fileLocation)
					newCode := this.codeReader.readCode()
					if(! newCode)
					{	
						MsgBox, , Error, Error file could not be read or was empty
						return
					}
					MsgBox, 4, Warning, Are you sure you wish to update the shortcut %toUpdate%?
					IfMsgBox, No
					{	
						return
					}
					r := new JPGIncRecompiler()
					r.update(toUpdate, newCode)
				}
			} else
			{	
				MsgBox, , Error, Error that shortcut does not exist
			}
		}
		return 
	}
	
}