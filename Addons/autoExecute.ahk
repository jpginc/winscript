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
    {   commandLineArgs[key] :=  %A_Index% 
    } else
    {   key :=  %A_Index%
    }
}


;~ if(! A_IsAdmin)
{	if(commandLineArgs["adminFlag"])
    {   MsgBox, 4, JPGInc Warning, Warning`, unable to get admin privelages. Would you like to continue (Admin acess may be required for some aspects of the program to work correctly)?
        IfMsgBox No
        {   ExitApp
        }
    } else
    {   Run *RunAs "%A_ScriptFullPath%" "adminFlag" 1
        ExitApp
    }
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
URLDownloadToVar(url, sizeWarn := false)
{   previousValue := ComObjError(false)
    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WebRequest.Open("HEAD", url)
    WebRequest.Send()
    requestStatus := WebRequest.status
    if(requestStatus < 200 || requestStatus > 299) ;2XX is success
    {   ComObjError(previousValue)
        return false
    } 
    size := WebRequest.GetResponseHeader("Content-Length") ;not all headers have a content length attribute!
    if(sizeWarn && size > sizeWarn)
    {   MsgBox, 4, JPGInc Warning, Warning the download you have requested is %size% bytes (ie large)`nDo you really want to download?
        IfMsgBox no
        {   ComObjError(previousValue)
            return false
        }
    }
    WebRequest.Open("GET", url)
    WebRequest.Send()
    response := WebRequest.ResponseText
    ComObjError(previousValue)
    Return response    
}