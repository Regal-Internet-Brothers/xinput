Strict

Public

' Preprocessor related:
#XINPUT_IMPLEMENTED = True

#If HOST = "winnt" And LANG = "cpp" And TARGET <> "win8" And TARGET <> "winrt"
	#XINPUT_IMPLEMENTED = True
#End

#If XINPUT_IMPLEMENTED
	'#XINPUT_STD_HEADER = True
	
	' Imports:
	#If Not XINPUT_STD_HEADER And LANG = "cpp"
		Import "native/xinput_header.${LANG}" ' ".cpp"
	#End
	
	Import "native/xinput.${LANG}"
	
	' External bindings:
	Extern
	
	' Constant variable(s):
	
	' Button macros (IMMUTABLE, DO NOT MODIFY):
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
		' Constructor(s):
		Method init:Bool(Index:Int)="init"
		
		' Methods:
		Method detect:Bool()
		
		Method setMotors:Void(Left:Int, Right:Int)
		Method resetMotors:Void()
		
		Method buttons:Int()
		
		Method leftTrigger:Int()
		Method rightTrigger:Int()
		
		Method thumbLX:Int()
		Method thumbLY:Int()
		
		Method thumbRX:Int()
		Method thumbRY:Int()
		
		' Fields:
		Field pluggedIn:Bool
	End
	
	' Functions:
	Function XInputInit:Void()="xinput_external::XInputInit"
	Function XInputDeinit:Void()="xinput_external::XInputDeinit"
	
	Public
	
	' Monkey:
	Class XInputDevice
		' Constructor(s) (Public):
		Method New(Index:Int)
			bbDevice = New BBXInputDevice()
			
			If (Not bbDevice.init(Index)) Then
				Throw New XInput_InvalidDeviceParameters(Self)
			Endif
		End
		
		' Constructor(s) (Private):
		Private
		
		Method New()
			' Blank implementation; reserved.
		End
		
		Public
		
		' Methods:
		Method Detect:Bool()
			Return bbDevice.detect()
		End
		
		Method SetRumble:Void(Left:Int, Right:Int)
			bbDevice.setMotors(Left, Right)
			
			Return
		End
		
		Method ResetRumble:Void()
			bbDevice.resetMotors()
			
			Return
		End
		
		' Properties:
		Method PluggedIn:Bool() Property
			Return bbDevice.pluggedIn
		End
		
		Method Buttons:Int() Property
			Return bbDevice.buttons()
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