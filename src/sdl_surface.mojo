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

"""Surface

SDL surfaces are buffers of pixels in system RAM. These are useful for
passing around and manipulating images that are not stored in GPU memory.

SDL_Surface makes serious efforts to manage images in various formats, and
provides a reasonable toolbox for transforming the data, including copying
between surfaces, filling rectangles in the image data, etc.

There is also a simple .bmp loader, SDL_LoadBMP(). SDL itself does not
provide loaders for various other file formats, but there are several
excellent external libraries that do, including its own satellite library,
SDL_image:

https://github.com/libsdl-org/SDL_image
"""


@register_passable("trivial")
struct SurfaceFlags(Intable):
    """The flags on an SDL_Surface.

    These are generally considered read-only.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SurfaceFlags.
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

    comptime SURFACE_PREALLOCATED = Self(0x00000001)
    """Surface uses preallocated pixel memory."""
    comptime SURFACE_LOCK_NEEDED = Self(0x00000002)
    """Surface needs to be locked to access pixels."""
    comptime SURFACE_LOCKED = Self(0x00000004)
    """Surface is currently locked."""
    comptime SURFACE_SIMD_ALIGNED = Self(0x00000008)
    """Surface uses pixel memory allocated with SDL_aligned_alloc()."""


@register_passable("trivial")
struct ScaleMode(Indexer, Intable):
    """The scaling mode.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ScaleMode.
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

    comptime SCALEMODE_INVALID = Self(-1)
    comptime SCALEMODE_NEAREST = Self(0)
    """Nearest pixel sampling."""
    comptime SCALEMODE_LINEAR = Self(1)
    """Linear filtering."""


@register_passable("trivial")
struct FlipMode(Indexer, Intable):
    """The flip mode.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FlipMode.
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

    comptime FLIP_NONE = Self(0)
    """Do not flip."""
    comptime FLIP_HORIZONTAL = Self(1)
    """Flip horizontally."""
    comptime FLIP_VERTICAL = Self(2)
    """Flip vertically."""


@fieldwise_init
struct Surface(ImplicitlyCopyable, Movable):
    """A collection of pixels used in software blitting.

    Pixels are arranged in memory in rows, with the top row first. Each row
    occupies an amount of memory given by the pitch (sometimes known as the row
    stride in non-SDL APIs).

    Within each row, pixels are arranged from left to right until the width is
    reached. Each pixel occupies a number of bits appropriate for its format,
    with most formats representing each pixel as one or more whole bytes (in
    some indexed formats, instead multiple pixels are packed into each byte),
    and a byte order given by the format. After encoding all pixels, any
    remaining bytes to reach the pitch are used as padding to reach a desired
    alignment, and have undefined contents.

    When a surface holds YUV format data, the planes are assumed to be
    contiguous without padding between them, e.g. a 32x32 surface in NV12
    format with a pitch of 32 would consist of 32x32 bytes of Y plane followed
    by 32x16 bytes of UV plane.

    When a surface holds MJPG format data, pixels points at the compressed JPEG
    image and pitch is the length of that data.

    Docs: https://wiki.libsdl.org/SDL3/SDL_Surface.
    """

    var flags: SurfaceFlags
    """The flags of the surface, read-only."""
    var format: PixelFormat
    """The format of the surface, read-only."""
    var w: c_int
    """The width of the surface, read-only."""
    var h: c_int
    """The height of the surface, read-only."""
    var pitch: c_int
    """The distance in bytes between rows of pixels, read-only."""
    var pixels: Ptr[NoneType, AnyOrigin[True]]
    """A pointer to the pixels of the surface, the pixels are writeable if non-NULL."""

    var refcount: c_int
    """Application reference count, used when freeing surface."""

    var reserved: Ptr[NoneType, AnyOrigin[True]]
    """Reserved for internal use."""


fn create_surface(width: c_int, height: c_int, format: PixelFormat, out ret: Ptr[Surface, AnyOrigin[True]]) raises:
    """Allocate a new surface with a specific pixel format.

    The pixels of the new surface are initialized to zero.

    Args:
        width: The width of the surface.
        height: The height of the surface.
        format: The SDL_PixelFormat for the new surface's pixel format.

    Returns:
        The new SDL_Surface structure that is created or NULL on failure;
        call SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateSurface.
    """

    ret = _get_dylib_function[lib, "SDL_CreateSurface", fn (width: c_int, height: c_int, format: PixelFormat) -> Ptr[Surface, AnyOrigin[True]]]()(width, height, format)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_surface_from(width: c_int, height: c_int, format: PixelFormat, pixels: Ptr[NoneType, AnyOrigin[True]], pitch: c_int, out ret: Ptr[Surface, AnyOrigin[True]]) raises:
    """Allocate a new surface with a specific pixel format and existing pixel
    data.

    No copy is made of the pixel data. Pixel data is not managed automatically;
    you must free the surface before you free the pixel data.

    Pitch is the offset in bytes from one row of pixels to the next, e.g.
    `width*4` for `SDL_PIXELFORMAT_RGBA8888`.

    You may pass NULL for pixels and 0 for pitch to create a surface that you
    will fill in with valid values later.

    Args:
        width: The width of the surface.
        height: The height of the surface.
        format: The SDL_PixelFormat for the new surface's pixel format.
        pixels: A pointer to existing pixel data.
        pitch: The number of bytes between each row, including padding.

    Returns:
        The new SDL_Surface structure that is created or NULL on failure;
        call SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateSurfaceFrom.
    """

    ret = _get_dylib_function[lib, "SDL_CreateSurfaceFrom", fn (width: c_int, height: c_int, format: PixelFormat, pixels: Ptr[NoneType, AnyOrigin[True]], pitch: c_int) -> Ptr[Surface, AnyOrigin[True]]]()(width, height, format, pixels, pitch)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn destroy_surface(surface: Ptr[Surface, AnyOrigin[True]]) raises -> None:
    """Free a surface.

    It is safe to pass NULL to this function.

    Args:
        surface: The SDL_Surface to free.

    Safety:
        No other thread should be using the surface when it is freed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroySurface.
    """

    return _get_dylib_function[lib, "SDL_DestroySurface", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> None]()(surface)


fn get_surface_properties(surface: Ptr[Surface, AnyOrigin[True]]) raises -> PropertiesID:
    """Get the properties associated with a surface.

    The following properties are understood by SDL:

    - `SDL_PROP_SURFACE_SDR_WHITE_POINT_FLOAT`: for HDR10 and floating point
      surfaces, this defines the value of 100% diffuse white, with higher
      values being displayed in the High Dynamic Range headroom. This defaults
      to 203 for HDR10 surfaces and 1.0 for floating point surfaces.
    - `SDL_PROP_SURFACE_HDR_HEADROOM_FLOAT`: for HDR10 and floating point
      surfaces, this defines the maximum dynamic range used by the content, in
      terms of the SDR white point. This defaults to 0.0, which disables tone
      mapping.
    - `SDL_PROP_SURFACE_TONEMAP_OPERATOR_STRING`: the tone mapping operator
      used when compressing from a surface with high dynamic range to another
      with lower dynamic range. Currently this supports "chrome", which uses
      the same tone mapping that Chrome uses for HDR content, the form "*=N",
      where N is a floating point scale factor applied in linear space, and
      "none", which disables tone mapping. This defaults to "chrome".
    - `SDL_PROP_SURFACE_HOTSPOT_X_NUMBER`: the hotspot pixel offset from the
      left edge of the image, if this surface is being used as a cursor.
    - `SDL_PROP_SURFACE_HOTSPOT_Y_NUMBER`: the hotspot pixel offset from the
      top edge of the image, if this surface is being used as a cursor.

    Args:
        surface: The SDL_Surface structure to query.

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSurfaceProperties.
    """

    return _get_dylib_function[lib, "SDL_GetSurfaceProperties", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> PropertiesID]()(surface)


fn set_surface_colorspace(surface: Ptr[Surface, AnyOrigin[True]], colorspace: Colorspace) raises:
    """Set the colorspace used by a surface.

    Setting the colorspace doesn't change the pixels, only how they are
    interpreted in color operations.

    Args:
        surface: The SDL_Surface structure to update.
        colorspace: An SDL_Colorspace value describing the surface
                    colorspace.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetSurfaceColorspace.
    """

    ret = _get_dylib_function[lib, "SDL_SetSurfaceColorspace", fn (surface: Ptr[Surface, AnyOrigin[True]], colorspace: Colorspace) -> Bool]()(surface, colorspace)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_surface_colorspace(surface: Ptr[Surface, AnyOrigin[True]]) raises -> Colorspace:
    """Get the colorspace used by a surface.

    The colorspace defaults to SDL_COLORSPACE_SRGB_LINEAR for floating point
    formats, SDL_COLORSPACE_HDR10 for 10-bit formats, SDL_COLORSPACE_SRGB for
    other RGB surfaces and SDL_COLORSPACE_BT709_FULL for YUV textures.

    Args:
        surface: The SDL_Surface structure to query.

    Returns:
        The colorspace used by the surface, or SDL_COLORSPACE_UNKNOWN if
        the surface is NULL.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSurfaceColorspace.
    """

    return _get_dylib_function[lib, "SDL_GetSurfaceColorspace", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> Colorspace]()(surface)


fn create_surface_palette(surface: Ptr[Surface, AnyOrigin[True]]) raises -> Ptr[Palette, AnyOrigin[True]]:
    """Create a palette and associate it with a surface.

    This function creates a palette compatible with the provided surface. The
    palette is then returned for you to modify, and the surface will
    automatically use the new palette in future operations. You do not need to
    destroy the returned palette, it will be freed when the reference count
    reaches 0, usually when the surface is destroyed.

    Bitmap surfaces (with format SDL_PIXELFORMAT_INDEX1LSB or
    SDL_PIXELFORMAT_INDEX1MSB) will have the palette initialized with 0 as
    white and 1 as black. Other surfaces will get a palette initialized with
    white in every entry.

    If this function is called for a surface that already has a palette, a new
    palette will be created to replace it.

    Args:
        surface: The SDL_Surface structure to update.

    Returns:
        A new SDL_Palette structure on success or NULL on failure (e.g. if
        the surface didn't have an index format); call SDL_GetError() for
        more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateSurfacePalette.
    """

    return _get_dylib_function[lib, "SDL_CreateSurfacePalette", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> Ptr[Palette, AnyOrigin[True]]]()(surface)


fn set_surface_palette(surface: Ptr[Surface, AnyOrigin[True]], palette: Ptr[Palette, AnyOrigin[True]]) raises:
    """Set the palette used by a surface.

    A single palette can be shared with many surfaces.

    Args:
        surface: The SDL_Surface structure to update.
        palette: The SDL_Palette structure to use.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetSurfacePalette.
    """

    ret = _get_dylib_function[lib, "SDL_SetSurfacePalette", fn (surface: Ptr[Surface, AnyOrigin[True]], palette: Ptr[Palette, AnyOrigin[True]]) -> Bool]()(surface, palette)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_surface_palette(surface: Ptr[Surface, AnyOrigin[True]]) raises -> Ptr[Palette, AnyOrigin[True]]:
    """Get the palette used by a surface.

    Args:
        surface: The SDL_Surface structure to query.

    Returns:
        A pointer to the palette used by the surface, or NULL if there is
        no palette used.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSurfacePalette.
    """

    return _get_dylib_function[lib, "SDL_GetSurfacePalette", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> Ptr[Palette, AnyOrigin[True]]]()(surface)


fn add_surface_alternate_image(surface: Ptr[Surface, AnyOrigin[True]], image: Ptr[Surface, AnyOrigin[True]]) raises:
    """Add an alternate version of a surface.

    This function adds an alternate version of this surface, usually used for
    content with high DPI representations like cursors or icons. The size,
    format, and content do not need to match the original surface, and these
    alternate versions will not be updated when the original surface changes.

    This function adds a reference to the alternate version, so you should call
    SDL_DestroySurface() on the image after this call.

    Args:
        surface: The SDL_Surface structure to update.
        image: A pointer to an alternate SDL_Surface to associate with this
               surface.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AddSurfaceAlternateImage.
    """

    ret = _get_dylib_function[lib, "SDL_AddSurfaceAlternateImage", fn (surface: Ptr[Surface, AnyOrigin[True]], image: Ptr[Surface, AnyOrigin[True]]) -> Bool]()(surface, image)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn surface_has_alternate_images(surface: Ptr[Surface, AnyOrigin[True]]) raises -> Bool:
    """Return whether a surface has alternate versions available.

    Args:
        surface: The SDL_Surface structure to query.

    Returns:
        True if alternate versions are available or false otherwise.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SurfaceHasAlternateImages.
    """

    return _get_dylib_function[lib, "SDL_SurfaceHasAlternateImages", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> Bool]()(surface)


fn get_surface_images(surface: Ptr[Surface, AnyOrigin[True]], count: Ptr[c_int, AnyOrigin[True]]) raises -> Ptr[Ptr[Surface, AnyOrigin[True]], AnyOrigin[True]]:
    """Get an array including all versions of a surface.

    This returns all versions of a surface, with the surface being queried as
    the first element in the returned array.

    Freeing the array of surfaces does not affect the surfaces in the array.
    They are still referenced by the surface being queried and will be cleaned
    up normally.

    Args:
        surface: The SDL_Surface structure to query.
        count: A pointer filled in with the number of surface pointers
               returned, may be NULL.

    Returns:
        A NULL terminated array of SDL_Surface pointers or NULL on
        failure; call SDL_GetError() for more information. This should be
        freed with SDL_free() when it is no longer needed.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSurfaceImages.
    """

    return _get_dylib_function[lib, "SDL_GetSurfaceImages", fn (surface: Ptr[Surface, AnyOrigin[True]], count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[Ptr[Surface, AnyOrigin[True]], AnyOrigin[True]]]()(surface, count)


fn remove_surface_alternate_images(surface: Ptr[Surface, AnyOrigin[True]]) raises -> None:
    """Remove all alternate versions of a surface.

    This function removes a reference from all the alternative versions,
    destroying them if this is the last reference to them.

    Args:
        surface: The SDL_Surface structure to update.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RemoveSurfaceAlternateImages.
    """

    return _get_dylib_function[lib, "SDL_RemoveSurfaceAlternateImages", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> None]()(surface)


fn lock_surface(surface: Ptr[Surface, AnyOrigin[True]]) raises:
    """Set up a surface for directly accessing the pixels.

    Between calls to SDL_LockSurface() / SDL_UnlockSurface(), you can write to
    and read from `surface->pixels`, using the pixel format stored in
    `surface->format`. Once you are done accessing the surface, you should use
    SDL_UnlockSurface() to release it.

    Not all surfaces require locking. If `SDL_MUSTLOCK(surface)` evaluates to
    0, then you can read and write to the surface at any time, and the pixel
    format of the surface will not change.

    Args:
        surface: The SDL_Surface structure to be locked.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe. The locking referred to by
        this function is making the pixels available for direct
        access, not thread-safe locking.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LockSurface.
    """

    ret = _get_dylib_function[lib, "SDL_LockSurface", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> Bool]()(surface)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn unlock_surface(surface: Ptr[Surface, AnyOrigin[True]]) raises -> None:
    """Release a surface after directly accessing the pixels.

    Args:
        surface: The SDL_Surface structure to be unlocked.

    Safety:
        This function is not thread safe. The locking referred to by
        this function is making the pixels available for direct
        access, not thread-safe locking.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UnlockSurface.
    """

    return _get_dylib_function[lib, "SDL_UnlockSurface", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> None]()(surface)


fn load_bmp_io(src: Ptr[IOStream, AnyOrigin[True]], closeio: Bool, out ret: Ptr[Surface, AnyOrigin[True]]) raises:
    """Load a BMP image from a seekable SDL data stream.

    The new surface should be freed with SDL_DestroySurface(). Not doing so
    will result in a memory leak.

    Args:
        src: The data stream for the surface.
        closeio: If true, calls SDL_CloseIO() on `src` before returning, even
                 in the case of an error.

    Returns:
        A pointer to a new SDL_Surface structure or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LoadBMP_IO.
    """

    ret = _get_dylib_function[lib, "SDL_LoadBMP_IO", fn (src: Ptr[IOStream, AnyOrigin[True]], closeio: Bool) -> Ptr[Surface, AnyOrigin[True]]]()(src, closeio)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn load_bmp(var file: String, out ret: Ptr[Surface, AnyOrigin[True]]) raises:
    """Load a BMP image from a file.

    The new surface should be freed with SDL_DestroySurface(). Not doing so
    will result in a memory leak.

    Args:
        file: The BMP file to load.

    Returns:
        A pointer to a new SDL_Surface structure or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LoadBMP.
    """

    ret = _get_dylib_function[lib, "SDL_LoadBMP", fn (file: Ptr[c_char, AnyOrigin[False]]) -> Ptr[Surface, AnyOrigin[True]]]()(file.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn save_bmp_io(surface: Ptr[Surface, AnyOrigin[True]], dst: Ptr[IOStream, AnyOrigin[True]], closeio: Bool) raises:
    """Save a surface to a seekable SDL data stream in BMP format.

    Surfaces with a 24-bit, 32-bit and paletted 8-bit format get saved in the
    BMP directly. Other RGB formats with 8-bit or higher get converted to a
    24-bit surface or, if they have an alpha mask or a colorkey, to a 32-bit
    surface before they are saved. YUV and paletted 1-bit and 4-bit formats are
    not supported.

    Args:
        surface: The SDL_Surface structure containing the image to be saved.
        dst: A data stream to save to.
        closeio: If true, calls SDL_CloseIO() on `dst` before returning, even
                 in the case of an error.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SaveBMP_IO.
    """

    ret = _get_dylib_function[lib, "SDL_SaveBMP_IO", fn (surface: Ptr[Surface, AnyOrigin[True]], dst: Ptr[IOStream, AnyOrigin[True]], closeio: Bool) -> Bool]()(surface, dst, closeio)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn save_bmp(surface: Ptr[Surface, AnyOrigin[True]], var file: String) raises:
    """Save a surface to a file.

    Surfaces with a 24-bit, 32-bit and paletted 8-bit format get saved in the
    BMP directly. Other RGB formats with 8-bit or higher get converted to a
    24-bit surface or, if they have an alpha mask or a colorkey, to a 32-bit
    surface before they are saved. YUV and paletted 1-bit and 4-bit formats are
    not supported.

    Args:
        surface: The SDL_Surface structure containing the image to be saved.
        file: A file to save to.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SaveBMP.
    """

    ret = _get_dylib_function[lib, "SDL_SaveBMP", fn (surface: Ptr[Surface, AnyOrigin[True]], file: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(surface, file.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_surface_rle(surface: Ptr[Surface, AnyOrigin[True]], enabled: Bool) raises:
    """Set the RLE acceleration hint for a surface.

    If RLE is enabled, color key and alpha blending blits are much faster, but
    the surface must be locked before directly accessing the pixels.

    Args:
        surface: The SDL_Surface structure to optimize.
        enabled: True to enable RLE acceleration, false to disable it.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetSurfaceRLE.
    """

    ret = _get_dylib_function[lib, "SDL_SetSurfaceRLE", fn (surface: Ptr[Surface, AnyOrigin[True]], enabled: Bool) -> Bool]()(surface, enabled)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn surface_has_rle(surface: Ptr[Surface, AnyOrigin[True]]) raises -> Bool:
    """Returns whether the surface is RLE enabled.

    It is safe to pass a NULL `surface` here; it will return false.

    Args:
        surface: The SDL_Surface structure to query.

    Returns:
        True if the surface is RLE enabled, false otherwise.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SurfaceHasRLE.
    """

    return _get_dylib_function[lib, "SDL_SurfaceHasRLE", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> Bool]()(surface)


fn set_surface_color_key(surface: Ptr[Surface, AnyOrigin[True]], enabled: Bool, key: UInt32) raises:
    """Set the color key (transparent pixel) in a surface.

    The color key defines a pixel value that will be treated as transparent in
    a blit. For example, one can use this to specify that cyan pixels should be
    considered transparent, and therefore not rendered.

    It is a pixel of the format used by the surface, as generated by
    SDL_MapRGB().

    Args:
        surface: The SDL_Surface structure to update.
        enabled: True to enable color key, false to disable color key.
        key: The transparent pixel.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetSurfaceColorKey.
    """

    ret = _get_dylib_function[lib, "SDL_SetSurfaceColorKey", fn (surface: Ptr[Surface, AnyOrigin[True]], enabled: Bool, key: UInt32) -> Bool]()(surface, enabled, key)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn surface_has_color_key(surface: Ptr[Surface, AnyOrigin[True]]) raises -> Bool:
    """Returns whether the surface has a color key.

    It is safe to pass a NULL `surface` here; it will return false.

    Args:
        surface: The SDL_Surface structure to query.

    Returns:
        True if the surface has a color key, false otherwise.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SurfaceHasColorKey.
    """

    return _get_dylib_function[lib, "SDL_SurfaceHasColorKey", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> Bool]()(surface)


fn get_surface_color_key(surface: Ptr[Surface, AnyOrigin[True]], key: Ptr[UInt32, AnyOrigin[True]]) raises:
    """Get the color key (transparent pixel) for a surface.

    The color key is a pixel of the format used by the surface, as generated by
    SDL_MapRGB().

    If the surface doesn't have color key enabled this function returns false.

    Args:
        surface: The SDL_Surface structure to query.
        key: A pointer filled in with the transparent pixel.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSurfaceColorKey.
    """

    ret = _get_dylib_function[lib, "SDL_GetSurfaceColorKey", fn (surface: Ptr[Surface, AnyOrigin[True]], key: Ptr[UInt32, AnyOrigin[True]]) -> Bool]()(surface, key)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_surface_color_mod(surface: Ptr[Surface, AnyOrigin[True]], r: UInt8, g: UInt8, b: UInt8) raises:
    """Set an additional color value multiplied into blit operations.

    When this surface is blitted, during the blit operation each source color
    channel is modulated by the appropriate color value according to the
    following formula:

    `srcC = srcC * (color / 255)`

    Args:
        surface: The SDL_Surface structure to update.
        r: The red color value multiplied into blit operations.
        g: The green color value multiplied into blit operations.
        b: The blue color value multiplied into blit operations.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetSurfaceColorMod.
    """

    ret = _get_dylib_function[lib, "SDL_SetSurfaceColorMod", fn (surface: Ptr[Surface, AnyOrigin[True]], r: UInt8, g: UInt8, b: UInt8) -> Bool]()(surface, r, g, b)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_surface_color_mod(surface: Ptr[Surface, AnyOrigin[True]], r: Ptr[UInt8, AnyOrigin[True]], g: Ptr[UInt8, AnyOrigin[True]], b: Ptr[UInt8, AnyOrigin[True]]) raises:
    """Get the additional color value multiplied into blit operations.

    Args:
        surface: The SDL_Surface structure to query.
        r: A pointer filled in with the current red color value.
        g: A pointer filled in with the current green color value.
        b: A pointer filled in with the current blue color value.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSurfaceColorMod.
    """

    ret = _get_dylib_function[lib, "SDL_GetSurfaceColorMod", fn (surface: Ptr[Surface, AnyOrigin[True]], r: Ptr[UInt8, AnyOrigin[True]], g: Ptr[UInt8, AnyOrigin[True]], b: Ptr[UInt8, AnyOrigin[True]]) -> Bool]()(surface, r, g, b)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_surface_alpha_mod(surface: Ptr[Surface, AnyOrigin[True]], alpha: UInt8) raises:
    """Set an additional alpha value used in blit operations.

    When this surface is blitted, during the blit operation the source alpha
    value is modulated by this alpha value according to the following formula:

    `srcA = srcA * (alpha / 255)`

    Args:
        surface: The SDL_Surface structure to update.
        alpha: The alpha value multiplied into blit operations.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetSurfaceAlphaMod.
    """

    ret = _get_dylib_function[lib, "SDL_SetSurfaceAlphaMod", fn (surface: Ptr[Surface, AnyOrigin[True]], alpha: UInt8) -> Bool]()(surface, alpha)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_surface_alpha_mod(surface: Ptr[Surface, AnyOrigin[True]], alpha: Ptr[UInt8, AnyOrigin[True]]) raises:
    """Get the additional alpha value used in blit operations.

    Args:
        surface: The SDL_Surface structure to query.
        alpha: A pointer filled in with the current alpha value.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSurfaceAlphaMod.
    """

    ret = _get_dylib_function[lib, "SDL_GetSurfaceAlphaMod", fn (surface: Ptr[Surface, AnyOrigin[True]], alpha: Ptr[UInt8, AnyOrigin[True]]) -> Bool]()(surface, alpha)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_surface_blend_mode(surface: Ptr[Surface, AnyOrigin[True]], blend_mode: BlendMode) raises:
    """Set the blend mode used for blit operations.

    To copy a surface to another surface (or texture) without blending with the
    existing data, the blendmode of the SOURCE surface should be set to
    `SDL_BLENDMODE_NONE`.

    Args:
        surface: The SDL_Surface structure to update.
        blend_mode: The SDL_BlendMode to use for blit blending.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetSurfaceBlendMode.
    """

    ret = _get_dylib_function[lib, "SDL_SetSurfaceBlendMode", fn (surface: Ptr[Surface, AnyOrigin[True]], blend_mode: BlendMode) -> Bool]()(surface, blend_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_surface_blend_mode(surface: Ptr[Surface, AnyOrigin[True]], blend_mode: Ptr[BlendMode, AnyOrigin[True]]) raises:
    """Get the blend mode used for blit operations.

    Args:
        surface: The SDL_Surface structure to query.
        blend_mode: A pointer filled in with the current SDL_BlendMode.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSurfaceBlendMode.
    """

    ret = _get_dylib_function[lib, "SDL_GetSurfaceBlendMode", fn (surface: Ptr[Surface, AnyOrigin[True]], blend_mode: Ptr[BlendMode, AnyOrigin[True]]) -> Bool]()(surface, blend_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_surface_clip_rect(surface: Ptr[Surface, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]]) raises -> Bool:
    """Set the clipping rectangle for a surface.

    When `surface` is the destination of a blit, only the area within the clip
    rectangle is drawn into.

    Note that blits are automatically clipped to the edges of the source and
    destination surfaces.

    Args:
        surface: The SDL_Surface structure to be clipped.
        rect: The SDL_Rect structure representing the clipping rectangle, or
              NULL to disable clipping.

    Returns:
        True if the rectangle intersects the surface, otherwise false and
        blits will be completely clipped.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetSurfaceClipRect.
    """

    return _get_dylib_function[lib, "SDL_SetSurfaceClipRect", fn (surface: Ptr[Surface, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]]) -> Bool]()(surface, rect)


fn get_surface_clip_rect(surface: Ptr[Surface, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]]) raises:
    """Get the clipping rectangle for a surface.

    When `surface` is the destination of a blit, only the area within the clip
    rectangle is drawn into.

    Args:
        surface: The SDL_Surface structure representing the surface to be
                 clipped.
        rect: An SDL_Rect structure filled in with the clipping rectangle for
              the surface.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSurfaceClipRect.
    """

    ret = _get_dylib_function[lib, "SDL_GetSurfaceClipRect", fn (surface: Ptr[Surface, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]]) -> Bool]()(surface, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn flip_surface(surface: Ptr[Surface, AnyOrigin[True]], flip: FlipMode) raises:
    """Flip a surface vertically or horizontally.

    Args:
        surface: The surface to flip.
        flip: The direction to flip.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FlipSurface.
    """

    ret = _get_dylib_function[lib, "SDL_FlipSurface", fn (surface: Ptr[Surface, AnyOrigin[True]], flip: FlipMode) -> Bool]()(surface, flip)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn duplicate_surface(surface: Ptr[Surface, AnyOrigin[True]], out ret: Ptr[Surface, AnyOrigin[True]]) raises:
    """Creates a new surface identical to the existing surface.

    If the original surface has alternate images, the new surface will have a
    reference to them as well.

    The returned surface should be freed with SDL_DestroySurface().

    Args:
        surface: The surface to duplicate.

    Returns:
        A copy of the surface or NULL on failure; call SDL_GetError() for
        more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DuplicateSurface.
    """

    ret = _get_dylib_function[lib, "SDL_DuplicateSurface", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> Ptr[Surface, AnyOrigin[True]]]()(surface)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn scale_surface(surface: Ptr[Surface, AnyOrigin[True]], width: c_int, height: c_int, scale_mode: ScaleMode, out ret: Ptr[Surface, AnyOrigin[True]]) raises:
    """Creates a new surface identical to the existing surface, scaled to the
    desired size.

    The returned surface should be freed with SDL_DestroySurface().

    Args:
        surface: The surface to duplicate and scale.
        width: The width of the new surface.
        height: The height of the new surface.
        scale_mode: The SDL_ScaleMode to be used.

    Returns:
        A copy of the surface or NULL on failure; call SDL_GetError() for
        more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ScaleSurface.
    """

    ret = _get_dylib_function[lib, "SDL_ScaleSurface", fn (surface: Ptr[Surface, AnyOrigin[True]], width: c_int, height: c_int, scale_mode: ScaleMode) -> Ptr[Surface, AnyOrigin[True]]]()(surface, width, height, scale_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn convert_surface(surface: Ptr[Surface, AnyOrigin[True]], format: PixelFormat, out ret: Ptr[Surface, AnyOrigin[True]]) raises:
    """Copy an existing surface to a new surface of the specified format.

    This function is used to optimize images for faster *repeat* blitting. This
    is accomplished by converting the original and storing the result as a new
    surface. The new, optimized surface can then be used as the source for
    future blits, making them faster.

    If you are converting to an indexed surface and want to map colors to a
    palette, you can use SDL_ConvertSurfaceAndColorspace() instead.

    If the original surface has alternate images, the new surface will have a
    reference to them as well.

    Args:
        surface: The existing SDL_Surface structure to convert.
        format: The new pixel format.

    Returns:
        The new SDL_Surface structure that is created or NULL on failure;
        call SDL_GetError() for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ConvertSurface.
    """

    ret = _get_dylib_function[lib, "SDL_ConvertSurface", fn (surface: Ptr[Surface, AnyOrigin[True]], format: PixelFormat) -> Ptr[Surface, AnyOrigin[True]]]()(surface, format)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn convert_surface_and_colorspace(surface: Ptr[Surface, AnyOrigin[True]], format: PixelFormat, palette: Ptr[Palette, AnyOrigin[True]], colorspace: Colorspace, props: PropertiesID, out ret: Ptr[Surface, AnyOrigin[True]]) raises:
    """Copy an existing surface to a new surface of the specified format and
    colorspace.

    This function converts an existing surface to a new format and colorspace
    and returns the new surface. This will perform any pixel format and
    colorspace conversion needed.

    If the original surface has alternate images, the new surface will have a
    reference to them as well.

    Args:
        surface: The existing SDL_Surface structure to convert.
        format: The new pixel format.
        palette: An optional palette to use for indexed formats, may be NULL.
        colorspace: The new colorspace.
        props: An SDL_PropertiesID with additional color properties, or 0.

    Returns:
        The new SDL_Surface structure that is created or NULL on failure;
        call SDL_GetError() for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ConvertSurfaceAndColorspace.
    """

    ret = _get_dylib_function[lib, "SDL_ConvertSurfaceAndColorspace", fn (surface: Ptr[Surface, AnyOrigin[True]], format: PixelFormat, palette: Ptr[Palette, AnyOrigin[True]], colorspace: Colorspace, props: PropertiesID) -> Ptr[Surface, AnyOrigin[True]]]()(surface, format, palette, colorspace, props)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn convert_pixels(width: c_int, height: c_int, src_format: PixelFormat, src: Ptr[NoneType, AnyOrigin[False]], src_pitch: c_int, dst_format: PixelFormat, dst: Ptr[NoneType, AnyOrigin[True]], dst_pitch: c_int) raises:
    """Copy a block of pixels of one format to another format.

    Args:
        width: The width of the block to copy, in pixels.
        height: The height of the block to copy, in pixels.
        src_format: An SDL_PixelFormat value of the `src` pixels format.
        src: A pointer to the source pixels.
        src_pitch: The pitch of the source pixels, in bytes.
        dst_format: An SDL_PixelFormat value of the `dst` pixels format.
        dst: A pointer to be filled in with new pixel data.
        dst_pitch: The pitch of the destination pixels, in bytes.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        The same destination pixels should not be used from two
        threads at once. It is safe to use the same source pixels
        from multiple threads.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ConvertPixels.
    """

    ret = _get_dylib_function[lib, "SDL_ConvertPixels", fn (width: c_int, height: c_int, src_format: PixelFormat, src: Ptr[NoneType, AnyOrigin[False]], src_pitch: c_int, dst_format: PixelFormat, dst: Ptr[NoneType, AnyOrigin[True]], dst_pitch: c_int) -> Bool]()(width, height, src_format, src, src_pitch, dst_format, dst, dst_pitch)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn convert_pixels_and_colorspace(width: c_int, height: c_int, src_format: PixelFormat, src_colorspace: Colorspace, src_properties: PropertiesID, src: Ptr[NoneType, AnyOrigin[False]], src_pitch: c_int, dst_format: PixelFormat, dst_colorspace: Colorspace, dst_properties: PropertiesID, dst: Ptr[NoneType, AnyOrigin[True]], dst_pitch: c_int) raises:
    """Copy a block of pixels of one format and colorspace to another format and
    colorspace.

    Args:
        width: The width of the block to copy, in pixels.
        height: The height of the block to copy, in pixels.
        src_format: An SDL_PixelFormat value of the `src` pixels format.
        src_colorspace: An SDL_Colorspace value describing the colorspace of
                        the `src` pixels.
        src_properties: An SDL_PropertiesID with additional source color
                        properties, or 0.
        src: A pointer to the source pixels.
        src_pitch: The pitch of the source pixels, in bytes.
        dst_format: An SDL_PixelFormat value of the `dst` pixels format.
        dst_colorspace: An SDL_Colorspace value describing the colorspace of
                        the `dst` pixels.
        dst_properties: An SDL_PropertiesID with additional destination color
                        properties, or 0.
        dst: A pointer to be filled in with new pixel data.
        dst_pitch: The pitch of the destination pixels, in bytes.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        The same destination pixels should not be used from two
        threads at once. It is safe to use the same source pixels
        from multiple threads.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ConvertPixelsAndColorspace.
    """

    ret = _get_dylib_function[lib, "SDL_ConvertPixelsAndColorspace", fn (width: c_int, height: c_int, src_format: PixelFormat, src_colorspace: Colorspace, src_properties: PropertiesID, src: Ptr[NoneType, AnyOrigin[False]], src_pitch: c_int, dst_format: PixelFormat, dst_colorspace: Colorspace, dst_properties: PropertiesID, dst: Ptr[NoneType, AnyOrigin[True]], dst_pitch: c_int) -> Bool]()(width, height, src_format, src_colorspace, src_properties, src, src_pitch, dst_format, dst_colorspace, dst_properties, dst, dst_pitch)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn premultiply_alpha(width: c_int, height: c_int, src_format: PixelFormat, src: Ptr[NoneType, AnyOrigin[False]], src_pitch: c_int, dst_format: PixelFormat, dst: Ptr[NoneType, AnyOrigin[True]], dst_pitch: c_int, linear: Bool) raises:
    """Premultiply the alpha on a block of pixels.

    This is safe to use with src == dst, but not for other overlapping areas.

    Args:
        width: The width of the block to convert, in pixels.
        height: The height of the block to convert, in pixels.
        src_format: An SDL_PixelFormat value of the `src` pixels format.
        src: A pointer to the source pixels.
        src_pitch: The pitch of the source pixels, in bytes.
        dst_format: An SDL_PixelFormat value of the `dst` pixels format.
        dst: A pointer to be filled in with premultiplied pixel data.
        dst_pitch: The pitch of the destination pixels, in bytes.
        linear: True to convert from sRGB to linear space for the alpha
                multiplication, false to do multiplication in sRGB space.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        The same destination pixels should not be used from two
        threads at once. It is safe to use the same source pixels
        from multiple threads.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PremultiplyAlpha.
    """

    ret = _get_dylib_function[lib, "SDL_PremultiplyAlpha", fn (width: c_int, height: c_int, src_format: PixelFormat, src: Ptr[NoneType, AnyOrigin[False]], src_pitch: c_int, dst_format: PixelFormat, dst: Ptr[NoneType, AnyOrigin[True]], dst_pitch: c_int, linear: Bool) -> Bool]()(width, height, src_format, src, src_pitch, dst_format, dst, dst_pitch, linear)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn premultiply_surface_alpha(surface: Ptr[Surface, AnyOrigin[True]], linear: Bool) raises:
    """Premultiply the alpha in a surface.

    This is safe to use with src == dst, but not for other overlapping areas.

    Args:
        surface: The surface to modify.
        linear: True to convert from sRGB to linear space for the alpha
                multiplication, false to do multiplication in sRGB space.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PremultiplySurfaceAlpha.
    """

    ret = _get_dylib_function[lib, "SDL_PremultiplySurfaceAlpha", fn (surface: Ptr[Surface, AnyOrigin[True]], linear: Bool) -> Bool]()(surface, linear)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn clear_surface(surface: Ptr[Surface, AnyOrigin[True]], r: c_float, g: c_float, b: c_float, a: c_float) raises:
    """Clear a surface with a specific color, with floating point precision.

    This function handles all surface formats, and ignores any clip rectangle.

    If the surface is YUV, the color is assumed to be in the sRGB colorspace,
    otherwise the color is assumed to be in the colorspace of the suface.

    Args:
        surface: The SDL_Surface to clear.
        r: The red component of the pixel, normally in the range 0-1.
        g: The green component of the pixel, normally in the range 0-1.
        b: The blue component of the pixel, normally in the range 0-1.
        a: The alpha component of the pixel, normally in the range 0-1.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ClearSurface.
    """

    ret = _get_dylib_function[lib, "SDL_ClearSurface", fn (surface: Ptr[Surface, AnyOrigin[True]], r: c_float, g: c_float, b: c_float, a: c_float) -> Bool]()(surface, r, g, b, a)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn fill_surface_rect(dst: Ptr[Surface, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], color: UInt32) raises:
    """Perform a fast fill of a rectangle with a specific color.

    `color` should be a pixel of the format used by the surface, and can be
    generated by SDL_MapRGB() or SDL_MapRGBA(). If the color value contains an
    alpha component then the destination is simply filled with that alpha
    information, no blending takes place.

    If there is a clip rectangle set on the destination (set via
    SDL_SetSurfaceClipRect()), then this function will fill based on the
    intersection of the clip rectangle and `rect`.

    Args:
        dst: The SDL_Surface structure that is the drawing target.
        rect: The SDL_Rect structure representing the rectangle to fill, or
              NULL to fill the entire surface.
        color: The color to fill with.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FillSurfaceRect.
    """

    ret = _get_dylib_function[lib, "SDL_FillSurfaceRect", fn (dst: Ptr[Surface, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], color: UInt32) -> Bool]()(dst, rect, color)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn fill_surface_rects(dst: Ptr[Surface, AnyOrigin[True]], rects: Ptr[Rect, AnyOrigin[False]], count: c_int, color: UInt32) raises:
    """Perform a fast fill of a set of rectangles with a specific color.

    `color` should be a pixel of the format used by the surface, and can be
    generated by SDL_MapRGB() or SDL_MapRGBA(). If the color value contains an
    alpha component then the destination is simply filled with that alpha
    information, no blending takes place.

    If there is a clip rectangle set on the destination (set via
    SDL_SetSurfaceClipRect()), then this function will fill based on the
    intersection of the clip rectangle and `rect`.

    Args:
        dst: The SDL_Surface structure that is the drawing target.
        rects: An array of SDL_Rects representing the rectangles to fill.
        count: The number of rectangles in the array.
        color: The color to fill with.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FillSurfaceRects.
    """

    ret = _get_dylib_function[lib, "SDL_FillSurfaceRects", fn (dst: Ptr[Surface, AnyOrigin[True]], rects: Ptr[Rect, AnyOrigin[False]], count: c_int, color: UInt32) -> Bool]()(dst, rects, count, color)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn blit_surface(src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]]) raises:
    """Performs a fast blit from the source surface to the destination surface
    with clipping.

    If either `srcrect` or `dstrect` are NULL, the entire surface (`src` or
    `dst`) is copied while ensuring clipping to `dst->clip_rect`.

    The blit function should not be called on a locked surface.

    The blit semantics for surfaces with and without blending and colorkey are
    defined as follows:

    ```
       RGBA->RGB:
         Source surface blend mode set to SDL_BLENDMODE_BLEND:
          alpha-blend (using the source alpha-channel and per-surface alpha)
          SDL_SRCCOLORKEY ignored.
        Source surface blend mode set to SDL_BLENDMODE_NONE:
          copy RGB.
          if SDL_SRCCOLORKEY set, only copy the pixels that do not match the
          RGB values of the source color key, ignoring alpha in the
          comparison.

      RGB->RGBA:
        Source surface blend mode set to SDL_BLENDMODE_BLEND:
          alpha-blend (using the source per-surface alpha)
        Source surface blend mode set to SDL_BLENDMODE_NONE:
          copy RGB, set destination alpha to source per-surface alpha value.
        both:
          if SDL_SRCCOLORKEY set, only copy the pixels that do not match the
          source color key.

      RGBA->RGBA:
        Source surface blend mode set to SDL_BLENDMODE_BLEND:
          alpha-blend (using the source alpha-channel and per-surface alpha)
          SDL_SRCCOLORKEY ignored.
        Source surface blend mode set to SDL_BLENDMODE_NONE:
          copy all of RGBA to the destination.
          if SDL_SRCCOLORKEY set, only copy the pixels that do not match the
          RGB values of the source color key, ignoring alpha in the
          comparison.

      RGB->RGB:
        Source surface blend mode set to SDL_BLENDMODE_BLEND:
          alpha-blend (using the source per-surface alpha)
        Source surface blend mode set to SDL_BLENDMODE_NONE:
          copy RGB.
        both:
          if SDL_SRCCOLORKEY set, only copy the pixels that do not match the
          source color key.
    ```

    Args:
        src: The SDL_Surface structure to be copied from.
        srcrect: The SDL_Rect structure representing the rectangle to be
                 copied, or NULL to copy the entire surface.
        dst: The SDL_Surface structure that is the blit target.
        dstrect: The SDL_Rect structure representing the x and y position in
                 the destination surface, or NULL for (0,0). The width and
                 height are ignored, and are copied from `srcrect`. If you
                 want a specific width and height, you should use
                 SDL_BlitSurfaceScaled().

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        Only one thread should be using the `src` and `dst` surfaces
        at any given time.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlitSurface.
    """

    ret = _get_dylib_function[lib, "SDL_BlitSurface", fn (src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]]) -> Bool]()(src, srcrect, dst, dstrect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn blit_surface_unchecked(src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]]) raises:
    """Perform low-level surface blitting only.

    This is a semi-private blit function and it performs low-level surface
    blitting, assuming the input rectangles have already been clipped.

    Args:
        src: The SDL_Surface structure to be copied from.
        srcrect: The SDL_Rect structure representing the rectangle to be
                 copied, may not be NULL.
        dst: The SDL_Surface structure that is the blit target.
        dstrect: The SDL_Rect structure representing the target rectangle in
                 the destination surface, may not be NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        Only one thread should be using the `src` and `dst` surfaces
        at any given time.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlitSurfaceUnchecked.
    """

    ret = _get_dylib_function[lib, "SDL_BlitSurfaceUnchecked", fn (src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]]) -> Bool]()(src, srcrect, dst, dstrect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn blit_surface_scaled(src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]], scale_mode: ScaleMode) raises:
    """Perform a scaled blit to a destination surface, which may be of a different
    format.

    Args:
        src: The SDL_Surface structure to be copied from.
        srcrect: The SDL_Rect structure representing the rectangle to be
                 copied, or NULL to copy the entire surface.
        dst: The SDL_Surface structure that is the blit target.
        dstrect: The SDL_Rect structure representing the target rectangle in
                 the destination surface, or NULL to fill the entire
                 destination surface.
        scale_mode: The SDL_ScaleMode to be used.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        Only one thread should be using the `src` and `dst` surfaces
        at any given time.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlitSurfaceScaled.
    """

    ret = _get_dylib_function[lib, "SDL_BlitSurfaceScaled", fn (src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]], scale_mode: ScaleMode) -> Bool]()(src, srcrect, dst, dstrect, scale_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn blit_surface_unchecked_scaled(src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]], scale_mode: ScaleMode) raises:
    """Perform low-level surface scaled blitting only.

    This is a semi-private function and it performs low-level surface blitting,
    assuming the input rectangles have already been clipped.

    Args:
        src: The SDL_Surface structure to be copied from.
        srcrect: The SDL_Rect structure representing the rectangle to be
                 copied, may not be NULL.
        dst: The SDL_Surface structure that is the blit target.
        dstrect: The SDL_Rect structure representing the target rectangle in
                 the destination surface, may not be NULL.
        scale_mode: The SDL_ScaleMode to be used.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        Only one thread should be using the `src` and `dst` surfaces
        at any given time.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlitSurfaceUncheckedScaled.
    """

    ret = _get_dylib_function[lib, "SDL_BlitSurfaceUncheckedScaled", fn (src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]], scale_mode: ScaleMode) -> Bool]()(src, srcrect, dst, dstrect, scale_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn stretch_surface(src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]], scale_mode: ScaleMode) raises:
    """Perform a stretched pixel copy from one surface to another.

    Args:
        src: The SDL_Surface structure to be copied from.
        srcrect: The SDL_Rect structure representing the rectangle to be
                 copied, or NULL to copy the entire surface.
        dst: The SDL_Surface structure that is the blit target.
        dstrect: The SDL_Rect structure representing the target rectangle in
                 the destination surface, or NULL to fill the entire
                 destination surface.
        scale_mode: The SDL_ScaleMode to be used.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        Only one thread should be using the `src` and `dst` surfaces
        at any given time.

    Docs: https://wiki.libsdl.org/SDL3/SDL_StretchSurface.
    """

    ret = _get_dylib_function[lib, "SDL_StretchSurface", fn (src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]], scale_mode: ScaleMode) -> Bool]()(src, srcrect, dst, dstrect, scale_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn blit_surface_tiled(src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]]) raises:
    """Perform a tiled blit to a destination surface, which may be of a different
    format.

    The pixels in `srcrect` will be repeated as many times as needed to
    completely fill `dstrect`.

    Args:
        src: The SDL_Surface structure to be copied from.
        srcrect: The SDL_Rect structure representing the rectangle to be
                 copied, or NULL to copy the entire surface.
        dst: The SDL_Surface structure that is the blit target.
        dstrect: The SDL_Rect structure representing the target rectangle in
                 the destination surface, or NULL to fill the entire surface.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        Only one thread should be using the `src` and `dst` surfaces
        at any given time.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlitSurfaceTiled.
    """

    ret = _get_dylib_function[lib, "SDL_BlitSurfaceTiled", fn (src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]]) -> Bool]()(src, srcrect, dst, dstrect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn blit_surface_tiled_with_scale(src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], scale: c_float, scale_mode: ScaleMode, dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]]) raises:
    """Perform a scaled and tiled blit to a destination surface, which may be of a
    different format.

    The pixels in `srcrect` will be scaled and repeated as many times as needed
    to completely fill `dstrect`.

    Args:
        src: The SDL_Surface structure to be copied from.
        srcrect: The SDL_Rect structure representing the rectangle to be
                 copied, or NULL to copy the entire surface.
        scale: The scale used to transform srcrect into the destination
               rectangle, e.g. a 32x32 texture with a scale of 2 would fill
               64x64 tiles.
        scale_mode: Scale algorithm to be used.
        dst: The SDL_Surface structure that is the blit target.
        dstrect: The SDL_Rect structure representing the target rectangle in
                 the destination surface, or NULL to fill the entire surface.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        Only one thread should be using the `src` and `dst` surfaces
        at any given time.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlitSurfaceTiledWithScale.
    """

    ret = _get_dylib_function[lib, "SDL_BlitSurfaceTiledWithScale", fn (src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], scale: c_float, scale_mode: ScaleMode, dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]]) -> Bool]()(src, srcrect, scale, scale_mode, dst, dstrect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn blit_surface_9grid(src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], left_width: c_int, right_width: c_int, top_height: c_int, bottom_height: c_int, scale: c_float, scale_mode: ScaleMode, dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]]) raises:
    """Perform a scaled blit using the 9-grid algorithm to a destination surface,
    which may be of a different format.

    The pixels in the source surface are split into a 3x3 grid, using the
    different corner sizes for each corner, and the sides and center making up
    the remaining pixels. The corners are then scaled using `scale` and fit
    into the corners of the destination rectangle. The sides and center are
    then stretched into place to cover the remaining destination rectangle.

    Args:
        src: The SDL_Surface structure to be copied from.
        srcrect: The SDL_Rect structure representing the rectangle to be used
                 for the 9-grid, or NULL to use the entire surface.
        left_width: The width, in pixels, of the left corners in `srcrect`.
        right_width: The width, in pixels, of the right corners in `srcrect`.
        top_height: The height, in pixels, of the top corners in `srcrect`.
        bottom_height: The height, in pixels, of the bottom corners in
                       `srcrect`.
        scale: The scale used to transform the corner of `srcrect` into the
               corner of `dstrect`, or 0.0f for an unscaled blit.
        scale_mode: Scale algorithm to be used.
        dst: The SDL_Surface structure that is the blit target.
        dstrect: The SDL_Rect structure representing the target rectangle in
                 the destination surface, or NULL to fill the entire surface.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        Only one thread should be using the `src` and `dst` surfaces
        at any given time.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlitSurface9Grid.
    """

    ret = _get_dylib_function[lib, "SDL_BlitSurface9Grid", fn (src: Ptr[Surface, AnyOrigin[True]], srcrect: Ptr[Rect, AnyOrigin[False]], left_width: c_int, right_width: c_int, top_height: c_int, bottom_height: c_int, scale: c_float, scale_mode: ScaleMode, dst: Ptr[Surface, AnyOrigin[True]], dstrect: Ptr[Rect, AnyOrigin[False]]) -> Bool]()(src, srcrect, left_width, right_width, top_height, bottom_height, scale, scale_mode, dst, dstrect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn map_surface_rgb(surface: Ptr[Surface, AnyOrigin[True]], r: UInt8, g: UInt8, b: UInt8) raises -> UInt32:
    """Map an RGB triple to an opaque pixel value for a surface.

    This function maps the RGB color value to the specified pixel format and
    returns the pixel value best approximating the given RGB color value for
    the given pixel format.

    If the surface has a palette, the index of the closest matching color in
    the palette will be returned.

    If the surface pixel format has an alpha component it will be returned as
    all 1 bits (fully opaque).

    If the pixel format bpp (color depth) is less than 32-bpp then the unused
    upper bits of the return value can safely be ignored (e.g., with a 16-bpp
    format the return value can be assigned to a Uint16, and similarly a Uint8
    for an 8-bpp format).

    Args:
        surface: The surface to use for the pixel format and palette.
        r: The red component of the pixel in the range 0-255.
        g: The green component of the pixel in the range 0-255.
        b: The blue component of the pixel in the range 0-255.

    Returns:
        A pixel value.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_MapSurfaceRGB.
    """

    return _get_dylib_function[lib, "SDL_MapSurfaceRGB", fn (surface: Ptr[Surface, AnyOrigin[True]], r: UInt8, g: UInt8, b: UInt8) -> UInt32]()(surface, r, g, b)


fn map_surface_rgba(surface: Ptr[Surface, AnyOrigin[True]], r: UInt8, g: UInt8, b: UInt8, a: UInt8) raises -> UInt32:
    """Map an RGBA quadruple to a pixel value for a surface.

    This function maps the RGBA color value to the specified pixel format and
    returns the pixel value best approximating the given RGBA color value for
    the given pixel format.

    If the surface pixel format has no alpha component the alpha value will be
    ignored (as it will be in formats with a palette).

    If the surface has a palette, the index of the closest matching color in
    the palette will be returned.

    If the pixel format bpp (color depth) is less than 32-bpp then the unused
    upper bits of the return value can safely be ignored (e.g., with a 16-bpp
    format the return value can be assigned to a Uint16, and similarly a Uint8
    for an 8-bpp format).

    Args:
        surface: The surface to use for the pixel format and palette.
        r: The red component of the pixel in the range 0-255.
        g: The green component of the pixel in the range 0-255.
        b: The blue component of the pixel in the range 0-255.
        a: The alpha component of the pixel in the range 0-255.

    Returns:
        A pixel value.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_MapSurfaceRGBA.
    """

    return _get_dylib_function[lib, "SDL_MapSurfaceRGBA", fn (surface: Ptr[Surface, AnyOrigin[True]], r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> UInt32]()(surface, r, g, b, a)


fn read_surface_pixel(surface: Ptr[Surface, AnyOrigin[True]], x: c_int, y: c_int, r: Ptr[UInt8, AnyOrigin[True]], g: Ptr[UInt8, AnyOrigin[True]], b: Ptr[UInt8, AnyOrigin[True]], a: Ptr[UInt8, AnyOrigin[True]]) raises:
    """Retrieves a single pixel from a surface.

    This function prioritizes correctness over speed: it is suitable for unit
    tests, but is not intended for use in a game engine.

    Like SDL_GetRGBA, this uses the entire 0..255 range when converting color
    components from pixel formats with less than 8 bits per RGB component.

    Args:
        surface: The surface to read.
        x: The horizontal coordinate, 0 <= x < width.
        y: The vertical coordinate, 0 <= y < height.
        r: A pointer filled in with the red channel, 0-255, or NULL to ignore
           this channel.
        g: A pointer filled in with the green channel, 0-255, or NULL to
           ignore this channel.
        b: A pointer filled in with the blue channel, 0-255, or NULL to
           ignore this channel.
        a: A pointer filled in with the alpha channel, 0-255, or NULL to
           ignore this channel.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadSurfacePixel.
    """

    ret = _get_dylib_function[lib, "SDL_ReadSurfacePixel", fn (surface: Ptr[Surface, AnyOrigin[True]], x: c_int, y: c_int, r: Ptr[UInt8, AnyOrigin[True]], g: Ptr[UInt8, AnyOrigin[True]], b: Ptr[UInt8, AnyOrigin[True]], a: Ptr[UInt8, AnyOrigin[True]]) -> Bool]()(surface, x, y, r, g, b, a)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_surface_pixel_float(surface: Ptr[Surface, AnyOrigin[True]], x: c_int, y: c_int, r: Ptr[c_float, AnyOrigin[True]], g: Ptr[c_float, AnyOrigin[True]], b: Ptr[c_float, AnyOrigin[True]], a: Ptr[c_float, AnyOrigin[True]]) raises:
    """Retrieves a single pixel from a surface.

    This function prioritizes correctness over speed: it is suitable for unit
    tests, but is not intended for use in a game engine.

    Args:
        surface: The surface to read.
        x: The horizontal coordinate, 0 <= x < width.
        y: The vertical coordinate, 0 <= y < height.
        r: A pointer filled in with the red channel, normally in the range
           0-1, or NULL to ignore this channel.
        g: A pointer filled in with the green channel, normally in the range
           0-1, or NULL to ignore this channel.
        b: A pointer filled in with the blue channel, normally in the range
           0-1, or NULL to ignore this channel.
        a: A pointer filled in with the alpha channel, normally in the range
           0-1, or NULL to ignore this channel.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadSurfacePixelFloat.
    """

    ret = _get_dylib_function[lib, "SDL_ReadSurfacePixelFloat", fn (surface: Ptr[Surface, AnyOrigin[True]], x: c_int, y: c_int, r: Ptr[c_float, AnyOrigin[True]], g: Ptr[c_float, AnyOrigin[True]], b: Ptr[c_float, AnyOrigin[True]], a: Ptr[c_float, AnyOrigin[True]]) -> Bool]()(surface, x, y, r, g, b, a)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_surface_pixel(surface: Ptr[Surface, AnyOrigin[True]], x: c_int, y: c_int, r: UInt8, g: UInt8, b: UInt8, a: UInt8) raises:
    """Writes a single pixel to a surface.

    This function prioritizes correctness over speed: it is suitable for unit
    tests, but is not intended for use in a game engine.

    Like SDL_MapRGBA, this uses the entire 0..255 range when converting color
    components from pixel formats with less than 8 bits per RGB component.

    Args:
        surface: The surface to write.
        x: The horizontal coordinate, 0 <= x < width.
        y: The vertical coordinate, 0 <= y < height.
        r: The red channel value, 0-255.
        g: The green channel value, 0-255.
        b: The blue channel value, 0-255.
        a: The alpha channel value, 0-255.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteSurfacePixel.
    """

    ret = _get_dylib_function[lib, "SDL_WriteSurfacePixel", fn (surface: Ptr[Surface, AnyOrigin[True]], x: c_int, y: c_int, r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> Bool]()(surface, x, y, r, g, b, a)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_surface_pixel_float(surface: Ptr[Surface, AnyOrigin[True]], x: c_int, y: c_int, r: c_float, g: c_float, b: c_float, a: c_float) raises:
    """Writes a single pixel to a surface.

    This function prioritizes correctness over speed: it is suitable for unit
    tests, but is not intended for use in a game engine.

    Args:
        surface: The surface to write.
        x: The horizontal coordinate, 0 <= x < width.
        y: The vertical coordinate, 0 <= y < height.
        r: The red channel value, normally in the range 0-1.
        g: The green channel value, normally in the range 0-1.
        b: The blue channel value, normally in the range 0-1.
        a: The alpha channel value, normally in the range 0-1.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteSurfacePixelFloat.
    """

    ret = _get_dylib_function[lib, "SDL_WriteSurfacePixelFloat", fn (surface: Ptr[Surface, AnyOrigin[True]], x: c_int, y: c_int, r: c_float, g: c_float, b: c_float, a: c_float) -> Bool]()(surface, x, y, r, g, b, a)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))
