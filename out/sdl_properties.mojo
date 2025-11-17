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

"""Properties

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


@register_passable("trivial")
struct PropertiesID(Intable):
    """SDL properties ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PropertiesID.
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
struct PropertyType(Indexer, Intable):
    """SDL property type.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PropertyType.
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

    comptime PROPERTY_TYPE_INVALID = Self(0)
    comptime PROPERTY_TYPE_POINTER = Self(1)
    comptime PROPERTY_TYPE_STRING = Self(2)
    comptime PROPERTY_TYPE_NUMBER = Self(3)
    comptime PROPERTY_TYPE_FLOAT = Self(4)
    comptime PROPERTY_TYPE_BOOLEAN = Self(5)


fn get_global_properties() raises -> PropertiesID:
    """Get the global SDL properties.

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGlobalProperties.
    """

    return _get_dylib_function[lib, "SDL_GetGlobalProperties", fn () -> PropertiesID]()()


fn create_properties() raises -> PropertiesID:
    """Create a group of properties.

    All properties are automatically destroyed when SDL_Quit() is called.

    Returns:
        An ID for a new group of properties, or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateProperties.
    """

    return _get_dylib_function[lib, "SDL_CreateProperties", fn () -> PropertiesID]()()


fn copy_properties(src: PropertiesID, dst: PropertiesID) raises:
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

    ret = _get_dylib_function[lib, "SDL_CopyProperties", fn (src: PropertiesID, dst: PropertiesID) -> Bool]()(src, dst)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn lock_properties(props: PropertiesID) raises:
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

    ret = _get_dylib_function[lib, "SDL_LockProperties", fn (props: PropertiesID) -> Bool]()(props)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn unlock_properties(props: PropertiesID) raises -> None:
    """Unlock a group of properties.

    Args:
        props: The properties to unlock.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UnlockProperties.
    """

    return _get_dylib_function[lib, "SDL_UnlockProperties", fn (props: PropertiesID) -> None]()(props)


comptime CleanupPropertyCallback = fn (userdata: Ptr[NoneType, AnyOrigin[True]], value: Ptr[NoneType, AnyOrigin[True]]) -> None
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


fn set_pointer_property_with_cleanup(props: PropertiesID, var name: String, value: Ptr[NoneType, AnyOrigin[True]], cleanup: CleanupPropertyCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetPointerPropertyWithCleanup", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], value: Ptr[NoneType, AnyOrigin[True]], cleanup: CleanupPropertyCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) -> Bool]()(props, name.unsafe_cstr_ptr(), value, cleanup, userdata)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_pointer_property(props: PropertiesID, var name: String, value: Ptr[NoneType, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetPointerProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], value: Ptr[NoneType, AnyOrigin[True]]) -> Bool]()(props, name.unsafe_cstr_ptr(), value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_string_property(props: PropertiesID, var name: String, var value: String) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetStringProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], value: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(props, name.unsafe_cstr_ptr(), value.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_number_property(props: PropertiesID, var name: String, value: Int64) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetNumberProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], value: Int64) -> Bool]()(props, name.unsafe_cstr_ptr(), value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_float_property(props: PropertiesID, var name: String, value: c_float) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetFloatProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], value: c_float) -> Bool]()(props, name.unsafe_cstr_ptr(), value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_boolean_property(props: PropertiesID, var name: String, value: Bool) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetBooleanProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], value: Bool) -> Bool]()(props, name.unsafe_cstr_ptr(), value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn has_property(props: PropertiesID, var name: String) raises -> Bool:
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

    return _get_dylib_function[lib, "SDL_HasProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(props, name.unsafe_cstr_ptr())


fn get_property_type(props: PropertiesID, var name: String) raises -> PropertyType:
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

    return _get_dylib_function[lib, "SDL_GetPropertyType", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]]) -> PropertyType]()(props, name.unsafe_cstr_ptr())


fn get_pointer_property(props: PropertiesID, var name: String, default_value: Ptr[NoneType, AnyOrigin[True]]) raises -> Ptr[NoneType, AnyOrigin[True]]:
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

    return _get_dylib_function[lib, "SDL_GetPointerProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], default_value: Ptr[NoneType, AnyOrigin[True]]) -> Ptr[NoneType, AnyOrigin[True]]]()(props, name.unsafe_cstr_ptr(), default_value)


fn get_string_property(props: PropertiesID, var name: String, var default_value: String) raises -> Ptr[c_char, AnyOrigin[False]]:
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

    return _get_dylib_function[lib, "SDL_GetStringProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], default_value: Ptr[c_char, AnyOrigin[False]]) -> Ptr[c_char, AnyOrigin[False]]]()(props, name.unsafe_cstr_ptr(), default_value.unsafe_cstr_ptr())


fn get_number_property(props: PropertiesID, var name: String, default_value: Int64) raises -> Int64:
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

    return _get_dylib_function[lib, "SDL_GetNumberProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], default_value: Int64) -> Int64]()(props, name.unsafe_cstr_ptr(), default_value)


fn get_float_property(props: PropertiesID, var name: String, default_value: c_float) raises -> c_float:
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

    return _get_dylib_function[lib, "SDL_GetFloatProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], default_value: c_float) -> c_float]()(props, name.unsafe_cstr_ptr(), default_value)


fn get_boolean_property(props: PropertiesID, var name: String, default_value: Bool) raises -> Bool:
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

    return _get_dylib_function[lib, "SDL_GetBooleanProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]], default_value: Bool) -> Bool]()(props, name.unsafe_cstr_ptr(), default_value)


fn clear_property(props: PropertiesID, var name: String) raises:
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

    ret = _get_dylib_function[lib, "SDL_ClearProperty", fn (props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(props, name.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


comptime EnumeratePropertiesCallback = fn (userdata: Ptr[NoneType, AnyOrigin[True]], props: PropertiesID, name: Ptr[c_char, AnyOrigin[False]]) -> None
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


fn enumerate_properties(props: PropertiesID, callback: EnumeratePropertiesCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_EnumerateProperties", fn (props: PropertiesID, callback: EnumeratePropertiesCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) -> Bool]()(props, callback, userdata)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn destroy_properties(props: PropertiesID) raises -> None:
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

    return _get_dylib_function[lib, "SDL_DestroyProperties", fn (props: PropertiesID) -> None]()(props)
