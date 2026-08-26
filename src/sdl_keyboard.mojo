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

"""Keyboard.

SDL keyboard management.

Please refer to the Best Keyboard Practices document for details on how
best to accept keyboard input in various types of programs:

https://wiki.libsdl.org/SDL3/BestKeyboardPractices
"""

from std.ffi import _get_dylib_function, c_char, c_int
from ._core import OptPtr, Ptr, c_string, lib
from .sdl_error import get_error
from .sdl_keycode import Keycode, Keymod
from .sdl_properties import PropertiesID
from .sdl_rect import Rect
from .sdl_scancode import Scancode
from .sdl_video import Window


from std.ffi import _get_dylib_function, c_char, c_int
from ._core import OptPtr, Ptr, c_string, lib
from .sdl_error import get_error
from .sdl_keycode import Keycode, Keymod
from .sdl_properties import PropertiesID
from .sdl_rect import Rect
from .sdl_scancode import Scancode
from .sdl_video import Window


struct KeyboardID(Intable, TrivialRegisterPassable):
    """This is a unique ID for a keyboard for the time it is connected to the
    system, and is never reused for the lifetime of the application.

    If the keyboard is disconnected and reconnected, it will get a new ID.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_KeyboardID.
    """

    var value: UInt32

    @always_inline
    def __init__(out self, value: UInt32):
        self.value = value

    @always_inline
    def __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    def __or__(lhs, rhs: Self) -> Self:
        return Self(lhs.value | rhs.value)


def has_keyboard() raises -> Bool:
    """Return whether a keyboard is currently connected.

    Returns:
        True if a keyboard is connected, false otherwise.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasKeyboard.
    """

    return _get_dylib_function[lib, "SDL_HasKeyboard", def() thin abi("C") -> Bool]()()


def get_keyboards[O_count: Origin, //](count: Ptr[c_int, O_count], out ret: Ptr[KeyboardID, UntrackedOrigin[mut=True]]) raises:
    """Get a list of currently connected keyboards.

    Note that this will include any device or virtual driver that includes
    keyboard functionality, including some mice, KVM switches, motherboard
    power buttons, etc. You should wait for input from a device before you
    consider it actively in use.

    Args:
        count: A pointer filled in with the number of keyboards returned, may
               be NULL.

    Returns:
        A 0 terminated array of keyboards instance IDs or NULL on failure;
        call SDL_GetError() for more information. This should be freed
        with SDL_free() when it is no longer needed.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetKeyboards.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetKeyboards", def(count: Ptr[c_int, O_count]) thin abi("C") -> OptPtr[KeyboardID, UntrackedOrigin[mut=True]]]()(count)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def get_keyboard_name_for_id(instance_id: KeyboardID, out ret: String) raises:
    """Get the name of a keyboard.

    This function returns "" if the keyboard doesn't have a name.

    Args:
        instance_id: The keyboard instance ID.

    Returns:
        The name of the selected keyboard or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetKeyboardNameForID.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetKeyboardNameForID", def(instance_id: KeyboardID) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(instance_id)
    if not _ffi_ret:
        raise Error(get_error())
    ret = c_string(_ffi_ret.value())


def get_keyboard_focus() raises -> Ptr[Window, UntrackedOrigin[mut=True]]:
    """Query the window which currently has keyboard focus.

    Returns:
        The window with keyboard focus.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetKeyboardFocus.
    """

    return _get_dylib_function[lib, "SDL_GetKeyboardFocus", def() thin abi("C") -> OptPtr[Window, UntrackedOrigin[mut=True]]]()().value()


def get_keyboard_state[O_numkeys: Origin, //](numkeys: Ptr[c_int, O_numkeys]) raises -> Ptr[Bool, UntrackedOrigin[mut=False]]:
    """Get a snapshot of the current state of the keyboard.

    The pointer returned is a pointer to an internal SDL array. It will be
    valid for the whole lifetime of the application and should not be freed by
    the caller.

    A array element with a value of true means that the key is pressed and a
    value of false means that it is not. Indexes into this array are obtained
    by using SDL_Scancode values.

    Use SDL_PumpEvents() to update the state array.

    This function gives you the current state after all events have been
    processed, so if a key or button has been pressed and released before you
    process events, then the pressed state will never show up in the
    SDL_GetKeyboardState() calls.

    Note: This function doesn't take into account whether shift has been
    pressed or not.

    Args:
        numkeys: If non-NULL, receives the length of the returned array.

    Returns:
        A pointer to an array of key states.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetKeyboardState.
    """

    return _get_dylib_function[lib, "SDL_GetKeyboardState", def(numkeys: Ptr[c_int, O_numkeys]) thin abi("C") -> OptPtr[Bool, UntrackedOrigin[mut=False]]]()(numkeys).value()


def reset_keyboard() raises -> None:
    """Clear the state of the keyboard.

    This function will generate key up events for all pressed keys.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ResetKeyboard.
    """

    return _get_dylib_function[lib, "SDL_ResetKeyboard", def() thin abi("C") -> None]()()


def get_mod_state() raises -> Keymod:
    """Get the current key modifier state for the keyboard.

    Returns:
        An OR'd combination of the modifier keys for the keyboard. See
        SDL_Keymod for details.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetModState.
    """

    return _get_dylib_function[lib, "SDL_GetModState", def() thin abi("C") -> Keymod]()()


def set_mod_state(modstate: Keymod) raises -> None:
    """Set the current key modifier state for the keyboard.

    The inverse of SDL_GetModState(), SDL_SetModState() allows you to impose
    modifier key states on your application. Simply pass your desired modifier
    states into `modstate`. This value may be a bitwise, OR'd combination of
    SDL_Keymod values.

    This does not change the keyboard state, only the key modifier flags that
    SDL reports.

    Args:
        modstate: The desired SDL_Keymod for the keyboard.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetModState.
    """

    return _get_dylib_function[lib, "SDL_SetModState", def(modstate: Keymod) thin abi("C") -> None]()(modstate)


def get_key_from_scancode(scancode: Scancode, modstate: Keymod, key_event: Bool) raises -> Keycode:
    """Get the key code corresponding to the given scancode according to the
    current keyboard layout.

    If you want to get the keycode as it would be delivered in key events,
    including options specified in SDL_HINT_KEYCODE_OPTIONS, then you should
    pass `key_event` as true. Otherwise this function simply translates the
    scancode based on the given modifier state.

    Args:
        scancode: The desired SDL_Scancode to query.
        modstate: The modifier state to use when translating the scancode to
                  a keycode.
        key_event: True if the keycode will be used in key events.

    Returns:
        The SDL_Keycode that corresponds to the given SDL_Scancode.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetKeyFromScancode.
    """

    return _get_dylib_function[lib, "SDL_GetKeyFromScancode", def(scancode: Scancode, modstate: Keymod, key_event: Bool) thin abi("C") -> Keycode]()(scancode, modstate, key_event)


def get_scancode_from_key[O_modstate: Origin, //](key: Keycode, modstate: Ptr[Keymod, O_modstate]) raises -> Scancode:
    """Get the scancode corresponding to the given key code according to the
    current keyboard layout.

    Note that there may be multiple scancode+modifier states that can generate
    this keycode, this will just return the first one found.

    Args:
        key: The desired SDL_Keycode to query.
        modstate: A pointer to the modifier state that would be used when the
                  scancode generates this key, may be NULL.

    Returns:
        The SDL_Scancode that corresponds to the given SDL_Keycode.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetScancodeFromKey.
    """

    return _get_dylib_function[lib, "SDL_GetScancodeFromKey", def(key: Keycode, modstate: Ptr[Keymod, O_modstate]) thin abi("C") -> Scancode]()(key, modstate)


def set_scancode_name(scancode: Scancode, var name: String) raises:
    """Set a human-readable name for a scancode.

    Args:
        scancode: The desired SDL_Scancode.
        name: The name to use for the scancode, encoded as UTF-8. The string
              is not copied, so the pointer given to this function must stay
              valid while SDL is being used.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetScancodeName.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetScancodeName", def(scancode: Scancode, name: Ptr[mut=False, c_char, origin_of(name)]) thin abi("C") -> Bool]()(scancode, name.as_c_string_slice().ptr())
    if not _ffi_ret:
        raise Error(get_error())


def get_scancode_name(scancode: Scancode) raises -> String:
    """Get a human-readable name for a scancode.

    **Warning**: The returned name is by design not stable across platforms,
    e.g. the name for `SDL_SCANCODE_LGUI` is "Left GUI" under Linux but "Left
    Windows" under Microsoft Windows, and some scancodes like
    `SDL_SCANCODE_NONUSBACKSLASH` don't have any name at all. There are even
    scancodes that share names, e.g. `SDL_SCANCODE_RETURN` and
    `SDL_SCANCODE_RETURN2` (both called "Return"). This function is therefore
    unsuitable for creating a stable cross-platform two-way mapping between
    strings and scancodes.

    Args:
        scancode: The desired SDL_Scancode to query.

    Returns:
        A pointer to the name for the scancode. If the scancode doesn't
        have a name this function returns an empty string ("").

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetScancodeName.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetScancodeName", def(scancode: Scancode) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(scancode).value())


def get_scancode_from_name(var name: String) raises -> Scancode:
    """Get a scancode from a human-readable name.

    Args:
        name: The human-readable scancode name.

    Returns:
        The SDL_Scancode, or `SDL_SCANCODE_UNKNOWN` if the name wasn't
        recognized; call SDL_GetError() for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetScancodeFromName.
    """

    return _get_dylib_function[lib, "SDL_GetScancodeFromName", def(name: Ptr[mut=False, c_char, origin_of(name)]) thin abi("C") -> Scancode]()(name.as_c_string_slice().ptr())


def get_key_name(key: Keycode) raises -> String:
    """Get a human-readable name for a key.

    If the key doesn't have a name, this function returns an empty string ("").

    Letters will be presented in their uppercase form, if applicable.

    Args:
        key: The desired SDL_Keycode to query.

    Returns:
        A UTF-8 encoded string of the key name.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetKeyName.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetKeyName", def(key: Keycode) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(key).value())


def get_key_from_name(var name: String) raises -> Keycode:
    """Get a key code from a human-readable name.

    Args:
        name: The human-readable key name.

    Returns:
        Key code, or `SDLK_UNKNOWN` if the name wasn't recognized; call
        SDL_GetError() for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetKeyFromName.
    """

    return _get_dylib_function[lib, "SDL_GetKeyFromName", def(name: Ptr[mut=False, c_char, origin_of(name)]) thin abi("C") -> Keycode]()(name.as_c_string_slice().ptr())


def start_text_input[O_window: Origin, //](window: Ptr[Window, O_window]) raises:
    """Start accepting Unicode text input events in a window.

    This function will enable text input (SDL_EVENT_TEXT_INPUT and
    SDL_EVENT_TEXT_EDITING events) in the specified window. Please use this
    function paired with SDL_StopTextInput().

    Text input events are not received by default.

    On some platforms using this function shows the screen keyboard and/or
    activates an IME, which can prevent some key press events from being passed
    through.

    Args:
        window: The window to enable text input.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_StartTextInput.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_StartTextInput", def(window: Ptr[Window, O_window]) thin abi("C") -> Bool]()(window)
    if not _ffi_ret:
        raise Error(get_error())


struct TextInputType(Indexer, Intable, TrivialRegisterPassable):
    """Text input type.

    These are the valid values for SDL_PROP_TEXTINPUT_TYPE_NUMBER. Not every
    value is valid on every platform, but where a value isn't supported, a
    reasonable fallback will be used.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TextInputType.
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

    comptime TEXTINPUT_TYPE_TEXT = Self(0)
    """The input is text."""
    comptime TEXTINPUT_TYPE_TEXT_NAME = Self(1)
    """The input is a person's name."""
    comptime TEXTINPUT_TYPE_TEXT_EMAIL = Self(2)
    """The input is an e-mail address."""
    comptime TEXTINPUT_TYPE_TEXT_USERNAME = Self(3)
    """The input is a username."""
    comptime TEXTINPUT_TYPE_TEXT_PASSWORD_HIDDEN = Self(4)
    """The input is a secure password that is hidden."""
    comptime TEXTINPUT_TYPE_TEXT_PASSWORD_VISIBLE = Self(5)
    """The input is a secure password that is visible."""
    comptime TEXTINPUT_TYPE_NUMBER = Self(6)
    """The input is a number."""
    comptime TEXTINPUT_TYPE_NUMBER_PASSWORD_HIDDEN = Self(7)
    """The input is a secure PIN that is hidden."""
    comptime TEXTINPUT_TYPE_NUMBER_PASSWORD_VISIBLE = Self(8)
    """The input is a secure PIN that is visible."""


struct Capitalization(Indexer, Intable, TrivialRegisterPassable):
    """Auto capitalization type.

    These are the valid values for SDL_PROP_TEXTINPUT_CAPITALIZATION_NUMBER.
    Not every value is valid on every platform, but where a value isn't
    supported, a reasonable fallback will be used.

    Docs: https://wiki.libsdl.org/SDL3/SDL_Capitalization.
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

    comptime CAPITALIZE_NONE = Self(0)
    """No auto-capitalization will be done."""
    comptime CAPITALIZE_SENTENCES = Self(1)
    """The first letter of sentences will be capitalized."""
    comptime CAPITALIZE_WORDS = Self(2)
    """The first letter of words will be capitalized."""
    comptime CAPITALIZE_LETTERS = Self(3)
    """All letters will be capitalized."""


def start_text_input_with_properties[O_window: Origin, //](window: Ptr[Window, O_window], props: PropertiesID) raises:
    """Start accepting Unicode text input events in a window, with properties
    describing the input.

    This function will enable text input (SDL_EVENT_TEXT_INPUT and
    SDL_EVENT_TEXT_EDITING events) in the specified window. Please use this
    function paired with SDL_StopTextInput().

    Text input events are not received by default.

    On some platforms using this function shows the screen keyboard and/or
    activates an IME, which can prevent some key press events from being passed
    through.

    These are the supported properties:

    - `SDL_PROP_TEXTINPUT_TYPE_NUMBER` - an SDL_TextInputType value that
      describes text being input, defaults to SDL_TEXTINPUT_TYPE_TEXT.
    - `SDL_PROP_TEXTINPUT_CAPITALIZATION_NUMBER` - an SDL_Capitalization value
      that describes how text should be capitalized, defaults to
      SDL_CAPITALIZE_SENTENCES for normal text entry, SDL_CAPITALIZE_WORDS for
      SDL_TEXTINPUT_TYPE_TEXT_NAME, and SDL_CAPITALIZE_NONE for e-mail
      addresses, usernames, and passwords.
    - `SDL_PROP_TEXTINPUT_AUTOCORRECT_BOOLEAN` - true to enable auto completion
      and auto correction, defaults to true.
    - `SDL_PROP_TEXTINPUT_MULTILINE_BOOLEAN` - true if multiple lines of text
      are allowed. This defaults to true if SDL_HINT_RETURN_KEY_HIDES_IME is
      "0" or is not set, and defaults to false if SDL_HINT_RETURN_KEY_HIDES_IME
      is "1".

    On Android you can directly specify the input type:

    - `SDL_PROP_TEXTINPUT_ANDROID_INPUTTYPE_NUMBER` - the text input type to
      use, overriding other properties. This is documented at
      https://developer.android.com/reference/android/text/InputType

    Args:
        window: The window to enable text input.
        props: The properties to use.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_StartTextInputWithProperties.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_StartTextInputWithProperties", def(window: Ptr[Window, O_window], props: PropertiesID) thin abi("C") -> Bool]()(window, props)
    if not _ffi_ret:
        raise Error(get_error())


def text_input_active[O_window: Origin, //](window: Ptr[Window, O_window]) raises -> Bool:
    """Check whether or not Unicode text input events are enabled for a window.

    Args:
        window: The window to check.

    Returns:
        True if text input events are enabled else false.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TextInputActive.
    """

    return _get_dylib_function[lib, "SDL_TextInputActive", def(window: Ptr[Window, O_window]) thin abi("C") -> Bool]()(window)


def stop_text_input[O_window: Origin, //](window: Ptr[Window, O_window]) raises:
    """Stop receiving any text input events in a window.

    If SDL_StartTextInput() showed the screen keyboard, this function will hide
    it.

    Args:
        window: The window to disable text input.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_StopTextInput.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_StopTextInput", def(window: Ptr[Window, O_window]) thin abi("C") -> Bool]()(window)
    if not _ffi_ret:
        raise Error(get_error())


def clear_composition[O_window: Origin, //](window: Ptr[Window, O_window]) raises:
    """Dismiss the composition window/IME without disabling the subsystem.

    Args:
        window: The window to affect.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ClearComposition.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_ClearComposition", def(window: Ptr[Window, O_window]) thin abi("C") -> Bool]()(window)
    if not _ffi_ret:
        raise Error(get_error())


def set_text_input_area[O_window: Origin, O_rect: Origin, //](window: Ptr[Window, O_window], rect: Ptr[Rect, O_rect], cursor: c_int) raises:
    """Set the area used to type Unicode text input.

    Native input methods may place a window with word suggestions near the
    cursor, without covering the text being entered.

    Args:
        window: The window for which to set the text input area.
        rect: The SDL_Rect representing the text input area, in window
              coordinates, or NULL to clear it.
        cursor: The offset of the current cursor location relative to
                `rect->x`, in window coordinates.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetTextInputArea.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetTextInputArea", def(window: Ptr[Window, O_window], rect: Ptr[Rect, O_rect], cursor: c_int) thin abi("C") -> Bool]()(window, rect, cursor)
    if not _ffi_ret:
        raise Error(get_error())


def get_text_input_area[O_window: Origin, O_rect: Origin, O_cursor: Origin, //](window: Ptr[Window, O_window], rect: Ptr[Rect, O_rect], cursor: Ptr[c_int, O_cursor]) raises:
    """Get the area used to type Unicode text input.

    This returns the values previously set by SDL_SetTextInputArea().

    Args:
        window: The window for which to query the text input area.
        rect: A pointer to an SDL_Rect filled in with the text input area,
              may be NULL.
        cursor: A pointer to the offset of the current cursor location
                relative to `rect->x`, may be NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTextInputArea.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetTextInputArea", def(window: Ptr[Window, O_window], rect: Ptr[Rect, O_rect], cursor: Ptr[c_int, O_cursor]) thin abi("C") -> Bool]()(window, rect, cursor)
    if not _ffi_ret:
        raise Error(get_error())


def has_screen_keyboard_support() raises -> Bool:
    """Check whether the platform has screen keyboard support.

    Returns:
        True if the platform has some screen keyboard support or false if
        not.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasScreenKeyboardSupport.
    """

    return _get_dylib_function[lib, "SDL_HasScreenKeyboardSupport", def() thin abi("C") -> Bool]()()


def screen_keyboard_shown[O_window: Origin, //](window: Ptr[Window, O_window]) raises -> Bool:
    """Check whether the screen keyboard is shown for given window.

    Args:
        window: The window for which screen keyboard should be queried.

    Returns:
        True if screen keyboard is shown or false if not.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ScreenKeyboardShown.
    """

    return _get_dylib_function[lib, "SDL_ScreenKeyboardShown", def(window: Ptr[Window, O_window]) thin abi("C") -> Bool]()(window)
