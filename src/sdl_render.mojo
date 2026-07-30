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

"""Render.

Header file for SDL 2D rendering functions.

This API supports the following features:

- single pixel points
- single pixel lines
- filled rectangles
- texture images
- 2D polygons

The primitives may be drawn in opaque, blended, or additive modes.

The texture images may be drawn in opaque, blended, or additive modes. They
can have an additional color tint or alpha modulation applied to them, and
may also be stretched with linear interpolation.

This API is designed to accelerate simple 2D operations. You may want more
functionality such as polygons and particle effects and in that case you
should use SDL's OpenGL/Direct3D support, the SDL3 GPU API, or one of the
many good 3D engines.

These functions must be called from the main thread. See this bug for
details: https://github.com/libsdl-org/SDL/issues/986
"""


@fieldwise_init
struct Vertex(ImplicitlyCopyable, Movable):
    """Vertex structure.

    Docs: https://wiki.libsdl.org/SDL3/Vertex.
    """

    var position: FPoint
    """Vertex position, in SDL_Renderer coordinates."""
    var color: FColor
    """Vertex color."""
    var tex_coord: FPoint
    """Normalized texture coordinates, if needed."""


struct TextureAccess(Indexer, Intable, TrivialRegisterPassable):
    """The access pattern allowed for a texture.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TextureAccess.
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

    comptime TEXTUREACCESS_STATIC = Self(0)
    """Changes rarely, not lockable."""
    comptime TEXTUREACCESS_STREAMING = Self(1)
    """Changes frequently, lockable."""
    comptime TEXTUREACCESS_TARGET = Self(2)
    """Texture can be used as a render target."""


struct RendererLogicalPresentation(Indexer, Intable, TrivialRegisterPassable):
    """How the logical size is mapped to the output.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RendererLogicalPresentation.
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

    comptime LOGICAL_PRESENTATION_DISABLED = Self(0)
    """There is no logical size in effect."""
    comptime LOGICAL_PRESENTATION_STRETCH = Self(1)
    """The rendered content is stretched to the output resolution."""
    comptime LOGICAL_PRESENTATION_LETTERBOX = Self(2)
    """The rendered content is fit to the largest dimension and the other dimension is letterboxed with black bars."""
    comptime LOGICAL_PRESENTATION_OVERSCAN = Self(3)
    """The rendered content is fit to the smallest dimension and the other dimension extends beyond the output bounds."""
    comptime LOGICAL_PRESENTATION_INTEGER_SCALE = Self(4)
    """The rendered content is scaled up by integer multiples to fit the output resolution."""


@fieldwise_init
struct Renderer(ImplicitlyCopyable, Movable):
    """A structure representing rendering state.

    Docs: https://wiki.libsdl.org/SDL3/Renderer.
    """

    pass


@fieldwise_init
struct Texture(ImplicitlyCopyable, Movable):
    """An efficient driver-specific representation of pixel data.

    Docs: https://wiki.libsdl.org/SDL3/SDL_Texture.
    """

    var format: PixelFormat
    """The format of the texture, read-only."""
    var w: c_int
    """The width of the texture, read-only."""
    var h: c_int
    """The height of the texture, read-only."""

    var refcount: c_int
    """Application reference count, used when freeing texture."""


def get_num_render_drivers() raises -> c_int:
    """Get the number of 2D rendering drivers available for the current display.

    A render driver is a set of code that handles rendering and texture
    management on a particular display. Normally there is only one, but some
    drivers may have several available with different capabilities.

    There may be none if SDL was compiled without render support.

    Returns:
        The number of built in render drivers.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumRenderDrivers.
    """

    return _get_dylib_function[lib, "SDL_GetNumRenderDrivers", def() thin abi("C") -> c_int]()()


def get_render_driver(index: c_int) raises -> Ptr[c_char, ExternalOrigin[mut=False]]:
    """Use this function to get the name of a built in 2D rendering driver.

    The list of rendering drivers is given in the order that they are normally
    initialized by default; the drivers that seem more reasonable to choose
    first (as far as the SDL developers believe) are earlier in the list.

    The names of drivers are all simple, low-ASCII identifiers, like "opengl",
    "direct3d12" or "metal". These never have Unicode characters, and are not
    meant to be proper names.

    Args:
        index: The index of the rendering driver; the value ranges from 0 to
               SDL_GetNumRenderDrivers() - 1.

    Returns:
        The name of the rendering driver at the requested index, or NULL
        if an invalid index was specified.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderDriver.
    """

    return _get_dylib_function[lib, "SDL_GetRenderDriver", def(index: c_int) thin abi("C") -> OptPtr[c_char, ExternalOrigin[mut=False]]]()(index).value()


def create_window_and_renderer[O_window: Origin, O_renderer: Origin, //](var title: String, width: c_int, height: c_int, window_flags: WindowFlags, window: Ptr[OptPtr[Window, ExternalOrigin[mut=True]], O_window], renderer: Ptr[OptPtr[Renderer, ExternalOrigin[mut=True]], O_renderer]) raises:
    """Create a window and default renderer.

    Args:
        title: The title of the window, in UTF-8 encoding.
        width: The width of the window.
        height: The height of the window.
        window_flags: The flags used to create the window (see
                      SDL_CreateWindow()).
        window: A pointer filled with the window, or NULL on error.
        renderer: A pointer filled with the renderer, or NULL on error.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateWindowAndRenderer.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_CreateWindowAndRenderer", def(title: Ptr[mut=False, c_char, origin_of(title)], width: c_int, height: c_int, window_flags: WindowFlags, window: Ptr[OptPtr[Window, ExternalOrigin[mut=True]], O_window], renderer: Ptr[OptPtr[Renderer, ExternalOrigin[mut=True]], O_renderer]) thin abi("C") -> Bool]()(title.as_c_string_slice().unsafe_ptr(), width, height, window_flags, window, renderer)
    if not _ffi_ret:
        raise Error(get_error())


def create_renderer[O_window: Origin, //](window: Ptr[Window, O_window], var name: String) raises -> Ptr[Renderer, ExternalOrigin[mut=True]]:
    """Create a 2D rendering context for a window.

    If you want a specific renderer, you can specify its name here. A list of
    available renderers can be obtained by calling SDL_GetRenderDriver()
    multiple times, with indices from 0 to SDL_GetNumRenderDrivers()-1. If you
    don't need a specific renderer, specify NULL and SDL will attempt to choose
    the best option for you, based on what is available on the user's system.

    If `name` is a comma-separated list, SDL will try each name, in the order
    listed, until one succeeds or all of them fail.

    By default the rendering size matches the window size in pixels, but you
    can call SDL_SetRenderLogicalPresentation() to change the content size and
    scaling options.

    Args:
        window: The window where rendering is displayed.
        name: The name of the rendering driver to initialize, or NULL to let
              SDL choose one.

    Returns:
        A valid rendering context or NULL if there was an error; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateRenderer.
    """

    return _get_dylib_function[lib, "SDL_CreateRenderer", def(window: Ptr[Window, O_window], name: Ptr[mut=False, c_char, origin_of(name)]) thin abi("C") -> OptPtr[Renderer, ExternalOrigin[mut=True]]]()(window, name.as_c_string_slice().unsafe_ptr()).value()


def create_renderer_with_properties(props: PropertiesID) raises -> Ptr[Renderer, ExternalOrigin[mut=True]]:
    """Create a 2D rendering context for a window, with the specified properties.

    These are the supported properties:

    - `SDL_PROP_RENDERER_CREATE_NAME_STRING`: the name of the rendering driver
      to use, if a specific one is desired
    - `SDL_PROP_RENDERER_CREATE_WINDOW_POINTER`: the window where rendering is
      displayed, required if this isn't a software renderer using a surface
    - `SDL_PROP_RENDERER_CREATE_SURFACE_POINTER`: the surface where rendering
      is displayed, if you want a software renderer without a window
    - `SDL_PROP_RENDERER_CREATE_OUTPUT_COLORSPACE_NUMBER`: an SDL_Colorspace
      value describing the colorspace for output to the display, defaults to
      SDL_COLORSPACE_SRGB. The direct3d11, direct3d12, and metal renderers
      support SDL_COLORSPACE_SRGB_LINEAR, which is a linear color space and
      supports HDR output. If you select SDL_COLORSPACE_SRGB_LINEAR, drawing
      still uses the sRGB colorspace, but values can go beyond 1.0 and float
      (linear) format textures can be used for HDR content.
    - `SDL_PROP_RENDERER_CREATE_PRESENT_VSYNC_NUMBER`: non-zero if you want
      present synchronized with the refresh rate. This property can take any
      value that is supported by SDL_SetRenderVSync() for the renderer.

    With the vulkan renderer:

    - `SDL_PROP_RENDERER_CREATE_VULKAN_INSTANCE_POINTER`: the VkInstance to use
      with the renderer, optional.
    - `SDL_PROP_RENDERER_CREATE_VULKAN_SURFACE_NUMBER`: the VkSurfaceKHR to use
      with the renderer, optional.
    - `SDL_PROP_RENDERER_CREATE_VULKAN_PHYSICAL_DEVICE_POINTER`: the
      VkPhysicalDevice to use with the renderer, optional.
    - `SDL_PROP_RENDERER_CREATE_VULKAN_DEVICE_POINTER`: the VkDevice to use
      with the renderer, optional.
    - `SDL_PROP_RENDERER_CREATE_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER`: the
      queue family index used for rendering.
    - `SDL_PROP_RENDERER_CREATE_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER`: the
      queue family index used for presentation.

    Args:
        props: The properties to use.

    Returns:
        A valid rendering context or NULL if there was an error; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateRendererWithProperties.
    """

    return _get_dylib_function[lib, "SDL_CreateRendererWithProperties", def(props: PropertiesID) thin abi("C") -> OptPtr[Renderer, ExternalOrigin[mut=True]]]()(props).value()


def create_software_renderer[O_surface: Origin, //](surface: Ptr[Surface, O_surface]) raises -> Ptr[Renderer, ExternalOrigin[mut=True]]:
    """Create a 2D software rendering context for a surface.

    Two other API which can be used to create SDL_Renderer:
    SDL_CreateRenderer() and SDL_CreateWindowAndRenderer(). These can _also_
    create a software renderer, but they are intended to be used with an
    SDL_Window as the final destination and not an SDL_Surface.

    Args:
        surface: The SDL_Surface structure representing the surface where
                 rendering is done.

    Returns:
        A valid rendering context or NULL if there was an error; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateSoftwareRenderer.
    """

    return _get_dylib_function[lib, "SDL_CreateSoftwareRenderer", def(surface: Ptr[Surface, O_surface]) thin abi("C") -> OptPtr[Renderer, ExternalOrigin[mut=True]]]()(surface).value()


def get_renderer[O_window: Origin, //](window: Ptr[Window, O_window], out ret: Ptr[Renderer, ExternalOrigin[mut=True]]) raises:
    """Get the renderer associated with a window.

    Args:
        window: The window to query.

    Returns:
        The rendering context on success or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderer.
    """

    _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderer", def(window: Ptr[Window, O_window]) thin abi("C") -> OptPtr[Renderer, ExternalOrigin[mut=True]]]()(window)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def get_render_window[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], out ret: Ptr[Window, ExternalOrigin[mut=True]]) raises:
    """Get the window associated with a renderer.

    Args:
        renderer: The renderer to query.

    Returns:
        The window on success or NULL on failure; call SDL_GetError() for
        more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderWindow.
    """

    _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderWindow", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> OptPtr[Window, ExternalOrigin[mut=True]]]()(renderer)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def get_renderer_name[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], out ret: Ptr[c_char, ExternalOrigin[mut=False]]) raises:
    """Get the name of a renderer.

    Args:
        renderer: The rendering context.

    Returns:
        The name of the selected renderer, or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRendererName.
    """

    _ffi_ret = _get_dylib_function[lib, "SDL_GetRendererName", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> OptPtr[c_char, ExternalOrigin[mut=False]]]()(renderer)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def get_renderer_properties[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer]) raises -> PropertiesID:
    """Get the properties associated with a renderer.

    The following read-only properties are provided by SDL:

    - `SDL_PROP_RENDERER_NAME_STRING`: the name of the rendering driver
    - `SDL_PROP_RENDERER_WINDOW_POINTER`: the window where rendering is
      displayed, if any
    - `SDL_PROP_RENDERER_SURFACE_POINTER`: the surface where rendering is
      displayed, if this is a software renderer without a window
    - `SDL_PROP_RENDERER_VSYNC_NUMBER`: the current vsync setting
    - `SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER`: the maximum texture width
      and height
    - `SDL_PROP_RENDERER_TEXTURE_FORMATS_POINTER`: a (const SDL_PixelFormat *)
      array of pixel formats, terminated with SDL_PIXELFORMAT_UNKNOWN,
      representing the available texture formats for this renderer.
    - `SDL_PROP_RENDERER_OUTPUT_COLORSPACE_NUMBER`: an SDL_Colorspace value
      describing the colorspace for output to the display, defaults to
      SDL_COLORSPACE_SRGB.
    - `SDL_PROP_RENDERER_HDR_ENABLED_BOOLEAN`: true if the output colorspace is
      SDL_COLORSPACE_SRGB_LINEAR and the renderer is showing on a display with
      HDR enabled. This property can change dynamically when
      SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.
    - `SDL_PROP_RENDERER_SDR_WHITE_POINT_FLOAT`: the value of SDR white in the
      SDL_COLORSPACE_SRGB_LINEAR colorspace. When HDR is enabled, this value is
      automatically multiplied into the color scale. This property can change
      dynamically when SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.
    - `SDL_PROP_RENDERER_HDR_HEADROOM_FLOAT`: the additional high dynamic range
      that can be displayed, in terms of the SDR white point. When HDR is not
      enabled, this will be 1.0. This property can change dynamically when
      SDL_EVENT_WINDOW_HDR_STATE_CHANGED is sent.

    With the direct3d renderer:

    - `SDL_PROP_RENDERER_D3D9_DEVICE_POINTER`: the IDirect3DDevice9 associated
      with the renderer

    With the direct3d11 renderer:

    - `SDL_PROP_RENDERER_D3D11_DEVICE_POINTER`: the ID3D11Device associated
      with the renderer
    - `SDL_PROP_RENDERER_D3D11_SWAPCHAIN_POINTER`: the IDXGISwapChain1
      associated with the renderer. This may change when the window is resized.

    With the direct3d12 renderer:

    - `SDL_PROP_RENDERER_D3D12_DEVICE_POINTER`: the ID3D12Device associated
      with the renderer
    - `SDL_PROP_RENDERER_D3D12_SWAPCHAIN_POINTER`: the IDXGISwapChain4
      associated with the renderer.
    - `SDL_PROP_RENDERER_D3D12_COMMAND_QUEUE_POINTER`: the ID3D12CommandQueue
      associated with the renderer

    With the vulkan renderer:

    - `SDL_PROP_RENDERER_VULKAN_INSTANCE_POINTER`: the VkInstance associated
      with the renderer
    - `SDL_PROP_RENDERER_VULKAN_SURFACE_NUMBER`: the VkSurfaceKHR associated
      with the renderer
    - `SDL_PROP_RENDERER_VULKAN_PHYSICAL_DEVICE_POINTER`: the VkPhysicalDevice
      associated with the renderer
    - `SDL_PROP_RENDERER_VULKAN_DEVICE_POINTER`: the VkDevice associated with
      the renderer
    - `SDL_PROP_RENDERER_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER`: the queue
      family index used for rendering
    - `SDL_PROP_RENDERER_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER`: the queue
      family index used for presentation
    - `SDL_PROP_RENDERER_VULKAN_SWAPCHAIN_IMAGE_COUNT_NUMBER`: the number of
      swapchain images, or potential frames in flight, used by the Vulkan
      renderer

    With the gpu renderer:

    - `SDL_PROP_RENDERER_GPU_DEVICE_POINTER`: the SDL_GPUDevice associated with
      the renderer

    Args:
        renderer: The rendering context.

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRendererProperties.
    """

    return _get_dylib_function[lib, "SDL_GetRendererProperties", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> PropertiesID]()(renderer)


def get_render_output_size[O_renderer: Origin, O_w: Origin, O_h: Origin, //](renderer: Ptr[Renderer, O_renderer], w: Ptr[c_int, O_w], h: Ptr[c_int, O_h]) raises:
    """Get the output size in pixels of a rendering context.

    This returns the true output size in pixels, ignoring any render targets or
    logical size and presentation.

    For the output size of the current rendering target, with logical size
    adjustments, use SDL_GetCurrentRenderOutputSize() instead.

    Args:
        renderer: The rendering context.
        w: A pointer filled in with the width in pixels.
        h: A pointer filled in with the height in pixels.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderOutputSize.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderOutputSize", def(renderer: Ptr[Renderer, O_renderer], w: Ptr[c_int, O_w], h: Ptr[c_int, O_h]) thin abi("C") -> Bool]()(renderer, w, h)
    if not _ffi_ret:
        raise Error(get_error())


def get_current_render_output_size[O_renderer: Origin, O_w: Origin, O_h: Origin, //](renderer: Ptr[Renderer, O_renderer], w: Ptr[c_int, O_w], h: Ptr[c_int, O_h]) raises:
    """Get the current output size in pixels of a rendering context.

    If a rendering target is active, this will return the size of the rendering
    target in pixels, otherwise return the value of SDL_GetRenderOutputSize().

    Rendering target or not, the output will be adjusted by the current logical
    presentation state, dictated by SDL_SetRenderLogicalPresentation().

    Args:
        renderer: The rendering context.
        w: A pointer filled in with the current width.
        h: A pointer filled in with the current height.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCurrentRenderOutputSize.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetCurrentRenderOutputSize", def(renderer: Ptr[Renderer, O_renderer], w: Ptr[c_int, O_w], h: Ptr[c_int, O_h]) thin abi("C") -> Bool]()(renderer, w, h)
    if not _ffi_ret:
        raise Error(get_error())


def create_texture[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], format: PixelFormat, access: TextureAccess, w: c_int, h: c_int, out ret: Ptr[Texture, ExternalOrigin[mut=True]]) raises:
    """Create a texture for a rendering context.

    The contents of a texture when first created are not defined.

    Args:
        renderer: The rendering context.
        format: One of the enumerated values in SDL_PixelFormat.
        access: One of the enumerated values in SDL_TextureAccess.
        w: The width of the texture in pixels.
        h: The height of the texture in pixels.

    Returns:
        The created texture or NULL on failure; call SDL_GetError() for
        more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateTexture.
    """

    _ffi_ret = _get_dylib_function[lib, "SDL_CreateTexture", def(renderer: Ptr[Renderer, O_renderer], format: PixelFormat, access: TextureAccess, w: c_int, h: c_int) thin abi("C") -> OptPtr[Texture, ExternalOrigin[mut=True]]]()(renderer, format, access, w, h)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def create_texture_from_surface[O_renderer: Origin, O_surface: Origin, //](renderer: Ptr[Renderer, O_renderer], surface: Ptr[Surface, O_surface], out ret: Ptr[Texture, ExternalOrigin[mut=True]]) raises:
    """Create a texture from an existing surface.

    The surface is not modified or freed by this function.

    The SDL_TextureAccess hint for the created texture is
    `SDL_TEXTUREACCESS_STATIC`.

    The pixel format of the created texture may be different from the pixel
    format of the surface, and can be queried using the
    SDL_PROP_TEXTURE_FORMAT_NUMBER property.

    Args:
        renderer: The rendering context.
        surface: The SDL_Surface structure containing pixel data used to fill
                 the texture.

    Returns:
        The created texture or NULL on failure; call SDL_GetError() for
        more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateTextureFromSurface.
    """

    _ffi_ret = _get_dylib_function[lib, "SDL_CreateTextureFromSurface", def(renderer: Ptr[Renderer, O_renderer], surface: Ptr[Surface, O_surface]) thin abi("C") -> OptPtr[Texture, ExternalOrigin[mut=True]]]()(renderer, surface)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def create_texture_with_properties[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], props: PropertiesID, out ret: Ptr[Texture, ExternalOrigin[mut=True]]) raises:
    """Create a texture for a rendering context with the specified properties.

    These are the supported properties:

    - `SDL_PROP_TEXTURE_CREATE_COLORSPACE_NUMBER`: an SDL_Colorspace value
      describing the texture colorspace, defaults to SDL_COLORSPACE_SRGB_LINEAR
      for floating point textures, SDL_COLORSPACE_HDR10 for 10-bit textures,
      SDL_COLORSPACE_SRGB for other RGB textures and SDL_COLORSPACE_JPEG for
      YUV textures.
    - `SDL_PROP_TEXTURE_CREATE_FORMAT_NUMBER`: one of the enumerated values in
      SDL_PixelFormat, defaults to the best RGBA format for the renderer
    - `SDL_PROP_TEXTURE_CREATE_ACCESS_NUMBER`: one of the enumerated values in
      SDL_TextureAccess, defaults to SDL_TEXTUREACCESS_STATIC
    - `SDL_PROP_TEXTURE_CREATE_WIDTH_NUMBER`: the width of the texture in
      pixels, required
    - `SDL_PROP_TEXTURE_CREATE_HEIGHT_NUMBER`: the height of the texture in
      pixels, required
    - `SDL_PROP_TEXTURE_CREATE_SDR_WHITE_POINT_FLOAT`: for HDR10 and floating
      point textures, this defines the value of 100% diffuse white, with higher
      values being displayed in the High Dynamic Range headroom. This defaults
      to 100 for HDR10 textures and 1.0 for floating point textures.
    - `SDL_PROP_TEXTURE_CREATE_HDR_HEADROOM_FLOAT`: for HDR10 and floating
      point textures, this defines the maximum dynamic range used by the
      content, in terms of the SDR white point. This would be equivalent to
      maxCLL / SDL_PROP_TEXTURE_CREATE_SDR_WHITE_POINT_FLOAT for HDR10 content.
      If this is defined, any values outside the range supported by the display
      will be scaled into the available HDR headroom, otherwise they are
      clipped.

    With the direct3d11 renderer:

    - `SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_POINTER`: the ID3D11Texture2D
      associated with the texture, if you want to wrap an existing texture.
    - `SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_U_POINTER`: the ID3D11Texture2D
      associated with the U plane of a YUV texture, if you want to wrap an
      existing texture.
    - `SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_V_POINTER`: the ID3D11Texture2D
      associated with the V plane of a YUV texture, if you want to wrap an
      existing texture.

    With the direct3d12 renderer:

    - `SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_POINTER`: the ID3D12Resource
      associated with the texture, if you want to wrap an existing texture.
    - `SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_U_POINTER`: the ID3D12Resource
      associated with the U plane of a YUV texture, if you want to wrap an
      existing texture.
    - `SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_V_POINTER`: the ID3D12Resource
      associated with the V plane of a YUV texture, if you want to wrap an
      existing texture.

    With the metal renderer:

    - `SDL_PROP_TEXTURE_CREATE_METAL_PIXELBUFFER_POINTER`: the CVPixelBufferRef
      associated with the texture, if you want to create a texture from an
      existing pixel buffer.

    With the opengl renderer:

    - `SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_NUMBER`: the GLuint texture
      associated with the texture, if you want to wrap an existing texture.
    - `SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_UV_NUMBER`: the GLuint texture
      associated with the UV plane of an NV12 texture, if you want to wrap an
      existing texture.
    - `SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_U_NUMBER`: the GLuint texture
      associated with the U plane of a YUV texture, if you want to wrap an
      existing texture.
    - `SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_V_NUMBER`: the GLuint texture
      associated with the V plane of a YUV texture, if you want to wrap an
      existing texture.

    With the opengles2 renderer:

    - `SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_NUMBER`: the GLuint texture
      associated with the texture, if you want to wrap an existing texture.
    - `SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_NUMBER`: the GLuint texture
      associated with the texture, if you want to wrap an existing texture.
    - `SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_UV_NUMBER`: the GLuint texture
      associated with the UV plane of an NV12 texture, if you want to wrap an
      existing texture.
    - `SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_U_NUMBER`: the GLuint texture
      associated with the U plane of a YUV texture, if you want to wrap an
      existing texture.
    - `SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_V_NUMBER`: the GLuint texture
      associated with the V plane of a YUV texture, if you want to wrap an
      existing texture.

    With the vulkan renderer:

    - `SDL_PROP_TEXTURE_CREATE_VULKAN_TEXTURE_NUMBER`: the VkImage with layout
      VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL associated with the texture, if
      you want to wrap an existing texture.

    Args:
        renderer: The rendering context.
        props: The properties to use.

    Returns:
        The created texture or NULL on failure; call SDL_GetError() for
        more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateTextureWithProperties.
    """

    _ffi_ret = _get_dylib_function[lib, "SDL_CreateTextureWithProperties", def(renderer: Ptr[Renderer, O_renderer], props: PropertiesID) thin abi("C") -> OptPtr[Texture, ExternalOrigin[mut=True]]]()(renderer, props)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def get_texture_properties[O_texture: Origin, //](texture: Ptr[Texture, O_texture]) raises -> PropertiesID:
    """Get the properties associated with a texture.

    The following read-only properties are provided by SDL:

    - `SDL_PROP_TEXTURE_COLORSPACE_NUMBER`: an SDL_Colorspace value describing
      the texture colorspace.
    - `SDL_PROP_TEXTURE_FORMAT_NUMBER`: one of the enumerated values in
      SDL_PixelFormat.
    - `SDL_PROP_TEXTURE_ACCESS_NUMBER`: one of the enumerated values in
      SDL_TextureAccess.
    - `SDL_PROP_TEXTURE_WIDTH_NUMBER`: the width of the texture in pixels.
    - `SDL_PROP_TEXTURE_HEIGHT_NUMBER`: the height of the texture in pixels.
    - `SDL_PROP_TEXTURE_SDR_WHITE_POINT_FLOAT`: for HDR10 and floating point
      textures, this defines the value of 100% diffuse white, with higher
      values being displayed in the High Dynamic Range headroom. This defaults
      to 100 for HDR10 textures and 1.0 for other textures.
    - `SDL_PROP_TEXTURE_HDR_HEADROOM_FLOAT`: for HDR10 and floating point
      textures, this defines the maximum dynamic range used by the content, in
      terms of the SDR white point. If this is defined, any values outside the
      range supported by the display will be scaled into the available HDR
      headroom, otherwise they are clipped. This defaults to 1.0 for SDR
      textures, 4.0 for HDR10 textures, and no default for floating point
      textures.

    With the direct3d11 renderer:

    - `SDL_PROP_TEXTURE_D3D11_TEXTURE_POINTER`: the ID3D11Texture2D associated
      with the texture
    - `SDL_PROP_TEXTURE_D3D11_TEXTURE_U_POINTER`: the ID3D11Texture2D
      associated with the U plane of a YUV texture
    - `SDL_PROP_TEXTURE_D3D11_TEXTURE_V_POINTER`: the ID3D11Texture2D
      associated with the V plane of a YUV texture

    With the direct3d12 renderer:

    - `SDL_PROP_TEXTURE_D3D12_TEXTURE_POINTER`: the ID3D12Resource associated
      with the texture
    - `SDL_PROP_TEXTURE_D3D12_TEXTURE_U_POINTER`: the ID3D12Resource associated
      with the U plane of a YUV texture
    - `SDL_PROP_TEXTURE_D3D12_TEXTURE_V_POINTER`: the ID3D12Resource associated
      with the V plane of a YUV texture

    With the vulkan renderer:

    - `SDL_PROP_TEXTURE_VULKAN_TEXTURE_NUMBER`: the VkImage associated with the
      texture

    With the opengl renderer:

    - `SDL_PROP_TEXTURE_OPENGL_TEXTURE_NUMBER`: the GLuint texture associated
      with the texture
    - `SDL_PROP_TEXTURE_OPENGL_TEXTURE_UV_NUMBER`: the GLuint texture
      associated with the UV plane of an NV12 texture
    - `SDL_PROP_TEXTURE_OPENGL_TEXTURE_U_NUMBER`: the GLuint texture associated
      with the U plane of a YUV texture
    - `SDL_PROP_TEXTURE_OPENGL_TEXTURE_V_NUMBER`: the GLuint texture associated
      with the V plane of a YUV texture
    - `SDL_PROP_TEXTURE_OPENGL_TEXTURE_TARGET_NUMBER`: the GLenum for the
      texture target (`GL_TEXTURE_2D`, `GL_TEXTURE_RECTANGLE_ARB`, etc)
    - `SDL_PROP_TEXTURE_OPENGL_TEX_W_FLOAT`: the texture coordinate width of
      the texture (0.0 - 1.0)
    - `SDL_PROP_TEXTURE_OPENGL_TEX_H_FLOAT`: the texture coordinate height of
      the texture (0.0 - 1.0)

    With the opengles2 renderer:

    - `SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_NUMBER`: the GLuint texture
      associated with the texture
    - `SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_UV_NUMBER`: the GLuint texture
      associated with the UV plane of an NV12 texture
    - `SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_U_NUMBER`: the GLuint texture
      associated with the U plane of a YUV texture
    - `SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_V_NUMBER`: the GLuint texture
      associated with the V plane of a YUV texture
    - `SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_TARGET_NUMBER`: the GLenum for the
      texture target (`GL_TEXTURE_2D`, `GL_TEXTURE_EXTERNAL_OES`, etc)

    Args:
        texture: The texture to query.

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTextureProperties.
    """

    return _get_dylib_function[lib, "SDL_GetTextureProperties", def(texture: Ptr[Texture, O_texture]) thin abi("C") -> PropertiesID]()(texture)


def get_renderer_from_texture[O_texture: Origin, //](texture: Ptr[Texture, O_texture]) raises -> Ptr[Renderer, ExternalOrigin[mut=True]]:
    """Get the renderer that created an SDL_Texture.

    Args:
        texture: The texture to query.

    Returns:
        A pointer to the SDL_Renderer that created the texture, or NULL on
        failure; call SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRendererFromTexture.
    """

    return _get_dylib_function[lib, "SDL_GetRendererFromTexture", def(texture: Ptr[Texture, O_texture]) thin abi("C") -> OptPtr[Renderer, ExternalOrigin[mut=True]]]()(texture).value()


def get_texture_size[O_texture: Origin, O_w: Origin, O_h: Origin, //](texture: Ptr[Texture, O_texture], w: Ptr[c_float, O_w], h: Ptr[c_float, O_h]) raises:
    """Get the size of a texture, as floating point values.

    Args:
        texture: The texture to query.
        w: A pointer filled in with the width of the texture in pixels. This
           argument can be NULL if you don't need this information.
        h: A pointer filled in with the height of the texture in pixels. This
           argument can be NULL if you don't need this information.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTextureSize.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetTextureSize", def(texture: Ptr[Texture, O_texture], w: Ptr[c_float, O_w], h: Ptr[c_float, O_h]) thin abi("C") -> Bool]()(texture, w, h)
    if not _ffi_ret:
        raise Error(get_error())


def set_texture_color_mod[O_texture: Origin, //](texture: Ptr[Texture, O_texture], r: UInt8, g: UInt8, b: UInt8) raises:
    """Set an additional color value multiplied into render copy operations.

    When this texture is rendered, during the copy operation each source color
    channel is modulated by the appropriate color value according to the
    following formula:

    `srcC = srcC * (color / 255)`

    Color modulation is not always supported by the renderer; it will return
    false if color modulation is not supported.

    Args:
        texture: The texture to update.
        r: The red color value multiplied into copy operations.
        g: The green color value multiplied into copy operations.
        b: The blue color value multiplied into copy operations.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetTextureColorMod.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetTextureColorMod", def(texture: Ptr[Texture, O_texture], r: UInt8, g: UInt8, b: UInt8) thin abi("C") -> Bool]()(texture, r, g, b)
    if not _ffi_ret:
        raise Error(get_error())


def set_texture_color_mod_float[O_texture: Origin, //](texture: Ptr[Texture, O_texture], r: c_float, g: c_float, b: c_float) raises:
    """Set an additional color value multiplied into render copy operations.

    When this texture is rendered, during the copy operation each source color
    channel is modulated by the appropriate color value according to the
    following formula:

    `srcC = srcC * color`

    Color modulation is not always supported by the renderer; it will return
    false if color modulation is not supported.

    Args:
        texture: The texture to update.
        r: The red color value multiplied into copy operations.
        g: The green color value multiplied into copy operations.
        b: The blue color value multiplied into copy operations.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetTextureColorModFloat.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetTextureColorModFloat", def(texture: Ptr[Texture, O_texture], r: c_float, g: c_float, b: c_float) thin abi("C") -> Bool]()(texture, r, g, b)
    if not _ffi_ret:
        raise Error(get_error())


def get_texture_color_mod[O_texture: Origin, O_r: Origin, O_g: Origin, O_b: Origin, //](texture: Ptr[Texture, O_texture], r: Ptr[UInt8, O_r], g: Ptr[UInt8, O_g], b: Ptr[UInt8, O_b]) raises:
    """Get the additional color value multiplied into render copy operations.

    Args:
        texture: The texture to query.
        r: A pointer filled in with the current red color value.
        g: A pointer filled in with the current green color value.
        b: A pointer filled in with the current blue color value.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTextureColorMod.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetTextureColorMod", def(texture: Ptr[Texture, O_texture], r: Ptr[UInt8, O_r], g: Ptr[UInt8, O_g], b: Ptr[UInt8, O_b]) thin abi("C") -> Bool]()(texture, r, g, b)
    if not _ffi_ret:
        raise Error(get_error())


def get_texture_color_mod_float[O_texture: Origin, O_r: Origin, O_g: Origin, O_b: Origin, //](texture: Ptr[Texture, O_texture], r: Ptr[c_float, O_r], g: Ptr[c_float, O_g], b: Ptr[c_float, O_b]) raises:
    """Get the additional color value multiplied into render copy operations.

    Args:
        texture: The texture to query.
        r: A pointer filled in with the current red color value.
        g: A pointer filled in with the current green color value.
        b: A pointer filled in with the current blue color value.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTextureColorModFloat.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetTextureColorModFloat", def(texture: Ptr[Texture, O_texture], r: Ptr[c_float, O_r], g: Ptr[c_float, O_g], b: Ptr[c_float, O_b]) thin abi("C") -> Bool]()(texture, r, g, b)
    if not _ffi_ret:
        raise Error(get_error())


def set_texture_alpha_mod[O_texture: Origin, //](texture: Ptr[Texture, O_texture], alpha: UInt8) raises:
    """Set an additional alpha value multiplied into render copy operations.

    When this texture is rendered, during the copy operation the source alpha
    value is modulated by this alpha value according to the following formula:

    `srcA = srcA * (alpha / 255)`

    Alpha modulation is not always supported by the renderer; it will return
    false if alpha modulation is not supported.

    Args:
        texture: The texture to update.
        alpha: The source alpha value multiplied into copy operations.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetTextureAlphaMod.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetTextureAlphaMod", def(texture: Ptr[Texture, O_texture], alpha: UInt8) thin abi("C") -> Bool]()(texture, alpha)
    if not _ffi_ret:
        raise Error(get_error())


def set_texture_alpha_mod_float[O_texture: Origin, //](texture: Ptr[Texture, O_texture], alpha: c_float) raises:
    """Set an additional alpha value multiplied into render copy operations.

    When this texture is rendered, during the copy operation the source alpha
    value is modulated by this alpha value according to the following formula:

    `srcA = srcA * alpha`

    Alpha modulation is not always supported by the renderer; it will return
    false if alpha modulation is not supported.

    Args:
        texture: The texture to update.
        alpha: The source alpha value multiplied into copy operations.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetTextureAlphaModFloat.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetTextureAlphaModFloat", def(texture: Ptr[Texture, O_texture], alpha: c_float) thin abi("C") -> Bool]()(texture, alpha)
    if not _ffi_ret:
        raise Error(get_error())


def get_texture_alpha_mod[O_texture: Origin, O_alpha: Origin, //](texture: Ptr[Texture, O_texture], alpha: Ptr[UInt8, O_alpha]) raises:
    """Get the additional alpha value multiplied into render copy operations.

    Args:
        texture: The texture to query.
        alpha: A pointer filled in with the current alpha value.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTextureAlphaMod.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetTextureAlphaMod", def(texture: Ptr[Texture, O_texture], alpha: Ptr[UInt8, O_alpha]) thin abi("C") -> Bool]()(texture, alpha)
    if not _ffi_ret:
        raise Error(get_error())


def get_texture_alpha_mod_float[O_texture: Origin, O_alpha: Origin, //](texture: Ptr[Texture, O_texture], alpha: Ptr[c_float, O_alpha]) raises:
    """Get the additional alpha value multiplied into render copy operations.

    Args:
        texture: The texture to query.
        alpha: A pointer filled in with the current alpha value.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTextureAlphaModFloat.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetTextureAlphaModFloat", def(texture: Ptr[Texture, O_texture], alpha: Ptr[c_float, O_alpha]) thin abi("C") -> Bool]()(texture, alpha)
    if not _ffi_ret:
        raise Error(get_error())


def set_texture_blend_mode[O_texture: Origin, //](texture: Ptr[Texture, O_texture], blend_mode: BlendMode) raises:
    """Set the blend mode for a texture, used by SDL_RenderTexture().

    If the blend mode is not supported, the closest supported mode is chosen
    and this function returns false.

    Args:
        texture: The texture to update.
        blend_mode: The SDL_BlendMode to use for texture blending.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetTextureBlendMode.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetTextureBlendMode", def(texture: Ptr[Texture, O_texture], blend_mode: BlendMode) thin abi("C") -> Bool]()(texture, blend_mode)
    if not _ffi_ret:
        raise Error(get_error())


def get_texture_blend_mode[O_texture: Origin, O_blend_mode: Origin, //](texture: Ptr[Texture, O_texture], blend_mode: Ptr[BlendMode, O_blend_mode]) raises:
    """Get the blend mode used for texture copy operations.

    Args:
        texture: The texture to query.
        blend_mode: A pointer filled in with the current SDL_BlendMode.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTextureBlendMode.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetTextureBlendMode", def(texture: Ptr[Texture, O_texture], blend_mode: Ptr[BlendMode, O_blend_mode]) thin abi("C") -> Bool]()(texture, blend_mode)
    if not _ffi_ret:
        raise Error(get_error())


def set_texture_scale_mode[O_texture: Origin, //](texture: Ptr[Texture, O_texture], scale_mode: ScaleMode) raises:
    """Set the scale mode used for texture scale operations.

    The default texture scale mode is SDL_SCALEMODE_LINEAR.

    If the scale mode is not supported, the closest supported mode is chosen.

    Args:
        texture: The texture to update.
        scale_mode: The SDL_ScaleMode to use for texture scaling.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetTextureScaleMode.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetTextureScaleMode", def(texture: Ptr[Texture, O_texture], scale_mode: ScaleMode) thin abi("C") -> Bool]()(texture, scale_mode)
    if not _ffi_ret:
        raise Error(get_error())


def get_texture_scale_mode[O_texture: Origin, O_scale_mode: Origin, //](texture: Ptr[Texture, O_texture], scale_mode: Ptr[ScaleMode, O_scale_mode]) raises:
    """Get the scale mode used for texture scale operations.

    Args:
        texture: The texture to query.
        scale_mode: A pointer filled in with the current scale mode.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetTextureScaleMode.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetTextureScaleMode", def(texture: Ptr[Texture, O_texture], scale_mode: Ptr[ScaleMode, O_scale_mode]) thin abi("C") -> Bool]()(texture, scale_mode)
    if not _ffi_ret:
        raise Error(get_error())


def update_texture[O_texture: Origin, O_rect: Origin, O_pixels: Origin, //](texture: Ptr[Texture, O_texture], rect: Ptr[Rect, O_rect], pixels: Ptr[NoneType, O_pixels], pitch: c_int) raises:
    """Update the given texture rectangle with new pixel data.

    The pixel data must be in the pixel format of the texture, which can be
    queried using the SDL_PROP_TEXTURE_FORMAT_NUMBER property.

    This is a fairly slow function, intended for use with static textures that
    do not change often.

    If the texture is intended to be updated often, it is preferred to create
    the texture as streaming and use the locking functions referenced below.
    While this function will work with streaming textures, for optimization
    reasons you may not get the pixels back if you lock the texture afterward.

    Args:
        texture: The texture to update.
        rect: An SDL_Rect structure representing the area to update, or NULL
              to update the entire texture.
        pixels: The raw pixel data in the format of the texture.
        pitch: The number of bytes in a row of pixel data, including padding
               between lines.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UpdateTexture.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_UpdateTexture", def(texture: Ptr[Texture, O_texture], rect: Ptr[Rect, O_rect], pixels: Ptr[NoneType, O_pixels], pitch: c_int) thin abi("C") -> Bool]()(texture, rect, pixels, pitch)
    if not _ffi_ret:
        raise Error(get_error())


def update_yuv_texture[O_texture: Origin, O_rect: Origin, O_y_plane: Origin, O_uplane: Origin, O_vplane: Origin, //](texture: Ptr[Texture, O_texture], rect: Ptr[Rect, O_rect], y_plane: Ptr[UInt8, O_y_plane], y_pitch: c_int, uplane: Ptr[UInt8, O_uplane], upitch: c_int, vplane: Ptr[UInt8, O_vplane], vpitch: c_int) raises:
    """Update a rectangle within a planar YV12 or IYUV texture with new pixel
    data.

    You can use SDL_UpdateTexture() as long as your pixel data is a contiguous
    block of Y and U/V planes in the proper order, but this function is
    available if your pixel data is not contiguous.

    Args:
        texture: The texture to update.
        rect: A pointer to the rectangle of pixels to update, or NULL to
              update the entire texture.
        y_plane: The raw pixel data for the Y plane.
        y_pitch: The number of bytes between rows of pixel data for the Y
                 plane.
        uplane: The raw pixel data for the U plane.
        upitch: The number of bytes between rows of pixel data for the U
                plane.
        vplane: The raw pixel data for the V plane.
        vpitch: The number of bytes between rows of pixel data for the V
                plane.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UpdateYUVTexture.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_UpdateYUVTexture", def(texture: Ptr[Texture, O_texture], rect: Ptr[Rect, O_rect], y_plane: Ptr[UInt8, O_y_plane], y_pitch: c_int, uplane: Ptr[UInt8, O_uplane], upitch: c_int, vplane: Ptr[UInt8, O_vplane], vpitch: c_int) thin abi("C") -> Bool]()(texture, rect, y_plane, y_pitch, uplane, upitch, vplane, vpitch)
    if not _ffi_ret:
        raise Error(get_error())


def update_nv_texture[O_texture: Origin, O_rect: Origin, O_y_plane: Origin, O_uv_plane: Origin, //](texture: Ptr[Texture, O_texture], rect: Ptr[Rect, O_rect], y_plane: Ptr[UInt8, O_y_plane], y_pitch: c_int, uv_plane: Ptr[UInt8, O_uv_plane], uv_pitch: c_int) raises:
    """Update a rectangle within a planar NV12 or NV21 texture with new pixels.

    You can use SDL_UpdateTexture() as long as your pixel data is a contiguous
    block of NV12/21 planes in the proper order, but this function is available
    if your pixel data is not contiguous.

    Args:
        texture: The texture to update.
        rect: A pointer to the rectangle of pixels to update, or NULL to
              update the entire texture.
        y_plane: The raw pixel data for the Y plane.
        y_pitch: The number of bytes between rows of pixel data for the Y
                 plane.
        uv_plane: The raw pixel data for the UV plane.
        uv_pitch: The number of bytes between rows of pixel data for the UV
                  plane.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UpdateNVTexture.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_UpdateNVTexture", def(texture: Ptr[Texture, O_texture], rect: Ptr[Rect, O_rect], y_plane: Ptr[UInt8, O_y_plane], y_pitch: c_int, uv_plane: Ptr[UInt8, O_uv_plane], uv_pitch: c_int) thin abi("C") -> Bool]()(texture, rect, y_plane, y_pitch, uv_plane, uv_pitch)
    if not _ffi_ret:
        raise Error(get_error())


def lock_texture[O_texture: Origin, O_rect: Origin, O_pixels: Origin, O_pitch: Origin, //](texture: Ptr[Texture, O_texture], rect: Ptr[Rect, O_rect], pixels: Ptr[OptPtr[NoneType, ExternalOrigin[mut=True]], O_pixels], pitch: Ptr[c_int, O_pitch]) raises:
    """Lock a portion of the texture for **write-only** pixel access.

    As an optimization, the pixels made available for editing don't necessarily
    contain the old texture data. This is a write-only operation, and if you
    need to keep a copy of the texture data you should do that at the
    application level.

    You must use SDL_UnlockTexture() to unlock the pixels and apply any
    changes.

    Args:
        texture: The texture to lock for access, which was created with
                 `SDL_TEXTUREACCESS_STREAMING`.
        rect: An SDL_Rect structure representing the area to lock for access;
              NULL to lock the entire texture.
        pixels: This is filled in with a pointer to the locked pixels,
                appropriately offset by the locked area.
        pitch: This is filled in with the pitch of the locked pixels; the
               pitch is the length of one row in bytes.

    Raises:
        Raises if the texture is not valid or was not
        created with `SDL_TEXTUREACCESS_STREAMING`; call SDL_GetError()
        for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LockTexture.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_LockTexture", def(texture: Ptr[Texture, O_texture], rect: Ptr[Rect, O_rect], pixels: Ptr[OptPtr[NoneType, ExternalOrigin[mut=True]], O_pixels], pitch: Ptr[c_int, O_pitch]) thin abi("C") -> Bool]()(texture, rect, pixels, pitch)
    if not _ffi_ret:
        raise Error(get_error())


def lock_texture_to_surface[O_texture: Origin, O_rect: Origin, O_surface: Origin, //](texture: Ptr[Texture, O_texture], rect: Ptr[Rect, O_rect], surface: Ptr[OptPtr[Surface, ExternalOrigin[mut=True]], O_surface]) raises:
    """Lock a portion of the texture for **write-only** pixel access, and expose
    it as a SDL surface.

    Besides providing an SDL_Surface instead of raw pixel data, this function
    operates like SDL_LockTexture.

    As an optimization, the pixels made available for editing don't necessarily
    contain the old texture data. This is a write-only operation, and if you
    need to keep a copy of the texture data you should do that at the
    application level.

    You must use SDL_UnlockTexture() to unlock the pixels and apply any
    changes.

    The returned surface is freed internally after calling SDL_UnlockTexture()
    or SDL_DestroyTexture(). The caller should not free it.

    Args:
        texture: The texture to lock for access, which must be created with
                 `SDL_TEXTUREACCESS_STREAMING`.
        rect: A pointer to the rectangle to lock for access. If the rect is
              NULL, the entire texture will be locked.
        surface: A pointer to an SDL surface of size **rect**. Don't assume
                 any specific pixel content.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LockTextureToSurface.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_LockTextureToSurface", def(texture: Ptr[Texture, O_texture], rect: Ptr[Rect, O_rect], surface: Ptr[OptPtr[Surface, ExternalOrigin[mut=True]], O_surface]) thin abi("C") -> Bool]()(texture, rect, surface)
    if not _ffi_ret:
        raise Error(get_error())


def unlock_texture[O_texture: Origin, //](texture: Ptr[Texture, O_texture]) raises -> None:
    """Unlock a texture, uploading the changes to video memory, if needed.

    **Warning**: Please note that SDL_LockTexture() is intended to be
    write-only; it will not guarantee the previous contents of the texture will
    be provided. You must fully initialize any area of a texture that you lock
    before unlocking it, as the pixels might otherwise be uninitialized memory.

    Which is to say: locking and immediately unlocking a texture can result in
    corrupted textures, depending on the renderer in use.

    Args:
        texture: A texture locked by SDL_LockTexture().

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UnlockTexture.
    """

    return _get_dylib_function[lib, "SDL_UnlockTexture", def(texture: Ptr[Texture, O_texture]) thin abi("C") -> None]()(texture)


def set_render_target[O_renderer: Origin, O_texture: Origin, //](renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture]) raises:
    """Set a texture as the current rendering target.

    The default render target is the window for which the renderer was created.
    To stop rendering to a texture and render to the window again, call this
    function with a NULL `texture`.

    Viewport, cliprect, scale, and logical presentation are unique to each
    render target. Get and set functions for these states apply to the current
    render target set by this function, and those states persist on each target
    when the current render target changes.

    Args:
        renderer: The rendering context.
        texture: The targeted texture, which must be created with the
                 `SDL_TEXTUREACCESS_TARGET` flag, or NULL to render to the
                 window instead of a texture.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetRenderTarget.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetRenderTarget", def(renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture]) thin abi("C") -> Bool]()(renderer, texture)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_target[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer]) raises -> Ptr[Texture, ExternalOrigin[mut=True]]:
    """Get the current render target.

    The default render target is the window for which the renderer was created,
    and is reported a NULL here.

    Args:
        renderer: The rendering context.

    Returns:
        The current render target or NULL for the default render target.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderTarget.
    """

    return _get_dylib_function[lib, "SDL_GetRenderTarget", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> OptPtr[Texture, ExternalOrigin[mut=True]]]()(renderer).value()


def set_render_logical_presentation[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], w: c_int, h: c_int, mode: RendererLogicalPresentation) raises:
    """Set a device-independent resolution and presentation mode for rendering.

    This function sets the width and height of the logical rendering output.
    The renderer will act as if the current render target is always the
    requested dimensions, scaling to the actual resolution as necessary.

    This can be useful for games that expect a fixed size, but would like to
    scale the output to whatever is available, regardless of how a user resizes
    a window, or if the display is high DPI.

    Logical presentation can be used with both render target textures and the
    renderer's window; the state is unique to each render target, and this
    function sets the state for the current render target. It might be useful
    to draw to a texture that matches the window dimensions with logical
    presentation enabled, and then draw that texture across the entire window
    with logical presentation disabled. Be careful not to render both with
    logical presentation enabled, however, as this could produce
    double-letterboxing, etc.

    You can disable logical coordinates by setting the mode to
    SDL_LOGICAL_PRESENTATION_DISABLED, and in that case you get the full pixel
    resolution of the render target; it is safe to toggle logical presentation
    during the rendering of a frame: perhaps most of the rendering is done to
    specific dimensions but to make fonts look sharp, the app turns off logical
    presentation while drawing text, for example.

    For the renderer's window, letterboxing is drawn into the framebuffer if
    logical presentation is enabled during SDL_RenderPresent; be sure to
    reenable it before presenting if you were toggling it, otherwise the
    letterbox areas might have artifacts from previous frames (or artifacts
    from external overlays, etc). Letterboxing is never drawn into texture
    render targets; be sure to call SDL_RenderClear() before drawing into the
    texture so the letterboxing areas are cleared, if appropriate.

    You can convert coordinates in an event into rendering coordinates using
    SDL_ConvertEventToRenderCoordinates().

    Args:
        renderer: The rendering context.
        w: The width of the logical resolution.
        h: The height of the logical resolution.
        mode: The presentation mode used.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetRenderLogicalPresentation.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetRenderLogicalPresentation", def(renderer: Ptr[Renderer, O_renderer], w: c_int, h: c_int, mode: RendererLogicalPresentation) thin abi("C") -> Bool]()(renderer, w, h, mode)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_logical_presentation[O_renderer: Origin, O_w: Origin, O_h: Origin, O_mode: Origin, //](renderer: Ptr[Renderer, O_renderer], w: Ptr[c_int, O_w], h: Ptr[c_int, O_h], mode: Ptr[RendererLogicalPresentation, O_mode]) raises:
    """Get device independent resolution and presentation mode for rendering.

    This function gets the width and height of the logical rendering output, or
    the output size in pixels if a logical resolution is not enabled.

    Each render target has its own logical presentation state. This function
    gets the state for the current render target.

    Args:
        renderer: The rendering context.
        w: An int to be filled with the width.
        h: An int to be filled with the height.
        mode: The presentation mode used.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderLogicalPresentation.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderLogicalPresentation", def(renderer: Ptr[Renderer, O_renderer], w: Ptr[c_int, O_w], h: Ptr[c_int, O_h], mode: Ptr[RendererLogicalPresentation, O_mode]) thin abi("C") -> Bool]()(renderer, w, h, mode)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_logical_presentation_rect[O_renderer: Origin, O_rect: Origin, //](renderer: Ptr[Renderer, O_renderer], rect: Ptr[FRect, O_rect]) raises:
    """Get the final presentation rectangle for rendering.

    This function returns the calculated rectangle used for logical
    presentation, based on the presentation mode and output size. If logical
    presentation is disabled, it will fill the rectangle with the output size,
    in pixels.

    Each render target has its own logical presentation state. This function
    gets the rectangle for the current render target.

    Args:
        renderer: The rendering context.
        rect: A pointer filled in with the final presentation rectangle, may
              be NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderLogicalPresentationRect.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderLogicalPresentationRect", def(renderer: Ptr[Renderer, O_renderer], rect: Ptr[FRect, O_rect]) thin abi("C") -> Bool]()(renderer, rect)
    if not _ffi_ret:
        raise Error(get_error())


def render_coordinates_from_window[O_renderer: Origin, O_x: Origin, O_y: Origin, //](renderer: Ptr[Renderer, O_renderer], window_x: c_float, window_y: c_float, x: Ptr[c_float, O_x], y: Ptr[c_float, O_y]) raises:
    """Get a point in render coordinates when given a point in window coordinates.

    This takes into account several states:

    - The window dimensions.
    - The logical presentation settings (SDL_SetRenderLogicalPresentation)
    - The scale (SDL_SetRenderScale)
    - The viewport (SDL_SetRenderViewport)

    Args:
        renderer: The rendering context.
        window_x: The x coordinate in window coordinates.
        window_y: The y coordinate in window coordinates.
        x: A pointer filled with the x coordinate in render coordinates.
        y: A pointer filled with the y coordinate in render coordinates.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderCoordinatesFromWindow.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderCoordinatesFromWindow", def(renderer: Ptr[Renderer, O_renderer], window_x: c_float, window_y: c_float, x: Ptr[c_float, O_x], y: Ptr[c_float, O_y]) thin abi("C") -> Bool]()(renderer, window_x, window_y, x, y)
    if not _ffi_ret:
        raise Error(get_error())


def render_coordinates_to_window[O_renderer: Origin, O_window_x: Origin, O_window_y: Origin, //](renderer: Ptr[Renderer, O_renderer], x: c_float, y: c_float, window_x: Ptr[c_float, O_window_x], window_y: Ptr[c_float, O_window_y]) raises:
    """Get a point in window coordinates when given a point in render coordinates.

    This takes into account several states:

    - The window dimensions.
    - The logical presentation settings (SDL_SetRenderLogicalPresentation)
    - The scale (SDL_SetRenderScale)
    - The viewport (SDL_SetRenderViewport)

    Args:
        renderer: The rendering context.
        x: The x coordinate in render coordinates.
        y: The y coordinate in render coordinates.
        window_x: A pointer filled with the x coordinate in window
                  coordinates.
        window_y: A pointer filled with the y coordinate in window
                  coordinates.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderCoordinatesToWindow.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderCoordinatesToWindow", def(renderer: Ptr[Renderer, O_renderer], x: c_float, y: c_float, window_x: Ptr[c_float, O_window_x], window_y: Ptr[c_float, O_window_y]) thin abi("C") -> Bool]()(renderer, x, y, window_x, window_y)
    if not _ffi_ret:
        raise Error(get_error())


def convert_event_to_render_coordinates[O_renderer: Origin, O_event: Origin, //](renderer: Ptr[Renderer, O_renderer], event: Ptr[Event, O_event]) raises:
    """Convert the coordinates in an event to render coordinates.

    This takes into account several states:

    - The window dimensions.
    - The logical presentation settings (SDL_SetRenderLogicalPresentation)
    - The scale (SDL_SetRenderScale)
    - The viewport (SDL_SetRenderViewport)

    Various event types are converted with this function: mouse, touch, pen,
    etc.

    Touch coordinates are converted from normalized coordinates in the window
    to non-normalized rendering coordinates.

    Relative mouse coordinates (xrel and yrel event fields) are _also_
    converted. Applications that do not want these fields converted should use
    SDL_RenderCoordinatesFromWindow() on the specific event fields instead of
    converting the entire event structure.

    Once converted, coordinates may be outside the rendering area.

    Args:
        renderer: The rendering context.
        event: The event to modify.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ConvertEventToRenderCoordinates.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_ConvertEventToRenderCoordinates", def(renderer: Ptr[Renderer, O_renderer], event: Ptr[Event, O_event]) thin abi("C") -> Bool]()(renderer, event)
    if not _ffi_ret:
        raise Error(get_error())


def set_render_viewport[O_renderer: Origin, O_rect: Origin, //](renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) raises:
    """Set the drawing area for rendering on the current target.

    Drawing will clip to this area (separately from any clipping done with
    SDL_SetRenderClipRect), and the top left of the area will become coordinate
    (0, 0) for future drawing commands.

    The area's width and height must be >= 0.

    Each render target has its own viewport. This function sets the viewport
    for the current render target.

    Args:
        renderer: The rendering context.
        rect: The SDL_Rect structure representing the drawing area, or NULL
              to set the viewport to the entire target.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetRenderViewport.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetRenderViewport", def(renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) thin abi("C") -> Bool]()(renderer, rect)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_viewport[O_renderer: Origin, O_rect: Origin, //](renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) raises:
    """Get the drawing area for the current target.

    Each render target has its own viewport. This function gets the viewport
    for the current render target.

    Args:
        renderer: The rendering context.
        rect: An SDL_Rect structure filled in with the current drawing area.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderViewport.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderViewport", def(renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) thin abi("C") -> Bool]()(renderer, rect)
    if not _ffi_ret:
        raise Error(get_error())


def render_viewport_set[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer]) raises -> Bool:
    """Return whether an explicit rectangle was set as the viewport.

    This is useful if you're saving and restoring the viewport and want to know
    whether you should restore a specific rectangle or NULL.

    Each render target has its own viewport. This function checks the viewport
    for the current render target.

    Args:
        renderer: The rendering context.

    Returns:
        True if the viewport was set to a specific rectangle, or false if
        it was set to NULL (the entire target).

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderViewportSet.
    """

    return _get_dylib_function[lib, "SDL_RenderViewportSet", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> Bool]()(renderer)


def get_render_safe_area[O_renderer: Origin, O_rect: Origin, //](renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) raises:
    """Get the safe area for rendering within the current viewport.

    Some devices have portions of the screen which are partially obscured or
    not interactive, possibly due to on-screen controls, curved edges, camera
    notches, TV overscan, etc. This function provides the area of the current
    viewport which is safe to have interactible content. You should continue
    rendering into the rest of the render target, but it should not contain
    visually important or interactible content.

    Args:
        renderer: The rendering context.
        rect: A pointer filled in with the area that is safe for interactive
              content.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderSafeArea.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderSafeArea", def(renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) thin abi("C") -> Bool]()(renderer, rect)
    if not _ffi_ret:
        raise Error(get_error())


def set_render_clip_rect[O_renderer: Origin, O_rect: Origin, //](renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) raises:
    """Set the clip rectangle for rendering on the specified target.

    Each render target has its own clip rectangle. This function sets the
    cliprect for the current render target.

    Args:
        renderer: The rendering context.
        rect: An SDL_Rect structure representing the clip area, relative to
              the viewport, or NULL to disable clipping.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetRenderClipRect.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetRenderClipRect", def(renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) thin abi("C") -> Bool]()(renderer, rect)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_clip_rect[O_renderer: Origin, O_rect: Origin, //](renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) raises:
    """Get the clip rectangle for the current target.

    Each render target has its own clip rectangle. This function gets the
    cliprect for the current render target.

    Args:
        renderer: The rendering context.
        rect: An SDL_Rect structure filled in with the current clipping area
              or an empty rectangle if clipping is disabled.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderClipRect.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderClipRect", def(renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) thin abi("C") -> Bool]()(renderer, rect)
    if not _ffi_ret:
        raise Error(get_error())


def render_clip_enabled[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer]) raises -> Bool:
    """Get whether clipping is enabled on the given render target.

    Each render target has its own clip rectangle. This function checks the
    cliprect for the current render target.

    Args:
        renderer: The rendering context.

    Returns:
        True if clipping is enabled or false if not; call SDL_GetError()
        for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderClipEnabled.
    """

    return _get_dylib_function[lib, "SDL_RenderClipEnabled", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> Bool]()(renderer)


def set_render_scale[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], scale_x: c_float, scale_y: c_float) raises:
    """Set the drawing scale for rendering on the current target.

    The drawing coordinates are scaled by the x/y scaling factors before they
    are used by the renderer. This allows resolution independent drawing with a
    single coordinate system.

    If this results in scaling or subpixel drawing by the rendering backend, it
    will be handled using the appropriate quality hints. For best results use
    integer scaling factors.

    Each render target has its own scale. This function sets the scale for the
    current render target.

    Args:
        renderer: The rendering context.
        scale_x: The horizontal scaling factor.
        scale_y: The vertical scaling factor.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetRenderScale.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetRenderScale", def(renderer: Ptr[Renderer, O_renderer], scale_x: c_float, scale_y: c_float) thin abi("C") -> Bool]()(renderer, scale_x, scale_y)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_scale[O_renderer: Origin, O_scale_x: Origin, O_scale_y: Origin, //](renderer: Ptr[Renderer, O_renderer], scale_x: Ptr[c_float, O_scale_x], scale_y: Ptr[c_float, O_scale_y]) raises:
    """Get the drawing scale for the current target.

    Each render target has its own scale. This function gets the scale for the
    current render target.

    Args:
        renderer: The rendering context.
        scale_x: A pointer filled in with the horizontal scaling factor.
        scale_y: A pointer filled in with the vertical scaling factor.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderScale.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderScale", def(renderer: Ptr[Renderer, O_renderer], scale_x: Ptr[c_float, O_scale_x], scale_y: Ptr[c_float, O_scale_y]) thin abi("C") -> Bool]()(renderer, scale_x, scale_y)
    if not _ffi_ret:
        raise Error(get_error())


def set_render_draw_color[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], r: UInt8, g: UInt8, b: UInt8, a: UInt8) raises:
    """Set the color used for drawing operations.

    Set the color for drawing or filling rectangles, lines, and points, and for
    SDL_RenderClear().

    Args:
        renderer: The rendering context.
        r: The red value used to draw on the rendering target.
        g: The green value used to draw on the rendering target.
        b: The blue value used to draw on the rendering target.
        a: The alpha value used to draw on the rendering target; usually
           `SDL_ALPHA_OPAQUE` (255). Use SDL_SetRenderDrawBlendMode to
           specify how the alpha channel is used.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetRenderDrawColor.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetRenderDrawColor", def(renderer: Ptr[Renderer, O_renderer], r: UInt8, g: UInt8, b: UInt8, a: UInt8) thin abi("C") -> Bool]()(renderer, r, g, b, a)
    if not _ffi_ret:
        raise Error(get_error())


def set_render_draw_color_float[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], r: c_float, g: c_float, b: c_float, a: c_float) raises:
    """Set the color used for drawing operations (Rect, Line and Clear).

    Set the color for drawing or filling rectangles, lines, and points, and for
    SDL_RenderClear().

    Args:
        renderer: The rendering context.
        r: The red value used to draw on the rendering target.
        g: The green value used to draw on the rendering target.
        b: The blue value used to draw on the rendering target.
        a: The alpha value used to draw on the rendering target. Use
           SDL_SetRenderDrawBlendMode to specify how the alpha channel is
           used.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetRenderDrawColorFloat.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetRenderDrawColorFloat", def(renderer: Ptr[Renderer, O_renderer], r: c_float, g: c_float, b: c_float, a: c_float) thin abi("C") -> Bool]()(renderer, r, g, b, a)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_draw_color[O_renderer: Origin, O_r: Origin, O_g: Origin, O_b: Origin, O_a: Origin, //](renderer: Ptr[Renderer, O_renderer], r: Ptr[UInt8, O_r], g: Ptr[UInt8, O_g], b: Ptr[UInt8, O_b], a: Ptr[UInt8, O_a]) raises:
    """Get the color used for drawing operations (Rect, Line and Clear).

    Args:
        renderer: The rendering context.
        r: A pointer filled in with the red value used to draw on the
           rendering target.
        g: A pointer filled in with the green value used to draw on the
           rendering target.
        b: A pointer filled in with the blue value used to draw on the
           rendering target.
        a: A pointer filled in with the alpha value used to draw on the
           rendering target; usually `SDL_ALPHA_OPAQUE` (255).

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderDrawColor.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderDrawColor", def(renderer: Ptr[Renderer, O_renderer], r: Ptr[UInt8, O_r], g: Ptr[UInt8, O_g], b: Ptr[UInt8, O_b], a: Ptr[UInt8, O_a]) thin abi("C") -> Bool]()(renderer, r, g, b, a)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_draw_color_float[O_renderer: Origin, O_r: Origin, O_g: Origin, O_b: Origin, O_a: Origin, //](renderer: Ptr[Renderer, O_renderer], r: Ptr[c_float, O_r], g: Ptr[c_float, O_g], b: Ptr[c_float, O_b], a: Ptr[c_float, O_a]) raises:
    """Get the color used for drawing operations (Rect, Line and Clear).

    Args:
        renderer: The rendering context.
        r: A pointer filled in with the red value used to draw on the
           rendering target.
        g: A pointer filled in with the green value used to draw on the
           rendering target.
        b: A pointer filled in with the blue value used to draw on the
           rendering target.
        a: A pointer filled in with the alpha value used to draw on the
           rendering target.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderDrawColorFloat.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderDrawColorFloat", def(renderer: Ptr[Renderer, O_renderer], r: Ptr[c_float, O_r], g: Ptr[c_float, O_g], b: Ptr[c_float, O_b], a: Ptr[c_float, O_a]) thin abi("C") -> Bool]()(renderer, r, g, b, a)
    if not _ffi_ret:
        raise Error(get_error())


def set_render_color_scale[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], scale: c_float) raises:
    """Set the color scale used for render operations.

    The color scale is an additional scale multiplied into the pixel color
    value while rendering. This can be used to adjust the brightness of colors
    during HDR rendering, or changing HDR video brightness when playing on an
    SDR display.

    The color scale does not affect the alpha channel, only the color
    brightness.

    Args:
        renderer: The rendering context.
        scale: The color scale value.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetRenderColorScale.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetRenderColorScale", def(renderer: Ptr[Renderer, O_renderer], scale: c_float) thin abi("C") -> Bool]()(renderer, scale)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_color_scale[O_renderer: Origin, O_scale: Origin, //](renderer: Ptr[Renderer, O_renderer], scale: Ptr[c_float, O_scale]) raises:
    """Get the color scale used for render operations.

    Args:
        renderer: The rendering context.
        scale: A pointer filled in with the current color scale value.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderColorScale.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderColorScale", def(renderer: Ptr[Renderer, O_renderer], scale: Ptr[c_float, O_scale]) thin abi("C") -> Bool]()(renderer, scale)
    if not _ffi_ret:
        raise Error(get_error())


def set_render_draw_blend_mode[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], blend_mode: BlendMode) raises:
    """Set the blend mode used for drawing operations (Fill and Line).

    If the blend mode is not supported, the closest supported mode is chosen.

    Args:
        renderer: The rendering context.
        blend_mode: The SDL_BlendMode to use for blending.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetRenderDrawBlendMode.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetRenderDrawBlendMode", def(renderer: Ptr[Renderer, O_renderer], blend_mode: BlendMode) thin abi("C") -> Bool]()(renderer, blend_mode)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_draw_blend_mode[O_renderer: Origin, O_blend_mode: Origin, //](renderer: Ptr[Renderer, O_renderer], blend_mode: Ptr[BlendMode, O_blend_mode]) raises:
    """Get the blend mode used for drawing operations.

    Args:
        renderer: The rendering context.
        blend_mode: A pointer filled in with the current SDL_BlendMode.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderDrawBlendMode.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderDrawBlendMode", def(renderer: Ptr[Renderer, O_renderer], blend_mode: Ptr[BlendMode, O_blend_mode]) thin abi("C") -> Bool]()(renderer, blend_mode)
    if not _ffi_ret:
        raise Error(get_error())


def render_clear[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer]) raises:
    """Clear the current rendering target with the drawing color.

    This function clears the entire rendering target, ignoring the viewport and
    the clip rectangle. Note, that clearing will also set/fill all pixels of
    the rendering target to current renderer draw color, so make sure to invoke
    SDL_SetRenderDrawColor() when needed.

    Args:
        renderer: The rendering context.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderClear.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderClear", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> Bool]()(renderer)
    if not _ffi_ret:
        raise Error(get_error())


def render_point[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], x: c_float, y: c_float) raises:
    """Draw a point on the current rendering target at subpixel precision.

    Args:
        renderer: The renderer which should draw a point.
        x: The x coordinate of the point.
        y: The y coordinate of the point.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderPoint.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderPoint", def(renderer: Ptr[Renderer, O_renderer], x: c_float, y: c_float) thin abi("C") -> Bool]()(renderer, x, y)
    if not _ffi_ret:
        raise Error(get_error())


def render_points[O_renderer: Origin, O_points: Origin, //](renderer: Ptr[Renderer, O_renderer], points: Ptr[FPoint, O_points], count: c_int) raises:
    """Draw multiple points on the current rendering target at subpixel precision.

    Args:
        renderer: The renderer which should draw multiple points.
        points: The points to draw.
        count: The number of points to draw.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderPoints.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderPoints", def(renderer: Ptr[Renderer, O_renderer], points: Ptr[FPoint, O_points], count: c_int) thin abi("C") -> Bool]()(renderer, points, count)
    if not _ffi_ret:
        raise Error(get_error())


def render_line[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], x1: c_float, y1: c_float, x2: c_float, y2: c_float) raises:
    """Draw a line on the current rendering target at subpixel precision.

    Args:
        renderer: The renderer which should draw a line.
        x1: The x coordinate of the start point.
        y1: The y coordinate of the start point.
        x2: The x coordinate of the end point.
        y2: The y coordinate of the end point.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderLine.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderLine", def(renderer: Ptr[Renderer, O_renderer], x1: c_float, y1: c_float, x2: c_float, y2: c_float) thin abi("C") -> Bool]()(renderer, x1, y1, x2, y2)
    if not _ffi_ret:
        raise Error(get_error())


def render_lines[O_renderer: Origin, O_points: Origin, //](renderer: Ptr[Renderer, O_renderer], points: Ptr[FPoint, O_points], count: c_int) raises:
    """Draw a series of connected lines on the current rendering target at
    subpixel precision.

    Args:
        renderer: The renderer which should draw multiple lines.
        points: The points along the lines.
        count: The number of points, drawing count-1 lines.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderLines.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderLines", def(renderer: Ptr[Renderer, O_renderer], points: Ptr[FPoint, O_points], count: c_int) thin abi("C") -> Bool]()(renderer, points, count)
    if not _ffi_ret:
        raise Error(get_error())


def render_rect[O_renderer: Origin, O_rect: Origin, //](renderer: Ptr[Renderer, O_renderer], rect: Ptr[FRect, O_rect]) raises:
    """Draw a rectangle on the current rendering target at subpixel precision.

    Args:
        renderer: The renderer which should draw a rectangle.
        rect: A pointer to the destination rectangle, or NULL to outline the
              entire rendering target.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderRect.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderRect", def(renderer: Ptr[Renderer, O_renderer], rect: Ptr[FRect, O_rect]) thin abi("C") -> Bool]()(renderer, rect)
    if not _ffi_ret:
        raise Error(get_error())


def render_rects[O_renderer: Origin, O_rects: Origin, //](renderer: Ptr[Renderer, O_renderer], rects: Ptr[FRect, O_rects], count: c_int) raises:
    """Draw some number of rectangles on the current rendering target at subpixel
    precision.

    Args:
        renderer: The renderer which should draw multiple rectangles.
        rects: A pointer to an array of destination rectangles.
        count: The number of rectangles.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderRects.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderRects", def(renderer: Ptr[Renderer, O_renderer], rects: Ptr[FRect, O_rects], count: c_int) thin abi("C") -> Bool]()(renderer, rects, count)
    if not _ffi_ret:
        raise Error(get_error())


def render_fill_rect[O_renderer: Origin, O_rect: Origin, //](renderer: Ptr[Renderer, O_renderer], rect: Ptr[FRect, O_rect]) raises:
    """Fill a rectangle on the current rendering target with the drawing color at
    subpixel precision.

    Args:
        renderer: The renderer which should fill a rectangle.
        rect: A pointer to the destination rectangle, or NULL for the entire
              rendering target.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderFillRect.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderFillRect", def(renderer: Ptr[Renderer, O_renderer], rect: Ptr[FRect, O_rect]) thin abi("C") -> Bool]()(renderer, rect)
    if not _ffi_ret:
        raise Error(get_error())


def render_fill_rects[O_renderer: Origin, O_rects: Origin, //](renderer: Ptr[Renderer, O_renderer], rects: Ptr[FRect, O_rects], count: c_int) raises:
    """Fill some number of rectangles on the current rendering target with the
    drawing color at subpixel precision.

    Args:
        renderer: The renderer which should fill multiple rectangles.
        rects: A pointer to an array of destination rectangles.
        count: The number of rectangles.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderFillRects.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderFillRects", def(renderer: Ptr[Renderer, O_renderer], rects: Ptr[FRect, O_rects], count: c_int) thin abi("C") -> Bool]()(renderer, rects, count)
    if not _ffi_ret:
        raise Error(get_error())


def render_texture[O_renderer: Origin, O_texture: Origin, O_srcrect: Origin, O_dstrect: Origin, //](renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], srcrect: Ptr[FRect, O_srcrect], dstrect: Ptr[FRect, O_dstrect]) raises:
    """Copy a portion of the texture to the current rendering target at subpixel
    precision.

    Args:
        renderer: The renderer which should copy parts of a texture.
        texture: The source texture.
        srcrect: A pointer to the source rectangle, or NULL for the entire
                 texture.
        dstrect: A pointer to the destination rectangle, or NULL for the
                 entire rendering target.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderTexture.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderTexture", def(renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], srcrect: Ptr[FRect, O_srcrect], dstrect: Ptr[FRect, O_dstrect]) thin abi("C") -> Bool]()(renderer, texture, srcrect, dstrect)
    if not _ffi_ret:
        raise Error(get_error())


def render_texture_rotated[O_renderer: Origin, O_texture: Origin, O_srcrect: Origin, O_dstrect: Origin, O_center: Origin, //](renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], srcrect: Ptr[FRect, O_srcrect], dstrect: Ptr[FRect, O_dstrect], angle: c_double, center: Ptr[FPoint, O_center], flip: FlipMode) raises:
    """Copy a portion of the source texture to the current rendering target, with
    rotation and flipping, at subpixel precision.

    Args:
        renderer: The renderer which should copy parts of a texture.
        texture: The source texture.
        srcrect: A pointer to the source rectangle, or NULL for the entire
                 texture.
        dstrect: A pointer to the destination rectangle, or NULL for the
                 entire rendering target.
        angle: An angle in degrees that indicates the rotation that will be
               applied to dstrect, rotating it in a clockwise direction.
        center: A pointer to a point indicating the point around which
                dstrect will be rotated (if NULL, rotation will be done
                around dstrect.w/2, dstrect.h/2).
        flip: An SDL_FlipMode value stating which flipping actions should be
              performed on the texture.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderTextureRotated.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderTextureRotated", def(renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], srcrect: Ptr[FRect, O_srcrect], dstrect: Ptr[FRect, O_dstrect], angle: c_double, center: Ptr[FPoint, O_center], flip: FlipMode) thin abi("C") -> Bool]()(renderer, texture, srcrect, dstrect, angle, center, flip)
    if not _ffi_ret:
        raise Error(get_error())


def render_texture_affine[O_renderer: Origin, O_texture: Origin, O_srcrect: Origin, O_origin: Origin, O_right: Origin, O_down: Origin, //](renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], srcrect: Ptr[FRect, O_srcrect], origin: Ptr[FPoint, O_origin], right: Ptr[FPoint, O_right], down: Ptr[FPoint, O_down]) raises:
    """Copy a portion of the source texture to the current rendering target, with
    affine transform, at subpixel precision.

    Args:
        renderer: The renderer which should copy parts of a texture.
        texture: The source texture.
        srcrect: A pointer to the source rectangle, or NULL for the entire
                 texture.
        origin: A pointer to a point indicating where the top-left corner of
                srcrect should be mapped to, or NULL for the rendering
                target's origin.
        right: A pointer to a point indicating where the top-right corner of
               srcrect should be mapped to, or NULL for the rendering
               target's top-right corner.
        down: A pointer to a point indicating where the bottom-left corner of
              srcrect should be mapped to, or NULL for the rendering target's
              bottom-left corner.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        You may only call this function from the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderTextureAffine.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderTextureAffine", def(renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], srcrect: Ptr[FRect, O_srcrect], origin: Ptr[FPoint, O_origin], right: Ptr[FPoint, O_right], down: Ptr[FPoint, O_down]) thin abi("C") -> Bool]()(renderer, texture, srcrect, origin, right, down)
    if not _ffi_ret:
        raise Error(get_error())


def render_texture_tiled[O_renderer: Origin, O_texture: Origin, O_srcrect: Origin, O_dstrect: Origin, //](renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], srcrect: Ptr[FRect, O_srcrect], scale: c_float, dstrect: Ptr[FRect, O_dstrect]) raises:
    """Tile a portion of the texture to the current rendering target at subpixel
    precision.

    The pixels in `srcrect` will be repeated as many times as needed to
    completely fill `dstrect`.

    Args:
        renderer: The renderer which should copy parts of a texture.
        texture: The source texture.
        srcrect: A pointer to the source rectangle, or NULL for the entire
                 texture.
        scale: The scale used to transform srcrect into the destination
               rectangle, e.g. a 32x32 texture with a scale of 2 would fill
               64x64 tiles.
        dstrect: A pointer to the destination rectangle, or NULL for the
                 entire rendering target.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderTextureTiled.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderTextureTiled", def(renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], srcrect: Ptr[FRect, O_srcrect], scale: c_float, dstrect: Ptr[FRect, O_dstrect]) thin abi("C") -> Bool]()(renderer, texture, srcrect, scale, dstrect)
    if not _ffi_ret:
        raise Error(get_error())


def render_texture_9grid[O_renderer: Origin, O_texture: Origin, O_srcrect: Origin, O_dstrect: Origin, //](renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], srcrect: Ptr[FRect, O_srcrect], left_width: c_float, right_width: c_float, top_height: c_float, bottom_height: c_float, scale: c_float, dstrect: Ptr[FRect, O_dstrect]) raises:
    """Perform a scaled copy using the 9-grid algorithm to the current rendering
    target at subpixel precision.

    The pixels in the texture are split into a 3x3 grid, using the different
    corner sizes for each corner, and the sides and center making up the
    remaining pixels. The corners are then scaled using `scale` and fit into
    the corners of the destination rectangle. The sides and center are then
    stretched into place to cover the remaining destination rectangle.

    Args:
        renderer: The renderer which should copy parts of a texture.
        texture: The source texture.
        srcrect: The SDL_Rect structure representing the rectangle to be used
                 for the 9-grid, or NULL to use the entire texture.
        left_width: The width, in pixels, of the left corners in `srcrect`.
        right_width: The width, in pixels, of the right corners in `srcrect`.
        top_height: The height, in pixels, of the top corners in `srcrect`.
        bottom_height: The height, in pixels, of the bottom corners in
                       `srcrect`.
        scale: The scale used to transform the corner of `srcrect` into the
               corner of `dstrect`, or 0.0f for an unscaled copy.
        dstrect: A pointer to the destination rectangle, or NULL for the
                 entire rendering target.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderTexture9Grid.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderTexture9Grid", def(renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], srcrect: Ptr[FRect, O_srcrect], left_width: c_float, right_width: c_float, top_height: c_float, bottom_height: c_float, scale: c_float, dstrect: Ptr[FRect, O_dstrect]) thin abi("C") -> Bool]()(renderer, texture, srcrect, left_width, right_width, top_height, bottom_height, scale, dstrect)
    if not _ffi_ret:
        raise Error(get_error())


def render_geometry[O_renderer: Origin, O_texture: Origin, O_vertices: Origin, O_indices: Origin, //](renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], vertices: Ptr[Vertex, O_vertices], num_vertices: c_int, indices: Ptr[c_int, O_indices], num_indices: c_int) raises:
    """Render a list of triangles, optionally using a texture and indices into the
    vertex array Color and alpha modulation is done per vertex
    (SDL_SetTextureColorMod and SDL_SetTextureAlphaMod are ignored).

    Args:
        renderer: The rendering context.
        texture: (optional) The SDL texture to use.
        vertices: Vertices.
        num_vertices: Number of vertices.
        indices: (optional) An array of integer indices into the 'vertices'
                 array, if NULL all vertices will be rendered in sequential
                 order.
        num_indices: Number of indices.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderGeometry.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderGeometry", def(renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], vertices: Ptr[Vertex, O_vertices], num_vertices: c_int, indices: Ptr[c_int, O_indices], num_indices: c_int) thin abi("C") -> Bool]()(renderer, texture, vertices, num_vertices, indices, num_indices)
    if not _ffi_ret:
        raise Error(get_error())


def render_geometry_raw[O_renderer: Origin, O_texture: Origin, O_xy: Origin, O_color: Origin, O_uv: Origin, O_indices: Origin, //](renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], xy: Ptr[c_float, O_xy], xy_stride: c_int, color: Ptr[FColor, O_color], color_stride: c_int, uv: Ptr[c_float, O_uv], uv_stride: c_int, num_vertices: c_int, indices: Ptr[NoneType, O_indices], num_indices: c_int, size_indices: c_int) raises:
    """Render a list of triangles, optionally using a texture and indices into the
    vertex arrays Color and alpha modulation is done per vertex
    (SDL_SetTextureColorMod and SDL_SetTextureAlphaMod are ignored).

    Args:
        renderer: The rendering context.
        texture: (optional) The SDL texture to use.
        xy: Vertex positions.
        xy_stride: Byte size to move from one element to the next element.
        color: Vertex colors (as SDL_FColor).
        color_stride: Byte size to move from one element to the next element.
        uv: Vertex normalized texture coordinates.
        uv_stride: Byte size to move from one element to the next element.
        num_vertices: Number of vertices.
        indices: (optional) An array of indices into the 'vertices' arrays,
                 if NULL all vertices will be rendered in sequential order.
        num_indices: Number of indices.
        size_indices: Index size: 1 (byte), 2 (short), 4 (int).

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderGeometryRaw.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderGeometryRaw", def(renderer: Ptr[Renderer, O_renderer], texture: Ptr[Texture, O_texture], xy: Ptr[c_float, O_xy], xy_stride: c_int, color: Ptr[FColor, O_color], color_stride: c_int, uv: Ptr[c_float, O_uv], uv_stride: c_int, num_vertices: c_int, indices: Ptr[NoneType, O_indices], num_indices: c_int, size_indices: c_int) thin abi("C") -> Bool]()(renderer, texture, xy, xy_stride, color, color_stride, uv, uv_stride, num_vertices, indices, num_indices, size_indices)
    if not _ffi_ret:
        raise Error(get_error())


def render_read_pixels[O_renderer: Origin, O_rect: Origin, //](renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect], out ret: Ptr[Surface, ExternalOrigin[mut=True]]) raises:
    """Read pixels from the current rendering target.

    The returned surface contains pixels inside the desired area clipped to the
    current viewport, and should be freed with SDL_DestroySurface().

    Note that this returns the actual pixels on the screen, so if you are using
    logical presentation you should use SDL_GetRenderLogicalPresentationRect()
    to get the area containing your content.

    **WARNING**: This is a very slow operation, and should not be used
    frequently. If you're using this on the main rendering target, it should be
    called after rendering and before SDL_RenderPresent().

    Args:
        renderer: The rendering context.
        rect: An SDL_Rect structure representing the area to read, which will
              be clipped to the current viewport, or NULL for the entire
              viewport.

    Returns:
        A new SDL_Surface on success or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderReadPixels.
    """

    _ffi_ret = _get_dylib_function[lib, "SDL_RenderReadPixels", def(renderer: Ptr[Renderer, O_renderer], rect: Ptr[Rect, O_rect]) thin abi("C") -> OptPtr[Surface, ExternalOrigin[mut=True]]]()(renderer, rect)
    if not _ffi_ret:
        raise Error(get_error())
    ret = _ffi_ret.value()


def render_present[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer]) raises:
    """Update the screen with any rendering performed since the previous call.

    SDL's rendering functions operate on a backbuffer; that is, calling a
    rendering function such as SDL_RenderLine() does not directly put a line on
    the screen, but rather updates the backbuffer. As such, you compose your
    entire scene and *present* the composed backbuffer to the screen as a
    complete picture.

    Therefore, when using SDL's rendering API, one does all drawing intended
    for the frame, and then calls this function once per frame to present the
    final drawing to the user.

    The backbuffer should be considered invalidated after each present; do not
    assume that previous contents will exist between frames. You are strongly
    encouraged to call SDL_RenderClear() to initialize the backbuffer before
    starting each new frame's drawing, even if you plan to overwrite every
    pixel.

    Please note, that in case of rendering to a texture - there is **no need**
    to call `SDL_RenderPresent` after drawing needed objects to a texture, and
    should not be done; you are only required to change back the rendering
    target to default via `SDL_SetRenderTarget(renderer, NULL)` afterwards, as
    textures by themselves do not have a concept of backbuffers. Calling
    SDL_RenderPresent while rendering to a texture will still update the screen
    with any current drawing that has been done _to the window itself_.

    Args:
        renderer: The rendering context.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderPresent.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderPresent", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> Bool]()(renderer)
    if not _ffi_ret:
        raise Error(get_error())


def destroy_texture[O_texture: Origin, //](texture: Ptr[Texture, O_texture]) raises -> None:
    """Destroy the specified texture.

    Passing NULL or an otherwise invalid texture will set the SDL error message
    to "Invalid texture".

    Args:
        texture: The texture to destroy.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyTexture.
    """

    return _get_dylib_function[lib, "SDL_DestroyTexture", def(texture: Ptr[Texture, O_texture]) thin abi("C") -> None]()(texture)


def destroy_renderer[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer]) raises -> None:
    """Destroy the rendering context for a window and free all associated
    textures.

    This should be called before destroying the associated window.

    Args:
        renderer: The rendering context.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyRenderer.
    """

    return _get_dylib_function[lib, "SDL_DestroyRenderer", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> None]()(renderer)


def flush_renderer[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer]) raises:
    """Force the rendering context to flush any pending commands and state.

    You do not need to (and in fact, shouldn't) call this function unless you
    are planning to call into OpenGL/Direct3D/Metal/whatever directly, in
    addition to using an SDL_Renderer.

    This is for a very-specific case: if you are using SDL's render API, and
    you plan to make OpenGL/D3D/whatever calls in addition to SDL render API
    calls. If this applies, you should call this function between calls to
    SDL's render API and the low-level API you're using in cooperation.

    In all other cases, you can ignore this function.

    This call makes SDL flush any pending rendering work it was queueing up to
    do later in a single batch, and marks any internal cached state as invalid,
    so it'll prepare all its state again later, from scratch.

    This means you do not need to save state in your rendering code to protect
    the SDL renderer. However, there lots of arbitrary pieces of Direct3D and
    OpenGL state that can confuse things; you should use your best judgment and
    be prepared to make changes if specific state needs to be protected.

    Args:
        renderer: The rendering context.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FlushRenderer.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_FlushRenderer", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> Bool]()(renderer)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_metal_layer[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer]) raises -> Ptr[NoneType, ExternalOrigin[mut=True]]:
    """Get the CAMetalLayer associated with the given Metal renderer.

    This function returns `void *`, so SDL doesn't have to include Metal's
    headers, but it can be safely cast to a `CAMetalLayer *`.

    Args:
        renderer: The renderer to query.

    Returns:
        A `CAMetalLayer *` on success, or NULL if the renderer isn't a
        Metal renderer.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderMetalLayer.
    """

    return _get_dylib_function[lib, "SDL_GetRenderMetalLayer", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> OptPtr[NoneType, ExternalOrigin[mut=True]]]()(renderer).value()


def get_render_metal_command_encoder[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer]) raises -> Ptr[NoneType, ExternalOrigin[mut=True]]:
    """Get the Metal command encoder for the current frame.

    This function returns `void *`, so SDL doesn't have to include Metal's
    headers, but it can be safely cast to an `id<MTLRenderCommandEncoder>`.

    This will return NULL if Metal refuses to give SDL a drawable to render to,
    which might happen if the window is hidden/minimized/offscreen. This
    doesn't apply to command encoders for render targets, just the window's
    backbuffer. Check your return values!

    Args:
        renderer: The renderer to query.

    Returns:
        An `id<MTLRenderCommandEncoder>` on success, or NULL if the
        renderer isn't a Metal renderer or there was an error.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderMetalCommandEncoder.
    """

    return _get_dylib_function[lib, "SDL_GetRenderMetalCommandEncoder", def(renderer: Ptr[Renderer, O_renderer]) thin abi("C") -> OptPtr[NoneType, ExternalOrigin[mut=True]]]()(renderer).value()


def add_vulkan_render_semaphores[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], wait_stage_mask: UInt32, wait_semaphore: Int64, signal_semaphore: Int64) raises:
    """Add a set of synchronization semaphores for the current frame.

    The Vulkan renderer will wait for `wait_semaphore` before submitting
    rendering commands and signal `signal_semaphore` after rendering commands
    are complete for this frame.

    This should be called each frame that you want semaphore synchronization.
    The Vulkan renderer may have multiple frames in flight on the GPU, so you
    should have multiple semaphores that are used for synchronization. Querying
    SDL_PROP_RENDERER_VULKAN_SWAPCHAIN_IMAGE_COUNT_NUMBER will give you the
    maximum number of semaphores you'll need.

    Args:
        renderer: The rendering context.
        wait_stage_mask: The VkPipelineStageFlags for the wait.
        wait_semaphore: A VkSempahore to wait on before rendering the current
                        frame, or 0 if not needed.
        signal_semaphore: A VkSempahore that SDL will signal when rendering
                          for the current frame is complete, or 0 if not
                          needed.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is **NOT** safe to call this function from two threads at
        once.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AddVulkanRenderSemaphores.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_AddVulkanRenderSemaphores", def(renderer: Ptr[Renderer, O_renderer], wait_stage_mask: UInt32, wait_semaphore: Int64, signal_semaphore: Int64) thin abi("C") -> Bool]()(renderer, wait_stage_mask, wait_semaphore, signal_semaphore)
    if not _ffi_ret:
        raise Error(get_error())


def set_render_vsync[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], vsync: c_int) raises:
    """Toggle VSync of the given renderer.

    When a renderer is created, vsync defaults to SDL_RENDERER_VSYNC_DISABLED.

    The `vsync` parameter can be 1 to synchronize present with every vertical
    refresh, 2 to synchronize present with every second vertical refresh, etc.,
    SDL_RENDERER_VSYNC_ADAPTIVE for late swap tearing (adaptive vsync), or
    SDL_RENDERER_VSYNC_DISABLED to disable. Not every value is supported by
    every driver, so you should check the return value to see whether the
    requested setting is supported.

    Args:
        renderer: The renderer to toggle.
        vsync: The vertical refresh sync interval.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetRenderVSync.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_SetRenderVSync", def(renderer: Ptr[Renderer, O_renderer], vsync: c_int) thin abi("C") -> Bool]()(renderer, vsync)
    if not _ffi_ret:
        raise Error(get_error())


def get_render_vsync[O_renderer: Origin, O_vsync: Origin, //](renderer: Ptr[Renderer, O_renderer], vsync: Ptr[c_int, O_vsync]) raises:
    """Get VSync of the given renderer.

    Args:
        renderer: The renderer to toggle.
        vsync: An int filled with the current vertical refresh sync interval.
               See SDL_SetRenderVSync() for the meaning of the value.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRenderVSync.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_GetRenderVSync", def(renderer: Ptr[Renderer, O_renderer], vsync: Ptr[c_int, O_vsync]) thin abi("C") -> Bool]()(renderer, vsync)
    if not _ffi_ret:
        raise Error(get_error())


def render_debug_text[O_renderer: Origin, //](renderer: Ptr[Renderer, O_renderer], x: c_float, y: c_float, var str: String) raises:
    """Draw debug text to an SDL_Renderer.

    This function will render a string of text to an SDL_Renderer. Note that
    this is a convenience function for debugging, with severe limitations, and
    not intended to be used for production apps and games.

    Among these limitations:

    - It accepts UTF-8 strings, but will only renders ASCII characters.
    - It has a single, tiny size (8x8 pixels). One can use logical presentation
      or scaling to adjust it, but it will be blurry.
    - It uses a simple, hardcoded bitmap font. It does not allow different font
      selections and it does not support truetype, for proper scaling.
    - It does no word-wrapping and does not treat newline characters as a line
      break. If the text goes out of the window, it's gone.

    For serious text rendering, there are several good options, such as
    SDL_ttf, stb_truetype, or other external libraries.

    On first use, this will create an internal texture for rendering glyphs.
    This texture will live until the renderer is destroyed.

    The text is drawn in the color specified by SDL_SetRenderDrawColor().

    Args:
        renderer: The renderer which should draw a line of text.
        x: The x coordinate where the top-left corner of the text will draw.
        y: The y coordinate where the top-left corner of the text will draw.
        str: The string to render.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenderDebugText.
    """

    var _ffi_ret = _get_dylib_function[lib, "SDL_RenderDebugText", def(renderer: Ptr[Renderer, O_renderer], x: c_float, y: c_float, str: Ptr[mut=False, c_char, origin_of(str)]) thin abi("C") -> Bool]()(renderer, x, y, str.as_c_string_slice().unsafe_ptr())
    if not _ffi_ret:
        raise Error(get_error())
