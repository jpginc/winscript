/* This is the template to use when creating a new addon for Winscript
 */
class default
{	defaultShortcutList := ""

	__New(controller)
	{	global WinscriptMode
		className := controller.getInput("Select script to run", StrSplit(shortcutList, ","))
		WinscriptMode .= className ","
		new %className%(controller)
		return this
	}
}