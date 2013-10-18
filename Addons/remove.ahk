class remove
{	__new(controller)
	{	while(true)
		{	toRemove := controller.getInput("Select a code segment to remove", StrSplit(controller.getShortcuts(), ","))
			if(toRemove == "cancelled")
			{	return
			}
			if(! controller.validShortcut(newShortcut))
			{	MsgBox, 4, Warning, Are you sure you wish to remove the shortcut %toRemove%?
				IfMsgBox, No
				{	return
				}
				r := new recompiler()
				r.remove(toRemove)
			} else
			{	MsgBox, , Error, Error that shortcut does not exist
			}
		}
		return this
	}
}