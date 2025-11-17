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

"""Video

SDL's video subsystem is largely interested in abstracting window
management from the underlying operating system. You can create windows,
manage them in various ways, set them fullscreen, and get events when
interesting things happen with them, such as the mouse or keyboard
interacting with a window.

The video subsystem is also interested in abstracting away some
platform-specific differences in OpenGL: context creation, swapping
buffers, etc. This may be crucial to your app, but also you are not
required to use OpenGL at all. In fact, SDL can provide rendering to those
windows as well, either with an easy-to-use
[2D API](https://wiki.libsdl.org/SDL3/CategoryRender)
or with a more-powerful
[GPU API](https://wiki.libsdl.org/SDL3/CategoryGPU)
. Of course, it can simply get out of your way and give you the window
handles you need to use Vulkan, Direct3D, Metal, or whatever else you like
directly, too.

The video subsystem covers a lot of functionality, out of necessity, so it
is worth perusing the list of functions just to see what's available, but
most apps can get by with simply creating a window and listening for
events, so start with SDL_CreateWindow() and SDL_PollEvent().
"""


@register_passable("trivial")
struct DisplayID(Intable):
    """This is a unique ID for a display for the time it is connected to the
    system, and is never reused for the lifetime of the application.

    If the display is disconnected and reconnected, it will get a new ID.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DisplayID.
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
struct WindowID(Intable):
    """This is a unique ID for a window.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WindowID.
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
struct SystemTheme(Indexer, Intable):
    """System theme.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SystemTheme.
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

    comptime SYSTEM_THEME_UNKNOWN = Self(0)
    """Unknown system theme."""
    comptime SYSTEM_THEME_LIGHT = Self(1)
    """Light colored system theme."""
    comptime SYSTEM_THEME_DARK = Self(2)
    """Dark colored system theme."""


@fieldwise_init
struct DisplayModeData(ImplicitlyCopyable, Movable):
    """Internal display mode data.

    This lives as a field in SDL_DisplayMode, as opaque data.

    Docs: https://wiki.libsdl.org/SDL3/DisplayModeData.
    """

    pass


@fieldwise_init
struct DisplayMode(ImplicitlyCopyable, Movable):
    """The structure that defines a display mode.

    Docs: https://wiki.libsdl.org/SDL3/DisplayMode.
    """

    var display_id: DisplayID
    """The display this mode is associated with."""
    var format: PixelFormat
    """Pixel format."""
    var w: c_int
    """Width."""
    var h: c_int
    """Height."""
    var pixel_density: c_float
    """Scale converting size to pixels (e.g. a 1920x1080 mode with 2.0 scale would have 3840x2160 pixels)."""
    var refresh_rate: c_float
    """Refresh rate (or 0.0f for unspecified)."""
    var refresh_rate_numerator: c_int
    """Precise refresh rate numerator (or 0 for unspecified)."""
    var refresh_rate_denominator: c_int
    """Precise refresh rate denominator."""

    var internal: Ptr[DisplayModeData, AnyOrigin[True]]
    """Private."""


@register_passable("trivial")
struct DisplayOrientation(Indexer, Intable):
    """Display orientation values; the way a display is rotated.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DisplayOrientation.
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

    comptime ORIENTATION_UNKNOWN = Self(0)
    """The display orientation can't be determined."""
    comptime ORIENTATION_LANDSCAPE = Self(1)
    """The display is in landscape mode, with the right side up, relative to portrait mode."""
    comptime ORIENTATION_LANDSCAPE_FLIPPED = Self(2)
    """The display is in landscape mode, with the left side up, relative to portrait mode."""
    comptime ORIENTATION_PORTRAIT = Self(3)
    """The display is in portrait mode."""
    comptime ORIENTATION_PORTRAIT_FLIPPED = Self(4)
    """The display is in portrait mode, upside down."""


@fieldwise_init
struct Window(ImplicitlyCopyable, Movable):
    """The struct used as an opaque handle to a window.

    Docs: https://wiki.libsdl.org/SDL3/Window.
    """

    pass


@register_passable("trivial")
struct WindowFlags(Intable):
    """The flags on a window.

    These cover a lot of true/false, or on/off, window state. Some of it is
    immutable after being set through SDL_CreateWindow(), some of it can be
    changed on existing windows by the app, and some of it might be altered by
    the user or system outside of the app's control.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WindowFlags.
    """

    var value: UInt64

    @always_inline
    fn __init__(out self, value: UInt64):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __or__(lhs, rhs: Self) -> Self:
        return Self(lhs.value | rhs.value)

    comptime WINDOW_FULLSCREEN = Self(0x0000000000000001)
    """Window is in fullscreen mode."""
    comptime WINDOW_OPENGL = Self(0x0000000000000002)
    """Window usable with OpenGL context."""
    comptime WINDOW_OCCLUDED = Self(0x0000000000000004)
    """Window is occluded."""
    comptime WINDOW_HIDDEN = Self(0x0000000000000008)
    """Window is neither mapped onto the desktop nor shown in the taskbar/dock/window list; SDL_ShowWindow() is required for it to become visible."""
    comptime WINDOW_BORDERLESS = Self(0x0000000000000010)
    """No window decoration."""
    comptime WINDOW_RESIZABLE = Self(0x0000000000000020)
    """Window can be resized."""
    comptime WINDOW_MINIMIZED = Self(0x0000000000000040)
    """Window is minimized."""
    comptime WINDOW_MAXIMIZED = Self(0x0000000000000080)
    """Window is maximized."""
    comptime WINDOW_MOUSE_GRABBED = Self(0x0000000000000100)
    """Window has grabbed mouse input."""
    comptime WINDOW_INPUT_FOCUS = Self(0x0000000000000200)
    """Window has input focus."""
    comptime WINDOW_MOUSE_FOCUS = Self(0x0000000000000400)
    """Window has mouse focus."""
    comptime WINDOW_EXTERNAL = Self(0x0000000000000800)
    """Window not created by SDL."""
    comptime WINDOW_MODAL = Self(0x0000000000001000)
    """Window is modal."""
    comptime WINDOW_HIGH_PIXEL_DENSITY = Self(0x0000000000002000)
    """Window uses high pixel density back buffer if possible."""
    comptime WINDOW_MOUSE_CAPTURE = Self(0x0000000000004000)
    """Window has mouse captured (unrelated to MOUSE_GRABBED)."""
    comptime WINDOW_MOUSE_RELATIVE_MODE = Self(0x0000000000008000)
    """Window has relative mode enabled."""
    comptime WINDOW_ALWAYS_ON_TOP = Self(0x0000000000010000)
    """Window should always be above others."""
    comptime WINDOW_UTILITY = Self(0x0000000000020000)
    """Window should be treated as a utility window, not showing in the task bar and window list."""
    comptime WINDOW_TOOLTIP = Self(0x0000000000040000)
    """Window should be treated as a tooltip and does not get mouse or keyboard focus, requires a parent window."""
    comptime WINDOW_POPUP_MENU = Self(0x0000000000080000)
    """Window should be treated as a popup menu, requires a parent window."""
    comptime WINDOW_KEYBOARD_GRABBED = Self(0x0000000000100000)
    """Window has grabbed keyboard input."""
    comptime WINDOW_VULKAN = Self(0x0000000010000000)
    """Window usable for Vulkan surface."""
    comptime WINDOW_METAL = Self(0x0000000020000000)
    """Window usable for Metal view."""
    comptime WINDOW_TRANSPARENT = Self(0x0000000040000000)
    """Window with transparent buffer."""
    comptime WINDOW_NOT_FOCUSABLE = Self(0x0000000080000000)
    """Window should not be focusable."""


@register_passable("trivial")
struct FlashOperation(Indexer, Intable):
    """Window flash operation.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FlashOperation.
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

    comptime FLASH_CANCEL = Self(0)
    """Cancel any window flash state."""
    comptime FLASH_BRIEFLY = Self(1)
    """Flash the window briefly to get attention."""
    comptime FLASH_UNTIL_FOCUSED = Self(2)
    """Flash the window until it gets focus."""


comptime GLContext = Ptr[NoneType, AnyOrigin[True]]
"""An opaque handle to an OpenGL context.

Docs: https://wiki.libsdl.org/SDL3/GLContext.
"""

comptime EGLDisplay = Ptr[NoneType, AnyOrigin[True]]
"""Opaque type for an EGL display.

Docs: https://wiki.libsdl.org/SDL3/SDL_EGLDisplay.
"""
comptime EGLConfig = Ptr[NoneType, AnyOrigin[True]]
"""Opaque type for an EGL config.

Docs: https://wiki.libsdl.org/SDL3/SDL_EGLConfig.
"""
comptime EGLSurface = Ptr[NoneType, AnyOrigin[True]]
"""Opaque type for an EGL surface.

Docs: https://wiki.libsdl.org/SDL3/SDL_EGLSurface.
"""


@register_passable("trivial")
struct EGLAttrib(Intable):
    """An EGL attribute, used when creating an EGL context.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EGLAttrib.
    """

    var value: Int

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __or__(lhs, rhs: Self) -> Self:
        return Self(lhs.value | rhs.value)


@register_passable("trivial")
struct EGLint(Intable):
    """An EGL integer attribute, used when creating an EGL surface.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EGLint.
    """

    var value: c_int

    @always_inline
    fn __init__(out self, value: c_int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __or__(lhs, rhs: Self) -> Self:
        return Self(lhs.value | rhs.value)


comptime EGLAttribArrayCallback = Ptr[fn (userdata: Ptr[NoneType, AnyOrigin[True]]) -> EGLAttrib, AnyOrigin[True]]
"""EGL platform attribute initialization callback.
    
    This is called when SDL is attempting to create an EGL context, to let the
    app add extra attributes to its eglGetPlatformDisplay() call.
    
    The callback should return a pointer to an EGL attribute array terminated
    with `EGL_NONE`. If this function returns NULL, the SDL_CreateWindow
    process will fail gracefully.
    
    The returned pointer should be allocated with SDL_malloc() and will be
    passed to SDL_free().
    
    The arrays returned by each callback will be appended to the existing
    attribute arrays defined by SDL.
    
    Args:
        userdata: An app-controlled pointer that is passed to the callback.
    
    Returns:
        A newly-allocated array of attributes, terminated with `EGL_NONE`.

Docs: https://wiki.libsdl.org/SDL3/SDL_EGLAttribArrayCallback.
"""


comptime EGLIntArrayCallback = Ptr[fn (userdata: Ptr[NoneType, AnyOrigin[True]], display: EGLDisplay, config: EGLConfig) -> EGLint, AnyOrigin[True]]
"""EGL surface/context attribute initialization callback types.
    
    This is called when SDL is attempting to create an EGL surface, to let the
    app add extra attributes to its eglCreateWindowSurface() or
    eglCreateContext calls.
    
    For convenience, the EGLDisplay and EGLConfig to use are provided to the
    callback.
    
    The callback should return a pointer to an EGL attribute array terminated
    with `EGL_NONE`. If this function returns NULL, the SDL_CreateWindow
    process will fail gracefully.
    
    The returned pointer should be allocated with SDL_malloc() and will be
    passed to SDL_free().
    
    The arrays returned by each callback will be appended to the existing
    attribute arrays defined by SDL.
    
    Args:
        userdata: An app-controlled pointer that is passed to the callback.
        display: The EGL display to be used.
        config: The EGL config to be used.
    
    Returns:
        A newly-allocated array of attributes, terminated with `EGL_NONE`.

Docs: https://wiki.libsdl.org/SDL3/SDL_EGLIntArrayCallback.
"""


@register_passable("trivial")
struct GLAttr(Indexer, Intable):
    """An enumeration of OpenGL configuration attributes.

    While you can set most OpenGL attributes normally, the attributes listed
    above must be known before SDL creates the window that will be used with
    the OpenGL context. These attributes are set and read with
    SDL_GL_SetAttribute() and SDL_GL_GetAttribute().

    In some cases, these attributes are minimum requests; the GL does not
    promise to give you exactly what you asked for. It's possible to ask for a
    16-bit depth buffer and get a 24-bit one instead, for example, or to ask
    for no stencil buffer and still have one available. Context creation should
    fail if the GL can't provide your requested attributes at a minimum, but
    you should check to see exactly what you got.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GLAttr.
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

    comptime GL_RED_SIZE = Self(0)
    """The minimum number of bits for the red channel of the color buffer; defaults to 8."""
    comptime GL_GREEN_SIZE = Self(1)
    """The minimum number of bits for the green channel of the color buffer; defaults to 8."""
    comptime GL_BLUE_SIZE = Self(2)
    """The minimum number of bits for the blue channel of the color buffer; defaults to 8."""
    comptime GL_ALPHA_SIZE = Self(3)
    """The minimum number of bits for the alpha channel of the color buffer; defaults to 8."""
    comptime GL_BUFFER_SIZE = Self(4)
    """The minimum number of bits for frame buffer size; defaults to 0."""
    comptime GL_DOUBLEBUFFER = Self(5)
    """Whether the output is single or double buffered; defaults to double buffering on."""
    comptime GL_DEPTH_SIZE = Self(6)
    """The minimum number of bits in the depth buffer; defaults to 16."""
    comptime GL_STENCIL_SIZE = Self(7)
    """The minimum number of bits in the stencil buffer; defaults to 0."""
    comptime GL_ACCUM_RED_SIZE = Self(8)
    """The minimum number of bits for the red channel of the accumulation buffer; defaults to 0."""
    comptime GL_ACCUM_GREEN_SIZE = Self(9)
    """The minimum number of bits for the green channel of the accumulation buffer; defaults to 0."""
    comptime GL_ACCUM_BLUE_SIZE = Self(10)
    """The minimum number of bits for the blue channel of the accumulation buffer; defaults to 0."""
    comptime GL_ACCUM_ALPHA_SIZE = Self(11)
    """The minimum number of bits for the alpha channel of the accumulation buffer; defaults to 0."""
    comptime GL_STEREO = Self(12)
    """Whether the output is stereo 3D; defaults to off."""
    comptime GL_MULTISAMPLEBUFFERS = Self(13)
    """The number of buffers used for multisample anti-aliasing; defaults to 0."""
    comptime GL_MULTISAMPLESAMPLES = Self(14)
    """The number of samples used around the current pixel used for multisample anti-aliasing."""
    comptime GL_ACCELERATED_VISUAL = Self(15)
    """Set to 1 to require hardware acceleration, set to 0 to force software rendering; defaults to allow either."""
    comptime GL_RETAINED_BACKING = Self(16)
    """Not used (deprecated)."""
    comptime GL_CONTEXT_MAJOR_VERSION = Self(17)
    """OpenGL context major version."""
    comptime GL_CONTEXT_MINOR_VERSION = Self(18)
    """OpenGL context minor version."""
    comptime GL_CONTEXT_FLAGS = Self(19)
    """Some combination of 0 or more of elements of the SDL_GLContextFlag enumeration; defaults to 0."""
    comptime GL_CONTEXT_PROFILE_MASK = Self(20)
    """Type of GL context (Core, Compatibility, ES). See SDL_GLProfile; default value depends on platform."""
    comptime GL_SHARE_WITH_CURRENT_CONTEXT = Self(21)
    """OpenGL context sharing; defaults to 0."""
    comptime GL_FRAMEBUFFER_SRGB_CAPABLE = Self(22)
    """Requests sRGB capable visual; defaults to 0."""
    comptime GL_CONTEXT_RELEASE_BEHAVIOR = Self(23)
    """Sets context the release behavior. See SDL_GLContextReleaseFlag; defaults to FLUSH."""
    comptime GL_CONTEXT_RESET_NOTIFICATION = Self(24)
    """Set context reset notification. See SDL_GLContextResetNotification; defaults to NO_NOTIFICATION."""
    comptime GL_CONTEXT_NO_ERROR = Self(25)
    comptime GL_FLOATBUFFERS = Self(26)
    comptime GL_EGL_PLATFORM = Self(27)


@register_passable("trivial")
struct GLProfile(Intable):
    """Possible values to be set for the SDL_GL_CONTEXT_PROFILE_MASK attribute.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GLProfile.
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

    comptime GL_CONTEXT_PROFILE_CORE = Self(0x0001)
    """OpenGL Core Profile context."""
    comptime GL_CONTEXT_PROFILE_COMPATIBILITY = Self(0x0002)
    """OpenGL Compatibility Profile context."""
    comptime GL_CONTEXT_PROFILE_ES = Self(0x0004)
    """GLX_CONTEXT_ES2_PROFILE_BIT_EXT."""


@register_passable("trivial")
struct GLContextFlag(Intable):
    """Possible flags to be set for the SDL_GL_CONTEXT_FLAGS attribute.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GLContextFlag.
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

    comptime GL_CONTEXT_DEBUG_FLAG = Self(0x0001)
    comptime GL_CONTEXT_FORWARD_COMPATIBLE_FLAG = Self(0x0002)
    comptime GL_CONTEXT_ROBUST_ACCESS_FLAG = Self(0x0004)
    comptime GL_CONTEXT_RESET_ISOLATION_FLAG = Self(0x0008)


@register_passable("trivial")
struct GLContextReleaseFlag(Intable):
    """Possible values to be set for the SDL_GL_CONTEXT_RELEASE_BEHAVIOR
    attribute.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GLContextReleaseFlag.
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

    comptime GL_CONTEXT_RELEASE_BEHAVIOR_NONE = Self(0x0000)
    comptime GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH = Self(0x0001)


@register_passable("trivial")
struct GLContextResetNotification(Intable):
    """Possible values to be set SDL_GL_CONTEXT_RESET_NOTIFICATION attribute.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GLContextResetNotification.
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

    comptime GL_CONTEXT_RESET_NO_NOTIFICATION = Self(0x0000)
    comptime GL_CONTEXT_RESET_LOSE_CONTEXT = Self(0x0001)


fn get_num_video_drivers() raises -> c_int:
    """Get the number of video drivers compiled into SDL.

    Returns:
        The number of built in video drivers.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumVideoDrivers.
    """

    return _get_dylib_function[lib, "SDL_GetNumVideoDrivers", fn () -> c_int]()()


fn get_video_driver(index: c_int) raises -> Ptr[c_char, AnyOrigin[False]]:
    """Get the name of a built in video driver.

    The video drivers are presented in the order in which they are normally
    checked during initialization.

    The names of drivers are all simple, low-ASCII identifiers, like "cocoa",
    "x11" or "windows". These never have Unicode characters, and are not meant
    to be proper names.

    Args:
        index: The index of a video driver.

    Returns:
        The name of the video driver with the given **index**.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetVideoDriver.
    """

    return _get_dylib_function[lib, "SDL_GetVideoDriver", fn (index: c_int) -> Ptr[c_char, AnyOrigin[False]]]()(index)


fn get_current_video_driver() raises -> Ptr[c_char, AnyOrigin[False]]:
    """Get the name of the currently initialized video driver.

    The names of drivers are all simple, low-ASCII identifiers, like "cocoa",
    "x11" or "windows". These never have Unicode characters, and are not meant
    to be proper names.

    Returns:
        The name of the current video driver or NULL if no driver has been
        initialized.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCurrentVideoDriver.
    """

    return _get_dylib_function[lib, "SDL_GetCurrentVideoDriver", fn () -> Ptr[c_char, AnyOrigin[False]]]()()


fn get_system_theme() raises -> SystemTheme:
    """Get the current system theme.

    Returns:
        The current system theme, light, dark, or unknown.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSystemTheme.
    """

    return _get_dylib_function[lib, "SDL_GetSystemTheme", fn () -> SystemTheme]()()


fn get_displays(count: Ptr[c_int, AnyOrigin[True]], out ret: Ptr[DisplayID, AnyOrigin[True]]) raises:
    """Get a list of currently connected displays.

    Args:
        count: A pointer filled in with the number of displays returned, may
               be NULL.

    Returns:
        A 0 terminated array of display instance IDs or NULL on failure;
        call SDL_GetError() for more information. This should be freed
        with SDL_free() when it is no longer needed.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDisplays.
    """

    ret = _get_dylib_function[lib, "SDL_GetDisplays", fn (count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[DisplayID, AnyOrigin[True]]]()(count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_primary_display() raises -> DisplayID:
    """Return the primary display.

    Returns:
        The instance ID of the primary display on success or 0 on failure;
        call SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPrimaryDisplay.
    """

    return _get_dylib_function[lib, "SDL_GetPrimaryDisplay", fn () -> DisplayID]()()


fn get_display_properties(display_id: DisplayID) raises -> PropertiesID:
    """Get the properties associated with a display.

    The following read-only properties are provided by SDL:

    - `SDL_PROP_DISPLAY_HDR_ENABLED_BOOLEAN`: true if the display has HDR
      headroom above the SDR white point. This is for informational and
      diagnostic purposes only, as not all platforms provide this information
      at the display level.

    On KMS/DRM:

    - `SDL_PROP_DISPLAY_KMSDRM_PANEL_ORIENTATION_NUMBER`: the "panel
      orientation" property for the display in degrees of clockwise rotation.
      Note that this is provided only as a hint, and the application is
      responsible for any coordinate transformations needed to conform to the
      requested display orientation.

    Args:
        display_id: The instance ID of the display to query.

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDisplayProperties.
    """

    return _get_dylib_function[lib, "SDL_GetDisplayProperties", fn (display_id: DisplayID) -> PropertiesID]()(display_id)


fn get_display_name(display_id: DisplayID, out ret: Ptr[c_char, AnyOrigin[False]]) raises:
    """Get the name of a display in UTF-8 encoding.

    Args:
        display_id: The instance ID of the display to query.

    Returns:
        The name of a display or NULL on failure; call SDL_GetError() for
        more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDisplayName.
    """

    ret = _get_dylib_function[lib, "SDL_GetDisplayName", fn (display_id: DisplayID) -> Ptr[c_char, AnyOrigin[False]]]()(display_id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_display_bounds(display_id: DisplayID, rect: Ptr[Rect, AnyOrigin[True]]) raises:
    """Get the desktop area represented by a display.

    The primary display is often located at (0,0), but may be placed at a
    different location depending on monitor layout.

    Args:
        display_id: The instance ID of the display to query.
        rect: The SDL_Rect structure filled in with the display bounds.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDisplayBounds.
    """

    ret = _get_dylib_function[lib, "SDL_GetDisplayBounds", fn (display_id: DisplayID, rect: Ptr[Rect, AnyOrigin[True]]) -> Bool]()(display_id, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_display_usable_bounds(display_id: DisplayID, rect: Ptr[Rect, AnyOrigin[True]]) raises:
    """Get the usable desktop area represented by a display, in screen
    coordinates.

    This is the same area as SDL_GetDisplayBounds() reports, but with portions
    reserved by the system removed. For example, on Apple's macOS, this
    subtracts the area occupied by the menu bar and dock.

    Setting a window to be fullscreen generally bypasses these unusable areas,
    so these are good guidelines for the maximum space available to a
    non-fullscreen window.

    Args:
        display_id: The instance ID of the display to query.
        rect: The SDL_Rect structure filled in with the display bounds.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDisplayUsableBounds.
    """

    ret = _get_dylib_function[lib, "SDL_GetDisplayUsableBounds", fn (display_id: DisplayID, rect: Ptr[Rect, AnyOrigin[True]]) -> Bool]()(display_id, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_natural_display_orientation(display_id: DisplayID) raises -> DisplayOrientation:
    """Get the orientation of a display when it is unrotated.

    Args:
        display_id: The instance ID of the display to query.

    Returns:
        The SDL_DisplayOrientation enum value of the display, or
        `SDL_ORIENTATION_UNKNOWN` if it isn't available.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNaturalDisplayOrientation.
    """

    return _get_dylib_function[lib, "SDL_GetNaturalDisplayOrientation", fn (display_id: DisplayID) -> DisplayOrientation]()(display_id)


fn get_current_display_orientation(display_id: DisplayID) raises -> DisplayOrientation:
    """Get the orientation of a display.

    Args:
        display_id: The instance ID of the display to query.

    Returns:
        The SDL_DisplayOrientation enum value of the display, or
        `SDL_ORIENTATION_UNKNOWN` if it isn't available.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCurrentDisplayOrientation.
    """

    return _get_dylib_function[lib, "SDL_GetCurrentDisplayOrientation", fn (display_id: DisplayID) -> DisplayOrientation]()(display_id)


fn get_display_content_scale(display_id: DisplayID) raises -> c_float:
    """Get the content scale of a display.

    The content scale is the expected scale for content based on the DPI
    settings of the display. For example, a 4K display might have a 2.0 (200%)
    display scale, which means that the user expects UI elements to be twice as
    big on this display, to aid in readability.

    After window creation, SDL_GetWindowDisplayScale() should be used to query
    the content scale factor for individual windows instead of querying the
    display for a window and calling this function, as the per-window content
    scale factor may differ from the base value of the display it is on,
    particularly on high-DPI and/or multi-monitor desktop configurations.

    Args:
        display_id: The instance ID of the display to query.

    Returns:
        The content scale of the display, or 0.0f on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDisplayContentScale.
    """

    return _get_dylib_function[lib, "SDL_GetDisplayContentScale", fn (display_id: DisplayID) -> c_float]()(display_id)


fn get_fullscreen_display_modes(display_id: DisplayID, count: Ptr[c_int, AnyOrigin[True]]) raises -> Ptr[Ptr[DisplayMode, AnyOrigin[True]], AnyOrigin[True]]:
    """Get a list of fullscreen display modes available on a display.

    The display modes are sorted in this priority:

    - w -> largest to smallest
    - h -> largest to smallest
    - bits per pixel -> more colors to fewer colors
    - packed pixel layout -> largest to smallest
    - refresh rate -> highest to lowest
    - pixel density -> lowest to highest

    Args:
        display_id: The instance ID of the display to query.
        count: A pointer filled in with the number of display modes returned,
               may be NULL.

    Returns:
        A NULL terminated array of display mode pointers or NULL on
        failure; call SDL_GetError() for more information. This is a
        single allocation that should be freed with SDL_free() when it is
        no longer needed.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetFullscreenDisplayModes.
    """

    return _get_dylib_function[lib, "SDL_GetFullscreenDisplayModes", fn (display_id: DisplayID, count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[Ptr[DisplayMode, AnyOrigin[True]], AnyOrigin[True]]]()(display_id, count)


fn get_closest_fullscreen_display_mode(display_id: DisplayID, w: c_int, h: c_int, refresh_rate: c_float, include_high_density_modes: Bool, closest: Ptr[DisplayMode, AnyOrigin[True]]) raises:
    """Get the closest match to the requested display mode.

    The available display modes are scanned and `closest` is filled in with the
    closest mode matching the requested mode and returned. The mode format and
    refresh rate default to the desktop mode if they are set to 0. The modes
    are scanned with size being first priority, format being second priority,
    and finally checking the refresh rate. If all the available modes are too
    small, then false is returned.

    Args:
        display_id: The instance ID of the display to query.
        w: The width in pixels of the desired display mode.
        h: The height in pixels of the desired display mode.
        refresh_rate: The refresh rate of the desired display mode, or 0.0f
                      for the desktop refresh rate.
        include_high_density_modes: Boolean to include high density modes in
                                    the search.
        closest: A pointer filled in with the closest display mode equal to
                 or larger than the desired mode.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetClosestFullscreenDisplayMode.
    """

    ret = _get_dylib_function[lib, "SDL_GetClosestFullscreenDisplayMode", fn (display_id: DisplayID, w: c_int, h: c_int, refresh_rate: c_float, include_high_density_modes: Bool, closest: Ptr[DisplayMode, AnyOrigin[True]]) -> Bool]()(display_id, w, h, refresh_rate, include_high_density_modes, closest)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_desktop_display_mode(display_id: DisplayID, out ret: Ptr[DisplayMode, AnyOrigin[False]]) raises:
    """Get information about the desktop's display mode.

    There's a difference between this function and SDL_GetCurrentDisplayMode()
    when SDL runs fullscreen and has changed the resolution. In that case this
    function will return the previous native display mode, and not the current
    display mode.

    Args:
        display_id: The instance ID of the display to query.

    Returns:
        A pointer to the desktop display mode or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDesktopDisplayMode.
    """

    ret = _get_dylib_function[lib, "SDL_GetDesktopDisplayMode", fn (display_id: DisplayID) -> Ptr[DisplayMode, AnyOrigin[False]]]()(display_id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_current_display_mode(display_id: DisplayID, out ret: Ptr[DisplayMode, AnyOrigin[False]]) raises:
    """Get information about the current display mode.

    There's a difference between this function and SDL_GetDesktopDisplayMode()
    when SDL runs fullscreen and has changed the resolution. In that case this
    function will return the current display mode, and not the previous native
    display mode.

    Args:
        display_id: The instance ID of the display to query.

    Returns:
        A pointer to the desktop display mode or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCurrentDisplayMode.
    """

    ret = _get_dylib_function[lib, "SDL_GetCurrentDisplayMode", fn (display_id: DisplayID) -> Ptr[DisplayMode, AnyOrigin[False]]]()(display_id)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_display_for_point(point: Ptr[Point, AnyOrigin[False]]) raises -> DisplayID:
    """Get the display containing a point.

    Args:
        point: The point to query.

    Returns:
        The instance ID of the display containing the point or 0 on
        failure; call SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDisplayForPoint.
    """

    return _get_dylib_function[lib, "SDL_GetDisplayForPoint", fn (point: Ptr[Point, AnyOrigin[False]]) -> DisplayID]()(point)


fn get_display_for_rect(rect: Ptr[Rect, AnyOrigin[False]]) raises -> DisplayID:
    """Get the display primarily containing a rect.

    Args:
        rect: The rect to query.

    Returns:
        The instance ID of the display entirely containing the rect or
        closest to the center of the rect on success or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDisplayForRect.
    """

    return _get_dylib_function[lib, "SDL_GetDisplayForRect", fn (rect: Ptr[Rect, AnyOrigin[False]]) -> DisplayID]()(rect)


fn get_display_for_window(window: Ptr[Window, AnyOrigin[True]]) raises -> DisplayID:
    """Get the display associated with a window.

    Args:
        window: The window to query.

    Returns:
        The instance ID of the display containing the center of the window
        on success or 0 on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetDisplayForWindow.
    """

    return _get_dylib_function[lib, "SDL_GetDisplayForWindow", fn (window: Ptr[Window, AnyOrigin[True]]) -> DisplayID]()(window)


fn get_window_pixel_density(window: Ptr[Window, AnyOrigin[True]]) raises -> c_float:
    """Get the pixel density of a window.

    This is a ratio of pixel size to window size. For example, if the window is
    1920x1080 and it has a high density back buffer of 3840x2160 pixels, it
    would have a pixel density of 2.0.

    Args:
        window: The window to query.

    Returns:
        The pixel density or 0.0f on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowPixelDensity.
    """

    return _get_dylib_function[lib, "SDL_GetWindowPixelDensity", fn (window: Ptr[Window, AnyOrigin[True]]) -> c_float]()(window)


fn get_window_display_scale(window: Ptr[Window, AnyOrigin[True]]) raises -> c_float:
    """Get the content display scale relative to a window's pixel size.

    This is a combination of the window pixel density and the display content
    scale, and is the expected scale for displaying content in this window. For
    example, if a 3840x2160 window had a display scale of 2.0, the user expects
    the content to take twice as many pixels and be the same physical size as
    if it were being displayed in a 1920x1080 window with a display scale of
    1.0.

    Conceptually this value corresponds to the scale display setting, and is
    updated when that setting is changed, or the window moves to a display with
    a different scale setting.

    Args:
        window: The window to query.

    Returns:
        The display scale, or 0.0f on failure; call SDL_GetError() for
        more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowDisplayScale.
    """

    return _get_dylib_function[lib, "SDL_GetWindowDisplayScale", fn (window: Ptr[Window, AnyOrigin[True]]) -> c_float]()(window)


fn set_window_fullscreen_mode(window: Ptr[Window, AnyOrigin[True]], mode: Ptr[DisplayMode, AnyOrigin[False]]) raises:
    """Set the display mode to use when a window is visible and fullscreen.

    This only affects the display mode used when the window is fullscreen. To
    change the window size when the window is not fullscreen, use
    SDL_SetWindowSize().

    If the window is currently in the fullscreen state, this request is
    asynchronous on some windowing systems and the new mode dimensions may not
    be applied immediately upon the return of this function. If an immediate
    change is required, call SDL_SyncWindow() to block until the changes have
    taken effect.

    When the new mode takes effect, an SDL_EVENT_WINDOW_RESIZED and/or an
    SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED event will be emitted with the new mode
    dimensions.

    Args:
        window: The window to affect.
        mode: A pointer to the display mode to use, which can be NULL for
              borderless fullscreen desktop mode, or one of the fullscreen
              modes returned by SDL_GetFullscreenDisplayModes() to set an
              exclusive fullscreen mode.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowFullscreenMode.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowFullscreenMode", fn (window: Ptr[Window, AnyOrigin[True]], mode: Ptr[DisplayMode, AnyOrigin[False]]) -> Bool]()(window, mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_fullscreen_mode(window: Ptr[Window, AnyOrigin[True]]) raises -> Ptr[DisplayMode, AnyOrigin[False]]:
    """Query the display mode to use when a window is visible at fullscreen.

    Args:
        window: The window to query.

    Returns:
        A pointer to the exclusive fullscreen mode to use or NULL for
        borderless fullscreen desktop mode.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowFullscreenMode.
    """

    return _get_dylib_function[lib, "SDL_GetWindowFullscreenMode", fn (window: Ptr[Window, AnyOrigin[True]]) -> Ptr[DisplayMode, AnyOrigin[False]]]()(window)


fn get_window_icc_profile(window: Ptr[Window, AnyOrigin[True]], size: Ptr[c_size_t, AnyOrigin[True]], out ret: Ptr[NoneType, AnyOrigin[True]]) raises:
    """Get the raw ICC profile data for the screen the window is currently on.

    Args:
        window: The window to query.
        size: The size of the ICC profile.

    Returns:
        The raw ICC profile data on success or NULL on failure; call
        SDL_GetError() for more information. This should be freed with
        SDL_free() when it is no longer needed.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowICCProfile.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowICCProfile", fn (window: Ptr[Window, AnyOrigin[True]], size: Ptr[c_size_t, AnyOrigin[True]]) -> Ptr[NoneType, AnyOrigin[True]]]()(window, size)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_pixel_format(window: Ptr[Window, AnyOrigin[True]]) raises -> PixelFormat:
    """Get the pixel format associated with the window.

    Args:
        window: The window to query.

    Returns:
        The pixel format of the window on success or
        SDL_PIXELFORMAT_UNKNOWN on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowPixelFormat.
    """

    return _get_dylib_function[lib, "SDL_GetWindowPixelFormat", fn (window: Ptr[Window, AnyOrigin[True]]) -> PixelFormat]()(window)


fn get_windows(count: Ptr[c_int, AnyOrigin[True]], out ret: Ptr[Ptr[Window, AnyOrigin[True]], AnyOrigin[True]]) raises:
    """Get a list of valid windows.

    Args:
        count: A pointer filled in with the number of windows returned, may
               be NULL.

    Returns:
        A NULL terminated array of SDL_Window pointers or NULL on failure;
        call SDL_GetError() for more information. This is a single
        allocation that should be freed with SDL_free() when it is no
        longer needed.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindows.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindows", fn (count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[Ptr[Window, AnyOrigin[True]], AnyOrigin[True]]]()(count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_window(var title: String, w: c_int, h: c_int, flags: WindowFlags, out ret: Ptr[Window, AnyOrigin[True]]) raises:
    """Create a window with the specified dimensions and flags.

    The window size is a request and may be different than expected based on
    the desktop layout and window manager policies. Your application should be
    prepared to handle a window of any size.

    `flags` may be any of the following OR'd together:

    - `SDL_WINDOW_FULLSCREEN`: fullscreen window at desktop resolution
    - `SDL_WINDOW_OPENGL`: window usable with an OpenGL context
    - `SDL_WINDOW_OCCLUDED`: window partially or completely obscured by another
      window
    - `SDL_WINDOW_HIDDEN`: window is not visible
    - `SDL_WINDOW_BORDERLESS`: no window decoration
    - `SDL_WINDOW_RESIZABLE`: window can be resized
    - `SDL_WINDOW_MINIMIZED`: window is minimized
    - `SDL_WINDOW_MAXIMIZED`: window is maximized
    - `SDL_WINDOW_MOUSE_GRABBED`: window has grabbed mouse focus
    - `SDL_WINDOW_INPUT_FOCUS`: window has input focus
    - `SDL_WINDOW_MOUSE_FOCUS`: window has mouse focus
    - `SDL_WINDOW_EXTERNAL`: window not created by SDL
    - `SDL_WINDOW_MODAL`: window is modal
    - `SDL_WINDOW_HIGH_PIXEL_DENSITY`: window uses high pixel density back
      buffer if possible
    - `SDL_WINDOW_MOUSE_CAPTURE`: window has mouse captured (unrelated to
      MOUSE_GRABBED)
    - `SDL_WINDOW_ALWAYS_ON_TOP`: window should always be above others
    - `SDL_WINDOW_UTILITY`: window should be treated as a utility window, not
      showing in the task bar and window list
    - `SDL_WINDOW_TOOLTIP`: window should be treated as a tooltip and does not
      get mouse or keyboard focus, requires a parent window
    - `SDL_WINDOW_POPUP_MENU`: window should be treated as a popup menu,
      requires a parent window
    - `SDL_WINDOW_KEYBOARD_GRABBED`: window has grabbed keyboard input
    - `SDL_WINDOW_VULKAN`: window usable with a Vulkan instance
    - `SDL_WINDOW_METAL`: window usable with a Metal instance
    - `SDL_WINDOW_TRANSPARENT`: window with transparent buffer
    - `SDL_WINDOW_NOT_FOCUSABLE`: window should not be focusable

    The SDL_Window is implicitly shown if SDL_WINDOW_HIDDEN is not set.

    On Apple's macOS, you **must** set the NSHighResolutionCapable Info.plist
    property to YES, otherwise you will not receive a High-DPI OpenGL canvas.

    The window pixel size may differ from its window coordinate size if the
    window is on a high pixel density display. Use SDL_GetWindowSize() to query
    the client area's size in window coordinates, and
    SDL_GetWindowSizeInPixels() or SDL_GetRenderOutputSize() to query the
    drawable size in pixels. Note that the drawable size can vary after the
    window is created and should be queried again if you get an
    SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED event.

    If the window is created with any of the SDL_WINDOW_OPENGL or
    SDL_WINDOW_VULKAN flags, then the corresponding LoadLibrary function
    (SDL_GL_LoadLibrary or SDL_Vulkan_LoadLibrary) is called and the
    corresponding UnloadLibrary function is called by SDL_DestroyWindow().

    If SDL_WINDOW_VULKAN is specified and there isn't a working Vulkan driver,
    SDL_CreateWindow() will fail, because SDL_Vulkan_LoadLibrary() will fail.

    If SDL_WINDOW_METAL is specified on an OS that does not support Metal,
    SDL_CreateWindow() will fail.

    If you intend to use this window with an SDL_Renderer, you should use
    SDL_CreateWindowAndRenderer() instead of this function, to avoid window
    flicker.

    On non-Apple devices, SDL requires you to either not link to the Vulkan
    loader or link to a dynamic library version. This limitation may be removed
    in a future version of SDL.

    Args:
        title: The title of the window, in UTF-8 encoding.
        w: The width of the window.
        h: The height of the window.
        flags: 0, or one or more SDL_WindowFlags OR'd together.

    Returns:
        The window that was created or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateWindow.
    """

    ret = _get_dylib_function[lib, "SDL_CreateWindow", fn (title: Ptr[c_char, AnyOrigin[False]], w: c_int, h: c_int, flags: WindowFlags) -> Ptr[Window, AnyOrigin[True]]]()(title.unsafe_cstr_ptr(), w, h, flags)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_popup_window(parent: Ptr[Window, AnyOrigin[True]], offset_x: c_int, offset_y: c_int, w: c_int, h: c_int, flags: WindowFlags, out ret: Ptr[Window, AnyOrigin[True]]) raises:
    """Create a child popup window of the specified parent window.

    The window size is a request and may be different than expected based on
    the desktop layout and window manager policies. Your application should be
    prepared to handle a window of any size.

    The flags parameter **must** contain at least one of the following:

    - `SDL_WINDOW_TOOLTIP`: The popup window is a tooltip and will not pass any
      input events.
    - `SDL_WINDOW_POPUP_MENU`: The popup window is a popup menu. The topmost
      popup menu will implicitly gain the keyboard focus.

    The following flags are not relevant to popup window creation and will be
    ignored:

    - `SDL_WINDOW_MINIMIZED`
    - `SDL_WINDOW_MAXIMIZED`
    - `SDL_WINDOW_FULLSCREEN`
    - `SDL_WINDOW_BORDERLESS`

    The following flags are incompatible with popup window creation and will
    cause it to fail:

    - `SDL_WINDOW_UTILITY`
    - `SDL_WINDOW_MODAL`

    The parent parameter **must** be non-null and a valid window. The parent of
    a popup window can be either a regular, toplevel window, or another popup
    window.

    Popup windows cannot be minimized, maximized, made fullscreen, raised,
    flash, be made a modal window, be the parent of a toplevel window, or grab
    the mouse and/or keyboard. Attempts to do so will fail.

    Popup windows implicitly do not have a border/decorations and do not appear
    on the taskbar/dock or in lists of windows such as alt-tab menus.

    By default, popup window positions will automatically be constrained to keep
    the entire window within display bounds. This can be overridden with the
    `SDL_PROP_WINDOW_CREATE_CONSTRAIN_POPUP_BOOLEAN` property.

    By default, popup menus will automatically grab keyboard focus from the parent
    when shown. This behavior can be overridden by setting the `SDL_WINDOW_NOT_FOCUSABLE`
    flag, setting the `SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN` property to false, or
    toggling it after creation via the `SDL_SetWindowFocusable()` function.

    If a parent window is hidden or destroyed, any child popup windows will be
    recursively hidden or destroyed as well. Child popup windows not explicitly
    hidden will be restored when the parent is shown.

    Args:
        parent: The parent of the window, must not be NULL.
        offset_x: The x position of the popup window relative to the origin
                  of the parent.
        offset_y: The y position of the popup window relative to the origin
                  of the parent window.
        w: The width of the window.
        h: The height of the window.
        flags: SDL_WINDOW_TOOLTIP or SDL_WINDOW_POPUP_MENU, and zero or more
               additional SDL_WindowFlags OR'd together.

    Returns:
        The window that was created or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreatePopupWindow.
    """

    ret = _get_dylib_function[lib, "SDL_CreatePopupWindow", fn (parent: Ptr[Window, AnyOrigin[True]], offset_x: c_int, offset_y: c_int, w: c_int, h: c_int, flags: WindowFlags) -> Ptr[Window, AnyOrigin[True]]]()(parent, offset_x, offset_y, w, h, flags)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_window_with_properties(props: PropertiesID, out ret: Ptr[Window, AnyOrigin[True]]) raises:
    """Create a window with the specified properties.

    The window size is a request and may be different than expected based on
    the desktop layout and window manager policies. Your application should be
    prepared to handle a window of any size.

    These are the supported properties:

    - `SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN`: true if the window should
      be always on top
    - `SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN`: true if the window has no
      window decoration
    - `SDL_PROP_WINDOW_CREATE_CONSTRAIN_POPUP_BOOLEAN`: true if the "tooltip" and
      "menu" window types should be automatically constrained to be entirely within
      display bounds (default), false if no constraints on the position are desired.
    - `SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN`: true if the
      window will be used with an externally managed graphics context.
    - `SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN`: true if the window should
      accept keyboard input (defaults true)
    - `SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN`: true if the window should
      start in fullscreen mode at desktop resolution
    - `SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER`: the height of the window
    - `SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN`: true if the window should start
      hidden
    - `SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN`: true if the window
      uses a high pixel density buffer if possible
    - `SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN`: true if the window should
      start maximized
    - `SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN`: true if the window is a popup menu
    - `SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN`: true if the window will be used
      with Metal rendering
    - `SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN`: true if the window should
      start minimized
    - `SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN`: true if the window is modal to
      its parent
    - `SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN`: true if the window starts
      with grabbed mouse focus
    - `SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN`: true if the window will be used
      with OpenGL rendering
    - `SDL_PROP_WINDOW_CREATE_PARENT_POINTER`: an SDL_Window that will be the
      parent of this window, required for windows with the "tooltip", "menu",
      and "modal" properties
    - `SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN`: true if the window should be
      resizable
    - `SDL_PROP_WINDOW_CREATE_TITLE_STRING`: the title of the window, in UTF-8
      encoding
    - `SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN`: true if the window show
      transparent in the areas with alpha of 0
    - `SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN`: true if the window is a tooltip
    - `SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN`: true if the window is a utility
      window, not showing in the task bar and window list
    - `SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN`: true if the window will be used
      with Vulkan rendering
    - `SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER`: the width of the window
    - `SDL_PROP_WINDOW_CREATE_X_NUMBER`: the x position of the window, or
      `SDL_WINDOWPOS_CENTERED`, defaults to `SDL_WINDOWPOS_UNDEFINED`. This is
      relative to the parent for windows with the "tooltip" or "menu" property
      set.
    - `SDL_PROP_WINDOW_CREATE_Y_NUMBER`: the y position of the window, or
      `SDL_WINDOWPOS_CENTERED`, defaults to `SDL_WINDOWPOS_UNDEFINED`. This is
      relative to the parent for windows with the "tooltip" or "menu" property
      set.

    These are additional supported properties on macOS:

    - `SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER`: the
      `(__unsafe_unretained)` NSWindow associated with the window, if you want
      to wrap an existing window.
    - `SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER`: the `(__unsafe_unretained)`
      NSView associated with the window, defaults to `[window contentView]`

    These are additional supported properties on Wayland:

    - `SDL_PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN` - true if
      the application wants to use the Wayland surface for a custom role and
      does not want it attached to an XDG toplevel window. See
      [README/wayland](README/wayland) for more information on using custom
      surfaces.
    - `SDL_PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN` - true if the
      application wants an associated `wl_egl_window` object to be created and
      attached to the window, even if the window does not have the OpenGL
      property or `SDL_WINDOW_OPENGL` flag set.
    - `SDL_PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER` - the wl_surface
      associated with the window, if you want to wrap an existing window. See
      [README/wayland](README/wayland) for more information.

    These are additional supported properties on Windows:

    - `SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER`: the HWND associated with the
      window, if you want to wrap an existing window.
    - `SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER`: optional,
      another window to share pixel format with, useful for OpenGL windows

    These are additional supported properties with X11:

    - `SDL_PROP_WINDOW_CREATE_X11_WINDOW_NUMBER`: the X11 Window associated
      with the window, if you want to wrap an existing window.

    The window is implicitly shown if the "hidden" property is not set.

    Windows with the "tooltip" and "menu" properties are popup windows and have
    the behaviors and guidelines outlined in SDL_CreatePopupWindow().

    If this window is being created to be used with an SDL_Renderer, you should
    not add a graphics API specific property
    (`SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN`, etc), as SDL will handle that
    internally when it chooses a renderer. However, SDL might need to recreate
    your window at that point, which may cause the window to appear briefly,
    and then flicker as it is recreated. The correct approach to this is to
    create the window with the `SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN` property
    set to true, then create the renderer, then show the window with
    SDL_ShowWindow().

    Args:
        props: The properties to use.

    Returns:
        The window that was created or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateWindowWithProperties.
    """

    ret = _get_dylib_function[lib, "SDL_CreateWindowWithProperties", fn (props: PropertiesID) -> Ptr[Window, AnyOrigin[True]]]()(props)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_id(window: Ptr[Window, AnyOrigin[True]]) raises -> WindowID:
    """Get the numeric ID of a window.

    The numeric ID is what SDL_WindowEvent references, and is necessary to map
    these events to specific SDL_Window objects.

    Args:
        window: The window to query.

    Returns:
        The ID of the window on success or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowID.
    """

    return _get_dylib_function[lib, "SDL_GetWindowID", fn (window: Ptr[Window, AnyOrigin[True]]) -> WindowID]()(window)


fn get_window_from_id(id: WindowID) raises -> Ptr[Window, AnyOrigin[True]]:
    """Get a window from a stored ID.

    The numeric ID is what SDL_WindowEvent references, and is necessary to map
    these events to specific SDL_Window objects.

    Args:
        id: The ID of the window.

    Returns:
        The window associated with `id` or NULL if it doesn't exist; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowFromID.
    """

    return _get_dylib_function[lib, "SDL_GetWindowFromID", fn (id: WindowID) -> Ptr[Window, AnyOrigin[True]]]()(id)


fn get_window_parent(window: Ptr[Window, AnyOrigin[True]]) raises -> Ptr[Window, AnyOrigin[True]]:
    """Get parent of a window.

    Args:
        window: The window to query.

    Returns:
        The parent of the window on success or NULL if the window has no
        parent.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowParent.
    """

    return _get_dylib_function[lib, "SDL_GetWindowParent", fn (window: Ptr[Window, AnyOrigin[True]]) -> Ptr[Window, AnyOrigin[True]]]()(window)


fn get_window_properties(window: Ptr[Window, AnyOrigin[True]]) raises -> PropertiesID:
    """Get the properties associated with a window.

    The following read-only properties are provided by SDL:

    - `SDL_PROP_WINDOW_SHAPE_POINTER`: the surface associated with a shaped
      window
    - `SDL_PROP_WINDOW_HDR_ENABLED_BOOLEAN`: true if the window has HDR
      headroom above the SDR white point. This property can change dynamically
      when SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.
    - `SDL_PROP_WINDOW_SDR_WHITE_LEVEL_FLOAT`: the value of SDR white in the
      SDL_COLORSPACE_SRGB_LINEAR colorspace. On Windows this corresponds to the
      SDR white level in scRGB colorspace, and on Apple platforms this is
      always 1.0 for EDR content. This property can change dynamically when
      SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.
    - `SDL_PROP_WINDOW_HDR_HEADROOM_FLOAT`: the additional high dynamic range
      that can be displayed, in terms of the SDR white point. When HDR is not
      enabled, this will be 1.0. This property can change dynamically when
      SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.

    On Android:

    - `SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER`: the ANativeWindow associated
      with the window
    - `SDL_PROP_WINDOW_ANDROID_SURFACE_POINTER`: the EGLSurface associated with
      the window

    On iOS:

    - `SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER`: the `(__unsafe_unretained)`
      UIWindow associated with the window
    - `SDL_PROP_WINDOW_UIKIT_METAL_VIEW_TAG_NUMBER`: the NSInteger tag
      associated with metal views on the window
    - `SDL_PROP_WINDOW_UIKIT_OPENGL_FRAMEBUFFER_NUMBER`: the OpenGL view's
      framebuffer object. It must be bound when rendering to the screen using
      OpenGL.
    - `SDL_PROP_WINDOW_UIKIT_OPENGL_RENDERBUFFER_NUMBER`: the OpenGL view's
      renderbuffer object. It must be bound when SDL_GL_SwapWindow is called.
    - `SDL_PROP_WINDOW_UIKIT_OPENGL_RESOLVE_FRAMEBUFFER_NUMBER`: the OpenGL
      view's resolve framebuffer, when MSAA is used.

    On KMS/DRM:

    - `SDL_PROP_WINDOW_KMSDRM_DEVICE_INDEX_NUMBER`: the device index associated
      with the window (e.g. the X in /dev/dri/cardX)
    - `SDL_PROP_WINDOW_KMSDRM_DRM_FD_NUMBER`: the DRM FD associated with the
      window
    - `SDL_PROP_WINDOW_KMSDRM_GBM_DEVICE_POINTER`: the GBM device associated
      with the window

    On macOS:

    - `SDL_PROP_WINDOW_COCOA_WINDOW_POINTER`: the `(__unsafe_unretained)`
      NSWindow associated with the window
    - `SDL_PROP_WINDOW_COCOA_METAL_VIEW_TAG_NUMBER`: the NSInteger tag
      associated with metal views on the window

    On OpenVR:

    - `SDL_PROP_WINDOW_OPENVR_OVERLAY_ID`: the OpenVR Overlay Handle ID for the
      associated overlay window.

    On Vivante:

    - `SDL_PROP_WINDOW_VIVANTE_DISPLAY_POINTER`: the EGLNativeDisplayType
      associated with the window
    - `SDL_PROP_WINDOW_VIVANTE_WINDOW_POINTER`: the EGLNativeWindowType
      associated with the window
    - `SDL_PROP_WINDOW_VIVANTE_SURFACE_POINTER`: the EGLSurface associated with
      the window

    On Windows:

    - `SDL_PROP_WINDOW_WIN32_HWND_POINTER`: the HWND associated with the window
    - `SDL_PROP_WINDOW_WIN32_HDC_POINTER`: the HDC associated with the window
    - `SDL_PROP_WINDOW_WIN32_INSTANCE_POINTER`: the HINSTANCE associated with
      the window

    On Wayland:

    Note: The `xdg_*` window objects do not internally persist across window
    show/hide calls. They will be null if the window is hidden and must be
    queried each time it is shown.

    - `SDL_PROP_WINDOW_WAYLAND_DISPLAY_POINTER`: the wl_display associated with
      the window
    - `SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER`: the wl_surface associated with
      the window
    - `SDL_PROP_WINDOW_WAYLAND_VIEWPORT_POINTER`: the wp_viewport associated
      with the window
    - `SDL_PROP_WINDOW_WAYLAND_EGL_WINDOW_POINTER`: the wl_egl_window
      associated with the window
    - `SDL_PROP_WINDOW_WAYLAND_XDG_SURFACE_POINTER`: the xdg_surface associated
      with the window
    - `SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_POINTER`: the xdg_toplevel role
      associated with the window
    - 'SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_EXPORT_HANDLE_STRING': the export
      handle associated with the window
    - `SDL_PROP_WINDOW_WAYLAND_XDG_POPUP_POINTER`: the xdg_popup role
      associated with the window
    - `SDL_PROP_WINDOW_WAYLAND_XDG_POSITIONER_POINTER`: the xdg_positioner
      associated with the window, in popup mode

    On X11:

    - `SDL_PROP_WINDOW_X11_DISPLAY_POINTER`: the X11 Display associated with
      the window
    - `SDL_PROP_WINDOW_X11_SCREEN_NUMBER`: the screen number associated with
      the window
    - `SDL_PROP_WINDOW_X11_WINDOW_NUMBER`: the X11 Window associated with the
      window

    Args:
        window: The window to query.

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowProperties.
    """

    return _get_dylib_function[lib, "SDL_GetWindowProperties", fn (window: Ptr[Window, AnyOrigin[True]]) -> PropertiesID]()(window)


fn get_window_flags(window: Ptr[Window, AnyOrigin[True]]) raises -> WindowFlags:
    """Get the window flags.

    Args:
        window: The window to query.

    Returns:
        A mask of the SDL_WindowFlags associated with `window`.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowFlags.
    """

    return _get_dylib_function[lib, "SDL_GetWindowFlags", fn (window: Ptr[Window, AnyOrigin[True]]) -> WindowFlags]()(window)


fn set_window_title(window: Ptr[Window, AnyOrigin[True]], var title: String) raises:
    """Set the title of a window.

    This string is expected to be in UTF-8 encoding.

    Args:
        window: The window to change.
        title: The desired window title in UTF-8 format.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowTitle.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowTitle", fn (window: Ptr[Window, AnyOrigin[True]], title: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(window, title.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_title(window: Ptr[Window, AnyOrigin[True]]) raises -> Ptr[c_char, AnyOrigin[False]]:
    """Get the title of a window.

    Args:
        window: The window to query.

    Returns:
        The title of the window in UTF-8 format or "" if there is no
        title.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowTitle.
    """

    return _get_dylib_function[lib, "SDL_GetWindowTitle", fn (window: Ptr[Window, AnyOrigin[True]]) -> Ptr[c_char, AnyOrigin[False]]]()(window)


fn set_window_icon(window: Ptr[Window, AnyOrigin[True]], icon: Ptr[Surface, AnyOrigin[True]]) raises:
    """Set the icon for a window.

    If this function is passed a surface with alternate representations, the
    surface will be interpreted as the content to be used for 100% display
    scale, and the alternate representations will be used for high DPI
    situations. For example, if the original surface is 32x32, then on a 2x
    macOS display or 200% display scale on Windows, a 64x64 version of the
    image will be used, if available. If a matching version of the image isn't
    available, the closest larger size image will be downscaled to the
    appropriate size and be used instead, if available. Otherwise, the closest
    smaller image will be upscaled and be used instead.

    Args:
        window: The window to change.
        icon: An SDL_Surface structure containing the icon for the window.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowIcon.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowIcon", fn (window: Ptr[Window, AnyOrigin[True]], icon: Ptr[Surface, AnyOrigin[True]]) -> Bool]()(window, icon)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_position(window: Ptr[Window, AnyOrigin[True]], x: c_int, y: c_int) raises:
    """Request that the window's position be set.

    If the window is in an exclusive fullscreen or maximized state, this
    request has no effect.

    This can be used to reposition fullscreen-desktop windows onto a different
    display, however, as exclusive fullscreen windows are locked to a specific
    display, they can only be repositioned programmatically via
    SDL_SetWindowFullscreenMode().

    On some windowing systems this request is asynchronous and the new
    coordinates may not have have been applied immediately upon the return of
    this function. If an immediate change is required, call SDL_SyncWindow() to
    block until the changes have taken effect.

    When the window position changes, an SDL_EVENT_WINDOW_MOVED event will be
    emitted with the window's new coordinates. Note that the new coordinates
    may not match the exact coordinates requested, as some windowing systems
    can restrict the position of the window in certain scenarios (e.g.
    constraining the position so the window is always within desktop bounds).
    Additionally, as this is just a request, it can be denied by the windowing
    system.

    Args:
        window: The window to reposition.
        x: The x coordinate of the window, or `SDL_WINDOWPOS_CENTERED` or
           `SDL_WINDOWPOS_UNDEFINED`.
        y: The y coordinate of the window, or `SDL_WINDOWPOS_CENTERED` or
           `SDL_WINDOWPOS_UNDEFINED`.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowPosition.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowPosition", fn (window: Ptr[Window, AnyOrigin[True]], x: c_int, y: c_int) -> Bool]()(window, x, y)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_position(window: Ptr[Window, AnyOrigin[True]], x: Ptr[c_int, AnyOrigin[True]], y: Ptr[c_int, AnyOrigin[True]]) raises:
    """Get the position of a window.

    This is the current position of the window as last reported by the
    windowing system.

    If you do not need the value for one of the positions a NULL may be passed
    in the `x` or `y` parameter.

    Args:
        window: The window to query.
        x: A pointer filled in with the x position of the window, may be
           NULL.
        y: A pointer filled in with the y position of the window, may be
           NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowPosition.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowPosition", fn (window: Ptr[Window, AnyOrigin[True]], x: Ptr[c_int, AnyOrigin[True]], y: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(window, x, y)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_size(window: Ptr[Window, AnyOrigin[True]], w: c_int, h: c_int) raises:
    """Request that the size of a window's client area be set.

    If the window is in a fullscreen or maximized state, this request has no
    effect.

    To change the exclusive fullscreen mode of a window, use
    SDL_SetWindowFullscreenMode().

    On some windowing systems, this request is asynchronous and the new window
    size may not have have been applied immediately upon the return of this
    function. If an immediate change is required, call SDL_SyncWindow() to
    block until the changes have taken effect.

    When the window size changes, an SDL_EVENT_WINDOW_RESIZED event will be
    emitted with the new window dimensions. Note that the new dimensions may
    not match the exact size requested, as some windowing systems can restrict
    the window size in certain scenarios (e.g. constraining the size of the
    content area to remain within the usable desktop bounds). Additionally, as
    this is just a request, it can be denied by the windowing system.

    Args:
        window: The window to change.
        w: The width of the window, must be > 0.
        h: The height of the window, must be > 0.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowSize.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowSize", fn (window: Ptr[Window, AnyOrigin[True]], w: c_int, h: c_int) -> Bool]()(window, w, h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_size(window: Ptr[Window, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) raises:
    """Get the size of a window's client area.

    The window pixel size may differ from its window coordinate size if the
    window is on a high pixel density display. Use SDL_GetWindowSizeInPixels()
    or SDL_GetRenderOutputSize() to get the real client area size in pixels.

    Args:
        window: The window to query the width and height from.
        w: A pointer filled in with the width of the window, may be NULL.
        h: A pointer filled in with the height of the window, may be NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowSize.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowSize", fn (window: Ptr[Window, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(window, w, h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_safe_area(window: Ptr[Window, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]]) raises:
    """Get the safe area for this window.

    Some devices have portions of the screen which are partially obscured or
    not interactive, possibly due to on-screen controls, curved edges, camera
    notches, TV overscan, etc. This function provides the area of the window
    which is safe to have interactable content. You should continue rendering
    into the rest of the window, but it should not contain visually important
    or interactible content.

    Args:
        window: The window to query.
        rect: A pointer filled in with the client area that is safe for
              interactive content.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowSafeArea.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowSafeArea", fn (window: Ptr[Window, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]]) -> Bool]()(window, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_aspect_ratio(window: Ptr[Window, AnyOrigin[True]], min_aspect: c_float, max_aspect: c_float) raises:
    """Request that the aspect ratio of a window's client area be set.

    The aspect ratio is the ratio of width divided by height, e.g. 2560x1600
    would be 1.6. Larger aspect ratios are wider and smaller aspect ratios are
    narrower.

    If, at the time of this request, the window in a fixed-size state, such as
    maximized or fullscreen, the request will be deferred until the window
    exits this state and becomes resizable again.

    On some windowing systems, this request is asynchronous and the new window
    aspect ratio may not have have been applied immediately upon the return of
    this function. If an immediate change is required, call SDL_SyncWindow() to
    block until the changes have taken effect.

    When the window size changes, an SDL_EVENT_WINDOW_RESIZED event will be
    emitted with the new window dimensions. Note that the new dimensions may
    not match the exact aspect ratio requested, as some windowing systems can
    restrict the window size in certain scenarios (e.g. constraining the size
    of the content area to remain within the usable desktop bounds).
    Additionally, as this is just a request, it can be denied by the windowing
    system.

    Args:
        window: The window to change.
        min_aspect: The minimum aspect ratio of the window, or 0.0f for no
                    limit.
        max_aspect: The maximum aspect ratio of the window, or 0.0f for no
                    limit.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowAspectRatio.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowAspectRatio", fn (window: Ptr[Window, AnyOrigin[True]], min_aspect: c_float, max_aspect: c_float) -> Bool]()(window, min_aspect, max_aspect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_aspect_ratio(window: Ptr[Window, AnyOrigin[True]], min_aspect: Ptr[c_float, AnyOrigin[True]], max_aspect: Ptr[c_float, AnyOrigin[True]]) raises:
    """Get the size of a window's client area.

    Args:
        window: The window to query the width and height from.
        min_aspect: A pointer filled in with the minimum aspect ratio of the
                    window, may be NULL.
        max_aspect: A pointer filled in with the maximum aspect ratio of the
                    window, may be NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowAspectRatio.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowAspectRatio", fn (window: Ptr[Window, AnyOrigin[True]], min_aspect: Ptr[c_float, AnyOrigin[True]], max_aspect: Ptr[c_float, AnyOrigin[True]]) -> Bool]()(window, min_aspect, max_aspect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_borders_size(window: Ptr[Window, AnyOrigin[True]], top: Ptr[c_int, AnyOrigin[True]], left: Ptr[c_int, AnyOrigin[True]], bottom: Ptr[c_int, AnyOrigin[True]], right: Ptr[c_int, AnyOrigin[True]]) raises:
    """Get the size of a window's borders (decorations) around the client area.

    Note: If this function fails (returns false), the size values will be
    initialized to 0, 0, 0, 0 (if a non-NULL pointer is provided), as if the
    window in question was borderless.

    Note: This function may fail on systems where the window has not yet been
    decorated by the display server (for example, immediately after calling
    SDL_CreateWindow). It is recommended that you wait at least until the
    window has been presented and composited, so that the window system has a
    chance to decorate the window and provide the border dimensions to SDL.

    This function also returns false if getting the information is not
    supported.

    Args:
        window: The window to query the size values of the border
                (decorations) from.
        top: Pointer to variable for storing the size of the top border; NULL
             is permitted.
        left: Pointer to variable for storing the size of the left border;
              NULL is permitted.
        bottom: Pointer to variable for storing the size of the bottom
                border; NULL is permitted.
        right: Pointer to variable for storing the size of the right border;
               NULL is permitted.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowBordersSize.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowBordersSize", fn (window: Ptr[Window, AnyOrigin[True]], top: Ptr[c_int, AnyOrigin[True]], left: Ptr[c_int, AnyOrigin[True]], bottom: Ptr[c_int, AnyOrigin[True]], right: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(window, top, left, bottom, right)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_size_in_pixels(window: Ptr[Window, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) raises:
    """Get the size of a window's client area, in pixels.

    Args:
        window: The window from which the drawable size should be queried.
        w: A pointer to variable for storing the width in pixels, may be
           NULL.
        h: A pointer to variable for storing the height in pixels, may be
           NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowSizeInPixels.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowSizeInPixels", fn (window: Ptr[Window, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(window, w, h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_minimum_size(window: Ptr[Window, AnyOrigin[True]], min_w: c_int, min_h: c_int) raises:
    """Set the minimum size of a window's client area.

    Args:
        window: The window to change.
        min_w: The minimum width of the window, or 0 for no limit.
        min_h: The minimum height of the window, or 0 for no limit.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowMinimumSize.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowMinimumSize", fn (window: Ptr[Window, AnyOrigin[True]], min_w: c_int, min_h: c_int) -> Bool]()(window, min_w, min_h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_minimum_size(window: Ptr[Window, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) raises:
    """Get the minimum size of a window's client area.

    Args:
        window: The window to query.
        w: A pointer filled in with the minimum width of the window, may be
           NULL.
        h: A pointer filled in with the minimum height of the window, may be
           NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowMinimumSize.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowMinimumSize", fn (window: Ptr[Window, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(window, w, h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_maximum_size(window: Ptr[Window, AnyOrigin[True]], max_w: c_int, max_h: c_int) raises:
    """Set the maximum size of a window's client area.

    Args:
        window: The window to change.
        max_w: The maximum width of the window, or 0 for no limit.
        max_h: The maximum height of the window, or 0 for no limit.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowMaximumSize.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowMaximumSize", fn (window: Ptr[Window, AnyOrigin[True]], max_w: c_int, max_h: c_int) -> Bool]()(window, max_w, max_h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_maximum_size(window: Ptr[Window, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) raises:
    """Get the maximum size of a window's client area.

    Args:
        window: The window to query.
        w: A pointer filled in with the maximum width of the window, may be
           NULL.
        h: A pointer filled in with the maximum height of the window, may be
           NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowMaximumSize.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowMaximumSize", fn (window: Ptr[Window, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(window, w, h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_bordered(window: Ptr[Window, AnyOrigin[True]], bordered: Bool) raises:
    """Set the border state of a window.

    This will add or remove the window's `SDL_WINDOW_BORDERLESS` flag and add
    or remove the border from the actual window. This is a no-op if the
    window's border already matches the requested state.

    You can't change the border state of a fullscreen window.

    Args:
        window: The window of which to change the border state.
        bordered: False to remove border, true to add border.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowBordered.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowBordered", fn (window: Ptr[Window, AnyOrigin[True]], bordered: Bool) -> Bool]()(window, bordered)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_resizable(window: Ptr[Window, AnyOrigin[True]], resizable: Bool) raises:
    """Set the user-resizable state of a window.

    This will add or remove the window's `SDL_WINDOW_RESIZABLE` flag and
    allow/disallow user resizing of the window. This is a no-op if the window's
    resizable state already matches the requested state.

    You can't change the resizable state of a fullscreen window.

    Args:
        window: The window of which to change the resizable state.
        resizable: True to allow resizing, false to disallow.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowResizable.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowResizable", fn (window: Ptr[Window, AnyOrigin[True]], resizable: Bool) -> Bool]()(window, resizable)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_always_on_top(window: Ptr[Window, AnyOrigin[True]], on_top: Bool) raises:
    """Set the window to always be above the others.

    This will add or remove the window's `SDL_WINDOW_ALWAYS_ON_TOP` flag. This
    will bring the window to the front and keep the window above the rest.

    Args:
        window: The window of which to change the always on top state.
        on_top: True to set the window always on top, false to disable.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowAlwaysOnTop.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowAlwaysOnTop", fn (window: Ptr[Window, AnyOrigin[True]], on_top: Bool) -> Bool]()(window, on_top)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn show_window(window: Ptr[Window, AnyOrigin[True]]) raises:
    """Show a window.

    Args:
        window: The window to show.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ShowWindow.
    """

    ret = _get_dylib_function[lib, "SDL_ShowWindow", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn hide_window(window: Ptr[Window, AnyOrigin[True]]) raises:
    """Hide a window.

    Args:
        window: The window to hide.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HideWindow.
    """

    ret = _get_dylib_function[lib, "SDL_HideWindow", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn raise_window(window: Ptr[Window, AnyOrigin[True]]) raises:
    """Request that a window be raised above other windows and gain the input
    focus.

    The result of this request is subject to desktop window manager policy,
    particularly if raising the requested window would result in stealing focus
    from another application. If the window is successfully raised and gains
    input focus, an SDL_EVENT_WINDOW_FOCUS_GAINED event will be emitted, and
    the window will have the SDL_WINDOW_INPUT_FOCUS flag set.

    Args:
        window: The window to raise.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RaiseWindow.
    """

    ret = _get_dylib_function[lib, "SDL_RaiseWindow", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn maximize_window(window: Ptr[Window, AnyOrigin[True]]) raises:
    """Request that the window be made as large as possible.

    Non-resizable windows can't be maximized. The window must have the
    SDL_WINDOW_RESIZABLE flag set, or this will have no effect.

    On some windowing systems this request is asynchronous and the new window
    state may not have have been applied immediately upon the return of this
    function. If an immediate change is required, call SDL_SyncWindow() to
    block until the changes have taken effect.

    When the window state changes, an SDL_EVENT_WINDOW_MAXIMIZED event will be
    emitted. Note that, as this is just a request, the windowing system can
    deny the state change.

    When maximizing a window, whether the constraints set via
    SDL_SetWindowMaximumSize() are honored depends on the policy of the window
    manager. Win32 and macOS enforce the constraints when maximizing, while X11
    and Wayland window managers may vary.

    Args:
        window: The window to maximize.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_MaximizeWindow.
    """

    ret = _get_dylib_function[lib, "SDL_MaximizeWindow", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn minimize_window(window: Ptr[Window, AnyOrigin[True]]) raises:
    """Request that the window be minimized to an iconic representation.

    If the window is in a fullscreen state, this request has no direct effect.
    It may alter the state the window is returned to when leaving fullscreen.

    On some windowing systems this request is asynchronous and the new window
    state may not have been applied immediately upon the return of this
    function. If an immediate change is required, call SDL_SyncWindow() to
    block until the changes have taken effect.

    When the window state changes, an SDL_EVENT_WINDOW_MINIMIZED event will be
    emitted. Note that, as this is just a request, the windowing system can
    deny the state change.

    Args:
        window: The window to minimize.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_MinimizeWindow.
    """

    ret = _get_dylib_function[lib, "SDL_MinimizeWindow", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn restore_window(window: Ptr[Window, AnyOrigin[True]]) raises:
    """Request that the size and position of a minimized or maximized window be
    restored.

    If the window is in a fullscreen state, this request has no direct effect.
    It may alter the state the window is returned to when leaving fullscreen.

    On some windowing systems this request is asynchronous and the new window
    state may not have have been applied immediately upon the return of this
    function. If an immediate change is required, call SDL_SyncWindow() to
    block until the changes have taken effect.

    When the window state changes, an SDL_EVENT_WINDOW_RESTORED event will be
    emitted. Note that, as this is just a request, the windowing system can
    deny the state change.

    Args:
        window: The window to restore.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RestoreWindow.
    """

    ret = _get_dylib_function[lib, "SDL_RestoreWindow", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_fullscreen(window: Ptr[Window, AnyOrigin[True]], fullscreen: Bool) raises:
    """Request that the window's fullscreen state be changed.

    By default a window in fullscreen state uses borderless fullscreen desktop
    mode, but a specific exclusive display mode can be set using
    SDL_SetWindowFullscreenMode().

    On some windowing systems this request is asynchronous and the new
    fullscreen state may not have have been applied immediately upon the return
    of this function. If an immediate change is required, call SDL_SyncWindow()
    to block until the changes have taken effect.

    When the window state changes, an SDL_EVENT_WINDOW_ENTER_FULLSCREEN or
    SDL_EVENT_WINDOW_LEAVE_FULLSCREEN event will be emitted. Note that, as this
    is just a request, it can be denied by the windowing system.

    Args:
        window: The window to change.
        fullscreen: True for fullscreen mode, false for windowed mode.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowFullscreen.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowFullscreen", fn (window: Ptr[Window, AnyOrigin[True]], fullscreen: Bool) -> Bool]()(window, fullscreen)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn sync_window(window: Ptr[Window, AnyOrigin[True]]) raises:
    """Block until any pending window state is finalized.

    On asynchronous windowing systems, this acts as a synchronization barrier
    for pending window state. It will attempt to wait until any pending window
    state has been applied and is guaranteed to return within finite time. Note
    that for how long it can potentially block depends on the underlying window
    system, as window state changes may involve somewhat lengthy animations
    that must complete before the window is in its final requested state.

    On windowing systems where changes are immediate, this does nothing.

    Args:
        window: The window for which to wait for the pending state to be
                applied.

    Raises:
        Raises if the operation timed out before the
        window was in the requested state.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SyncWindow.
    """

    ret = _get_dylib_function[lib, "SDL_SyncWindow", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn window_has_surface(window: Ptr[Window, AnyOrigin[True]]) raises -> Bool:
    """Return whether the window has a surface associated with it.

    Args:
        window: The window to query.

    Returns:
        True if there is a surface associated with the window, or false
        otherwise.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WindowHasSurface.
    """

    return _get_dylib_function[lib, "SDL_WindowHasSurface", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)


fn get_window_surface(window: Ptr[Window, AnyOrigin[True]], out ret: Ptr[Surface, AnyOrigin[True]]) raises:
    """Get the SDL surface associated with the window.

    A new surface will be created with the optimal format for the window, if
    necessary. This surface will be freed when the window is destroyed. Do not
    free this surface.

    This surface will be invalidated if the window is resized. After resizing a
    window this function must be called again to return a valid surface.

    You may not combine this with 3D or the rendering API on this window.

    This function is affected by `SDL_HINT_FRAMEBUFFER_ACCELERATION`.

    Args:
        window: The window to query.

    Returns:
        The surface associated with the window, or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowSurface.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowSurface", fn (window: Ptr[Window, AnyOrigin[True]]) -> Ptr[Surface, AnyOrigin[True]]]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_surface_vsync(window: Ptr[Window, AnyOrigin[True]], vsync: c_int) raises:
    """Toggle VSync for the window surface.

    When a window surface is created, vsync defaults to
    SDL_WINDOW_SURFACE_VSYNC_DISABLED.

    The `vsync` parameter can be 1 to synchronize present with every vertical
    refresh, 2 to synchronize present with every second vertical refresh, etc.,
    SDL_WINDOW_SURFACE_VSYNC_ADAPTIVE for late swap tearing (adaptive vsync),
    or SDL_WINDOW_SURFACE_VSYNC_DISABLED to disable. Not every value is
    supported by every driver, so you should check the return value to see
    whether the requested setting is supported.

    Args:
        window: The window.
        vsync: The vertical refresh sync interval.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowSurfaceVSync.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowSurfaceVSync", fn (window: Ptr[Window, AnyOrigin[True]], vsync: c_int) -> Bool]()(window, vsync)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_surface_vsync(window: Ptr[Window, AnyOrigin[True]], vsync: Ptr[c_int, AnyOrigin[True]]) raises:
    """Get VSync for the window surface.

    Args:
        window: The window to query.
        vsync: An int filled with the current vertical refresh sync interval.
               See SDL_SetWindowSurfaceVSync() for the meaning of the value.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowSurfaceVSync.
    """

    ret = _get_dylib_function[lib, "SDL_GetWindowSurfaceVSync", fn (window: Ptr[Window, AnyOrigin[True]], vsync: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(window, vsync)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn update_window_surface(window: Ptr[Window, AnyOrigin[True]]) raises:
    """Copy the window surface to the screen.

    This is the function you use to reflect any changes to the surface on the
    screen.

    This function is equivalent to the SDL 1.2 API SDL_Flip().

    Args:
        window: The window to update.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UpdateWindowSurface.
    """

    ret = _get_dylib_function[lib, "SDL_UpdateWindowSurface", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn update_window_surface_rects(window: Ptr[Window, AnyOrigin[True]], rects: Ptr[Rect, AnyOrigin[False]], numrects: c_int) raises:
    """Copy areas of the window surface to the screen.

    This is the function you use to reflect changes to portions of the surface
    on the screen.

    This function is equivalent to the SDL 1.2 API SDL_UpdateRects().

    Note that this function will update _at least_ the rectangles specified,
    but this is only intended as an optimization; in practice, this might
    update more of the screen (or all of the screen!), depending on what method
    SDL uses to send pixels to the system.

    Args:
        window: The window to update.
        rects: An array of SDL_Rect structures representing areas of the
               surface to copy, in pixels.
        numrects: The number of rectangles.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UpdateWindowSurfaceRects.
    """

    ret = _get_dylib_function[lib, "SDL_UpdateWindowSurfaceRects", fn (window: Ptr[Window, AnyOrigin[True]], rects: Ptr[Rect, AnyOrigin[False]], numrects: c_int) -> Bool]()(window, rects, numrects)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn destroy_window_surface(window: Ptr[Window, AnyOrigin[True]]) raises:
    """Destroy the surface associated with the window.

    Args:
        window: The window to update.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyWindowSurface.
    """

    ret = _get_dylib_function[lib, "SDL_DestroyWindowSurface", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_keyboard_grab(window: Ptr[Window, AnyOrigin[True]], grabbed: Bool) raises:
    """Set a window's keyboard grab mode.

    Keyboard grab enables capture of system keyboard shortcuts like Alt+Tab or
    the Meta/Super key. Note that not all system keyboard shortcuts can be
    captured by applications (one example is Ctrl+Alt+Del on Windows).

    This is primarily intended for specialized applications such as VNC clients
    or VM frontends. Normal games should not use keyboard grab.

    When keyboard grab is enabled, SDL will continue to handle Alt+Tab when the
    window is full-screen to ensure the user is not trapped in your
    application. If you have a custom keyboard shortcut to exit fullscreen
    mode, you may suppress this behavior with
    `SDL_HINT_ALLOW_ALT_TAB_WHILE_GRABBED`.

    If the caller enables a grab while another window is currently grabbed, the
    other window loses its grab in favor of the caller's window.

    Args:
        window: The window for which the keyboard grab mode should be set.
        grabbed: This is true to grab keyboard, and false to release.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowKeyboardGrab.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowKeyboardGrab", fn (window: Ptr[Window, AnyOrigin[True]], grabbed: Bool) -> Bool]()(window, grabbed)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_mouse_grab(window: Ptr[Window, AnyOrigin[True]], grabbed: Bool) raises:
    """Set a window's mouse grab mode.

    Mouse grab confines the mouse cursor to the window.

    Args:
        window: The window for which the mouse grab mode should be set.
        grabbed: This is true to grab mouse, and false to release.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowMouseGrab.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowMouseGrab", fn (window: Ptr[Window, AnyOrigin[True]], grabbed: Bool) -> Bool]()(window, grabbed)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_keyboard_grab(window: Ptr[Window, AnyOrigin[True]]) raises -> Bool:
    """Get a window's keyboard grab mode.

    Args:
        window: The window to query.

    Returns:
        True if keyboard is grabbed, and false otherwise.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowKeyboardGrab.
    """

    return _get_dylib_function[lib, "SDL_GetWindowKeyboardGrab", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)


fn get_window_mouse_grab(window: Ptr[Window, AnyOrigin[True]]) raises -> Bool:
    """Get a window's mouse grab mode.

    Args:
        window: The window to query.

    Returns:
        True if mouse is grabbed, and false otherwise.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowMouseGrab.
    """

    return _get_dylib_function[lib, "SDL_GetWindowMouseGrab", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)


fn get_grabbed_window() raises -> Ptr[Window, AnyOrigin[True]]:
    """Get the window that currently has an input grab enabled.

    Returns:
        The window if input is grabbed or NULL otherwise.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGrabbedWindow.
    """

    return _get_dylib_function[lib, "SDL_GetGrabbedWindow", fn () -> Ptr[Window, AnyOrigin[True]]]()()


fn set_window_mouse_rect(window: Ptr[Window, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]]) raises:
    """Confines the cursor to the specified area of a window.

    Note that this does NOT grab the cursor, it only defines the area a cursor
    is restricted to when the window has mouse focus.

    Args:
        window: The window that will be associated with the barrier.
        rect: A rectangle area in window-relative coordinates. If NULL the
              barrier for the specified window will be destroyed.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowMouseRect.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowMouseRect", fn (window: Ptr[Window, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]]) -> Bool]()(window, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_mouse_rect(window: Ptr[Window, AnyOrigin[True]]) raises -> Ptr[Rect, AnyOrigin[False]]:
    """Get the mouse confinement rectangle of a window.

    Args:
        window: The window to query.

    Returns:
        A pointer to the mouse confinement rectangle of a window, or NULL
        if there isn't one.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowMouseRect.
    """

    return _get_dylib_function[lib, "SDL_GetWindowMouseRect", fn (window: Ptr[Window, AnyOrigin[True]]) -> Ptr[Rect, AnyOrigin[False]]]()(window)


fn set_window_opacity(window: Ptr[Window, AnyOrigin[True]], opacity: c_float) raises:
    """Set the opacity for a window.

    The parameter `opacity` will be clamped internally between 0.0f
    (transparent) and 1.0f (opaque).

    This function also returns false if setting the opacity isn't supported.

    Args:
        window: The window which will be made transparent or opaque.
        opacity: The opacity value (0.0f - transparent, 1.0f - opaque).

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowOpacity.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowOpacity", fn (window: Ptr[Window, AnyOrigin[True]], opacity: c_float) -> Bool]()(window, opacity)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_window_opacity(window: Ptr[Window, AnyOrigin[True]]) raises -> c_float:
    """Get the opacity of a window.

    If transparency isn't supported on this platform, opacity will be returned
    as 1.0f without error.

    Args:
        window: The window to get the current opacity value from.

    Returns:
        The opacity, (0.0f - transparent, 1.0f - opaque), or -1.0f on
        failure; call SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowOpacity.
    """

    return _get_dylib_function[lib, "SDL_GetWindowOpacity", fn (window: Ptr[Window, AnyOrigin[True]]) -> c_float]()(window)


fn set_window_parent(window: Ptr[Window, AnyOrigin[True]], parent: Ptr[Window, AnyOrigin[True]]) raises:
    """Set the window as a child of a parent window.

    If the window is already the child of an existing window, it will be
    reparented to the new owner. Setting the parent window to NULL unparents
    the window and removes child window status.

    If a parent window is hidden or destroyed, the operation will be
    recursively applied to child windows. Child windows hidden with the parent
    that did not have their hidden status explicitly set will be restored when
    the parent is shown.

    Attempting to set the parent of a window that is currently in the modal
    state will fail. Use SDL_SetWindowModal() to cancel the modal status before
    attempting to change the parent.

    Popup windows cannot change parents and attempts to do so will fail.

    Setting a parent window that is currently the sibling or descendent of the
    child window results in undefined behavior.

    Args:
        window: The window that should become the child of a parent.
        parent: The new parent window for the child window.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowParent.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowParent", fn (window: Ptr[Window, AnyOrigin[True]], parent: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window, parent)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_modal(window: Ptr[Window, AnyOrigin[True]], modal: Bool) raises:
    """Toggle the state of the window as modal.

    To enable modal status on a window, the window must currently be the child
    window of a parent, or toggling modal status on will fail.

    Args:
        window: The window on which to set the modal state.
        modal: True to toggle modal status on, false to toggle it off.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowModal.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowModal", fn (window: Ptr[Window, AnyOrigin[True]], modal: Bool) -> Bool]()(window, modal)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_focusable(window: Ptr[Window, AnyOrigin[True]], focusable: Bool) raises:
    """Set whether the window may have input focus.

    Args:
        window: The window to set focusable state.
        focusable: True to allow input focus, false to not allow input focus.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowFocusable.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowFocusable", fn (window: Ptr[Window, AnyOrigin[True]], focusable: Bool) -> Bool]()(window, focusable)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn show_window_system_menu(window: Ptr[Window, AnyOrigin[True]], x: c_int, y: c_int) raises:
    """Display the system-level window menu.

    This default window menu is provided by the system and on some platforms
    provides functionality for setting or changing privileged state on the
    window, such as moving it between workspaces or displays, or toggling the
    always-on-top property.

    On platforms or desktops where this is unsupported, this function does
    nothing.

    Args:
        window: The window for which the menu will be displayed.
        x: The x coordinate of the menu, relative to the origin (top-left) of
           the client area.
        y: The y coordinate of the menu, relative to the origin (top-left) of
           the client area.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ShowWindowSystemMenu.
    """

    ret = _get_dylib_function[lib, "SDL_ShowWindowSystemMenu", fn (window: Ptr[Window, AnyOrigin[True]], x: c_int, y: c_int) -> Bool]()(window, x, y)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


@register_passable("trivial")
struct HitTestResult(Indexer, Intable):
    """Possible return values from the SDL_HitTest callback.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HitTestResult.
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

    comptime HITTEST_NORMAL = Self(0)
    """Region is normal. No special properties."""
    comptime HITTEST_DRAGGABLE = Self(1)
    """Region can drag entire window."""
    comptime HITTEST_RESIZE_TOPLEFT = Self(2)
    """Region is the resizable top-left corner border."""
    comptime HITTEST_RESIZE_TOP = Self(3)
    """Region is the resizable top border."""
    comptime HITTEST_RESIZE_TOPRIGHT = Self(4)
    """Region is the resizable top-right corner border."""
    comptime HITTEST_RESIZE_RIGHT = Self(5)
    """Region is the resizable right border."""
    comptime HITTEST_RESIZE_BOTTOMRIGHT = Self(6)
    """Region is the resizable bottom-right corner border."""
    comptime HITTEST_RESIZE_BOTTOM = Self(7)
    """Region is the resizable bottom border."""
    comptime HITTEST_RESIZE_BOTTOMLEFT = Self(8)
    """Region is the resizable bottom-left corner border."""
    comptime HITTEST_RESIZE_LEFT = Self(9)
    """Region is the resizable left border."""


comptime HitTest = fn (win: Ptr[Window, AnyOrigin[True]], area: Ptr[Point, AnyOrigin[False]], data: Ptr[NoneType, AnyOrigin[True]]) -> HitTestResult
"""Callback used for hit-testing.
    
    Args:
        win: The SDL_Window where hit-testing was set on.
        area: An SDL_Point which should be hit-tested.
        data: What was passed as `callback_data` to SDL_SetWindowHitTest().
    
    Returns:
        An SDL_HitTestResult value.

Docs: https://wiki.libsdl.org/SDL3/SDL_HitTest.
"""


fn set_window_hit_test(window: Ptr[Window, AnyOrigin[True]], callback: HitTest, callback_data: Ptr[NoneType, AnyOrigin[True]]) raises:
    """Provide a callback that decides if a window region has special properties.

    Normally windows are dragged and resized by decorations provided by the
    system window manager (a title bar, borders, etc), but for some apps, it
    makes sense to drag them from somewhere else inside the window itself; for
    example, one might have a borderless window that wants to be draggable from
    any part, or simulate its own title bar, etc.

    This function lets the app provide a callback that designates pieces of a
    given window as special. This callback is run during event processing if we
    need to tell the OS to treat a region of the window specially; the use of
    this callback is known as "hit testing."

    Mouse input may not be delivered to your application if it is within a
    special area; the OS will often apply that input to moving the window or
    resizing the window and not deliver it to the application.

    Specifying NULL for a callback disables hit-testing. Hit-testing is
    disabled by default.

    Platforms that don't support this functionality will return false
    unconditionally, even if you're attempting to disable hit-testing.

    Your callback may fire at any time, and its firing does not indicate any
    specific behavior (for example, on Windows, this certainly might fire when
    the OS is deciding whether to drag your window, but it fires for lots of
    other reasons, too, some unrelated to anything you probably care about _and
    when the mouse isn't actually at the location it is testing_). Since this
    can fire at any time, you should try to keep your callback efficient,
    devoid of allocations, etc.

    Args:
        window: The window to set hit-testing on.
        callback: The function to call when doing a hit-test.
        callback_data: An app-defined void pointer passed to **callback**.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowHitTest.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowHitTest", fn (window: Ptr[Window, AnyOrigin[True]], callback: HitTest, callback_data: Ptr[NoneType, AnyOrigin[True]]) -> Bool]()(window, callback, callback_data)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_window_shape(window: Ptr[Window, AnyOrigin[True]], shape: Ptr[Surface, AnyOrigin[True]]) raises:
    """Set the shape of a transparent window.

    This sets the alpha channel of a transparent window and any fully
    transparent areas are also transparent to mouse clicks. If you are using
    something besides the SDL render API, then you are responsible for drawing
    the alpha channel of the window to match the shape alpha channel to get
    consistent cross-platform results.

    The shape is copied inside this function, so you can free it afterwards. If
    your shape surface changes, you should call SDL_SetWindowShape() again to
    update the window. This is an expensive operation, so should be done
    sparingly.

    The window must have been created with the SDL_WINDOW_TRANSPARENT flag.

    Args:
        window: The window.
        shape: The surface representing the shape of the window, or NULL to
               remove any current shape.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetWindowShape.
    """

    ret = _get_dylib_function[lib, "SDL_SetWindowShape", fn (window: Ptr[Window, AnyOrigin[True]], shape: Ptr[Surface, AnyOrigin[True]]) -> Bool]()(window, shape)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn flash_window(window: Ptr[Window, AnyOrigin[True]], operation: FlashOperation) raises:
    """Request a window to demand attention from the user.

    Args:
        window: The window to be flashed.
        operation: The operation to perform.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FlashWindow.
    """

    ret = _get_dylib_function[lib, "SDL_FlashWindow", fn (window: Ptr[Window, AnyOrigin[True]], operation: FlashOperation) -> Bool]()(window, operation)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn destroy_window(window: Ptr[Window, AnyOrigin[True]]) raises -> None:
    """Destroy a window.

    Any child windows owned by the window will be recursively destroyed as
    well.

    Note that on some platforms, the visible window may not actually be removed
    from the screen until the SDL event loop is pumped again, even though the
    SDL_Window is no longer valid after this call.

    Args:
        window: The window to destroy.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyWindow.
    """

    return _get_dylib_function[lib, "SDL_DestroyWindow", fn (window: Ptr[Window, AnyOrigin[True]]) -> None]()(window)


fn screen_saver_enabled() raises -> Bool:
    """Check whether the screensaver is currently enabled.

    The screensaver is disabled by default.

    The default can also be changed using `SDL_HINT_VIDEO_ALLOW_SCREENSAVER`.

    Returns:
        True if the screensaver is enabled, false if it is disabled.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ScreenSaverEnabled.
    """

    return _get_dylib_function[lib, "SDL_ScreenSaverEnabled", fn () -> Bool]()()


fn enable_screen_saver() raises:
    """Allow the screen to be blanked by a screen saver.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EnableScreenSaver.
    """

    ret = _get_dylib_function[lib, "SDL_EnableScreenSaver", fn () -> Bool]()()
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn disable_screen_saver() raises:
    """Prevent the screen from being blanked by a screen saver.

    If you disable the screensaver, it is automatically re-enabled when SDL
    quits.

    The screensaver is disabled by default, but this may by changed by
    SDL_HINT_VIDEO_ALLOW_SCREENSAVER.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DisableScreenSaver.
    """

    ret = _get_dylib_function[lib, "SDL_DisableScreenSaver", fn () -> Bool]()()
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn gl_load_library(var path: String) raises:
    """Dynamically load an OpenGL library.

    This should be done after initializing the video driver, but before
    creating any OpenGL windows. If no OpenGL library is loaded, the default
    library will be loaded upon creation of the first OpenGL window.

    If you do this, you need to retrieve all of the GL functions used in your
    program from the dynamic library using SDL_GL_GetProcAddress().

    Args:
        path: The platform dependent OpenGL library name, or NULL to open the
              default OpenGL library.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_LoadLibrary.
    """

    ret = _get_dylib_function[lib, "SDL_GL_LoadLibrary", fn (path: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(path.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn gl_get_proc_address(var proc: String) raises -> fn () -> None:
    """Get an OpenGL function by name.

    If the GL library is loaded at runtime with SDL_GL_LoadLibrary(), then all
    GL functions must be retrieved this way. Usually this is used to retrieve
    function pointers to OpenGL extensions.

    There are some quirks to looking up OpenGL functions that require some
    extra care from the application. If you code carefully, you can handle
    these quirks without any platform-specific code, though:

    - On Windows, function pointers are specific to the current GL context;
      this means you need to have created a GL context and made it current
      before calling SDL_GL_GetProcAddress(). If you recreate your context or
      create a second context, you should assume that any existing function
      pointers aren't valid to use with it. This is (currently) a
      Windows-specific limitation, and in practice lots of drivers don't suffer
      this limitation, but it is still the way the wgl API is documented to
      work and you should expect crashes if you don't respect it. Store a copy
      of the function pointers that comes and goes with context lifespan.
    - On X11, function pointers returned by this function are valid for any
      context, and can even be looked up before a context is created at all.
      This means that, for at least some common OpenGL implementations, if you
      look up a function that doesn't exist, you'll get a non-NULL result that
      is _NOT_ safe to call. You must always make sure the function is actually
      available for a given GL context before calling it, by checking for the
      existence of the appropriate extension with SDL_GL_ExtensionSupported(),
      or verifying that the version of OpenGL you're using offers the function
      as core functionality.
    - Some OpenGL drivers, on all platforms, *will* return NULL if a function
      isn't supported, but you can't count on this behavior. Check for
      extensions you use, and if you get a NULL anyway, act as if that
      extension wasn't available. This is probably a bug in the driver, but you
      can code defensively for this scenario anyhow.
    - Just because you're on Linux/Unix, don't assume you'll be using X11.
      Next-gen display servers are waiting to replace it, and may or may not
      make the same promises about function pointers.
    - OpenGL function pointers must be declared `APIENTRY` as in the example
      code. This will ensure the proper calling convention is followed on
      platforms where this matters (Win32) thereby avoiding stack corruption.

    Args:
        proc: The name of an OpenGL function.

    Returns:
        A pointer to the named OpenGL function. The returned pointer
        should be cast to the appropriate function signature.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_GetProcAddress.
    """

    return _get_dylib_function[lib, "SDL_GL_GetProcAddress", fn (proc: Ptr[c_char, AnyOrigin[False]]) -> fn () -> None]()(proc.unsafe_cstr_ptr())


fn egl_get_proc_address(var proc: String) raises -> fn () -> None:
    """Get an EGL library function by name.

    If an EGL library is loaded, this function allows applications to get entry
    points for EGL functions. This is useful to provide to an EGL API and
    extension loader.

    Args:
        proc: The name of an EGL function.

    Returns:
        A pointer to the named EGL function. The returned pointer should
        be cast to the appropriate function signature.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EGL_GetProcAddress.
    """

    return _get_dylib_function[lib, "SDL_EGL_GetProcAddress", fn (proc: Ptr[c_char, AnyOrigin[False]]) -> fn () -> None]()(proc.unsafe_cstr_ptr())


fn gl_unload_library() raises -> None:
    """Unload the OpenGL library previously loaded by SDL_GL_LoadLibrary().

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_UnloadLibrary.
    """

    return _get_dylib_function[lib, "SDL_GL_UnloadLibrary", fn () -> None]()()


fn gl_extension_supported(var extension: String) raises -> Bool:
    """Check if an OpenGL extension is supported for the current context.

    This function operates on the current GL context; you must have created a
    context and it must be current before calling this function. Do not assume
    that all contexts you create will have the same set of extensions
    available, or that recreating an existing context will offer the same
    extensions again.

    While it's probably not a massive overhead, this function is not an O(1)
    operation. Check the extensions you care about after creating the GL
    context and save that information somewhere instead of calling the function
    every time you need to know.

    Args:
        extension: The name of the extension to check.

    Returns:
        True if the extension is supported, false otherwise.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_ExtensionSupported.
    """

    return _get_dylib_function[lib, "SDL_GL_ExtensionSupported", fn (extension: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(extension.unsafe_cstr_ptr())


fn gl_reset_attributes() raises -> None:
    """Reset all previously set OpenGL context attributes to their default values.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_ResetAttributes.
    """

    return _get_dylib_function[lib, "SDL_GL_ResetAttributes", fn () -> None]()()


fn gl_set_attribute(attr: GLAttr, value: c_int) raises:
    """Set an OpenGL window attribute before window creation.

    This function sets the OpenGL attribute `attr` to `value`. The requested
    attributes should be set before creating an OpenGL window. You should use
    SDL_GL_GetAttribute() to check the values after creating the OpenGL
    context, since the values obtained can differ from the requested ones.

    Args:
        attr: An SDL_GLAttr enum value specifying the OpenGL attribute to
              set.
        value: The desired value for the attribute.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_SetAttribute.
    """

    ret = _get_dylib_function[lib, "SDL_GL_SetAttribute", fn (attr: GLAttr, value: c_int) -> Bool]()(attr, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn gl_get_attribute(attr: GLAttr, value: Ptr[c_int, AnyOrigin[True]]) raises:
    """Get the actual value for an attribute from the current context.

    Args:
        attr: An SDL_GLAttr enum value specifying the OpenGL attribute to
              get.
        value: A pointer filled in with the current value of `attr`.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_GetAttribute.
    """

    ret = _get_dylib_function[lib, "SDL_GL_GetAttribute", fn (attr: GLAttr, value: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(attr, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn gl_create_context(window: Ptr[Window, AnyOrigin[True]]) raises -> GLContext:
    """Create an OpenGL context for an OpenGL window, and make it current.

    Windows users new to OpenGL should note that, for historical reasons, GL
    functions added after OpenGL version 1.1 are not available by default.
    Those functions must be loaded at run-time, either with an OpenGL
    extension-handling library or with SDL_GL_GetProcAddress() and its related
    functions.

    SDL_GLContext is opaque to the application.

    Args:
        window: The window to associate with the context.

    Returns:
        The OpenGL context associated with `window` or NULL on failure;
        call SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_CreateContext.
    """

    return _get_dylib_function[lib, "SDL_GL_CreateContext", fn (window: Ptr[Window, AnyOrigin[True]]) -> GLContext]()(window)


fn gl_make_current(window: Ptr[Window, AnyOrigin[True]], context: GLContext) raises:
    """Set up an OpenGL context for rendering into an OpenGL window.

    The context must have been created with a compatible window.

    Args:
        window: The window to associate with the context.
        context: The OpenGL context to associate with the window.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_MakeCurrent.
    """

    ret = _get_dylib_function[lib, "SDL_GL_MakeCurrent", fn (window: Ptr[Window, AnyOrigin[True]], context: GLContext) -> Bool]()(window, context)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn gl_get_current_window(out ret: Ptr[Window, AnyOrigin[True]]) raises:
    """Get the currently active OpenGL window.

    Returns:
        The currently active OpenGL window on success or NULL on failure;
        call SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_GetCurrentWindow.
    """

    ret = _get_dylib_function[lib, "SDL_GL_GetCurrentWindow", fn () -> Ptr[Window, AnyOrigin[True]]]()()
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn gl_get_current_context() raises -> GLContext:
    """Get the currently active OpenGL context.

    Returns:
        The currently active OpenGL context or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_GetCurrentContext.
    """

    return _get_dylib_function[lib, "SDL_GL_GetCurrentContext", fn () -> GLContext]()()


fn egl_get_current_display() raises -> EGLDisplay:
    """Get the currently active EGL display.

    Returns:
        The currently active EGL display or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EGL_GetCurrentDisplay.
    """

    return _get_dylib_function[lib, "SDL_EGL_GetCurrentDisplay", fn () -> EGLDisplay]()()


fn egl_get_current_config() raises -> EGLConfig:
    """Get the currently active EGL config.

    Returns:
        The currently active EGL config or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EGL_GetCurrentConfig.
    """

    return _get_dylib_function[lib, "SDL_EGL_GetCurrentConfig", fn () -> EGLConfig]()()


fn egl_get_window_surface(window: Ptr[Window, AnyOrigin[True]]) raises -> EGLSurface:
    """Get the EGL surface associated with the window.

    Args:
        window: The window to query.

    Returns:
        The EGLSurface pointer associated with the window, or NULL on
        failure.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EGL_GetWindowSurface.
    """

    return _get_dylib_function[lib, "SDL_EGL_GetWindowSurface", fn (window: Ptr[Window, AnyOrigin[True]]) -> EGLSurface]()(window)


fn egl_set_attribute_callbacks(platform_attrib_callback: EGLAttribArrayCallback, surface_attrib_callback: EGLIntArrayCallback, context_attrib_callback: EGLIntArrayCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) raises -> None:
    """Sets the callbacks for defining custom EGLAttrib arrays for EGL
    initialization.

    Callbacks that aren't needed can be set to NULL.

    NOTE: These callback pointers will be reset after SDL_GL_ResetAttributes.

    Args:
        platform_attrib_callback: Callback for attributes to pass to
                                  eglGetPlatformDisplay. May be NULL.
        surface_attrib_callback: Callback for attributes to pass to
                                 eglCreateSurface. May be NULL.
        context_attrib_callback: Callback for attributes to pass to
                                 eglCreateContext. May be NULL.
        userdata: A pointer that is passed to the callbacks.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EGL_SetAttributeCallbacks.
    """

    return _get_dylib_function[lib, "SDL_EGL_SetAttributeCallbacks", fn (platform_attrib_callback: EGLAttribArrayCallback, surface_attrib_callback: EGLIntArrayCallback, context_attrib_callback: EGLIntArrayCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) -> None]()(platform_attrib_callback, surface_attrib_callback, context_attrib_callback, userdata)


fn gl_set_swap_interval(interval: c_int) raises:
    """Set the swap interval for the current OpenGL context.

    Some systems allow specifying -1 for the interval, to enable adaptive
    vsync. Adaptive vsync works the same as vsync, but if you've already missed
    the vertical retrace for a given frame, it swaps buffers immediately, which
    might be less jarring for the user during occasional framerate drops. If an
    application requests adaptive vsync and the system does not support it,
    this function will fail and return false. In such a case, you should
    probably retry the call with 1 for the interval.

    Adaptive vsync is implemented for some glX drivers with
    GLX_EXT_swap_control_tear, and for some Windows drivers with
    WGL_EXT_swap_control_tear.

    Read more on the Khronos wiki:
    https://www.khronos.org/opengl/wiki/Swap_Interval#Adaptive_Vsync

    Args:
        interval: 0 for immediate updates, 1 for updates synchronized with
                  the vertical retrace, -1 for adaptive vsync.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_SetSwapInterval.
    """

    ret = _get_dylib_function[lib, "SDL_GL_SetSwapInterval", fn (interval: c_int) -> Bool]()(interval)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn gl_get_swap_interval(interval: Ptr[c_int, AnyOrigin[True]]) raises:
    """Get the swap interval for the current OpenGL context.

    If the system can't determine the swap interval, or there isn't a valid
    current context, this function will set *interval to 0 as a safe default.

    Args:
        interval: Output interval value. 0 if there is no vertical retrace
                  synchronization, 1 if the buffer swap is synchronized with
                  the vertical retrace, and -1 if late swaps happen
                  immediately instead of waiting for the next retrace.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_GetSwapInterval.
    """

    ret = _get_dylib_function[lib, "SDL_GL_GetSwapInterval", fn (interval: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(interval)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn gl_swap_window(window: Ptr[Window, AnyOrigin[True]]) raises:
    """Update a window with OpenGL rendering.

    This is used with double-buffered OpenGL contexts, which are the default.

    On macOS, make sure you bind 0 to the draw framebuffer before swapping the
    window, otherwise nothing will happen. If you aren't using
    glBindFramebuffer(), this is the default and you won't have to do anything
    extra.

    Args:
        window: The window to change.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_SwapWindow.
    """

    ret = _get_dylib_function[lib, "SDL_GL_SwapWindow", fn (window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn gl_destroy_context(context: GLContext) raises:
    """Delete an OpenGL context.

    Args:
        context: The OpenGL context to be deleted.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GL_DestroyContext.
    """

    ret = _get_dylib_function[lib, "SDL_GL_DestroyContext", fn (context: GLContext) -> Bool]()(context)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))
