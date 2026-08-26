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

"""Properties.

A property is a variable that can be created and retrieved by name at
runtime.

All properties are part of a property group (SDL_PropertiesID). A property
group can be created with the SDL_CreateProperties function and destroyed
with the SDL_DestroyProperties function.

Properties can be added to and retrieved from a property group through the
following functions:

- SDL_SetPointerProperty and SDL_GetPointerProperty operate on `void*`
  pointer types.
- SDL_SetStringProperty and SDL_GetStringProperty operate on string types.
- SDL_SetNumberProperty and SDL_GetNumberProperty operate on signed 64-bit
  integer types.
- SDL_SetFloatProperty and SDL_GetFloatProperty operate on floating point
  types.
- SDL_SetBooleanProperty and SDL_GetBooleanProperty operate on boolean
  types.

Properties can be removed from a group by using SDL_ClearProperty.
"""

from std.ffi import _get_dylib_function, c_char, c_float
from ._core import OptPtr, Ptr, c_string, lib
from .sdl_error import get_error


from std.ffi import _get_dylib_function, c_char, c_float
from ._core import OptPtr, Ptr, c_string, lib
from .sdl_error import get_error


struct PropertiesID(Intable, TrivialRegisterPassable):
    """SDL properties ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PropertiesID.
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


struct PropertyType(Indexer, Intable, TrivialRegisterPassable):
    """SDL property type.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PropertyType.
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

    comptime PROPERTY_TYPE_INVALID = Self(0)
    comptime PROPERTY_TYPE_POINTER = Self(1)
    comptime PROPERTY_TYPE_STRING = Self(2)
    comptime PROPERTY_TYPE_NUMBER = Self(3)
    comptime PROPERTY_TYPE_FLOAT = Self(4)
    comptime PROPERTY_TYPE_BOOLEAN = Self(5)


def get_global_properties() raises -> PropertiesID:
    """Get the global SDL properties.

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGlobalProperties.
    """

    return _get_dylib_function[lib, "SDL_GetGlobalProperties", def() thin abi("C") -> PropertiesID]()()


def create_properties() raises -> PropertiesID:
    """Create a group of properties.

    All properties are automatically destroyed when SDL_Quit() is called.

    Returns:
        An ID for a new group of properties, or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateProperties.
    """

    return _get_dylib_function[lib, "SDL_CreateProperties", def() thin abi("C") -> PropertiesID]()()


def copy_properties(src: PropertiesID, dst: PropertiesID) raises:
    """Copy a group of properties.

    Copy all the properties from one group of properties to another, with the
    exception of properties requiring cleanup (set using
    SDL_SetPointerPropertyWithCleanup()), which will not be copied. Any
    property that already exists on `dst` will be overwritten.

    Args:
        src: The properties to copy.
        dst: The destination properties.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CopyProperties.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_CopyProperties", def(src: PropertiesID, dst: PropertiesID) thin abi("C") -> Bool]()(src, dst)
    if not _ffi_ret:
        raise Error(get_error())


def lock_properties(props: PropertiesID) raises:
    """Lock a group of properties.

    Obtain a multi-threaded lock for these properties. Other threads will wait
    while trying to lock these properties until they are unlocked. Properties
    must be unlocked before they are destroyed.

    The lock is automatically taken when setting individual properties, this
    function is only needed when you want to set several properties atomically
    or want to guarantee that properties being queried aren't freed in another
    thread.

    Args:
        props: The properties to lock.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LockProperties.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_LockProperties", def(props: PropertiesID) thin abi("C") -> Bool]()(props)
    if not _ffi_ret:
        raise Error(get_error())


def unlock_properties(props: PropertiesID) raises -> None:
    """Unlock a group of properties.

    Args:
        props: The properties to unlock.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UnlockProperties.
    """

    return _get_dylib_function[lib, "SDL_UnlockProperties", def(props: PropertiesID) thin abi("C") -> None]()(props)


comptime CleanupPropertyCallback = def(userdata: OptPtr[NoneType, UntrackedOrigin[mut=True]], value: OptPtr[NoneType, UntrackedOrigin[mut=True]]) thin abi("C") -> None
"""A callback used to free resources when a property is deleted.
    
    This should release any resources associated with `value` that are no
    longer needed.
    
    This callback is set per-property. Different properties in the same group
    can have different cleanup callbacks.
    
    This callback will be called _during_ SDL_SetPointerPropertyWithCleanup if
    the function fails for any reason.
    
    Args:
        userdata: An app-defined pointer passed to the callback.
        value: The pointer assigned to the property to clean up.
    
    Safety:
        This callback may fire without any locks held; if this is a
        concern, the app should provide its own locking.

Docs: https://wiki.libsdl.org/SDL3/SDL_CleanupPropertyCallback.
"""


def set_pointer_property_with_cleanup[O_value: Origin, O_userdata: Origin, //](props: PropertiesID, var name: String, value: Ptr[NoneType, O_value], cleanup: CleanupPropertyCallback, userdata: Ptr[NoneType, O_userdata]) raises:
    """Set a pointer property in a group of properties with a cleanup function
    that is called when the property is deleted.

    The cleanup function is also called if setting the property fails for any
    reason.

    For simply setting basic data types, like numbers, bools, or strings, use
    SDL_SetNumberProperty, SDL_SetBooleanProperty, or SDL_SetStringProperty
    instead, as those functions will handle cleanup on your behalf. This
    function is only for more complex, custom data.

    Args:
        props: The properties to modify.
        name: The name of the property to modify.
        value: The new value of the property, or NULL to delete the property.
        cleanup: The function to call when this property is deleted, or NULL
                 if no cleanup is necessary.
        userdata: A pointer that is passed to the cleanup function.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetPointerPropertyWithCleanup.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetPointerPropertyWithCleanup", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], value: Ptr[NoneType, O_value], cleanup: CleanupPropertyCallback, userdata: Ptr[NoneType, O_userdata]) thin abi("C") -> Bool]()(props, name.as_c_string_slice().ptr(), value, cleanup, userdata)
    if not _ffi_ret:
        raise Error(get_error())


def set_pointer_property[O_value: Origin, //](props: PropertiesID, var name: String, value: Ptr[NoneType, O_value]) raises:
    """Set a pointer property in a group of properties.

    Args:
        props: The properties to modify.
        name: The name of the property to modify.
        value: The new value of the property, or NULL to delete the property.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetPointerProperty.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetPointerProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], value: Ptr[NoneType, O_value]) thin abi("C") -> Bool]()(props, name.as_c_string_slice().ptr(), value)
    if not _ffi_ret:
        raise Error(get_error())


def set_string_property(props: PropertiesID, var name: String, var value: String) raises:
    """Set a string property in a group of properties.

    This function makes a copy of the string; the caller does not have to
    preserve the data after this call completes.

    Args:
        props: The properties to modify.
        name: The name of the property to modify.
        value: The new value of the property, or NULL to delete the property.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetStringProperty.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetStringProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], value: Ptr[mut=False, c_char, origin_of(value)]) thin abi("C") -> Bool]()(props, name.as_c_string_slice().ptr(), value.as_c_string_slice().ptr())
    if not _ffi_ret:
        raise Error(get_error())


def set_number_property(props: PropertiesID, var name: String, value: Int64) raises:
    """Set an integer property in a group of properties.

    Args:
        props: The properties to modify.
        name: The name of the property to modify.
        value: The new value of the property.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetNumberProperty.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetNumberProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], value: Int64) thin abi("C") -> Bool]()(props, name.as_c_string_slice().ptr(), value)
    if not _ffi_ret:
        raise Error(get_error())


def set_float_property(props: PropertiesID, var name: String, value: c_float) raises:
    """Set a floating point property in a group of properties.

    Args:
        props: The properties to modify.
        name: The name of the property to modify.
        value: The new value of the property.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetFloatProperty.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetFloatProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], value: c_float) thin abi("C") -> Bool]()(props, name.as_c_string_slice().ptr(), value)
    if not _ffi_ret:
        raise Error(get_error())


def set_boolean_property(props: PropertiesID, var name: String, value: Bool) raises:
    """Set a boolean property in a group of properties.

    Args:
        props: The properties to modify.
        name: The name of the property to modify.
        value: The new value of the property.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetBooleanProperty.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetBooleanProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], value: Bool) thin abi("C") -> Bool]()(props, name.as_c_string_slice().ptr(), value)
    if not _ffi_ret:
        raise Error(get_error())


def has_property(props: PropertiesID, var name: String) raises -> Bool:
    """Return whether a property exists in a group of properties.

    Args:
        props: The properties to query.
        name: The name of the property to query.

    Returns:
        True if the property exists, or false if it doesn't.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasProperty.
    """

    return _get_dylib_function[lib, "SDL_HasProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)]) thin abi("C") -> Bool]()(props, name.as_c_string_slice().ptr())


def get_property_type(props: PropertiesID, var name: String) raises -> PropertyType:
    """Get the type of a property in a group of properties.

    Args:
        props: The properties to query.
        name: The name of the property to query.

    Returns:
        The type of the property, or SDL_PROPERTY_TYPE_INVALID if it is
        not set.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPropertyType.
    """

    return _get_dylib_function[lib, "SDL_GetPropertyType", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)]) thin abi("C") -> PropertyType]()(props, name.as_c_string_slice().ptr())


def get_pointer_property[O_default_value: Origin, //](props: PropertiesID, var name: String, default_value: Ptr[NoneType, O_default_value]) raises -> Ptr[NoneType, UntrackedOrigin[mut=True]]:
    """Get a pointer property from a group of properties.

    By convention, the names of properties that SDL exposes on objects will
    start with "SDL.", and properties that SDL uses internally will start with
    "SDL.internal.". These should be considered read-only and should not be
    modified by applications.

    Args:
        props: The properties to query.
        name: The name of the property to query.
        default_value: The default value of the property.

    Returns:
        The value of the property, or `default_value` if it is not set or
        not a pointer property.

    Safety:
        It is safe to call this function from any thread, although
        the data returned is not protected and could potentially be
        freed if you call SDL_SetPointerProperty() or
        SDL_ClearProperty() on these properties from another thread.
        If you need to avoid this, use SDL_LockProperties() and
        SDL_UnlockProperties().

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPointerProperty.
    """

    return _get_dylib_function[lib, "SDL_GetPointerProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], default_value: Ptr[NoneType, O_default_value]) thin abi("C") -> OptPtr[NoneType, UntrackedOrigin[mut=True]]]()(props, name.as_c_string_slice().ptr(), default_value).value()


def get_string_property(props: PropertiesID, var name: String, var default_value: String) raises -> String:
    """Get a string property from a group of properties.

    Args:
        props: The properties to query.
        name: The name of the property to query.
        default_value: The default value of the property.

    Returns:
        The value of the property, or `default_value` if it is not set or
        not a string property.

    Safety:
        It is safe to call this function from any thread, although
        the data returned is not protected and could potentially be
        freed if you call SDL_SetStringProperty() or
        SDL_ClearProperty() on these properties from another thread.
        If you need to avoid this, use SDL_LockProperties() and
        SDL_UnlockProperties().

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetStringProperty.
    """

    return c_string(_get_dylib_function[lib, "SDL_GetStringProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], default_value: Ptr[mut=False, c_char, origin_of(default_value)]) thin abi("C") -> OptPtr[c_char, UntrackedOrigin[mut=False]]]()(props, name.as_c_string_slice().ptr(), default_value.as_c_string_slice().ptr()).value())


def get_number_property(props: PropertiesID, var name: String, default_value: Int64) raises -> Int64:
    """Get a number property from a group of properties.

    You can use SDL_GetPropertyType() to query whether the property exists and
    is a number property.

    Args:
        props: The properties to query.
        name: The name of the property to query.
        default_value: The default value of the property.

    Returns:
        The value of the property, or `default_value` if it is not set or
        not a number property.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumberProperty.
    """

    return _get_dylib_function[lib, "SDL_GetNumberProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], default_value: Int64) thin abi("C") -> Int64]()(props, name.as_c_string_slice().ptr(), default_value)


def get_float_property(props: PropertiesID, var name: String, default_value: c_float) raises -> c_float:
    """Get a floating point property from a group of properties.

    You can use SDL_GetPropertyType() to query whether the property exists and
    is a floating point property.

    Args:
        props: The properties to query.
        name: The name of the property to query.
        default_value: The default value of the property.

    Returns:
        The value of the property, or `default_value` if it is not set or
        not a float property.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetFloatProperty.
    """

    return _get_dylib_function[lib, "SDL_GetFloatProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], default_value: c_float) thin abi("C") -> c_float]()(props, name.as_c_string_slice().ptr(), default_value)


def get_boolean_property(props: PropertiesID, var name: String, default_value: Bool) raises -> Bool:
    """Get a boolean property from a group of properties.

    You can use SDL_GetPropertyType() to query whether the property exists and
    is a boolean property.

    Args:
        props: The properties to query.
        name: The name of the property to query.
        default_value: The default value of the property.

    Returns:
        The value of the property, or `default_value` if it is not set or
        not a boolean property.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetBooleanProperty.
    """

    return _get_dylib_function[lib, "SDL_GetBooleanProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)], default_value: Bool) thin abi("C") -> Bool]()(props, name.as_c_string_slice().ptr(), default_value)


def clear_property(props: PropertiesID, var name: String) raises:
    """Clear a property from a group of properties.

    Args:
        props: The properties to modify.
        name: The name of the property to clear.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ClearProperty.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_ClearProperty", def(props: PropertiesID, name: Ptr[mut=False, c_char, origin_of(name)]) thin abi("C") -> Bool]()(props, name.as_c_string_slice().ptr())
    if not _ffi_ret:
        raise Error(get_error())


comptime EnumeratePropertiesCallback = def(userdata: OptPtr[NoneType, UntrackedOrigin[mut=True]], props: PropertiesID, name: OptPtr[c_char, UntrackedOrigin[mut=False]]) thin abi("C") -> None
"""A callback used to enumerate all the properties in a group of properties.
    
    This callback is called from SDL_EnumerateProperties(), and is called once
    per property in the set.
    
    Args:
        userdata: An app-defined pointer passed to the callback.
        props: The SDL_PropertiesID that is being enumerated.
        name: The next property name in the enumeration.
    
    Safety:
        SDL_EnumerateProperties holds a lock on `props` during this
        callback.

Docs: https://wiki.libsdl.org/SDL3/SDL_EnumeratePropertiesCallback.
"""


def enumerate_properties[O_userdata: Origin, //](props: PropertiesID, callback: EnumeratePropertiesCallback, userdata: Ptr[NoneType, O_userdata]) raises:
    """Enumerate the properties contained in a group of properties.

    The callback function is called for each property in the group of
    properties. The properties are locked during enumeration.

    Args:
        props: The properties to query.
        callback: The function to call for each property.
        userdata: A pointer that is passed to `callback`.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EnumerateProperties.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_EnumerateProperties", def(props: PropertiesID, callback: EnumeratePropertiesCallback, userdata: Ptr[NoneType, O_userdata]) thin abi("C") -> Bool]()(props, callback, userdata)
    if not _ffi_ret:
        raise Error(get_error())


def destroy_properties(props: PropertiesID) raises -> None:
    """Destroy a group of properties.

    All properties are deleted and their cleanup functions will be called, if
    any.

    Args:
        props: The properties to destroy.

    Safety:
        This function should not be called while these properties are
        locked or other threads might be setting or getting values
        from these properties.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyProperties.
    """

    return _get_dylib_function[lib, "SDL_DestroyProperties", def(props: PropertiesID) thin abi("C") -> None]()(props)
