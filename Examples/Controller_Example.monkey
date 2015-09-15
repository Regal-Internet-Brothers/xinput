Strict

Public

' Imports:
Import xinput

Import time

' Functions:
Function Main:Int()
	XInputInit()
	
	Local Gamepad:= New XInputDevice(0)
	
	Repeat
		If (Gamepad.Detect()) Then
			Print("Device packet received.")
			
			Local Buttons:= Gamepad.Buttons
			
			Print("Button state: " + Buttons)
			
			If (((Buttons & XINPUT_GAMEPAD_START) > 0) And ((Buttons & XINPUT_GAMEPAD_BACK) > 0)) Then
				Exit
			Endif
		Endif
		
		Delay(16)
	Forever
	
	XInputDeinit()
	
	' Return the default response.
	Return 0
End