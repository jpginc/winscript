/* This function updates a code segment within the running code
 * 
 * The user is presented with a list of code segments and if one
 * is selected it is removed and replaced with the new code
 *
 * If a file exists in the addons folder with the same name of
 * the code segment that the user selects then the contents of 
 * that file is used to replace the removed code otherwise the
 * user is prompted to select the new file
 *
 * @param controller
 * 		An instance of the Controller class
 */
Update_SCript(controller)
{	
	includer := new JPGIncScriptIncluder(controller)
	includer.update()
	return
}
