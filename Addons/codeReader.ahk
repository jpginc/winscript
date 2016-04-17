/*
 * reads an ahk file and it's include directives
 * Doesn't read includeAgain's
 * Doesn't read library includes files
 */
class JPGIncCodeReader
{
	pathToRootFile := ""
	
	__new(pathToRootFile)
	{
		this.pathToRootFile := pathToRootFile
		this.workingDir := this.getDir(pathToRootFile)
		return this
	}
	
	getDir(path) 
	{
		loop, % path
		{
			return, A_LoopFileDir "\"
		}
		return ""
	}
	
	readCode() 
	{
		filesToLoad := [this.getAbsolutePath(this.pathToRootFile)]
		code := ""
		while true 
		{
			if(! filesToLoad[A_Index])
			{
				break
			}
			
			file := this.readFile(filesToLoad[A_Index])
			code .= file "`n"
			this.getIncludes(file, filesToLoad)
		}
		
		return code
	}
	
	readFile(file) 
	{
		FileRead, contents, % file
		return contents
	}
	
	getIncludes(code, toLoadArray)
	{
		pos := 1
		
		while true 
		{
			foundAt := RegExMatch(code, "`aOim)^#include (.*)$", include, pos)
			if(! include.Count()) 
			{
				return
			}
			path := this.getAbsolutePath(this.removeComment(include.value(1)))
			if(! this.arrayContains(toLoadArray, path))
			{
				toLoadArray.Insert(path)
			}
			pos := foundAt + include.len(1)
		}
	}
	
	removeComment(str) 
	{
		;more efficient then stringsplit
		loop, parse, str, `;
		{
			return A_LoopField
		}
		return str
	}
	
	arrayContains(array, value) 
	{
		Loop, % array.maxIndex()
		{
			if(array[A_Index] == value)
			{
				return true
			}
		}
		return false
	}
	
	getAbsolutePath(path)
	{
		IfExist, % path
		{
			Loop, % path
			{
				return A_LoopFileLongPath
			}
		}
		IfExist, % this.workingDir path
		{
			return this.workingDir path
		}
		return path
	}
}