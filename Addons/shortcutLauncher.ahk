;JPGIncWinscriptFlag Start shortcutLauncher
/* This is the class that will be loaded when entering script mode 
 * Displays a list of shorcuts to choose from
 */
shortcutLauncher(controller)
{	className := controller.getChoice(controller.getShortcuts(), "Select script to run")
	if(className == "cancelled")
	{	return
	}
	controller.setContext(className)
	if(IsObject(%className%))
	{	new %className%(controller)
	} else if(IsFunc(className))
	{	%className%()
	} else if(IsLabel(className))
	{	gosub, %className%
	}
	return
}
;JPGIncWinscriptFlag End shortcutLauncher