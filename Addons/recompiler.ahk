/* This program was written by Joshua Graham joshua.graham@jpgautomation.com
 * www.jpgautomation.com
 * Anyone may use any part of this code for any non-malicious purpose
 * with or without referencing me. There is No Warranty 
 */
/* Usage /a winscriptPID shortcutToAdd1 [shortcutToAdd2 ...]
 *      /r winscriptPID shortcutToRemove1 [shortcutToRemove2 ...]
 *      /u winscriptPID shortcutToUpdate1 [shortcutToUpdate2 ...]
 *
 * WinscriptPID can be extracted by using within Winscript
 * process, exist, 
 * WinscriptPID := errorlevel
 */
args := ""
args2 := object()
processID := 1
flag := 2
firstShortcut := 3
fullScriptDir := "WinscriptCurrent.ahk"
beforeFlag := ";JPGIncWinscriptFlag Start"
afterFlag := ";JPGIncWinscriptFlag End"
includeFix = `%A_ScriptDir`%\Addons

if 0 < 3
{   invalidArgs()
}

;extract the command line arguments in case the script needs to be relaunched as admin
loop, %0%
{	args2.insert(param := %A_index%)
	args := """" param """ " args
}
if not A_IsAdmin
{  Run *RunAs "%A_ScriptFullPath%" %args% ; Requires v1.0.92.01+
   ExitApp
}

;check if any command line arguments were sent
if(! args2.maxIndex())
{	invalidArgs()
}
;check that the winscriptPID was send
if args2[processID] is not integer
{   invalidArgs()
}
process, exist, % args2[processID]
if(ErrorLevel != args2[processID])
{   invalidArgs()
}

;get the current source code
FileRead, currentWinscript, % fullScriptDir
if(ErrorLevel)
{   MsgBox, 4 , Warning, Warning the current Winscript file does not exist. Would you like to continue?
    IfMsgBox, No
    {   ExitApp
    }
}

;check a valid flag was sent
if(args2[flag] == "/a")
{   ;get the default shortcut list (incase it is updated)
    RegExMatch(test, "(defaultShortcutList := "".*"")", shortcutList)
    recompile(args[processID], addShortcut(args2, firstShortcut, currentWinscript, shortcutList1), fullScriptDir)
} else if(args2[flag] == "/r")
{   recompile(args2[flag], removeShortcut(args2, firstShortcut, currentWinscript), fullScriptDir)
} else if(args2[flag] == "/f")
{   recompile(args2[flag], addFile(args2, firstShortcut, currentWinscript), fullScriptDir)
} else if(args2[flag] == "/u")
{   currentWinscript := removeShortcut(args2, firstShortcut, currentWinscript)
    ;get the default shortcut list (incase it is updated)
    RegExMatch(test, "(defaultShortcutList := "".*"")", shortcutList)
    recompile(args2[flag], addShortcut(args2, firstShortcut, currentWinScript, shortcutList1), fullScriptDir)
}
invalidArgs()
ExitApp

/* Display a usage message
 */
invalidArgs()
{   usage =
(
Usage:
      recompile.ahk winscriptPID /a shortcutToAdd1 [shortcutToAdd2 ...]
      recompile.ahk winscriptPID /r shortcutToRemove1 [shortcutToRemove2 ...]
      recompile.ahk winscriptPID /u shortcutToUpdate1 [shortcutToUpdate2 ...]
      recompile.ahk winscriptPID /f fileToAppend1 [shortcutToUpdate2 ...] (option doesn't update default shortcuts)
)   
    MsgBox, , Error, Error invalid command line arguments recieved`n%usage%
    ExitApp
}

/* Append a script to the current script string
 */
addShortcut(args, firstShortcut, currentWinscript, shortcutList)
{   global beforeFlag
    global afterFlag
    while(args[firstShortcut])
    {   FileRead, newScript, % args[firstShortcut] ".ahk"
        currentWinscript .= "`n" beforeFlag " " args[firstShortcut] "`n" newScript "`n" afterFlag " " args[firstShortcut] "`n"
        firstShortcut++
    }
    return currentWinscript
}
addFile(args, firstShortcut, currentWinscript)
{   global beforeFlag
    global afterFlag
    while(args[firstShortcut])
    {   FileRead, newScript, % args[firstShortcut] ".ahk"
        currentWinscript .= beforeFlag " " args[firstShortcut] "`n" newScript "`n" afterFlag " " args[firstShortcut] "`n"
        currentWinscript := RegExReplace(currentWinscript, "(defaultShortcutList := "".*)""", "$1" args[firstShortcut] ",""")
        firstShortcut++
    }
    return currentWinscript
}
recompile(oldPID, newFile, fullScriptDir)
{   
    FileDelete, % fullScriptDir ".new"
    FileDelete, errorlog.txt
    ;check for syntax errors
    FileAppend, % "exitApp`n" newFile, % fullScriptDir ".new"
    RunWait, %A_AhkPath% /ErrorStdOut %fullScriptDir%.new > errorlog.txt
    FileRead, errorlog, errorlog.txt
    if(errorlog)
    {   msgbox, , ERROR, There are syntax errors in the new script
        Run, edit errorlog.txt
        ExitApp
    }
    FileDelete, % fullScriptDir ".new"
    FileDelete, % fullScriptDir
    FileAppend, % newFile, % fullScriptDir
    Process, Close, oldPID
    FileCopy, % fullScriptDir, % "../Winscript.ahk", 1
    Run, ../Winscript.ahk
    ExitApp
}
removeShortcut(args, firstShortcut, currentWinscript)
{   global beforeFlag
    global afterFlag
    while(args[firstShortcut])
    {   theStart := RegExMatch(currentWinscript, beforeFlag " " args[firstShortcut])
        theEnd := RegExMatch(currentWinscript, "P)" afterFlag " " args[firstShortcut] "`n", length)
        currentWinscript := SubStr(currentWinscript, 1, theStart - 1) SubStr(currentWinscript, theEnd + length)
        currentWinscript := RegExReplace(currentWinscript, "(defaultShortcutList := "")(.*)" args[firstShortcut] ",(.*)""", "$1$2$3""")
        firstShortcut++
    }
    return currentWinscript
}
