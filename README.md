# xinput
An XInput wrapper for the [Monkey programming language](https://github.com/blitz-research/monkey).

### Description:
This module provides a "raw device" interface to the XInput API. This is not a replacement for Mojo's input functionality, but it could be used as a backend. Data is provided as it's read from XInput, so this isn't Mojo-compatible.

This is only for supported *Windows* targets. Testing has been done with the GLFW and STDCPP (C++ Tool) targets. There are no prerequisites when installing this module. As long as the host computer has some kind of XInput redistributable installed, this will use it (*Most Windows installations do*). No need to distribute the DLLs yourself, just plug and play.

#### TODO:
* *Add rumble support.*

**If you're interested in improving this module, feel free to make a pull request.**
