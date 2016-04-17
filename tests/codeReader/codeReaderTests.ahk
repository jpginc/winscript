filePath := A_WorkingDir "\includerScript.ahk"
FileRead, expected, expected.txt
expected := RegExReplace(expected, "\R", "`n")
reader := new JPGIncCodeReader(filePath)
code := RegExReplace(reader.readCode(), "\R", "`n")

if(code != expected)
{
	Clipboard := "actual:`n" code "`nexpected:`n" expected
	msgbox % "failed readCode `ncodeLength: " strlen(code) "`nexpected lenght: " strlen(expected)
}
if(reader.removeIncludes("#include test`n;#include asdf") != "`n;#include asdf")
{
	MsgBox % "failed remove includes`n" reader.removeIncludes("#include test`n;#include asdf")
}
if(reader.getDir(filePath) != A_WorkingDir "\")
{
	MsgBox, % "failed getDir`n" reader.getDir(filePath)
}

if(reader.getAbsolutePath("include1.ahk") != A_WorkingDir "\include1.ahk")
{
	MsgBox, % "failed getAbsolutePath`n" reader.getAbsolutePath("include1.ahk")
}

if(reader.getAbsolutePath(A_WorkingDir "\include1.ahk") != A_WorkingDir "\include1.ahk")
{
	MsgBox, % "failed getAbsolutePath`n" reader.getAbsolutePath("include1.ahk")
}	

if(reader.removeComment("abc `;def") != "abc ")
{
	MsgBox "remove comment failed"
}
ExitApp
#Include ..\..\Addons\codeReader.ahk
