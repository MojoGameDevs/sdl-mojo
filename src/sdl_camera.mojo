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

"""Camera

Video capture for the SDL library.

This API lets apps read input from video sources, like webcams. Camera
devices can be enumerated, queried, and opened. Once opened, it will
provide SDL_Surface objects as new frames of video come in. These surfaces
can be uploaded to an SDL_Texture or processed as pixels in memory.

Several platforms will alert the user if an app tries to access a camera,
and some will present a UI asking the user if your application should be
allowed to obtain images at all, which they can deny. A successfully opened
camera will not provide images until permission is granted. Applications,
after opening a camera device, can see if they were granted access by
either polling with the SDL_GetCameraPermissionState() function, or waiting
for an SDL_EVENT_CAMERA_DEVICE_APPROVED or SDL_EVENT_CAMERA_DEVICE_DENIED
event. Platforms that don't have any user approval process will report
approval immediately.

Note that SDL cameras only provide video as individual frames; they will
not provide full-motion video encoded in a movie file format, although an
app is free to encode the acquired frames into any format it likes. It also
does not provide audio from the camera hardware through this API; not only
do many webcams not have microphones at all, many people--from streamers to
people on Zoom calls--will want to use a separate microphone regardless of
the camera. In any case, recorded audio will be available through SDL's
audio API no matter what hardware provides the microphone.

## Camera gotchas

Consumer-level camera hardware tends to take a little while to warm up,
once the device has been opened. Generally most camera apps have some sort
of UI to take a picture (a button to snap a pic while a preview is showing,
some sort of multi-second countdown for the user to pose, like a photo
booth), which puts control in the users' hands, or they are intended to
stay on for long times (Pokemon Go, etc).

It's not uncommon that a newly-opened camera will provide a couple of
completely black frames, maybe followed by some under-exposed images. If
taking a single frame automatically, or recording video from a camera's
input without the user initiating it from a preview, it could be wise to
drop the first several frames (if not the first several _seconds_ worth of
frames!) before using images from a camera.
"""


@register_passable("trivial")
struct CameraID(Intable):
    """This is a unique ID for a camera device for the time it is connected to the
    system, and is never reused for the lifetime of the application.

    If the device is disconnected and reconnected, it will get a new ID.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CameraID.
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


@fieldwise_init
struct Camera(ImplicitlyCopyable, Movable):
    """The opaque structure used to identify an opened SDL camera.

    Docs: https://wiki.libsdl.org/SDL3/Camera.
    """

    pass


@fieldwise_init
struct CameraSpec(ImplicitlyCopyable, Movable):
    """The details of an output format for a camera device.

    Cameras often support multiple formats; each one will be encapsulated in
    this struct.

    Docs: https://wiki.libsdl.org/SDL3/CameraSpec.
    """

    var format: PixelFormat
    """Frame format."""
    var colorspace: Colorspace
    """Frame colorspace."""
    var width: c_int
    """Frame width."""
    var height: c_int
    """Frame height."""
    var framerate_numerator: c_int
    """Frame rate numerator ((num / denom) == FPS, (denom / num) == duration in seconds)."""
    var framerate_denominator: c_int
    """Frame rate denominator ((num / denom) == FPS, (denom / num) == duration in seconds)."""


@register_passable("trivial")
struct CameraPosition(Indexer, Intable):
    """The position of camera in relation to system device.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CameraPosition.
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

    comptime CAMERA_POSITION_UNKNOWN = Self(0x0)
    comptime CAMERA_POSITION_FRONT_FACING = Self(0x1)
    comptime CAMERA_POSITION_BACK_FACING = Self(0x2)


fn get_num_camera_drivers() raises -> c_int:
    """Use this function to get the number of built-in camera drivers.

    This function returns a hardcoded number. This never returns a negative
    value; if there are no drivers compiled into this build of SDL, this
    function returns zero. The presence of a driver in this list does not mean
    it will function, it just means SDL is capable of interacting with that
    interface. For example, a build of SDL might have v4l2 support, but if
    there's no kernel support available, SDL's v4l2 driver would fail if used.

    By default, SDL tries all drivers, in its preferred order, until one is
    found to be usable.

    Returns:
        The number of built-in camera drivers.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumCameraDrivers.
    """

    return _get_dylib_function[lib, "SDL_GetNumCameraDrivers", fn () -> c_int]()()


fn get_camera_driver(index: c_int) raises -> Ptr[c_char, AnyOrigin[False]]:
    """Use this function to get the name of a built in camera driver.

    The list of camera drivers is given in the order that they are normally
    initialized by default; the drivers that seem more reasonable to choose
    first (as far as the SDL developers believe) are earlier in the list.

    The names of drivers are all simple, low-ASCII identifiers, like "v4l2",
    "coremedia" or "android". These never have Unicode characters, and are not
    meant to be proper names.

    Args:
        index: The index of the camera driver; the value ranges from 0 to
               SDL_GetNumCameraDrivers() - 1.

    Returns:
        The name of the camera driver at the requested index, or NULL if
        an invalid index was specified.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCameraDriver.
    """

    return _get_dylib_function[lib, "SDL_GetCameraDriver", fn (index: c_int) -> Ptr[c_char, AnyOrigin[False]]]()(index)


fn get_current_camera_driver() raises -> Ptr[c_char, AnyOrigin[False]]:
    """Get the name of the current camera driver.

    The names of drivers are all simple, low-ASCII identifiers, like "v4l2",
    "coremedia" or "android". These never have Unicode characters, and are not
    meant to be proper names.

    Returns:
        The name of the current camera driver or NULL if no driver has
        been initialized.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCurrentCameraDriver.
    """

    return _get_dylib_function[lib, "SDL_GetCurrentCameraDriver", fn () -> Ptr[c_char, AnyOrigin[False]]]()()


fn get_cameras(count: Ptr[c_int, AnyOrigin[True]], out ret: Ptr[CameraID, AnyOrigin[True]]) raises:
    """Get a list of currently connected camera devices.

    Args:
        count: A pointer filled in with the number of cameras returned, may
               be NULL.

    Returns:
        A 0 terminated array of camera instance IDs or NULL on failure;
        call SDL_GetError() for more information. This should be freed
        with SDL_free() when it is no longer needed.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCameras.
    """

    ret = _get_dylib_function[lib, "SDL_GetCameras", fn (count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[CameraID, AnyOrigin[True]]]()(count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_camera_supported_formats(instance_id: CameraID, count: Ptr[c_int, AnyOrigin[True]]) raises -> Ptr[Ptr[CameraSpec, AnyOrigin[True]], AnyOrigin[True]]:
    """Get the list of native formats/sizes a camera supports.

    This returns a list of all formats and frame sizes that a specific camera
    can offer. This is useful if your app can accept a variety of image formats
    and sizes and so want to find the optimal spec that doesn't require
    conversion.

    This function isn't strictly required; if you call SDL_OpenCamera with a
    NULL spec, SDL will choose a native format for you, and if you instead
    specify a desired format, it will transparently convert to the requested
    format on your behalf.

    If `count` is not NULL, it will be filled with the number of elements in
    the returned array.

    Note that it's legal for a camera to supply an empty list. This is what
    will happen on Emscripten builds, since that platform won't tell _anything_
    about available cameras until you've opened one, and won't even tell if
    there _is_ a camera until the user has given you permission to check
    through a scary warning popup.

    Args:
        instance_id: The camera device instance ID.
        count: A pointer filled in with the number of elements in the list,
               may be NULL.

    Returns:
        A NULL terminated array of pointers to SDL_CameraSpec or NULL on
        failure; call SDL_GetError() for more information. This is a
        single allocation that should be freed with SDL_free() when it is
        no longer needed.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCameraSupportedFormats.
    """

    return _get_dylib_function[lib, "SDL_GetCameraSupportedFormats", fn (instance_id: CameraID, count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[Ptr[CameraSpec, AnyOrigin[True]], AnyOrigin[True]]]()(instance_id, count)


fn get_camera_name(instance_id: CameraID, out ret: Ptr[c_char, AnyOrigin[False]]) raises:
    """Get the human-readable device name for a camera.

    Args:
        instance_id: The camera device instance ID.

    Returns:
        A human-readable device name or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCameraName.
    """

    ret = _get_dylib_function[lib, "SDL_GetCameraName", fn (instance_id: CameraID) -> Ptr[c_char, AnyOrigin[False]]]()(instance_id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_camera_position(instance_id: CameraID) raises -> CameraPosition:
    """Get the position of the camera in relation to the system.

    Most platforms will report UNKNOWN, but mobile devices, like phones, can
    often make a distinction between cameras on the front of the device (that
    points towards the user, for taking "selfies") and cameras on the back (for
    filming in the direction the user is facing).

    Args:
        instance_id: The camera device instance ID.

    Returns:
        The position of the camera on the system hardware.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCameraPosition.
    """

    return _get_dylib_function[lib, "SDL_GetCameraPosition", fn (instance_id: CameraID) -> CameraPosition]()(instance_id)


fn open_camera(instance_id: CameraID, spec: Ptr[CameraSpec, AnyOrigin[False]], out ret: Ptr[Camera, AnyOrigin[True]]) raises:
    """Open a video recording device (a "camera").

    You can open the device with any reasonable spec, and if the hardware can't
    directly support it, it will convert data seamlessly to the requested
    format. This might incur overhead, including scaling of image data.

    If you would rather accept whatever format the device offers, you can pass
    a NULL spec here and it will choose one for you (and you can use
    SDL_Surface's conversion/scaling functions directly if necessary).

    You can call SDL_GetCameraFormat() to get the actual data format if passing
    a NULL spec here. You can see the exact specs a device can support without
    conversion with SDL_GetCameraSupportedFormats().

    SDL will not attempt to emulate framerate; it will try to set the hardware
    to the rate closest to the requested speed, but it won't attempt to limit
    or duplicate frames artificially; call SDL_GetCameraFormat() to see the
    actual framerate of the opened the device, and check your timestamps if
    this is crucial to your app!

    Note that the camera is not usable until the user approves its use! On some
    platforms, the operating system will prompt the user to permit access to
    the camera, and they can choose Yes or No at that point. Until they do, the
    camera will not be usable. The app should either wait for an
    SDL_EVENT_CAMERA_DEVICE_APPROVED (or SDL_EVENT_CAMERA_DEVICE_DENIED) event,
    or poll SDL_GetCameraPermissionState() occasionally until it returns
    non-zero. On platforms that don't require explicit user approval (and
    perhaps in places where the user previously permitted access), the approval
    event might come immediately, but it might come seconds, minutes, or hours
    later!

    Args:
        instance_id: The camera device instance ID.
        spec: The desired format for data the device will provide. Can be
              NULL.

    Returns:
        An SDL_Camera object or NULL on failure; call SDL_GetError() for
        more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenCamera.
    """

    ret = _get_dylib_function[lib, "SDL_OpenCamera", fn (instance_id: CameraID, spec: Ptr[CameraSpec, AnyOrigin[False]]) -> Ptr[Camera, AnyOrigin[True]]]()(instance_id, spec)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_camera_permission_state(camera: Ptr[Camera, AnyOrigin[True]]) raises -> c_int:
    """Query if camera access has been approved by the user.

    Cameras will not function between when the device is opened by the app and
    when the user permits access to the hardware. On some platforms, this
    presents as a popup dialog where the user has to explicitly approve access;
    on others the approval might be implicit and not alert the user at all.

    This function can be used to check the status of that approval. It will
    return 0 if still waiting for user response, 1 if the camera is approved
    for use, and -1 if the user denied access.

    Instead of polling with this function, you can wait for a
    SDL_EVENT_CAMERA_DEVICE_APPROVED (or SDL_EVENT_CAMERA_DEVICE_DENIED) event
    in the standard SDL event loop, which is guaranteed to be sent once when
    permission to use the camera is decided.

    If a camera is declined, there's nothing to be done but call
    SDL_CloseCamera() to dispose of it.

    Args:
        camera: The opened camera device to query.

    Returns:
        -1 if user denied access to the camera, 1 if user approved access,
        0 if no decision has been made yet.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCameraPermissionState.
    """

    return _get_dylib_function[lib, "SDL_GetCameraPermissionState", fn (camera: Ptr[Camera, AnyOrigin[True]]) -> c_int]()(camera)


fn get_camera_id(camera: Ptr[Camera, AnyOrigin[True]]) raises -> CameraID:
    """Get the instance ID of an opened camera.

    Args:
        camera: An SDL_Camera to query.

    Returns:
        The instance ID of the specified camera on success or 0 on
        failure; call SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCameraID.
    """

    return _get_dylib_function[lib, "SDL_GetCameraID", fn (camera: Ptr[Camera, AnyOrigin[True]]) -> CameraID]()(camera)


fn get_camera_properties(camera: Ptr[Camera, AnyOrigin[True]]) raises -> PropertiesID:
    """Get the properties associated with an opened camera.

    Args:
        camera: The SDL_Camera obtained from SDL_OpenCamera().

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCameraProperties.
    """

    return _get_dylib_function[lib, "SDL_GetCameraProperties", fn (camera: Ptr[Camera, AnyOrigin[True]]) -> PropertiesID]()(camera)


fn get_camera_format(camera: Ptr[Camera, AnyOrigin[True]], spec: Ptr[CameraSpec, AnyOrigin[True]]) raises:
    """Get the spec that a camera is using when generating images.

    Note that this might not be the native format of the hardware, as SDL might
    be converting to this format behind the scenes.

    If the system is waiting for the user to approve access to the camera, as
    some platforms require, this will return false, but this isn't necessarily
    a fatal error; you should either wait for an
    SDL_EVENT_CAMERA_DEVICE_APPROVED (or SDL_EVENT_CAMERA_DEVICE_DENIED) event,
    or poll SDL_GetCameraPermissionState() occasionally until it returns
    non-zero.

    Args:
        camera: Opened camera device.
        spec: The SDL_CameraSpec to be initialized by this function.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCameraFormat.
    """

    ret = _get_dylib_function[lib, "SDL_GetCameraFormat", fn (camera: Ptr[Camera, AnyOrigin[True]], spec: Ptr[CameraSpec, AnyOrigin[True]]) -> Bool]()(camera, spec)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn acquire_camera_frame(camera: Ptr[Camera, AnyOrigin[True]], timestamp_ns: Ptr[UInt64, AnyOrigin[True]]) raises -> Ptr[Surface, AnyOrigin[True]]:
    """Acquire a frame.

    The frame is a memory pointer to the image data, whose size and format are
    given by the spec requested when opening the device.

    This is a non blocking API. If there is a frame available, a non-NULL
    surface is returned, and timestampNS will be filled with a non-zero value.

    Note that an error case can also return NULL, but a NULL by itself is
    normal and just signifies that a new frame is not yet available. Note that
    even if a camera device fails outright (a USB camera is unplugged while in
    use, etc), SDL will send an event separately to notify the app, but
    continue to provide blank frames at ongoing intervals until
    SDL_CloseCamera() is called, so real failure here is almost always an out
    of memory condition.

    After use, the frame should be released with SDL_ReleaseCameraFrame(). If
    you don't do this, the system may stop providing more video!

    Do not call SDL_DestroySurface() on the returned surface! It must be given
    back to the camera subsystem with SDL_ReleaseCameraFrame!

    If the system is waiting for the user to approve access to the camera, as
    some platforms require, this will return NULL (no frames available); you
    should either wait for an SDL_EVENT_CAMERA_DEVICE_APPROVED (or
    SDL_EVENT_CAMERA_DEVICE_DENIED) event, or poll
    SDL_GetCameraPermissionState() occasionally until it returns non-zero.

    Args:
        camera: Opened camera device.
        timestamp_ns: A pointer filled in with the frame's timestamp, or 0 on
                      error. Can be NULL.

    Returns:
        A new frame of video on success, NULL if none is currently
        available.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AcquireCameraFrame.
    """

    return _get_dylib_function[lib, "SDL_AcquireCameraFrame", fn (camera: Ptr[Camera, AnyOrigin[True]], timestamp_ns: Ptr[UInt64, AnyOrigin[True]]) -> Ptr[Surface, AnyOrigin[True]]]()(camera, timestamp_ns)


fn release_camera_frame(camera: Ptr[Camera, AnyOrigin[True]], frame: Ptr[Surface, AnyOrigin[True]]) raises -> None:
    """Release a frame of video acquired from a camera.

    Let the back-end re-use the internal buffer for camera.

    This function _must_ be called only on surface objects returned by
    SDL_AcquireCameraFrame(). This function should be called as quickly as
    possible after acquisition, as SDL keeps a small FIFO queue of surfaces for
    video frames; if surfaces aren't released in a timely manner, SDL may drop
    upcoming video frames from the camera.

    If the app needs to keep the surface for a significant time, they should
    make a copy of it and release the original.

    The app should not use the surface again after calling this function;
    assume the surface is freed and the pointer is invalid.

    Args:
        camera: Opened camera device.
        frame: The video frame surface to release.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReleaseCameraFrame.
    """

    return _get_dylib_function[lib, "SDL_ReleaseCameraFrame", fn (camera: Ptr[Camera, AnyOrigin[True]], frame: Ptr[Surface, AnyOrigin[True]]) -> None]()(camera, frame)


fn close_camera(camera: Ptr[Camera, AnyOrigin[True]]) raises -> None:
    """Use this function to shut down camera processing and close the camera
    device.

    Args:
        camera: Opened camera device.

    Safety:
        It is safe to call this function from any thread, but no
        thread may reference `device` once this function is called.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CloseCamera.
    """

    return _get_dylib_function[lib, "SDL_CloseCamera", fn (camera: Ptr[Camera, AnyOrigin[True]]) -> None]()(camera)
