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

"""Timer

SDL provides time management functionality. It is useful for dealing with
(usually) small durations of time.

This is not to be confused with _calendar time_ management, which is
provided by [CategoryTime](CategoryTime).

This category covers measuring time elapsed (SDL_GetTicks(),
SDL_GetPerformanceCounter()), putting a thread to sleep for a certain
amount of time (SDL_Delay(), SDL_DelayNS(), SDL_DelayPrecise()), and firing
a callback function after a certain amount of time has elasped
(SDL_AddTimer(), etc).

There are also useful macros to convert between time units, like
SDL_SECONDS_TO_NS() and such.
"""


fn get_ticks() raises -> UInt64:
    """Get the number of milliseconds since SDL library initialization.

    Returns:
        An unsigned 64-bit value representing the number of milliseconds
        since the SDL library initialized.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTicks.
    """

    return _get_dylib_function[lib, "SDL_GetTicks", fn () -> UInt64]()()


fn get_ticks_ns() raises -> UInt64:
    """Get the number of nanoseconds since SDL library initialization.

    Returns:
        An unsigned 64-bit value representing the number of nanoseconds
        since the SDL library initialized.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTicksNS.
    """

    return _get_dylib_function[lib, "SDL_GetTicksNS", fn () -> UInt64]()()


fn get_performance_counter() raises -> UInt64:
    """Get the current value of the high resolution counter.

    This function is typically used for profiling.

    The counter values are only meaningful relative to each other. Differences
    between values can be converted to times by using
    SDL_GetPerformanceFrequency().

    Returns:
        The current counter value.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPerformanceCounter.
    """

    return _get_dylib_function[lib, "SDL_GetPerformanceCounter", fn () -> UInt64]()()


fn get_performance_frequency() raises -> UInt64:
    """Get the count per second of the high resolution counter.

    Returns:
        A platform-specific count per second.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPerformanceFrequency.
    """

    return _get_dylib_function[lib, "SDL_GetPerformanceFrequency", fn () -> UInt64]()()


fn delay(ms: UInt32) raises -> None:
    """Wait a specified number of milliseconds before returning.

    This function waits a specified number of milliseconds before returning. It
    waits at least the specified time, but possibly longer due to OS
    scheduling.

    Args:
        ms: The number of milliseconds to delay.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_Delay.
    """

    return _get_dylib_function[lib, "SDL_Delay", fn (ms: UInt32) -> None]()(ms)


fn delay_ns(ns: UInt64) raises -> None:
    """Wait a specified number of nanoseconds before returning.

    This function waits a specified number of nanoseconds before returning. It
    waits at least the specified time, but possibly longer due to OS
    scheduling.

    Args:
        ns: The number of nanoseconds to delay.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DelayNS.
    """

    return _get_dylib_function[lib, "SDL_DelayNS", fn (ns: UInt64) -> None]()(ns)


fn delay_precise(ns: UInt64) raises -> None:
    """Wait a specified number of nanoseconds before returning.

    This function waits a specified number of nanoseconds before returning. It
    will attempt to wait as close to the requested time as possible, busy
    waiting if necessary, but could return later due to OS scheduling.

    Args:
        ns: The number of nanoseconds to delay.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DelayPrecise.
    """

    return _get_dylib_function[lib, "SDL_DelayPrecise", fn (ns: UInt64) -> None]()(ns)


@register_passable("trivial")
struct TimerID(Intable):
    """Definition of the timer ID type.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TimerID.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: UInt32):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __or__(lhs, rhs: Self) -> Self:
        return Self(lhs.value | rhs.value)


comptime TimerCallback = fn (userdata: Ptr[NoneType, AnyOrigin[True]], timer_id: TimerID, interval: UInt32) -> UInt32
"""Function prototype for the millisecond timer callback function.
    
    The callback function is passed the current timer interval and returns the
    next timer interval, in milliseconds. If the returned value is the same as
    the one passed in, the periodic alarm continues, otherwise a new alarm is
    scheduled. If the callback returns 0, the periodic alarm is canceled and
    will be removed.
    
    Args:
        userdata: An arbitrary pointer provided by the app through
                  SDL_AddTimer, for its own use.
        timer_id: The current timer being processed.
        interval: The current callback time interval.
    
    Returns:
        The new callback time interval, or 0 to disable further runs of
        the callback.
    
    Safety:
        SDL may call this callback at any time from a background
        thread; the application is responsible for locking resources
        the callback touches that need to be protected.

Docs: https://wiki.libsdl.org/SDL3/SDL_TimerCallback.
"""


fn add_timer(interval: UInt32, callback: TimerCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) raises -> TimerID:
    """Call a callback function at a future time.

    The callback function is passed the current timer interval and the user
    supplied parameter from the SDL_AddTimer() call and should return the next
    timer interval. If the value returned from the callback is 0, the timer is
    canceled and will be removed.

    The callback is run on a separate thread, and for short timeouts can
    potentially be called before this function returns.

    Timers take into account the amount of time it took to execute the
    callback. For example, if the callback took 250 ms to execute and returned
    1000 (ms), the timer would only wait another 750 ms before its next
    iteration.

    Timing may be inexact due to OS scheduling. Be sure to note the current
    time with SDL_GetTicksNS() or SDL_GetPerformanceCounter() in case your
    callback needs to adjust for variances.

    Args:
        interval: The timer delay, in milliseconds, passed to `callback`.
        callback: The SDL_TimerCallback function to call when the specified
                  `interval` elapses.
        userdata: A pointer that is passed to `callback`.

    Returns:
        A timer ID or 0 on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AddTimer.
    """

    return _get_dylib_function[lib, "SDL_AddTimer", fn (interval: UInt32, callback: TimerCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) -> TimerID]()(interval, callback, userdata)


comptime NSTimerCallback = fn (userdata: Ptr[NoneType, AnyOrigin[True]], timer_id: TimerID, interval: UInt64) -> UInt64
"""Function prototype for the nanosecond timer callback function.
    
    The callback function is passed the current timer interval and returns the
    next timer interval, in nanoseconds. If the returned value is the same as
    the one passed in, the periodic alarm continues, otherwise a new alarm is
    scheduled. If the callback returns 0, the periodic alarm is canceled and
    will be removed.
    
    Args:
        userdata: An arbitrary pointer provided by the app through
                  SDL_AddTimer, for its own use.
        timer_id: The current timer being processed.
        interval: The current callback time interval.
    
    Returns:
        The new callback time interval, or 0 to disable further runs of
        the callback.
    
    Safety:
        SDL may call this callback at any time from a background
        thread; the application is responsible for locking resources
        the callback touches that need to be protected.

Docs: https://wiki.libsdl.org/SDL3/SDL_NSTimerCallback.
"""


fn add_timer_ns(interval: UInt64, callback: NSTimerCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) raises -> TimerID:
    """Call a callback function at a future time.

    The callback function is passed the current timer interval and the user
    supplied parameter from the SDL_AddTimerNS() call and should return the
    next timer interval. If the value returned from the callback is 0, the
    timer is canceled and will be removed.

    The callback is run on a separate thread, and for short timeouts can
    potentially be called before this function returns.

    Timers take into account the amount of time it took to execute the
    callback. For example, if the callback took 250 ns to execute and returned
    1000 (ns), the timer would only wait another 750 ns before its next
    iteration.

    Timing may be inexact due to OS scheduling. Be sure to note the current
    time with SDL_GetTicksNS() or SDL_GetPerformanceCounter() in case your
    callback needs to adjust for variances.

    Args:
        interval: The timer delay, in nanoseconds, passed to `callback`.
        callback: The SDL_TimerCallback function to call when the specified
                  `interval` elapses.
        userdata: A pointer that is passed to `callback`.

    Returns:
        A timer ID or 0 on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AddTimerNS.
    """

    return _get_dylib_function[lib, "SDL_AddTimerNS", fn (interval: UInt64, callback: NSTimerCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) -> TimerID]()(interval, callback, userdata)


fn remove_timer(id: TimerID) raises:
    """Remove a timer created with SDL_AddTimer().

    Args:
        id: The ID of the timer to remove.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RemoveTimer.
    """

    ret = _get_dylib_function[lib, "SDL_RemoveTimer", fn (id: TimerID) -> Bool]()(id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))
