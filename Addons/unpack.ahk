unpack()
{	SetWorkingDir, % A_ScriptDir
	IfNotExist, Addons
	{	FileCreateDir, Addons
	}
	recompiler := new recompiler()
	beforeFlag := recompiler.getBeforeFlag()
	afterFlag := recompiler.getAfterFlag()
	source := recompiler.getRunningCode()
	fileName := ""
	warnings := ""
	
	Loop, parse, source, `n, `r
	{	if(RegExMatch(A_loopfield, "m)^" beforeFlag))
		{	filename := RegExReplace(A_loopfield, "m)^" beforeFlag "(.*)", "$1")
			IfNotInString, fileName, .
			{	filename .= ".ahk"
			}
			IfExist, Addons\%fileName%
			{	warnings .= fileName "`n"
				filename := "" ;dont append to an already existing file
			}
			continue
		}
		if(RegExMatch(A_loopfield, "m)^" afterFlag))
		{	filename := ""
		}
		if(filename != "")
		{	FileAppend, % A_loopfield "`r`n", Addons\%filename%
		}
	}
	if(warnings)
	{	MsgBox, , JPGInc Warning, Warning the following files already existed and were not unpacked`n%warnings%
	} else
	{	MsgBox, , JPGInc Success, Files unpacked successfully
	}
	return
}