
// xinput.h:

/*
	Dynamic linker-layer for XInput, providing support for all
	versions of XInput up to version 1.4 automatically. (Support may vary)
	
	This implementation allows use of the 'XInputGetStateEx' extension when available.
	
	The "dynamic linker" portion of this source code is based off of the IOSync project.
*/

// Includes:
#ifdef CFG_XINPUT_STD_HEADER
	#include <XInput.h>
#endif

#include <windef.h>

// Macros:
#define XINPUT_MAX_SUBVERSION 4
#define XINPUT_DLL_NAMELENGTH  16 // xinput1_4.dll

#define XINPUT_COMPATIBILITY_DLL "xinput9_1_0.dll"

// Other:
#define XINPUT_GAMEPAD_THUMB_MAX 32768
#define XINPUT_GAMEPAD_TRIGGER_MAX 255
#define XINPUT_GAMEPAD_RUMBLE_MAX 65535

// Buttons:
#define XINPUT_GAMEPAD_GUIDE			0x0400

// Namespace(s):
namespace xinput_external
{
	// Typedefs:
	
	// Function types:
	typedef VOID (WINAPI *_XInputEnable_t)(BOOL);
	typedef DWORD (WINAPI *_XInputSetState_t)(DWORD, PXINPUT_VIBRATION);
	typedef DWORD (WINAPI *_XInputGetState_t)(DWORD, PXINPUT_STATE);
	typedef DWORD (WINAPI *_XInputGetCapabilities_t)(DWORD, DWORD, PXINPUT_CAPABILITIES);
	typedef DWORD (WINAPI *_XInputGetStateEx_t)(DWORD, PXINPUT_STATE);
	
	//typedef DWORD WINAPI (*XInputGetBatteryInformation_t)(DWORD, BYTE, PXINPUT_BATTERY_INFORMATION);
	//typedef DWORD WINAPI (*XInputGetKeystroke_t)(DWORD, DWORD, PXINPUT_KEYSTROKE);
	//typedef DWORD WINAPI (*XInputGetAudioDeviceIds_t)(DWORD, LPWSTR, PUINT, LPWSTR, PUINT);
	
	// Function prototypes:
	
	// XInput API:
	VOID WINAPI XInputEnable(BOOL enable);
	DWORD WINAPI XInputSetState(DWORD dwUserIndex, PXINPUT_VIBRATION pVibration);
	DWORD WINAPI XInputGetState(DWORD dwUserIndex, PXINPUT_STATE pState);
	DWORD WINAPI XInputGetCapabilities(DWORD dwUserIndex, DWORD dwFlags, PXINPUT_CAPABILITIES pCapabilities);
	DWORD WINAPI XInputGetStateEx(DWORD dwUserIndex, PXINPUT_STATE pState);
	
	/*
		DWORD WINAPI XInputGetBatteryInformation(DWORD dwUserIndex, BYTE devType, PXINPUT_BATTERY_INFORMATION battery);
		DWORD WINAPI XInputGetKeystroke(DWORD dwUserIndex, DWORD dwReserved, PXINPUT_KEYSTROKE pKeyStroke);
		DWORD WINAPI XInputGetAudioDeviceIds(DWORD dwUserIndex, LPWSTR pRenderDeviceId, PUINT renderCount, LPWSTR captureDeviceId, PUINT captureCount);
	*/
	
	// Linker related:
	LPCSTR XInputGetStateEx_Ordinal();
	
	void linkTo(HMODULE hDLL);
	
	HMODULE linkTo(LPCSTR DLL_Location);
	HMODULE linkTo();
	
	void XInputInit();
	void XInputDeinit();
	
	// Classes:
	class BBXInputDevice : public Object
	{
		public:
			// Functions:
			static bool devicePluggedIn(XINPUT_CAPABILITIES* capabilities, int index, bool force=false);
			static bool devicePluggedIn(int index, bool force=false);
			
			static void forceResetVibration();
			
			// Fields:
			int userIndex; // DWORD
			
			XINPUT_STATE state;
			XINPUT_STATE previousState;
			XINPUT_CAPABILITIES capabilities;
			
			// Booleans / Flags:
			int deviceIn; // unsigned
			
			// Constructor(s):
			BBXInputDevice();
			
			virtual bool init(int index=XUSER_INDEX_ANY, bool force=false);
			
			// Methods:
			bool detect();
			
			void setMotors(int left, int right);
			void resetMotors();
			
			bool pluggedIn() const;
			
			int buttons() const;
			int previousButtons() const;
			
			int leftTrigger() const;
			int rightTrigger() const;
			
			int thumbLX() const;
			int thumbLY() const;
			
			int thumbRX() const;
			int thumbRY() const;
	};
}

// xinput.cpp:

// Includes:
//#include "xinput.h"

#include <cstdio> // stdio.h

// Namespace(s):
namespace xinput_external
{
	// Global variable(s):
	HMODULE XInputModule;
	
	bool deviceStatus[XUSER_MAX_COUNT]; // 4
	bool hadRealRepresentative[XUSER_MAX_COUNT]; // 4
	
	// Functions pointers:
	_XInputEnable_t _XInputEnable;
	_XInputSetState_t _XInputSetState;
	_XInputGetState_t _XInputGetState;
	_XInputGetCapabilities_t _XInputGetCapabilities;
	_XInputGetStateEx_t _XInputGetStateEx;
	
	// Classes:
	
	// BBXInputDevice:
	
	// Functions:
	bool BBXInputDevice::devicePluggedIn(XINPUT_CAPABILITIES* capabilities, int index, bool force)
	{
		// Check for errors:
		if (index < 0 || index > XUSER_MAX_COUNT)
		{
			return false;
		}
		
		if (force || !deviceStatus[index])
		{
			//*capabilities = XINPUT_CAPABILITIES();
			
			if (XInputGetCapabilities((DWORD)index, XINPUT_FLAG_GAMEPAD, capabilities) != ERROR_DEVICE_NOT_CONNECTED)
			{
				// If for some reason we were given a non-gamepad device, stop executing:
				if (capabilities->Type != XINPUT_DEVTYPE_GAMEPAD)
				{
					return false;
				}
				
				deviceStatus[index] = true;
			}
			else
			{
				return false; // response = false;
			}
		}
		
		// Return the default response.
		return true;
	}
	
	bool BBXInputDevice::devicePluggedIn(int index, bool force)
	{
		XINPUT_CAPABILITIES capabilities = XINPUT_CAPABILITIES();
		
		return devicePluggedIn(&capabilities, index, force);
	}
	
	void BBXInputDevice::forceResetVibration()
	{
		XINPUT_VIBRATION vibration = XINPUT_VIBRATION();
		
		for (DWORD dwUserIndex = 0; dwUserIndex < XUSER_MAX_COUNT; dwUserIndex++)
		{
			if (deviceStatus[dwUserIndex])
			{
				XInputSetState(dwUserIndex, &vibration);
			}
		}
		
		return;
	}
	
	// Constructor(s):
	BBXInputDevice::BBXInputDevice()
		: userIndex(-1), deviceIn(-1), state(), previousState(), capabilities() // nullptr
	{
		// Nothing so far.
	}
	
	bool BBXInputDevice::init(int index, bool force)
	{
		if (index == (int)XUSER_INDEX_ANY)
		{
			for (index = 0; index < XUSER_MAX_COUNT; index++)
			{
				if (devicePluggedIn(index) && !hadRealRepresentative[index])
				{
					break;
				}
			}
			
			// Check if we weren't able to find an empty slot:
			if (index >= XUSER_MAX_COUNT)
			{
				index = 0;
			}
		}
		
		if (!devicePluggedIn(&capabilities, index, force))
		{
			return false;
		}
		
		deviceIn = index;
		userIndex = index;
		
		hadRealRepresentative[index] = true; // deviceIn;
		
		// Return the default response.
		return true;
	}
	
	// Methods:
	bool BBXInputDevice::detect()
	{
		previousState = state;
		
		state = XINPUT_STATE();
		
		if (XInputGetStateEx((DWORD)userIndex, &state) == ERROR_SUCCESS)
		{
			if (state.dwPacketNumber != previousState.dwPacketNumber)
			{
				return true;
			}
		}
		
		// Return the default response.
		return false;
	}
	
	void BBXInputDevice::setMotors(int left, int right)
	{
		XINPUT_VIBRATION vibration = XINPUT_VIBRATION();
		
		vibration.wLeftMotorSpeed = left;
		vibration.wRightMotorSpeed = right;
		
		XInputSetState(userIndex, &vibration);
		
		return;
	}
	
	void BBXInputDevice::resetMotors()
	{
		setMotors(0, 0);
		
		return;
	}
	
	bool BBXInputDevice::pluggedIn() const
	{
		if (deviceIn == -1)
		{
			return false;
		}
		
		return deviceStatus[deviceIn];
	}
	
	int BBXInputDevice::buttons() const
	{
		return (int)state.Gamepad.wButtons;
	}
	
	int BBXInputDevice::previousButtons() const
	{
		return (int)previousState.Gamepad.wButtons;
	}
	
	int BBXInputDevice::leftTrigger() const
	{
		return (int)state.Gamepad.bLeftTrigger;
	}
	
	int BBXInputDevice::rightTrigger() const
	{
		return (int)state.Gamepad.bRightTrigger;
	}
	
	int BBXInputDevice::thumbLX() const
	{
		return (int)state.Gamepad.sThumbLX;
	}
	
	int BBXInputDevice::thumbLY() const
	{
		return (int)state.Gamepad.sThumbLY;
	}
	
	int BBXInputDevice::thumbRX() const
	{
		return (int)state.Gamepad.sThumbRX;
	}
	
	int BBXInputDevice::thumbRY() const
	{
		return (int)state.Gamepad.sThumbRY;
	}
	
	// Functions:
	
	// XInput API:
	VOID WINAPI XInputEnable(BOOL enable)
	{
		if (_XInputEnable != NULL)
		{
			_XInputEnable(enable);
		}
		
		return;
	}
	
	DWORD WINAPI XInputSetState(DWORD dwUserIndex, PXINPUT_VIBRATION pVibration)
	{
		if (_XInputSetState != NULL)
		{
			return _XInputSetState(dwUserIndex, pVibration);
		}
		
		return ERROR_DEVICE_NOT_CONNECTED;
	}
	
	DWORD WINAPI XInputGetState(DWORD dwUserIndex, PXINPUT_STATE pState)
	{
		if (_XInputGetState != NULL)
		{
			return _XInputGetState(dwUserIndex, pState);
		}
		
		return ERROR_DEVICE_NOT_CONNECTED;
	}
	
	DWORD WINAPI XInputGetCapabilities(DWORD dwUserIndex, DWORD dwFlags, PXINPUT_CAPABILITIES pCapabilities)
	{
		if (_XInputGetCapabilities != NULL)
		{
			return _XInputGetCapabilities(dwUserIndex, dwFlags, pCapabilities);
		}
		
		return ERROR_DEVICE_NOT_CONNECTED;
	}
	
	DWORD WINAPI XInputGetStateEx(DWORD dwUserIndex, PXINPUT_STATE pState)
	{
		if (_XInputGetStateEx != NULL)
		{
			return _XInputGetStateEx(dwUserIndex, pState);
		}
		
		return ERROR_DEVICE_NOT_CONNECTED;
	}
	
	/*
		DWORD WINAPI XInputGetBatteryInformation(DWORD dwUserIndex, BYTE devType, PXINPUT_BATTERY_INFORMATION battery);
		DWORD WINAPI XInputGetKeystroke(DWORD dwUserIndex, DWORD dwReserved, PXINPUT_KEYSTROKE pKeyStroke);
		DWORD WINAPI XInputGetAudioDeviceIds(DWORD dwUserIndex, LPWSTR pRenderDeviceId, PUINT renderCount, LPWSTR captureDeviceId, PUINT captureCount);
	*/
	
	// Linker related:
	LPCSTR XInputGetStateEx_Ordinal()
	{
		return (LPCSTR)100;
	}
	
	void linkTo(HMODULE hDLL)
	{
		_XInputEnable = (_XInputEnable_t)GetProcAddress(hDLL, "XInputEnable");
		_XInputSetState = (_XInputSetState_t)GetProcAddress(hDLL, "XInputSetState");
		_XInputGetState = (_XInputGetState_t)GetProcAddress(hDLL, "XInputGetState");
		_XInputGetCapabilities = (_XInputGetCapabilities_t)GetProcAddress(hDLL, "XInputGetCapabilities");
		
		/*
			_XInputGetBatteryInformation = (_XInputGetBatteryInformation_t)GetProcAddress(hDLL, "XInputGetBatteryInformation");
			_XInputGetKeystroke = (_XInputGetKeystroke_t)GetProcAddress(hDLL, "XInputGetKeystroke");
			_XInputGetAudioDeviceIds = (_XInputGetAudioDeviceIds_t)GetProcAddress(hDLL, "XInputGetAudioDeviceIds");
		*/
		
		// Attempt to get the hidden 'XInputGetStateEx' function.
		_XInputGetStateEx = (_XInputGetStateEx_t)GetProcAddress(hDLL, XInputGetStateEx_Ordinal());
		
		// Check if we were able to find it:
		if (_XInputGetStateEx == NULL)
		{
			// Try getting the function normally (Normally doesn't work):
			_XInputGetStateEx = (_XInputGetStateEx_t)GetProcAddress(hDLL, "XInputGetStateEx");

			if (_XInputGetStateEx == NULL)
			{
				// If all else fails, attach to the standard version.
				_XInputGetStateEx = _XInputGetState;
			}
		}
		
		return;
	}
	
	HMODULE linkTo(LPCSTR DLL_Location)
	{
		HMODULE library = LoadLibraryA(DLL_Location);

		if (library == NULL)
			return NULL;

		// Call the main implementation using the loaded module.
		linkTo(library);

		// Return the loaded module.
		return library;
	}
	
	HMODULE link()
	{
		using namespace std;
		
		// Not the most efficient, but it works:
		char DLLName[XINPUT_DLL_NAMELENGTH];
		
		for (unsigned i = XINPUT_MAX_SUBVERSION; i >= 0; i--)
		{
			if (i == 0)
			{
				sprintf(DLLName, XINPUT_COMPATIBILITY_DLL);
			}
			else
			{
				sprintf(DLLName, "xinput1_%d.dll", i);
			}
			
			HMODULE module = linkTo(DLLName);
			
			if (module != NULL)
			{
				return module;
			}
			
			//sprintf(DLLName, "xinput1_%d.dll", i);
		}

		return NULL;
	}
	
	void XInputInit()
	{
		if (XInputModule != NULL)
		{
			return;
		}
		
		XInputModule = link();
		
		XInputEnable(TRUE);
		
		return;
	}
	
	void XInputDeinit()
	{
		if (XInputModule == NULL)
			return;
		
		// Ensure we don't still have vibrating controllers.
		BBXInputDevice::forceResetVibration();
		
		FreeLibrary(XInputModule);
		
		XInputModule = NULL;
		
		// Function pointers:
		_XInputEnable = NULL;
		_XInputSetState = NULL;
		_XInputGetState = NULL;
		_XInputGetCapabilities = NULL;
		
		/*
			_XInputGetBatteryInformation = NULL;
			_XInputGetKeystroke = NULL;
			_XInputGetAudioDeviceIds = NULL;
		*/
		
		_XInputGetStateEx = NULL;
		
		return;
	}
}
