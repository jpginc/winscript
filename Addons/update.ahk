class update
{	__new(controller)
	{	while(true)
		{	toUpdate := controller.getInput("Select a code segment to update", StrSplit(controller.getAllShortcuts(), ","))
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