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

"""Clipboard

SDL provides access to the system clipboard, both for reading information
from other processes and publishing information of its own.

This is not just text! SDL apps can access and publish data by mimetype.

## Basic use (text)

Obtaining and publishing simple text to the system clipboard is as easy as
calling SDL_GetClipboardText() and SDL_SetClipboardText(), respectively.
These deal with C strings in UTF-8 encoding. Data transmission and encoding
conversion is completely managed by SDL.

## Clipboard callbacks (data other than text)

Things get more complicated when the clipboard contains something other
than text. Not only can the system clipboard contain data of any type, in
some cases it can contain the same data in different formats! For example,
an image painting app might let the user copy a graphic to the clipboard,
and offers it in .BMP, .JPG, or .PNG format for other apps to consume.

Obtaining clipboard data ("pasting") like this is a matter of calling
SDL_GetClipboardData() and telling it the mimetype of the data you want.
But how does one know if that format is available? SDL_HasClipboardData()
can report if a specific mimetype is offered, and
SDL_GetClipboardMimeTypes() can provide the entire list of mimetypes
available, so the app can decide what to do with the data and what formats
it can support.

Setting the clipboard ("copying") to arbitrary data is done with
SDL_SetClipboardData. The app does not provide the data in this call, but
rather the mimetypes it is willing to provide and a callback function.
During the callback, the app will generate the data. This allows massive
data sets to be provided to the clipboard, without any data being copied
before it is explicitly requested. More specifically, it allows an app to
offer data in multiple formats without providing a copy of all of them
upfront. If the app has an image that it could provide in PNG or JPG
format, it doesn't have to encode it to either of those unless and until
something tries to paste it.

## Primary Selection

The X11 and Wayland video targets have a concept of the "primary selection"
in addition to the usual clipboard. This is generally highlighted (but not
explicitly copied) text from various apps. SDL offers APIs for this through
SDL_GetPrimarySelectionText() and SDL_SetPrimarySelectionText(). SDL offers
these APIs on platforms without this concept, too, but only so far that it
will keep a copy of a string that the app sets for later retrieval; the
operating system will not ever attempt to change the string externally if
it doesn't support a primary selection.
"""


fn set_clipboard_text(var text: String) raises:
    """Put UTF-8 text into the clipboard.

    Args:
        text: The text to store in the clipboard.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetClipboardText.
    """

    ret = _get_dylib_function[lib, "SDL_SetClipboardText", fn (text: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(text.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_clipboard_text(out ret: Ptr[c_char, AnyOrigin[True]]) raises:
    """Get UTF-8 text from the clipboard.

    This function returns an empty string if there is not enough memory left
    for a copy of the clipboard's content.

    Returns:
        The clipboard text on success or an empty string on failure; call
        SDL_GetError() for more information. This should be freed with
        SDL_free() when it is no longer needed.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetClipboardText.
    """

    ret = _get_dylib_function[lib, "SDL_GetClipboardText", fn () -> Ptr[c_char, AnyOrigin[True]]]()()
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn has_clipboard_text() raises -> Bool:
    """Query whether the clipboard exists and contains a non-empty text string.

    Returns:
        True if the clipboard has text, or false if it does not.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasClipboardText.
    """

    return _get_dylib_function[lib, "SDL_HasClipboardText", fn () -> Bool]()()


fn set_primary_selection_text(var text: String) raises:
    """Put UTF-8 text into the primary selection.

    Args:
        text: The text to store in the primary selection.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetPrimarySelectionText.
    """

    ret = _get_dylib_function[lib, "SDL_SetPrimarySelectionText", fn (text: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(text.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_primary_selection_text() raises -> Ptr[c_char, AnyOrigin[True]]:
    """Get UTF-8 text from the primary selection.

    This function returns an empty string if there is not enough memory left
    for a copy of the primary selection's content.

    Returns:
        The primary selection text on success or an empty string on
        failure; call SDL_GetError() for more information. This should be
        freed with SDL_free() when it is no longer needed.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPrimarySelectionText.
    """

    return _get_dylib_function[lib, "SDL_GetPrimarySelectionText", fn () -> Ptr[c_char, AnyOrigin[True]]]()()


fn has_primary_selection_text() raises -> Bool:
    """Query whether the primary selection exists and contains a non-empty text
    string.

    Returns:
        True if the primary selection has text, or false if it does not.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasPrimarySelectionText.
    """

    return _get_dylib_function[lib, "SDL_HasPrimarySelectionText", fn () -> Bool]()()


comptime ClipboardDataCallback = Ptr[fn (userdata: Ptr[NoneType, AnyOrigin[True]], mime_type: Ptr[c_char, AnyOrigin[False]], size: Ptr[c_size_t, AnyOrigin[True]]) -> None, AnyOrigin[True]]
"""Callback function that will be called when data for the specified mime-type
    is requested by the OS.
    
    The callback function is called with NULL as the mime_type when the
    clipboard is cleared or new data is set. The clipboard is automatically
    cleared in SDL_Quit().
    
    Args:
        userdata: A pointer to the provided user data.
        mime_type: The requested mime-type.
        size: A pointer filled in with the length of the returned data.
    
    Returns:
        A pointer to the data for the provided mime-type. Returning NULL
        or setting the length to 0 will cause zero length data to be sent
        to the "receiver", which should be able to handle this. The
        returned data will not be freed, so it needs to be retained and
        dealt with internally.

Docs: https://wiki.libsdl.org/SDL3/SDL_ClipboardDataCallback.
"""


comptime ClipboardCleanupCallback = fn (userdata: Ptr[NoneType, AnyOrigin[True]]) -> None
"""Callback function that will be called when the clipboard is cleared, or when new
    data is set.
    
    Args:
        userdata: A pointer to the provided user data.

Docs: https://wiki.libsdl.org/SDL3/SDL_ClipboardCleanupCallback.
"""


fn set_clipboard_data(callback: ClipboardDataCallback, cleanup: ClipboardCleanupCallback, userdata: Ptr[NoneType, AnyOrigin[True]], mime_types: Ptr[Ptr[c_char, AnyOrigin[False]], AnyOrigin[False]], num_mime_types: c_size_t) raises:
    """Offer clipboard data to the OS.

    Tell the operating system that the application is offering clipboard data
    for each of the provided mime-types. Once another application requests the
    data the callback function will be called, allowing it to generate and
    respond with the data for the requested mime-type.

    The size of text data does not include any terminator, and the text does
    not need to be null-terminated (e.g., you can directly copy a portion of a
    document).

    Args:
        callback: A function pointer to the function that provides the
                  clipboard data.
        cleanup: A function pointer to the function that cleans up the
                 clipboard data.
        userdata: An opaque pointer that will be forwarded to the callbacks.
        mime_types: A list of mime-types that are being offered. SDL copies the given list.
        num_mime_types: The number of mime-types in the mime_types list.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetClipboardData.
    """

    ret = _get_dylib_function[lib, "SDL_SetClipboardData", fn (callback: ClipboardDataCallback, cleanup: ClipboardCleanupCallback, userdata: Ptr[NoneType, AnyOrigin[True]], mime_types: Ptr[Ptr[c_char, AnyOrigin[False]], AnyOrigin[False]], num_mime_types: c_size_t) -> Bool]()(callback, cleanup, userdata, mime_types, num_mime_types)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn clear_clipboard_data() raises:
    """Clear the clipboard data.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ClearClipboardData.
    """

    ret = _get_dylib_function[lib, "SDL_ClearClipboardData", fn () -> Bool]()()
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_clipboard_data(var mime_type: String, size: Ptr[c_size_t, AnyOrigin[True]], out ret: Ptr[NoneType, AnyOrigin[True]]) raises:
    """Get the data from the clipboard for a given mime type.

    The size of text data does not include the terminator, but the text is
    guaranteed to be null-terminated.

    Args:
        mime_type: The mime type to read from the clipboard.
        size: A pointer filled in with the length of the returned data.

    Returns:
        The retrieved data buffer or NULL on failure; call SDL_GetError()
        for more information. This should be freed with SDL_free() when it
        is no longer needed.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetClipboardData.
    """

    ret = _get_dylib_function[lib, "SDL_GetClipboardData", fn (mime_type: Ptr[c_char, AnyOrigin[False]], size: Ptr[c_size_t, AnyOrigin[True]]) -> Ptr[NoneType, AnyOrigin[True]]]()(mime_type.unsafe_cstr_ptr(), size)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn has_clipboard_data(var mime_type: String) raises -> Bool:
    """Query whether there is data in the clipboard for the provided mime type.

    Args:
        mime_type: The mime type to check for data.

    Returns:
        True if data exists in the clipboard for the provided mime type,
        false if it does not.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasClipboardData.
    """

    return _get_dylib_function[lib, "SDL_HasClipboardData", fn (mime_type: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(mime_type.unsafe_cstr_ptr())


fn get_clipboard_mime_types(num_mime_types: Ptr[c_size_t, AnyOrigin[True]]) raises -> Ptr[Ptr[c_char, AnyOrigin[True]], AnyOrigin[True]]:
    """Retrieve the list of mime types available in the clipboard.

    Args:
        num_mime_types: A pointer filled with the number of mime types, may
                        be NULL.

    Returns:
        A null-terminated array of strings with mime types, or NULL on
        failure; call SDL_GetError() for more information. This should be
        freed with SDL_free() when it is no longer needed.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetClipboardMimeTypes.
    """

    return _get_dylib_function[lib, "SDL_GetClipboardMimeTypes", fn (num_mime_types: Ptr[c_size_t, AnyOrigin[True]]) -> Ptr[Ptr[c_char, AnyOrigin[True]], AnyOrigin[True]]]()(num_mime_types)
