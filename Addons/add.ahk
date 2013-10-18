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
				{	dir := % A_scriptdir "\Addons\" newShortcut ".ahk"
				} else
				{	controller.display("Select the file to load", ignoreMouseClicks := true)
					FileSelectFile, dir, 12 ,% A_ScriptDir "\Addons"
				}
				recomp = new recompiler(controller)
				recomp.addShortcut(dir, newShortcut)
				return
			}
		}
			
	}
}