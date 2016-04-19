/*
 * This file is always included first in the compilation process and is the auto execute secion
 * of the script
 */
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

commandLineArgs := {}
key := ""
Loop, %0%  ; For each parameter:
{   
    if(Mod(A_index, 2) == 0)
    {   
        commandLineArgs[key] :=  %A_Index% 
    } else
    {   
        key :=  %A_Index%
    }
}


{	if(commandLineArgs["adminFlag"])
    {   
        MsgBox, 4, JPGInc Warning, Warning`, unable to get admin privelages. Would you like to continue (Admin acess may be required for some aspects of the program to work correctly)?
        IfMsgBox No
        {   
            ExitApp
        }
    } else
    {   
        Run *RunAs "%A_ScriptFullPath%" "adminFlag" 1
        ExitApp
    }
}
IfNotExist, Addons
{   
    MsgBox, 4, JPGInc ERROR, ERROR the Addons folder does not exist. Would you like to create and populate the folder now?
    IfMsgBox, Yes
    {   
        Unpack_Scripts()
    }
}
GlobalController := new JPGIncController(JPGIncShortcuts, JPGIncCodeSegments)

return
