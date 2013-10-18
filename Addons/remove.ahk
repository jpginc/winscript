class remove
{	__new(controller)
	{	while(true)
		{	toRemove := controller.getInput("Type a shortcut name.", controller.getShortcuts())
			if(toRemove == "cancelled")
			{	return
			}
			if(! controller.validShortcut(newShortcut))
			{	MsgBox, 4, Warning, Are you sure you wish to remove this shortcut?
				IfMsgBox, No
				{	return
				}
				r := new recompiler()
				r.remove(toRemove)
			} else
			{	MsgBox, , Error, Error that shortcut does not exist
			}
		}
			
	}
}