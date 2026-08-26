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

"""Hints.

This file contains functions to set and get configuration hints, as well as
listing each of them alphabetically.

The convention for naming hints is SDL_HINT_X, where "SDL_X" is the
environment variable that can be used to override the default.

In general these hints are just that - they may or may not be supported or
applicable on any given platform, but they provide a way for an application
or user to give the library a hint as to how they would like the library to
work.
"""

from std.ffi import _get_dylib_function, c_char
from ._core import OptPtr, Ptr, c_string, lib
from .sdl_error import get_error


from std.ffi import _get_dylib_function, c_char
from ._core import OptPtr, Ptr, c_string, lib
from .sdl_error import get_error


struct HintPriority(Indexer, Intable, TrivialRegisterPassable):
    """An enumeration of hint priorities.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HintPriority.
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

    comptime HINT_DEFAULT = Self(0)
    comptime HINT_NORMAL = Self(1)
    comptime HINT_OVERRIDE = Self(2)


def set_hint_with_priority(var name: String, var value: String, priority: HintPriority) raises:
    """Set a hint with a specific priority.

    The priority controls the behavior when setting a hint that already has a
    value. Hints will replace existing hints of their priority and lower.
    Environment variables are considered to have override priority.

    Args:
        name: The hint to set.
        value: The value of the hint variable.
        priority: The SDL_HintPriority level for the hint.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetHintWithPriority.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetHintWithPriority", def(name: Ptr[mut=False, c_char, origin_of(name)], value: Ptr[mut=False, c_char, origin_of(value)], priority: HintPriority) thin abi("C") -> Bool]()(name.as_c_string_slice().ptr(), value.as_c_string_slice().ptr(), priority)
    if not _ffi_ret:
        raise Error(get_error())


def set_hint(var name: String, var value: String) raises:
    """Set a hint with normal priority.

    Hints will not be set if there is an existing override hint or environment
    variable that takes precedence. You can use SDL_SetHintWithPriority() to
    set the hint with override priority instead.

    Args:
        name: The hint to set.
        value: The value of the hint variable.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetHint.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetHint", def(name: Ptr[mut=False, c_char, origin_of(name)], value: Ptr[mut=False, c_char, origin_of(value)]) thin abi("C") -> Bool]()(name.as_c_string_slice().ptr(), value.as_c_string_slice().ptr())
    if not _ffi_ret:
        raise Error(get_error())


def reset_hint(var name: String) raises:
    """Reset a hint to the default value.

    This will reset a hint to the value of the environment variable, or NULL if
    the environment isn't set. Callbacks will be called normally with this
    change.

    Args:
        name: The hint to set.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ResetHint.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_ResetHint", def(name: Ptr[mut=False, c_char, origin_of(name)]) thin abi("C") -> Bool]()(name.as_c_string_slice().ptr())
    if not _ffi_ret:
        raise Error(get_error())


def reset_hints() raises -> None:
    """Reset all hints to the default values.

    This will reset all hints to the value of the associated environment
    variable, or NULL if the environment isn't set. Callbacks will be called
    normally with this change.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ResetHints.
    """

    return _get_dylib_function[lib, "SDL_ResetHints", def() thin abi("C") -> None]()()


def get_hint(var name: String) raises -> String:
    """Get the value of a hint.

    Args:
        name: The hint to query.

    Returns:
        The string value of a hint or NULL if the hint isn't set.

    Safety:
        It is safe to call this function from any thread, however the
        return value only remains valid until the hint is changed; if
        another thread might do so, the app should supply locks
        and/or make a copy of the string. Note that using a hint
        callback instead is always thread-safe, as SDL holds a lock
        on the thread subsystem during the callback.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetHint.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetHint", def(name: Ptr[mut=False, c_char, origin_of(name)]) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(name.as_c_string_slice().ptr()).value())


def get_hint_boolean(var name: String, default_value: Bool) raises -> Bool:
    """Get the boolean value of a hint variable.

    Args:
        name: The name of the hint to get the boolean value from.
        default_value: The value to return if the hint does not exist.

    Returns:
        The boolean value of a hint or the provided default value if the
        hint does not exist.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetHintBoolean.
    """

    return _get_dylib_function[lib, "SDL_GetHintBoolean", def(name: Ptr[mut=False, c_char, origin_of(name)], default_value: Bool) thin abi("C") -> Bool]()(name.as_c_string_slice().ptr(), default_value)


comptime HintCallback = def(userdata: OptPtr[NoneType, UntrackedOrigin[mut=True]], name: OptPtr[c_char, UntrackedOrigin[mut=False]], old_value: OptPtr[c_char, UntrackedOrigin[mut=False]], new_value: OptPtr[c_char, UntrackedOrigin[mut=False]]) thin abi("C") -> None
"""A callback used to send notifications of hint value changes.
    
    This is called an initial time during SDL_AddHintCallback with the hint's
    current value, and then again each time the hint's value changes.
    
    Args:
        userdata: What was passed as `userdata` to SDL_AddHintCallback().
        name: What was passed as `name` to SDL_AddHintCallback().
        old_value: The previous hint value.
        new_value: The new value hint is to be set to.
    
    Safety:
        This callback is fired from whatever thread is setting a new
        hint value. SDL holds a lock on the hint subsystem when
        calling this callback.

Docs: https://wiki.libsdl.org/SDL3/SDL_HintCallback.
"""


def add_hint_callback[O_userdata: Origin, //](var name: String, callback: HintCallback, userdata: Ptr[NoneType, O_userdata]) raises:
    """Add a function to watch a particular hint.

    The callback function is called _during_ this function, to provide it an
    initial value, and again each time the hint's value changes.

    Args:
        name: The hint to watch.
        callback: An SDL_HintCallback function that will be called when the
                  hint value changes.
        userdata: A pointer to pass to the callback function.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AddHintCallback.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_AddHintCallback", def(name: Ptr[mut=False, c_char, origin_of(name)], callback: HintCallback, userdata: Ptr[NoneType, O_userdata]) thin abi("C") -> Bool]()(name.as_c_string_slice().ptr(), callback, userdata)
    if not _ffi_ret:
        raise Error(get_error())


def remove_hint_callback[O_userdata: Origin, //](var name: String, callback: HintCallback, userdata: Ptr[NoneType, O_userdata]) raises -> None:
    """Remove a function watching a particular hint.

    Args:
        name: The hint being watched.
        callback: An SDL_HintCallback function that will be called when the
                  hint value changes.
        userdata: A pointer being passed to the callback function.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RemoveHintCallback.
    """

    return _get_dylib_function[lib, "SDL_RemoveHintCallback", def(name: Ptr[mut=False, c_char, origin_of(name)], callback: HintCallback, userdata: Ptr[NoneType, O_userdata]) thin abi("C") -> None]()(name.as_c_string_slice().ptr(), callback, userdata)
