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

"""Haptic

The SDL haptic subsystem manages haptic (force feedback) devices.

The basic usage is as follows:

- Initialize the subsystem (SDL_INIT_HAPTIC).
- Open a haptic device.
- SDL_OpenHaptic() to open from index.
- SDL_OpenHapticFromJoystick() to open from an existing joystick.
- Create an effect (SDL_HapticEffect).
- Upload the effect with SDL_CreateHapticEffect().
- Run the effect with SDL_RunHapticEffect().
- (optional) Free the effect with SDL_DestroyHapticEffect().
- Close the haptic device with SDL_CloseHaptic().

Simple rumble example:

```c
   SDL_Haptic *haptic = NULL;

   // Open the device
   SDL_HapticID *haptics = SDL_GetHaptics(NULL);
   if (haptics) {
       haptic = SDL_OpenHaptic(haptics[0]);
       SDL_free(haptics);
   }
   if (haptic == NULL)
      return;

   // Initialize simple rumble
   if (!SDL_InitHapticRumble(haptic))
      return;

   // Play effect at 50% strength for 2 seconds
   if (!SDL_PlayHapticRumble(haptic, 0.5, 2000))
      return;
   SDL_Delay(2000);

   // Clean up
   SDL_CloseHaptic(haptic);
```

Complete example:

```c
bool test_haptic(SDL_Joystick *joystick)
{
   SDL_Haptic *haptic;
   SDL_HapticEffect effect;
   int effect_id;

   // Open the device
   haptic = SDL_OpenHapticFromJoystick(joystick);
   if (haptic == NULL) return false; // Most likely joystick isn't haptic

   // See if it can do sine waves
   if ((SDL_GetHapticFeatures(haptic) & SDL_HAPTIC_SINE)==0) {
      SDL_CloseHaptic(haptic); // No sine effect
      return false;
   }

   // Create the effect
   SDL_memset(&effect, 0, sizeof(SDL_HapticEffect)); // 0 is safe default
   effect.type = SDL_HAPTIC_SINE;
   effect.periodic.direction.type = SDL_HAPTIC_POLAR; // Polar coordinates
   effect.periodic.direction.dir[0] = 18000; // Force comes from south
   effect.periodic.period = 1000; // 1000 ms
   effect.periodic.magnitude = 20000; // 20000/32767 strength
   effect.periodic.length = 5000; // 5 seconds long
   effect.periodic.attack_length = 1000; // Takes 1 second to get max strength
   effect.periodic.fade_length = 1000; // Takes 1 second to fade away

   // Upload the effect
   effect_id = SDL_CreateHapticEffect(haptic, &effect);

   // Test the effect
   SDL_RunHapticEffect(haptic, effect_id, 1);
   SDL_Delay(5000); // Wait for the effect to finish

   // We destroy the effect, although closing the device also does this
   SDL_DestroyHapticEffect(haptic, effect_id);

   // Close the device
   SDL_CloseHaptic(haptic);

   return true; // Success
}
```

Note that the SDL haptic subsystem is not thread-safe.
"""


@fieldwise_init
struct Haptic(ImplicitlyCopyable, Movable):
    """The haptic structure used to identify an SDL haptic.

    Docs: https://wiki.libsdl.org/SDL3/Haptic.
    """

    pass


@fieldwise_init
struct HapticDirection(ImplicitlyCopyable, Movable):
    """Structure that represents a haptic direction.

    This is the direction where the force comes from, instead of the direction
    in which the force is exerted.

    Directions can be specified by:

    - SDL_HAPTIC_POLAR : Specified by polar coordinates.
    - SDL_HAPTIC_CARTESIAN : Specified by cartesian coordinates.
    - SDL_HAPTIC_SPHERICAL : Specified by spherical coordinates.

    Cardinal directions of the haptic device are relative to the positioning of
    the device. North is considered to be away from the user.

    The following diagram represents the cardinal directions:

    ```
                   .--.
                   |__| .-------.
                   |=.| |.-----.|
                   |--| ||     ||
                   |  | |'-----'|
                   |__|~')_____('
                     [ COMPUTER ]

                       North (0,-1)
                           ^
                           |
                           |
     (-1,0)  West <----[ HAPTIC ]----> East (1,0)
                           |
                           |
                           v
                        South (0,1)

                        [ USER ]
                          \\|||/
                          (o o)
                    ---ooO-(_)-Ooo---
    ```

    If type is SDL_HAPTIC_POLAR, direction is encoded by hundredths of a degree
    starting north and turning clockwise. SDL_HAPTIC_POLAR only uses the first
    `dir` parameter. The cardinal directions would be:

    - North: 0 (0 degrees)
    - East: 9000 (90 degrees)
    - South: 18000 (180 degrees)
    - West: 27000 (270 degrees)

    If type is SDL_HAPTIC_CARTESIAN, direction is encoded by three positions (X
    axis, Y axis and Z axis (with 3 axes)). SDL_HAPTIC_CARTESIAN uses the first
    three `dir` parameters. The cardinal directions would be:

    - North: 0,-1, 0
    - East: 1, 0, 0
    - South: 0, 1, 0
    - West: -1, 0, 0

    The Z axis represents the height of the effect if supported, otherwise it's
    unused. In cartesian encoding (1, 2) would be the same as (2, 4), you can
    use any multiple you want, only the direction matters.

    If type is SDL_HAPTIC_SPHERICAL, direction is encoded by two rotations. The
    first two `dir` parameters are used. The `dir` parameters are as follows
    (all values are in hundredths of degrees):

    - Degrees from (1, 0) rotated towards (0, 1).
    - Degrees towards (0, 0, 1) (device needs at least 3 axes).

    Example of force coming from the south with all encodings (force coming
    from the south means the user will have to pull the stick to counteract):

    ```c
     SDL_HapticDirection direction;

     // Cartesian directions
     direction.type = SDL_HAPTIC_CARTESIAN; // Using cartesian direction encoding.
     direction.dir[0] = 0; // X position
     direction.dir[1] = 1; // Y position
     // Assuming the device has 2 axes, we don't need to specify third parameter.

     // Polar directions
     direction.type = SDL_HAPTIC_POLAR; // We'll be using polar direction encoding.
     direction.dir[0] = 18000; // Polar only uses first parameter

     // Spherical coordinates
     direction.type = SDL_HAPTIC_SPHERICAL; // Spherical encoding
     direction.dir[0] = 9000; // Since we only have two axes we don't need more parameters.
    ```

    Docs: https://wiki.libsdl.org/SDL3/HapticDirection.
    """

    var type: UInt8
    """The type of encoding."""
    var dir: ArrayHelper[Int32, 3, AnyOrigin[True]].result
    """The encoded direction."""


@fieldwise_init
struct HapticConstant(ImplicitlyCopyable, Movable):
    """A structure containing a template for a Constant effect.

    This struct is exclusively for the SDL_HAPTIC_CONSTANT effect.

    A constant effect applies a constant force in the specified direction to
    the joystick.

    Docs: https://wiki.libsdl.org/SDL3/HapticConstant.
    """

    var type: UInt16
    """Header."""
    var direction: HapticDirection
    """Direction of the effect."""

    var length: UInt32
    """Replay."""
    var delay: UInt16
    """Delay before starting the effect."""

    var button: UInt16
    """Trigger."""
    var interval: UInt16
    """How soon it can be triggered again after button."""

    var level: Int16
    """Constant."""

    var attack_length: UInt16
    """Envelope."""
    var attack_level: UInt16
    """Level at the start of the attack."""
    var fade_length: UInt16
    """Duration of the fade."""
    var fade_level: UInt16
    """Level at the end of the fade."""


@fieldwise_init
struct HapticPeriodic(ImplicitlyCopyable, Movable):
    """A structure containing a template for a Periodic effect.
    
    The struct handles the following effects:
    
    - SDL_HAPTIC_SINE
    - SDL_HAPTIC_SQUARE
    - SDL_HAPTIC_TRIANGLE
    - SDL_HAPTIC_SAWTOOTHUP
    - SDL_HAPTIC_SAWTOOTHDOWN
    
    A periodic effect consists in a wave-shaped effect that repeats itself over
    time. The type determines the shape of the wave and the parameters
    determine the dimensions of the wave.
    
    Phase is given by hundredth of a degree meaning that giving the phase a
    value of 9000 will displace it 25% of its period. Here are sample values:
    
    - 0: No phase displacement.
    - 9000: Displaced 25% of its period.
    - 18000: Displaced 50% of its period.
    - 27000: Displaced 75% of its period.
    - 36000: Displaced 100% of its period, same as 0, but 0 is preferred.
    
    Examples:
    
    ```
      SDL_HAPTIC_SINE
        __      __      __      __
       /  \\    /  \\    /  \\    /
      /    \\__/    \\__/    \\__/
    
      SDL_HAPTIC_SQUARE
       __    __    __    __    __
      |  |  |  |  |  |  |  |  |  |
      |  |__|  |__|  |__|  |__|  |
    
      SDL_HAPTIC_TRIANGLE
        /\\    /\\    /\\    /\\    /\\
       /  \\  /  \\  /  \\  /  \\  /
      /    \\/    \\/    \\/    \\/
    
      SDL_HAPTIC_SAWTOOTHUP
        /|  /|  /|  /|  /|  /|  /|
       / | / | / | / | / | / | / |
      /  |/  |/  |/  |/  |/  |/  |
    
      SDL_HAPTIC_SAWTOOTHDOWN
      \\  |\\  |\\  |\\  |\\  |\\  |\\  |
       \\ | \\ | \\ | \\ | \\ | \\ | \\ |
        \\|  \\|  \\|  \\|  \\|  \\|  \\|
    ```

    Docs: https://wiki.libsdl.org/SDL3/HapticPeriodic.
    """

    var type: UInt16
    """Header."""
    var direction: HapticDirection
    """Direction of the effect."""

    var length: UInt32
    """Replay."""
    var delay: UInt16
    """Delay before starting the effect."""

    var button: UInt16
    """Trigger."""
    var interval: UInt16
    """How soon it can be triggered again after button."""

    var period: UInt16
    """Periodic."""
    var magnitude: Int16
    """Peak value; if negative, equivalent to 180 degrees extra phase shift."""
    var offset: Int16
    """Mean value of the wave."""
    var phase: UInt16
    """Positive phase shift given by hundredth of a degree."""

    var attack_length: UInt16
    """Envelope."""
    var attack_level: UInt16
    """Level at the start of the attack."""
    var fade_length: UInt16
    """Duration of the fade."""
    var fade_level: UInt16
    """Level at the end of the fade."""


@fieldwise_init
struct HapticCondition(ImplicitlyCopyable, Movable):
    """A structure containing a template for a Condition effect.

    The struct handles the following effects:

    - SDL_HAPTIC_SPRING: Effect based on axes position.
    - SDL_HAPTIC_DAMPER: Effect based on axes velocity.
    - SDL_HAPTIC_INERTIA: Effect based on axes acceleration.
    - SDL_HAPTIC_FRICTION: Effect based on axes movement.

    Direction is handled by condition internals instead of a direction member.
    The condition effect specific members have three parameters. The first
    refers to the X axis, the second refers to the Y axis and the third refers
    to the Z axis. The right terms refer to the positive side of the axis and
    the left terms refer to the negative side of the axis. Please refer to the
    SDL_HapticDirection diagram for which side is positive and which is
    negative.

    Docs: https://wiki.libsdl.org/SDL3/HapticCondition.
    """

    var type: UInt16
    """Header."""
    var direction: HapticDirection
    """Direction of the effect."""

    var length: UInt32
    """Replay."""
    var delay: UInt16
    """Delay before starting the effect."""

    var button: UInt16
    """Trigger."""
    var interval: UInt16
    """How soon it can be triggered again after button."""

    var right_sat: ArrayHelper[UInt16, 3, AnyOrigin[True]].result
    """Condition."""
    var left_sat: ArrayHelper[UInt16, 3, AnyOrigin[True]].result
    """Level when joystick is to the negative side; max 0xFFFF."""
    var right_coeff: ArrayHelper[Int16, 3, AnyOrigin[True]].result
    """How fast to increase the force towards the positive side."""
    var left_coeff: ArrayHelper[Int16, 3, AnyOrigin[True]].result
    """How fast to increase the force towards the negative side."""
    var deadband: ArrayHelper[UInt16, 3, AnyOrigin[True]].result
    """Size of the dead zone; max 0xFFFF: whole axis-range when 0-centered."""
    var center: ArrayHelper[Int16, 3, AnyOrigin[True]].result
    """Position of the dead zone."""


@fieldwise_init
struct HapticRamp(ImplicitlyCopyable, Movable):
    """A structure containing a template for a Ramp effect.

    This struct is exclusively for the SDL_HAPTIC_RAMP effect.

    The ramp effect starts at start strength and ends at end strength. It
    augments in linear fashion. If you use attack and fade with a ramp the
    effects get added to the ramp effect making the effect become quadratic
    instead of linear.

    Docs: https://wiki.libsdl.org/SDL3/HapticRamp.
    """

    var type: UInt16
    """Header."""
    var direction: HapticDirection
    """Direction of the effect."""

    var length: UInt32
    """Replay."""
    var delay: UInt16
    """Delay before starting the effect."""

    var button: UInt16
    """Trigger."""
    var interval: UInt16
    """How soon it can be triggered again after button."""

    var start: Int16
    """Ramp."""
    var end: Int16
    """Ending strength level."""

    var attack_length: UInt16
    """Envelope."""
    var attack_level: UInt16
    """Level at the start of the attack."""
    var fade_length: UInt16
    """Duration of the fade."""
    var fade_level: UInt16
    """Level at the end of the fade."""


@fieldwise_init
struct HapticLeftRight(ImplicitlyCopyable, Movable):
    """A structure containing a template for a Left/Right effect.

    This struct is exclusively for the SDL_HAPTIC_LEFTRIGHT effect.

    The Left/Right effect is used to explicitly control the large and small
    motors, commonly found in modern game controllers. The small (right) motor
    is high frequency, and the large (left) motor is low frequency.

    Docs: https://wiki.libsdl.org/SDL3/HapticLeftRight.
    """

    var type: UInt16
    """Header."""

    var length: UInt32
    """Replay."""

    var large_magnitude: UInt16
    """Rumble."""
    var small_magnitude: UInt16
    """Control of the small controller motor."""


@fieldwise_init
struct HapticCustom(ImplicitlyCopyable, Movable):
    """A structure containing a template for the SDL_HAPTIC_CUSTOM effect.

    This struct is exclusively for the SDL_HAPTIC_CUSTOM effect.

    A custom force feedback effect is much like a periodic effect, where the
    application can define its exact shape. You will have to allocate the data
    yourself. Data should consist of channels * samples Uint16 samples.

    If channels is one, the effect is rotated using the defined direction.
    Otherwise it uses the samples in data for the different axes.

    Docs: https://wiki.libsdl.org/SDL3/HapticCustom.
    """

    var type: UInt16
    """Header."""
    var direction: HapticDirection
    """Direction of the effect."""

    var length: UInt32
    """Replay."""
    var delay: UInt16
    """Delay before starting the effect."""

    var button: UInt16
    """Trigger."""
    var interval: UInt16
    """How soon it can be triggered again after button."""

    var channels: UInt8
    """Custom."""
    var period: UInt16
    """Sample periods."""
    var samples: UInt16
    """Amount of samples."""
    var data: Ptr[UInt16, AnyOrigin[True]]
    """Should contain channels*samples items."""

    var attack_length: UInt16
    """Envelope."""
    var attack_level: UInt16
    """Level at the start of the attack."""
    var fade_length: UInt16
    """Duration of the fade."""
    var fade_level: UInt16
    """Level at the end of the fade."""


struct HapticEffect:
    comptime _mlir_type = __mlir_type[`!pop.union<`, UInt16, `, `, HapticConstant, `, `, HapticPeriodic, `, `, HapticCondition, `, `, HapticRamp, `, `, HapticLeftRight, `, `, HapticCustom, `>`]
    var _impl: Self._mlir_type

    @implicit
    fn __init__[T: AnyType](out self, value: T):
        self._impl = rebind[Self._mlir_type](value)

    fn __getitem__[T: AnyType](ref self) -> ref [self._impl] T:
        return rebind[Ptr[T, origin_of(self._impl)]](Ptr(to=self._impl))[]


@register_passable("trivial")
struct HapticID(Intable):
    """This is a unique ID for a haptic device for the time it is connected to the
    system, and is never reused for the lifetime of the application.

    If the haptic device is disconnected and reconnected, it will get a new ID.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HapticID.
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


fn get_haptics(count: Ptr[c_int, AnyOrigin[True]]) raises -> Ptr[HapticID, AnyOrigin[True]]:
    """Get a list of currently connected haptic devices.

    Args:
        count: A pointer filled in with the number of haptic devices
               returned, may be NULL.

    Returns:
        A 0 terminated array of haptic device instance IDs or NULL on
        failure; call SDL_GetError() for more information. This should be
        freed with SDL_free() when it is no longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetHaptics.
    """

    return _get_dylib_function[lib, "SDL_GetHaptics", fn (count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[HapticID, AnyOrigin[True]]]()(count)


fn get_haptic_name_for_id(instance_id: HapticID) raises -> Ptr[c_char, AnyOrigin[False]]:
    """Get the implementation dependent name of a haptic device.

    This can be called before any haptic devices are opened.

    Args:
        instance_id: The haptic device instance ID.

    Returns:
        The name of the selected haptic device. If no name can be found,
        this function returns NULL; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetHapticNameForID.
    """

    return _get_dylib_function[lib, "SDL_GetHapticNameForID", fn (instance_id: HapticID) -> Ptr[c_char, AnyOrigin[False]]]()(instance_id)


fn open_haptic(instance_id: HapticID, out ret: Ptr[Haptic, AnyOrigin[True]]) raises:
    """Open a haptic device for use.

    The index passed as an argument refers to the N'th haptic device on this
    system.

    When opening a haptic device, its gain will be set to maximum and
    autocenter will be disabled. To modify these values use SDL_SetHapticGain()
    and SDL_SetHapticAutocenter().

    Args:
        instance_id: The haptic device instance ID.

    Returns:
        The device identifier or NULL on failure; call SDL_GetError() for
        more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenHaptic.
    """

    ret = _get_dylib_function[lib, "SDL_OpenHaptic", fn (instance_id: HapticID) -> Ptr[Haptic, AnyOrigin[True]]]()(instance_id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_haptic_from_id(instance_id: HapticID) raises -> Ptr[Haptic, AnyOrigin[True]]:
    """Get the SDL_Haptic associated with an instance ID, if it has been opened.

    Args:
        instance_id: The instance ID to get the SDL_Haptic for.

    Returns:
        An SDL_Haptic on success or NULL on failure or if it hasn't been
        opened yet; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetHapticFromID.
    """

    return _get_dylib_function[lib, "SDL_GetHapticFromID", fn (instance_id: HapticID) -> Ptr[Haptic, AnyOrigin[True]]]()(instance_id)


fn get_haptic_id(haptic: Ptr[Haptic, AnyOrigin[True]]) raises -> HapticID:
    """Get the instance ID of an opened haptic device.

    Args:
        haptic: The SDL_Haptic device to query.

    Returns:
        The instance ID of the specified haptic device on success or 0 on
        failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetHapticID.
    """

    return _get_dylib_function[lib, "SDL_GetHapticID", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> HapticID]()(haptic)


fn get_haptic_name(haptic: Ptr[Haptic, AnyOrigin[True]]) raises -> Ptr[c_char, AnyOrigin[False]]:
    """Get the implementation dependent name of a haptic device.

    Args:
        haptic: The SDL_Haptic obtained from SDL_OpenJoystick().

    Returns:
        The name of the selected haptic device. If no name can be found,
        this function returns NULL; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetHapticName.
    """

    return _get_dylib_function[lib, "SDL_GetHapticName", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> Ptr[c_char, AnyOrigin[False]]]()(haptic)


fn is_mouse_haptic() raises -> Bool:
    """Query whether or not the current mouse has haptic capabilities.

    Returns:
        True if the mouse is haptic or false if it isn't.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IsMouseHaptic.
    """

    return _get_dylib_function[lib, "SDL_IsMouseHaptic", fn () -> Bool]()()


fn open_haptic_from_mouse(out ret: Ptr[Haptic, AnyOrigin[True]]) raises:
    """Try to open a haptic device from the current mouse.

    Returns:
        The haptic device identifier or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenHapticFromMouse.
    """

    ret = _get_dylib_function[lib, "SDL_OpenHapticFromMouse", fn () -> Ptr[Haptic, AnyOrigin[True]]]()()
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn is_joystick_haptic(joystick: Ptr[Joystick, AnyOrigin[True]]) raises -> Bool:
    """Query if a joystick has haptic features.

    Args:
        joystick: The SDL_Joystick to test for haptic capabilities.

    Returns:
        True if the joystick is haptic or false if it isn't.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IsJoystickHaptic.
    """

    return _get_dylib_function[lib, "SDL_IsJoystickHaptic", fn (joystick: Ptr[Joystick, AnyOrigin[True]]) -> Bool]()(joystick)


fn open_haptic_from_joystick(joystick: Ptr[Joystick, AnyOrigin[True]], out ret: Ptr[Haptic, AnyOrigin[True]]) raises:
    """Open a haptic device for use from a joystick device.

    You must still close the haptic device separately. It will not be closed
    with the joystick.

    When opened from a joystick you should first close the haptic device before
    closing the joystick device. If not, on some implementations the haptic
    device will also get unallocated and you'll be unable to use force feedback
    on that device.

    Args:
        joystick: The SDL_Joystick to create a haptic device from.

    Returns:
        A valid haptic device identifier on success or NULL on failure;
        call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenHapticFromJoystick.
    """

    ret = _get_dylib_function[lib, "SDL_OpenHapticFromJoystick", fn (joystick: Ptr[Joystick, AnyOrigin[True]]) -> Ptr[Haptic, AnyOrigin[True]]]()(joystick)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn close_haptic(haptic: Ptr[Haptic, AnyOrigin[True]]) raises -> None:
    """Close a haptic device previously opened with SDL_OpenHaptic().

    Args:
        haptic: The SDL_Haptic device to close.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CloseHaptic.
    """

    return _get_dylib_function[lib, "SDL_CloseHaptic", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> None]()(haptic)


fn get_max_haptic_effects(haptic: Ptr[Haptic, AnyOrigin[True]]) raises -> c_int:
    """Get the number of effects a haptic device can store.

    On some platforms this isn't fully supported, and therefore is an
    approximation. Always check to see if your created effect was actually
    created and do not rely solely on SDL_GetMaxHapticEffects().

    Args:
        haptic: The SDL_Haptic device to query.

    Returns:
        The number of effects the haptic device can store or a negative
        error code on failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetMaxHapticEffects.
    """

    return _get_dylib_function[lib, "SDL_GetMaxHapticEffects", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> c_int]()(haptic)


fn get_max_haptic_effects_playing(haptic: Ptr[Haptic, AnyOrigin[True]]) raises -> c_int:
    """Get the number of effects a haptic device can play at the same time.

    This is not supported on all platforms, but will always return a value.

    Args:
        haptic: The SDL_Haptic device to query maximum playing effects.

    Returns:
        The number of effects the haptic device can play at the same time
        or -1 on failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetMaxHapticEffectsPlaying.
    """

    return _get_dylib_function[lib, "SDL_GetMaxHapticEffectsPlaying", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> c_int]()(haptic)


fn get_haptic_features(haptic: Ptr[Haptic, AnyOrigin[True]]) raises -> UInt32:
    """Get the haptic device's supported features in bitwise manner.

    Args:
        haptic: The SDL_Haptic device to query.

    Returns:
        A list of supported haptic features in bitwise manner (OR'd), or 0
        on failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetHapticFeatures.
    """

    return _get_dylib_function[lib, "SDL_GetHapticFeatures", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> UInt32]()(haptic)


fn get_num_haptic_axes(haptic: Ptr[Haptic, AnyOrigin[True]]) raises -> c_int:
    """Get the number of haptic axes the device has.

    The number of haptic axes might be useful if working with the
    SDL_HapticDirection effect.

    Args:
        haptic: The SDL_Haptic device to query.

    Returns:
        The number of axes on success or -1 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumHapticAxes.
    """

    return _get_dylib_function[lib, "SDL_GetNumHapticAxes", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> c_int]()(haptic)


fn haptic_effect_supported(haptic: Ptr[Haptic, AnyOrigin[True]], effect: Ptr[HapticEffect, AnyOrigin[False]]) raises -> Bool:
    """Check to see if an effect is supported by a haptic device.

    Args:
        haptic: The SDL_Haptic device to query.
        effect: The desired effect to query.

    Returns:
        True if the effect is supported or false if it isn't.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HapticEffectSupported.
    """

    return _get_dylib_function[lib, "SDL_HapticEffectSupported", fn (haptic: Ptr[Haptic, AnyOrigin[True]], effect: Ptr[HapticEffect, AnyOrigin[False]]) -> Bool]()(haptic, effect)


fn create_haptic_effect(haptic: Ptr[Haptic, AnyOrigin[True]], effect: Ptr[HapticEffect, AnyOrigin[False]]) raises -> c_int:
    """Create a new haptic effect on a specified device.

    Args:
        haptic: An SDL_Haptic device to create the effect on.
        effect: An SDL_HapticEffect structure containing the properties of
                the effect to create.

    Returns:
        The ID of the effect on success or -1 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateHapticEffect.
    """

    return _get_dylib_function[lib, "SDL_CreateHapticEffect", fn (haptic: Ptr[Haptic, AnyOrigin[True]], effect: Ptr[HapticEffect, AnyOrigin[False]]) -> c_int]()(haptic, effect)


fn update_haptic_effect(haptic: Ptr[Haptic, AnyOrigin[True]], effect: c_int, data: Ptr[HapticEffect, AnyOrigin[False]]) raises:
    """Update the properties of an effect.

    Can be used dynamically, although behavior when dynamically changing
    direction may be strange. Specifically the effect may re-upload itself and
    start playing from the start. You also cannot change the type either when
    running SDL_UpdateHapticEffect().

    Args:
        haptic: The SDL_Haptic device that has the effect.
        effect: The identifier of the effect to update.
        data: An SDL_HapticEffect structure containing the new effect
              properties to use.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UpdateHapticEffect.
    """

    ret = _get_dylib_function[lib, "SDL_UpdateHapticEffect", fn (haptic: Ptr[Haptic, AnyOrigin[True]], effect: c_int, data: Ptr[HapticEffect, AnyOrigin[False]]) -> Bool]()(haptic, effect, data)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn run_haptic_effect(haptic: Ptr[Haptic, AnyOrigin[True]], effect: c_int, iterations: UInt32) raises:
    """Run the haptic effect on its associated haptic device.

    To repeat the effect over and over indefinitely, set `iterations` to
    `SDL_HAPTIC_INFINITY`. (Repeats the envelope - attack and fade.) To make
    one instance of the effect last indefinitely (so the effect does not fade),
    set the effect's `length` in its structure/union to `SDL_HAPTIC_INFINITY`
    instead.

    Args:
        haptic: The SDL_Haptic device to run the effect on.
        effect: The ID of the haptic effect to run.
        iterations: The number of iterations to run the effect; use
                    `SDL_HAPTIC_INFINITY` to repeat forever.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RunHapticEffect.
    """

    ret = _get_dylib_function[lib, "SDL_RunHapticEffect", fn (haptic: Ptr[Haptic, AnyOrigin[True]], effect: c_int, iterations: UInt32) -> Bool]()(haptic, effect, iterations)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn stop_haptic_effect(haptic: Ptr[Haptic, AnyOrigin[True]], effect: c_int) raises:
    """Stop the haptic effect on its associated haptic device.

    Args:
        haptic: The SDL_Haptic device to stop the effect on.
        effect: The ID of the haptic effect to stop.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_StopHapticEffect.
    """

    ret = _get_dylib_function[lib, "SDL_StopHapticEffect", fn (haptic: Ptr[Haptic, AnyOrigin[True]], effect: c_int) -> Bool]()(haptic, effect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn destroy_haptic_effect(haptic: Ptr[Haptic, AnyOrigin[True]], effect: c_int) raises -> None:
    """Destroy a haptic effect on the device.

    This will stop the effect if it's running. Effects are automatically
    destroyed when the device is closed.

    Args:
        haptic: The SDL_Haptic device to destroy the effect on.
        effect: The ID of the haptic effect to destroy.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyHapticEffect.
    """

    return _get_dylib_function[lib, "SDL_DestroyHapticEffect", fn (haptic: Ptr[Haptic, AnyOrigin[True]], effect: c_int) -> None]()(haptic, effect)


fn get_haptic_effect_status(haptic: Ptr[Haptic, AnyOrigin[True]], effect: c_int) raises -> Bool:
    """Get the status of the current effect on the specified haptic device.

    Device must support the SDL_HAPTIC_STATUS feature.

    Args:
        haptic: The SDL_Haptic device to query for the effect status on.
        effect: The ID of the haptic effect to query its status.

    Returns:
        True if it is playing, false if it isn't playing or haptic status
        isn't supported.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetHapticEffectStatus.
    """

    return _get_dylib_function[lib, "SDL_GetHapticEffectStatus", fn (haptic: Ptr[Haptic, AnyOrigin[True]], effect: c_int) -> Bool]()(haptic, effect)


fn set_haptic_gain(haptic: Ptr[Haptic, AnyOrigin[True]], gain: c_int) raises:
    """Set the global gain of the specified haptic device.

    Device must support the SDL_HAPTIC_GAIN feature.

    The user may specify the maximum gain by setting the environment variable
    `SDL_HAPTIC_GAIN_MAX` which should be between 0 and 100. All calls to
    SDL_SetHapticGain() will scale linearly using `SDL_HAPTIC_GAIN_MAX` as the
    maximum.

    Args:
        haptic: The SDL_Haptic device to set the gain on.
        gain: Value to set the gain to, should be between 0 and 100 (0 -
              100).

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetHapticGain.
    """

    ret = _get_dylib_function[lib, "SDL_SetHapticGain", fn (haptic: Ptr[Haptic, AnyOrigin[True]], gain: c_int) -> Bool]()(haptic, gain)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_haptic_autocenter(haptic: Ptr[Haptic, AnyOrigin[True]], autocenter: c_int) raises:
    """Set the global autocenter of the device.

    Autocenter should be between 0 and 100. Setting it to 0 will disable
    autocentering.

    Device must support the SDL_HAPTIC_AUTOCENTER feature.

    Args:
        haptic: The SDL_Haptic device to set autocentering on.
        autocenter: Value to set autocenter to (0-100).

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetHapticAutocenter.
    """

    ret = _get_dylib_function[lib, "SDL_SetHapticAutocenter", fn (haptic: Ptr[Haptic, AnyOrigin[True]], autocenter: c_int) -> Bool]()(haptic, autocenter)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn pause_haptic(haptic: Ptr[Haptic, AnyOrigin[True]]) raises:
    """Pause a haptic device.

    Device must support the `SDL_HAPTIC_PAUSE` feature. Call SDL_ResumeHaptic()
    to resume playback.

    Do not modify the effects nor add new ones while the device is paused. That
    can cause all sorts of weird errors.

    Args:
        haptic: The SDL_Haptic device to pause.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PauseHaptic.
    """

    ret = _get_dylib_function[lib, "SDL_PauseHaptic", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> Bool]()(haptic)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn resume_haptic(haptic: Ptr[Haptic, AnyOrigin[True]]) raises:
    """Resume a haptic device.

    Call to unpause after SDL_PauseHaptic().

    Args:
        haptic: The SDL_Haptic device to unpause.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ResumeHaptic.
    """

    ret = _get_dylib_function[lib, "SDL_ResumeHaptic", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> Bool]()(haptic)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn stop_haptic_effects(haptic: Ptr[Haptic, AnyOrigin[True]]) raises:
    """Stop all the currently playing effects on a haptic device.

    Args:
        haptic: The SDL_Haptic device to stop.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_StopHapticEffects.
    """

    ret = _get_dylib_function[lib, "SDL_StopHapticEffects", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> Bool]()(haptic)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn haptic_rumble_supported(haptic: Ptr[Haptic, AnyOrigin[True]]) raises -> Bool:
    """Check whether rumble is supported on a haptic device.

    Args:
        haptic: Haptic device to check for rumble support.

    Returns:
        True if the effect is supported or false if it isn't.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HapticRumbleSupported.
    """

    return _get_dylib_function[lib, "SDL_HapticRumbleSupported", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> Bool]()(haptic)


fn init_haptic_rumble(haptic: Ptr[Haptic, AnyOrigin[True]]) raises:
    """Initialize a haptic device for simple rumble playback.

    Args:
        haptic: The haptic device to initialize for simple rumble playback.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_InitHapticRumble.
    """

    ret = _get_dylib_function[lib, "SDL_InitHapticRumble", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> Bool]()(haptic)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn play_haptic_rumble(haptic: Ptr[Haptic, AnyOrigin[True]], strength: c_float, length: UInt32) raises:
    """Run a simple rumble effect on a haptic device.

    Args:
        haptic: The haptic device to play the rumble effect on.
        strength: Strength of the rumble to play as a 0-1 float value.
        length: Length of the rumble to play in milliseconds.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PlayHapticRumble.
    """

    ret = _get_dylib_function[lib, "SDL_PlayHapticRumble", fn (haptic: Ptr[Haptic, AnyOrigin[True]], strength: c_float, length: UInt32) -> Bool]()(haptic, strength, length)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn stop_haptic_rumble(haptic: Ptr[Haptic, AnyOrigin[True]]) raises:
    """Stop the simple rumble on a haptic device.

    Args:
        haptic: The haptic device to stop the rumble effect on.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_StopHapticRumble.
    """

    ret = _get_dylib_function[lib, "SDL_StopHapticRumble", fn (haptic: Ptr[Haptic, AnyOrigin[True]]) -> Bool]()(haptic)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))
