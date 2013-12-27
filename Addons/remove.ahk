/* this function allows the user to remove a code segment from the running code
 * The user is presented with a list of code segments and, if they select one
 * it is removed from the running code and the script is reloaded.
 * @param controller
 *		An instance of the Controller class
 */
remove(controller)
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
			{	continue
			}
			r := new recompiler()
			r.remove(toRemove)
		} else
		{	MsgBox, , Error, Error that shortcut does not exist
		}
	}
	return 
}
