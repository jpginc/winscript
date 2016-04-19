;~ inputClass := new input_class("")
;~ tempp := inputClass.getLine("hi")
;~ MsgBox % tempp.string " " tempp.value
;~ inputClass.setInputHandler("builtInStyle")
;~ tempp := inputClass.getLine("hi", {"block": false})
;~ MsgBox % tempp.string " " tempp.value
;~ ExitApp
;/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
class EditInput
{
 guiName := ""
 threadNumber := 0
 
 __new()
 {
  ;generate a random gui name
  Random, guiName, 100, 1000000
  ;a number can't be a gui name
  this.guiName := guiName "a"
  this.__inputGui(this.guiName)
  return this
 }
 
  __inputGui(guiName) 
 {
  Gui %guiName%: destroy
  Gui %guiName%: new
  ;two rows so that it accepts the newline character
  Gui %guiName%: add, Edit, r2 w100 WantTab
  Gui %guiName%: -Caption -SysMenu +ToolWindow
  Gui %guiName%: show, h0 w0 NA, % guiName
  return
 }
 
 getChar(existingString, settings := false)
 {
  newString := ""
  threadNumber := this.threadNumber
  inputValue := ""
  guiName := this.guiName
  if(! winactive(guiName))
  {
   WinShow, % guiName
  }
  ;give the contents of the edit box a value so we can capture the backspace and delete button
  if(existingString == "")
  {
   GuiControl, %guiName%:, Edit1,
  } 
  GuiControlGet, existingValue, %guiName%:, Edit1
  while(true)
  {	
   if(threadNumber != this.threadNumber)
   {	
    inputValue := "cancelled"
    break
   }
   GuiControlGet, inputValue, %guiName%:, Edit1
   if(inputValue != existingValue || existingString != existingValue)
   {
    existingString := inputValue
    ;check if the user hit backspace
    if(strlen(inputValue) < strlen(existingValue))
    {
     inputValue := "backspace"
     break
    }
    inputValue := RegExReplace(inputValue, existingString)
    break
   }
   ;check if the gui was closed by alt+f4 or something similar
   IfWinNotExist, %guiName%
   {
    inputValue := "cancelled"
    break
   }
   ;check if the gui has lost focus by alt+tab or something similar
  
   IfWinNotActive, %guiName%
   {
    waitModifierKeys()
    this.focusEdit()
   }
  
  if(GetKeyState("esc", "P"))
  { 
   inputValue := "cancelled"
   break
  }
 }
  return {"string": existingString, "value": inputValue}
 }
 
 focusEdit()
 {
  guiName := this.guiName
  WinActivate, %guiName%
  GuiControlGet, focused, %guiName%: Focus
  if(focused != "Edit1")
  { 
   guicontrol, focus, %guiName%: Edit1
  }
  return
 }
 
 cancel()
 {
  ;~ guiName := this.guiName
  WinHide, % this.guiName
  this.threadNumber++
  return
 }
 
 unBlocckable()
 {
  return false
 }
  __Delete()
 {
  guiName := this.guiName
  Gui %guiName%: Destroy
  return
 }
}
;/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
class BuiltInInput
{
 isActive := false
 
 __new()
 {
  return this
 }
 
 /* Gets one character from the keyboard. 
 *
 * You can use this input style to get input without stealing the keystrokes from the active window
 * by setting the second paramater to an object {"block": false}
 *
 * If you use this method to get a line of input you can miss characters if the user
 * is typing too quickly as foucus isn't kept between getChar calls...
 *
 * @return value an object who's keys:
 *  "currentString": the string that was passed to the function + one character (or minus one character is backspace was pressed),
 *  "value": the one character OR "cancelled" if input was cancelled OR "backspace" if backspace was pressed
 */
 getChar(existingString, settings := false)
 {	
  this.isActive := true
  inputValue := ""
  ;if the user doesn't supply any settings then use the default settings
  if(settings == false)
  {
   block := "" 
  } else
  {
   ;keystrokes will be sent to the active window
   block := "V" 
  } 
  Loop
  {
   ;get one character of input
   input, inputValue, L1 %block%,{Esc}{BackSpace}{enter}{Lalt}{RAlt}{Lctrl}{RCtrl}{LWin}{RWin}
   if(ErrorLevel == "EndKey:Escape" || ErrorLevel == "NewInput")
   {
    inputValue := "cancelled"
    break
   } else if(ErrorLevel == "EndKey:Backspace")
   { 	
    StringTrimRight, existingString, existingString, 1
    inputValue := "backspace"
    break
   } else if(ErrorLevel == "EndKey:Enter")
   {	
    inputValue := "`n"
    existingString := existingString inputValue
    break
   } else if(InStr(errorLevel, "EndKey:"))
   {	
    StringReplace, keyName, ErrorLevel, EndKey:
    if(block == "") 
    {
     ;if input was blocked then we need to send the key
     send {%keyName% down}
    }
    waitModifierKeys()
    continue
   }
   existingString := existingString inputValue
   break
  }
  this.isActive := false
  return {"string": existingString, "value": inputValue}
 }
 
 unBlockable()
 {
  return true
 }
 
 cancel()
 {
  if(this.isActive)
  {
   this.isActive := false
   ;running the input command will cancel any other input's waiting
   Input, notNeeded, T0.00001
  }
  return
 }
}
;/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
/*
 *
 */
class input_class
{
 ;contains classes that handle input differently
 handlers := {"builtInStyle": new BuiltInInput(), "editStyle": new EditInput()}
 ;the class selected for use
 currentHandler := this.handlers.editStyle
 
 __new()
 {	
  return this
 }
/*
 *  If the user has specified settings that the current input handler doesn't accept then the built in
 *  style handler is used
 *  
 *  otherwise the current handler is returned
 */
 __getHandler(settings)
 {
  if(settings != false)
  {
   if(settings.block == false && ! this.currentHandler.unBlockable())
   {
    return this.handlers.builtInStyle
   }
  }
  return this.currentHandler
 }
/*
 *  Get a character from the user
 *
 * @currentString (optional)
 *  if the user presses backspace then keep track will be returned
 *  with one less character
 *
 * @settings
 * an object where the following keys have meaning
 *      "block" with the value false sends the input to to active window
 *
 * returns an object with the following keys:
 *  "currentString": the string that was passed to the function + one character (or minus one character is backspace was pressed),
 *  "value": the one character OR "cancelled" if input was cancelled OR "backspace" if backspace was pressed
 *  
 */
 getCharacter(currentString := "", settings := false)
 {
  return this.getChar(currentString, settings)
 }
 getChar(currentString := "", settings := false)
 {	
  ;~ this.cancel()
  currentHandler := this.__getHandler(settings)
  return currentHandler.getChar(currentString, settings)
 }
 
/*
 *  calls getChar until it reaches a newline character
 *
 * @currentString (optional)
 *  if the user presses backspace then keep track will be returned
 *  with one less character
 *
 * @settings
 * an object where the following keys have meaning
 *      "block" with the value false sends the input to to active window
 *
 * returns an object with the keys:
 *  "currentString" contains the string when the user pressed enter or cancelled the input
 *  "value" contains "`n" if the user pressed enter OR "cancelled" if input was cancelled
 */
 getLine(currentString := "", settings := false)
 {
  this.cancel()
  currentHandler := this.__getHandler(settings)
  while(true)
  {	
   inputObj := currentHandler.getChar(currentString, settings)
   if(inputObj.value == "cancelled" || inputObj.value == "`n")
   {
    return inputObj
   } else
   {
    ToolTip, % inputObj.string " " inputObj.value
    currentString := inputObj.string
   }
  }
 }
 
 /*
  * sets the current input handler to the given name
  * 
  * @param name 
  * a string key, either builtInStyle, editStyle or a name that was added using addInputHandler
  *
  * returns true on success 
  * returns false if the handler doesn't exist
  */
 setInputHandler(newType)
 {
  if(this.handlers[newType])
  {
   this.currentHandler := this.handlers[newType]
   return true
  }
  return false
 }
 
 /*
  * adds the given input handler, overwriting another handler with name if it exists
  * optionally sets the given input handler as the current input handler (to be used for future calls)
  *
  * returns true if the handler was added successfully
  * returns false if the handler didn't have the required functions (and wasn't added)
  */
 addInputHandler(newInputHandler, name, setAsDefault := false)
 {
  if(this.implementsInputFunctions(newInputHandler)) {
   this.handlers[name] := newInputHandler
   if(setAsDefault) {
    this.currentHandler := this.handlers[name]
   }
   return true
  }
  return false
 }
/*
 *  returns true if and input handler with the given name exists
 */
 inputHandlerExists(name)
 {
  if(this.handlers[name])
  {
   return true
  } 
  return false
 }
/*
 *  cancels any input that might be active
 */
 cancel()
 {
  for key, val in this.handlers 
  {
   val.cancel()
  }
  return
 }
 
 /*
  * checks to make sure that the given variable has the expected functions of an input handler
  *
  * returns true if toTest has the required functions
  * returns false otherwise
  */
 implementsInputFunctions(toTest)
 {
  functions := ["getChar", "cancel", "unBlockable"]
  for key, functionName in functions
  {
   if(! IsFunc(toTest[functionName]))
   {
    return false
   }
  }
  return true
 }
}
waitModifierKeys()
{	
 KeyWait, Control
 KeyWait, Alt
 KeyWait, LWin
 KeyWait, rWin
 KeyWait, LButton
 KeyWait, RButton
 KeyWait, MButton
 return
}
