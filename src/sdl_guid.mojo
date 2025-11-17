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

"""GUID

A GUID is a 128-bit value that represents something that is uniquely
identifiable by this value: "globally unique."

SDL provides functions to convert a GUID to/from a string.
"""


@fieldwise_init
struct GUID(ImplicitlyCopyable, Movable):
    """An SDL_GUID is a 128-bit identifier for an input device that identifies
    that device across runs of SDL programs on the same platform.

    If the device is detached and then re-attached to a different port, or if
    the base system is rebooted, the device should still report the same GUID.

    GUIDs are as precise as possible but are not guaranteed to distinguish
    physically distinct but equivalent devices. For example, two game
    controllers from the same vendor with the same product ID and revision may
    have the same GUID.

    GUIDs may be platform-dependent (i.e., the same device may report different
    GUIDs on different operating systems).

    Docs: https://wiki.libsdl.org/SDL3/GUID.
    """

    var data: ArrayHelper[UInt8, 16, AnyOrigin[True]].result


fn guid_to_string(guid: GUID, psz_guid: Ptr[c_char, AnyOrigin[True]], cb_guid: c_int) raises -> None:
    """Get an ASCII string representation for a given SDL_GUID.

    Args:
        guid: The SDL_GUID you wish to convert to string.
        psz_guid: Buffer in which to write the ASCII string.
        cb_guid: The size of pszGUID, should be at least 33 bytes.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GUIDToString.
    """

    return _get_dylib_function[lib, "SDL_GUIDToString", fn (guid: GUID, psz_guid: Ptr[c_char, AnyOrigin[True]], cb_guid: c_int) -> None]()(guid, psz_guid, cb_guid)


fn string_to_guid(var pch_guid: String) raises -> GUID:
    """Convert a GUID string into a SDL_GUID structure.

    Performs no error checking. If this function is given a string containing
    an invalid GUID, the function will silently succeed, but the GUID generated
    will not be useful.

    Args:
        pch_guid: String containing an ASCII representation of a GUID.

    Returns:
        A SDL_GUID structure.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_StringToGUID.
    """

    return _get_dylib_function[lib, "SDL_StringToGUID", fn (pch_guid: Ptr[c_char, AnyOrigin[False]]) -> GUID]()(pch_guid.unsafe_cstr_ptr())
