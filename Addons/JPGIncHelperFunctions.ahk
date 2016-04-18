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