# xinput

## Description
An XInput wrapper for the [Monkey programming language](https://github.com/blitz-research/monkey).

This module provides both a "raw device" interface to the XInput API, and a Mojo compatibility API. This is not a replacement for Mojo's input functionality. Normally, data is provided as it's read from XInput.

**This is only for supported *Windows* targets. Testing has been done with the GLFW and STDCPP (C++ Tool) targets.**

### Mojo Compatibility:
Optionally, a Mojo compatibility API is provided, for the sake of supporting XInput in your own game. It's not perfect, and certainly not a proper '[InputDevice](https://github.com/blitz-research/monkey/blob/develop/modules/mojo/inputdevice.monkey)', but it's useful. **This is not the original API**, it only provides equivalent behavior.

### XInput Redistribution:
There are no prerequisites when installing this module. As long as the host computer has some kind of XInput redistributable installed, this will use it (*Most Windows installations have this through Windows Update*; XP SP1+, Vista+, etc). No need to distribute the DLLs yourself, just plug and play.

**If you're interested in improving this module, feel free to make a pull request.**

## Installation
This module is officially distributed with the [Regal Modules](https://github.com/Regal-Internet-Brothers/regal-modules#regal-modules) project. To install this module, please follow the installation guide provided with that repository.
