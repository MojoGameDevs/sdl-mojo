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

"""Touch

SDL offers touch input, on platforms that support it. It can manage
multiple touch devices and track multiple fingers on those devices.

Touches are mostly dealt with through the event system, in the
SDL_EVENT_FINGER_DOWN, SDL_EVENT_FINGER_MOTION, and SDL_EVENT_FINGER_UP
events, but there are also functions to query for hardware details, etc.

The touch system, by default, will also send virtual mouse events; this can
be useful for making a some desktop apps work on a phone without
significant changes. For apps that care about mouse and touch input
separately, they should ignore mouse events that have a `which` field of
SDL_TOUCH_MOUSEID.
"""


@register_passable("trivial")
struct TouchID(Intable):
    """A unique ID for a touch device.

    This ID is valid for the time the device is connected to the system, and is
    never reused for the lifetime of the application.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TouchID.
    """

    var value: UInt64

    @always_inline
    fn __init__(out self, value: UInt64):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __or__(lhs, rhs: Self) -> Self:
        return Self(lhs.value | rhs.value)


@register_passable("trivial")
struct FingerID(Intable):
    """A unique ID for a single finger on a touch device.

    This ID is valid for the time the finger (stylus, etc) is touching and will
    be unique for all fingers currently in contact, so this ID tracks the
    lifetime of a single continuous touch. This value may represent an index, a
    pointer, or some other unique ID, depending on the platform.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FingerID.
    """

    var value: UInt64

    @always_inline
    fn __init__(out self, value: UInt64):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __or__(lhs, rhs: Self) -> Self:
        return Self(lhs.value | rhs.value)


@register_passable("trivial")
struct TouchDeviceType(Indexer, Intable):
    """An enum that describes the type of a touch device.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TouchDeviceType.
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

    comptime TOUCH_DEVICE_INVALID = Self(-1)
    comptime TOUCH_DEVICE_DIRECT = Self(0)
    """Touch screen with window-relative coordinates."""
    comptime TOUCH_DEVICE_INDIRECT_ABSOLUTE = Self(1)
    """Trackpad with absolute device coordinates."""
    comptime TOUCH_DEVICE_INDIRECT_RELATIVE = Self(2)
    """Trackpad with screen cursor-relative coordinates."""


@fieldwise_init
struct Finger(ImplicitlyCopyable, Movable):
    """Data about a single finger in a multitouch event.

    Each touch event is a collection of fingers that are simultaneously in
    contact with the touch device (so a "touch" can be a "multitouch," in
    reality), and this struct reports details of the specific fingers.

    Docs: https://wiki.libsdl.org/SDL3/Finger.
    """

    var id: FingerID
    """The finger ID."""
    var x: c_float
    """The x-axis location of the touch event, normalized (0...1)."""
    var y: c_float
    """The y-axis location of the touch event, normalized (0...1)."""
    var pressure: c_float
    """The quantity of pressure applied, normalized (0...1)."""


fn get_touch_devices(count: Ptr[c_int, AnyOrigin[True]], out ret: Ptr[TouchID, AnyOrigin[True]]) raises:
    """Get a list of registered touch devices.

    On some platforms SDL first sees the touch device if it was actually used.
    Therefore the returned list might be empty, although devices are available.
    After using all devices at least once the number will be correct.

    Args:
        count: A pointer filled in with the number of devices returned, may
               be NULL.

    Returns:
        A 0 terminated array of touch device IDs or NULL on failure; call
        SDL_GetError() for more information. This should be freed with
        SDL_free() when it is no longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTouchDevices.
    """

    ret = _get_dylib_function[lib, "SDL_GetTouchDevices", fn (count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[TouchID, AnyOrigin[True]]]()(count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_touch_device_name(touch_id: TouchID, out ret: Ptr[c_char, AnyOrigin[False]]) raises:
    """Get the touch device name as reported from the driver.

    Args:
        touch_id: The touch device instance ID.

    Returns:
        Touch device name, or NULL on failure; call SDL_GetError() for
        more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTouchDeviceName.
    """

    ret = _get_dylib_function[lib, "SDL_GetTouchDeviceName", fn (touch_id: TouchID) -> Ptr[c_char, AnyOrigin[False]]]()(touch_id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_touch_device_type(touch_id: TouchID) raises -> TouchDeviceType:
    """Get the type of the given touch device.

    Args:
        touch_id: The ID of a touch device.

    Returns:
        Touch device type.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTouchDeviceType.
    """

    return _get_dylib_function[lib, "SDL_GetTouchDeviceType", fn (touch_id: TouchID) -> TouchDeviceType]()(touch_id)


fn get_touch_fingers(touch_id: TouchID, count: Ptr[c_int, AnyOrigin[True]], out ret: Ptr[Ptr[Finger, AnyOrigin[True]], AnyOrigin[True]]) raises:
    """Get a list of active fingers for a given touch device.

    Args:
        touch_id: The ID of a touch device.
        count: A pointer filled in with the number of fingers returned, can
               be NULL.

    Returns:
        A NULL terminated array of SDL_Finger pointers or NULL on failure;
        call SDL_GetError() for more information. This is a single
        allocation that should be freed with SDL_free() when it is no
        longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTouchFingers.
    """

    ret = _get_dylib_function[lib, "SDL_GetTouchFingers", fn (touch_id: TouchID, count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[Ptr[Finger, AnyOrigin[True]], AnyOrigin[True]]]()(touch_id, count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))
