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

"""Keyboard

SDL keyboard management.

Please refer to the Best Keyboard Practices document for details on how
best to accept keyboard input in various types of programs:

https://wiki.libsdl.org/SDL3/BestKeyboardPractices
"""


@register_passable("trivial")
struct KeyboardID(Intable):
    """This is a unique ID for a keyboard for the time it is connected to the
    system, and is never reused for the lifetime of the application.

    If the keyboard is disconnected and reconnected, it will get a new ID.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_KeyboardID.
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


fn has_keyboard() raises -> Bool:
    """Return whether a keyboard is currently connected.

    Returns:
        True if a keyboard is connected, false otherwise.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasKeyboard.
    """

    return _get_dylib_function[lib, "SDL_HasKeyboard", fn () -> Bool]()()


fn get_keyboards(count: Ptr[c_int, AnyOrigin[True]], out ret: Ptr[KeyboardID, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetKeyboards", fn (count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[KeyboardID, AnyOrigin[True]]]()(count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_keyboard_name_for_id(instance_id: KeyboardID, out ret: Ptr[c_char, AnyOrigin[False]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetKeyboardNameForID", fn (instance_id: KeyboardID) -> Ptr[c_char, AnyOrigin[False]]]()(instance_id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_keyboard_focus() raises -> Ptr[Window, AnyOrigin[True]]:
    """Query the window which currently has keyboard focus.

    Returns:
        The window with keyboard focus.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetKeyboardFocus.
    """

    return _get_dylib_function[lib, "SDL_GetKeyboardFocus", fn () -> Ptr[Window, AnyOrigin[True]]]()()


fn get_keyboard_state(numkeys: Ptr[c_int, AnyOrigin[True]]) raises -> Ptr[Bool, AnyOrigin[False]]:
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

    return _get_dylib_function[lib, "SDL_GetKeyboardState", fn (numkeys: Ptr[c_int, AnyOrigin[True]]) -> Ptr[Bool, AnyOrigin[False]]]()(numkeys)


fn reset_keyboard() raises -> None:
    """Clear the state of the keyboard.

    This function will generate key up events for all pressed keys.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ResetKeyboard.
    """

    return _get_dylib_function[lib, "SDL_ResetKeyboard", fn () -> None]()()


fn get_mod_state() raises -> Keymod:
    """Get the current key modifier state for the keyboard.

    Returns:
        An OR'd combination of the modifier keys for the keyboard. See
        SDL_Keymod for details.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetModState.
    """

    return _get_dylib_function[lib, "SDL_GetModState", fn () -> Keymod]()()


fn set_mod_state(modstate: Keymod) raises -> None:
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

    return _get_dylib_function[lib, "SDL_SetModState", fn (modstate: Keymod) -> None]()(modstate)


fn get_key_from_scancode(scancode: Scancode, modstate: Keymod, key_event: Bool) raises -> Keycode:
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

    return _get_dylib_function[lib, "SDL_GetKeyFromScancode", fn (scancode: Scancode, modstate: Keymod, key_event: Bool) -> Keycode]()(scancode, modstate, key_event)


fn get_scancode_from_key(key: Keycode, modstate: Ptr[Keymod, AnyOrigin[True]]) raises -> Scancode:
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

    return _get_dylib_function[lib, "SDL_GetScancodeFromKey", fn (key: Keycode, modstate: Ptr[Keymod, AnyOrigin[True]]) -> Scancode]()(key, modstate)


fn set_scancode_name(scancode: Scancode, var name: String) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetScancodeName", fn (scancode: Scancode, name: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(scancode, name.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_scancode_name(scancode: Scancode) raises -> Ptr[c_char, AnyOrigin[False]]:
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

    return _get_dylib_function[lib, "SDL_GetScancodeName", fn (scancode: Scancode) -> Ptr[c_char, AnyOrigin[False]]]()(scancode)


fn get_scancode_from_name(var name: String) raises -> Scancode:
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

    return _get_dylib_function[lib, "SDL_GetScancodeFromName", fn (name: Ptr[c_char, AnyOrigin[False]]) -> Scancode]()(name.unsafe_cstr_ptr())


fn get_key_name(key: Keycode) raises -> Ptr[c_char, AnyOrigin[False]]:
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

    return _get_dylib_function[lib, "SDL_GetKeyName", fn (key: Keycode) -> Ptr[c_char, AnyOrigin[False]]]()(key)


fn get_key_from_name(var name: String) raises -> Keycode:
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

    return _get_dylib_function[lib, "SDL_GetKeyFromName", fn (name: Ptr[c_char, AnyOrigin[False]]) -> Keycode]()(name.unsafe_cstr_ptr())


fn start_text_input(window: Ptr[Window, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_StartTextInput", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


@register_passable("trivial")
struct TextInputType(Indexer, Intable):
    """Text input type.

    These are the valid values for SDL_PROP_TEXTINPUT_TYPE_NUMBER. Not every
    value is valid on every platform, but where a value isn't supported, a
    reasonable fallback will be used.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TextInputType.
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


@register_passable("trivial")
struct Capitalization(Indexer, Intable):
    """Auto capitalization type.

    These are the valid values for SDL_PROP_TEXTINPUT_CAPITALIZATION_NUMBER.
    Not every value is valid on every platform, but where a value isn't
    supported, a reasonable fallback will be used.

    Docs: https://wiki.libsdl.org/SDL3/SDL_Capitalization.
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

    comptime CAPITALIZE_NONE = Self(0)
    """No auto-capitalization will be done."""
    comptime CAPITALIZE_SENTENCES = Self(1)
    """The first letter of sentences will be capitalized."""
    comptime CAPITALIZE_WORDS = Self(2)
    """The first letter of words will be capitalized."""
    comptime CAPITALIZE_LETTERS = Self(3)
    """All letters will be capitalized."""


fn start_text_input_with_properties(window: Ptr[Window, AnyOrigin[True]], props: PropertiesID) raises:
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

    ret = _get_dylib_function[lib, "SDL_StartTextInputWithProperties", fn (window: Ptr[Window, AnyOrigin[True]], props: PropertiesID) -> Bool]()(window, props)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn text_input_active(window: Ptr[Window, AnyOrigin[True]]) raises -> Bool:
    """Check whether or not Unicode text input events are enabled for a window.

    Args:
        window: The window to check.

    Returns:
        True if text input events are enabled else false.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TextInputActive.
    """

    return _get_dylib_function[lib, "SDL_TextInputActive", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)


fn stop_text_input(window: Ptr[Window, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_StopTextInput", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn clear_composition(window: Ptr[Window, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_ClearComposition", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_text_input_area(window: Ptr[Window, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], cursor: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetTextInputArea", fn (window: Ptr[Window, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], cursor: c_int) -> Bool]()(window, rect, cursor)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_text_input_area(window: Ptr[Window, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]], cursor: Ptr[c_int, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetTextInputArea", fn (window: Ptr[Window, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]], cursor: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(window, rect, cursor)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn has_screen_keyboard_support() raises -> Bool:
    """Check whether the platform has screen keyboard support.

    Returns:
        True if the platform has some screen keyboard support or false if
        not.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasScreenKeyboardSupport.
    """

    return _get_dylib_function[lib, "SDL_HasScreenKeyboardSupport", fn () -> Bool]()()


fn screen_keyboard_shown(window: Ptr[Window, AnyOrigin[True]]) raises -> Bool:
    """Check whether the screen keyboard is shown for given window.

    Args:
        window: The window for which screen keyboard should be queried.

    Returns:
        True if screen keyboard is shown or false if not.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ScreenKeyboardShown.
    """

    return _get_dylib_function[lib, "SDL_ScreenKeyboardShown", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
