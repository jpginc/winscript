class recompiler
{

    beforeFlag := ";JPGIncWinscriptFlag Start "
    afterFlag := ";JPGIncWinscriptFlag End "
    
    __New(args*)
    {   return this
    }
    
    getRunningCode() 
    {   if(A_IsCompiled) 
        {   MsgBox, , ERROR, ERROR Cannot edit this script because it is already compiled!
            return ""
        ;not yet implemented
        } else 
        {   FileRead, fullScript, % A_ScriptFullPath
        }
        return fullScript
    }
    
    /*
     * Simply appends the given file to the main script without adding a sortcut
     * @param filename
     *  the full path of the file to include OR the name of the file in the %A_scriptdir%\Addons folder
     * @param shortcutName
     *  the name of the shortcut. If blank a shortcut is not added and the file is simply appended to the running code
     */
    doAdd(name, newCode, addShortcut) 
    {   runningCode := this.getSource()
        if(this.joinCode(name, newCode, runningCode, addShortcut)) 
        {   MsgBox, 4, JPGInc Warning, Warning adding this file will overwite existing code`nDo you want to continue?
            IfMsgBox, no 
            {   return
            }
        }
		return this.recompile(runningCode)
    }
    
    /*
     * Edit's existingCode to include newCode in between beforeflag and afterflag optionally updating the defaultShortcutList := "..." to include name ","
     * returns false if the code was added without removing existing code
     * returns true existing code was updated
     */
    joinCode(name, newCode, ByRef existingCode, addShortcut, isUpdate := false) 
    {	if(theStart := RegExMatch(existingCode, "`am)^" this.escapeRegex(this.beforeFlag name) "$")) 
        {   ;we need to replace the existing code
            MsgBox % "here " theStart
            theEnd := RegExMatch(existingCode, "P`am)^" this.escapeRegex(this.afterFlag name) "$", length)
            existingCode := SubStr(existingCode, 1, theStart - 1) SubStr(existingCode, theEnd + length)
        }
        if(! isUpdate)
        {   if(addShortcut && ! theStart) 
            {   ;need to add the shortcut
                existingCode := RegExReplace(existingCode, "`am)^JPGIncShortcuts := ""(.*)""", "JPGIncShortcuts := ""$1" this.escapeDollars(name) ",""", notNeeded, 1)
            } else if (! theStart)
            {   existingCode := RegExReplace(existingCode, "`am)^JPGIncCodeSegments := ""(.*)""", "JPGIncCodeSegments := ""$1" this.escapeDollars(name) ",""", notNeeded, 1)
            }
        }
        if(name == "autoExecute")
        {   theEnd := RegExMatch(existingCode, "P`am)^" this.escapeRegex(this.afterFlag "shortcutNames") "$", length)
            shortcutNames := SubStr(existingCode, 1, theEnd + length)
            otherCode := SubStr(existingCode, theEnd + length)
            ;special case where the code has to be added to the start of the script but after the shortcutNames section
            existingCode := shortcutNames "`n" this.beforeFlag name "`n" newCode "`n" this.afterFlag name "`n" otherCode
        } else
        {   ;append the new code with flags
            existingCode .= "`n" this.beforeFlag name "`n" newCode "`n" this.afterFlag name "`n"
        }
        return theStart != 0
    }
    
    /*
     * removes from the start flag of 'name' to the endflag (inclusive) from 'existingCode'
     * returns 0 if successful
     * returns 1 if unsuccessful
     */
    splitCode(name, ByRef existingCode, deleteShortcut := false)
    {   if(theStart := RegExMatch(existingCode, "`am)^" this.escapeRegex(this.beforeFlag name) "$")) 
        {	theEnd := RegExMatch(existingCode, "P`am)^" this.escapeRegex(this.afterFlag name) "$", length)
            existingCode := SubStr(existingCode, 1, theStart - 1) SubStr(existingCode, theEnd + length)
            existingCode := RegExReplace(existingCode, "\R\R", "`r`n")
            if(deleteShortcut)
            {   existingCode := RegExReplace(existingCode, "m)""(.*)" this.escapeRegex(name) ",", """$1", notNeeded, 1)
            }
            return 0
        }
        return 1
    }

    /*
     * Appends the given file to the main script also adding it to the shortcut list
     */
    addShortcut(name, newCode) 
    {   return this.doAdd(name, newCode, true)
    }
    
    add(name, newCode) 
    {   return this.doAdd(name, newCode, false)
    }
    
    /*
     * Removes the code snipit from the main file
     */
    remove(name, update := false) 
    {   existingCode := this.getSource()
        if(this.splitCode(name, existingCode, deleteShortcut := true))
        {   MsgBox, , JPGInc Error, Error code segment not found in the currently running code!
            return 
        }
        return this.recompile(existingCode)
    }
    
    /* 
     * Updates an existing code snipit within the file
	 * Not yet implemented
     */
    update(name, newCode) 
    {	existingCode := this.getSource()
        if(this.splitCode(name, existingCode))
        {   MsgBox, 4, JPGInc Warning, Warning existing code was not found (or removed) do you wish to continue?
			IfMsgBox No
			{	return
			}
		}
		this.joinCode(name, newCode, existingCode, addShortcut := false, isUpdate := true)
		return this.recompile(existingCode)
    }
    
    /*
     * Checks if the given code will compile
     * returns 0 if the code compiles without any problems
     * returns the compilation errors otherwise
     */
    checkCodeSyntax(code) 
    {
        FileDelete, JPGIncTempFile.ahk
        FileDelete, errorlog.txt

        FileAppend, % "exitapp`n" code, JPGIncTempFile.ahk
        RunWait, %A_AhkPath% /ErrorStdOut JPGIncTempFile.ahk > errorlog.txt
        FileDelete, JPGIncTempFile.ahk

        FileRead, errorlog, errorlog.txt
        if(errorlog)
        {   return errorlog
        }
        return false
    }
    
    /*
     * returns the code of the currently running script
     */
    getSource() 
    {
        if(A_IsCompiled) 
        {
            ;not yet implemented
        } else 
        {
            FileRead, fullScript, % A_ScriptFullPath
        }
        return fullScript
    }
    
    recompile(newCode) 
    {	if(A_IsCompiled) 
        {	return
            ;not implemented
        } else 
        {	FileMove, % A_scriptfullpath, % a_scriptfullpath ".backup", 1
            FileAppend, % newCode, % A_scriptfullpath
            Reload
            Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
			WinClose, ahk_class #32770
			FileMove, % A_ScriptFullPath, % A_ScriptFullPath ".failed", 1
			FileMove, % A_scriptfullpath ".backup", % a_scriptfullpath, 1
            MsgBox, 4, JPGInc ERROR, ERROR The script could not be reloaded. Would you like to open it for editing?
            IfMsgBox, Yes 
            {   Run, edit "%A_scriptfullpath%.failed", , UseErrorLevel
				if(errorlevel)
				{	run, % "notepad """ A_scriptfullpath ".failed"""
				}
            }
            return
        }
    }
	
	doMatch(haystack, needle)
	{	return RegExMatch(haystack, "`am)^" needle "$")
	}
	
	escapeRegex(theString) 
	{	return "\Q" RegExReplace(theString, "(\Q|\E)", "\$1") "\E"
	}
	
	escapeDollars(theString)
	{	StringReplace, theString, theString, $, $$, all
		return theString
	}
}