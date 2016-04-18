class New_Script
{	
	__new(controller)
	{	
		shortcutName := scriptName := controller.getInput("Enter the name of your new script. Ideally the name will be the same as the shortcut you intend to use")
		if(scriptName == "cancelled" || trim(scriptName) == "")
		{	return
		}
		StringReplace, shortcutName, shortcutName, %A_space%, _, All
		IfNotInString, scriptName, .
		{	scriptname .= ".ahk"
		}
		{	IfExist, addons\%scriptName%
			{	MsgBox, 4, JPGInc Warning, Warning, the file %scriptName% already exists in the Addons folder. Would you like to open it for editing?
				IfMsgBox, Yes
				{	controller.edit("addons\" scriptName)
				}
				return
			}
		}
		FileAppend,
			(
/* If you add this file to Winscript using the 'add' shortcut when the shortcut
 * is selected the program will first try to instanciate a class with the same 
 * name, then try and run a function with the same name and finally jump to 
 * a label with the same name. 
 *
 */
;uncomment this if you want to create a class
/*
class %shortcutName%
{	__new(controller)
	{	controller.showMessage("created the class")
		return this
	}
}
*/
;uncomment this if you want to use a function
/*
%shortcutName%(controller)
{	controller.showMessage("Called the function")
	return
}
*/
;uncomment this if you want to use a label
/*
%shortcutName%:
{	globalController.showMessage("Called the label")
	return
}
*/

/* When the shortcut is launched the global controllers 'context' is set to the
 * name of the shortcut. This allows you to activate hotkeys only when your script
 * has been launched
 */
;place the hotkeys you wish to be active while running this script here
#if GlobalController.getContext() == "%shortcutName%"
;by default the escape key will cancel your shortcut
esc::
{	globalController.clearDisplay()
	globalController.setContext("")
	return
}

;place any hotkeys you want to be active all the time here
#if
			)
			, addons\%scriptName%
		controller.edit("addons\" scriptName)
		controller.showMessage("The file " scriptName " has been created in the Addons folder. When you have finished creating the script use the 'Add' shortcut to include it into the main script")
		return this
	}
}
