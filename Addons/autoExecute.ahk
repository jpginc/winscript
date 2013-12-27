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
escapeRegex(theString) 
{	return "\Q" theString "\E"
}
inArray(array, item)
{	for key, val in array
    {	if(val == item)
        {	return true
        }
    }
    return false
}
firstIsLast(ByRef theArray, reverse := false)
{	if(reverse)
    {	removed := theArray.remove(theArray.maxIndex())
        theArray.insert(theArray.minIndex() - 1, removed)
    } else
    {	removed := theArray.remove(theArray.minIndex())
        theArray.insert(theArray.maxIndex() + 1, removed)
    }
    return
}
arrayToString(theArray)
{	theString := ""
    for key, aString in theArray
    {	if(trim(aString) == "")
        {	continue
        }
        theString .= aString "`n"
    }
    return theString
}	
removeFromArray(theArray, item)
{   for key, val in theArray
    {  if(val == item)
       {    return theArray.remove(key)
       }
    }
    return
}