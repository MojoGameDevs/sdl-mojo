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
# |  claim that you wrote the original software. If you use this software
# |  in a product, an acknowledgment in the product documentation would be
# |  appreciated but is not required.
# | 2. Altered source versions must be plainly marked as such, and must not be
# |  misrepresented as being the original software.
# | 3. This notice may not be removed or altered from any source distribution.
# x--------------------------------------------------------------------------x #

"""Time

SDL realtime clock and date/time routines.

There are two data types that are used in this category: SDL_Time, which
represents the nanoseconds since a specific moment (an "epoch"), and
SDL_DateTime, which breaks time down into human-understandable components:
years, months, days, hours, etc.

Much of the functionality is involved in converting those two types to
other useful forms.
"""


@fieldwise_init
struct DateTime(ImplicitlyCopyable, Movable):
    """A structure holding a calendar date and time broken down into its
    components.

    Docs: https://wiki.libsdl.org/SDL3/DateTime.
    """

    var year: c_int
    """Year."""
    var month: c_int
    """Month [01-12]."""
    var day: c_int
    """Day of the month [01-31]."""
    var hour: c_int
    """Hour [0-23]."""
    var minute: c_int
    """Minute [0-59]."""
    var second: c_int
    """Seconds [0-60]."""
    var nanosecond: c_int
    """Nanoseconds [0-999999999]."""
    var day_of_week: c_int
    """Day of the week [0-6] (0 being Sunday)."""
    var utc_offset: c_int
    """Seconds east of UTC."""


@register_passable("trivial")
struct DateFormat(Indexer, Intable):
    """The preferred date format of the current system locale.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DateFormat.
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

    comptime DATE_FORMAT_YYYYMMDD = Self(0)
    """Year/Month/Day."""
    comptime DATE_FORMAT_DDMMYYYY = Self(1)
    """Day/Month/Year."""
    comptime DATE_FORMAT_MMDDYYYY = Self(2)
    """Month/Day/Year."""


@register_passable("trivial")
struct TimeFormat(Indexer, Intable):
    """The preferred time format of the current system locale.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TimeFormat.
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

    comptime TIME_FORMAT_24HR = Self(0)
    """24 hour time."""
    comptime TIME_FORMAT_12HR = Self(1)
    """12 hour time."""


fn get_date_time_locale_preferences(date_format: Ptr[DateFormat, AnyOrigin[True]], time_format: Ptr[TimeFormat, AnyOrigin[True]]) raises:
    """Gets the current preferred date and time format for the system locale.

    This might be a "slow" call that has to query the operating system. It's
    best to ask for this once and save the results. However, the preferred
    formats can change, usually because the user has changed a system
    preference outside of your program.

    Args:
        date_format: A pointer to the SDL_DateFormat to hold the returned date
                     format, may be NULL.
        time_format: A pointer to the SDL_TimeFormat to hold the returned time
                     format, may be NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDateTimeLocalePreferences.
    """

    ret = _get_dylib_function[lib, "SDL_GetDateTimeLocalePreferences", fn (date_format: Ptr[DateFormat, AnyOrigin[True]], time_format: Ptr[TimeFormat, AnyOrigin[True]]) -> Bool]()(date_format, time_format)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_current_time(ticks: Ptr[Int64, AnyOrigin[True]]) raises:
    """Gets the current value of the system realtime clock in nanoseconds since
    Jan 1, 1970 in Universal Coordinated Time (UTC).

    Args:
        ticks: The SDL_Time to hold the returned tick count.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCurrentTime.
    """

    ret = _get_dylib_function[lib, "SDL_GetCurrentTime", fn (ticks: Ptr[Int64, AnyOrigin[True]]) -> Bool]()(ticks)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn time_to_date_time(ticks: Int64, dt: Ptr[DateTime, AnyOrigin[True]], local_time: Bool) raises:
    """Converts an SDL_Time in nanoseconds since the epoch to a calendar time in
    the SDL_DateTime format.

    Args:
        ticks: The SDL_Time to be converted.
        dt: The resulting SDL_DateTime.
        local_time: The resulting SDL_DateTime will be expressed in local time
                    if true, otherwise it will be in Universal Coordinated
                    Time (UTC).

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TimeToDateTime.
    """

    ret = _get_dylib_function[lib, "SDL_TimeToDateTime", fn (ticks: Int64, dt: Ptr[DateTime, AnyOrigin[True]], local_time: Bool) -> Bool]()(ticks, dt, local_time)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn date_time_to_time(dt: Ptr[DateTime, AnyOrigin[False]], ticks: Ptr[Int64, AnyOrigin[True]]) raises:
    """Converts a calendar time to an SDL_Time in nanoseconds since the epoch.

    This function ignores the day_of_week member of the SDL_DateTime struct, so
    it may remain unset.

    Args:
        dt: The source SDL_DateTime.
        ticks: The resulting SDL_Time.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DateTimeToTime.
    """

    ret = _get_dylib_function[lib, "SDL_DateTimeToTime", fn (dt: Ptr[DateTime, AnyOrigin[False]], ticks: Ptr[Int64, AnyOrigin[True]]) -> Bool]()(dt, ticks)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn time_to_windows(ticks: Int64, dw_low_date_time: Ptr[UInt32, AnyOrigin[True]], dw_high_date_time: Ptr[UInt32, AnyOrigin[True]]) raises -> None:
    """Converts an SDL time into a Windows FILETIME (100-nanosecond intervals
    since January 1, 1601).

    This function fills in the two 32-bit values of the FILETIME structure.

    Args:
        ticks: The time to convert.
        dw_low_date_time: A pointer filled in with the low portion of the
                          Windows FILETIME value.
        dw_high_date_time: A pointer filled in with the high portion of the
                           Windows FILETIME value.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TimeToWindows.
    """

    return _get_dylib_function[lib, "SDL_TimeToWindows", fn (ticks: Int64, dw_low_date_time: Ptr[UInt32, AnyOrigin[True]], dw_high_date_time: Ptr[UInt32, AnyOrigin[True]]) -> None]()(ticks, dw_low_date_time, dw_high_date_time)


fn time_from_windows(dw_low_date_time: UInt32, dw_high_date_time: UInt32) raises -> Int64:
    """Converts a Windows FILETIME (100-nanosecond intervals since January 1,
    1601) to an SDL time.

    This function takes the two 32-bit values of the FILETIME structure as
    parameters.

    Args:
        dw_low_date_time: The low portion of the Windows FILETIME value.
        dw_high_date_time: The high portion of the Windows FILETIME value.

    Returns:
        The converted SDL time.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TimeFromWindows.
    """

    return _get_dylib_function[lib, "SDL_TimeFromWindows", fn (dw_low_date_time: UInt32, dw_high_date_time: UInt32) -> Int64]()(dw_low_date_time, dw_high_date_time)


fn get_days_in_month(year: c_int, month: c_int) raises -> c_int:
    """Get the number of days in a month for a given year.

    Args:
        year: The year.
        month: The month [1-12].

    Returns:
        The number of days in the requested month or -1 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDaysInMonth.
    """

    return _get_dylib_function[lib, "SDL_GetDaysInMonth", fn (year: c_int, month: c_int) -> c_int]()(year, month)


fn get_day_of_year(year: c_int, month: c_int, day: c_int) raises -> c_int:
    """Get the day of year for a calendar date.

    Args:
        year: The year component of the date.
        month: The month component of the date.
        day: The day component of the date.

    Returns:
        The day of year [0-365] if the date is valid or -1 on failure;
        call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDayOfYear.
    """

    return _get_dylib_function[lib, "SDL_GetDayOfYear", fn (year: c_int, month: c_int, day: c_int) -> c_int]()(year, month, day)


fn get_day_of_week(year: c_int, month: c_int, day: c_int) raises -> c_int:
    """Get the day of week for a calendar date.

    Args:
        year: The year component of the date.
        month: The month component of the date.
        day: The day component of the date.

    Returns:
        A value between 0 and 6 (0 being Sunday) if the date is valid or
        -1 on failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDayOfWeek.
    """

    return _get_dylib_function[lib, "SDL_GetDayOfWeek", fn (year: c_int, month: c_int, day: c_int) -> c_int]()(year, month, day)
