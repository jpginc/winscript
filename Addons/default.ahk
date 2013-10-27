class default
{	__New(controller)
	{	global WinscriptMode
		shortcutList := controller.getShortcuts()
		className := controller.getInput("Select script to run", StrSplit(shortcutList, ","))
		if(className == "cancelled")
		{	return
		}
		WinscriptMode := className
		if(IsObject(%className%))
		{	new %className%(controller)
		} else if(IsFunc(className))
		{	%className%()
		} else if(IsLabel(className))
		{	gosub, %className%
		}
		return this
	}
}