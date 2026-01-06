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

"""Hints

This file contains functions to set and get configuration hints, as well as
listing each of them alphabetically.

The convention for naming hints is SDL_HINT_X, where "SDL_X" is the
environment variable that can be used to override the default.

In general these hints are just that - they may or may not be supported or
applicable on any given platform, but they provide a way for an application
or user to give the library a hint as to how they would like the library to
work.
"""


@register_passable("trivial")
struct HintPriority(Indexer, Intable):
    """An enumeration of hint priorities.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HintPriority.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __eq__(lhs, rhs: Self) -> Bool:
        return lhs.value == rhs.value

    @always_inline("nodebug")
    fn __mlir_index__(self) -> __mlir_type.index:
        return Int(self)._mlir_value

    comptime HINT_DEFAULT = Self(0)
    comptime HINT_NORMAL = Self(1)
    comptime HINT_OVERRIDE = Self(2)


fn set_hint_with_priority(var name: String, var value: String, priority: HintPriority) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetHintWithPriority", fn (name: Ptr[c_char, AnyOrigin[False]], value: Ptr[c_char, AnyOrigin[False]], priority: HintPriority) -> Bool]()(name.as_c_string_slice().unsafe_ptr(), value.as_c_string_slice().unsafe_ptr(), priority)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_hint(var name: String, var value: String) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetHint", fn (name: Ptr[c_char, AnyOrigin[False]], value: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(name.as_c_string_slice().unsafe_ptr(), value.as_c_string_slice().unsafe_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn reset_hint(var name: String) raises:
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

    ret = _get_dylib_function[lib, "SDL_ResetHint", fn (name: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(name.as_c_string_slice().unsafe_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn reset_hints() raises -> None:
    """Reset all hints to the default values.

    This will reset all hints to the value of the associated environment
    variable, or NULL if the environment isn't set. Callbacks will be called
    normally with this change.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ResetHints.
    """

    return _get_dylib_function[lib, "SDL_ResetHints", fn () -> None]()()


fn get_hint(var name: String) raises -> Ptr[c_char, AnyOrigin[False]]:
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

    return _get_dylib_function[lib, "SDL_GetHint", fn (name: Ptr[c_char, AnyOrigin[False]]) -> Ptr[c_char, AnyOrigin[False]]]()(name.as_c_string_slice().unsafe_ptr())


fn get_hint_boolean(var name: String, default_value: Bool) raises -> Bool:
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

    return _get_dylib_function[lib, "SDL_GetHintBoolean", fn (name: Ptr[c_char, AnyOrigin[False]], default_value: Bool) -> Bool]()(name.as_c_string_slice().unsafe_ptr(), default_value)


comptime HintCallback = fn (userdata: Ptr[NoneType, AnyOrigin[True]], name: Ptr[c_char, AnyOrigin[False]], old_value: Ptr[c_char, AnyOrigin[False]], new_value: Ptr[c_char, AnyOrigin[False]]) -> None
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


fn add_hint_callback(var name: String, callback: HintCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_AddHintCallback", fn (name: Ptr[c_char, AnyOrigin[False]], callback: HintCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) -> Bool]()(name.as_c_string_slice().unsafe_ptr(), callback, userdata)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn remove_hint_callback(var name: String, callback: HintCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) raises -> None:
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

    return _get_dylib_function[lib, "SDL_RemoveHintCallback", fn (name: Ptr[c_char, AnyOrigin[False]], callback: HintCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) -> None]()(name.as_c_string_slice().unsafe_ptr(), callback, userdata)
