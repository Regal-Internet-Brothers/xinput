Strict

Public

' Preprocessor related:
#If HOST = "winnt" And LANG = "cpp" And TARGET <> "win8" And TARGET <> "winrt"
	#XINPUT_IMPLEMENTED = True
#End

#If XINPUT_IMPLEMENTED
	' Enabled by default; toggles Mojo compatibility utilities.
	#XINPUT_MOJO_COMPATIBILITY_API = True
	
	' This toggles Mojo Z-axis mapping similar to the GLFW targets.
	'#XINPUT_MOJO_COMPATIBILITY_API_GLFW_ACCURACY = True
	'#XINPUT_STD_HEADER = True
	
	' Imports (Public):
	#If Not XINPUT_STD_HEADER And LANG = "cpp"
		Import "native/xinput_header.${LANG}" ' ".cpp"
	#End
	
	Import "native/xinput.${LANG}"
	
	' Imports (Private):
	Private
	
	#If XINPUT_MOJO_COMPATIBILITY_API
		'Import mojo.input
		Import mojo.keycodes
	#End
	
	Public
	
	' External bindings:
	Extern
	
	' Constant variable(s):
	
	' Macros (IMMUTABLE, DO NOT MODIFY):
	Global XUSER_MAX_COUNT:Int
	Global XUSER_INDEX_ANY:Int
	
	Global XINPUT_GAMEPAD_THUMB_MAX:Int
	Global XINPUT_GAMEPAD_TRIGGER_MAX:Int
	Global XINPUT_GAMEPAD_RUMBLE_MAX:Int
	
	' Buttons:
	Global XINPUT_GAMEPAD_DPAD_UP:Int
	Global XINPUT_GAMEPAD_DPAD_DOWN:Int
	Global XINPUT_GAMEPAD_DPAD_LEFT:Int
	Global XINPUT_GAMEPAD_DPAD_RIGHT:Int
	
	Global XINPUT_GAMEPAD_START:Int
	Global XINPUT_GAMEPAD_BACK:Int
	
	Global XINPUT_GAMEPAD_LEFT_THUMB:Int
	Global XINPUT_GAMEPAD_RIGHT_THUMB:Int
	
	Global XINPUT_GAMEPAD_LEFT_SHOULDER:Int
	Global XINPUT_GAMEPAD_RIGHT_SHOULDER:Int
	
	Global XINPUT_GAMEPAD_GUIDE:Int
	
	Global XINPUT_GAMEPAD_A:Int
	Global XINPUT_GAMEPAD_B:Int
	Global XINPUT_GAMEPAD_X:Int
	Global XINPUT_GAMEPAD_Y:Int
	
	' Classes:
	Class BBXInputDevice="xinput_external::BBXInputDevice"
		' Functions:
		Function devicePluggedIn:Bool(Index:Int, Force:Bool=False)
		Function forceResetVibration:Void()
		
		' Constructor(s):
		Method init:Bool(Index:Int=XUSER_INDEX_ANY, Force:Bool=False)
		
		' Methods:
		Method detect:Bool()
		
		Method setMotors:Void(Left:Int, Right:Int)
		Method resetMotors:Void()
		
		Method pluggedIn:Bool()
		
		Method buttons:Int()
		Method previousButtons:Int()
		
		Method leftTrigger:Int()
		Method rightTrigger:Int()
		
		Method thumbLX:Int()
		Method thumbLY:Int()
		
		Method thumbRX:Int()
		Method thumbRY:Int()
		
		' Fields:
		' Nothing so far.
	End
	
	' Functions:
	Function XInputInit:Void()="xinput_external::XInputInit"
	Function XInputDeinit:Void()="xinput_external::XInputDeinit"
	
	Public
	
	' Monkey:
	
	' Aliases:
	
	' Constant variable(s):
	
	' These are used with 'GetRawAxis', which is mainly
	' useful for the Mojo compatibility API.
	Const XINPUT_CHANNEL_X:= 0
	Const XINPUT_CHANNEL_Y:= 1
	Const XINPUT_CHANNEL_Z:= 2
	
	' Classes:
	Class XInputDevice
		' Functions:
		Function DevicePluggedIn:Bool(Index:Int, Force:Bool=False)
			Return BBXInputDevice.devicePluggedIn(Index, Force)
		End
		
		Function ForceResetVibration:Void()
			BBXInputDevice.forceResetVibration()
			
			Return
		End
		
		' Mojo compatibility API:
		#If XINPUT_MOJO_COMPATIBILITY_API
			' This command converts 'Value' into a ratio usign 'Max'. (Used internally)
			Function ConvertToMojoAxis:Float(Value:Int, Max:Int)
				Return (Float(Value) / Float(Max))
			End
			
			' This command converts a Mojo joypad code into an XInput button.
			Function ConvertMojoButton:Int(MojoButton:Int)
				Select MojoButton
					Case JOY_A
						Return XINPUT_GAMEPAD_A
					Case JOY_B
						Return XINPUT_GAMEPAD_B
					Case JOY_X
						Return XINPUT_GAMEPAD_X
					Case JOY_Y
						Return XINPUT_GAMEPAD_Y
					Case JOY_LB
						Return XINPUT_GAMEPAD_LEFT_SHOULDER
					Case JOY_RB
						Return XINPUT_GAMEPAD_RIGHT_SHOULDER
					Case JOY_BACK
						Return XINPUT_GAMEPAD_BACK
					Case JOY_START
						Return XINPUT_GAMEPAD_START
					Case JOY_LEFT
						Return XINPUT_GAMEPAD_DPAD_LEFT
					Case JOY_UP
						Return XINPUT_GAMEPAD_DPAD_UP
					Case JOY_RIGHT
						Return XINPUT_GAMEPAD_DPAD_RIGHT
					Case JOY_DOWN
						Return XINPUT_GAMEPAD_DPAD_DOWN
					Case JOY_LSB
						Return XINPUT_GAMEPAD_LEFT_THUMB
					Case JOY_RSB
						Return XINPUT_GAMEPAD_RIGHT_THUMB
					Case JOY_MENU
						Return XINPUT_GAMEPAD_GUIDE
				End Select
				
				Return 0
			End
		#End
		
		' Constructor(s):
		Method New(Index:Int=XUSER_INDEX_ANY)
			bbDevice = New BBXInputDevice()
			
			If (Not bbDevice.init(Index)) Then
				Throw New XInput_InvalidDeviceParameters(Self)
			Endif
		End
		
		' Methods:
		Method Detect:Bool()
			Return bbDevice.detect()
		End
		
		Method ButtonDown:Bool(Button:Int)
			Return ((Buttons & Button) > 0)
		End
		
		Method ButtonHit:Bool(Button:Int)
			Return (((PreviousButtons & Button) > 0) And Not ButtonDown(Button))
		End
		
		Method SetRumble:Void(Left:Int, Right:Int)
			bbDevice.setMotors(Left, Right)
			
			Return
		End
		
		Method ResetRumble:Void()
			bbDevice.resetMotors()
			
			Return
		End
		
		' This command provides a "dynamic" way of accessing the axis properties. (Useful for Mojo compatibility)
		Method GetRawAxis:Int(Channel:Int=0, Axis:Int=0, ControllerID:Int=0)
			Select Channel
				Case XINPUT_CHANNEL_X
					Select Axis
						Case 0
							Return ThumbLX
						Case 1
							Return ThumbRX
					End Select
				Case XINPUT_CHANNEL_Y
					Select Axis
						Case 0
							Return ThumbLY
						Case 1
							Return ThumbRY
					End Select
				Case XINPUT_CHANNEL_Z
					Select Axis
						Case 0
							Return LeftTrigger
						Case 1
							Return RightTrigger
					End Select
			End Select
			
			Return 0
		End
		
		' Mojo compatibility API:
		#If XINPUT_MOJO_COMPATIBILITY_API
			' These commands function similarly to Mojo's input APIs:
			Method JoyX:Float(Axis:Int=0)
				Return ConvertToMojoAxis(GetRawAxis(XINPUT_CHANNEL_X, Axis), XINPUT_GAMEPAD_THUMB_MAX)
			End
			
			Method JoyY:Float(Axis:Int=0)
				Return ConvertToMojoAxis(GetRawAxis(XINPUT_CHANNEL_Y, Axis), XINPUT_GAMEPAD_THUMB_MAX)
			End
			
			Method JoyZ:Float(Axis:Int=0)
				#If XINPUT_MOJO_COMPATIBILITY_API_GLFW_ACCURACY
					Return (ConvertToMojoAxis(GetRawAxis(XINPUT_CHANNEL_Z, Axis), XINPUT_GAMEPAD_TRIGGER_MAX) -
							ConvertToMojoAxis(GetRawAxis(XINPUT_CHANNEL_Z, (Axis+1) Mod 2), XINPUT_GAMEPAD_TRIGGER_MAX))
				#Else
					Return ConvertToMojoAxis(GetRawAxis(XINPUT_CHANNEL_Z, Axis), XINPUT_GAMEPAD_TRIGGER_MAX)
				#End
			End
			
			' These commands require Mojo joy-codes as inputs:
			Method JoyHit:Int(MojoButton:Int)
				Return Int(ButtonHit(ConvertMojoButton(MojoButton)))
			End
			
			Method JoyDown:Int(MojoButton:Int)
				Return Int(ButtonDown(ConvertMojoButton(MojoButton)))
			End
		#End
		
		' Properties:
		Method PluggedIn:Bool() Property
			Return bbDevice.pluggedIn()
		End
		
		Method Buttons:Int() Property
			Return bbDevice.buttons()
		End
		
		Method PreviousButtons:Int() Property
			Return bbDevice.previousButtons()
		End
		
		Method LeftTrigger:Int() Property
			Return bbDevice.leftTrigger()
		End
		
		Method RightTrigger:Int() Property
			Return bbDevice.rightTrigger()
		End
		
		Method ThumbLX:Int() Property
			Return bbDevice.thumbLX()
		End
		
		Method ThumbLY:Int() Property
			Return bbDevice.thumbLY()
		End
		
		Method ThumbRX:Int() Property
			Return bbDevice.thumbRX()
		End
		
		Method ThumbRY:Int() Property
			Return bbDevice.thumbRY()
		End
		
		' Fields:
		Field bbDevice:BBXInputDevice
	End
	
	Class XInput_InvalidDeviceParameters Extends Throwable
		' Constructor(s):
		Method New(Gamepad:XInputDevice=Null)
			Self.Gamepad = Gamepad
		End
		
		' Methods:
		Method ToString:String() ' Property
			Return "Unable to allocate native device."
		End
		
		' Fields:
		Field Gamepad:XInputDevice
	End
#End