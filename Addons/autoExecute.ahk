;JPGIncWinscriptFlag Start autoExecute
/*
 * This file is always included first in the compilation process and is the auto execute secion
 * of the script
 */
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
if not A_IsAdmin
{	Run *RunAs "%A_ScriptFullPath%" 
	ExitApp
}
IfNotExist, Addons
{   MsgBox, 4, JPGInc ERROR, ERROR the Addons folder does not exist. Would you like to create and populate the folder now?
    IfMsgBox, Yes
    {   unpack()
    }
}
GlobalController := new Controller(JPGIncShortcuts, JPGIncCodeSegments)
return
;JPGIncWinscriptFlag End autoExecute
