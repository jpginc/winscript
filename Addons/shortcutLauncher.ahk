/* This is the class that will be loaded when entering script mode 
 * Displays a list of shorcuts to choose from
 */
shortcutLauncher(controller)
{	className := controller.getChoice(controller.getShortcuts(), "Select script to run")
	if(className == "cancelled")
	{	return
	}
	StringReplace, className, className, %A_space%, _ , All
	controller.setContext(className)
	if(IsObject(%className%))
	{	new %className%(controller)
	} else if((argCount := IsFunc(className)))
	{	if(argCount == 1)
		{	%className%()
		} else
		{	%className%(controller)
		}
	} else if(IsLabel(className))
	{	gosub, %className%
	}
	return
}