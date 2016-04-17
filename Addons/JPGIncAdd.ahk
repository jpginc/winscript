/* This function merges a new code segment into the running code.
 * The user is prompted for a shortcut name which must not be
 * the same as an already merged code segment. 
 * 
 * The code segment may be added as a new 'shortcut' in which case
 * a shortcut is added to the default shortcut list. If a file exists
 * in the Addons folder with the same name as the shortcut then it is
 * used otherwise the user is prompted to select a file. 
 * 
 * After the code segment is added the script is reloaded
 * @param controller
 *		An instance of the Controller class
 */
JPGIncAdd(controller)
{	
	includer := new JPGIncScriptIncluder(controller)
	includer.add()
	return
}
