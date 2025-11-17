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

"""Pen

SDL pen event handling.

SDL provides an API for pressure-sensitive pen (stylus and/or eraser)
handling, e.g., for input and drawing tablets or suitably equipped mobile /
tablet devices.

To get started with pens, simply handle SDL_EVENT_PEN_* events. When a pen
starts providing input, SDL will assign it a unique SDL_PenID, which will
remain for the life of the process, as long as the pen stays connected.

Pens may provide more than simple touch input; they might have other axes,
such as pressure, tilt, rotation, etc.
"""


@register_passable("trivial")
struct PenID(Intable):
    """SDL pen instance IDs.

    Zero is used to signify an invalid/null device.

    These show up in pen events when SDL sees input from them. They remain
    consistent as long as SDL can recognize a tool to be the same pen; but if a
    pen physically leaves the area and returns, it might get a new ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PenID.
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


@register_passable("trivial")
struct PenInputFlags(Intable):
    """Pen input flags, as reported by various pen events' `pen_state` field.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PenInputFlags.
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

    comptime PEN_INPUT_DOWN = Self(1 << 0)
    """Pen is pressed down."""
    comptime PEN_INPUT_BUTTON_1 = Self(1 << 1)
    """Button 1 is pressed."""
    comptime PEN_INPUT_BUTTON_2 = Self(1 << 2)
    """Button 2 is pressed."""
    comptime PEN_INPUT_BUTTON_3 = Self(1 << 3)
    """Button 3 is pressed."""
    comptime PEN_INPUT_BUTTON_4 = Self(1 << 4)
    """Button 4 is pressed."""
    comptime PEN_INPUT_BUTTON_5 = Self(1 << 5)
    """Button 5 is pressed."""
    comptime PEN_INPUT_ERASER_TIP = Self(1 << 30)
    """Eraser tip is used."""


@register_passable("trivial")
struct PenAxis(Indexer, Intable):
    """Pen axis indices.

    These are the valid values for the `axis` field in SDL_PenAxisEvent. All
    axes are either normalised to 0..1 or report a (positive or negative) angle
    in degrees, with 0.0 representing the centre. Not all pens/backends support
    all axes: unsupported axes are always zero.

    To convert angles for tilt and rotation into vector representation, use
    SDL_sinf on the XTILT, YTILT, or ROTATION component, for example:

    `SDL_sinf(xtilt * SDL_PI_F / 180.0)`.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PenAxis.
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

    comptime PEN_AXIS_PRESSURE = Self(0)
    """Pen pressure.  Unidirectional: 0 to 1.0."""
    comptime PEN_AXIS_XTILT = Self(1)
    """Pen horizontal tilt angle.  Bidirectional: -90.0 to 90.0 (left-to-right)."""
    comptime PEN_AXIS_YTILT = Self(2)
    """Pen vertical tilt angle.  Bidirectional: -90.0 to 90.0 (top-to-down)."""
    comptime PEN_AXIS_DISTANCE = Self(3)
    """Pen distance to drawing surface.  Unidirectional: 0.0 to 1.0."""
    comptime PEN_AXIS_ROTATION = Self(4)
    """Pen barrel rotation.  Bidirectional: -180 to 179.9 (clockwise, 0 is facing up, -180.0 is facing down)."""
    comptime PEN_AXIS_SLIDER = Self(5)
    """Pen finger wheel or slider (e.g., Airbrush Pen).  Unidirectional: 0 to 1.0."""
    comptime PEN_AXIS_TANGENTIAL_PRESSURE = Self(6)
    """Pressure from squeezing the pen ("barrel pressure")."""
    comptime PEN_AXIS_COUNT = Self(7)
    """Total known pen axis types in this version of SDL. This number may grow in future releases!."""
