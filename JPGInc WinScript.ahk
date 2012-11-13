/* This program was written by Joshua Graham jpg.inc.au@gmail.com
 * Anyone may use any part of this code for any non-malicious purpose
 * with or without referencing me. There is No Warranty 
*/

;start main:
if not A_IsAdmin
{	Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
	ExitApp
}
#UseHook on 	;because block input is used this needs to be on to allow hot strings to work properly?
#InstallMouseHook	;trying to get a click to exit script mode but doesn't work...
#SingleInstance force


;a place to keep old version backups/complier files etc.
IfNotExist, % A_ScriptDir "\WinScriptData"
{	FileCreateDir, % A_ScriptDir "\WinScriptData"
}

;this global variable determains which hotkeys will be in effect
JPGIncMode := "insert" 
JPGIncVersionNumber := 1
JPGIncShortcuts := "i,add,remove,edit,jk,kj,update,main,"
return

;Capslock + Esc always exits the program
~CapsLock & Esc::
~Esc & CapsLock::
{	SetCapsLockState, off
	ExitApp
}

;the default keys to enter 'script' mode are shift and capslock together
~shift & CapsLock::
~CapsLock & Shift::
{	KeyWait shift
	KeyWait capslock
	SetCapsLockState, off
	JPGIncMode := "script"	
	BlockInput, On
	SplashTextOn, , , Script Mode
	sleep 500
	SplashTextOff
	return
}

;i followed by space etc puts the script back into insert mode.
:B0:i::
{	;if your already in insert mode dont splash the 'insert mode' message
	if(JPGIncMode == "insert")
	{	return	
	}
	JPGIncMode := "insert"
	BlockInput, Off
	SplashTextOn, , , Insert Mode
	sleep 500
	SplashTextOff
	return
}

;I use jk/kj to enter 'win' mode, which helps me navigate around the screen with my
;keyboard
#if JPGIncMode == "insert"
{	:O:jk::
	:O:kj::
	JPGIncMode := "script"	
	BlockInput, On
	SplashTextOn, , , Script Mode
	sleep 500
	SplashTextOff
	return
}

;below here are the list of shortcuts that become available in 'script mode'
#if JPGIncMode == "script"
{	;if you click the mouse then your not using keyboard shortcuts so enter insert mode
	LButton::
	RButton::
	MButton::		;this isn't working :-(
	{	JPGIncMode := "insert"
		BlockInput, Off
		return
	}
	:B0O:add::		;add an script from file to the main script
	{	JPGIncMode := "add"
		gosub, JPGIncAdd
		return
	}
	:B0O:remove::	;remove a script that has already been added to the main script
	{	JPGIncMode := "remove"
		gosub, JPGIncRemove
		return
	}
	:B0O:edit::		;edit a script that has already been added to the main script
	{	JPGIncMode := "edit"
		gosub, JPGIncEdit
		return
	}
	:B0O:update::	;update a script that has already been added to the main script
	{	JPGIncMode := "update"
		gosub, JPGIncUpdate
		return
	}
;Add New Shortcut Above Here do not edit this line!
}

;add a script from file
#if JPGIncMode == "add"
JPGIncAdd:
{	BlockInput, off
	;get a shortcut for the new script
	Loop
	{	message := JPGIncGetScriptName(JPGIncShortcuts, shortcut)
		if(isCancelled := (message == "cancelled"))
		{	break
		}
		if(message == "exists")
		{	msgbox, , JPGInc Error, ERROR Shortcut already exists!
			continue
		}
		if(message == "notExist")
		{	;select the new script file
			FileSelectFile, filename, , , Select Script, *.ahk
			if(isCancelled := errorlevel)
			{	break
			}	;combine the file with the current script
			JPGIncCombine(fileName, shortcut, JPGIncShortcuts)
			break
		}
	}
	JPGIncShortCancelled(isCancelled)
	return
}

;extracts a script that has already been added to the main script but is no longer wanted
#if JPGIncMode == "remove"
JPGIncRemove:
{	BlockInput, off
	;get a shortcut for the script to be removed
	Loop
	{	message := JPGIncGetScriptName(JPGIncShortcuts, shortcut)
		if(isCancelled := (message == "cancelled"))
		{	break
		}
		if(message == "notExist" || JPGIncIsDefaultShortcut(message))
		{	msgbox, , JPGInc Error, ERROR Shortcut does not exist or cannot be removed!
			continue
		}
		if(message == "exists")
		{	FileInstall, c:\programming\projects\WinScript\JPGInc WinScript.ahk, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk", 1
			FileRead, currentFile, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
			if(isCancelled := errorlevel)
			{	MsgBox, , JPGInc ERROR, ERROR WinScriptMainCurrent Does not exist!, 2
				break
			}
			JPGIncRemoveScript(currentFile, shortcut, JPGIncShortcuts)
			if(JPGIncRecompile(currentFile))
			{	break
			}
			renameAndQuit()	;this functin exit's the program
			break
		}
	}
	JPGIncShortCancelled(isCancelled)
	return
}


;runs an already installed script for editing. The edited script isn't used until update is called
JPGIncEdit:
{	BlockInput, off
	Loop
	{	message := JPGIncGetScriptName(JPGIncShortcuts, shortcut)
		if(isCancelled := (message == "cancelled"))
		{	break
		}
		if(message == "notExist" || JPGIncIsDefaultShortcut(message))
		{	msgbox, , JPGInc Error, ERROR Shortcut does not exist or cannot be edited!
			continue
		}
		if(message == "exists")
		{	if(shortcut == "main")	;if the user wants to edit the main script
			{	IfNotExist, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
				{	FileInstall, c:\programming\projects\WinScript\JPGInc WinScript.ahk, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk", 1
				}
				Run, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
				break
			}
			;there is a global variable saved for each script added to the master script which 
			;contains the location of the script when it was origionally added. first try to open that location
			tempFileName := % JPGInc%shortcut%filelocation
			IfNotExist, % tempFileName
			{	MsgBox, , JPGInc ERROR, ERROR The origional file does not exist!
				FileSelectFile, tempFileName, , , , *.ahk
				if(isCancelled := errorlevel)
				{	break
				}
			}
			run, % tempFileName
			break
		}		
	}
	JPGIncShortCancelled(isCancelled)
	return
}

;updates an already included script
JPGIncUpdate:
{	BlockInput, off
	Loop
	{	message := JPGIncGetScriptName(JPGIncShortcuts, shortcut)
		if(isCancelled := (message == "cancelled"))
		{	break
		}
		if(message == "notExist" || JPGIncIsDefaultShortcut(message))
		{	msgbox, , JPGInc Error, ERROR Shortcut does not exist or cannot be updated!
			continue
		}
		if(message == "exists")
		{	if(shortcut == "main")	;if the user wants to edit the main script
			{	filelocation := % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
				IfNotExist, % filelocation
				{	MsgBox, , JPGInc ERROR, ERROR The main script's current file does not exist!
					FileSelectFile, filelocation, , , , *.ahk
					if(isCancelled := errorlevel)
					{	break
					}
				}
				FileRead, toCompile, % filelocation
				if(JPGIncRecompile(toCompile))
				{	break
				}
				renameAndQuit()
				break
			}
			;there is a global variable saved for each script added to the master script which 
			;contains the location of the script when it was origionally added. first try to open that location
			filelocation := % JPGInc%shortcut%filelocation
			IfNotExist, % filelocation
			{	MsgBox, , JPGInc ERROR, ERROR The origional file does not exist!
				FileSelectFile, filelocation, , , , *.ahk
				if(isCancelled := errorlevel)
				{	break
				}
			}
			FileInstall, c:\programming\projects\WinScript\JPGInc WinScript.ahk, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk", 1
			FileRead, mainFile, % A_scriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
			FileRead, newFile, % filelocation
			JPGIncRemoveScript(mainFile, shortcut, JPGIncShortcuts)
			;because main file's JPGIncShortcuts will be without the current shortcut we have to strip it out for the next call
			StringReplace, newShortcuts, JPGIncShortcuts, % shortcut ",", , All 
			JPGIncInsertScript(mainFile, newFile, shortcut, newShortcuts , filelocation)
			if(JPGIncRecompile(mainFile))
			{	break
			}
			renameAndQuit()
			break
		}		
	}
	JPGIncShortCancelled(isCancelled)
	return
}

;returns true if the given 'name' is a default shortcut
JPGIncIsDefaultShortcut(name)
{	return (name == "i" || name == "add" || name == "remove" 
		|| name == "jk" || name == "kj" || name == "edit"
		|| name == "update" || name == "main")
}

;this function takes a list of comma seperated strings and compare input to that list
;returns exists if the input is one of the comma seperated values
;returns notExist if the input is one NOT part of the comma seperated values
;returns cancelled if the input is cancelled or blank
JPGIncGetScriptName(JPGIncShortcuts, ByRef shortcut)
{	BlockInput, off
	;get a shortcut for the new script
	InputBox, newScriptName, Enter Script Shortcut:
	if(errorlevel)
	{	return "cancelled"
	}
	newScriptName = %newScriptName%
	if(newScriptName == "" && isCancelled := 1)
	{	return "cancelled"
	}
	shortcut := newScriptName
	IfInString, JPGIncShortcuts, % newScriptName ","
	{	return "exists"
	}
	return "notExist"
}

;when one of add/remove/edit/update are called this is used at the end.
JPGIncShortCancelled(isCancelled)
{	if(isCancelled)
	{	SplashTextOn, , , Cancelled
		sleep 500
		SplashTextOff
	}
	BlockInput, on
	JPGIncMode := "script"
	return
}

;accepts a string representing the current WinScript code and removes a script from it
JPGIncRemoveScript(ByRef currentFile, removeScriptName, JPGIncShortcuts)
{	;remove it from the current shortcut list
	StringReplace, newShortcuts, JPGIncShortcuts, % removeScriptName ","
	StringReplace, currentFile, currentFile, % JPGIncShortcuts, % newShortcuts
	;remove the file reference
	currentFile := RegExReplace(currentFile, "JPGInc" removeScriptName "fileLocation :=.*(`r`n)")
	;remove the hostring
	theStart := RegExMatch(currentfile, ";start short " removeScriptName ":")
	theEnd := RegExMatch(currentfile, "P);end short " removeScriptName ":", length)
	currentFile := SubStr(currentFile, 1, theStart - 1) SubStr(currentFile, theEnd + length)
	;remove the script
	theStart := RegExMatch(currentfile, ";start " removeScriptName ":")
	theEnd := RegExMatch(currentfile, "P);end " removeScriptName ":", length)
	currentFile := SubStr(currentFile, 1, theStart - 1) SubStr(currentFile, theEnd + length)
	;remove the file reference
	currentFile := RegExReplace(currentFile, "JPGInc" removeScriptName "file Location:=.+", "")
	return		
}

;accepts a string representing the to be compiled program and compiles it,
;first it changes the fileinstall commands to the current directory
JPGIncRecompile(ByRef newFileString)
{	;first change all the old fileInstall absolute paths to the current directory
	oldDirectory := "FileInstall, c:\programming\projects\WinScript\WinScriptData"	;change this to the directory your code is in
	;delete after first compile:
	theStart := RegExMatch(newFileString, ";delete after first compile:(`r`n)")
	theEnd := RegExMatch(newFileString, "P);end delete after first compile:(`r`n)", length)
	newFileString := SubStr(newFileString, 1, theStart - 1) SubStr(newFileString, theEnd + length)
	StringReplace, newFileString, newFileString, % "FileInstall, c:\programming\projects\WinScript\JPGInc WinScript.ahk"
		, % oldDirectory "\WinScriptMainCurrent.ahk", All
	StringReplace, newFileString, newFileString, % "FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler", % oldDirectory, All
	;end delete after first compile:
	StringReplace, newFileString, newFileString, % oldDirectory, % "FileInstall, " A_ScriptDir "\WinScriptData", All
	StringReplace, newFileString, newFileString, % "oldDirectory := """	oldDirectory """", % "oldDirectory := ""FileInstall, " A_ScriptDir "\WinScriptData"""
	FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler\Ahk2Exe.exe, % A_ScriptDir "\WinScriptData\Ahk2Exe.exe"
	FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler\ANSI 32-bit.bin, % A_ScriptDir "\WinScriptData\ANSI 32-bit.bin"
	FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler\AutoHotkeySC.bin, % A_ScriptDir "\WinScriptData\AutoHotkeySC.bin"
	FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler\Unicode 32-bit.bin, % A_ScriptDir "\WinScriptData\Unicode 32-bit.bin"
	FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler\Unicode 64-bit.bin, % A_ScriptDir "\WinScriptData\Unicode 64-bit.bin"
	backupCurrent()	;backup the current running version in case there was a problem with the merging proccess
	FileAppend, % newFileString, % A_scriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
	RunWait, WinScriptData\Ahk2Exe.exe /in WinScriptData\WinScriptMainCurrent.ahk /out newExe.exe
	Run, newExe.exe, , UseErrorLevel, newExePid
	;wait one second for an error box to appear
	WinWait, ahk_pid %newExePid% ahk_class #32770 , , 1
	if(! errorlevel) ;if it does then there might be a problem with the recompilation so give the user an option to use the current verison
	{	msgbox, 4 , JPGInc Warning, Warning an error was detected in the new script`nWould you like to keep using the CURRENT version?
		IfMsgBox, Yes
		{	BlockInput, on
			JPGIncMode := "script"
			Process, close, % newExePid
			return "error"
		}
	}
	Process, close, % newExePid
	return
}
;accepts a file name (must be valid) and combines the selected file with the current version
;of WinScript. 
;filemname = string representation of a .ahk path
;shortcutName = string of the new shortcut to add to the main file
;shortcutList = a comma seperated string of shortcut's already in use
JPGIncCombine(fileName, shortcutName, shortcutList)
{	;get the current version of the program which is installed during recompilation
	FileInstall, c:\programming\projects\WinScript\JPGInc WinScript.ahk, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk", 1
	FileRead, mainFile, % A_scriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
	if(errorlevel)
	{	msgbox, , JPGInc ERROR, ERROR WinScript's current code could not be read!, 2
		return "error"
	}
	FileRead, newFile, % fileName
	if(errorlevel)
	{	msgbox, , JPGInc ERROR, ERROR the new scripts code could not be read!, 2
	}
	JPGIncInsertScript(mainFile, newFile, shortcutName, shortcutList, fileName)
	if(JPGIncRecompile(mainFile))
	{	return
	}
	renameAndQuit()
	return
}

;takes a string representing the main script and inserts a new script inside it
;adds a shortcut that can be fired in 'script' mode
;saves the locaiton of the file to be added under a global called JPGInc*shortcutName*fileLocation for editing/updating use
;changes any #if statements to only fire when in the shortcut's mode
JPGIncInsertScript(ByRef mainFile, ByRef newFile, shortcutName, shortcutList, fileName)
{
shortcutDefault = 
(
	;start short JPGIncNewName:
	:B0O:JPGIncNewName::
	{	JPGIncMode := "JPGIncNewName"
		gosub, JPGIncJPGIncNewName
		return
	}
	;end short JPGIncNewName:	
;Add New Shortcut Above Here do not edit this line
)
	global JPGIncVersionNumber
	;add the new hotstring
	StringReplace, newShort, shortcutDefault, JPGIncNewName, % shortcutName, All
	mainFile := RegExReplace(mainFile, ";Add New Shortcut Above Here do not edit this line", newShort, "" , 1)
	;now add the new shortcut to the shortcut list
	StringReplace, mainFile, mainFile, % shortcutList, % shortcutList shortcutName ",", All
	;now update the version number
	StringReplace, mainFile, mainFile, JPGIncVersionNumber := %JPGIncVersionNumber%, % "JPGIncVersionNumber := " (JPGIncVersionNumber + 1)
	;Now make changes to the script to be loaded
	;change andy #ifwin* statements to be #if statements so that && shortcut name can be added to them
	newFile := RegExReplace(newFile, "#ifwin(active|exist) *, *([^(;|`r|`n]*)", "#if win$1($2) $3")
	newFile := RegExReplace(newFile, "#ifwinnot(active|exist) *, *([^(;|`r|`n]*)", "#if ! win$1($2) $3")
	;add shortcut name && to each #if statement (dont add && if there is only a #if ;etc)
	newFile := RegExReplace(newFile, "#if +[^;`r`n]", "#if JPGIncMode == """ shortcutName """ && ")
	newFile := RegExReplace(newFile, "#if *[`r`n]", "#if JPGIncMode == """ shortcutName """ `n")
	newFile := RegExReplace(newFile, "#if *;", "#if JPGIncMode == """ shortcutName """ `;")
	newFile := "`n;start " shortcutName ":`n#if JPGIncMode == """ shortcutName """`nJPGInc" shortcutName ":`n" newFile "`n;end " shortcutName ":`n"
	mainFile := "JPGInc" shortcutName "fileLocation := """ fileName """`n" mainFile newFile
	return
}

;looks to see how many previous versions have been saved and saves the current version as a backup (max of 10 backups kept)
backupCurrent()
{	IfExist, % A_ScriptDir "\WinScriptData\WinScriptMainBackup10.ahk"
	{	loop, 10
		{	FileMove, % A_ScriptDir "\WinScriptData\WinScriptMainBackup" A_index ".ahk", % A_ScriptDir "\WinScriptData\WinScriptMainBackup" A_index - 1 ".ahk", 1
		}
	}
	loop, 10
	{	IfNotExist, % A_ScriptDir "\WinScriptData\WinScriptMainBackup" A_index ".ahk"
		{	FileMove, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk", % A_ScriptDir "\WinScriptData\WinScriptMainBackup" A_Index ".ahk"
			break
		}
	}
	return
}

;creates a .bat file to delete the old exe and run the new one (waits one second before deleting)
renameAndQuit()
{	IfExist, tempBat.bat
	{	FileDelete, tempBat.bat
	}
batFile =
(
ping 1.1.1.1 -n 1 -w 1000
del "%A_ScriptFullPath%"
move /Y "%A_scriptDir%\newExe.exe" "%A_scriptDir%\JPGInc WinScript.exe"
"%A_scriptDir%\JPGInc WinScript.exe"
exit
)
	FileAppend, % batFile, tempBat.bat
	Run, tempBat.bat, , Hide
	ExitApp
}
;end main: