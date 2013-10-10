/* This is the template to use when creating a new addon for Winscript
 */
class default
{	defaultShortcutList := ""

	__New(controller)
	{	global WinscriptMode
		className := controller.getInput("Select script to run", StrSplit(shortcutList, ","))
		if(className == "cancelled")
		{	return
		}
		WinscriptMode .= className ","
		if(IsObject(%className%))
		{	new %className%(controller)
		} else if(IsFunc(%className%))
		{	%className%()
		} else if(IsLabel(%className%))
		{	gosub, %className%
		}
		return this
	}
}