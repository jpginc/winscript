class remove
{	__new(controller)
	{	while(true)
		{	toRemove := controller.getChoice(controller.getAllShortcuts(), "Select a code segment/shortcut to remove")
			if(toRemove == "cancelled")
			{	return
			}
			if(toRemove == "autoExecute")
			{	MsgBox, , ERROR, Error you cannot remove the autoExecute section. Use edit/update instead
				return
			}
			if(controller.codeOrShortcutExists(toRemove))
			{	MsgBox, 4, Warning, Are you sure you wish to remove the code segment %toRemove%?
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