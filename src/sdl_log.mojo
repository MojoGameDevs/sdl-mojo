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

"""Log

Simple log messages with priorities and categories. A message's
SDL_LogPriority signifies how important the message is. A message's
SDL_LogCategory signifies from what domain it belongs to. Every category
has a minimum priority specified: when a message belongs to that category,
it will only be sent out if it has that minimum priority or higher.

SDL's own logs are sent below the default priority threshold, so they are
quiet by default.

You can change the log verbosity programmatically using
SDL_SetLogPriority() or with SDL_SetHint(SDL_HINT_LOGGING, ...), or with
the "SDL_LOGGING" environment variable. This variable is a comma separated
set of category=level tokens that define the default logging levels for SDL
applications.

The category can be a numeric category, one of "app", "error", "assert",
"system", "audio", "video", "render", "input", "test", or `*` for any
unspecified category.

The level can be a numeric level, one of "trace", "verbose", "debug",
"info", "warn", "error", "critical", or "quiet" to disable that category.

You can omit the category if you want to set the logging level for all
categories.

If this hint isn't set, the default log levels are equivalent to:

`app=info,assert=warn,test=verbose,*=error`

Here's where the messages go on different platforms:

- Windows: debug output stream
- Android: log output
- Others: standard error output (stderr)

You don't need to have a newline (`\n`) on the end of messages, the
functions will do that for you. For consistent behavior cross-platform, you
shouldn't have any newlines in messages, such as to log multiple lines in
one call; unusual platform-specific behavior can be observed in such usage.
Do one log call per line instead, with no newlines in messages.

Each log call is atomic, so you won't see log messages cut off one another
when logging from multiple threads.
"""


@register_passable("trivial")
struct LogCategory(Indexer, Intable):
    """The predefined log categories.

    By default the application and gpu categories are enabled at the INFO
    level, the assert category is enabled at the WARN level, test is enabled at
    the VERBOSE level and all other categories are enabled at the ERROR level.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LogCategory.
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

    comptime LOG_CATEGORY_APPLICATION = Self(0)
    comptime LOG_CATEGORY_ERROR = Self(1)
    comptime LOG_CATEGORY_ASSERT = Self(2)
    comptime LOG_CATEGORY_SYSTEM = Self(3)
    comptime LOG_CATEGORY_AUDIO = Self(4)
    comptime LOG_CATEGORY_VIDEO = Self(5)
    comptime LOG_CATEGORY_RENDER = Self(6)
    comptime LOG_CATEGORY_INPUT = Self(7)
    comptime LOG_CATEGORY_TEST = Self(8)
    comptime LOG_CATEGORY_GPU = Self(9)

    # Reserved for future SDL library use
    comptime LOG_CATEGORY_RESERVED2 = Self(10)
    comptime LOG_CATEGORY_RESERVED3 = Self(11)
    comptime LOG_CATEGORY_RESERVED4 = Self(12)
    comptime LOG_CATEGORY_RESERVED5 = Self(13)
    comptime LOG_CATEGORY_RESERVED6 = Self(14)
    comptime LOG_CATEGORY_RESERVED7 = Self(15)
    comptime LOG_CATEGORY_RESERVED8 = Self(16)
    comptime LOG_CATEGORY_RESERVED9 = Self(17)
    comptime LOG_CATEGORY_RESERVED10 = Self(18)

    # Beyond this point is reserved for application use, e.g.
    #        enum {
    #            MYAPP_CATEGORY_AWESOME1 = SDL_LOG_CATEGORY_CUSTOM,
    #            MYAPP_CATEGORY_AWESOME2,
    #            MYAPP_CATEGORY_AWESOME3,
    #            ...
    #        };
    comptime LOG_CATEGORY_CUSTOM = Self(19)


@register_passable("trivial")
struct LogPriority(Indexer, Intable):
    """The predefined log priorities.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LogPriority.
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

    comptime LOG_PRIORITY_INVALID = Self(0)
    comptime LOG_PRIORITY_TRACE = Self(1)
    comptime LOG_PRIORITY_VERBOSE = Self(2)
    comptime LOG_PRIORITY_DEBUG = Self(3)
    comptime LOG_PRIORITY_INFO = Self(4)
    comptime LOG_PRIORITY_WARN = Self(5)
    comptime LOG_PRIORITY_ERROR = Self(6)
    comptime LOG_PRIORITY_CRITICAL = Self(7)
    comptime LOG_PRIORITY_COUNT = Self(8)


fn set_log_priorities(priority: LogPriority) raises -> None:
    """Set the priority of all log categories.

    Args:
        priority: The SDL_LogPriority to assign.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetLogPriorities.
    """

    return _get_dylib_function[lib, "SDL_SetLogPriorities", fn (priority: LogPriority) -> None]()(priority)


fn set_log_priority(category: c_int, priority: LogPriority) raises -> None:
    """Set the priority of a particular log category.

    Args:
        category: The category to assign a priority to.
        priority: The SDL_LogPriority to assign.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetLogPriority.
    """

    return _get_dylib_function[lib, "SDL_SetLogPriority", fn (category: c_int, priority: LogPriority) -> None]()(category, priority)


fn get_log_priority(category: c_int) raises -> LogPriority:
    """Get the priority of a particular log category.

    Args:
        category: The category to query.

    Returns:
        The SDL_LogPriority for the requested category.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetLogPriority.
    """

    return _get_dylib_function[lib, "SDL_GetLogPriority", fn (category: c_int) -> LogPriority]()(category)


fn reset_log_priorities() raises -> None:
    """Reset all priorities to default.

    This is called by SDL_Quit().

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ResetLogPriorities.
    """

    return _get_dylib_function[lib, "SDL_ResetLogPriorities", fn () -> None]()()


fn set_log_priority_prefix(priority: LogPriority, var prefix: String) raises:
    """Set the text prepended to log messages of a given priority.

    By default SDL_LOG_PRIORITY_INFO and below have no prefix, and
    SDL_LOG_PRIORITY_WARN and higher have a prefix showing their priority, e.g.
    "WARNING: ".

    Args:
        priority: The SDL_LogPriority to modify.
        prefix: The prefix to use for that log priority, or NULL to use no
                prefix.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetLogPriorityPrefix.
    """

    ret = _get_dylib_function[lib, "SDL_SetLogPriorityPrefix", fn (priority: LogPriority, prefix: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(priority, prefix.as_c_string_slice().unsafe_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


comptime LogOutputFunction = fn (userdata: Ptr[NoneType, AnyOrigin[True]], category: c_int, priority: LogPriority, message: Ptr[c_char, AnyOrigin[False]]) -> None
"""The prototype for the log output callback function.
    
    This function is called by SDL when there is new text to be logged. A mutex
    is held so that this function is never called by more than one thread at
    once.
    
    Args:
        userdata: What was passed as `userdata` to
                  SDL_SetLogOutputFunction().
        category: The category of the message.
        priority: The priority of the message.
        message: The message being output.

Docs: https://wiki.libsdl.org/SDL3/SDL_LogOutputFunction.
"""


fn get_default_log_output_function() raises -> LogOutputFunction:
    """Get the default log output function.

    Returns:
        The default log output callback.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDefaultLogOutputFunction.
    """

    return _get_dylib_function[lib, "SDL_GetDefaultLogOutputFunction", fn () -> LogOutputFunction]()()


fn get_log_output_function(callback: Ptr[LogOutputFunction, AnyOrigin[True]], userdata: Ptr[Ptr[NoneType, AnyOrigin[True]], AnyOrigin[True]]) raises -> None:
    """Get the current log output function.

    Args:
        callback: An SDL_LogOutputFunction filled in with the current log
                  callback.
        userdata: A pointer filled in with the pointer that is passed to
                  `callback`.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetLogOutputFunction.
    """

    return _get_dylib_function[lib, "SDL_GetLogOutputFunction", fn (callback: Ptr[LogOutputFunction, AnyOrigin[True]], userdata: Ptr[Ptr[NoneType, AnyOrigin[True]], AnyOrigin[True]]) -> None]()(callback, userdata)


fn set_log_output_function(callback: LogOutputFunction, userdata: Ptr[NoneType, AnyOrigin[True]]) raises -> None:
    """Replace the default log output function with one of your own.

    Args:
        callback: An SDL_LogOutputFunction to call instead of the default.
        userdata: A pointer that is passed to `callback`.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetLogOutputFunction.
    """

    return _get_dylib_function[lib, "SDL_SetLogOutputFunction", fn (callback: LogOutputFunction, userdata: Ptr[NoneType, AnyOrigin[True]]) -> None]()(callback, userdata)
