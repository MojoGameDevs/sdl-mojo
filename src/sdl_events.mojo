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

"""Events

Event queue management.

It's extremely common--often required--that an app deal with SDL's event
queue. Almost all useful information about interactions with the real world
flow through here: the user interacting with the computer and app, hardware
coming and going, the system changing in some way, etc.

An app generally takes a moment, perhaps at the start of a new frame, to
examine any events that have occured since the last time and process or
ignore them. This is generally done by calling SDL_PollEvent() in a loop
until it returns false (or, if using the main callbacks, events are
provided one at a time in calls to SDL_AppEvent() before the next call to
SDL_AppIterate(); in this scenario, the app does not call SDL_PollEvent()
at all).

There is other forms of control, too: SDL_PeepEvents() has more
functionality at the cost of more complexity, and SDL_WaitEvent() can block
the process until something interesting happens, which might be beneficial
for certain types of programs on low-power hardware. One may also call
SDL_AddEventWatch() to set a callback when new events arrive.

The app is free to generate their own events, too: SDL_PushEvent allows the
app to put events onto the queue for later retrieval; SDL_RegisterEvents
can guarantee that these events have a type that isn't in use by other
parts of the system.
"""


@register_passable("trivial")
struct EventType(Indexer, Intable):
    """The types of events that can be delivered.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EventType.
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

    comptime EVENT_FIRST = Self(0)
    """Unused (do not remove)."""

    # Application events
    comptime EVENT_QUIT = Self(0x100)
    """User-requested quit."""

    # These application events have special meaning on iOS and Android, see README-ios.md and README-android.md for details
    comptime EVENT_TERMINATING = Self(0x101)
    """The application is being terminated by the OS. This event must be handled in a callback set with SDL_AddEventWatch().
                                         Called on iOS in applicationWillTerminate()
                                         Called on Android in onDestroy()."""
    comptime EVENT_LOW_MEMORY = Self(0x102)
    """The application is low on memory, free memory if possible. This event must be handled in a callback set with SDL_AddEventWatch().
                                         Called on iOS in applicationDidReceiveMemoryWarning()
                                         Called on Android in onTrimMemory()."""
    comptime EVENT_WILL_ENTER_BACKGROUND = Self(0x103)
    """The application is about to enter the background. This event must be handled in a callback set with SDL_AddEventWatch().
                                         Called on iOS in applicationWillResignActive()
                                         Called on Android in onPause()."""
    comptime EVENT_DID_ENTER_BACKGROUND = Self(0x104)
    """The application did enter the background and may not get CPU for some time. This event must be handled in a callback set with SDL_AddEventWatch().
                                         Called on iOS in applicationDidEnterBackground()
                                         Called on Android in onPause()."""
    comptime EVENT_WILL_ENTER_FOREGROUND = Self(0x105)
    """The application is about to enter the foreground. This event must be handled in a callback set with SDL_AddEventWatch().
                                         Called on iOS in applicationWillEnterForeground()
                                         Called on Android in onResume()."""
    comptime EVENT_DID_ENTER_FOREGROUND = Self(0x106)
    """The application is now interactive. This event must be handled in a callback set with SDL_AddEventWatch().
                                         Called on iOS in applicationDidBecomeActive()
                                         Called on Android in onResume()."""

    comptime EVENT_LOCALE_CHANGED = Self(0x107)
    """The user's locale preferences have changed."""

    comptime EVENT_SYSTEM_THEME_CHANGED = Self(0x108)
    """The system theme changed."""

    # Display events
    # 0x150 was SDL_DISPLAYEVENT, reserve the number for sdl2-compat
    comptime EVENT_DISPLAY_ORIENTATION = Self(0x151)
    """Display orientation has changed to data1."""
    comptime EVENT_DISPLAY_ADDED = Self(0x152)
    """Display has been added to the system."""
    comptime EVENT_DISPLAY_REMOVED = Self(0x153)
    """Display has been removed from the system."""
    comptime EVENT_DISPLAY_MOVED = Self(0x154)
    """Display has changed position."""
    comptime EVENT_DISPLAY_DESKTOP_MODE_CHANGED = Self(0x155)
    """Display has changed desktop mode."""
    comptime EVENT_DISPLAY_CURRENT_MODE_CHANGED = Self(0x156)
    """Display has changed current mode."""
    comptime EVENT_DISPLAY_CONTENT_SCALE_CHANGED = Self(0x157)
    """Display has changed content scale."""
    comptime EVENT_DISPLAY_FIRST = Self.EVENT_DISPLAY_ORIENTATION
    comptime EVENT_DISPLAY_LAST = Self.EVENT_DISPLAY_CONTENT_SCALE_CHANGED

    # Window events
    # 0x200 was SDL_WINDOWEVENT, reserve the number for sdl2-compat
    # 0x201 was SDL_SYSWMEVENT, reserve the number for sdl2-compat
    comptime EVENT_WINDOW_SHOWN = Self(0x202)
    """Window has been shown."""
    comptime EVENT_WINDOW_HIDDEN = Self(0x203)
    """Window has been hidden."""
    comptime EVENT_WINDOW_EXPOSED = Self(0x204)
    """Window has been exposed and should be redrawn, and can be redrawn directly from event watchers for this event."""
    comptime EVENT_WINDOW_MOVED = Self(0x205)
    """Window has been moved to data1, data2."""
    comptime EVENT_WINDOW_RESIZED = Self(0x206)
    """Window has been resized to data1xdata2."""
    comptime EVENT_WINDOW_PIXEL_SIZE_CHANGED = Self(0x207)
    """The pixel size of the window has changed to data1xdata2."""
    comptime EVENT_WINDOW_METAL_VIEW_RESIZED = Self(0x208)
    """The pixel size of a Metal view associated with the window has changed."""
    comptime EVENT_WINDOW_MINIMIZED = Self(0x209)
    """Window has been minimized."""
    comptime EVENT_WINDOW_MAXIMIZED = Self(0x20A)
    """Window has been maximized."""
    comptime EVENT_WINDOW_RESTORED = Self(0x20B)
    """Window has been restored to normal size and position."""
    comptime EVENT_WINDOW_MOUSE_ENTER = Self(0x20C)
    """Window has gained mouse focus."""
    comptime EVENT_WINDOW_MOUSE_LEAVE = Self(0x20D)
    """Window has lost mouse focus."""
    comptime EVENT_WINDOW_FOCUS_GAINED = Self(0x20E)
    """Window has gained keyboard focus."""
    comptime EVENT_WINDOW_FOCUS_LOST = Self(0x20F)
    """Window has lost keyboard focus."""
    comptime EVENT_WINDOW_CLOSE_REQUESTED = Self(0x210)
    """The window manager requests that the window be closed."""
    comptime EVENT_WINDOW_HIT_TEST = Self(0x211)
    """Window had a hit test that wasn't SDL_HITTEST_NORMAL."""
    comptime EVENT_WINDOW_ICCPROF_CHANGED = Self(0x212)
    """The ICC profile of the window's display has changed."""
    comptime EVENT_WINDOW_DISPLAY_CHANGED = Self(0x213)
    """Window has been moved to display data1."""
    comptime EVENT_WINDOW_DISPLAY_SCALE_CHANGED = Self(0x214)
    """Window display scale has been changed."""
    comptime EVENT_WINDOW_SAFE_AREA_CHANGED = Self(0x215)
    """The window safe area has been changed."""
    comptime EVENT_WINDOW_OCCLUDED = Self(0x216)
    """The window has been occluded."""
    comptime EVENT_WINDOW_ENTER_FULLSCREEN = Self(0x217)
    """The window has entered fullscreen mode."""
    comptime EVENT_WINDOW_LEAVE_FULLSCREEN = Self(0x218)
    """The window has left fullscreen mode."""
    comptime EVENT_WINDOW_DESTROYED = Self(0x219)
    """The window with the associated ID is being or has been destroyed. If this message is being handled
                                                 in an event watcher, the window handle is still valid and can still be used to retrieve any properties
                                                 associated with the window. Otherwise, the handle has already been destroyed and all resources
                                                 associated with it are invalid."""
    comptime EVENT_WINDOW_HDR_STATE_CHANGED = Self(0x21A)
    """Window HDR properties have changed."""
    comptime EVENT_WINDOW_FIRST = Self.EVENT_WINDOW_SHOWN
    comptime EVENT_WINDOW_LAST = Self.EVENT_WINDOW_HDR_STATE_CHANGED

    # Keyboard events
    comptime EVENT_KEY_DOWN = Self(0x300)
    """Key pressed."""
    comptime EVENT_KEY_UP = Self(0x301)
    """Key released."""
    comptime EVENT_TEXT_EDITING = Self(0x302)
    """Keyboard text editing (composition)."""
    comptime EVENT_TEXT_INPUT = Self(0x303)
    """Keyboard text input."""
    comptime EVENT_KEYMAP_CHANGED = Self(0x304)
    """Keymap changed due to a system event such as an
                                                input language or keyboard layout change."""
    comptime EVENT_KEYBOARD_ADDED = Self(0x305)
    """A new keyboard has been inserted into the system."""
    comptime EVENT_KEYBOARD_REMOVED = Self(0x306)
    """A keyboard has been removed."""
    comptime EVENT_TEXT_EDITING_CANDIDATES = Self(0x307)
    """Keyboard text editing candidates."""

    # Mouse events
    comptime EVENT_MOUSE_MOTION = Self(0x400)
    """Mouse moved."""
    comptime EVENT_MOUSE_BUTTON_DOWN = Self(0x401)
    """Mouse button pressed."""
    comptime EVENT_MOUSE_BUTTON_UP = Self(0x402)
    """Mouse button released."""
    comptime EVENT_MOUSE_WHEEL = Self(0x403)
    """Mouse wheel motion."""
    comptime EVENT_MOUSE_ADDED = Self(0x404)
    """A new mouse has been inserted into the system."""
    comptime EVENT_MOUSE_REMOVED = Self(0x405)
    """A mouse has been removed."""

    # Joystick events
    comptime EVENT_JOYSTICK_AXIS_MOTION = Self(0x600)
    """Joystick axis motion."""
    comptime EVENT_JOYSTICK_BALL_MOTION = Self(0x601)
    """Joystick trackball motion."""
    comptime EVENT_JOYSTICK_HAT_MOTION = Self(0x602)
    """Joystick hat position change."""
    comptime EVENT_JOYSTICK_BUTTON_DOWN = Self(0x603)
    """Joystick button pressed."""
    comptime EVENT_JOYSTICK_BUTTON_UP = Self(0x604)
    """Joystick button released."""
    comptime EVENT_JOYSTICK_ADDED = Self(0x605)
    """A new joystick has been inserted into the system."""
    comptime EVENT_JOYSTICK_REMOVED = Self(0x606)
    """An opened joystick has been removed."""
    comptime EVENT_JOYSTICK_BATTERY_UPDATED = Self(0x607)
    """Joystick battery level change."""
    comptime EVENT_JOYSTICK_UPDATE_COMPLETE = Self(0x608)
    """Joystick update is complete."""

    # Gamepad events
    comptime EVENT_GAMEPAD_AXIS_MOTION = Self(0x650)
    """Gamepad axis motion."""
    comptime EVENT_GAMEPAD_BUTTON_DOWN = Self(0x651)
    """Gamepad button pressed."""
    comptime EVENT_GAMEPAD_BUTTON_UP = Self(0x652)
    """Gamepad button released."""
    comptime EVENT_GAMEPAD_ADDED = Self(0x653)
    """A new gamepad has been inserted into the system."""
    comptime EVENT_GAMEPAD_REMOVED = Self(0x654)
    """A gamepad has been removed."""
    comptime EVENT_GAMEPAD_REMAPPED = Self(0x655)
    """The gamepad mapping was updated."""
    comptime EVENT_GAMEPAD_TOUCHPAD_DOWN = Self(0x656)
    """Gamepad touchpad was touched."""
    comptime EVENT_GAMEPAD_TOUCHPAD_MOTION = Self(0x657)
    """Gamepad touchpad finger was moved."""
    comptime EVENT_GAMEPAD_TOUCHPAD_UP = Self(0x658)
    """Gamepad touchpad finger was lifted."""
    comptime EVENT_GAMEPAD_SENSOR_UPDATE = Self(0x659)
    """Gamepad sensor was updated."""
    comptime EVENT_GAMEPAD_UPDATE_COMPLETE = Self(0x65A)
    """Gamepad update is complete."""
    comptime EVENT_GAMEPAD_STEAM_HANDLE_UPDATED = Self(0x65B)
    """Gamepad Steam handle has changed."""

    # Touch events
    comptime EVENT_FINGER_DOWN = Self(0x700)
    comptime EVENT_FINGER_UP = Self(0x701)
    comptime EVENT_FINGER_MOTION = Self(0x702)
    comptime EVENT_FINGER_CANCELED = Self(0x703)

    # 0x800, 0x801, and 0x802 were the Gesture events from SDL2. Do not reuse these values! sdl2-compat needs them!

    # Clipboard events
    comptime EVENT_CLIPBOARD_UPDATE = Self(0x900)
    """The clipboard or primary selection changed."""

    # Drag and drop events
    comptime EVENT_DROP_FILE = Self(0x1000)
    """The system requests a file open."""
    comptime EVENT_DROP_TEXT = Self(0x1001)
    """Text/plain drag-and-drop event."""
    comptime EVENT_DROP_BEGIN = Self(0x1002)
    """A new set of drops is beginning (NULL filename)."""
    comptime EVENT_DROP_COMPLETE = Self(0x1003)
    """Current set of drops is now complete (NULL filename)."""
    comptime EVENT_DROP_POSITION = Self(0x1004)
    """Position while moving over the window."""

    # Audio hotplug events
    comptime EVENT_AUDIO_DEVICE_ADDED = Self(0x1100)
    """A new audio device is available."""
    comptime EVENT_AUDIO_DEVICE_REMOVED = Self(0x1101)
    """An audio device has been removed."""
    comptime EVENT_AUDIO_DEVICE_FORMAT_CHANGED = Self(0x1102)
    """An audio device's format has been changed by the system."""

    # Sensor events
    comptime EVENT_SENSOR_UPDATE = Self(0x1200)
    """A sensor was updated."""

    # Pressure-sensitive pen events
    comptime EVENT_PEN_PROXIMITY_IN = Self(0x1300)
    """Pressure-sensitive pen has become available."""
    comptime EVENT_PEN_PROXIMITY_OUT = Self(0x1301)
    """Pressure-sensitive pen has become unavailable."""
    comptime EVENT_PEN_DOWN = Self(0x1302)
    """Pressure-sensitive pen touched drawing surface."""
    comptime EVENT_PEN_UP = Self(0x1303)
    """Pressure-sensitive pen stopped touching drawing surface."""
    comptime EVENT_PEN_BUTTON_DOWN = Self(0x1304)
    """Pressure-sensitive pen button pressed."""
    comptime EVENT_PEN_BUTTON_UP = Self(0x1305)
    """Pressure-sensitive pen button released."""
    comptime EVENT_PEN_MOTION = Self(0x1306)
    """Pressure-sensitive pen is moving on the tablet."""
    comptime EVENT_PEN_AXIS = Self(0x1307)
    """Pressure-sensitive pen angle/pressure/etc changed."""

    # Camera hotplug events
    comptime EVENT_CAMERA_DEVICE_ADDED = Self(0x1400)
    """A new camera device is available."""
    comptime EVENT_CAMERA_DEVICE_REMOVED = Self(0x1401)
    """A camera device has been removed."""
    comptime EVENT_CAMERA_DEVICE_APPROVED = Self(0x1402)
    """A camera device has been approved for use by the user."""
    comptime EVENT_CAMERA_DEVICE_DENIED = Self(0x1403)
    """A camera device has been denied for use by the user."""

    # Render events
    comptime EVENT_RENDER_TARGETS_RESET = Self(0x2000)
    """The render targets have been reset and their contents need to be updated."""
    comptime EVENT_RENDER_DEVICE_RESET = Self(0x2001)
    """The device has been reset and all textures need to be recreated."""
    comptime EVENT_RENDER_DEVICE_LOST = Self(0x2002)
    """The device has been lost and can't be recovered."""

    # Reserved events for private platforms
    comptime EVENT_PRIVATE0 = Self(0x4000)
    comptime EVENT_PRIVATE1 = Self(0x4001)
    comptime EVENT_PRIVATE2 = Self(0x4002)
    comptime EVENT_PRIVATE3 = Self(0x4003)

    # Internal events
    comptime EVENT_POLL_SENTINEL = Self(0x7F00)
    """Signals the end of an event poll cycle."""

    # Events SDL_EVENT_USER through SDL_EVENT_LAST are for your use,
    #      *  and should be allocated with SDL_RegisterEvents()
    comptime EVENT_USER = Self(0x8000)

    # *  This last event is only for bounding internal arrays
    comptime EVENT_LAST = Self(0xFFFF)

    # This just makes sure the enum is the size of Uint32
    comptime EVENT_ENUM_PADDING = Self(0x7FFFFFFF)


@fieldwise_init
struct CommonEvent(ImplicitlyCopyable, Movable):
    """Fields shared by every event.

    Docs: https://wiki.libsdl.org/SDL3/CommonEvent.
    """

    var type: UInt32
    """Event type, shared with all events, Uint32 to cover user events which are not in the SDL_EventType enumeration."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""


@fieldwise_init
struct DisplayEvent(ImplicitlyCopyable, Movable):
    """Display state change event data (event.display.*).

    Docs: https://wiki.libsdl.org/SDL3/DisplayEvent.
    """

    var type: EventType
    """SDL_DISPLAYEVENT_*."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var display_id: DisplayID
    """The associated display."""
    var data1: Int32
    """Event dependent data."""
    var data2: Int32
    """Event dependent data."""


@fieldwise_init
struct WindowEvent(ImplicitlyCopyable, Movable):
    """Window state change event data (event.window.*).

    Docs: https://wiki.libsdl.org/SDL3/WindowEvent.
    """

    var type: EventType
    """SDL_EVENT_WINDOW_*."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The associated window."""
    var data1: Int32
    """Event dependent data."""
    var data2: Int32
    """Event dependent data."""


@fieldwise_init
struct KeyboardDeviceEvent(ImplicitlyCopyable, Movable):
    """Keyboard device event structure (event.kdevice.*).

    Docs: https://wiki.libsdl.org/SDL3/KeyboardDeviceEvent.
    """

    var type: EventType
    """SDL_EVENT_KEYBOARD_ADDED or SDL_EVENT_KEYBOARD_REMOVED."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: KeyboardID
    """The keyboard instance id."""


@fieldwise_init
struct KeyboardEvent(ImplicitlyCopyable, Movable):
    """Keyboard button event structure (event.key.*).

    The `key` is the base SDL_Keycode generated by pressing the `scancode`
    using the current keyboard layout, applying any options specified in
    SDL_HINT_KEYCODE_OPTIONS. You can get the SDL_Keycode corresponding to the
    event scancode and modifiers directly from the keyboard layout, bypassing
    SDL_HINT_KEYCODE_OPTIONS, by calling SDL_GetKeyFromScancode().

    Docs: https://wiki.libsdl.org/SDL3/KeyboardEvent.
    """

    var type: EventType
    """SDL_EVENT_KEY_DOWN or SDL_EVENT_KEY_UP."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with keyboard focus, if any."""
    var which: KeyboardID
    """The keyboard instance id, or 0 if unknown or virtual."""
    var scancode: Scancode
    """SDL physical key code."""
    var key: Keycode
    """SDL virtual key code."""
    var mod: Keymod
    """Current key modifiers."""
    var raw: UInt16
    """The platform dependent scancode for this event."""
    var down: Bool
    """True if the key is pressed."""
    var repeat: Bool
    """True if this is a key repeat."""


@fieldwise_init
struct TextEditingEvent(ImplicitlyCopyable, Movable):
    """Keyboard text editing event structure (event.edit.*).

    The start cursor is the position, in UTF-8 characters, where new typing
    will be inserted into the editing text. The length is the number of UTF-8
    characters that will be replaced by new typing.

    Docs: https://wiki.libsdl.org/SDL3/TextEditingEvent.
    """

    var type: EventType
    """SDL_EVENT_TEXT_EDITING."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with keyboard focus, if any."""
    var text: Ptr[c_char, AnyOrigin[False]]
    """The editing text."""
    var start: Int32
    """The start cursor of selected editing text, or -1 if not set."""
    var length: Int32
    """The length of selected editing text, or -1 if not set."""


@fieldwise_init
struct TextEditingCandidatesEvent(ImplicitlyCopyable, Movable):
    """Keyboard IME candidates event structure (event.edit_candidates.*).

    Docs: https://wiki.libsdl.org/SDL3/TextEditingCandidatesEvent.
    """

    var type: EventType
    """SDL_EVENT_TEXT_EDITING_CANDIDATES."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with keyboard focus, if any."""
    var candidates: Ptr[c_char, AnyOrigin[False]]
    """The list of candidates, or NULL if there are no candidates available."""
    var num_candidates: Int32
    """The number of strings in `candidates`."""
    var selected_candidate: Int32
    """The index of the selected candidate, or -1 if no candidate is selected."""
    var horizontal: Bool
    """True if the list is horizontal, false if it's vertical."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8


@fieldwise_init
struct TextInputEvent(ImplicitlyCopyable, Movable):
    """Keyboard text input event structure (event.text.*).

    This event will never be delivered unless text input is enabled by calling
    SDL_StartTextInput(). Text input is disabled by default!

    Docs: https://wiki.libsdl.org/SDL3/TextInputEvent.
    """

    var type: EventType
    """SDL_EVENT_TEXT_INPUT."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with keyboard focus, if any."""
    var text: Ptr[c_char, AnyOrigin[False]]
    """The input text, UTF-8 encoded."""


@fieldwise_init
struct MouseDeviceEvent(ImplicitlyCopyable, Movable):
    """Mouse device event structure (event.mdevice.*).

    Docs: https://wiki.libsdl.org/SDL3/MouseDeviceEvent.
    """

    var type: EventType
    """SDL_EVENT_MOUSE_ADDED or SDL_EVENT_MOUSE_REMOVED."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: MouseID
    """The mouse instance id."""


@fieldwise_init
struct MouseMotionEvent(ImplicitlyCopyable, Movable):
    """Mouse motion event structure (event.motion.*).

    Docs: https://wiki.libsdl.org/SDL3/MouseMotionEvent.
    """

    var type: EventType
    """SDL_EVENT_MOUSE_MOTION."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with mouse focus, if any."""
    var which: MouseID
    """The mouse instance id in relative mode, SDL_TOUCH_MOUSEID for touch events, or 0."""
    var state: MouseButtonFlags
    """The current button state."""
    var x: c_float
    """X coordinate, relative to window."""
    var y: c_float
    """Y coordinate, relative to window."""
    var xrel: c_float
    """The relative motion in the X direction."""
    var yrel: c_float
    """The relative motion in the Y direction."""


@fieldwise_init
struct MouseButtonEvent(ImplicitlyCopyable, Movable):
    """Mouse button event structure (event.button.*).

    Docs: https://wiki.libsdl.org/SDL3/MouseButtonEvent.
    """

    var type: EventType
    """SDL_EVENT_MOUSE_BUTTON_DOWN or SDL_EVENT_MOUSE_BUTTON_UP."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with mouse focus, if any."""
    var which: MouseID
    """The mouse instance id in relative mode, SDL_TOUCH_MOUSEID for touch events, or 0."""
    var button: UInt8
    """The mouse button index."""
    var down: Bool
    """True if the button is pressed."""
    var clicks: UInt8
    """1 for single-click, 2 for double-click, etc."""
    var padding: UInt8
    var x: c_float
    """X coordinate, relative to window."""
    var y: c_float
    """Y coordinate, relative to window."""


@fieldwise_init
struct MouseWheelEvent(ImplicitlyCopyable, Movable):
    """Mouse wheel event structure (event.wheel.*).

    Docs: https://wiki.libsdl.org/SDL3/MouseWheelEvent.
    """

    var type: EventType
    """SDL_EVENT_MOUSE_WHEEL."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with mouse focus, if any."""
    var which: MouseID
    """The mouse instance id in relative mode or 0."""
    var x: c_float
    """The amount scrolled horizontally, positive to the right and negative to the left."""
    var y: c_float
    """The amount scrolled vertically, positive away from the user and negative toward the user."""
    var direction: MouseWheelDirection
    """Set to one of the SDL_MOUSEWHEEL_* defines. When FLIPPED the values in X and Y will be opposite. Multiply by -1 to change them back."""
    var mouse_x: c_float
    """X coordinate, relative to window."""
    var mouse_y: c_float
    """Y coordinate, relative to window."""
    var integer_x: Int32
    """The amount scrolled horizontally, accumulated to whole scroll "ticks" (added in 3.2.12)."""
    var integer_y: Int32
    """The amount scrolled vertically, accumulated to whole scroll "ticks" (added in 3.2.12)."""


@fieldwise_init
struct JoyAxisEvent(ImplicitlyCopyable, Movable):
    """Joystick axis motion event structure (event.jaxis.*).

    Docs: https://wiki.libsdl.org/SDL3/JoyAxisEvent.
    """

    var type: EventType
    """SDL_EVENT_JOYSTICK_AXIS_MOTION."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""
    var axis: UInt8
    """The joystick axis index."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8
    var value: Int16
    """The axis value (range: -32768 to 32767)."""
    var padding4: UInt16


@fieldwise_init
struct JoyBallEvent(ImplicitlyCopyable, Movable):
    """Joystick trackball motion event structure (event.jball.*).

    Docs: https://wiki.libsdl.org/SDL3/JoyBallEvent.
    """

    var type: EventType
    """SDL_EVENT_JOYSTICK_BALL_MOTION."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""
    var ball: UInt8
    """The joystick trackball index."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8
    var xrel: Int16
    """The relative motion in the X direction."""
    var yrel: Int16
    """The relative motion in the Y direction."""


@fieldwise_init
struct JoyHatEvent(ImplicitlyCopyable, Movable):
    """Joystick hat position change event structure (event.jhat.*).

    Docs: https://wiki.libsdl.org/SDL3/JoyHatEvent.
    """

    var type: EventType
    """SDL_EVENT_JOYSTICK_HAT_MOTION."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""
    var hat: UInt8
    """The joystick hat index."""
    var value: UInt8
    """The hat position value.
      \\sa SDL_HAT_LEFTUP SDL_HAT_UP SDL_HAT_RIGHTUP
      \\sa SDL_HAT_LEFT SDL_HAT_CENTERED SDL_HAT_RIGHT
      \\sa SDL_HAT_LEFTDOWN SDL_HAT_DOWN SDL_HAT_RIGHTDOWN.
    
      Note that zero means the POV is centered."""
    var padding1: UInt8
    var padding2: UInt8


@fieldwise_init
struct JoyButtonEvent(ImplicitlyCopyable, Movable):
    """Joystick button event structure (event.jbutton.*).

    Docs: https://wiki.libsdl.org/SDL3/JoyButtonEvent.
    """

    var type: EventType
    """SDL_EVENT_JOYSTICK_BUTTON_DOWN or SDL_EVENT_JOYSTICK_BUTTON_UP."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""
    var button: UInt8
    """The joystick button index."""
    var down: Bool
    """True if the button is pressed."""
    var padding1: UInt8
    var padding2: UInt8


@fieldwise_init
struct JoyDeviceEvent(ImplicitlyCopyable, Movable):
    """Joystick device event structure (event.jdevice.*).

    SDL will send JOYSTICK_ADDED events for devices that are already plugged in
    during SDL_Init.

    Docs: https://wiki.libsdl.org/SDL3/JoyDeviceEvent.
    """

    var type: EventType
    """SDL_EVENT_JOYSTICK_ADDED or SDL_EVENT_JOYSTICK_REMOVED or SDL_EVENT_JOYSTICK_UPDATE_COMPLETE."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""


@fieldwise_init
struct JoyBatteryEvent(ImplicitlyCopyable, Movable):
    """Joystick battery level change event structure (event.jbattery.*).

    Docs: https://wiki.libsdl.org/SDL3/JoyBatteryEvent.
    """

    var type: EventType
    """SDL_EVENT_JOYSTICK_BATTERY_UPDATED."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""
    var state: PowerState
    """The joystick battery state."""
    var percent: c_int
    """The joystick battery percent charge remaining."""


@fieldwise_init
struct GamepadAxisEvent(ImplicitlyCopyable, Movable):
    """Gamepad axis motion event structure (event.gaxis.*).

    Docs: https://wiki.libsdl.org/SDL3/GamepadAxisEvent.
    """

    var type: EventType
    """SDL_EVENT_GAMEPAD_AXIS_MOTION."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""
    var axis: UInt8
    """The gamepad axis (SDL_GamepadAxis)."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8
    var value: Int16
    """The axis value (range: -32768 to 32767)."""
    var padding4: UInt16


@fieldwise_init
struct GamepadButtonEvent(ImplicitlyCopyable, Movable):
    """Gamepad button event structure (event.gbutton.*).

    Docs: https://wiki.libsdl.org/SDL3/GamepadButtonEvent.
    """

    var type: EventType
    """SDL_EVENT_GAMEPAD_BUTTON_DOWN or SDL_EVENT_GAMEPAD_BUTTON_UP."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""
    var button: UInt8
    """The gamepad button (SDL_GamepadButton)."""
    var down: Bool
    """True if the button is pressed."""
    var padding1: UInt8
    var padding2: UInt8


@fieldwise_init
struct GamepadDeviceEvent(ImplicitlyCopyable, Movable):
    """Gamepad device event structure (event.gdevice.*).

    Joysticks that are supported gamepads receive both an SDL_JoyDeviceEvent
    and an SDL_GamepadDeviceEvent.

    SDL will send GAMEPAD_ADDED events for joysticks that are already plugged
    in during SDL_Init() and are recognized as gamepads. It will also send
    events for joysticks that get gamepad mappings at runtime.

    Docs: https://wiki.libsdl.org/SDL3/GamepadDeviceEvent.
    """

    var type: EventType
    """SDL_EVENT_GAMEPAD_ADDED, SDL_EVENT_GAMEPAD_REMOVED, or SDL_EVENT_GAMEPAD_REMAPPED, SDL_EVENT_GAMEPAD_UPDATE_COMPLETE or SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""


@fieldwise_init
struct GamepadTouchpadEvent(ImplicitlyCopyable, Movable):
    """Gamepad touchpad event structure (event.gtouchpad.*).

    Docs: https://wiki.libsdl.org/SDL3/GamepadTouchpadEvent.
    """

    var type: EventType
    """SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN or SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION or SDL_EVENT_GAMEPAD_TOUCHPAD_UP."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""
    var touchpad: Int32
    """The index of the touchpad."""
    var finger: Int32
    """The index of the finger on the touchpad."""
    var x: c_float
    """Normalized in the range 0...1 with 0 being on the left."""
    var y: c_float
    """Normalized in the range 0...1 with 0 being at the top."""
    var pressure: c_float
    """Normalized in the range 0...1."""


@fieldwise_init
struct GamepadSensorEvent(ImplicitlyCopyable, Movable):
    """Gamepad sensor event structure (event.gsensor.*).

    Docs: https://wiki.libsdl.org/SDL3/GamepadSensorEvent.
    """

    var type: EventType
    """SDL_EVENT_GAMEPAD_SENSOR_UPDATE."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: JoystickID
    """The joystick instance id."""
    var sensor: Int32
    """The type of the sensor, one of the values of SDL_SensorType."""
    var data: ArrayHelper[c_float, 3, AnyOrigin[True]]
    """Up to 3 values from the sensor, as defined in SDL_sensor.h."""
    var sensor_timestamp: UInt64
    """The timestamp of the sensor reading in nanoseconds, not necessarily synchronized with the system clock."""


@fieldwise_init
struct AudioDeviceEvent(ImplicitlyCopyable, Movable):
    """Audio device event structure (event.adevice.*).

    Docs: https://wiki.libsdl.org/SDL3/AudioDeviceEvent.
    """

    var type: EventType
    """SDL_EVENT_AUDIO_DEVICE_ADDED, or SDL_EVENT_AUDIO_DEVICE_REMOVED, or SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: AudioDeviceID
    """SDL_AudioDeviceID for the device being added or removed or changing."""
    var recording: Bool
    """False if a playback device, true if a recording device."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8


@fieldwise_init
struct CameraDeviceEvent(ImplicitlyCopyable, Movable):
    """Camera device event structure (event.cdevice.*).

    Docs: https://wiki.libsdl.org/SDL3/CameraDeviceEvent.
    """

    var type: EventType
    """SDL_EVENT_CAMERA_DEVICE_ADDED, SDL_EVENT_CAMERA_DEVICE_REMOVED, SDL_EVENT_CAMERA_DEVICE_APPROVED, SDL_EVENT_CAMERA_DEVICE_DENIED."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: CameraID
    """SDL_CameraID for the device being added or removed or changing."""


@fieldwise_init
struct RenderEvent(ImplicitlyCopyable, Movable):
    """Renderer event structure (event.render.*).

    Docs: https://wiki.libsdl.org/SDL3/RenderEvent.
    """

    var type: EventType
    """SDL_EVENT_RENDER_TARGETS_RESET, SDL_EVENT_RENDER_DEVICE_RESET, SDL_EVENT_RENDER_DEVICE_LOST."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window containing the renderer in question."""


@fieldwise_init
struct TouchFingerEvent(ImplicitlyCopyable, Movable):
    """Touch finger event structure (event.tfinger.*).

    Coordinates in this event are normalized. `x` and `y` are normalized to a
    range between 0.0f and 1.0f, relative to the window, so (0,0) is the top
    left and (1,1) is the bottom right. Delta coordinates `dx` and `dy` are
    normalized in the ranges of -1.0f (traversed all the way from the bottom or
    right to all the way up or left) to 1.0f (traversed all the way from the
    top or left to all the way down or right).

    Note that while the coordinates are _normalized_, they are not _clamped_,
    which means in some circumstances you can get a value outside of this
    range. For example, a renderer using logical presentation might give a
    negative value when the touch is in the letterboxing. Some platforms might
    report a touch outside of the window, which will also be outside of the
    range.

    Docs: https://wiki.libsdl.org/SDL3/TouchFingerEvent.
    """

    var type: EventType
    """SDL_EVENT_FINGER_DOWN, SDL_EVENT_FINGER_UP, SDL_EVENT_FINGER_MOTION, or SDL_EVENT_FINGER_CANCELED."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var touch_id: TouchID
    """The touch device id."""
    var finger_id: FingerID
    var x: c_float
    """Normalized in the range 0...1."""
    var y: c_float
    """Normalized in the range 0...1."""
    var dx: c_float
    """Normalized in the range -1...1."""
    var dy: c_float
    """Normalized in the range -1...1."""
    var pressure: c_float
    """Normalized in the range 0...1."""
    var window_id: WindowID
    """The window underneath the finger, if any."""


@fieldwise_init
struct PenProximityEvent(ImplicitlyCopyable, Movable):
    """Pressure-sensitive pen proximity event structure (event.pmotion.*).

    When a pen becomes visible to the system (it is close enough to a tablet,
    etc), SDL will send an SDL_EVENT_PEN_PROXIMITY_IN event with the new pen's
    ID. This ID is valid until the pen leaves proximity again (has been removed
    from the tablet's area, the tablet has been unplugged, etc). If the same
    pen reenters proximity again, it will be given a new ID.

    Note that "proximity" means "close enough for the tablet to know the tool
    is there." The pen touching and lifting off from the tablet while not
    leaving the area are handled by SDL_EVENT_PEN_DOWN and SDL_EVENT_PEN_UP.

    Docs: https://wiki.libsdl.org/SDL3/PenProximityEvent.
    """

    var type: EventType
    """SDL_EVENT_PEN_PROXIMITY_IN or SDL_EVENT_PEN_PROXIMITY_OUT."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with pen focus, if any."""
    var which: PenID
    """The pen instance id."""


@fieldwise_init
struct PenMotionEvent(ImplicitlyCopyable, Movable):
    """Pressure-sensitive pen motion event structure (event.pmotion.*).

    Depending on the hardware, you may get motion events when the pen is not
    touching a tablet, for tracking a pen even when it isn't drawing. You
    should listen for SDL_EVENT_PEN_DOWN and SDL_EVENT_PEN_UP events, or check
    `pen_state & SDL_PEN_INPUT_DOWN` to decide if a pen is "drawing" when
    dealing with pen motion.

    Docs: https://wiki.libsdl.org/SDL3/PenMotionEvent.
    """

    var type: EventType
    """SDL_EVENT_PEN_MOTION."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with pen focus, if any."""
    var which: PenID
    """The pen instance id."""
    var pen_state: PenInputFlags
    """Complete pen input state at time of event."""
    var x: c_float
    """X coordinate, relative to window."""
    var y: c_float
    """Y coordinate, relative to window."""


@fieldwise_init
struct PenTouchEvent(ImplicitlyCopyable, Movable):
    """Pressure-sensitive pen touched event structure (event.ptouch.*).

    These events come when a pen touches a surface (a tablet, etc), or lifts
    off from one.

    Docs: https://wiki.libsdl.org/SDL3/PenTouchEvent.
    """

    var type: EventType
    """SDL_EVENT_PEN_DOWN or SDL_EVENT_PEN_UP."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with pen focus, if any."""
    var which: PenID
    """The pen instance id."""
    var pen_state: PenInputFlags
    """Complete pen input state at time of event."""
    var x: c_float
    """X coordinate, relative to window."""
    var y: c_float
    """Y coordinate, relative to window."""
    var eraser: Bool
    """True if eraser end is used (not all pens support this)."""
    var down: Bool
    """True if the pen is touching or false if the pen is lifted off."""


@fieldwise_init
struct PenButtonEvent(ImplicitlyCopyable, Movable):
    """Pressure-sensitive pen button event structure (event.pbutton.*).

    This is for buttons on the pen itself that the user might click. The pen
    itself pressing down to draw triggers a SDL_EVENT_PEN_DOWN event instead.

    Docs: https://wiki.libsdl.org/SDL3/PenButtonEvent.
    """

    var type: EventType
    """SDL_EVENT_PEN_BUTTON_DOWN or SDL_EVENT_PEN_BUTTON_UP."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with mouse focus, if any."""
    var which: PenID
    """The pen instance id."""
    var pen_state: PenInputFlags
    """Complete pen input state at time of event."""
    var x: c_float
    """X coordinate, relative to window."""
    var y: c_float
    """Y coordinate, relative to window."""
    var button: UInt8
    """The pen button index (first button is 1)."""
    var down: Bool
    """True if the button is pressed."""


@fieldwise_init
struct PenAxisEvent(ImplicitlyCopyable, Movable):
    """Pressure-sensitive pen pressure / angle event structure (event.paxis.*).

    You might get some of these events even if the pen isn't touching the
    tablet.

    Docs: https://wiki.libsdl.org/SDL3/PenAxisEvent.
    """

    var type: EventType
    """SDL_EVENT_PEN_AXIS."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window with pen focus, if any."""
    var which: PenID
    """The pen instance id."""
    var pen_state: PenInputFlags
    """Complete pen input state at time of event."""
    var x: c_float
    """X coordinate, relative to window."""
    var y: c_float
    """Y coordinate, relative to window."""
    var axis: PenAxis
    """Axis that has changed."""
    var value: c_float
    """New value of axis."""


@fieldwise_init
struct DropEvent(ImplicitlyCopyable, Movable):
    """An event used to drop text or request a file open by the system
    (event.drop.*).

    Docs: https://wiki.libsdl.org/SDL3/DropEvent.
    """

    var type: EventType
    """SDL_EVENT_DROP_BEGIN or SDL_EVENT_DROP_FILE or SDL_EVENT_DROP_TEXT or SDL_EVENT_DROP_COMPLETE or SDL_EVENT_DROP_POSITION."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The window that was dropped on, if any."""
    var x: c_float
    """X coordinate, relative to window (not on begin)."""
    var y: c_float
    """Y coordinate, relative to window (not on begin)."""
    var source: Ptr[c_char, AnyOrigin[False]]
    """The source app that sent this drop event, or NULL if that isn't available."""
    var data: Ptr[c_char, AnyOrigin[False]]
    """The text for SDL_EVENT_DROP_TEXT and the file name for SDL_EVENT_DROP_FILE, NULL for other events."""


@fieldwise_init
struct ClipboardEvent(ImplicitlyCopyable, Movable):
    """An event triggered when the clipboard contents have changed
    (event.clipboard.*).

    Docs: https://wiki.libsdl.org/SDL3/ClipboardEvent.
    """

    var type: EventType
    """SDL_EVENT_CLIPBOARD_UPDATE."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var owner: Bool
    """Are we owning the clipboard (internal update)."""
    var num_mime_types: Int32
    """Number of mime types."""
    var mime_types: Ptr[Ptr[c_char, AnyOrigin[False]], AnyOrigin[False]]
    """Current mime types."""


@fieldwise_init
struct SensorEvent(ImplicitlyCopyable, Movable):
    """Sensor event structure (event.sensor.*).

    Docs: https://wiki.libsdl.org/SDL3/SensorEvent.
    """

    var type: EventType
    """SDL_EVENT_SENSOR_UPDATE."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var which: SensorID
    """The instance ID of the sensor."""
    var data: ArrayHelper[c_float, 6, AnyOrigin[True]]
    """Up to 6 values from the sensor - additional values can be queried using SDL_GetSensorData()."""
    var sensor_timestamp: UInt64
    """The timestamp of the sensor reading in nanoseconds, not necessarily synchronized with the system clock."""


@fieldwise_init
struct QuitEvent(ImplicitlyCopyable, Movable):
    """The "quit requested" event.

    Docs: https://wiki.libsdl.org/SDL3/QuitEvent.
    """

    var type: EventType
    """SDL_EVENT_QUIT."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""


@fieldwise_init
struct UserEvent(ImplicitlyCopyable, Movable):
    """A user-defined event type (event.user.*).

    This event is unique; it is never created by SDL, but only by the
    application. The event can be pushed onto the event queue using
    SDL_PushEvent(). The contents of the structure members are completely up to
    the programmer; the only requirement is that '''type''' is a value obtained
    from SDL_RegisterEvents().

    Docs: https://wiki.libsdl.org/SDL3/UserEvent.
    """

    var type: UInt32
    """SDL_EVENT_USER through SDL_EVENT_LAST-1, Uint32 because these are not in the SDL_EventType enumeration."""
    var reserved: UInt32
    var timestamp: UInt64
    """In nanoseconds, populated using SDL_GetTicksNS()."""
    var window_id: WindowID
    """The associated window if any."""
    var code: Int32
    """User defined event code."""
    var data1: Ptr[NoneType, AnyOrigin[True]]
    """User defined data pointer."""
    var data2: Ptr[NoneType, AnyOrigin[True]]
    """User defined data pointer."""


struct Event:
    comptime _mlir_type = __mlir_type[`!pop.union<`, UInt32, `, `, CommonEvent, `, `, DisplayEvent, `, `, WindowEvent, `, `, KeyboardDeviceEvent, `, `, KeyboardEvent, `, `, TextEditingEvent, `, `, TextEditingCandidatesEvent, `, `, TextInputEvent, `, `, MouseDeviceEvent, `, `, MouseMotionEvent, `, `, MouseButtonEvent, `, `, MouseWheelEvent, `, `, JoyDeviceEvent, `, `, JoyAxisEvent, `, `, JoyBallEvent, `, `, JoyHatEvent, `, `, JoyButtonEvent, `, `, JoyBatteryEvent, `, `, GamepadDeviceEvent, `, `, GamepadAxisEvent, `, `, GamepadButtonEvent, `, `, GamepadTouchpadEvent, `, `, GamepadSensorEvent, `, `, AudioDeviceEvent, `, `, CameraDeviceEvent, `, `, SensorEvent, `, `, QuitEvent, `, `, UserEvent, `, `, TouchFingerEvent, `, `, PenProximityEvent, `, `, PenTouchEvent, `, `, PenMotionEvent, `, `, PenButtonEvent, `, `, PenAxisEvent, `, `, RenderEvent, `, `, DropEvent, `, `, ClipboardEvent, `, `, InlineArray[UInt8, 128], `>`]
    var _impl: Self._mlir_type

    @implicit
    fn __init__[T: AnyType](out self, value: T):
        self._impl = rebind[Self._mlir_type](value)

    fn __getitem__[T: AnyType](ref self) -> ref [self._impl] T:
        return rebind[Ptr[T, origin_of(self._impl)]](Ptr(to=self._impl))[]


fn pump_events() raises -> None:
    """Pump the event loop, gathering events from the input devices.

    This function updates the event queue and internal input device state.

    SDL_PumpEvents() gathers all the pending input information from devices and
    places it in the event queue. Without calls to SDL_PumpEvents() no events
    would ever be placed on the queue. Often the need for calls to
    SDL_PumpEvents() is hidden from the user since SDL_PollEvent() and
    SDL_WaitEvent() implicitly call SDL_PumpEvents(). However, if you are not
    polling or waiting for events (e.g. you are filtering them), then you must
    call SDL_PumpEvents() to force an event queue update.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PumpEvents.
    """

    return _get_dylib_function[lib, "SDL_PumpEvents", fn () -> None]()()


@register_passable("trivial")
struct EventAction(Indexer, Intable):
    """The type of action to request from SDL_PeepEvents().

    Docs: https://wiki.libsdl.org/SDL3/SDL_EventAction.
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

    comptime ADDEVENT = Self(0x0)
    """Add events to the back of the queue."""
    comptime PEEKEVENT = Self(0x1)
    """Check but don't remove events from the queue front."""
    comptime GETEVENT = Self(0x2)
    """Retrieve/remove events from the front of the queue."""


fn peep_events(events: Ptr[Event, AnyOrigin[True]], numevents: c_int, action: EventAction, min_type: UInt32, max_type: UInt32) raises -> c_int:
    """Check the event queue for messages and optionally return them.

    `action` may be any of the following:

    - `SDL_ADDEVENT`: up to `numevents` events will be added to the back of the
      event queue.
    - `SDL_PEEKEVENT`: `numevents` events at the front of the event queue,
      within the specified minimum and maximum type, will be returned to the
      caller and will _not_ be removed from the queue. If you pass NULL for
      `events`, then `numevents` is ignored and the total number of matching
      events will be returned.
    - `SDL_GETEVENT`: up to `numevents` events at the front of the event queue,
      within the specified minimum and maximum type, will be returned to the
      caller and will be removed from the queue.

    You may have to call SDL_PumpEvents() before calling this function.
    Otherwise, the events may not be ready to be filtered when you call
    SDL_PeepEvents().

    Args:
        events: Destination buffer for the retrieved events, may be NULL to
                leave the events in the queue and return the number of events
                that would have been stored.
        numevents: If action is SDL_ADDEVENT, the number of events to add
                   back to the event queue; if action is SDL_PEEKEVENT or
                   SDL_GETEVENT, the maximum number of events to retrieve.
        action: Action to take; see [Remarks](#remarks) for details.
        min_type: Minimum value of the event type to be considered;
                  SDL_EVENT_FIRST is a safe choice.
        max_type: Maximum value of the event type to be considered;
                  SDL_EVENT_LAST is a safe choice.

    Returns:
        The number of events actually stored or -1 on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PeepEvents.
    """

    return _get_dylib_function[lib, "SDL_PeepEvents", fn (events: Ptr[Event, AnyOrigin[True]], numevents: c_int, action: EventAction, min_type: UInt32, max_type: UInt32) -> c_int]()(events, numevents, action, min_type, max_type)


fn has_event(type: UInt32) raises -> Bool:
    """Check for the existence of a certain event type in the event queue.

    If you need to check for a range of event types, use SDL_HasEvents()
    instead.

    Args:
        type: The type of event to be queried; see SDL_EventType for details.

    Returns:
        True if events matching `type` are present, or false if events
        matching `type` are not present.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasEvent.
    """

    return _get_dylib_function[lib, "SDL_HasEvent", fn (type: UInt32) -> Bool]()(type)


fn has_events(min_type: UInt32, max_type: UInt32) raises -> Bool:
    """Check for the existence of certain event types in the event queue.

    If you need to check for a single event type, use SDL_HasEvent() instead.

    Args:
        min_type: The low end of event type to be queried, inclusive; see
                  SDL_EventType for details.
        max_type: The high end of event type to be queried, inclusive; see
                  SDL_EventType for details.

    Returns:
        True if events with type >= `minType` and <= `maxType` are
        present, or false if not.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasEvents.
    """

    return _get_dylib_function[lib, "SDL_HasEvents", fn (min_type: UInt32, max_type: UInt32) -> Bool]()(min_type, max_type)


fn flush_event(type: UInt32) raises -> None:
    """Clear events of a specific type from the event queue.

    This will unconditionally remove any events from the queue that match
    `type`. If you need to remove a range of event types, use SDL_FlushEvents()
    instead.

    It's also normal to just ignore events you don't care about in your event
    loop without calling this function.

    This function only affects currently queued events. If you want to make
    sure that all pending OS events are flushed, you can call SDL_PumpEvents()
    on the main thread immediately before the flush call.

    If you have user events with custom data that needs to be freed, you should
    use SDL_PeepEvents() to remove and clean up those events before calling
    this function.

    Args:
        type: The type of event to be cleared; see SDL_EventType for details.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FlushEvent.
    """

    return _get_dylib_function[lib, "SDL_FlushEvent", fn (type: UInt32) -> None]()(type)


fn flush_events(min_type: UInt32, max_type: UInt32) raises -> None:
    """Clear events of a range of types from the event queue.

    This will unconditionally remove any events from the queue that are in the
    range of `minType` to `maxType`, inclusive. If you need to remove a single
    event type, use SDL_FlushEvent() instead.

    It's also normal to just ignore events you don't care about in your event
    loop without calling this function.

    This function only affects currently queued events. If you want to make
    sure that all pending OS events are flushed, you can call SDL_PumpEvents()
    on the main thread immediately before the flush call.

    Args:
        min_type: The low end of event type to be cleared, inclusive; see
                  SDL_EventType for details.
        max_type: The high end of event type to be cleared, inclusive; see
                  SDL_EventType for details.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FlushEvents.
    """

    return _get_dylib_function[lib, "SDL_FlushEvents", fn (min_type: UInt32, max_type: UInt32) -> None]()(min_type, max_type)


fn poll_event(event: Ptr[Event, AnyOrigin[True]]) raises -> Bool:
    """Poll for currently pending events.

    If `event` is not NULL, the next event is removed from the queue and stored
    in the SDL_Event structure pointed to by `event`. The 1 returned refers to
    this event, immediately stored in the SDL Event structure -- not an event
    to follow.

    If `event` is NULL, it simply returns 1 if there is an event in the queue,
    but will not remove it from the queue.

    As this function may implicitly call SDL_PumpEvents(), you can only call
    this function in the thread that set the video mode.

    SDL_PollEvent() is the favored way of receiving system events since it can
    be done from the main loop and does not suspend the main loop while waiting
    on an event to be posted.

    The common practice is to fully process the event queue once every frame,
    usually as a first step before updating the game's state:

    ```c
    while (game_is_still_running) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {  // poll until all events are handled!
            // decide what to do with this event.
        }

        // update game state, draw the current frame
    }
    ```

    Args:
        event: The SDL_Event structure to be filled with the next event from
               the queue, or NULL.

    Returns:
        True if this got an event or false if there are none available.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PollEvent.
    """

    return _get_dylib_function[lib, "SDL_PollEvent", fn (event: Ptr[Event, AnyOrigin[True]]) -> Bool]()(event)


fn wait_event(event: Ptr[Event, AnyOrigin[True]]) raises:
    """Wait indefinitely for the next available event.

    If `event` is not NULL, the next event is removed from the queue and stored
    in the SDL_Event structure pointed to by `event`.

    As this function may implicitly call SDL_PumpEvents(), you can only call
    this function in the thread that initialized the video subsystem.

    Args:
        event: The SDL_Event structure to be filled in with the next event
               from the queue, or NULL.

    Raises:
        Raises if there was an error while waiting for
        events; call SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WaitEvent.
    """

    ret = _get_dylib_function[lib, "SDL_WaitEvent", fn (event: Ptr[Event, AnyOrigin[True]]) -> Bool]()(event)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn wait_event_timeout(event: Ptr[Event, AnyOrigin[True]], timeout_ms: Int32) raises -> Bool:
    """Wait until the specified timeout (in milliseconds) for the next available
    event.

    If `event` is not NULL, the next event is removed from the queue and stored
    in the SDL_Event structure pointed to by `event`.

    As this function may implicitly call SDL_PumpEvents(), you can only call
    this function in the thread that initialized the video subsystem.

    The timeout is not guaranteed, the actual wait time could be longer due to
    system scheduling.

    Args:
        event: The SDL_Event structure to be filled in with the next event
               from the queue, or NULL.
        timeout_ms: The maximum number of milliseconds to wait for the next
                    available event.

    Returns:
        True if this got an event or false if the timeout elapsed without
        any events available.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WaitEventTimeout.
    """

    return _get_dylib_function[lib, "SDL_WaitEventTimeout", fn (event: Ptr[Event, AnyOrigin[True]], timeout_ms: Int32) -> Bool]()(event, timeout_ms)


fn push_event(event: Ptr[Event, AnyOrigin[True]]) raises:
    """Add an event to the event queue.

    The event queue can actually be used as a two way communication channel.
    Not only can events be read from the queue, but the user can also push
    their own events onto it. `event` is a pointer to the event structure you
    wish to push onto the queue. The event is copied into the queue, and the
    caller may dispose of the memory pointed to after SDL_PushEvent() returns.

    Note: Pushing device input events onto the queue doesn't modify the state
    of the device within SDL.

    Note: Events pushed onto the queue with SDL_PushEvent() get passed through
    the event filter but events added with SDL_PeepEvents() do not.

    For pushing application-specific events, please use SDL_RegisterEvents() to
    get an event type that does not conflict with other code that also wants
    its own custom event types.

    Args:
        event: The SDL_Event to be added to the queue.

    Raises:
        Raises if the event was filtered or on failure;
        call SDL_GetError() for more information. A common reason for
        error is the event queue being full.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PushEvent.
    """

    ret = _get_dylib_function[lib, "SDL_PushEvent", fn (event: Ptr[Event, AnyOrigin[True]]) -> Bool]()(event)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


comptime EventFilter = fn (userdata: Ptr[NoneType, AnyOrigin[True]], event: Ptr[Event, AnyOrigin[True]]) -> Bool
"""A function pointer used for callbacks that watch the event queue.
    
    Args:
        userdata: What was passed as `userdata` to SDL_SetEventFilter() or
                  SDL_AddEventWatch, etc.
        event: The event that triggered the callback.
    
    Returns:
        True to permit event to be added to the queue, and false to
        disallow it. When used with SDL_AddEventWatch, the return value is
        ignored.
    
    Safety:
        SDL may call this callback at any time from any thread; the
        application is responsible for locking resources the callback
        touches that need to be protected.

Docs: https://wiki.libsdl.org/SDL3/SDL_EventFilter.
"""


fn set_event_filter(filter: EventFilter, userdata: Ptr[NoneType, AnyOrigin[True]]) raises -> None:
    """Set up a filter to process all events before they are added to the internal
    event queue.

    If you just want to see events without modifying them or preventing them
    from being queued, you should use SDL_AddEventWatch() instead.

    If the filter function returns true when called, then the event will be
    added to the internal queue. If it returns false, then the event will be
    dropped from the queue, but the internal state will still be updated. This
    allows selective filtering of dynamically arriving events.

    **WARNING**: Be very careful of what you do in the event filter function,
    as it may run in a different thread!

    On platforms that support it, if the quit event is generated by an
    interrupt signal (e.g. pressing Ctrl-C), it will be delivered to the
    application at the next event poll.

    Note: Disabled events never make it to the event filter function; see
    SDL_SetEventEnabled().

    Note: Events pushed onto the queue with SDL_PushEvent() get passed through
    the event filter, but events pushed onto the queue with SDL_PeepEvents() do
    not.

    Args:
        filter: An SDL_EventFilter function to call when an event happens.
        userdata: A pointer that is passed to `filter`.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetEventFilter.
    """

    return _get_dylib_function[lib, "SDL_SetEventFilter", fn (filter: EventFilter, userdata: Ptr[NoneType, AnyOrigin[True]]) -> None]()(filter, userdata)


fn get_event_filter(filter: Ptr[EventFilter, AnyOrigin[True]], userdata: Ptr[Ptr[NoneType, AnyOrigin[True]], AnyOrigin[True]]) raises:
    """Query the current event filter.

    This function can be used to "chain" filters, by saving the existing filter
    before replacing it with a function that will call that saved filter.

    Args:
        filter: The current callback function will be stored here.
        userdata: The pointer that is passed to the current event filter will
                  be stored here.

    Raises:
        Raises if there is no event filter set.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetEventFilter.
    """

    ret = _get_dylib_function[lib, "SDL_GetEventFilter", fn (filter: Ptr[EventFilter, AnyOrigin[True]], userdata: Ptr[Ptr[NoneType, AnyOrigin[True]], AnyOrigin[True]]) -> Bool]()(filter, userdata)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn add_event_watch(filter: EventFilter, userdata: Ptr[NoneType, AnyOrigin[True]]) raises:
    """Add a callback to be triggered when an event is added to the event queue.

    `filter` will be called when an event happens, and its return value is
    ignored.

    **WARNING**: Be very careful of what you do in the event filter function,
    as it may run in a different thread!

    If the quit event is generated by a signal (e.g. SIGINT), it will bypass
    the internal queue and be delivered to the watch callback immediately, and
    arrive at the next event poll.

    Note: the callback is called for events posted by the user through
    SDL_PushEvent(), but not for disabled events, nor for events by a filter
    callback set with SDL_SetEventFilter(), nor for events posted by the user
    through SDL_PeepEvents().

    Args:
        filter: An SDL_EventFilter function to call when an event happens.
        userdata: A pointer that is passed to `filter`.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AddEventWatch.
    """

    ret = _get_dylib_function[lib, "SDL_AddEventWatch", fn (filter: EventFilter, userdata: Ptr[NoneType, AnyOrigin[True]]) -> Bool]()(filter, userdata)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn remove_event_watch(filter: EventFilter, userdata: Ptr[NoneType, AnyOrigin[True]]) raises -> None:
    """Remove an event watch callback added with SDL_AddEventWatch().

    This function takes the same input as SDL_AddEventWatch() to identify and
    delete the corresponding callback.

    Args:
        filter: The function originally passed to SDL_AddEventWatch().
        userdata: The pointer originally passed to SDL_AddEventWatch().

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RemoveEventWatch.
    """

    return _get_dylib_function[lib, "SDL_RemoveEventWatch", fn (filter: EventFilter, userdata: Ptr[NoneType, AnyOrigin[True]]) -> None]()(filter, userdata)


fn filter_events(filter: EventFilter, userdata: Ptr[NoneType, AnyOrigin[True]]) raises -> None:
    """Run a specific filter function on the current event queue, removing any
    events for which the filter returns false.

    See SDL_SetEventFilter() for more information. Unlike SDL_SetEventFilter(),
    this function does not change the filter permanently, it only uses the
    supplied filter until this function returns.

    Args:
        filter: The SDL_EventFilter function to call when an event happens.
        userdata: A pointer that is passed to `filter`.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FilterEvents.
    """

    return _get_dylib_function[lib, "SDL_FilterEvents", fn (filter: EventFilter, userdata: Ptr[NoneType, AnyOrigin[True]]) -> None]()(filter, userdata)


fn set_event_enabled(type: UInt32, enabled: Bool) raises -> None:
    """Set the state of processing events by type.

    Args:
        type: The type of event; see SDL_EventType for details.
        enabled: Whether to process the event or not.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetEventEnabled.
    """

    return _get_dylib_function[lib, "SDL_SetEventEnabled", fn (type: UInt32, enabled: Bool) -> None]()(type, enabled)


fn event_enabled(type: UInt32) raises -> Bool:
    """Query the state of processing events by type.

    Args:
        type: The type of event; see SDL_EventType for details.

    Returns:
        True if the event is being processed, false otherwise.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EventEnabled.
    """

    return _get_dylib_function[lib, "SDL_EventEnabled", fn (type: UInt32) -> Bool]()(type)


fn register_events(numevents: c_int) raises -> UInt32:
    """Allocate a set of user-defined events, and return the beginning event
    number for that set of events.

    Args:
        numevents: The number of events to be allocated.

    Returns:
        The beginning event number, or 0 if numevents is invalid or if
        there are not enough user-defined events left.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RegisterEvents.
    """

    return _get_dylib_function[lib, "SDL_RegisterEvents", fn (numevents: c_int) -> UInt32]()(numevents)


fn get_window_from_event(event: Ptr[Event, AnyOrigin[False]]) raises -> Ptr[Window, AnyOrigin[True]]:
    """Get window associated with an event.

    Args:
        event: An event containing a `windowID`.

    Returns:
        The associated window on success or NULL if there is none.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetWindowFromEvent.
    """

    return _get_dylib_function[lib, "SDL_GetWindowFromEvent", fn (event: Ptr[Event, AnyOrigin[False]]) -> Ptr[Window, AnyOrigin[True]]]()(event)
