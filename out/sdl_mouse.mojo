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

"""Mouse

Any GUI application has to deal with the mouse, and SDL provides functions
to manage mouse input and the displayed cursor.

Most interactions with the mouse will come through the event subsystem.
Moving a mouse generates an SDL_EVENT_MOUSE_MOTION event, pushing a button
generates SDL_EVENT_MOUSE_BUTTON_DOWN, etc, but one can also query the
current state of the mouse at any time with SDL_GetMouseState().

For certain games, it's useful to disassociate the mouse cursor from mouse
input. An FPS, for example, would not want the player's motion to stop as
the mouse hits the edge of the window. For these scenarios, use
SDL_SetWindowRelativeMouseMode(), which hides the cursor, grabs mouse input
to the window, and reads mouse input no matter how far it moves.

Games that want the system to track the mouse but want to draw their own
cursor can use SDL_HideCursor() and SDL_ShowCursor(). It might be more
efficient to let the system manage the cursor, if possible, using
SDL_SetCursor() with a custom image made through SDL_CreateColorCursor(),
or perhaps just a specific system cursor from SDL_CreateSystemCursor().

SDL can, on many platforms, differentiate between multiple connected mice,
allowing for interesting input scenarios and multiplayer games. They can be
enumerated with SDL_GetMice(), and SDL will send SDL_EVENT_MOUSE_ADDED and
SDL_EVENT_MOUSE_REMOVED events as they are connected and unplugged.

Since many apps only care about basic mouse input, SDL offers a virtual
mouse device for touch and pen input, which often can make a desktop
application work on a touchscreen phone without any code changes. Apps that
care about touch/pen separately from mouse input should filter out events
with a `which` field of SDL_TOUCH_MOUSEID/SDL_PEN_MOUSEID.
"""


@register_passable("trivial")
struct MouseID(Intable):
    """This is a unique ID for a mouse for the time it is connected to the system,
    and is never reused for the lifetime of the application.

    If the mouse is disconnected and reconnected, it will get a new ID.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_MouseID.
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


@fieldwise_init
struct Cursor(ImplicitlyCopyable, Movable):
    """The structure used to identify an SDL cursor.

    This is opaque data.

    Docs: https://wiki.libsdl.org/SDL3/Cursor.
    """

    pass


@register_passable("trivial")
struct SystemCursor(Indexer, Intable):
    """Cursor types for SDL_CreateSystemCursor().

    Docs: https://wiki.libsdl.org/SDL3/SDL_SystemCursor.
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

    comptime SYSTEM_CURSOR_DEFAULT = Self(0)
    """Default cursor. Usually an arrow."""
    comptime SYSTEM_CURSOR_TEXT = Self(1)
    """Text selection. Usually an I-beam."""
    comptime SYSTEM_CURSOR_WAIT = Self(2)
    """Wait. Usually an hourglass or watch or spinning ball."""
    comptime SYSTEM_CURSOR_CROSSHAIR = Self(3)
    """Crosshair."""
    comptime SYSTEM_CURSOR_PROGRESS = Self(4)
    """Program is busy but still interactive. Usually it's WAIT with an arrow."""
    comptime SYSTEM_CURSOR_NWSE_RESIZE = Self(5)
    """Double arrow pointing northwest and southeast."""
    comptime SYSTEM_CURSOR_NESW_RESIZE = Self(6)
    """Double arrow pointing northeast and southwest."""
    comptime SYSTEM_CURSOR_EW_RESIZE = Self(7)
    """Double arrow pointing west and east."""
    comptime SYSTEM_CURSOR_NS_RESIZE = Self(8)
    """Double arrow pointing north and south."""
    comptime SYSTEM_CURSOR_MOVE = Self(9)
    """Four pointed arrow pointing north, south, east, and west."""
    comptime SYSTEM_CURSOR_NOT_ALLOWED = Self(10)
    """Not permitted. Usually a slashed circle or crossbones."""
    comptime SYSTEM_CURSOR_POINTER = Self(11)
    """Pointer that indicates a link. Usually a pointing hand."""
    comptime SYSTEM_CURSOR_NW_RESIZE = Self(12)
    """Window resize top-left. This may be a single arrow or a double arrow like NWSE_RESIZE."""
    comptime SYSTEM_CURSOR_N_RESIZE = Self(13)
    """Window resize top. May be NS_RESIZE."""
    comptime SYSTEM_CURSOR_NE_RESIZE = Self(14)
    """Window resize top-right. May be NESW_RESIZE."""
    comptime SYSTEM_CURSOR_E_RESIZE = Self(15)
    """Window resize right. May be EW_RESIZE."""
    comptime SYSTEM_CURSOR_SE_RESIZE = Self(16)
    """Window resize bottom-right. May be NWSE_RESIZE."""
    comptime SYSTEM_CURSOR_S_RESIZE = Self(17)
    """Window resize bottom. May be NS_RESIZE."""
    comptime SYSTEM_CURSOR_SW_RESIZE = Self(18)
    """Window resize bottom-left. May be NESW_RESIZE."""
    comptime SYSTEM_CURSOR_W_RESIZE = Self(19)
    """Window resize left. May be EW_RESIZE."""
    comptime SYSTEM_CURSOR_COUNT = Self(20)


@register_passable("trivial")
struct MouseWheelDirection(Indexer, Intable):
    """Scroll direction types for the Scroll event.

    Docs: https://wiki.libsdl.org/SDL3/SDL_MouseWheelDirection.
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

    comptime MOUSEWHEEL_NORMAL = Self(0)
    """The scroll direction is normal."""
    comptime MOUSEWHEEL_FLIPPED = Self(1)
    """The scroll direction is flipped / natural."""


@register_passable("trivial")
struct MouseButtonFlags(Intable):
    """A bitmask of pressed mouse buttons, as reported by SDL_GetMouseState, etc.

    - Button 1: Left mouse button
    - Button 2: Middle mouse button
    - Button 3: Right mouse button
    - Button 4: Side mouse button 1
    - Button 5: Side mouse button 2

    Docs: https://wiki.libsdl.org/SDL3/SDL_MouseButtonFlags.
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

    comptime BUTTON_LEFT = Self(1)
    comptime BUTTON_MIDDLE = Self(2)
    comptime BUTTON_RIGHT = Self(3)
    comptime BUTTON_X1 = Self(4)
    comptime BUTTON_X2 = Self(5)


fn has_mouse() raises -> Bool:
    """Return whether a mouse is currently connected.

    Returns:
        True if a mouse is connected, false otherwise.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasMouse.
    """

    return _get_dylib_function[lib, "SDL_HasMouse", fn () -> Bool]()()


fn get_mice(count: Ptr[c_int, AnyOrigin[True]], out ret: Ptr[MouseID, AnyOrigin[True]]) raises:
    """Get a list of currently connected mice.

    Note that this will include any device or virtual driver that includes
    mouse functionality, including some game controllers, KVM switches, etc.
    You should wait for input from a device before you consider it actively in
    use.

    Args:
        count: A pointer filled in with the number of mice returned, may be
               NULL.

    Returns:
        A 0 terminated array of mouse instance IDs or NULL on failure;
        call SDL_GetError() for more information. This should be freed
        with SDL_free() when it is no longer needed.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetMice.
    """

    ret = _get_dylib_function[lib, "SDL_GetMice", fn (count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[MouseID, AnyOrigin[True]]]()(count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_mouse_name_for_id(instance_id: MouseID, out ret: Ptr[c_char, AnyOrigin[False]]) raises:
    """Get the name of a mouse.

    This function returns "" if the mouse doesn't have a name.

    Args:
        instance_id: The mouse instance ID.

    Returns:
        The name of the selected mouse, or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetMouseNameForID.
    """

    ret = _get_dylib_function[lib, "SDL_GetMouseNameForID", fn (instance_id: MouseID) -> Ptr[c_char, AnyOrigin[False]]]()(instance_id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_mouse_focus() raises -> Ptr[Window, AnyOrigin[True]]:
    """Get the window which currently has mouse focus.

    Returns:
        The window with mouse focus.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetMouseFocus.
    """

    return _get_dylib_function[lib, "SDL_GetMouseFocus", fn () -> Ptr[Window, AnyOrigin[True]]]()()


fn get_mouse_state(x: Ptr[c_float, AnyOrigin[True]], y: Ptr[c_float, AnyOrigin[True]]) raises -> MouseButtonFlags:
    """Query SDL's cache for the synchronous mouse button state and the
    window-relative SDL-cursor position.

    This function returns the cached synchronous state as SDL understands it
    from the last pump of the event queue.

    To query the platform for immediate asynchronous state, use
    SDL_GetGlobalMouseState.

    Passing non-NULL pointers to `x` or `y` will write the destination with
    respective x or y coordinates relative to the focused window.

    In Relative Mode, the SDL-cursor's position usually contradicts the
    platform-cursor's position as manually calculated from
    SDL_GetGlobalMouseState() and SDL_GetWindowPosition.

    Args:
        x: A pointer to receive the SDL-cursor's x-position from the focused
           window's top left corner, can be NULL if unused.
        y: A pointer to receive the SDL-cursor's y-position from the focused
           window's top left corner, can be NULL if unused.

    Returns:
        A 32-bit bitmask of the button state that can be bitwise-compared
        against the SDL_BUTTON_MASK(X) macro.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetMouseState.
    """

    return _get_dylib_function[lib, "SDL_GetMouseState", fn (x: Ptr[c_float, AnyOrigin[True]], y: Ptr[c_float, AnyOrigin[True]]) -> MouseButtonFlags]()(x, y)


fn get_global_mouse_state(x: Ptr[c_float, AnyOrigin[True]], y: Ptr[c_float, AnyOrigin[True]]) raises -> MouseButtonFlags:
    """Query the platform for the asynchronous mouse button state and the
    desktop-relative platform-cursor position.

    This function immediately queries the platform for the most recent
    asynchronous state, more costly than retrieving SDL's cached state in
    SDL_GetMouseState().

    Passing non-NULL pointers to `x` or `y` will write the destination with
    respective x or y coordinates relative to the desktop.

    In Relative Mode, the platform-cursor's position usually contradicts the
    SDL-cursor's position as manually calculated from SDL_GetMouseState() and
    SDL_GetWindowPosition.

    This function can be useful if you need to track the mouse outside of a
    specific window and SDL_CaptureMouse() doesn't fit your needs. For example,
    it could be useful if you need to track the mouse while dragging a window,
    where coordinates relative to a window might not be in sync at all times.

    Args:
        x: A pointer to receive the platform-cursor's x-position from the
           desktop's top left corner, can be NULL if unused.
        y: A pointer to receive the platform-cursor's y-position from the
           desktop's top left corner, can be NULL if unused.

    Returns:
        A 32-bit bitmask of the button state that can be bitwise-compared
        against the SDL_BUTTON_MASK(X) macro.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGlobalMouseState.
    """

    return _get_dylib_function[lib, "SDL_GetGlobalMouseState", fn (x: Ptr[c_float, AnyOrigin[True]], y: Ptr[c_float, AnyOrigin[True]]) -> MouseButtonFlags]()(x, y)


fn get_relative_mouse_state(x: Ptr[c_float, AnyOrigin[True]], y: Ptr[c_float, AnyOrigin[True]]) raises -> MouseButtonFlags:
    """Query SDL's cache for the synchronous mouse button state and accumulated
    mouse delta since last call.

    This function returns the cached synchronous state as SDL understands it
    from the last pump of the event queue.

    To query the platform for immediate asynchronous state, use
    SDL_GetGlobalMouseState.

    Passing non-NULL pointers to `x` or `y` will write the destination with
    respective x or y deltas accumulated since the last call to this function
    (or since event initialization).

    This function is useful for reducing overhead by processing relative mouse
    inputs in one go per-frame instead of individually per-event, at the
    expense of losing the order between events within the frame (e.g. quickly
    pressing and releasing a button within the same frame).

    Args:
        x: A pointer to receive the x mouse delta accumulated since last
           call, can be NULL if unused.
        y: A pointer to receive the y mouse delta accumulated since last
           call, can be NULL if unused.

    Returns:
        A 32-bit bitmask of the button state that can be bitwise-compared
        against the SDL_BUTTON_MASK(X) macro.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRelativeMouseState.
    """

    return _get_dylib_function[lib, "SDL_GetRelativeMouseState", fn (x: Ptr[c_float, AnyOrigin[True]], y: Ptr[c_float, AnyOrigin[True]]) -> MouseButtonFlags]()(x, y)


fn warp_mouse_in_window(window: Ptr[Window, AnyOrigin[True]], x: c_float, y: c_float) raises -> None:
    """Move the mouse cursor to the given position within the window.

    This function generates a mouse motion event if relative mode is not
    enabled. If relative mode is enabled, you can force mouse events for the
    warp by setting the SDL_HINT_MOUSE_RELATIVE_WARP_MOTION hint.

    Note that this function will appear to succeed, but not actually move the
    mouse when used over Microsoft Remote Desktop.

    Args:
        window: The window to move the mouse into, or NULL for the current
                mouse focus.
        x: The x coordinate within the window.
        y: The y coordinate within the window.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WarpMouseInWindow.
    """

    return _get_dylib_function[lib, "SDL_WarpMouseInWindow", fn (window: Ptr[Window, AnyOrigin[True]], x: c_float, y: c_float) -> None]()(window, x, y)


fn warp_mouse_global(x: c_float, y: c_float) raises:
    """Move the mouse to the given position in global screen space.

    This function generates a mouse motion event.

    A failure of this function usually means that it is unsupported by a
    platform.

    Note that this function will appear to succeed, but not actually move the
    mouse when used over Microsoft Remote Desktop.

    Args:
        x: The x coordinate.
        y: The y coordinate.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WarpMouseGlobal.
    """

    ret = _get_dylib_function[lib, "SDL_WarpMouseGlobal", fn (x: c_float, y: c_float) -> Bool]()(x, y)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_relative_mouse_mode(window: Ptr[Window, AnyOrigin[True]], enabled: Bool) raises:
    """Set relative mouse mode for a window.

    While the window has focus and relative mouse mode is enabled, the cursor
    is hidden, the mouse position is constrained to the window, and SDL will
    report continuous relative mouse motion even if the mouse is at the edge of
    the window.

    If you'd like to keep the mouse position fixed while in relative mode you
    can use SDL_SetWindowMouseRect(). If you'd like the cursor to be at a
    specific location when relative mode ends, you should use
    SDL_WarpMouseInWindow() before disabling relative mode.

    This function will flush any pending mouse motion for this window.

    Args:
        window: The window to change.
        enabled: True to enable relative mode, false to disable.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowRelativeMouseMode.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowRelativeMouseMode", fn (window: Ptr[Window, AnyOrigin[True]], enabled: Bool) -> Bool]()(window, enabled)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_relative_mouse_mode(window: Ptr[Window, AnyOrigin[True]]) raises -> Bool:
    """Query whether relative mouse mode is enabled for a window.

    Args:
        window: The window to query.

    Returns:
        True if relative mode is enabled for a window or false otherwise.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowRelativeMouseMode.
    """

    return _get_dylib_function[lib, "SDL_GetWindowRelativeMouseMode", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)


fn capture_mouse(enabled: Bool) raises:
    """Capture the mouse and to track input outside an SDL window.

    Capturing enables your app to obtain mouse events globally, instead of just
    within your window. Not all video targets support this function. When
    capturing is enabled, the current window will get all mouse events, but
    unlike relative mode, no change is made to the cursor and it is not
    restrained to your window.

    This function may also deny mouse input to other windows--both those in
    your application and others on the system--so you should use this function
    sparingly, and in small bursts. For example, you might want to track the
    mouse while the user is dragging something, until the user releases a mouse
    button. It is not recommended that you capture the mouse for long periods
    of time, such as the entire time your app is running. For that, you should
    probably use SDL_SetWindowRelativeMouseMode() or SDL_SetWindowMouseGrab(),
    depending on your goals.

    While captured, mouse events still report coordinates relative to the
    current (foreground) window, but those coordinates may be outside the
    bounds of the window (including negative values). Capturing is only allowed
    for the foreground window. If the window loses focus while capturing, the
    capture will be disabled automatically.

    While capturing is enabled, the current window will have the
    `SDL_WINDOW_MOUSE_CAPTURE` flag set.

    Please note that SDL will attempt to "auto capture" the mouse while the
    user is pressing a button; this is to try and make mouse behavior more
    consistent between platforms, and deal with the common case of a user
    dragging the mouse outside of the window. This means that if you are
    calling SDL_CaptureMouse() only to deal with this situation, you do not
    have to (although it is safe to do so). If this causes problems for your
    app, you can disable auto capture by setting the
    `SDL_HINT_MOUSE_AUTO_CAPTURE` hint to zero.

    Args:
        enabled: True to enable capturing, false to disable.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CaptureMouse.
    """

    ret = _get_dylib_function[lib, "SDL_CaptureMouse", fn (enabled: Bool) -> Bool]()(enabled)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_cursor(data: Ptr[UInt8, AnyOrigin[False]], mask: Ptr[UInt8, AnyOrigin[False]], w: c_int, h: c_int, hot_x: c_int, hot_y: c_int) raises -> Ptr[Cursor, AnyOrigin[True]]:
    """Create a cursor using the specified bitmap data and mask (in MSB format).

    `mask` has to be in MSB (Most Significant Bit) format.

    The cursor width (`w`) must be a multiple of 8 bits.

    The cursor is created in black and white according to the following:

    - data=0, mask=1: white
    - data=1, mask=1: black
    - data=0, mask=0: transparent
    - data=1, mask=0: inverted color if possible, black if not.

    Cursors created with this function must be freed with SDL_DestroyCursor().

    If you want to have a color cursor, or create your cursor from an
    SDL_Surface, you should use SDL_CreateColorCursor(). Alternately, you can
    hide the cursor and draw your own as part of your game's rendering, but it
    will be bound to the framerate.

    Also, SDL_CreateSystemCursor() is available, which provides several
    readily-available system cursors to pick from.

    Args:
        data: The color value for each pixel of the cursor.
        mask: The mask value for each pixel of the cursor.
        w: The width of the cursor.
        h: The height of the cursor.
        hot_x: The x-axis offset from the left of the cursor image to the
               mouse x position, in the range of 0 to `w` - 1.
        hot_y: The y-axis offset from the top of the cursor image to the
               mouse y position, in the range of 0 to `h` - 1.

    Returns:
        A new cursor with the specified parameters on success or NULL on
        failure; call SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateCursor.
    """

    return _get_dylib_function[lib, "SDL_CreateCursor", fn (data: Ptr[UInt8, AnyOrigin[False]], mask: Ptr[UInt8, AnyOrigin[False]], w: c_int, h: c_int, hot_x: c_int, hot_y: c_int) -> Ptr[Cursor, AnyOrigin[True]]]()(data, mask, w, h, hot_x, hot_y)


fn create_color_cursor(surface: Ptr[Surface, AnyOrigin[True]], hot_x: c_int, hot_y: c_int, out ret: Ptr[Cursor, AnyOrigin[True]]) raises:
    """Create a color cursor.

    If this function is passed a surface with alternate representations, the
    surface will be interpreted as the content to be used for 100% display
    scale, and the alternate representations will be used for high DPI
    situations. For example, if the original surface is 32x32, then on a 2x
    macOS display or 200% display scale on Windows, a 64x64 version of the
    image will be used, if available. If a matching version of the image isn't
    available, the closest larger size image will be downscaled to the
    appropriate size and be used instead, if available. Otherwise, the closest
    smaller image will be upscaled and be used instead.

    Args:
        surface: An SDL_Surface structure representing the cursor image.
        hot_x: The x position of the cursor hot spot.
        hot_y: The y position of the cursor hot spot.

    Returns:
        The new cursor on success or NULL on failure; call SDL_GetError()
        for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateColorCursor.
    """

    ret = _get_dylib_function[lib, "SDL_CreateColorCursor", fn (surface: Ptr[Surface, AnyOrigin[True]], hot_x: c_int, hot_y: c_int) -> Ptr[Cursor, AnyOrigin[True]]]()(surface, hot_x, hot_y)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_system_cursor(id: SystemCursor, out ret: Ptr[Cursor, AnyOrigin[True]]) raises:
    """Create a system cursor.

    Args:
        id: An SDL_SystemCursor enum value.

    Returns:
        A cursor on success or NULL on failure; call SDL_GetError() for
        more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateSystemCursor.
    """

    ret = _get_dylib_function[lib, "SDL_CreateSystemCursor", fn (id: SystemCursor) -> Ptr[Cursor, AnyOrigin[True]]]()(id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_cursor(cursor: Ptr[Cursor, AnyOrigin[True]]) raises:
    """Set the active cursor.

    This function sets the currently active cursor to the specified one. If the
    cursor is currently visible, the change will be immediately represented on
    the display. SDL_SetCursor(NULL) can be used to force cursor redraw, if
    this is desired for any reason.

    Args:
        cursor: A cursor to make active.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetCursor.
    """

    ret = _get_dylib_function[lib, "SDL_SetCursor", fn (cursor: Ptr[Cursor, AnyOrigin[True]]) -> Bool]()(cursor)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_cursor() raises -> Ptr[Cursor, AnyOrigin[True]]:
    """Get the active cursor.

    This function returns a pointer to the current cursor which is owned by the
    library. It is not necessary to free the cursor with SDL_DestroyCursor().

    Returns:
        The active cursor or NULL if there is no mouse.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCursor.
    """

    return _get_dylib_function[lib, "SDL_GetCursor", fn () -> Ptr[Cursor, AnyOrigin[True]]]()()


fn get_default_cursor() raises -> Ptr[Cursor, AnyOrigin[True]]:
    """Get the default cursor.

    You do not have to call SDL_DestroyCursor() on the return value, but it is
    safe to do so.

    Returns:
        The default cursor on success or NULL on failuree; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDefaultCursor.
    """

    return _get_dylib_function[lib, "SDL_GetDefaultCursor", fn () -> Ptr[Cursor, AnyOrigin[True]]]()()


fn destroy_cursor(cursor: Ptr[Cursor, AnyOrigin[True]]) raises -> None:
    """Free a previously-created cursor.

    Use this function to free cursor resources created with SDL_CreateCursor(),
    SDL_CreateColorCursor() or SDL_CreateSystemCursor().

    Args:
        cursor: The cursor to free.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyCursor.
    """

    return _get_dylib_function[lib, "SDL_DestroyCursor", fn (cursor: Ptr[Cursor, AnyOrigin[True]]) -> None]()(cursor)


fn show_cursor() raises:
    """Show the cursor.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ShowCursor.
    """

    ret = _get_dylib_function[lib, "SDL_ShowCursor", fn () -> Bool]()()
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn hide_cursor() raises:
    """Hide the cursor.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HideCursor.
    """

    ret = _get_dylib_function[lib, "SDL_HideCursor", fn () -> Bool]()()
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn cursor_visible() raises -> Bool:
    """Return whether the cursor is currently being shown.

    Returns:
        `true` if the cursor is being shown, or `false` if the cursor is
        hidden.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CursorVisible.
    """

    return _get_dylib_function[lib, "SDL_CursorVisible", fn () -> Bool]()()
