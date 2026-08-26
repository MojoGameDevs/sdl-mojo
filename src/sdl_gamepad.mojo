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

"""Gamepad.

SDL provides a low-level joystick API, which just treats joysticks as an
arbitrary pile of buttons, axes, and hat switches. If you're planning to
write your own control configuration screen, this can give you a lot of
flexibility, but that's a lot of work, and most things that we consider
"joysticks" now are actually console-style gamepads. So SDL provides the
gamepad API on top of the lower-level joystick functionality.

The difference between a joystick and a gamepad is that a gamepad tells you
_where_ a button or axis is on the device. You don't speak to gamepads in
terms of arbitrary numbers like "button 3" or "axis 2" but in standard
locations: the d-pad, the shoulder buttons, triggers, A/B/X/Y (or
X/O/Square/Triangle, if you will).

One turns a joystick into a gamepad by providing a magic configuration
string, which tells SDL the details of a specific device: when you see this
specific hardware, if button 2 gets pressed, this is actually D-Pad Up,
etc.

SDL has many popular controllers configured out of the box, and users can
add their own controller details through an environment variable if it's
otherwise unknown to SDL.

In order to use these functions, SDL_Init() must have been called with the
SDL_INIT_GAMEPAD flag. This causes SDL to scan the system for gamepads, and
load appropriate drivers.

If you would like to receive gamepad updates while the application is in
the background, you should set the following hint before calling
SDL_Init(): SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS

Gamepads support various optional features such as rumble, color LEDs,
touchpad, gyro, etc. The support for these features varies depending on the
controller and OS support available. You can check for LED and rumble
capabilities at runtime by calling SDL_GetGamepadProperties() and checking
the various capability properties. You can check for touchpad by calling
SDL_GetNumGamepadTouchpads() and check for gyro and accelerometer by
calling SDL_GamepadHasSensor().

By default SDL will try to use the most capable driver available, but you
can tune which OS drivers to use with the various joystick hints in
SDL_hints.h.

Your application should always support gamepad hotplugging. On some
platforms like Xbox, Steam Deck, etc., this is a requirement for
certification. On other platforms, like macOS and Windows when using
Windows.Gaming.Input, controllers may not be available at startup and will
come in at some point after you've started processing events.
"""

from std.ffi import UnsafeUnion, _get_dylib_function, c_char, c_float, c_int
from ._core import OptPtr, Ptr, c_string, lib
from .sdl_error import get_error
from .sdl_guid import GUID
from .sdl_iostream import IOStream
from .sdl_joystick import Joystick, JoystickConnectionState, JoystickID
from .sdl_power import PowerState
from .sdl_properties import PropertiesID
from .sdl_sensor import SensorType


from std.ffi import UnsafeUnion, _get_dylib_function, c_char, c_float, c_int
from ._core import OptPtr, Ptr, c_string, lib
from .sdl_error import get_error
from .sdl_guid import GUID
from .sdl_iostream import IOStream
from .sdl_joystick import Joystick, JoystickConnectionState, JoystickID
from .sdl_power import PowerState
from .sdl_properties import PropertiesID
from .sdl_sensor import SensorType


@fieldwise_init
struct Gamepad(ImplicitlyCopyable, Movable):
    """The structure used to identify an SDL gamepad.

    Docs: https://wiki.libsdl.org/SDL3/Gamepad.
    """

    pass


struct GamepadType(Indexer, Intable, TrivialRegisterPassable):
    """Standard gamepad types.

    This type does not necessarily map to first-party controllers from
    Microsoft/Sony/Nintendo; in many cases, third-party controllers can report
    as these, either because they were designed for a specific console, or they
    simply most closely match that console's controllers (does it have A/B/X/Y
    buttons or X/O/Square/Triangle? Does it have a touchpad? etc).

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadType.
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

    comptime GAMEPAD_TYPE_UNKNOWN = Self(0)
    comptime GAMEPAD_TYPE_STANDARD = Self(1)
    comptime GAMEPAD_TYPE_XBOX360 = Self(2)
    comptime GAMEPAD_TYPE_XBOXONE = Self(3)
    comptime GAMEPAD_TYPE_PS3 = Self(4)
    comptime GAMEPAD_TYPE_PS4 = Self(5)
    comptime GAMEPAD_TYPE_PS5 = Self(6)
    comptime GAMEPAD_TYPE_NINTENDO_SWITCH_PRO = Self(7)
    comptime GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT = Self(8)
    comptime GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT = Self(9)
    comptime GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR = Self(10)
    comptime GAMEPAD_TYPE_COUNT = Self(11)


struct GamepadButton(Indexer, Intable, TrivialRegisterPassable):
    """The list of buttons available on a gamepad.

    For controllers that use a diamond pattern for the face buttons, the
    south/east/west/north buttons below correspond to the locations in the
    diamond pattern. For Xbox controllers, this would be A/B/X/Y, for Nintendo
    Switch controllers, this would be B/A/Y/X, for PlayStation controllers this
    would be Cross/Circle/Square/Triangle.

    For controllers that don't use a diamond pattern for the face buttons, the
    south/east/west/north buttons indicate the buttons labeled A, B, C, D, or
    1, 2, 3, 4, or for controllers that aren't labeled, they are the primary,
    secondary, etc. buttons.

    The activate action is often the south button and the cancel action is
    often the east button, but in some regions this is reversed, so your game
    should allow remapping actions based on user preferences.

    You can query the labels for the face buttons using
    SDL_GetGamepadButtonLabel()

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadButton.
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

    comptime GAMEPAD_BUTTON_INVALID = Self(-1)
    comptime GAMEPAD_BUTTON_SOUTH = Self(0)
    """Bottom face button (e.g. Xbox A button)."""
    comptime GAMEPAD_BUTTON_EAST = Self(1)
    """Right face button (e.g. Xbox B button)."""
    comptime GAMEPAD_BUTTON_WEST = Self(2)
    """Left face button (e.g. Xbox X button)."""
    comptime GAMEPAD_BUTTON_NORTH = Self(3)
    """Top face button (e.g. Xbox Y button)."""
    comptime GAMEPAD_BUTTON_BACK = Self(4)
    comptime GAMEPAD_BUTTON_GUIDE = Self(5)
    comptime GAMEPAD_BUTTON_START = Self(6)
    comptime GAMEPAD_BUTTON_LEFT_STICK = Self(7)
    comptime GAMEPAD_BUTTON_RIGHT_STICK = Self(8)
    comptime GAMEPAD_BUTTON_LEFT_SHOULDER = Self(9)
    comptime GAMEPAD_BUTTON_RIGHT_SHOULDER = Self(10)
    comptime GAMEPAD_BUTTON_DPAD_UP = Self(11)
    comptime GAMEPAD_BUTTON_DPAD_DOWN = Self(12)
    comptime GAMEPAD_BUTTON_DPAD_LEFT = Self(13)
    comptime GAMEPAD_BUTTON_DPAD_RIGHT = Self(14)
    comptime GAMEPAD_BUTTON_MISC1 = Self(15)
    """Additional button (e.g. Xbox Series X share button, PS5 microphone button, Nintendo Switch Pro capture button, Amazon Luna microphone button, Google Stadia capture button)."""
    comptime GAMEPAD_BUTTON_RIGHT_PADDLE1 = Self(16)
    """Upper or primary paddle, under your right hand (e.g. Xbox Elite paddle P1)."""
    comptime GAMEPAD_BUTTON_LEFT_PADDLE1 = Self(17)
    """Upper or primary paddle, under your left hand (e.g. Xbox Elite paddle P3)."""
    comptime GAMEPAD_BUTTON_RIGHT_PADDLE2 = Self(18)
    """Lower or secondary paddle, under your right hand (e.g. Xbox Elite paddle P2)."""
    comptime GAMEPAD_BUTTON_LEFT_PADDLE2 = Self(19)
    """Lower or secondary paddle, under your left hand (e.g. Xbox Elite paddle P4)."""
    comptime GAMEPAD_BUTTON_TOUCHPAD = Self(20)
    """PS4/PS5 touchpad button."""
    comptime GAMEPAD_BUTTON_MISC2 = Self(21)
    """Additional button."""
    comptime GAMEPAD_BUTTON_MISC3 = Self(22)
    """Additional button."""
    comptime GAMEPAD_BUTTON_MISC4 = Self(23)
    """Additional button."""
    comptime GAMEPAD_BUTTON_MISC5 = Self(24)
    """Additional button."""
    comptime GAMEPAD_BUTTON_MISC6 = Self(25)
    """Additional button."""
    comptime GAMEPAD_BUTTON_COUNT = Self(26)


struct GamepadButtonLabel(Indexer, Intable, TrivialRegisterPassable):
    """The set of gamepad button labels.

    This isn't a complete set, just the face buttons to make it easy to show
    button prompts.

    For a complete set, you should look at the button and gamepad type and have
    a set of symbols that work well with your art style.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadButtonLabel.
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

    comptime GAMEPAD_BUTTON_LABEL_UNKNOWN = Self(0)
    comptime GAMEPAD_BUTTON_LABEL_A = Self(1)
    comptime GAMEPAD_BUTTON_LABEL_B = Self(2)
    comptime GAMEPAD_BUTTON_LABEL_X = Self(3)
    comptime GAMEPAD_BUTTON_LABEL_Y = Self(4)
    comptime GAMEPAD_BUTTON_LABEL_CROSS = Self(5)
    comptime GAMEPAD_BUTTON_LABEL_CIRCLE = Self(6)
    comptime GAMEPAD_BUTTON_LABEL_SQUARE = Self(7)
    comptime GAMEPAD_BUTTON_LABEL_TRIANGLE = Self(8)


struct GamepadAxis(Indexer, Intable, TrivialRegisterPassable):
    """The list of axes available on a gamepad.

    Thumbstick axis values range from SDL_JOYSTICK_AXIS_MIN to
    SDL_JOYSTICK_AXIS_MAX, and are centered within ~8000 of zero, though
    advanced UI will allow users to set or autodetect the dead zone, which
    varies between gamepads.

    Trigger axis values range from 0 (released) to SDL_JOYSTICK_AXIS_MAX (fully
    pressed) when reported by SDL_GetGamepadAxis(). Note that this is not the
    same range that will be reported by the lower-level SDL_GetJoystickAxis().

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadAxis.
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

    comptime GAMEPAD_AXIS_INVALID = Self(-1)
    comptime GAMEPAD_AXIS_LEFTX = Self(0)
    comptime GAMEPAD_AXIS_LEFTY = Self(1)
    comptime GAMEPAD_AXIS_RIGHTX = Self(2)
    comptime GAMEPAD_AXIS_RIGHTY = Self(3)
    comptime GAMEPAD_AXIS_LEFT_TRIGGER = Self(4)
    comptime GAMEPAD_AXIS_RIGHT_TRIGGER = Self(5)
    comptime GAMEPAD_AXIS_COUNT = Self(6)


struct GamepadBindingType(Indexer, Intable, TrivialRegisterPassable):
    """Types of gamepad control bindings.

    A gamepad is a collection of bindings that map arbitrary joystick buttons,
    axes and hat switches to specific positions on a generic console-style
    gamepad. This enum is used as part of SDL_GamepadBinding to specify those
    mappings.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadBindingType.
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

    comptime GAMEPAD_BINDTYPE_NONE = Self(0)
    comptime GAMEPAD_BINDTYPE_BUTTON = Self(1)
    comptime GAMEPAD_BINDTYPE_AXIS = Self(2)
    comptime GAMEPAD_BINDTYPE_HAT = Self(3)


@fieldwise_init
struct GamepadBindingInputAxis(ImplicitlyCopyable, Movable, TrivialRegisterPassable):
    var axis: c_int
    var axis_min: c_int
    var axis_max: c_int


@fieldwise_init
struct GamepadBindingInputHat(ImplicitlyCopyable, Movable, TrivialRegisterPassable):
    var hat: c_int
    var hat_mask: c_int


comptime GamepadBindingInput = UnsafeUnion[GamepadBindingInputAxis, GamepadBindingInputHat]


@fieldwise_init
struct GamepadBindingOutputAxis(ImplicitlyCopyable, Movable, TrivialRegisterPassable):
    var axis: GamepadAxis
    var axis_min: c_int
    var axis_max: c_int


comptime GamepadBindingOutput = UnsafeUnion[GamepadButton, GamepadBindingOutputAxis]


@fieldwise_init
struct GamepadBinding(ImplicitlyCopyable, Movable):
    """A mapping between one joystick input to a gamepad control.

    A gamepad has a collection of several bindings, to say, for example, when
    joystick button number 5 is pressed, that should be treated like the
    gamepad's "start" button.

    SDL has these bindings built-in for many popular controllers, and can add
    more with a simple text string. Those strings are parsed into a collection
    of these structs to make it easier to operate on the data.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadBinding.
    """

    var input_type: GamepadBindingType
    var input: GamepadBindingInput

    var output_type: GamepadBindingType
    var output: GamepadBindingOutput


def add_gamepad_mapping(var mapping: String) raises -> c_int:
    """Add support for gamepads that SDL is unaware of or change the binding of an
    existing gamepad.

    The mapping string has the format "GUID,name,mapping", where GUID is the
    string value from SDL_GUIDToString(), name is the human readable string for
    the device and mappings are gamepad mappings to joystick ones. Under
    Windows there is a reserved GUID of "xinput" that covers all XInput
    devices. The mapping format for joystick is:

    - `bX`: a joystick button, index X
    - `hX.Y`: hat X with value Y
    - `aX`: axis X of the joystick

    Buttons can be used as a gamepad axes and vice versa.

    If a device with this GUID is already plugged in, SDL will generate an
    SDL_EVENT_GAMEPAD_ADDED event.

    This string shows an example of a valid mapping for a gamepad:

    ```c
    "341a3608000000000000504944564944,Afterglow PS3 Controller,a:b1,b:b2,y:b3,x:b0,start:b9,guide:b12,back:b8,dpup:h0.1,dpleft:h0.8,dpdown:h0.4,dpright:h0.2,leftshoulder:b4,rightshoulder:b5,leftstick:b10,rightstick:b11,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:b6,righttrigger:b7"
    ```

    Args:
        mapping: The mapping string.

    Returns:
        1 if a new mapping is added, 0 if an existing mapping is updated,
        -1 on failure; call SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AddGamepadMapping.
    """

    return _get_dylib_function[lib, "SDL_AddGamepadMapping", def(mapping: Ptr[mut=False, c_char, origin_of(mapping)]) thin abi("C") -> c_int]()(mapping.as_c_string_slice().ptr())


def add_gamepad_mappings_from_io[O_src: Origin, //](src: Ptr[IOStream, O_src], closeio: Bool) raises -> c_int:
    """Load a set of gamepad mappings from an SDL_IOStream.

    You can call this function several times, if needed, to load different
    database files.

    If a new mapping is loaded for an already known gamepad GUID, the later
    version will overwrite the one currently loaded.

    Any new mappings for already plugged in controllers will generate
    SDL_EVENT_GAMEPAD_ADDED events.

    Mappings not belonging to the current platform or with no platform field
    specified will be ignored (i.e. mappings for Linux will be ignored in
    Windows, etc).

    This function will load the text database entirely in memory before
    processing it, so take this into consideration if you are in a memory
    constrained environment.

    Args:
        src: The data stream for the mappings to be added.
        closeio: If true, calls SDL_CloseIO() on `src` before returning, even
                 in the case of an error.

    Returns:
        The number of mappings added or -1 on failure; call SDL_GetError()
        for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AddGamepadMappingsFromIO.
    """

    return _get_dylib_function[lib, "SDL_AddGamepadMappingsFromIO", def(src: Ptr[IOStream, O_src], closeio: Bool) thin abi("C") -> c_int]()(src, closeio)


def add_gamepad_mappings_from_file(var file: String) raises -> c_int:
    """Load a set of gamepad mappings from a file.

    You can call this function several times, if needed, to load different
    database files.

    If a new mapping is loaded for an already known gamepad GUID, the later
    version will overwrite the one currently loaded.

    Any new mappings for already plugged in controllers will generate
    SDL_EVENT_GAMEPAD_ADDED events.

    Mappings not belonging to the current platform or with no platform field
    specified will be ignored (i.e. mappings for Linux will be ignored in
    Windows, etc).

    Args:
        file: The mappings file to load.

    Returns:
        The number of mappings added or -1 on failure; call SDL_GetError()
        for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AddGamepadMappingsFromFile.
    """

    return _get_dylib_function[lib, "SDL_AddGamepadMappingsFromFile", def(file: Ptr[mut=False, c_char, origin_of(file)]) thin abi("C") -> c_int]()(file.as_c_string_slice().ptr())


def reload_gamepad_mappings() raises:
    """Reinitialize the SDL mapping database to its initial state.

    This will generate gamepad events as needed if device mappings change.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReloadGamepadMappings.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_ReloadGamepadMappings", def() thin abi("C") -> Bool]()()
    if not _ffi_ret:
        raise Error(get_error())


def get_gamepad_mappings[O_count: Origin, //](count: Ptr[c_int, O_count]) raises -> Ptr[OptPtr[c_char, UntrackedOrigin[mut=True]], UntrackedOrigin[mut=True]]:
    """Get the current gamepad mappings.

    Args:
        count: A pointer filled in with the number of mappings returned, can
               be NULL.

    Returns:
        An array of the mapping strings, NULL-terminated, or NULL on
        failure; call SDL_GetError() for more information. This is a
        single allocation that should be freed with SDL_free() when it is
        no longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadMappings.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadMappings", def(count: Ptr[c_int, O_count]) thin abi("C") -> OptPtr[OptPtr[c_char, UntrackedOrigin[mut=True]], UntrackedOrigin[mut=True]]]()(count).value()


def get_gamepad_mapping_for_guid(guid: GUID, out ret: Ptr[c_char, UntrackedOrigin[mut=True]]) raises:
    """Get the gamepad mapping string for a given GUID.

    Args:
        guid: A structure containing the GUID for which a mapping is desired.

    Returns:
        A mapping string or NULL on failure; call SDL_GetError() for more
        information. This should be freed with SDL_free() when it is no
        longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadMappingForGUID.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetGamepadMappingForGUID", def(guid: GUID) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=True]]]()(guid)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def get_gamepad_mapping[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> Ptr[c_char, UntrackedOrigin[mut=True]]:
    """Get the current mapping of a gamepad.

    Details about mappings are discussed with SDL_AddGamepadMapping().

    Args:
        gamepad: The gamepad you want to get the current mapping for.

    Returns:
        A string that has the gamepad's mapping or NULL if no mapping is
        available; call SDL_GetError() for more information. This should
        be freed with SDL_free() when it is no longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadMapping.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadMapping", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=True]]]()(gamepad).value()


def set_gamepad_mapping(instance_id: JoystickID, var mapping: String) raises:
    """Set the current mapping of a joystick or gamepad.

    Details about mappings are discussed with SDL_AddGamepadMapping().

    Args:
        instance_id: The joystick instance ID.
        mapping: The mapping to use for this device, or NULL to clear the
                 mapping.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGamepadMapping.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetGamepadMapping", def(instance_id: JoystickID, mapping: Ptr[mut=False, c_char, origin_of(mapping)]) thin abi("C") -> Bool]()(instance_id, mapping.as_c_string_slice().ptr())
    if not _ffi_ret:
        raise Error(get_error())


def has_gamepad() raises -> Bool:
    """Return whether a gamepad is currently connected.

    Returns:
        True if a gamepad is connected, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasGamepad.
    """

    return _get_dylib_function[lib, "SDL_HasGamepad", def() thin abi("C") -> Bool]()()


def get_gamepads[O_count: Origin, //](count: Ptr[c_int, O_count], out ret: Ptr[JoystickID, UntrackedOrigin[mut=True]]) raises:
    """Get a list of currently connected gamepads.

    Args:
        count: A pointer filled in with the number of gamepads returned, may
               be NULL.

    Returns:
        A 0 terminated array of joystick instance IDs or NULL on failure;
        call SDL_GetError() for more information. This should be freed
        with SDL_free() when it is no longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepads.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetGamepads", def(count: Ptr[c_int, O_count]) thin abi("C") -> OptPtr[JoystickID, UntrackedOrigin[mut=True]]]()(count)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def is_gamepad(instance_id: JoystickID) raises -> Bool:
    """Check if the given joystick is supported by the gamepad interface.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        True if the given joystick is supported by the gamepad interface,
        false if it isn't or it's an invalid index.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IsGamepad.
    """

    return _get_dylib_function[lib, "SDL_IsGamepad", def(instance_id: JoystickID) thin abi("C") -> Bool]()(instance_id)


def get_gamepad_name_for_id(instance_id: JoystickID) raises -> String:
    """Get the implementation dependent name of a gamepad.

    This can be called before any gamepads are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The name of the selected gamepad. If no name can be found, this
        function returns NULL; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadNameForID.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetGamepadNameForID", def(instance_id: JoystickID) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(instance_id).value())


def get_gamepad_path_for_id(instance_id: JoystickID) raises -> String:
    """Get the implementation dependent path of a gamepad.

    This can be called before any gamepads are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The path of the selected gamepad. If no path can be found, this
        function returns NULL; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadPathForID.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetGamepadPathForID", def(instance_id: JoystickID) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(instance_id).value())


def get_gamepad_player_index_for_id(instance_id: JoystickID) raises -> c_int:
    """Get the player index of a gamepad.

    This can be called before any gamepads are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The player index of a gamepad, or -1 if it's not available.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadPlayerIndexForID.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadPlayerIndexForID", def(instance_id: JoystickID) thin abi("C") -> c_int]()(instance_id)


def get_gamepad_guid_for_id(instance_id: JoystickID) raises -> GUID:
    """Get the implementation-dependent GUID of a gamepad.

    This can be called before any gamepads are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The GUID of the selected gamepad. If called on an invalid index,
        this function returns a zero GUID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadGUIDForID.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadGUIDForID", def(instance_id: JoystickID) thin abi("C") -> GUID]()(instance_id)


def get_gamepad_vendor_for_id(instance_id: JoystickID) raises -> UInt16:
    """Get the USB vendor ID of a gamepad, if available.

    This can be called before any gamepads are opened. If the vendor ID isn't
    available this function returns 0.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The USB vendor ID of the selected gamepad. If called on an invalid
        index, this function returns zero.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadVendorForID.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadVendorForID", def(instance_id: JoystickID) thin abi("C") -> UInt16]()(instance_id)


def get_gamepad_product_for_id(instance_id: JoystickID) raises -> UInt16:
    """Get the USB product ID of a gamepad, if available.

    This can be called before any gamepads are opened. If the product ID isn't
    available this function returns 0.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The USB product ID of the selected gamepad. If called on an
        invalid index, this function returns zero.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadProductForID.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadProductForID", def(instance_id: JoystickID) thin abi("C") -> UInt16]()(instance_id)


def get_gamepad_product_version_for_id(instance_id: JoystickID) raises -> UInt16:
    """Get the product version of a gamepad, if available.

    This can be called before any gamepads are opened. If the product version
    isn't available this function returns 0.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The product version of the selected gamepad. If called on an
        invalid index, this function returns zero.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadProductVersionForID.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadProductVersionForID", def(instance_id: JoystickID) thin abi("C") -> UInt16]()(instance_id)


def get_gamepad_type_for_id(instance_id: JoystickID) raises -> GamepadType:
    """Get the type of a gamepad.

    This can be called before any gamepads are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The gamepad type.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadTypeForID.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadTypeForID", def(instance_id: JoystickID) thin abi("C") -> GamepadType]()(instance_id)


def get_real_gamepad_type_for_id(instance_id: JoystickID) raises -> GamepadType:
    """Get the type of a gamepad, ignoring any mapping override.

    This can be called before any gamepads are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The gamepad type.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRealGamepadTypeForID.
    """

    return _get_dylib_function[lib, "SDL_GetRealGamepadTypeForID", def(instance_id: JoystickID) thin abi("C") -> GamepadType]()(instance_id)


def get_gamepad_mapping_for_id(instance_id: JoystickID) raises -> Ptr[c_char, UntrackedOrigin[mut=True]]:
    """Get the mapping of a gamepad.

    This can be called before any gamepads are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The mapping string. Returns NULL if no mapping is available. This
        should be freed with SDL_free() when it is no longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadMappingForID.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadMappingForID", def(instance_id: JoystickID) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=True]]]()(instance_id).value()


def open_gamepad(instance_id: JoystickID) raises -> Ptr[Gamepad, UntrackedOrigin[mut=True]]:
    """Open a gamepad for use.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        A gamepad identifier or NULL if an error occurred; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenGamepad.
    """

    return _get_dylib_function[lib, "SDL_OpenGamepad", def(instance_id: JoystickID) thin abi("C") -> OptPtr[Gamepad, UntrackedOrigin[mut=True]]]()(instance_id).value()


def get_gamepad_from_id(instance_id: JoystickID) raises -> Ptr[Gamepad, UntrackedOrigin[mut=True]]:
    """Get the SDL_Gamepad associated with a joystick instance ID, if it has been
    opened.

    Args:
        instance_id: The joystick instance ID of the gamepad.

    Returns:
        An SDL_Gamepad on success or NULL on failure or if it hasn't been
        opened yet; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadFromID.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadFromID", def(instance_id: JoystickID) thin abi("C") -> OptPtr[Gamepad, UntrackedOrigin[mut=True]]]()(instance_id).value()


def get_gamepad_from_player_index(player_index: c_int) raises -> Ptr[Gamepad, UntrackedOrigin[mut=True]]:
    """Get the SDL_Gamepad associated with a player index.

    Args:
        player_index: The player index, which different from the instance ID.

    Returns:
        The SDL_Gamepad associated with a player index.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadFromPlayerIndex.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadFromPlayerIndex", def(player_index: c_int) thin abi("C") -> OptPtr[Gamepad, UntrackedOrigin[mut=True]]]()(player_index).value()


def get_gamepad_properties[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> PropertiesID:
    """Get the properties associated with an opened gamepad.

    These properties are shared with the underlying joystick object.

    The following read-only properties are provided by SDL:

    - `SDL_PROP_GAMEPAD_CAP_MONO_LED_BOOLEAN`: true if this gamepad has an LED
      that has adjustable brightness
    - `SDL_PROP_GAMEPAD_CAP_RGB_LED_BOOLEAN`: true if this gamepad has an LED
      that has adjustable color
    - `SDL_PROP_GAMEPAD_CAP_PLAYER_LED_BOOLEAN`: true if this gamepad has a
      player LED
    - `SDL_PROP_GAMEPAD_CAP_RUMBLE_BOOLEAN`: true if this gamepad has
      left/right rumble
    - `SDL_PROP_GAMEPAD_CAP_TRIGGER_RUMBLE_BOOLEAN`: true if this gamepad has
      simple trigger rumble

    Args:
        gamepad: A gamepad identifier previously returned by
                 SDL_OpenGamepad().

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadProperties.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadProperties", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> PropertiesID]()(gamepad)


def get_gamepad_id[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> JoystickID:
    """Get the instance ID of an opened gamepad.

    Args:
        gamepad: A gamepad identifier previously returned by
                 SDL_OpenGamepad().

    Returns:
        The instance ID of the specified gamepad on success or 0 on
        failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadID.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadID", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> JoystickID]()(gamepad)


def get_gamepad_name[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> String:
    """Get the implementation-dependent name for an opened gamepad.

    Args:
        gamepad: A gamepad identifier previously returned by
                 SDL_OpenGamepad().

    Returns:
        The implementation dependent name for the gamepad, or NULL if
        there is no name or the identifier passed is invalid.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadName.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetGamepadName", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(gamepad).value())


def get_gamepad_path[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> String:
    """Get the implementation-dependent path for an opened gamepad.

    Args:
        gamepad: A gamepad identifier previously returned by
                 SDL_OpenGamepad().

    Returns:
        The implementation dependent path for the gamepad, or NULL if
        there is no path or the identifier passed is invalid.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadPath.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetGamepadPath", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(gamepad).value())


def get_gamepad_type[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> GamepadType:
    """Get the type of an opened gamepad.

    Args:
        gamepad: The gamepad object to query.

    Returns:
        The gamepad type, or SDL_GAMEPAD_TYPE_UNKNOWN if it's not
        available.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadType.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadType", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> GamepadType]()(gamepad)


def get_real_gamepad_type[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> GamepadType:
    """Get the type of an opened gamepad, ignoring any mapping override.

    Args:
        gamepad: The gamepad object to query.

    Returns:
        The gamepad type, or SDL_GAMEPAD_TYPE_UNKNOWN if it's not
        available.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRealGamepadType.
    """

    return _get_dylib_function[lib, "SDL_GetRealGamepadType", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> GamepadType]()(gamepad)


def get_gamepad_player_index[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> c_int:
    """Get the player index of an opened gamepad.

    For XInput gamepads this returns the XInput user index.

    Args:
        gamepad: The gamepad object to query.

    Returns:
        The player index for gamepad, or -1 if it's not available.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadPlayerIndex.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadPlayerIndex", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> c_int]()(gamepad)


def set_gamepad_player_index[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], player_index: c_int) raises:
    """Set the player index of an opened gamepad.

    Args:
        gamepad: The gamepad object to adjust.
        player_index: Player index to assign to this gamepad, or -1 to clear
                      the player index and turn off player LEDs.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGamepadPlayerIndex.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetGamepadPlayerIndex", def(gamepad: Ptr[Gamepad, O_gamepad], player_index: c_int) thin abi("C") -> Bool]()(gamepad, player_index)
    if not _ffi_ret:
        raise Error(get_error())


def get_gamepad_vendor[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> UInt16:
    """Get the USB vendor ID of an opened gamepad, if available.

    If the vendor ID isn't available this function returns 0.

    Args:
        gamepad: The gamepad object to query.

    Returns:
        The USB vendor ID, or zero if unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadVendor.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadVendor", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> UInt16]()(gamepad)


def get_gamepad_product[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> UInt16:
    """Get the USB product ID of an opened gamepad, if available.

    If the product ID isn't available this function returns 0.

    Args:
        gamepad: The gamepad object to query.

    Returns:
        The USB product ID, or zero if unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadProduct.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadProduct", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> UInt16]()(gamepad)


def get_gamepad_product_version[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> UInt16:
    """Get the product version of an opened gamepad, if available.

    If the product version isn't available this function returns 0.

    Args:
        gamepad: The gamepad object to query.

    Returns:
        The USB product version, or zero if unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadProductVersion.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadProductVersion", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> UInt16]()(gamepad)


def get_gamepad_firmware_version[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> UInt16:
    """Get the firmware version of an opened gamepad, if available.

    If the firmware version isn't available this function returns 0.

    Args:
        gamepad: The gamepad object to query.

    Returns:
        The gamepad firmware version, or zero if unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadFirmwareVersion.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadFirmwareVersion", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> UInt16]()(gamepad)


def get_gamepad_serial[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> String:
    """Get the serial number of an opened gamepad, if available.

    Returns the serial number of the gamepad, or NULL if it is not available.

    Args:
        gamepad: The gamepad object to query.

    Returns:
        The serial number, or NULL if unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadSerial.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetGamepadSerial", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(gamepad).value())


def get_gamepad_steam_handle[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> UInt64:
    """Get the Steam Input handle of an opened gamepad, if available.

    Returns an InputHandle_t for the gamepad that can be used with Steam Input
    API: https://partner.steamgames.com/doc/api/ISteamInput

    Args:
        gamepad: The gamepad object to query.

    Returns:
        The gamepad handle, or 0 if unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadSteamHandle.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadSteamHandle", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> UInt64]()(gamepad)


def get_gamepad_connection_state[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> JoystickConnectionState:
    """Get the connection state of a gamepad.

    Args:
        gamepad: The gamepad object to query.

    Returns:
        The connection state on success or
        `SDL_JOYSTICK_CONNECTION_INVALID` on failure; call SDL_GetError()
        for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadConnectionState.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadConnectionState", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> JoystickConnectionState]()(gamepad)


def get_gamepad_power_info[O_gamepad: Origin, O_percent: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], percent: Ptr[c_int, O_percent]) raises -> PowerState:
    """Get the battery state of a gamepad.

    You should never take a battery status as absolute truth. Batteries
    (especially failing batteries) are delicate hardware, and the values
    reported here are best estimates based on what that hardware reports. It's
    not uncommon for older batteries to lose stored power much faster than it
    reports, or completely drain when reporting it has 20 percent left, etc.

    Args:
        gamepad: The gamepad object to query.
        percent: A pointer filled in with the percentage of battery life
                 left, between 0 and 100, or NULL to ignore. This will be
                 filled in with -1 we can't determine a value or there is no
                 battery.

    Returns:
        The current battery state.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadPowerInfo.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadPowerInfo", def(gamepad: Ptr[Gamepad, O_gamepad], percent: Ptr[c_int, O_percent]) thin abi("C") -> PowerState]()(gamepad, percent)


def gamepad_connected[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> Bool:
    """Check if a gamepad has been opened and is currently connected.

    Args:
        gamepad: A gamepad identifier previously returned by
                 SDL_OpenGamepad().

    Returns:
        True if the gamepad has been opened and is currently connected, or
        false if not.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadConnected.
    """

    return _get_dylib_function[lib, "SDL_GamepadConnected", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> Bool]()(gamepad)


def get_gamepad_joystick[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], out ret: Ptr[Joystick, UntrackedOrigin[mut=True]]) raises:
    """Get the underlying joystick from a gamepad.

    This function will give you a SDL_Joystick object, which allows you to use
    the SDL_Joystick functions with a SDL_Gamepad object. This would be useful
    for getting a joystick's position at any given time, even if it hasn't
    moved (moving it would produce an event, which would have the axis' value).

    The pointer returned is owned by the SDL_Gamepad. You should not call
    SDL_CloseJoystick() on it, for example, since doing so will likely cause
    SDL to crash.

    Args:
        gamepad: The gamepad object that you want to get a joystick from.

    Returns:
        An SDL_Joystick object, or NULL on failure; call SDL_GetError()
        for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadJoystick.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetGamepadJoystick", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> OptPtr[Joystick, UntrackedOrigin[mut=True]]]()(gamepad)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def set_gamepad_events_enabled(enabled: Bool) raises -> None:
    """Set the state of gamepad event processing.

    If gamepad events are disabled, you must call SDL_UpdateGamepads() yourself
    and check the state of the gamepad when you want gamepad information.

    Args:
        enabled: Whether to process gamepad events or not.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGamepadEventsEnabled.
    """

    return _get_dylib_function[lib, "SDL_SetGamepadEventsEnabled", def(enabled: Bool) thin abi("C") -> None]()(enabled)


def gamepad_events_enabled() raises -> Bool:
    """Query the state of gamepad event processing.

    If gamepad events are disabled, you must call SDL_UpdateGamepads() yourself
    and check the state of the gamepad when you want gamepad information.

    Returns:
        True if gamepad events are being processed, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadEventsEnabled.
    """

    return _get_dylib_function[lib, "SDL_GamepadEventsEnabled", def() thin abi("C") -> Bool]()()


def get_gamepad_bindings[O_gamepad: Origin, O_count: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], count: Ptr[c_int, O_count]) raises -> Ptr[OptPtr[GamepadBinding, UntrackedOrigin[mut=True]], UntrackedOrigin[mut=True]]:
    """Get the SDL joystick layer bindings for a gamepad.

    Args:
        gamepad: A gamepad.
        count: A pointer filled in with the number of bindings returned.

    Returns:
        A NULL terminated array of pointers to bindings or NULL on
        failure; call SDL_GetError() for more information. This is a
        single allocation that should be freed with SDL_free() when it is
        no longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadBindings.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadBindings", def(gamepad: Ptr[Gamepad, O_gamepad], count: Ptr[c_int, O_count]) thin abi("C") -> OptPtr[OptPtr[GamepadBinding, UntrackedOrigin[mut=True]], UntrackedOrigin[mut=True]]]()(gamepad, count).value()


def update_gamepads() raises -> None:
    """Manually pump gamepad updates if not using the loop.

    This function is called automatically by the event loop if events are
    enabled. Under such circumstances, it will not be necessary to call this
    function.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UpdateGamepads.
    """

    return _get_dylib_function[lib, "SDL_UpdateGamepads", def() thin abi("C") -> None]()()


def get_gamepad_type_from_string(var str: String) raises -> GamepadType:
    """Convert a string into SDL_GamepadType enum.

    This function is called internally to translate SDL_Gamepad mapping strings
    for the underlying joystick device into the consistent SDL_Gamepad mapping.
    You do not normally need to call this function unless you are parsing
    SDL_Gamepad mappings in your own code.

    Args:
        str: String representing a SDL_GamepadType type.

    Returns:
        The SDL_GamepadType enum corresponding to the input string, or
        `SDL_GAMEPAD_TYPE_UNKNOWN` if no match was found.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadTypeFromString.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadTypeFromString", def(str: Ptr[mut=False, c_char, origin_of(str)]) thin abi("C") -> GamepadType]()(str.as_c_string_slice().ptr())


def get_gamepad_string_for_type(type: GamepadType) raises -> String:
    """Convert from an SDL_GamepadType enum to a string.

    Args:
        type: An enum value for a given SDL_GamepadType.

    Returns:
        A string for the given type, or NULL if an invalid type is
        specified. The string returned is of the format used by
        SDL_Gamepad mapping strings.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadStringForType.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetGamepadStringForType", def(type: GamepadType) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(type).value())


def get_gamepad_axis_from_string(var str: String) raises -> GamepadAxis:
    """Convert a string into SDL_GamepadAxis enum.

    This function is called internally to translate SDL_Gamepad mapping strings
    for the underlying joystick device into the consistent SDL_Gamepad mapping.
    You do not normally need to call this function unless you are parsing
    SDL_Gamepad mappings in your own code.

    Note specially that "righttrigger" and "lefttrigger" map to
    `SDL_GAMEPAD_AXIS_RIGHT_TRIGGER` and `SDL_GAMEPAD_AXIS_LEFT_TRIGGER`,
    respectively.

    Args:
        str: String representing a SDL_Gamepad axis.

    Returns:
        The SDL_GamepadAxis enum corresponding to the input string, or
        `SDL_GAMEPAD_AXIS_INVALID` if no match was found.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadAxisFromString.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadAxisFromString", def(str: Ptr[mut=False, c_char, origin_of(str)]) thin abi("C") -> GamepadAxis]()(str.as_c_string_slice().ptr())


def get_gamepad_string_for_axis(axis: GamepadAxis) raises -> String:
    """Convert from an SDL_GamepadAxis enum to a string.

    Args:
        axis: An enum value for a given SDL_GamepadAxis.

    Returns:
        A string for the given axis, or NULL if an invalid axis is
        specified. The string returned is of the format used by
        SDL_Gamepad mapping strings.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadStringForAxis.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetGamepadStringForAxis", def(axis: GamepadAxis) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(axis).value())


def gamepad_has_axis[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], axis: GamepadAxis) raises -> Bool:
    """Query whether a gamepad has a given axis.

    This merely reports whether the gamepad's mapping defined this axis, as
    that is all the information SDL has about the physical device.

    Args:
        gamepad: A gamepad.
        axis: An axis enum value (an SDL_GamepadAxis value).

    Returns:
        True if the gamepad has this axis, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadHasAxis.
    """

    return _get_dylib_function[lib, "SDL_GamepadHasAxis", def(gamepad: Ptr[Gamepad, O_gamepad], axis: GamepadAxis) thin abi("C") -> Bool]()(gamepad, axis)


def get_gamepad_axis[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], axis: GamepadAxis) raises -> Int16:
    """Get the current state of an axis control on a gamepad.

    The axis indices start at index 0.

    For thumbsticks, the state is a value ranging from -32768 (up/left) to
    32767 (down/right).

    Triggers range from 0 when released to 32767 when fully pressed, and never
    return a negative value. Note that this differs from the value reported by
    the lower-level SDL_GetJoystickAxis(), which normally uses the full range.

    Args:
        gamepad: A gamepad.
        axis: An axis index (one of the SDL_GamepadAxis values).

    Returns:
        Axis state (including 0) on success or 0 (also) on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadAxis.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadAxis", def(gamepad: Ptr[Gamepad, O_gamepad], axis: GamepadAxis) thin abi("C") -> Int16]()(gamepad, axis)


def get_gamepad_button_from_string(var str: String) raises -> GamepadButton:
    """Convert a string into an SDL_GamepadButton enum.

    This function is called internally to translate SDL_Gamepad mapping strings
    for the underlying joystick device into the consistent SDL_Gamepad mapping.
    You do not normally need to call this function unless you are parsing
    SDL_Gamepad mappings in your own code.

    Args:
        str: String representing a SDL_Gamepad axis.

    Returns:
        The SDL_GamepadButton enum corresponding to the input string, or
        `SDL_GAMEPAD_BUTTON_INVALID` if no match was found.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadButtonFromString.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadButtonFromString", def(str: Ptr[mut=False, c_char, origin_of(str)]) thin abi("C") -> GamepadButton]()(str.as_c_string_slice().ptr())


def get_gamepad_string_for_button(button: GamepadButton) raises -> String:
    """Convert from an SDL_GamepadButton enum to a string.

    Args:
        button: An enum value for a given SDL_GamepadButton.

    Returns:
        A string for the given button, or NULL if an invalid button is
        specified. The string returned is of the format used by
        SDL_Gamepad mapping strings.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadStringForButton.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetGamepadStringForButton", def(button: GamepadButton) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(button).value())


def gamepad_has_button[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], button: GamepadButton) raises -> Bool:
    """Query whether a gamepad has a given button.

    This merely reports whether the gamepad's mapping defined this button, as
    that is all the information SDL has about the physical device.

    Args:
        gamepad: A gamepad.
        button: A button enum value (an SDL_GamepadButton value).

    Returns:
        True if the gamepad has this button, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadHasButton.
    """

    return _get_dylib_function[lib, "SDL_GamepadHasButton", def(gamepad: Ptr[Gamepad, O_gamepad], button: GamepadButton) thin abi("C") -> Bool]()(gamepad, button)


def get_gamepad_button[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], button: GamepadButton) raises -> Bool:
    """Get the current state of a button on a gamepad.

    Args:
        gamepad: A gamepad.
        button: A button index (one of the SDL_GamepadButton values).

    Returns:
        True if the button is pressed, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadButton.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadButton", def(gamepad: Ptr[Gamepad, O_gamepad], button: GamepadButton) thin abi("C") -> Bool]()(gamepad, button)


def get_gamepad_button_label_for_type(type: GamepadType, button: GamepadButton) raises -> GamepadButtonLabel:
    """Get the label of a button on a gamepad.

    Args:
        type: The type of gamepad to check.
        button: A button index (one of the SDL_GamepadButton values).

    Returns:
        The SDL_GamepadButtonLabel enum corresponding to the button label.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadButtonLabelForType.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadButtonLabelForType", def(type: GamepadType, button: GamepadButton) thin abi("C") -> GamepadButtonLabel]()(type, button)


def get_gamepad_button_label[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], button: GamepadButton) raises -> GamepadButtonLabel:
    """Get the label of a button on a gamepad.

    Args:
        gamepad: A gamepad.
        button: A button index (one of the SDL_GamepadButton values).

    Returns:
        The SDL_GamepadButtonLabel enum corresponding to the button label.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadButtonLabel.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadButtonLabel", def(gamepad: Ptr[Gamepad, O_gamepad], button: GamepadButton) thin abi("C") -> GamepadButtonLabel]()(gamepad, button)


def get_num_gamepad_touchpads[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> c_int:
    """Get the number of touchpads on a gamepad.

    Args:
        gamepad: A gamepad.

    Returns:
        Number of touchpads.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumGamepadTouchpads.
    """

    return _get_dylib_function[lib, "SDL_GetNumGamepadTouchpads", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> c_int]()(gamepad)


def get_num_gamepad_touchpad_fingers[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], touchpad: c_int) raises -> c_int:
    """Get the number of supported simultaneous fingers on a touchpad on a game
    gamepad.

    Args:
        gamepad: A gamepad.
        touchpad: A touchpad.

    Returns:
        Number of supported simultaneous fingers.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumGamepadTouchpadFingers.
    """

    return _get_dylib_function[lib, "SDL_GetNumGamepadTouchpadFingers", def(gamepad: Ptr[Gamepad, O_gamepad], touchpad: c_int) thin abi("C") -> c_int]()(gamepad, touchpad)


def get_gamepad_touchpad_finger[O_gamepad: Origin, O_down: Origin, O_x: Origin, O_y: Origin, O_pressure: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], touchpad: c_int, finger: c_int, down: Ptr[Bool, O_down], x: Ptr[c_float, O_x], y: Ptr[c_float, O_y], pressure: Ptr[c_float, O_pressure]) raises:
    """Get the current state of a finger on a touchpad on a gamepad.

    Args:
        gamepad: A gamepad.
        touchpad: A touchpad.
        finger: A finger.
        down: A pointer filled with true if the finger is down, false
              otherwise, may be NULL.
        x: A pointer filled with the x position, normalized 0 to 1, with the
           origin in the upper left, may be NULL.
        y: A pointer filled with the y position, normalized 0 to 1, with the
           origin in the upper left, may be NULL.
        pressure: A pointer filled with pressure value, may be NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadTouchpadFinger.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetGamepadTouchpadFinger", def(gamepad: Ptr[Gamepad, O_gamepad], touchpad: c_int, finger: c_int, down: Ptr[Bool, O_down], x: Ptr[c_float, O_x], y: Ptr[c_float, O_y], pressure: Ptr[c_float, O_pressure]) thin abi("C") -> Bool]()(gamepad, touchpad, finger, down, x, y, pressure)
    if not _ffi_ret:
        raise Error(get_error())


def gamepad_has_sensor[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], type: SensorType) raises -> Bool:
    """Return whether a gamepad has a particular sensor.

    Args:
        gamepad: The gamepad to query.
        type: The type of sensor to query.

    Returns:
        True if the sensor exists, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadHasSensor.
    """

    return _get_dylib_function[lib, "SDL_GamepadHasSensor", def(gamepad: Ptr[Gamepad, O_gamepad], type: SensorType) thin abi("C") -> Bool]()(gamepad, type)


def set_gamepad_sensor_enabled[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], type: SensorType, enabled: Bool) raises:
    """Set whether data reporting for a gamepad sensor is enabled.

    Args:
        gamepad: The gamepad to update.
        type: The type of sensor to enable/disable.
        enabled: Whether data reporting should be enabled.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGamepadSensorEnabled.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetGamepadSensorEnabled", def(gamepad: Ptr[Gamepad, O_gamepad], type: SensorType, enabled: Bool) thin abi("C") -> Bool]()(gamepad, type, enabled)
    if not _ffi_ret:
        raise Error(get_error())


def gamepad_sensor_enabled[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], type: SensorType) raises -> Bool:
    """Query whether sensor data reporting is enabled for a gamepad.

    Args:
        gamepad: The gamepad to query.
        type: The type of sensor to query.

    Returns:
        True if the sensor is enabled, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadSensorEnabled.
    """

    return _get_dylib_function[lib, "SDL_GamepadSensorEnabled", def(gamepad: Ptr[Gamepad, O_gamepad], type: SensorType) thin abi("C") -> Bool]()(gamepad, type)


def get_gamepad_sensor_data_rate[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], type: SensorType) raises -> c_float:
    """Get the data rate (number of events per second) of a gamepad sensor.

    Args:
        gamepad: The gamepad to query.
        type: The type of sensor to query.

    Returns:
        The data rate, or 0.0f if the data rate is not available.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadSensorDataRate.
    """

    return _get_dylib_function[lib, "SDL_GetGamepadSensorDataRate", def(gamepad: Ptr[Gamepad, O_gamepad], type: SensorType) thin abi("C") -> c_float]()(gamepad, type)


def get_gamepad_sensor_data[O_gamepad: Origin, O_data: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], type: SensorType, data: Ptr[c_float, O_data], num_values: c_int) raises:
    """Get the current state of a gamepad sensor.

    The number of values and interpretation of the data is sensor dependent.
    See SDL_sensor.h for the details for each type of sensor.

    Args:
        gamepad: The gamepad to query.
        type: The type of sensor to query.
        data: A pointer filled with the current sensor state.
        num_values: The number of values to write to data.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadSensorData.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetGamepadSensorData", def(gamepad: Ptr[Gamepad, O_gamepad], type: SensorType, data: Ptr[c_float, O_data], num_values: c_int) thin abi("C") -> Bool]()(gamepad, type, data, num_values)
    if not _ffi_ret:
        raise Error(get_error())


def rumble_gamepad[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], low_frequency_rumble: UInt16, high_frequency_rumble: UInt16, duration_ms: UInt32) raises:
    """Start a rumble effect on a gamepad.

    Each call to this function cancels any previous rumble effect, and calling
    it with 0 intensity stops any rumbling.

    This function requires you to process SDL events or call
    SDL_UpdateJoysticks() to update rumble state.

    Args:
        gamepad: The gamepad to vibrate.
        low_frequency_rumble: The intensity of the low frequency (left)
                              rumble motor, from 0 to 0xFFFF.
        high_frequency_rumble: The intensity of the high frequency (right)
                               rumble motor, from 0 to 0xFFFF.
        duration_ms: The duration of the rumble effect, in milliseconds.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RumbleGamepad.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RumbleGamepad", def(gamepad: Ptr[Gamepad, O_gamepad], low_frequency_rumble: UInt16, high_frequency_rumble: UInt16, duration_ms: UInt32) thin abi("C") -> Bool]()(gamepad, low_frequency_rumble, high_frequency_rumble, duration_ms)
    if not _ffi_ret:
        raise Error(get_error())


def rumble_gamepad_triggers[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], left_rumble: UInt16, right_rumble: UInt16, duration_ms: UInt32) raises:
    """Start a rumble effect in the gamepad's triggers.

    Each call to this function cancels any previous trigger rumble effect, and
    calling it with 0 intensity stops any rumbling.

    Note that this is rumbling of the _triggers_ and not the gamepad as a
    whole. This is currently only supported on Xbox One gamepads. If you want
    the (more common) whole-gamepad rumble, use SDL_RumbleGamepad() instead.

    This function requires you to process SDL events or call
    SDL_UpdateJoysticks() to update rumble state.

    Args:
        gamepad: The gamepad to vibrate.
        left_rumble: The intensity of the left trigger rumble motor, from 0
                     to 0xFFFF.
        right_rumble: The intensity of the right trigger rumble motor, from 0
                      to 0xFFFF.
        duration_ms: The duration of the rumble effect, in milliseconds.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RumbleGamepadTriggers.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RumbleGamepadTriggers", def(gamepad: Ptr[Gamepad, O_gamepad], left_rumble: UInt16, right_rumble: UInt16, duration_ms: UInt32) thin abi("C") -> Bool]()(gamepad, left_rumble, right_rumble, duration_ms)
    if not _ffi_ret:
        raise Error(get_error())


def set_gamepad_led[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], red: UInt8, green: UInt8, blue: UInt8) raises:
    """Update a gamepad's LED color.

    An example of a joystick LED is the light on the back of a PlayStation 4's
    DualShock 4 controller.

    For gamepads with a single color LED, the maximum of the RGB values will be
    used as the LED brightness.

    Args:
        gamepad: The gamepad to update.
        red: The intensity of the red LED.
        green: The intensity of the green LED.
        blue: The intensity of the blue LED.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGamepadLED.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetGamepadLED", def(gamepad: Ptr[Gamepad, O_gamepad], red: UInt8, green: UInt8, blue: UInt8) thin abi("C") -> Bool]()(gamepad, red, green, blue)
    if not _ffi_ret:
        raise Error(get_error())


def send_gamepad_effect[O_gamepad: Origin, O_data: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], data: Ptr[NoneType, O_data], size: c_int) raises:
    """Send a gamepad specific effect packet.

    Args:
        gamepad: The gamepad to affect.
        data: The data to send to the gamepad.
        size: The size of the data to send to the gamepad.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SendGamepadEffect.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SendGamepadEffect", def(gamepad: Ptr[Gamepad, O_gamepad], data: Ptr[NoneType, O_data], size: c_int) thin abi("C") -> Bool]()(gamepad, data, size)
    if not _ffi_ret:
        raise Error(get_error())


def close_gamepad[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad]) raises -> None:
    """Close a gamepad previously opened with SDL_OpenGamepad().

    Args:
        gamepad: A gamepad identifier previously returned by
                 SDL_OpenGamepad().

    Docs: https://wiki.libsdl.org/SDL3/SDL_CloseGamepad.
    """

    return _get_dylib_function[lib, "SDL_CloseGamepad", def(gamepad: Ptr[Gamepad, O_gamepad]) thin abi("C") -> None]()(gamepad)


def get_gamepad_apple_sf_symbols_name_for_button[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], button: GamepadButton) raises -> String:
    """Return the sfSymbolsName for a given button on a gamepad on Apple
    platforms.

    Args:
        gamepad: The gamepad to query.
        button: A button on the gamepad.

    Returns:
        The sfSymbolsName or NULL if the name can't be found.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadAppleSFSymbolsNameForButton.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetGamepadAppleSFSymbolsNameForButton", def(gamepad: Ptr[Gamepad, O_gamepad], button: GamepadButton) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(gamepad, button).value())


def get_gamepad_apple_sf_symbols_name_for_axis[O_gamepad: Origin, //](gamepad: Ptr[Gamepad, O_gamepad], axis: GamepadAxis) raises -> String:
    """Return the sfSymbolsName for a given axis on a gamepad on Apple platforms.

    Args:
        gamepad: The gamepad to query.
        axis: An axis on the gamepad.

    Returns:
        The sfSymbolsName or NULL if the name can't be found.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGamepadAppleSFSymbolsNameForAxis.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetGamepadAppleSFSymbolsNameForAxis", def(gamepad: Ptr[Gamepad, O_gamepad], axis: GamepadAxis) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(gamepad, axis).value())
