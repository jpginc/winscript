class add
{
	__new(controller)
	{	while(true)
		{	newShortcut := controller.getInput("Type a shortcut")
			if(newShortcut == "cancelled")
			{	return
			}
			if(! controller.validShortcut(newShortcut))
			{	MsgBox, , Error, Error that shortcut is already in use
			} else
			{	new recompile(["/a", "newShortcut"])
				return
			}
		}
			
	}
}