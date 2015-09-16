Strict

Public

' Imports:
Import xinput

Import brl.process

' Functions:
Function Main:Int()
	XInputInit()
	
	Local Gamepad:= New XInputDevice(0)
	
	If (Gamepad.PluggedIn) Then
		Print("Device found.")
		
		Repeat
			If (Gamepad.Detect()) Then
				Local Buttons:= Gamepad.Buttons
				
				Print("Buttons: " + Buttons)
				Print("Left: " + Gamepad.ThumbLX + ", " + Gamepad.ThumbLY)
				Print("Right: " + Gamepad.ThumbRX + ", " + Gamepad.ThumbRY)
				Print("Triggers: " + Gamepad.LeftTrigger + ", " + Gamepad.RightTrigger)
				Print("------------------")
				
				Local LMotor:= Int(Float(Gamepad.LeftTrigger / 255) * 65535)
				Local RMotor:= Int(Float(Gamepad.RightTrigger / 255) * 65535)
				
				Gamepad.SetRumble(LMotor, RMotor)
				
				If (((Buttons & XINPUT_GAMEPAD_START) > 0) And ((Buttons & XINPUT_GAMEPAD_BACK) > 0)) Then
					Exit
				Endif
			Endif
			
			Sleep(16)
		Forever
		
		Gamepad.ResetRumble()
	Else
		Print("Unable to find device.")
	Endif
	
	XInputDeinit()
	
	' Return the default response.
	Return 0
End