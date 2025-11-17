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

"""Sensor

SDL sensor management.

These APIs grant access to gyros and accelerometers on various platforms.

In order to use these functions, SDL_Init() must have been called with the
SDL_INIT_SENSOR flag. This causes SDL to scan the system for sensors, and
load appropriate drivers.
"""


@fieldwise_init
struct Sensor(ImplicitlyCopyable, Movable):
    """The opaque structure used to identify an opened SDL sensor.

    Docs: https://wiki.libsdl.org/SDL3/Sensor.
    """

    pass


@register_passable("trivial")
struct SensorID(Intable):
    """This is a unique ID for a sensor for the time it is connected to the
    system, and is never reused for the lifetime of the application.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SensorID.
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
struct SensorType(Indexer, Intable):
    """The different sensors defined by SDL.

    Additional sensors may be available, using platform dependent semantics.

    Here are the additional Android sensors:

    https://developer.android.com/reference/android/hardware/SensorEvent.html#values

    Accelerometer sensor notes:

    The accelerometer returns the current acceleration in SI meters per second
    squared. This measurement includes the force of gravity, so a device at
    rest will have an value of SDL_STANDARD_GRAVITY away from the center of the
    earth, which is a positive Y value.

    - `values[0]`: Acceleration on the x axis
    - `values[1]`: Acceleration on the y axis
    - `values[2]`: Acceleration on the z axis

    For phones and tablets held in natural orientation and game controllers
    held in front of you, the axes are defined as follows:

    - -X ... +X : left ... right
    - -Y ... +Y : bottom ... top
    - -Z ... +Z : farther ... closer

    The accelerometer axis data is not changed when the device is rotated.

    Gyroscope sensor notes:

    The gyroscope returns the current rate of rotation in radians per second.
    The rotation is positive in the counter-clockwise direction. That is, an
    observer looking from a positive location on one of the axes would see
    positive rotation on that axis when it appeared to be rotating
    counter-clockwise.

    - `values[0]`: Angular speed around the x axis (pitch)
    - `values[1]`: Angular speed around the y axis (yaw)
    - `values[2]`: Angular speed around the z axis (roll)

    For phones and tablets held in natural orientation and game controllers
    held in front of you, the axes are defined as follows:

    - -X ... +X : left ... right
    - -Y ... +Y : bottom ... top
    - -Z ... +Z : farther ... closer

    The gyroscope axis data is not changed when the device is rotated.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SensorType.
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

    comptime SENSOR_INVALID = Self(-1)
    """Returned for an invalid sensor."""
    comptime SENSOR_UNKNOWN = Self(0)
    """Unknown sensor type."""
    comptime SENSOR_ACCEL = Self(1)
    """Accelerometer."""
    comptime SENSOR_GYRO = Self(2)
    """Gyroscope."""
    comptime SENSOR_ACCEL_L = Self(3)
    """Accelerometer for left Joy-Con controller and Wii nunchuk."""
    comptime SENSOR_GYRO_L = Self(4)
    """Gyroscope for left Joy-Con controller."""
    comptime SENSOR_ACCEL_R = Self(5)
    """Accelerometer for right Joy-Con controller."""
    comptime SENSOR_GYRO_R = Self(6)
    """Gyroscope for right Joy-Con controller."""
    comptime SENSOR_COUNT = Self(7)


fn get_sensors(count: Ptr[c_int, AnyOrigin[True]], out ret: Ptr[SensorID, AnyOrigin[True]]) raises:
    """Get a list of currently connected sensors.

    Args:
        count: A pointer filled in with the number of sensors returned, may
               be NULL.

    Returns:
        A 0 terminated array of sensor instance IDs or NULL on failure;
        call SDL_GetError() for more information. This should be freed
        with SDL_free() when it is no longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensors.
    """

    ret = _get_dylib_function[lib, "SDL_GetSensors", fn (count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[SensorID, AnyOrigin[True]]]()(count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_sensor_name_for_id(instance_id: SensorID) raises -> Ptr[c_char, AnyOrigin[False]]:
    """Get the implementation dependent name of a sensor.

    This can be called before any sensors are opened.

    Args:
        instance_id: The sensor instance ID.

    Returns:
        The sensor name, or NULL if `instance_id` is not valid.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensorNameForID.
    """

    return _get_dylib_function[lib, "SDL_GetSensorNameForID", fn (instance_id: SensorID) -> Ptr[c_char, AnyOrigin[False]]]()(instance_id)


fn get_sensor_type_for_id(instance_id: SensorID) raises -> SensorType:
    """Get the type of a sensor.

    This can be called before any sensors are opened.

    Args:
        instance_id: The sensor instance ID.

    Returns:
        The SDL_SensorType, or `SDL_SENSOR_INVALID` if `instance_id` is
        not valid.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensorTypeForID.
    """

    return _get_dylib_function[lib, "SDL_GetSensorTypeForID", fn (instance_id: SensorID) -> SensorType]()(instance_id)


fn get_sensor_non_portable_type_for_id(instance_id: SensorID) raises -> c_int:
    """Get the platform dependent type of a sensor.

    This can be called before any sensors are opened.

    Args:
        instance_id: The sensor instance ID.

    Returns:
        The sensor platform dependent type, or -1 if `instance_id` is not
        valid.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensorNonPortableTypeForID.
    """

    return _get_dylib_function[lib, "SDL_GetSensorNonPortableTypeForID", fn (instance_id: SensorID) -> c_int]()(instance_id)


fn open_sensor(instance_id: SensorID, out ret: Ptr[Sensor, AnyOrigin[True]]) raises:
    """Open a sensor for use.

    Args:
        instance_id: The sensor instance ID.

    Returns:
        An SDL_Sensor object or NULL on failure; call SDL_GetError() for
        more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenSensor.
    """

    ret = _get_dylib_function[lib, "SDL_OpenSensor", fn (instance_id: SensorID) -> Ptr[Sensor, AnyOrigin[True]]]()(instance_id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_sensor_from_id(instance_id: SensorID, out ret: Ptr[Sensor, AnyOrigin[True]]) raises:
    """Return the SDL_Sensor associated with an instance ID.

    Args:
        instance_id: The sensor instance ID.

    Returns:
        An SDL_Sensor object or NULL on failure; call SDL_GetError() for
        more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensorFromID.
    """

    ret = _get_dylib_function[lib, "SDL_GetSensorFromID", fn (instance_id: SensorID) -> Ptr[Sensor, AnyOrigin[True]]]()(instance_id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_sensor_properties(sensor: Ptr[Sensor, AnyOrigin[True]]) raises -> PropertiesID:
    """Get the properties associated with a sensor.

    Args:
        sensor: The SDL_Sensor object.

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensorProperties.
    """

    return _get_dylib_function[lib, "SDL_GetSensorProperties", fn (sensor: Ptr[Sensor, AnyOrigin[True]]) -> PropertiesID]()(sensor)


fn get_sensor_name(sensor: Ptr[Sensor, AnyOrigin[True]], out ret: Ptr[c_char, AnyOrigin[False]]) raises:
    """Get the implementation dependent name of a sensor.

    Args:
        sensor: The SDL_Sensor object.

    Returns:
        The sensor name or NULL on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensorName.
    """

    ret = _get_dylib_function[lib, "SDL_GetSensorName", fn (sensor: Ptr[Sensor, AnyOrigin[True]]) -> Ptr[c_char, AnyOrigin[False]]]()(sensor)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_sensor_type(sensor: Ptr[Sensor, AnyOrigin[True]]) raises -> SensorType:
    """Get the type of a sensor.

    Args:
        sensor: The SDL_Sensor object to inspect.

    Returns:
        The SDL_SensorType type, or `SDL_SENSOR_INVALID` if `sensor` is
        NULL.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensorType.
    """

    return _get_dylib_function[lib, "SDL_GetSensorType", fn (sensor: Ptr[Sensor, AnyOrigin[True]]) -> SensorType]()(sensor)


fn get_sensor_non_portable_type(sensor: Ptr[Sensor, AnyOrigin[True]]) raises -> c_int:
    """Get the platform dependent type of a sensor.

    Args:
        sensor: The SDL_Sensor object to inspect.

    Returns:
        The sensor platform dependent type, or -1 if `sensor` is NULL.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensorNonPortableType.
    """

    return _get_dylib_function[lib, "SDL_GetSensorNonPortableType", fn (sensor: Ptr[Sensor, AnyOrigin[True]]) -> c_int]()(sensor)


fn get_sensor_id(sensor: Ptr[Sensor, AnyOrigin[True]]) raises -> SensorID:
    """Get the instance ID of a sensor.

    Args:
        sensor: The SDL_Sensor object to inspect.

    Returns:
        The sensor instance ID, or 0 on failure; call SDL_GetError() for
        more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensorID.
    """

    return _get_dylib_function[lib, "SDL_GetSensorID", fn (sensor: Ptr[Sensor, AnyOrigin[True]]) -> SensorID]()(sensor)


fn get_sensor_data(sensor: Ptr[Sensor, AnyOrigin[True]], data: Ptr[c_float, AnyOrigin[True]], num_values: c_int) raises:
    """Get the current state of an opened sensor.

    The number of values and interpretation of the data is sensor dependent.

    Args:
        sensor: The SDL_Sensor object to query.
        data: A pointer filled with the current sensor state.
        num_values: The number of values to write to data.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSensorData.
    """

    ret = _get_dylib_function[lib, "SDL_GetSensorData", fn (sensor: Ptr[Sensor, AnyOrigin[True]], data: Ptr[c_float, AnyOrigin[True]], num_values: c_int) -> Bool]()(sensor, data, num_values)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn close_sensor(sensor: Ptr[Sensor, AnyOrigin[True]]) raises -> None:
    """Close a sensor previously opened with SDL_OpenSensor().

    Args:
        sensor: The SDL_Sensor object to close.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CloseSensor.
    """

    return _get_dylib_function[lib, "SDL_CloseSensor", fn (sensor: Ptr[Sensor, AnyOrigin[True]]) -> None]()(sensor)


fn update_sensors() raises -> None:
    """Update the current state of the open sensors.

    This is called automatically by the event loop if sensor events are
    enabled.

    This needs to be called from the thread that initialized the sensor
    subsystem.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UpdateSensors.
    """

    return _get_dylib_function[lib, "SDL_UpdateSensors", fn () -> None]()()
