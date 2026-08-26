# x--------------------------------------------------------------------------x #
# | SDL3 Bindings in Mojo
# x--------------------------------------------------------------------------x #
# | Simple DirectMedia Layer
# | Copyright (C) 1997-2025 Sam Lantinga <slouken@libsdl.org>
# |
# | This software is provided 'as-is', without any express or implied
# | warranty.  In no event will the authors be held liable for any damages
# | arising from the use of this software.
# |
# | Permission is granted to anyone to use this software for any purpose,
# | including commercial applications, and to alter it and redistribute it
# | freely, subject to the following restrictions:
# |
# | 1. The origin of this software must not be misrepresented; you must not
# |    claim that you wrote the original software. If you use this software
# |    in a product, an acknowledgment in the product documentation would be
# |    appreciated but is not required.
# | 2. Altered source versions must be plainly marked as such, and must not be
# |    misrepresented as being the original software.
# | 3. This notice may not be removed or altered from any source distribution.
# x--------------------------------------------------------------------------x #

"""Power.

SDL power management routines.

There is a single function in this category: SDL_GetPowerInfo().

This function is useful for games on the go. This allows an app to know if
it's running on a draining battery, which can be useful if the app wants to
reduce processing, or perhaps framerate, to extend the duration of the
battery's charge. Perhaps the app just wants to show a battery meter when
fullscreen, or alert the user when the power is getting extremely low, so
they can save their game.
"""

from std.ffi import _get_dylib_function, c_int
from ._core import Ptr, lib


from std.ffi import _get_dylib_function, c_int
from ._core import Ptr, lib


struct PowerState(Indexer, Intable, TrivialRegisterPassable):
    """The basic state for the system's power supply.

    These are results returned by SDL_GetPowerInfo().

    Docs: https://wiki.libsdl.org/SDL3/SDL_PowerState.
    """

    var value: UInt32

    @always_inline
    def __init__(out self, value: Int):
        self.value = UInt32(value)

    @always_inline
    def __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    def __eq__(lhs, rhs: Self) -> Bool:
        return lhs.value == rhs.value

    @always_inline("nodebug")
    def __mlir_index__(self) -> __mlir_type.index:
        return __mlir_op.`pop.cast_to_builtin`[_type=__mlir_type.index](Int(self)._mlir_value)

    comptime POWERSTATE_ERROR = Self(-1)
    """Error determining power status."""
    comptime POWERSTATE_UNKNOWN = Self(0)
    """Cannot determine power status."""
    comptime POWERSTATE_ON_BATTERY = Self(1)
    """Not plugged in, running on the battery."""
    comptime POWERSTATE_NO_BATTERY = Self(2)
    """Plugged in, no battery available."""
    comptime POWERSTATE_CHARGING = Self(3)
    """Plugged in, charging battery."""
    comptime POWERSTATE_CHARGED = Self(4)
    """Plugged in, battery charged."""


def get_power_info[O_seconds: Origin, O_percent: Origin, //](seconds: Ptr[c_int, O_seconds], percent: Ptr[c_int, O_percent]) raises -> PowerState:
    """Get the current power supply details.

    You should never take a battery status as absolute truth. Batteries
    (especially failing batteries) are delicate hardware, and the values
    reported here are best estimates based on what that hardware reports. It's
    not uncommon for older batteries to lose stored power much faster than it
    reports, or completely drain when reporting it has 20 percent left, etc.

    Battery status can change at any time; if you are concerned with power
    state, you should call this function frequently, and perhaps ignore changes
    until they seem to be stable for a few seconds.

    It's possible a platform can only report battery percentage or time left
    but not both.

    On some platforms, retrieving power supply details might be expensive. If
    you want to display continuous status you could call this function every
    minute or so.

    Args:
        seconds: A pointer filled in with the seconds of battery life left,
                 or NULL to ignore. This will be filled in with -1 if we
                 can't determine a value or there is no battery.
        percent: A pointer filled in with the percentage of battery life
                 left, between 0 and 100, or NULL to ignore. This will be
                 filled in with -1 we can't determine a value or there is no
                 battery.

    Returns:
        The current battery state or `SDL_POWERSTATE_ERROR` on failure;
        call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPowerInfo.
    """

    return _get_dylib_function[lib, "SDL_GetPowerInfo", def(seconds: Ptr[c_int, O_seconds], percent: Ptr[c_int, O_percent]) thin abi("C") -> PowerState]()(seconds, percent)
