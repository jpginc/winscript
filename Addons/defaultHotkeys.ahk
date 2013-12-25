﻿;JPGIncWinscriptFlag Start defaultHotkeys
#If
;Capslock + Esc exits the program
~CapsLock & Esc::
~Esc & CapsLock::
{	KeyWait capslock
	KeyWait esc
	SetCapsLockState, off
	ExitApp
}

;the default keys to enter 'script' mode are shift and capslock together
~shift & CapsLock::
~CapsLock & Shift::
{	KeyWait shift
	KeyWait capslock
	SetCapsLockState, off
	GlobalController.enterScriptMode()
	return
}
;clicking a mouse button by default will leave script mode
~LButton::
~RButton::
~MButton::
{	GlobalController.mouseClick()
	return
}
;
~Esc::
{	GlobalController.esc()
	return
}
;JPGIncWinscriptFlag End defaultHotkeys