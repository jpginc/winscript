;start main:
if not A_IsAdmin
{	Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
	ExitApp
}
#UseHook on 	;because block input is used this needs to be on to allow hot strings to work properly
#InstallMouseHook
#SingleInstance force


;I want the compiler to be with the script so that it can be recompiled on machines that dont have autohotkey
IfNotExist, % A_ScriptDir "\WinScriptData"
{	FileCreateDir, % A_ScriptDir "\WinScriptData"
}

;this global variable determains which hotkeys will be in effect
JPGIncMode := "insert" 
JPGIncVersionNumber := 1
JPGIncShortcuts := "i,add,remove,jk,kj,"
return
;Capslock + Esc always exits the app
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
{	enterInsert:
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

#if JPGIncMode == "insert"
{	
	:O:jk::
	:O:kj::
	JPGIncMode := "win"	
	BlockInput, On
	SplashTextOn, , , Script Mode
	sleep 500
	SplashTextOff
	return
}



;when the user isn't in insert mode you can return there by pressing i and then enter or space etc.
#if JPGIncMode == "script"
{	;if you click the mouse then your not using keyboard shortcuts so enter insert mode
	LButton::
	RButton::
	MButton::		;this isn't working :-(
	{	JPGIncMode := "insert"
		BlockInput, Off
		return
	}
	:B0O:add::
	{	JPGIncMode := "add"
		gosub, JPGIncAdd
		return
	}
	:B0O:remove::
	{	JPGIncMode := "remove"
		gosub, JPGIncRemove
		return
	}
;Add New Shortcut Above Here do not edit this line!
}

;the new shortcut allows a user to combine an existing script with the master script
#if JPGIncMode == "add"
JPGIncAdd:
{	;a list of currently used shortcuts (add to this each time a new shortcut is added)
	isCancelled := 0
	BlockInput, off
	;get a shortcut for the new script
	Loop
	{	InputBox, newScriptName, Enter Script Shortcut:
		if(isCancelled := errorlevel)
		{	break
		}
		newScriptName = %newScriptName%
		if(newScriptName == "" && isCancelled := 1)
		{	break
		}
		IfInString, JPGIncShortcuts, % newScriptName ","
		{	MsgBox, , JPGInc ERROR, ERROR Shortcut Already Exists
			continue
		}
		FileSelectFile, filename, , , Select Script, *.ahk
		if(isCancelled := errorlevel)
		{	break
		}
		isCancelled := JPGIncCombine(fileName, newScriptName, JPGIncShortcuts)
		break
	}
	if(isCancelled)
	{	SplashTextOn, , , Cancelled
		sleep 500
		SplashTextOff
	}
	BlockInput, on
	JPGIncMode := "script"
	return	
}

;accepts a file name (must be valid) and combines the selected file with the current version
;of WinScript. If WinScript's current version.
;filemname = string representation of a .ahk path
;shortcutName = string of the new shortcut to add to the main file
;shortcutList = a comma seperated string of shortcut's already in use
JPGIncCombine(fileName, shortcutName, shortcutList)
{	
	;get the current version of the program
	FileInstall, c:\programming\projects\WinScript\WinScriptMainCurrent.ahk, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk", 1
	IfNotExist, % A_scriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
	{	MsgBox, , JPGInc ERROR, ERROR WinScriptMainCurrent Does not exist!, 2
		return "error"
	}
	FileRead, mainFile, % A_scriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
	FileRead, newFile, % fileName
	JPGIncInsertScript(mainFile, newFile, shortcutName, shortcutList)
	if(JPGIncRecompile(mainFile))
	{	return
	}
	renameAndQuit()
	return
}

JPGIncInsertScript(ByRef mainFile, ByRef newFile, shortcutName, shortcutList)
{	;replace JPGIncNewName with the new shortcut name and insert it in the "script" part
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
	mainFile := mainFile newFile
	return
}

;looks to see how many previous versions have been saved and saves the current version as a backup
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
renameAndQuit()
{	IfExist, tempBat.bat
	{	FileDelete, tempBat.bat
	}
batFile =
(
ping 127.0.0.1
del "%A_ScriptFullPath%"
move /Y "%A_scriptDir%\newExe.exe" "%A_scriptDir%\JPGInc WinScript.exe"
"%A_scriptDir%\JPGInc WinScript.exe"
exit
)
	FileAppend, % batFile, tempBat.bat
	Run, tempBat.bat, , Hide
	ExitApp
}

#if JPGIncMode == "remove"
JPGIncRemove:
{	isCancelled := 0
	BlockInput, off
	;get a shortcut for the new script
	Loop
	{	InputBox, removeScriptName, Enter Script Shortcut:
		if(isCancelled := errorlevel)
		{	break
		}
		removeScriptName = %removeScriptName%
		if(removeScriptName == "" && isCancelled := 1)
		{	break
		}
		IfNotInString, JPGIncShortcuts, % removeScriptName ","
		{	MsgBox, , JPGInc ERROR, ERROR Shortcut does not exist
			continue
		}
		if(removeScriptName == "i" || removeScriptName == "add" || removeScriptName == "remove")
		{	MsgBox, , JPGInc ERROR, ERROR That shortcut cannot be removed!
			continue
		}
		isCancelled := JPGIncRemove(removeScriptName, JPGIncShortcuts)
		break
	}
	if(isCancelled)
	{	SplashTextOn, , , Cancelled
		sleep 500
		SplashTextOff
	}
	BlockInput, on
	JPGIncMode := "script"
	return	
}

JPGIncRemove(removeScriptName, JPGIncShortcuts)
{	FileInstall, C:\Programming\Projects\WinScript\WinScriptMainCurrent.ahk, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk", 1
	IfNotExist, % A_scriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
	{	MsgBox, , JPGInc ERROR, ERROR WinScriptMainCurrent Does not exist!, 2
		return "error"
	}
	FileRead, currentFile, % A_ScriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
	StringReplace, newShortcuts, JPGIncShortcuts, % removeScriptName ","
	StringReplace, currentFile, currentFile, % JPGIncShortcuts, % newShortcuts
	theStart := RegExMatch(currentfile, ";start short " removeScriptName ":")
	theEnd := RegExMatch(currentfile, "P);end short " removeScriptName ":", length)
	currentFile := SubStr(currentFile, 1, theStart - 1) SubStr(currentFile, theEnd + length)
	theStart := RegExMatch(currentfile, ";start " removeScriptName ":")
	theEnd := RegExMatch(currentfile, "P);end " removeScriptName ":", length)
	currentFile := SubStr(currentFile, 1, theStart - 1) SubStr(currentFile, theEnd + length)
	if(JPGIncRecompile(currentFile))
	{	return
	}
	renameAndQuit()
	return
}

JPGIncRecompile(ByRef newFileString)
{	oldDirectory := "FileInstall, c:\programming\projects\WinScript"
	StringReplace, newFileString, newFileString, % oldDirectory, % "FileInstall, " A_ScriptDir "\WinScriptData", All
	FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler\Ahk2Exe.exe, % A_ScriptDir "\WinScriptData\Ahk2Exe.exe"
	FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler\ANSI 32-bit.bin, % A_ScriptDir "\WinScriptData\ANSI 32-bit.bin"
	FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler\AutoHotkeySC.bin, % A_ScriptDir "\WinScriptData\AutoHotkeySC.bin"
	FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler\Unicode 32-bit.bin, % A_ScriptDir "\WinScriptData\Unicode 32-bit.bin"
	FileInstall, C:\Program Files (x86)\AutoHotkey\Compiler\Unicode 64-bit.bin, % A_ScriptDir "\WinScriptData\Unicode 64-bit.bin"
	backupCurrent()
	FileAppend, % newFileString, % A_scriptDir "\WinScriptData\WinScriptMainCurrent.ahk"
	RunWait, % A_ScriptDir "\WinScriptData\Ahk2Exe.exe /in " A_scriptDir "\WinScriptData\WinScriptMainCurrent.ahk /out newExe.exe"
	Run, newExe.exe, , UseErrorLevel, newExePid
	sleep, 1000
	IfWinExist, ahk_pid %newExePid% ahk_class #32770 
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
;end main: