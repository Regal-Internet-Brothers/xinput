
/*
	Based on the official "XInput.h" Windows SDK header, and the official MSDN documentation.
	This file is provided for compatibility purposes.
*/

// Preprocessor related:

// Includes:
#include <windef.h>

// API macros:

// Device types (Used with 'XINPUT_CAPABILITIES'):
#define XINPUT_DEVTYPE_GAMEPAD 0x01

// Device sub-types (Used with 'XINPUT_CAPABILITIES'):
#define XINPUT_DEVSUBTYPE_GAMEPAD 0x01

// Flags used with 'XINPUT_CAPABILITIES':
#define XINPUT_CAPS_VOICE_SUPPORTED 0x0004

// Flags used with 'XInputGetCapabilities':
#define XINPUT_FLAG_GAMEPAD 0x00000001

// Button macros (Bitwise):
#define XINPUT_GAMEPAD_DPAD_UP          0x0001
#define XINPUT_GAMEPAD_DPAD_DOWN        0x0002
#define XINPUT_GAMEPAD_DPAD_LEFT        0x0004
#define XINPUT_GAMEPAD_DPAD_RIGHT       0x0008
#define XINPUT_GAMEPAD_START            0x0010
#define XINPUT_GAMEPAD_BACK             0x0020
#define XINPUT_GAMEPAD_LEFT_THUMB       0x0040
#define XINPUT_GAMEPAD_RIGHT_THUMB      0x0080
#define XINPUT_GAMEPAD_LEFT_SHOULDER    0x0100
#define XINPUT_GAMEPAD_RIGHT_SHOULDER   0x0200
#define XINPUT_GAMEPAD_A                0x1000
#define XINPUT_GAMEPAD_B                0x2000
#define XINPUT_GAMEPAD_X                0x4000
#define XINPUT_GAMEPAD_Y                0x8000

// Gamepad thresholds:
#define XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  7849
#define XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE 8689
#define XINPUT_GAMEPAD_TRIGGER_THRESHOLD    30

// Other:
#define XINPUT_GAMEPAD_THUMB_MAX 32768
#define XINPUT_GAMEPAD_TRIGGER_MAX 255

// User-index definitions:
#define XUSER_MAX_COUNT 4
#define XUSER_INDEX_ANY 0x000000FF

// Structures:
typedef struct _XINPUT_GAMEPAD
{
	WORD wButtons;
	
	BYTE bLeftTrigger;
	BYTE bRightTrigger;
	
	SHORT sThumbLX;
	SHORT sThumbLY;
	SHORT sThumbRX;
	SHORT sThumbRY;
} XINPUT_GAMEPAD, *PXINPUT_GAMEPAD;

typedef struct _XINPUT_STATE
{
	DWORD dwPacketNumber;
	
	XINPUT_GAMEPAD Gamepad;
} XINPUT_STATE, *PXINPUT_STATE;

typedef struct _XINPUT_VIBRATION
{
	WORD wLeftMotorSpeed;
	WORD wRightMotorSpeed;
} XINPUT_VIBRATION, *PXINPUT_VIBRATION;

typedef struct _XINPUT_CAPABILITIES
{
	BYTE Type;
	BYTE SubType;
    WORD Flags;
    
    XINPUT_GAMEPAD Gamepad;
    XINPUT_VIBRATION Vibration;
} XINPUT_CAPABILITIES, *PXINPUT_CAPABILITIES;
