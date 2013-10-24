class update
{	__new(controller)
	{	while(true)
		{	toUpdate := controller.getInput("Select a code segment to update", StrSplit(controller.getShortcuts(), ","))
			if(toUpdate == "cancelled")
			{	return
			}
			if(! controller.validShortcut(newShortcut))
			{	IfExist, % A_scriptdir "\Addons\" newShortcut ".ahk"
				{	dir := % A_scriptdir "\Addons\" newShortcut ".ahk"
				} else
				{	controller.display("Select the file to load", ignoreMouseClicks := true)
					FileSelectFile, dir, 12 ,% A_ScriptDir "\Addons"
				}
				MsgBox, 4, Warning, Are you sure you wish to update the shortcut %toUpdate%?
				IfMsgBox, No
				{	return
				}
				r := new recompiler()
				r.update(toUpdate)
			} else
			{	MsgBox, , Error, Error that shortcut does not exist
			}
		}
		return this
	}
}