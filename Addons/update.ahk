/* This function updates a code segment within the running code
 * 
 * The user is presented with a list of code segments and if one
 * is selected it is removed and replaced with the new code
 *
 * If a file exists in the addons folder with the same name of
 * the code segment that the user selects then the contents of 
 * that file is used to replace the removed code otherwise the
 * user is prompted to select the new file
 *
 * @param controller
 * 		An instance of the Controller class
 */
update(controller)
{	while(true)
	{	;get the name of the code segment to update
		toUpdate := controller.getChoice(controller.getAllShortcuts(), "Select a code segment to update")
		if(toUpdate == "cancelled")
		{	return
		}
		if(controller.codeOrShortcutExists(toUpdate))
		{	;check if a file with the same name exists in the addons folder
			IfExist, % A_scriptdir "\Addons\" toUpdate ".ahk"
			{	FileRead, newCode, % A_ScriptDir "\Addons\" toUpdate ".ahk"
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
			{	MsgBox, , Error, Error file could not be read or was empty
				return
			}
			MsgBox, 4, Warning, Are you sure you wish to update the shortcut %toUpdate%?
			IfMsgBox, No
			{	continue
			}
			r := new recompiler()
			r.update(toUpdate, newCode)
		} else
		{	MsgBox, , Error, Error that shortcut does not exist
		}
	}
	return 
}
