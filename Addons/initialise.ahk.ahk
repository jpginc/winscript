#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
process, Exist
run, %A_AhkPath% "recompiler.ahk" "4" "%ErrorLevel%" "/a" "main" "default" "recompile"