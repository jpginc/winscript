class recompiler
{

    beforeFlag := ";JPGIncWinscriptFlag Start "
    afterFlag := ";JPGIncWinscriptFlag End "
    
    __New(args*)
    {   return this
    }
    
    getRunningCode() 
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
    
    /*
     * Simply appends the given file to the main script without adding a sortcut
     * @param filename
     *  the full path of the file to include OR the name of the file in the %A_scriptdir%\Addons folder
     * @param shortcutName
     *  the name of the shortcut. If blank a shortcut is not added and the file is simply appended to the running code
     */
    doAdd(filename, shortcutName = "") 
    {
        IfExist, % filename 
        {   FileRead, newCode, % filename
        } else 
        {
            IfExist, % A_ScriptDir "\addons\" filename ".ahk" 
            {   FileRead, newCode, % A_ScriptDir "\addons\" filename ".ahk"
            }
        }
        if(this.joinCode(shortcutName ? shortcutName : fileName, newCode, this.getSource(), shortcutName)) 
        {
            MsgBox, 4, JPGInc Warning, Warning adding this file will overwite existing code`nDo you want to continue?
            IfMsgBox, no 
            {   ;this.fullScript has been changed....
                return
            }
        }
        if(errors := this.checkCodeSyntax(this.fullScript)) 
        {
            MsgBox, 4, JPGInc Error, Error adding this file causes syntax errors`nDo you want to view the errors?
            IfMsgBox, yes 
            {   run, errorLog.txt
            } 
            return
        }
    }
    
    /*
     * Edit's existingCode to include newCode in between beforeflag and afterflag optionally updating the defaultShortcutList := "..." to include name ","
     * returns false if the code was added without removing existing code
     * returns true existing code was updated
     */
    joinCode(name, newCode, ByRef existingCode, addShortcut) 
    {
        
        existingCode := SubStr(existingCode, Instr(existingCode, "`n"))
        if(theStart := RegExMatch(existingCode, this.beforeFlag name "`n")) 
        {
            ;we need to replace the existing code
            theEnd := RegExMatch(existingCode, "P)" this.afterFlag name "`n", length)
            existingCode := SubStr(existingCode, 1, theStart - 1) SubStr(existingCode, theEnd + length)
        }
        if(addShortcut && ! theStart) 
        {
            ;need to add the shortcut
            existingCode := RegExReplace(existingCode, "m)""(.*)""", """$1" name ",""", notNeeded, 1)
        }
        
        ;append the new code with flags
        existingCode .= this.beforeFlag name "`n" newCode "`n" this.afterFlag name "`n"
        return theStart != 0
    }

    /*
     * Appends the given file to the main script also adding it to the shortcut list
     */
    addShortcut(fileName, shortcutName) 
    {
        this.doAdd(fileName, shortcutName)
    }
    
    add(fileName) 
    {
        this.doAdd(fileName, fileName)
    }
    
    /*
     * Removes the code snipit from the main file
     */
    remove(name) {
        existingCode := this.getSource()
        if(theStart := RegExMatch(existingCode, this.beforeFlag name "`n")) 
        {
            theEnd := RegExMatch(existingCode, "P)" this.afterFlag name "`n", length)
            existingCode := SubStr(existingCode, 1, theStart - 1) SubStr(existingCode, theEnd + length)
            existingCode := RegExReplace(existingCode, "m)""(.*)" name ",", """$1", notNeeded, 1)
            this.recompile(existingCode)
        } else 
        {
            MsgBox, , JPGInc Error, Error code segment not found in the currently running code!
            return
        }
    }
    
    /* 
     * Updates an existing code snipit within the file
     */
    update() 
    {
        this.remove()
        this.add()
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
    {
        if(A_IsCompiled) 
        {
            ;not implemented
        } else 
        {
            FileMove, % A_scriptfullpath, % a_scriptfullpat ".backup", 1
            FileAppend, % newCode, % A_scriptfullpath
            Reload
            Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
            MsgBox, 4, JPGInc ERROR, ERROR The script could not be reloaded. Would you like to open it for editing?
            IfMsgBox, Yes 
            {   Edit
            }
            return
        }
    }

}