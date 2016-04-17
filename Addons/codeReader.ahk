/*
 * reads an ahk file and it's include directives
 * Doesn't read includeAgain's
 * Doesn't read library includes files
 */
class JPGIncCodeReader
{
	pathToRootFile := ""
	loadedFiles := []
	
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
		this.loadedFiles := []
		return this._readCode(this.getAbsolutePath(this.pathToRootFile))
	}
	
	_readCode(path, existing := "")
	{
		if(this._fileIsAlreadyIncluded(path))
		{
			return ""
		}
		fileContents := this.loadFile(path)
		

		includes := this._getIncludes(fileContents)
		existing .= this.removeIncludes(fileContents) "`n"
		
		loop, % includes.maxIndex()
		{
			existing .= this._readCode(includes[A_Index])
		}
		
		return existing
	}
	
	loadFile(path)
	{
		path := this.getAbsolutePath(path)
		this.loadedFiles.insert(path)
		FileRead, fileContents, % path
		return fileContents
	}

	removeIncludes(fileContents)
	{
		return RegExReplace(fileContents, "`aOim)^#include .+$")
	}
	
	_getIncludes(fileContents)
	{
		pos := 1
		includes := []
		
		while true 
		{
			foundAt := RegExMatch(fileContents, "`aOim)^#include (.+)$", include, pos)
			if(! include.Count()) 
			{
				return includes
			}
			
			includes.insert(this.getAbsolutePath(this.removeComment(include.value(1))))
			
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
	
	_fileIsAlreadyIncluded(path) 
	{
		path := this.getAbsolutePath(path)
		Loop, % this.loadedFiles.maxIndex()
		{
			if(this.loadedFiles[A_Index] == path)
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