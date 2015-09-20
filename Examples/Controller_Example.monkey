Strict

Public

' Preprocessor related:
'#XINPUT_DEMO_CLEAR_STDOUT = True

' Imports:
Import xinput

#If XINPUT_DEMO_CLEAR_STDOUT
	Import ioutil.stdio
#End

Import brl.process

' Functions:
Function Main:Int()
	XInputInit()
	
	#If XINPUT_DEMO_CLEAR_STDOUT
		Local Console:= New StandardIOStream()
	#End
	
	Local Gamepad:= New XInputDevice(0)
	
	For Local I:= 0 Until XUSER_MAX_COUNT
		If (XInputDevice.DevicePluggedIn(I)) Then
			Print("Device["+I+"]: Available")
		Endif
	Next
	
	If (Gamepad.PluggedIn) Then
		Print("Device found.")
		
		Repeat
			If (Gamepad.Detect()) Then
				#If XINPUT_DEMO_CLEAR_STDOUT
					Console.Clear()
				#End
				
				Local Buttons:= Gamepad.Buttons
				
				Print("Buttons: " + Buttons)
				Print("Left: " + Gamepad.ThumbLX + ", " + Gamepad.ThumbLY)
				Print("Right: " + Gamepad.ThumbRX + ", " + Gamepad.ThumbRY)
				Print("Triggers: " + Gamepad.LeftTrigger + ", " + Gamepad.RightTrigger)
				Print("------------------")
				
				Local LMotor:Int ' = Int(Float(Gamepad.LeftTrigger / XINPUT_GAMEPAD_TRIGGER_MAX) * 65535)
				Local RMotor:Int ' = Int(Float(Gamepad.RightTrigger / XINPUT_GAMEPAD_TRIGGER_MAX) * 65535)
				
				If (Gamepad.LeftTrigger = XINPUT_GAMEPAD_TRIGGER_MAX) Then
					LMotor = 65535
				Endif
				
				If (Gamepad.RightTrigger = XINPUT_GAMEPAD_TRIGGER_MAX) Then
					RMotor = 65535
				Endif
				
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