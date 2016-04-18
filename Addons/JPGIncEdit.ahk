/* This function opens a code segments file for editing 
 * as long as the file is present in the Addons folder
 * @param controller
 *		An instance of the Controller class
 */
Edit_Script(controller)
{	
	toEdit := controller.getChoice(controller.getAllShortcuts(), "Select a code segment/shortcut to edit")
	includer := new JPGIncScriptIncluder(controller)
	if(fileLocation := includer.getFileLocation(toEdit))
	{
		run, edit "%fileLocation%", , UseErrorLevel
		if(errorLevel)
		{	
			run, % "notepad """ fileLocation """"
		}
	}
	return
}