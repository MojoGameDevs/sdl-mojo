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

"""Pixels

SDL offers facilities for pixel management.

Largely these facilities deal with pixel _format_: what does this set of
bits represent?

If you mostly want to think of a pixel as some combination of red, green,
blue, and maybe alpha intensities, this is all pretty straightforward, and
in many cases, is enough information to build a perfectly fine game.

However, the actual definition of a pixel is more complex than that:

Pixels are a representation of a color in a particular color space.

The first characteristic of a color space is the color type. SDL
understands two different color types, RGB and YCbCr, or in SDL also
referred to as YUV.

RGB colors consist of red, green, and blue channels of color that are added
together to represent the colors we see on the screen.

https://en.wikipedia.org/wiki/RGB_color_model

YCbCr colors represent colors as a Y luma brightness component and red and
blue chroma color offsets. This color representation takes advantage of the
fact that the human eye is more sensitive to brightness than the color in
an image. The Cb and Cr components are often compressed and have lower
resolution than the luma component.

https://en.wikipedia.org/wiki/YCbCr

When the color information in YCbCr is compressed, the Y pixels are left at
full resolution and each Cr and Cb pixel represents an average of the color
information in a block of Y pixels. The chroma location determines where in
that block of pixels the color information is coming from.

The color range defines how much of the pixel to use when converting a
pixel into a color on the display. When the full color range is used, the
entire numeric range of the pixel bits is significant. When narrow color
range is used, for historical reasons, the pixel uses only a portion of the
numeric range to represent colors.

The color primaries and white point are a definition of the colors in the
color space relative to the standard XYZ color space.

https://en.wikipedia.org/wiki/CIE_1931_color_space

The transfer characteristic, or opto-electrical transfer function (OETF),
is the way a color is converted from mathematically linear space into a
non-linear output signals.

https://en.wikipedia.org/wiki/Rec._709#Transfer_characteristics

The matrix coefficients are used to convert between YCbCr and RGB colors.
"""


@register_passable("trivial")
struct SDL_PixelType(Intable):
    """Pixel type.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PixelType.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_PIXELTYPE_UNKNOWN = 0
    alias SDL_PIXELTYPE_INDEX1 = 1
    alias SDL_PIXELTYPE_INDEX4 = 2
    alias SDL_PIXELTYPE_INDEX8 = 3
    alias SDL_PIXELTYPE_PACKED8 = 4
    alias SDL_PIXELTYPE_PACKED16 = 5
    alias SDL_PIXELTYPE_PACKED32 = 6
    alias SDL_PIXELTYPE_ARRAYU8 = 7
    alias SDL_PIXELTYPE_ARRAYU16 = 8
    alias SDL_PIXELTYPE_ARRAYU32 = 9
    alias SDL_PIXELTYPE_ARRAYF16 = 10
    alias SDL_PIXELTYPE_ARRAYF32 = 11
    # appended at the end for compatibility with sdl2-compat:
    alias SDL_PIXELTYPE_INDEX2 = 12


@register_passable("trivial")
struct SDL_BitmapOrder(Intable):
    """Bitmap pixel order, high bit -> low bit.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BitmapOrder.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_BITMAPORDER_NONE = 0
    alias SDL_BITMAPORDER_4321 = 1
    alias SDL_BITMAPORDER_1234 = 2


@register_passable("trivial")
struct SDL_PackedOrder(Intable):
    """Packed component order, high bit -> low bit.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PackedOrder.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_PACKEDORDER_NONE = 0
    alias SDL_PACKEDORDER_XRGB = 1
    alias SDL_PACKEDORDER_RGBX = 2
    alias SDL_PACKEDORDER_ARGB = 3
    alias SDL_PACKEDORDER_RGBA = 4
    alias SDL_PACKEDORDER_XBGR = 5
    alias SDL_PACKEDORDER_BGRX = 6
    alias SDL_PACKEDORDER_ABGR = 7
    alias SDL_PACKEDORDER_BGRA = 8


@register_passable("trivial")
struct SDL_ArrayOrder(Intable):
    """Array component order, low byte -> high byte.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ArrayOrder.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_ARRAYORDER_NONE = 0
    alias SDL_ARRAYORDER_RGB = 1
    alias SDL_ARRAYORDER_RGBA = 2
    alias SDL_ARRAYORDER_ARGB = 3
    alias SDL_ARRAYORDER_BGR = 4
    alias SDL_ARRAYORDER_BGRA = 5
    alias SDL_ARRAYORDER_ABGR = 6


@register_passable("trivial")
struct SDL_PackedLayout(Intable):
    """Packed component layout.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PackedLayout.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_PACKEDLAYOUT_NONE = 0
    alias SDL_PACKEDLAYOUT_332 = 1
    alias SDL_PACKEDLAYOUT_4444 = 2
    alias SDL_PACKEDLAYOUT_1555 = 3
    alias SDL_PACKEDLAYOUT_5551 = 4
    alias SDL_PACKEDLAYOUT_565 = 5
    alias SDL_PACKEDLAYOUT_8888 = 6
    alias SDL_PACKEDLAYOUT_2101010 = 7
    alias SDL_PACKEDLAYOUT_1010102 = 8


@register_passable("trivial")
struct SDL_PixelFormat(Intable):
    """Pixel format.

    SDL's pixel formats have the following naming convention:

    - Names with a list of components and a single bit count, such as RGB24 and
      ABGR32, define a platform-independent encoding into bytes in the order
      specified. For example, in RGB24 data, each pixel is encoded in 3 bytes
      (red, green, blue) in that order, and in ABGR32 data, each pixel is
      encoded in 4 bytes (alpha, blue, green, red) in that order. Use these
      names if the property of a format that is important to you is the order
      of the bytes in memory or on disk.
    - Names with a bit count per component, such as ARGB8888 and XRGB1555, are
      "packed" into an appropriately-sized integer in the platform's native
      endianness. For example, ARGB8888 is a sequence of 32-bit integers; in
      each integer, the most significant bits are alpha, and the least
      significant bits are blue. On a little-endian CPU such as x86, the least
      significant bits of each integer are arranged first in memory, but on a
      big-endian CPU such as s390x, the most significant bits are arranged
      first. Use these names if the property of a format that is important to
      you is the meaning of each bit position within a native-endianness
      integer.
    - In indexed formats such as INDEX4LSB, each pixel is represented by
      encoding an index into the palette into the indicated number of bits,
      with multiple pixels packed into each byte if appropriate. In LSB
      formats, the first (leftmost) pixel is stored in the least-significant
      bits of the byte; in MSB formats, it's stored in the most-significant
      bits. INDEX8 does not need LSB/MSB variants, because each pixel exactly
      fills one byte.

    The 32-bit byte-array encodings such as RGBA32 are aliases for the
    appropriate 8888 encoding for the current platform. For example, RGBA32 is
    an alias for ABGR8888 on little-endian CPUs like x86, or an alias for
    RGBA8888 on big-endian CPUs.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PixelFormat.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_PIXELFORMAT_UNKNOWN = 0
    alias SDL_PIXELFORMAT_INDEX1LSB = 0x11100100
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1, SDL_BITMAPORDER_4321, 0, 1, 0),
    alias SDL_PIXELFORMAT_INDEX1MSB = 0x11200100
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1, SDL_BITMAPORDER_1234, 0, 1, 0),
    alias SDL_PIXELFORMAT_INDEX2LSB = 0x1C100200
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX2, SDL_BITMAPORDER_4321, 0, 2, 0),
    alias SDL_PIXELFORMAT_INDEX2MSB = 0x1C200200
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX2, SDL_BITMAPORDER_1234, 0, 2, 0),
    alias SDL_PIXELFORMAT_INDEX4LSB = 0x12100400
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4, SDL_BITMAPORDER_4321, 0, 4, 0),
    alias SDL_PIXELFORMAT_INDEX4MSB = 0x12200400
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4, SDL_BITMAPORDER_1234, 0, 4, 0),
    alias SDL_PIXELFORMAT_INDEX8 = 0x13000801
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX8, 0, 0, 8, 1),
    alias SDL_PIXELFORMAT_RGB332 = 0x14110801
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED8, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_332, 8, 1),
    alias SDL_PIXELFORMAT_XRGB4444 = 0x15120C02
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_4444, 12, 2),
    alias SDL_PIXELFORMAT_XBGR4444 = 0x15520C02
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_4444, 12, 2),
    alias SDL_PIXELFORMAT_XRGB1555 = 0x15130F02
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_1555, 15, 2),
    alias SDL_PIXELFORMAT_XBGR1555 = 0x15530F02
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_1555, 15, 2),
    alias SDL_PIXELFORMAT_ARGB4444 = 0x15321002
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_4444, 16, 2),
    alias SDL_PIXELFORMAT_RGBA4444 = 0x15421002
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_4444, 16, 2),
    alias SDL_PIXELFORMAT_ABGR4444 = 0x15721002
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_4444, 16, 2),
    alias SDL_PIXELFORMAT_BGRA4444 = 0x15821002
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_4444, 16, 2),
    alias SDL_PIXELFORMAT_ARGB1555 = 0x15331002
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_1555, 16, 2),
    alias SDL_PIXELFORMAT_RGBA5551 = 0x15441002
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_5551, 16, 2),
    alias SDL_PIXELFORMAT_ABGR1555 = 0x15731002
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_1555, 16, 2),
    alias SDL_PIXELFORMAT_BGRA5551 = 0x15841002
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_5551, 16, 2),
    alias SDL_PIXELFORMAT_RGB565 = 0x15151002
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_565, 16, 2),
    alias SDL_PIXELFORMAT_BGR565 = 0x15551002
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_565, 16, 2),
    alias SDL_PIXELFORMAT_RGB24 = 0x17101803
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8, SDL_ARRAYORDER_RGB, 0, 24, 3),
    alias SDL_PIXELFORMAT_BGR24 = 0x17401803
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8, SDL_ARRAYORDER_BGR, 0, 24, 3),
    alias SDL_PIXELFORMAT_XRGB8888 = 0x16161804
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_8888, 24, 4),
    alias SDL_PIXELFORMAT_RGBX8888 = 0x16261804
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBX, SDL_PACKEDLAYOUT_8888, 24, 4),
    alias SDL_PIXELFORMAT_XBGR8888 = 0x16561804
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_8888, 24, 4),
    alias SDL_PIXELFORMAT_BGRX8888 = 0x16661804
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_BGRX, SDL_PACKEDLAYOUT_8888, 24, 4),
    alias SDL_PIXELFORMAT_ARGB8888 = 0x16362004
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_8888, 32, 4),
    alias SDL_PIXELFORMAT_RGBA8888 = 0x16462004
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_8888, 32, 4),
    alias SDL_PIXELFORMAT_ABGR8888 = 0x16762004
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_8888, 32, 4),
    alias SDL_PIXELFORMAT_BGRA8888 = 0x16862004
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_8888, 32, 4),
    alias SDL_PIXELFORMAT_XRGB2101010 = 0x16172004
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_2101010, 32, 4),
    alias SDL_PIXELFORMAT_XBGR2101010 = 0x16572004
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_2101010, 32, 4),
    alias SDL_PIXELFORMAT_ARGB2101010 = 0x16372004
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_2101010, 32, 4),
    alias SDL_PIXELFORMAT_ABGR2101010 = 0x16772004
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_2101010, 32, 4),
    alias SDL_PIXELFORMAT_RGB48 = 0x18103006
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_RGB, 0, 48, 6),
    alias SDL_PIXELFORMAT_BGR48 = 0x18403006
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_BGR, 0, 48, 6),
    alias SDL_PIXELFORMAT_RGBA64 = 0x18204008
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_RGBA, 0, 64, 8),
    alias SDL_PIXELFORMAT_ARGB64 = 0x18304008
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_ARGB, 0, 64, 8),
    alias SDL_PIXELFORMAT_BGRA64 = 0x18504008
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_BGRA, 0, 64, 8),
    alias SDL_PIXELFORMAT_ABGR64 = 0x18604008
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_ABGR, 0, 64, 8),
    alias SDL_PIXELFORMAT_RGB48_FLOAT = 0x1A103006
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_RGB, 0, 48, 6),
    alias SDL_PIXELFORMAT_BGR48_FLOAT = 0x1A403006
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_BGR, 0, 48, 6),
    alias SDL_PIXELFORMAT_RGBA64_FLOAT = 0x1A204008
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_RGBA, 0, 64, 8),
    alias SDL_PIXELFORMAT_ARGB64_FLOAT = 0x1A304008
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_ARGB, 0, 64, 8),
    alias SDL_PIXELFORMAT_BGRA64_FLOAT = 0x1A504008
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_BGRA, 0, 64, 8),
    alias SDL_PIXELFORMAT_ABGR64_FLOAT = 0x1A604008
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_ABGR, 0, 64, 8),
    alias SDL_PIXELFORMAT_RGB96_FLOAT = 0x1B10600C
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_RGB, 0, 96, 12),
    alias SDL_PIXELFORMAT_BGR96_FLOAT = 0x1B40600C
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_BGR, 0, 96, 12),
    alias SDL_PIXELFORMAT_RGBA128_FLOAT = 0x1B208010
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_RGBA, 0, 128, 16),
    alias SDL_PIXELFORMAT_ARGB128_FLOAT = 0x1B308010
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_ARGB, 0, 128, 16),
    alias SDL_PIXELFORMAT_BGRA128_FLOAT = 0x1B508010
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_BGRA, 0, 128, 16),
    alias SDL_PIXELFORMAT_ABGR128_FLOAT = 0x1B608010
    # SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_ABGR, 0, 128, 16),

    alias SDL_PIXELFORMAT_YV12 = 0x32315659
    """Planar mode: Y + V + U  (3 planes)."""
    # SDL_DEFINE_PIXELFOURCC('Y', 'V', '1', '2'),
    alias SDL_PIXELFORMAT_IYUV = 0x56555949
    """Planar mode: Y + U + V  (3 planes)."""
    # SDL_DEFINE_PIXELFOURCC('I', 'Y', 'U', 'V'),
    alias SDL_PIXELFORMAT_YUY2 = 0x32595559
    """Packed mode: Y0+U0+Y1+V0 (1 plane)."""
    # SDL_DEFINE_PIXELFOURCC('Y', 'U', 'Y', '2'),
    alias SDL_PIXELFORMAT_UYVY = 0x59565955
    """Packed mode: U0+Y0+V0+Y1 (1 plane)."""
    # SDL_DEFINE_PIXELFOURCC('U', 'Y', 'V', 'Y'),
    alias SDL_PIXELFORMAT_YVYU = 0x55595659
    """Packed mode: Y0+V0+Y1+U0 (1 plane)."""
    # SDL_DEFINE_PIXELFOURCC('Y', 'V', 'Y', 'U'),
    alias SDL_PIXELFORMAT_NV12 = 0x3231564E
    """Planar mode: Y + U/V interleaved  (2 planes)."""
    # SDL_DEFINE_PIXELFOURCC('N', 'V', '1', '2'),
    alias SDL_PIXELFORMAT_NV21 = 0x3132564E
    """Planar mode: Y + V/U interleaved  (2 planes)."""
    # SDL_DEFINE_PIXELFOURCC('N', 'V', '2', '1'),
    alias SDL_PIXELFORMAT_P010 = 0x30313050
    """Planar mode: Y + U/V interleaved  (2 planes)."""
    # SDL_DEFINE_PIXELFOURCC('P', '0', '1', '0'),
    alias SDL_PIXELFORMAT_EXTERNAL_OES = 0x2053454F
    """Android video texture format."""
    # SDL_DEFINE_PIXELFOURCC('O', 'E', 'S', ' ')

    alias SDL_PIXELFORMAT_MJPG = 0x47504A4D
    """Motion JPEG."""
    # SDL_DEFINE_PIXELFOURCC('M', 'J', 'P', 'G')

    # Aliases for RGBA byte arrays of color data, for the current platform
    alias SDL_PIXELFORMAT_RGBA32 = Self.SDL_PIXELFORMAT_RGBA8888 if is_big_endian() else Self.SDL_PIXELFORMAT_ABGR8888
    alias SDL_PIXELFORMAT_ARGB32 = Self.SDL_PIXELFORMAT_ARGB8888 if is_big_endian() else Self.SDL_PIXELFORMAT_BGRA8888
    alias SDL_PIXELFORMAT_BGRA32 = Self.SDL_PIXELFORMAT_BGRA8888 if is_big_endian() else Self.SDL_PIXELFORMAT_ARGB8888
    alias SDL_PIXELFORMAT_ABGR32 = Self.SDL_PIXELFORMAT_ABGR8888 if is_big_endian() else Self.SDL_PIXELFORMAT_RGBA8888
    alias SDL_PIXELFORMAT_RGBX32 = Self.SDL_PIXELFORMAT_RGBX8888 if is_big_endian() else Self.SDL_PIXELFORMAT_XBGR8888
    alias SDL_PIXELFORMAT_XRGB32 = Self.SDL_PIXELFORMAT_XRGB8888 if is_big_endian() else Self.SDL_PIXELFORMAT_BGRX8888
    alias SDL_PIXELFORMAT_BGRX32 = Self.SDL_PIXELFORMAT_BGRX8888 if is_big_endian() else Self.SDL_PIXELFORMAT_XRGB8888
    alias SDL_PIXELFORMAT_XBGR32 = Self.SDL_PIXELFORMAT_XBGR8888 if is_big_endian() else Self.SDL_PIXELFORMAT_RGBX8888


@register_passable("trivial")
struct SDL_ColorType(Intable):
    """Colorspace color type.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ColorType.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_COLOR_TYPE_UNKNOWN = 0
    alias SDL_COLOR_TYPE_RGB = 1
    alias SDL_COLOR_TYPE_YCBCR = 2


@register_passable("trivial")
struct SDL_ColorRange(Intable):
    """Colorspace color range, as described by
    https://www.itu.int/rec/R-REC-BT.2100-2-201807-I/en.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ColorRange.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_COLOR_RANGE_UNKNOWN = 0
    alias SDL_COLOR_RANGE_LIMITED = 1
    """Narrow range, e.g. 16-235 for 8-bit RGB and luma, and 16-240 for 8-bit chroma."""
    alias SDL_COLOR_RANGE_FULL = 2
    """Full range, e.g. 0-255 for 8-bit RGB and luma, and 1-255 for 8-bit chroma."""


@register_passable("trivial")
struct SDL_ColorPrimaries(Intable):
    """Colorspace color primaries, as described by
    https://www.itu.int/rec/T-REC-H.273-201612-S/en.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ColorPrimaries.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_COLOR_PRIMARIES_UNKNOWN = 0
    alias SDL_COLOR_PRIMARIES_BT709 = 1
    """ITU-R BT.709-6."""
    alias SDL_COLOR_PRIMARIES_UNSPECIFIED = 2
    alias SDL_COLOR_PRIMARIES_BT470M = 4
    """ITU-R BT.470-6 System M."""
    alias SDL_COLOR_PRIMARIES_BT470BG = 5
    """ITU-R BT.470-6 System B, G / ITU-R BT.601-7 625."""
    alias SDL_COLOR_PRIMARIES_BT601 = 6
    """ITU-R BT.601-7 525, SMPTE 170M."""
    alias SDL_COLOR_PRIMARIES_SMPTE240 = 7
    """SMPTE 240M, functionally the same as SDL_COLOR_PRIMARIES_BT601."""
    alias SDL_COLOR_PRIMARIES_GENERIC_FILM = 8
    """Generic film (color filters using Illuminant C)."""
    alias SDL_COLOR_PRIMARIES_BT2020 = 9
    """ITU-R BT.2020-2 / ITU-R BT.2100-0."""
    alias SDL_COLOR_PRIMARIES_XYZ = 10
    """SMPTE ST 428-1."""
    alias SDL_COLOR_PRIMARIES_SMPTE431 = 11
    """SMPTE RP 431-2."""
    alias SDL_COLOR_PRIMARIES_SMPTE432 = 12
    """SMPTE EG 432-1 / DCI P3."""
    alias SDL_COLOR_PRIMARIES_EBU3213 = 22
    """EBU Tech. 3213-E."""
    alias SDL_COLOR_PRIMARIES_CUSTOM = 31


@register_passable("trivial")
struct SDL_TransferCharacteristics(Intable):
    """Colorspace transfer characteristics.

    These are as described by https://www.itu.int/rec/T-REC-H.273-201612-S/en

    Docs: https://wiki.libsdl.org/SDL3/SDL_TransferCharacteristics.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_TRANSFER_CHARACTERISTICS_UNKNOWN = 0
    alias SDL_TRANSFER_CHARACTERISTICS_BT709 = 1
    """Rec. ITU-R BT.709-6 / ITU-R BT1361."""
    alias SDL_TRANSFER_CHARACTERISTICS_UNSPECIFIED = 2
    alias SDL_TRANSFER_CHARACTERISTICS_GAMMA22 = 4
    """ITU-R BT.470-6 System M / ITU-R BT1700 625 PAL & SECAM."""
    alias SDL_TRANSFER_CHARACTERISTICS_GAMMA28 = 5
    """ITU-R BT.470-6 System B, G."""
    alias SDL_TRANSFER_CHARACTERISTICS_BT601 = 6
    """SMPTE ST 170M / ITU-R BT.601-7 525 or 625."""
    alias SDL_TRANSFER_CHARACTERISTICS_SMPTE240 = 7
    """SMPTE ST 240M."""
    alias SDL_TRANSFER_CHARACTERISTICS_LINEAR = 8
    alias SDL_TRANSFER_CHARACTERISTICS_LOG100 = 9
    alias SDL_TRANSFER_CHARACTERISTICS_LOG100_SQRT10 = 10
    alias SDL_TRANSFER_CHARACTERISTICS_IEC61966 = 11
    """IEC 61966-2-4."""
    alias SDL_TRANSFER_CHARACTERISTICS_BT1361 = 12
    """ITU-R BT1361 Extended Colour Gamut."""
    alias SDL_TRANSFER_CHARACTERISTICS_SRGB = 13
    """IEC 61966-2-1 (sRGB or sYCC)."""
    alias SDL_TRANSFER_CHARACTERISTICS_BT2020_10BIT = 14
    """ITU-R BT2020 for 10-bit system."""
    alias SDL_TRANSFER_CHARACTERISTICS_BT2020_12BIT = 15
    """ITU-R BT2020 for 12-bit system."""
    alias SDL_TRANSFER_CHARACTERISTICS_PQ = 16
    """SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems."""
    alias SDL_TRANSFER_CHARACTERISTICS_SMPTE428 = 17
    """SMPTE ST 428-1."""
    alias SDL_TRANSFER_CHARACTERISTICS_HLG = 18
    """ARIB STD-B67, known as "hybrid log-gamma" (HLG)."""
    alias SDL_TRANSFER_CHARACTERISTICS_CUSTOM = 31


@register_passable("trivial")
struct SDL_MatrixCoefficients(Intable):
    """Colorspace matrix coefficients.

    These are as described by https://www.itu.int/rec/T-REC-H.273-201612-S/en

    Docs: https://wiki.libsdl.org/SDL3/SDL_MatrixCoefficients.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_MATRIX_COEFFICIENTS_IDENTITY = 0
    alias SDL_MATRIX_COEFFICIENTS_BT709 = 1
    """ITU-R BT.709-6."""
    alias SDL_MATRIX_COEFFICIENTS_UNSPECIFIED = 2
    alias SDL_MATRIX_COEFFICIENTS_FCC = 4
    """US FCC Title 47."""
    alias SDL_MATRIX_COEFFICIENTS_BT470BG = 5
    """ITU-R BT.470-6 System B, G / ITU-R BT.601-7 625, functionally the same as SDL_MATRIX_COEFFICIENTS_BT601."""
    alias SDL_MATRIX_COEFFICIENTS_BT601 = 6
    """ITU-R BT.601-7 525."""
    alias SDL_MATRIX_COEFFICIENTS_SMPTE240 = 7
    """SMPTE 240M."""
    alias SDL_MATRIX_COEFFICIENTS_YCGCO = 8
    alias SDL_MATRIX_COEFFICIENTS_BT2020_NCL = 9
    """ITU-R BT.2020-2 non-constant luminance."""
    alias SDL_MATRIX_COEFFICIENTS_BT2020_CL = 10
    """ITU-R BT.2020-2 constant luminance."""
    alias SDL_MATRIX_COEFFICIENTS_SMPTE2085 = 11
    """SMPTE ST 2085."""
    alias SDL_MATRIX_COEFFICIENTS_CHROMA_DERIVED_NCL = 12
    alias SDL_MATRIX_COEFFICIENTS_CHROMA_DERIVED_CL = 13
    alias SDL_MATRIX_COEFFICIENTS_ICTCP = 14
    """ITU-R BT.2100-0 ICTCP."""
    alias SDL_MATRIX_COEFFICIENTS_CUSTOM = 31


@register_passable("trivial")
struct SDL_ChromaLocation(Intable):
    """Colorspace chroma sample location.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ChromaLocation.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_CHROMA_LOCATION_NONE = 0
    """RGB, no chroma sampling."""
    alias SDL_CHROMA_LOCATION_LEFT = 1
    """In MPEG-2, MPEG-4, and AVC, Cb and Cr are taken on midpoint of the left-edge of the 2x2 square. In other words, they have the same horizontal location as the top-left pixel, but is shifted one-half pixel down vertically."""
    alias SDL_CHROMA_LOCATION_CENTER = 2
    """In JPEG/JFIF, H.261, and MPEG-1, Cb and Cr are taken at the center of the 2x2 square. In other words, they are offset one-half pixel to the right and one-half pixel down compared to the top-left pixel."""
    alias SDL_CHROMA_LOCATION_TOPLEFT = 3
    """In HEVC for BT.2020 and BT.2100 content (in particular on Blu-rays), Cb and Cr are sampled at the same location as the group's top-left Y pixel ("co-sited", "co-located")."""


@register_passable("trivial")
struct SDL_Colorspace(Intable):
    """Colorspace definitions.

    Since similar colorspaces may vary in their details (matrix, transfer
    function, etc.), this is not an exhaustive list, but rather a
    representative sample of the kinds of colorspaces supported in SDL.

    Docs: https://wiki.libsdl.org/SDL3/SDL_Colorspace.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_COLORSPACE_UNKNOWN = 0

    # sRGB is a gamma corrected colorspace, and the default colorspace for SDL rendering and 8-bit RGB surfaces
    alias SDL_COLORSPACE_SRGB = 0x120005A0
    """Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709."""
    # SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_RGB,
    #                                  SDL_COLOR_RANGE_FULL,
    #                                  SDL_COLOR_PRIMARIES_BT709,
    #                                  SDL_TRANSFER_CHARACTERISTICS_SRGB,
    #                                  SDL_MATRIX_COEFFICIENTS_IDENTITY,
    #                                  SDL_CHROMA_LOCATION_NONE),

    # This is a linear colorspace and the default colorspace for floating point surfaces. On Windows this is the scRGB colorspace, and on Apple platforms this is kCGColorSpaceExtendedLinearSRGB for EDR content
    alias SDL_COLORSPACE_SRGB_LINEAR = 0x12000500
    """Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G10_NONE_P709."""
    # SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_RGB,
    #                                  SDL_COLOR_RANGE_FULL,
    #                                  SDL_COLOR_PRIMARIES_BT709,
    #                                  SDL_TRANSFER_CHARACTERISTICS_LINEAR,
    #                                  SDL_MATRIX_COEFFICIENTS_IDENTITY,
    #                                  SDL_CHROMA_LOCATION_NONE),

    # HDR10 is a non-linear HDR colorspace and the default colorspace for 10-bit surfaces
    alias SDL_COLORSPACE_HDR10 = 0x12002600
    """Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020."""
    # SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_RGB,
    #                                  SDL_COLOR_RANGE_FULL,
    #                                  SDL_COLOR_PRIMARIES_BT2020,
    #                                  SDL_TRANSFER_CHARACTERISTICS_PQ,
    #                                  SDL_MATRIX_COEFFICIENTS_IDENTITY,
    #                                  SDL_CHROMA_LOCATION_NONE),

    alias SDL_COLORSPACE_JPEG = 0x220004C6
    """Equivalent to DXGI_COLOR_SPACE_YCBCR_FULL_G22_NONE_P709_X601."""
    # SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    #                                  SDL_COLOR_RANGE_FULL,
    #                                  SDL_COLOR_PRIMARIES_BT709,
    #                                  SDL_TRANSFER_CHARACTERISTICS_BT601,
    #                                  SDL_MATRIX_COEFFICIENTS_BT601,
    #                                  SDL_CHROMA_LOCATION_NONE),

    alias SDL_COLORSPACE_BT601_LIMITED = 0x211018C6
    """Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601."""
    # SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    #                                  SDL_COLOR_RANGE_LIMITED,
    #                                  SDL_COLOR_PRIMARIES_BT601,
    #                                  SDL_TRANSFER_CHARACTERISTICS_BT601,
    #                                  SDL_MATRIX_COEFFICIENTS_BT601,
    #                                  SDL_CHROMA_LOCATION_LEFT),

    alias SDL_COLORSPACE_BT601_FULL = 0x221018C6
    """Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601."""
    # SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    #                                  SDL_COLOR_RANGE_FULL,
    #                                  SDL_COLOR_PRIMARIES_BT601,
    #                                  SDL_TRANSFER_CHARACTERISTICS_BT601,
    #                                  SDL_MATRIX_COEFFICIENTS_BT601,
    #                                  SDL_CHROMA_LOCATION_LEFT),

    alias SDL_COLORSPACE_BT709_LIMITED = 0x21100421
    """Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709."""
    # SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    #                                  SDL_COLOR_RANGE_LIMITED,
    #                                  SDL_COLOR_PRIMARIES_BT709,
    #                                  SDL_TRANSFER_CHARACTERISTICS_BT709,
    #                                  SDL_MATRIX_COEFFICIENTS_BT709,
    #                                  SDL_CHROMA_LOCATION_LEFT),

    alias SDL_COLORSPACE_BT709_FULL = 0x22100421
    """Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709."""
    # SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    #                                  SDL_COLOR_RANGE_FULL,
    #                                  SDL_COLOR_PRIMARIES_BT709,
    #                                  SDL_TRANSFER_CHARACTERISTICS_BT709,
    #                                  SDL_MATRIX_COEFFICIENTS_BT709,
    #                                  SDL_CHROMA_LOCATION_LEFT),

    alias SDL_COLORSPACE_BT2020_LIMITED = 0x21102609
    """Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P2020."""
    # SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    #                                  SDL_COLOR_RANGE_LIMITED,
    #                                  SDL_COLOR_PRIMARIES_BT2020,
    #                                  SDL_TRANSFER_CHARACTERISTICS_PQ,
    #                                  SDL_MATRIX_COEFFICIENTS_BT2020_NCL,
    #                                  SDL_CHROMA_LOCATION_LEFT),

    alias SDL_COLORSPACE_BT2020_FULL = 0x22102609
    """Equivalent to DXGI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P2020."""
    # SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    #                                  SDL_COLOR_RANGE_FULL,
    #                                  SDL_COLOR_PRIMARIES_BT2020,
    #                                  SDL_TRANSFER_CHARACTERISTICS_PQ,
    #                                  SDL_MATRIX_COEFFICIENTS_BT2020_NCL,
    #                                  SDL_CHROMA_LOCATION_LEFT),

    alias SDL_COLORSPACE_RGB_DEFAULT = Self.SDL_COLORSPACE_SRGB
    """The default colorspace for RGB surfaces if no colorspace is specified."""
    alias SDL_COLORSPACE_YUV_DEFAULT = Self.SDL_COLORSPACE_JPEG
    """The default colorspace for YUV surfaces if no colorspace is specified."""


@fieldwise_init
struct SDL_Color(Copyable, Movable):
    """A structure that represents a color as RGBA components.

    The bits of this structure can be directly reinterpreted as an
    integer-packed color which uses the SDL_PIXELFORMAT_RGBA32 format
    (SDL_PIXELFORMAT_ABGR8888 on little-endian systems and
    SDL_PIXELFORMAT_RGBA8888 on big-endian systems).

    Docs: https://wiki.libsdl.org/SDL3/SDL_Color.
    """

    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8


@fieldwise_init
struct SDL_FColor(Copyable, Movable):
    """The bits of this structure can be directly reinterpreted as a float-packed
    color which uses the SDL_PIXELFORMAT_RGBA128_FLOAT format.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FColor.
    """

    var r: c_float
    var g: c_float
    var b: c_float
    var a: c_float


@fieldwise_init
struct SDL_Palette(Copyable, Movable):
    """A set of indexed colors representing a palette.

    Docs: https://wiki.libsdl.org/SDL3/SDL_Palette.
    """

    var ncolors: c_int
    """Number of elements in `colors`."""
    var colors: Ptr[SDL_Color, mut=True]
    """An array of colors, `ncolors` long."""
    var version: UInt32
    """Internal use only, do not touch."""
    var refcount: c_int
    """Internal use only, do not touch."""


@fieldwise_init
struct SDL_PixelFormatDetails(Copyable, Movable):
    """Details about the format of a pixel.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PixelFormatDetails.
    """

    var format: SDL_PixelFormat
    var bits_per_pixel: UInt8
    var bytes_per_pixel: UInt8
    var padding: ArrayHelper[UInt8, 2, mut=True].result
    var rmask: UInt32
    var gmask: UInt32
    var bmask: UInt32
    var amask: UInt32
    var rbits: UInt8
    var gbits: UInt8
    var bbits: UInt8
    var abits: UInt8
    var rshift: UInt8
    var gshift: UInt8
    var bshift: UInt8
    var ashift: UInt8


fn sdl_get_pixel_format_name(format: SDL_PixelFormat) -> Ptr[c_char, mut=False]:
    """Get the human readable name of a pixel format.

    Args:
        format: The pixel format to query.

    Returns:
        The human readable name of the specified pixel format or
        "SDL_PIXELFORMAT_UNKNOWN" if the format isn't recognized.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPixelFormatName.
    """

    return _get_dylib_function[lib, "SDL_GetPixelFormatName", fn (format: SDL_PixelFormat) -> Ptr[c_char, mut=False]]()(format)


fn sdl_get_masks_for_pixel_format(format: SDL_PixelFormat, bpp: Ptr[c_int, mut=True], rmask: Ptr[UInt32, mut=True], gmask: Ptr[UInt32, mut=True], bmask: Ptr[UInt32, mut=True], amask: Ptr[UInt32, mut=True]) raises:
    """Convert one of the enumerated pixel formats to a bpp value and RGBA masks.

    Args:
        format: One of the SDL_PixelFormat values.
        bpp: A bits per pixel value; usually 15, 16, or 32.
        rmask: A pointer filled in with the red mask for the format.
        gmask: A pointer filled in with the green mask for the format.
        bmask: A pointer filled in with the blue mask for the format.
        amask: A pointer filled in with the alpha mask for the format.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetMasksForPixelFormat.
    """

    ret = _get_dylib_function[lib, "SDL_GetMasksForPixelFormat", fn (format: SDL_PixelFormat, bpp: Ptr[c_int, mut=True], rmask: Ptr[UInt32, mut=True], gmask: Ptr[UInt32, mut=True], bmask: Ptr[UInt32, mut=True], amask: Ptr[UInt32, mut=True]) -> Bool]()(format, bpp, rmask, gmask, bmask, amask)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_get_pixel_format_for_masks(bpp: c_int, rmask: UInt32, gmask: UInt32, bmask: UInt32, amask: UInt32) -> SDL_PixelFormat:
    """Convert a bpp value and RGBA masks to an enumerated pixel format.

    This will return `SDL_PIXELFORMAT_UNKNOWN` if the conversion wasn't
    possible.

    Args:
        bpp: A bits per pixel value; usually 15, 16, or 32.
        rmask: The red mask for the format.
        gmask: The green mask for the format.
        bmask: The blue mask for the format.
        amask: The alpha mask for the format.

    Returns:
        The SDL_PixelFormat value corresponding to the format masks, or
        SDL_PIXELFORMAT_UNKNOWN if there isn't a match.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPixelFormatForMasks.
    """

    return _get_dylib_function[lib, "SDL_GetPixelFormatForMasks", fn (bpp: c_int, rmask: UInt32, gmask: UInt32, bmask: UInt32, amask: UInt32) -> SDL_PixelFormat]()(bpp, rmask, gmask, bmask, amask)


fn sdl_get_pixel_format_details(format: SDL_PixelFormat) -> Ptr[SDL_PixelFormatDetails, mut=False]:
    """Create an SDL_PixelFormatDetails structure corresponding to a pixel format.

    Returned structure may come from a shared global cache (i.e. not newly
    allocated), and hence should not be modified, especially the palette. Weird
    errors such as `Blit combination not supported` may occur.

    Args:
        format: One of the SDL_PixelFormat values.

    Returns:
        A pointer to a SDL_PixelFormatDetails structure or NULL on
        failure; call SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPixelFormatDetails.
    """

    return _get_dylib_function[lib, "SDL_GetPixelFormatDetails", fn (format: SDL_PixelFormat) -> Ptr[SDL_PixelFormatDetails, mut=False]]()(format)


fn sdl_create_palette(ncolors: c_int) -> Ptr[SDL_Palette, mut=True]:
    """Create a palette structure with the specified number of color entries.

    The palette entries are initialized to white.

    Args:
        ncolors: Represents the number of color entries in the color palette.

    Returns:
        A new SDL_Palette structure on success or NULL on failure (e.g. if
        there wasn't enough memory); call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreatePalette.
    """

    return _get_dylib_function[lib, "SDL_CreatePalette", fn (ncolors: c_int) -> Ptr[SDL_Palette, mut=True]]()(ncolors)


fn sdl_set_palette_colors(palette: Ptr[SDL_Palette, mut=True], colors: Ptr[SDL_Color, mut=False], firstcolor: c_int, ncolors: c_int) raises:
    """Set a range of colors in a palette.

    Args:
        palette: The SDL_Palette structure to modify.
        colors: An array of SDL_Color structures to copy into the palette.
        firstcolor: The index of the first palette entry to modify.
        ncolors: The number of entries to modify.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread, as long as
        the palette is not modified or destroyed in another thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetPaletteColors.
    """

    ret = _get_dylib_function[lib, "SDL_SetPaletteColors", fn (palette: Ptr[SDL_Palette, mut=True], colors: Ptr[SDL_Color, mut=False], firstcolor: c_int, ncolors: c_int) -> Bool]()(palette, colors, firstcolor, ncolors)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_destroy_palette(palette: Ptr[SDL_Palette, mut=True]) -> None:
    """Free a palette created with SDL_CreatePalette().

    Args:
        palette: The SDL_Palette structure to be freed.

    Safety:
        It is safe to call this function from any thread, as long as
        the palette is not modified or destroyed in another thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyPalette.
    """

    return _get_dylib_function[lib, "SDL_DestroyPalette", fn (palette: Ptr[SDL_Palette, mut=True]) -> None]()(palette)


fn sdl_map_rgb(format: Ptr[SDL_PixelFormatDetails, mut=False], palette: Ptr[SDL_Palette, mut=False], r: UInt8, g: UInt8, b: UInt8) -> UInt32:
    """Map an RGB triple to an opaque pixel value for a given pixel format.

    This function maps the RGB color value to the specified pixel format and
    returns the pixel value best approximating the given RGB color value for
    the given pixel format.

    If the format has a palette (8-bit) the index of the closest matching color
    in the palette will be returned.

    If the specified pixel format has an alpha component it will be returned as
    all 1 bits (fully opaque).

    If the pixel format bpp (color depth) is less than 32-bpp then the unused
    upper bits of the return value can safely be ignored (e.g., with a 16-bpp
    format the return value can be assigned to a Uint16, and similarly a Uint8
    for an 8-bpp format).

    Args:
        format: A pointer to SDL_PixelFormatDetails describing the pixel
                format.
        palette: An optional palette for indexed formats, may be NULL.
        r: The red component of the pixel in the range 0-255.
        g: The green component of the pixel in the range 0-255.
        b: The blue component of the pixel in the range 0-255.

    Returns:
        A pixel value.

    Safety:
        It is safe to call this function from any thread, as long as
        the palette is not modified.

    Docs: https://wiki.libsdl.org/SDL3/SDL_MapRGB.
    """

    return _get_dylib_function[lib, "SDL_MapRGB", fn (format: Ptr[SDL_PixelFormatDetails, mut=False], palette: Ptr[SDL_Palette, mut=False], r: UInt8, g: UInt8, b: UInt8) -> UInt32]()(format, palette, r, g, b)


fn sdl_map_rgba(format: Ptr[SDL_PixelFormatDetails, mut=False], palette: Ptr[SDL_Palette, mut=False], r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> UInt32:
    """Map an RGBA quadruple to a pixel value for a given pixel format.

    This function maps the RGBA color value to the specified pixel format and
    returns the pixel value best approximating the given RGBA color value for
    the given pixel format.

    If the specified pixel format has no alpha component the alpha value will
    be ignored (as it will be in formats with a palette).

    If the format has a palette (8-bit) the index of the closest matching color
    in the palette will be returned.

    If the pixel format bpp (color depth) is less than 32-bpp then the unused
    upper bits of the return value can safely be ignored (e.g., with a 16-bpp
    format the return value can be assigned to a Uint16, and similarly a Uint8
    for an 8-bpp format).

    Args:
        format: A pointer to SDL_PixelFormatDetails describing the pixel
                format.
        palette: An optional palette for indexed formats, may be NULL.
        r: The red component of the pixel in the range 0-255.
        g: The green component of the pixel in the range 0-255.
        b: The blue component of the pixel in the range 0-255.
        a: The alpha component of the pixel in the range 0-255.

    Returns:
        A pixel value.

    Safety:
        It is safe to call this function from any thread, as long as
        the palette is not modified.

    Docs: https://wiki.libsdl.org/SDL3/SDL_MapRGBA.
    """

    return _get_dylib_function[lib, "SDL_MapRGBA", fn (format: Ptr[SDL_PixelFormatDetails, mut=False], palette: Ptr[SDL_Palette, mut=False], r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> UInt32]()(format, palette, r, g, b, a)


fn sdl_get_rgb(pixel: UInt32, format: Ptr[SDL_PixelFormatDetails, mut=False], palette: Ptr[SDL_Palette, mut=False], r: Ptr[UInt8, mut=True], g: Ptr[UInt8, mut=True], b: Ptr[UInt8, mut=True]) -> None:
    """Get RGB values from a pixel in the specified format.

    This function uses the entire 8-bit [0..255] range when converting color
    components from pixel formats with less than 8-bits per RGB component
    (e.g., a completely white pixel in 16-bit RGB565 format would return [0xff,
    0xff, 0xff] not [0xf8, 0xfc, 0xf8]).

    Args:
        pixel: A pixel value.
        format: A pointer to SDL_PixelFormatDetails describing the pixel
                format.
        palette: An optional palette for indexed formats, may be NULL.
        r: A pointer filled in with the red component, may be NULL.
        g: A pointer filled in with the green component, may be NULL.
        b: A pointer filled in with the blue component, may be NULL.

    Safety:
        It is safe to call this function from any thread, as long as
        the palette is not modified.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRGB.
    """

    return _get_dylib_function[lib, "SDL_GetRGB", fn (pixel: UInt32, format: Ptr[SDL_PixelFormatDetails, mut=False], palette: Ptr[SDL_Palette, mut=False], r: Ptr[UInt8, mut=True], g: Ptr[UInt8, mut=True], b: Ptr[UInt8, mut=True]) -> None]()(pixel, format, palette, r, g, b)


fn sdl_get_rgba(pixel: UInt32, format: Ptr[SDL_PixelFormatDetails, mut=False], palette: Ptr[SDL_Palette, mut=False], r: Ptr[UInt8, mut=True], g: Ptr[UInt8, mut=True], b: Ptr[UInt8, mut=True], a: Ptr[UInt8, mut=True]) -> None:
    """Get RGBA values from a pixel in the specified format.

    This function uses the entire 8-bit [0..255] range when converting color
    components from pixel formats with less than 8-bits per RGB component
    (e.g., a completely white pixel in 16-bit RGB565 format would return [0xff,
    0xff, 0xff] not [0xf8, 0xfc, 0xf8]).

    If the surface has no alpha component, the alpha will be returned as 0xff
    (100% opaque).

    Args:
        pixel: A pixel value.
        format: A pointer to SDL_PixelFormatDetails describing the pixel
                format.
        palette: An optional palette for indexed formats, may be NULL.
        r: A pointer filled in with the red component, may be NULL.
        g: A pointer filled in with the green component, may be NULL.
        b: A pointer filled in with the blue component, may be NULL.
        a: A pointer filled in with the alpha component, may be NULL.

    Safety:
        It is safe to call this function from any thread, as long as
        the palette is not modified.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRGBA.
    """

    return _get_dylib_function[lib, "SDL_GetRGBA", fn (pixel: UInt32, format: Ptr[SDL_PixelFormatDetails, mut=False], palette: Ptr[SDL_Palette, mut=False], r: Ptr[UInt8, mut=True], g: Ptr[UInt8, mut=True], b: Ptr[UInt8, mut=True], a: Ptr[UInt8, mut=True]) -> None]()(pixel, format, palette, r, g, b, a)
