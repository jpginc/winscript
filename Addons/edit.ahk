/* This function opens a code segments file for editing 
 * as long as the file is present in the Addons folder
 * @param controller
 *		An instance of the Controller class
 */
edit(controller)
{	while(true)
	{	;get the name of the code segment to edit
		toEdit := controller.getChoice(controller.getAllShortcuts(), "Select a code segment/shortcut to edit")
		if(toEdit == "cancelled")
		{	return
		}
		if(controller.codeOrShortcutExists(toEdit)) ;this isn't really neccesarry...
		{	IfNotExist, % A_ScriptDir "\Addons\" toEdit ".ahk"
			{	MsgBox, , JPGInc ERROR, ERROR file does not exists in the Addons folder.
				return
			}
			run, edit "%A_ScriptDir%\Addons\%toEdit%.ahk", , UseErrorLevel
			if(errorLevel)
			{	run, % "notepad """ A_ScriptDir "\Addons\" toEdit ".ahk"""
			}
			return
		} else
		{	MsgBox, , JPGInc ERROR, ERROR that shortcut does not exist!
		}
	}
}