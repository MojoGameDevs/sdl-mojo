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

"""Scancode

Defines keyboard scancodes.

Please refer to the Best Keyboard Practices document for details on what
this information means and how best to use it.

https://wiki.libsdl.org/SDL3/BestKeyboardPractices
"""


@register_passable("trivial")
struct Scancode(Indexer, Intable):
    """The SDL keyboard scancode representation.

    An SDL scancode is the physical representation of a key on the keyboard,
    independent of language and keyboard mapping.

    Values of this type are used to represent keyboard keys, among other places
    in the `scancode` field of the SDL_KeyboardEvent structure.

    The values in this enumeration are based on the USB usage page standard:
    https://usb.org/sites/default/files/hut1_5.pdf

    Docs: https://wiki.libsdl.org/SDL3/SDL_Scancode.
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

    comptime SCANCODE_UNKNOWN = Self(0)

    # *  \name Usage page 0x07
    #      *
    #      *  These values are from usage page 0x07 (USB keyboard page).

    comptime SCANCODE_A = Self(4)
    comptime SCANCODE_B = Self(5)
    comptime SCANCODE_C = Self(6)
    comptime SCANCODE_D = Self(7)
    comptime SCANCODE_E = Self(8)
    comptime SCANCODE_F = Self(9)
    comptime SCANCODE_G = Self(10)
    comptime SCANCODE_H = Self(11)
    comptime SCANCODE_I = Self(12)
    comptime SCANCODE_J = Self(13)
    comptime SCANCODE_K = Self(14)
    comptime SCANCODE_L = Self(15)
    comptime SCANCODE_M = Self(16)
    comptime SCANCODE_N = Self(17)
    comptime SCANCODE_O = Self(18)
    comptime SCANCODE_P = Self(19)
    comptime SCANCODE_Q = Self(20)
    comptime SCANCODE_R = Self(21)
    comptime SCANCODE_S = Self(22)
    comptime SCANCODE_T = Self(23)
    comptime SCANCODE_U = Self(24)
    comptime SCANCODE_V = Self(25)
    comptime SCANCODE_W = Self(26)
    comptime SCANCODE_X = Self(27)
    comptime SCANCODE_Y = Self(28)
    comptime SCANCODE_Z = Self(29)

    comptime SCANCODE_1 = Self(30)
    comptime SCANCODE_2 = Self(31)
    comptime SCANCODE_3 = Self(32)
    comptime SCANCODE_4 = Self(33)
    comptime SCANCODE_5 = Self(34)
    comptime SCANCODE_6 = Self(35)
    comptime SCANCODE_7 = Self(36)
    comptime SCANCODE_8 = Self(37)
    comptime SCANCODE_9 = Self(38)
    comptime SCANCODE_0 = Self(39)

    comptime SCANCODE_RETURN = Self(40)
    comptime SCANCODE_ESCAPE = Self(41)
    comptime SCANCODE_BACKSPACE = Self(42)
    comptime SCANCODE_TAB = Self(43)
    comptime SCANCODE_SPACE = Self(44)

    comptime SCANCODE_MINUS = Self(45)
    comptime SCANCODE_EQUALS = Self(46)
    comptime SCANCODE_LEFTBRACKET = Self(47)
    comptime SCANCODE_RIGHTBRACKET = Self(48)
    comptime SCANCODE_BACKSLASH = Self(49)
    """Located at the lower left of the return
      key on ISO keyboards and at the right end
      of the QWERTY row on ANSI keyboards.
      Produces REVERSE SOLIDUS (backslash) and
      VERTICAL LINE in a US layout, REVERSE
      SOLIDUS and VERTICAL LINE in a UK Mac
      layout, NUMBER SIGN and TILDE in a UK
      Windows layout, DOLLAR SIGN and POUND SIGN
      in a Swiss German layout, NUMBER SIGN and
      APOSTROPHE in a German layout, GRAVE
      ACCENT and POUND SIGN in a French Mac
      layout, and ASTERISK and MICRO SIGN in a
      French Windows layout."""
    comptime SCANCODE_NONUSHASH = Self(50)
    """ISO USB keyboards actually use this code
      instead of 49 for the same key, but all
      OSes I've seen treat the two codes
      identically. So, as an implementor, unless
      your keyboard generates both of those
      codes and your OS treats them differently,
      you should generate SDL_SCANCODE_BACKSLASH
      instead of this code. As a user, you
      should not rely on this code because SDL
      will never generate it with most (all?)
      keyboards."""
    comptime SCANCODE_SEMICOLON = Self(51)
    comptime SCANCODE_APOSTROPHE = Self(52)
    comptime SCANCODE_GRAVE = Self(53)
    """Located in the top left corner (on both ANSI
      and ISO keyboards). Produces GRAVE ACCENT and
      TILDE in a US Windows layout and in US and UK
      Mac layouts on ANSI keyboards, GRAVE ACCENT
      and NOT SIGN in a UK Windows layout, SECTION
      SIGN and PLUS-MINUS SIGN in US and UK Mac
      layouts on ISO keyboards, SECTION SIGN and
      DEGREE SIGN in a Swiss German layout (Mac:
      only on ISO keyboards), CIRCUMFLEX ACCENT and
      DEGREE SIGN in a German layout (Mac: only on
      ISO keyboards), SUPERSCRIPT TWO and TILDE in a
      French Windows layout, COMMERCIAL AT and
      NUMBER SIGN in a French Mac layout on ISO
      keyboards, and LESS-THAN SIGN and GREATER-THAN
      SIGN in a Swiss German, German, or French Mac
      layout on ANSI keyboards."""
    comptime SCANCODE_COMMA = Self(54)
    comptime SCANCODE_PERIOD = Self(55)
    comptime SCANCODE_SLASH = Self(56)

    comptime SCANCODE_CAPSLOCK = Self(57)

    comptime SCANCODE_F1 = Self(58)
    comptime SCANCODE_F2 = Self(59)
    comptime SCANCODE_F3 = Self(60)
    comptime SCANCODE_F4 = Self(61)
    comptime SCANCODE_F5 = Self(62)
    comptime SCANCODE_F6 = Self(63)
    comptime SCANCODE_F7 = Self(64)
    comptime SCANCODE_F8 = Self(65)
    comptime SCANCODE_F9 = Self(66)
    comptime SCANCODE_F10 = Self(67)
    comptime SCANCODE_F11 = Self(68)
    comptime SCANCODE_F12 = Self(69)

    comptime SCANCODE_PRINTSCREEN = Self(70)
    comptime SCANCODE_SCROLLLOCK = Self(71)
    comptime SCANCODE_PAUSE = Self(72)
    comptime SCANCODE_INSERT = Self(73)
    """Insert on PC, help on some Mac keyboards (but
                                       does send code 73, not 117)."""
    comptime SCANCODE_HOME = Self(74)
    comptime SCANCODE_PAGEUP = Self(75)
    comptime SCANCODE_DELETE = Self(76)
    comptime SCANCODE_END = Self(77)
    comptime SCANCODE_PAGEDOWN = Self(78)
    comptime SCANCODE_RIGHT = Self(79)
    comptime SCANCODE_LEFT = Self(80)
    comptime SCANCODE_DOWN = Self(81)
    comptime SCANCODE_UP = Self(82)

    comptime SCANCODE_NUMLOCKCLEAR = Self(83)
    """Num lock on PC, clear on Mac keyboards."""
    comptime SCANCODE_KP_DIVIDE = Self(84)
    comptime SCANCODE_KP_MULTIPLY = Self(85)
    comptime SCANCODE_KP_MINUS = Self(86)
    comptime SCANCODE_KP_PLUS = Self(87)
    comptime SCANCODE_KP_ENTER = Self(88)
    comptime SCANCODE_KP_1 = Self(89)
    comptime SCANCODE_KP_2 = Self(90)
    comptime SCANCODE_KP_3 = Self(91)
    comptime SCANCODE_KP_4 = Self(92)
    comptime SCANCODE_KP_5 = Self(93)
    comptime SCANCODE_KP_6 = Self(94)
    comptime SCANCODE_KP_7 = Self(95)
    comptime SCANCODE_KP_8 = Self(96)
    comptime SCANCODE_KP_9 = Self(97)
    comptime SCANCODE_KP_0 = Self(98)
    comptime SCANCODE_KP_PERIOD = Self(99)

    comptime SCANCODE_NONUSBACKSLASH = Self(100)
    """This is the additional key that ISO
      keyboards have over ANSI ones,
      located between left shift and Z.
      Produces GRAVE ACCENT and TILDE in a
      US or UK Mac layout, REVERSE SOLIDUS
      (backslash) and VERTICAL LINE in a
      US or UK Windows layout, and
      LESS-THAN SIGN and GREATER-THAN SIGN
      in a Swiss German, German, or French
      layout."""
    comptime SCANCODE_APPLICATION = Self(101)
    """Windows contextual menu, compose."""
    comptime SCANCODE_POWER = Self(102)
    """The USB document says this is a status flag,
      not a physical key - but some Mac keyboards
      do have a power key."""
    comptime SCANCODE_KP_EQUALS = Self(103)
    comptime SCANCODE_F13 = Self(104)
    comptime SCANCODE_F14 = Self(105)
    comptime SCANCODE_F15 = Self(106)
    comptime SCANCODE_F16 = Self(107)
    comptime SCANCODE_F17 = Self(108)
    comptime SCANCODE_F18 = Self(109)
    comptime SCANCODE_F19 = Self(110)
    comptime SCANCODE_F20 = Self(111)
    comptime SCANCODE_F21 = Self(112)
    comptime SCANCODE_F22 = Self(113)
    comptime SCANCODE_F23 = Self(114)
    comptime SCANCODE_F24 = Self(115)
    comptime SCANCODE_EXECUTE = Self(116)
    comptime SCANCODE_HELP = Self(117)
    """AL Integrated Help Center."""
    comptime SCANCODE_MENU = Self(118)
    """Menu (show menu)."""
    comptime SCANCODE_SELECT = Self(119)
    comptime SCANCODE_STOP = Self(120)
    """AC Stop."""
    comptime SCANCODE_AGAIN = Self(121)
    """AC Redo/Repeat."""
    comptime SCANCODE_UNDO = Self(122)
    """AC Undo."""
    comptime SCANCODE_CUT = Self(123)
    """AC Cut."""
    comptime SCANCODE_COPY = Self(124)
    """AC Copy."""
    comptime SCANCODE_PASTE = Self(125)
    """AC Paste."""
    comptime SCANCODE_FIND = Self(126)
    """AC Find."""
    comptime SCANCODE_MUTE = Self(127)
    comptime SCANCODE_VOLUMEUP = Self(128)
    comptime SCANCODE_VOLUMEDOWN = Self(129)
    # not sure whether there's a reason to enable these
    # SDL_SCANCODE_LOCKINGCAPSLOCK = 130,
    # SDL_SCANCODE_LOCKINGNUMLOCK = 131,
    # SDL_SCANCODE_LOCKINGSCROLLLOCK = 132,
    comptime SCANCODE_KP_COMMA = Self(133)
    comptime SCANCODE_KP_EQUALSAS400 = Self(134)

    comptime SCANCODE_INTERNATIONAL1 = Self(135)
    """Used on Asian keyboards, see
                                                footnotes in USB doc."""
    comptime SCANCODE_INTERNATIONAL2 = Self(136)
    comptime SCANCODE_INTERNATIONAL3 = Self(137)
    """Yen."""
    comptime SCANCODE_INTERNATIONAL4 = Self(138)
    comptime SCANCODE_INTERNATIONAL5 = Self(139)
    comptime SCANCODE_INTERNATIONAL6 = Self(140)
    comptime SCANCODE_INTERNATIONAL7 = Self(141)
    comptime SCANCODE_INTERNATIONAL8 = Self(142)
    comptime SCANCODE_INTERNATIONAL9 = Self(143)
    comptime SCANCODE_LANG1 = Self(144)
    """Hangul/English toggle."""
    comptime SCANCODE_LANG2 = Self(145)
    """Hanja conversion."""
    comptime SCANCODE_LANG3 = Self(146)
    """Katakana."""
    comptime SCANCODE_LANG4 = Self(147)
    """Hiragana."""
    comptime SCANCODE_LANG5 = Self(148)
    """Zenkaku/Hankaku."""
    comptime SCANCODE_LANG6 = Self(149)
    """Reserved."""
    comptime SCANCODE_LANG7 = Self(150)
    """Reserved."""
    comptime SCANCODE_LANG8 = Self(151)
    """Reserved."""
    comptime SCANCODE_LANG9 = Self(152)
    """Reserved."""

    comptime SCANCODE_ALTERASE = Self(153)
    """Erase-Eaze."""
    comptime SCANCODE_SYSREQ = Self(154)
    comptime SCANCODE_CANCEL = Self(155)
    """AC Cancel."""
    comptime SCANCODE_CLEAR = Self(156)
    comptime SCANCODE_PRIOR = Self(157)
    comptime SCANCODE_RETURN2 = Self(158)
    comptime SCANCODE_SEPARATOR = Self(159)
    comptime SCANCODE_OUT = Self(160)
    comptime SCANCODE_OPER = Self(161)
    comptime SCANCODE_CLEARAGAIN = Self(162)
    comptime SCANCODE_CRSEL = Self(163)
    comptime SCANCODE_EXSEL = Self(164)

    comptime SCANCODE_KP_00 = Self(176)
    comptime SCANCODE_KP_000 = Self(177)
    comptime SCANCODE_THOUSANDSSEPARATOR = Self(178)
    comptime SCANCODE_DECIMALSEPARATOR = Self(179)
    comptime SCANCODE_CURRENCYUNIT = Self(180)
    comptime SCANCODE_CURRENCYSUBUNIT = Self(181)
    comptime SCANCODE_KP_LEFTPAREN = Self(182)
    comptime SCANCODE_KP_RIGHTPAREN = Self(183)
    comptime SCANCODE_KP_LEFTBRACE = Self(184)
    comptime SCANCODE_KP_RIGHTBRACE = Self(185)
    comptime SCANCODE_KP_TAB = Self(186)
    comptime SCANCODE_KP_BACKSPACE = Self(187)
    comptime SCANCODE_KP_A = Self(188)
    comptime SCANCODE_KP_B = Self(189)
    comptime SCANCODE_KP_C = Self(190)
    comptime SCANCODE_KP_D = Self(191)
    comptime SCANCODE_KP_E = Self(192)
    comptime SCANCODE_KP_F = Self(193)
    comptime SCANCODE_KP_XOR = Self(194)
    comptime SCANCODE_KP_POWER = Self(195)
    comptime SCANCODE_KP_PERCENT = Self(196)
    comptime SCANCODE_KP_LESS = Self(197)
    comptime SCANCODE_KP_GREATER = Self(198)
    comptime SCANCODE_KP_AMPERSAND = Self(199)
    comptime SCANCODE_KP_DBLAMPERSAND = Self(200)
    comptime SCANCODE_KP_VERTICALBAR = Self(201)
    comptime SCANCODE_KP_DBLVERTICALBAR = Self(202)
    comptime SCANCODE_KP_COLON = Self(203)
    comptime SCANCODE_KP_HASH = Self(204)
    comptime SCANCODE_KP_SPACE = Self(205)
    comptime SCANCODE_KP_AT = Self(206)
    comptime SCANCODE_KP_EXCLAM = Self(207)
    comptime SCANCODE_KP_MEMSTORE = Self(208)
    comptime SCANCODE_KP_MEMRECALL = Self(209)
    comptime SCANCODE_KP_MEMCLEAR = Self(210)
    comptime SCANCODE_KP_MEMADD = Self(211)
    comptime SCANCODE_KP_MEMSUBTRACT = Self(212)
    comptime SCANCODE_KP_MEMMULTIPLY = Self(213)
    comptime SCANCODE_KP_MEMDIVIDE = Self(214)
    comptime SCANCODE_KP_PLUSMINUS = Self(215)
    comptime SCANCODE_KP_CLEAR = Self(216)
    comptime SCANCODE_KP_CLEARENTRY = Self(217)
    comptime SCANCODE_KP_BINARY = Self(218)
    comptime SCANCODE_KP_OCTAL = Self(219)
    comptime SCANCODE_KP_DECIMAL = Self(220)
    comptime SCANCODE_KP_HEXADECIMAL = Self(221)

    comptime SCANCODE_LCTRL = Self(224)
    comptime SCANCODE_LSHIFT = Self(225)
    comptime SCANCODE_LALT = Self(226)
    """Alt, option."""
    comptime SCANCODE_LGUI = Self(227)
    """Windows, command (apple), meta."""
    comptime SCANCODE_RCTRL = Self(228)
    comptime SCANCODE_RSHIFT = Self(229)
    comptime SCANCODE_RALT = Self(230)
    """Alt gr, option."""
    comptime SCANCODE_RGUI = Self(231)
    """Windows, command (apple), meta."""

    comptime SCANCODE_MODE = Self(257)
    """I'm not sure if this is really not covered
      by any of the above, but since there's a
      special SDL_KMOD_MODE for it I'm adding it here."""

    # *  \name Usage page 0x0C
    #      *
    #      *  These values are mapped from usage page 0x0C (USB consumer page).
    #      *
    #      *  There are way more keys in the spec than we can represent in the
    #      *  current scancode range, so pick the ones that commonly come up in
    #      *  real world usage.

    comptime SCANCODE_SLEEP = Self(258)
    """Sleep."""
    comptime SCANCODE_WAKE = Self(259)
    """Wake."""

    comptime SCANCODE_CHANNEL_INCREMENT = Self(260)
    """Channel Increment."""
    comptime SCANCODE_CHANNEL_DECREMENT = Self(261)
    """Channel Decrement."""

    comptime SCANCODE_MEDIA_PLAY = Self(262)
    """Play."""
    comptime SCANCODE_MEDIA_PAUSE = Self(263)
    """Pause."""
    comptime SCANCODE_MEDIA_RECORD = Self(264)
    """Record."""
    comptime SCANCODE_MEDIA_FAST_FORWARD = Self(265)
    """Fast Forward."""
    comptime SCANCODE_MEDIA_REWIND = Self(266)
    """Rewind."""
    comptime SCANCODE_MEDIA_NEXT_TRACK = Self(267)
    """Next Track."""
    comptime SCANCODE_MEDIA_PREVIOUS_TRACK = Self(268)
    """Previous Track."""
    comptime SCANCODE_MEDIA_STOP = Self(269)
    """Stop."""
    comptime SCANCODE_MEDIA_EJECT = Self(270)
    """Eject."""
    comptime SCANCODE_MEDIA_PLAY_PAUSE = Self(271)
    """Play / Pause."""
    comptime SCANCODE_MEDIA_SELECT = Self(272)
    """Media Select."""

    comptime SCANCODE_AC_NEW = Self(273)
    """AC New."""
    comptime SCANCODE_AC_OPEN = Self(274)
    """AC Open."""
    comptime SCANCODE_AC_CLOSE = Self(275)
    """AC Close."""
    comptime SCANCODE_AC_EXIT = Self(276)
    """AC Exit."""
    comptime SCANCODE_AC_SAVE = Self(277)
    """AC Save."""
    comptime SCANCODE_AC_PRINT = Self(278)
    """AC Print."""
    comptime SCANCODE_AC_PROPERTIES = Self(279)
    """AC Properties."""

    comptime SCANCODE_AC_SEARCH = Self(280)
    """AC Search."""
    comptime SCANCODE_AC_HOME = Self(281)
    """AC Home."""
    comptime SCANCODE_AC_BACK = Self(282)
    """AC Back."""
    comptime SCANCODE_AC_FORWARD = Self(283)
    """AC Forward."""
    comptime SCANCODE_AC_STOP = Self(284)
    """AC Stop."""
    comptime SCANCODE_AC_REFRESH = Self(285)
    """AC Refresh."""
    comptime SCANCODE_AC_BOOKMARKS = Self(286)
    """AC Bookmarks."""

    # *  \name Mobile keys
    #      *
    #      *  These are values that are often used on mobile phones.

    comptime SCANCODE_SOFTLEFT = Self(287)
    """Usually situated below the display on phones and
                                          used as a multi-function feature key for selecting
                                          a software defined function shown on the bottom left
                                          of the display."""
    comptime SCANCODE_SOFTRIGHT = Self(288)
    """Usually situated below the display on phones and
                                           used as a multi-function feature key for selecting
                                           a software defined function shown on the bottom right
                                           of the display."""
    comptime SCANCODE_CALL = Self(289)
    """Used for accepting phone calls."""
    comptime SCANCODE_ENDCALL = Self(290)
    """Used for rejecting phone calls."""

    # Add any other keys here.

    comptime SCANCODE_RESERVED = Self(400)
    """400-500 reserved for dynamic keycodes."""

    comptime SCANCODE_COUNT = Self(512)
    """Not a key, just marks the number of scancodes for array bounds."""
