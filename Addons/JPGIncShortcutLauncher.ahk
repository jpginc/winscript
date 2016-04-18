/* This is the class that will be loaded when entering script mode 
 * Displays a list of shorcuts to choose from
 */
JPGIncShortcutLauncher(controller)
{	
	shortcutName := controller.getChoice(controller.getShortcuts(), "Select script to run")
	if(shortcutName == "cancelled")
	{	
		return
	}
	StringReplace, shortcutName, shortcutName, %A_space%, _ , All
	controller.setContext(shortcutName)
	if(IsObject(%shortcutName%))
	{	
		new %shortcutName%(controller)
	} else if((argCount := IsFunc(shortcutName)))
	{	
		if(argCount == 1)
		{	
			%shortcutName%()
		} else
		{	
			%shortcutName%(controller)
		}
	} else if(IsLabel(shortcutName))
	{	
		gosub, %shortcutName%
	}
	return
}