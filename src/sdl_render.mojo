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

"""Render

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


@register_passable("trivial")
struct TextureAccess(Indexer, Intable):
    """The access pattern allowed for a texture.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TextureAccess.
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

    comptime TEXTUREACCESS_STATIC = Self(0)
    """Changes rarely, not lockable."""
    comptime TEXTUREACCESS_STREAMING = Self(1)
    """Changes frequently, lockable."""
    comptime TEXTUREACCESS_TARGET = Self(2)
    """Texture can be used as a render target."""


@register_passable("trivial")
struct RendererLogicalPresentation(Indexer, Intable):
    """How the logical size is mapped to the output.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RendererLogicalPresentation.
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


fn get_num_render_drivers() raises -> c_int:
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

    return _get_dylib_function[lib, "SDL_GetNumRenderDrivers", fn () -> c_int]()()


fn get_render_driver(index: c_int) raises -> Ptr[c_char, AnyOrigin[False]]:
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

    return _get_dylib_function[lib, "SDL_GetRenderDriver", fn (index: c_int) -> Ptr[c_char, AnyOrigin[False]]]()(index)


fn create_window_and_renderer(var title: String, width: c_int, height: c_int, window_flags: WindowFlags, window: Ptr[Ptr[Window, AnyOrigin[True]], AnyOrigin[True]], renderer: Ptr[Ptr[Renderer, AnyOrigin[True]], AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_CreateWindowAndRenderer", fn (title: Ptr[c_char, AnyOrigin[False]], width: c_int, height: c_int, window_flags: WindowFlags, window: Ptr[Ptr[Window, AnyOrigin[True]], AnyOrigin[True]], renderer: Ptr[Ptr[Renderer, AnyOrigin[True]], AnyOrigin[True]]) -> Bool]()(title.as_c_string_slice().unsafe_ptr(), width, height, window_flags, window, renderer)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_renderer(window: Ptr[Window, AnyOrigin[True]], var name: String) raises -> Ptr[Renderer, AnyOrigin[True]]:
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

    return _get_dylib_function[lib, "SDL_CreateRenderer", fn (window: Ptr[Window, AnyOrigin[True]], name: Ptr[c_char, AnyOrigin[False]]) -> Ptr[Renderer, AnyOrigin[True]]]()(window, name.as_c_string_slice().unsafe_ptr())


fn create_renderer_with_properties(props: PropertiesID) raises -> Ptr[Renderer, AnyOrigin[True]]:
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

    return _get_dylib_function[lib, "SDL_CreateRendererWithProperties", fn (props: PropertiesID) -> Ptr[Renderer, AnyOrigin[True]]]()(props)


fn create_software_renderer(surface: Ptr[Surface, AnyOrigin[True]]) raises -> Ptr[Renderer, AnyOrigin[True]]:
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

    return _get_dylib_function[lib, "SDL_CreateSoftwareRenderer", fn (surface: Ptr[Surface, AnyOrigin[True]]) -> Ptr[Renderer, AnyOrigin[True]]]()(surface)


fn get_renderer(window: Ptr[Window, AnyOrigin[True]], out ret: Ptr[Renderer, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderer", fn (window: Ptr[Window, AnyOrigin[True]]) -> Ptr[Renderer, AnyOrigin[True]]]()(window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_window(renderer: Ptr[Renderer, AnyOrigin[True]], out ret: Ptr[Window, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderWindow", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> Ptr[Window, AnyOrigin[True]]]()(renderer)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_renderer_name(renderer: Ptr[Renderer, AnyOrigin[True]], out ret: Ptr[c_char, AnyOrigin[False]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRendererName", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> Ptr[c_char, AnyOrigin[False]]]()(renderer)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_renderer_properties(renderer: Ptr[Renderer, AnyOrigin[True]]) raises -> PropertiesID:
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

    return _get_dylib_function[lib, "SDL_GetRendererProperties", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> PropertiesID]()(renderer)


fn get_render_output_size(renderer: Ptr[Renderer, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderOutputSize", fn (renderer: Ptr[Renderer, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(renderer, w, h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_current_render_output_size(renderer: Ptr[Renderer, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetCurrentRenderOutputSize", fn (renderer: Ptr[Renderer, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(renderer, w, h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_texture(renderer: Ptr[Renderer, AnyOrigin[True]], format: PixelFormat, access: TextureAccess, w: c_int, h: c_int, out ret: Ptr[Texture, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_CreateTexture", fn (renderer: Ptr[Renderer, AnyOrigin[True]], format: PixelFormat, access: TextureAccess, w: c_int, h: c_int) -> Ptr[Texture, AnyOrigin[True]]]()(renderer, format, access, w, h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_texture_from_surface(renderer: Ptr[Renderer, AnyOrigin[True]], surface: Ptr[Surface, AnyOrigin[True]], out ret: Ptr[Texture, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_CreateTextureFromSurface", fn (renderer: Ptr[Renderer, AnyOrigin[True]], surface: Ptr[Surface, AnyOrigin[True]]) -> Ptr[Texture, AnyOrigin[True]]]()(renderer, surface)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_texture_with_properties(renderer: Ptr[Renderer, AnyOrigin[True]], props: PropertiesID, out ret: Ptr[Texture, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_CreateTextureWithProperties", fn (renderer: Ptr[Renderer, AnyOrigin[True]], props: PropertiesID) -> Ptr[Texture, AnyOrigin[True]]]()(renderer, props)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_texture_properties(texture: Ptr[Texture, AnyOrigin[True]]) raises -> PropertiesID:
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

    return _get_dylib_function[lib, "SDL_GetTextureProperties", fn (texture: Ptr[Texture, AnyOrigin[True]]) -> PropertiesID]()(texture)


fn get_renderer_from_texture(texture: Ptr[Texture, AnyOrigin[True]]) raises -> Ptr[Renderer, AnyOrigin[True]]:
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

    return _get_dylib_function[lib, "SDL_GetRendererFromTexture", fn (texture: Ptr[Texture, AnyOrigin[True]]) -> Ptr[Renderer, AnyOrigin[True]]]()(texture)


fn get_texture_size(texture: Ptr[Texture, AnyOrigin[True]], w: Ptr[c_float, AnyOrigin[True]], h: Ptr[c_float, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetTextureSize", fn (texture: Ptr[Texture, AnyOrigin[True]], w: Ptr[c_float, AnyOrigin[True]], h: Ptr[c_float, AnyOrigin[True]]) -> Bool]()(texture, w, h)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_texture_color_mod(texture: Ptr[Texture, AnyOrigin[True]], r: UInt8, g: UInt8, b: UInt8) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetTextureColorMod", fn (texture: Ptr[Texture, AnyOrigin[True]], r: UInt8, g: UInt8, b: UInt8) -> Bool]()(texture, r, g, b)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_texture_color_mod_float(texture: Ptr[Texture, AnyOrigin[True]], r: c_float, g: c_float, b: c_float) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetTextureColorModFloat", fn (texture: Ptr[Texture, AnyOrigin[True]], r: c_float, g: c_float, b: c_float) -> Bool]()(texture, r, g, b)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_texture_color_mod(texture: Ptr[Texture, AnyOrigin[True]], r: Ptr[UInt8, AnyOrigin[True]], g: Ptr[UInt8, AnyOrigin[True]], b: Ptr[UInt8, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetTextureColorMod", fn (texture: Ptr[Texture, AnyOrigin[True]], r: Ptr[UInt8, AnyOrigin[True]], g: Ptr[UInt8, AnyOrigin[True]], b: Ptr[UInt8, AnyOrigin[True]]) -> Bool]()(texture, r, g, b)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_texture_color_mod_float(texture: Ptr[Texture, AnyOrigin[True]], r: Ptr[c_float, AnyOrigin[True]], g: Ptr[c_float, AnyOrigin[True]], b: Ptr[c_float, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetTextureColorModFloat", fn (texture: Ptr[Texture, AnyOrigin[True]], r: Ptr[c_float, AnyOrigin[True]], g: Ptr[c_float, AnyOrigin[True]], b: Ptr[c_float, AnyOrigin[True]]) -> Bool]()(texture, r, g, b)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_texture_alpha_mod(texture: Ptr[Texture, AnyOrigin[True]], alpha: UInt8) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetTextureAlphaMod", fn (texture: Ptr[Texture, AnyOrigin[True]], alpha: UInt8) -> Bool]()(texture, alpha)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_texture_alpha_mod_float(texture: Ptr[Texture, AnyOrigin[True]], alpha: c_float) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetTextureAlphaModFloat", fn (texture: Ptr[Texture, AnyOrigin[True]], alpha: c_float) -> Bool]()(texture, alpha)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_texture_alpha_mod(texture: Ptr[Texture, AnyOrigin[True]], alpha: Ptr[UInt8, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetTextureAlphaMod", fn (texture: Ptr[Texture, AnyOrigin[True]], alpha: Ptr[UInt8, AnyOrigin[True]]) -> Bool]()(texture, alpha)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_texture_alpha_mod_float(texture: Ptr[Texture, AnyOrigin[True]], alpha: Ptr[c_float, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetTextureAlphaModFloat", fn (texture: Ptr[Texture, AnyOrigin[True]], alpha: Ptr[c_float, AnyOrigin[True]]) -> Bool]()(texture, alpha)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_texture_blend_mode(texture: Ptr[Texture, AnyOrigin[True]], blend_mode: BlendMode) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetTextureBlendMode", fn (texture: Ptr[Texture, AnyOrigin[True]], blend_mode: BlendMode) -> Bool]()(texture, blend_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_texture_blend_mode(texture: Ptr[Texture, AnyOrigin[True]], blend_mode: Ptr[BlendMode, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetTextureBlendMode", fn (texture: Ptr[Texture, AnyOrigin[True]], blend_mode: Ptr[BlendMode, AnyOrigin[True]]) -> Bool]()(texture, blend_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_texture_scale_mode(texture: Ptr[Texture, AnyOrigin[True]], scale_mode: ScaleMode) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetTextureScaleMode", fn (texture: Ptr[Texture, AnyOrigin[True]], scale_mode: ScaleMode) -> Bool]()(texture, scale_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_texture_scale_mode(texture: Ptr[Texture, AnyOrigin[True]], scale_mode: Ptr[ScaleMode, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetTextureScaleMode", fn (texture: Ptr[Texture, AnyOrigin[True]], scale_mode: Ptr[ScaleMode, AnyOrigin[True]]) -> Bool]()(texture, scale_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn update_texture(texture: Ptr[Texture, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], pixels: Ptr[NoneType, AnyOrigin[False]], pitch: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_UpdateTexture", fn (texture: Ptr[Texture, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], pixels: Ptr[NoneType, AnyOrigin[False]], pitch: c_int) -> Bool]()(texture, rect, pixels, pitch)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn update_yuv_texture(texture: Ptr[Texture, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], y_plane: Ptr[UInt8, AnyOrigin[False]], y_pitch: c_int, uplane: Ptr[UInt8, AnyOrigin[False]], upitch: c_int, vplane: Ptr[UInt8, AnyOrigin[False]], vpitch: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_UpdateYUVTexture", fn (texture: Ptr[Texture, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], y_plane: Ptr[UInt8, AnyOrigin[False]], y_pitch: c_int, uplane: Ptr[UInt8, AnyOrigin[False]], upitch: c_int, vplane: Ptr[UInt8, AnyOrigin[False]], vpitch: c_int) -> Bool]()(texture, rect, y_plane, y_pitch, uplane, upitch, vplane, vpitch)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn update_nv_texture(texture: Ptr[Texture, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], y_plane: Ptr[UInt8, AnyOrigin[False]], y_pitch: c_int, uv_plane: Ptr[UInt8, AnyOrigin[False]], uv_pitch: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_UpdateNVTexture", fn (texture: Ptr[Texture, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], y_plane: Ptr[UInt8, AnyOrigin[False]], y_pitch: c_int, uv_plane: Ptr[UInt8, AnyOrigin[False]], uv_pitch: c_int) -> Bool]()(texture, rect, y_plane, y_pitch, uv_plane, uv_pitch)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn lock_texture(texture: Ptr[Texture, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], pixels: Ptr[Ptr[NoneType, AnyOrigin[True]], AnyOrigin[True]], pitch: Ptr[c_int, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_LockTexture", fn (texture: Ptr[Texture, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], pixels: Ptr[Ptr[NoneType, AnyOrigin[True]], AnyOrigin[True]], pitch: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(texture, rect, pixels, pitch)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn lock_texture_to_surface(texture: Ptr[Texture, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], surface: Ptr[Ptr[Surface, AnyOrigin[True]], AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_LockTextureToSurface", fn (texture: Ptr[Texture, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], surface: Ptr[Ptr[Surface, AnyOrigin[True]], AnyOrigin[True]]) -> Bool]()(texture, rect, surface)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn unlock_texture(texture: Ptr[Texture, AnyOrigin[True]]) raises -> None:
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

    return _get_dylib_function[lib, "SDL_UnlockTexture", fn (texture: Ptr[Texture, AnyOrigin[True]]) -> None]()(texture)


fn set_render_target(renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetRenderTarget", fn (renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]]) -> Bool]()(renderer, texture)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_target(renderer: Ptr[Renderer, AnyOrigin[True]]) raises -> Ptr[Texture, AnyOrigin[True]]:
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

    return _get_dylib_function[lib, "SDL_GetRenderTarget", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> Ptr[Texture, AnyOrigin[True]]]()(renderer)


fn set_render_logical_presentation(renderer: Ptr[Renderer, AnyOrigin[True]], w: c_int, h: c_int, mode: RendererLogicalPresentation) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetRenderLogicalPresentation", fn (renderer: Ptr[Renderer, AnyOrigin[True]], w: c_int, h: c_int, mode: RendererLogicalPresentation) -> Bool]()(renderer, w, h, mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_logical_presentation(renderer: Ptr[Renderer, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]], mode: Ptr[RendererLogicalPresentation, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderLogicalPresentation", fn (renderer: Ptr[Renderer, AnyOrigin[True]], w: Ptr[c_int, AnyOrigin[True]], h: Ptr[c_int, AnyOrigin[True]], mode: Ptr[RendererLogicalPresentation, AnyOrigin[True]]) -> Bool]()(renderer, w, h, mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_logical_presentation_rect(renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[FRect, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderLogicalPresentationRect", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[FRect, AnyOrigin[True]]) -> Bool]()(renderer, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_coordinates_from_window(renderer: Ptr[Renderer, AnyOrigin[True]], window_x: c_float, window_y: c_float, x: Ptr[c_float, AnyOrigin[True]], y: Ptr[c_float, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderCoordinatesFromWindow", fn (renderer: Ptr[Renderer, AnyOrigin[True]], window_x: c_float, window_y: c_float, x: Ptr[c_float, AnyOrigin[True]], y: Ptr[c_float, AnyOrigin[True]]) -> Bool]()(renderer, window_x, window_y, x, y)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_coordinates_to_window(renderer: Ptr[Renderer, AnyOrigin[True]], x: c_float, y: c_float, window_x: Ptr[c_float, AnyOrigin[True]], window_y: Ptr[c_float, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderCoordinatesToWindow", fn (renderer: Ptr[Renderer, AnyOrigin[True]], x: c_float, y: c_float, window_x: Ptr[c_float, AnyOrigin[True]], window_y: Ptr[c_float, AnyOrigin[True]]) -> Bool]()(renderer, x, y, window_x, window_y)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn convert_event_to_render_coordinates(renderer: Ptr[Renderer, AnyOrigin[True]], event: Ptr[Event, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_ConvertEventToRenderCoordinates", fn (renderer: Ptr[Renderer, AnyOrigin[True]], event: Ptr[Event, AnyOrigin[True]]) -> Bool]()(renderer, event)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_render_viewport(renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetRenderViewport", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]]) -> Bool]()(renderer, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_viewport(renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderViewport", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]]) -> Bool]()(renderer, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_viewport_set(renderer: Ptr[Renderer, AnyOrigin[True]]) raises -> Bool:
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

    return _get_dylib_function[lib, "SDL_RenderViewportSet", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> Bool]()(renderer)


fn get_render_safe_area(renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderSafeArea", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]]) -> Bool]()(renderer, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_render_clip_rect(renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetRenderClipRect", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]]) -> Bool]()(renderer, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_clip_rect(renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderClipRect", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[True]]) -> Bool]()(renderer, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_clip_enabled(renderer: Ptr[Renderer, AnyOrigin[True]]) raises -> Bool:
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

    return _get_dylib_function[lib, "SDL_RenderClipEnabled", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> Bool]()(renderer)


fn set_render_scale(renderer: Ptr[Renderer, AnyOrigin[True]], scale_x: c_float, scale_y: c_float) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetRenderScale", fn (renderer: Ptr[Renderer, AnyOrigin[True]], scale_x: c_float, scale_y: c_float) -> Bool]()(renderer, scale_x, scale_y)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_scale(renderer: Ptr[Renderer, AnyOrigin[True]], scale_x: Ptr[c_float, AnyOrigin[True]], scale_y: Ptr[c_float, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderScale", fn (renderer: Ptr[Renderer, AnyOrigin[True]], scale_x: Ptr[c_float, AnyOrigin[True]], scale_y: Ptr[c_float, AnyOrigin[True]]) -> Bool]()(renderer, scale_x, scale_y)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_render_draw_color(renderer: Ptr[Renderer, AnyOrigin[True]], r: UInt8, g: UInt8, b: UInt8, a: UInt8) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetRenderDrawColor", fn (renderer: Ptr[Renderer, AnyOrigin[True]], r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> Bool]()(renderer, r, g, b, a)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_render_draw_color_float(renderer: Ptr[Renderer, AnyOrigin[True]], r: c_float, g: c_float, b: c_float, a: c_float) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetRenderDrawColorFloat", fn (renderer: Ptr[Renderer, AnyOrigin[True]], r: c_float, g: c_float, b: c_float, a: c_float) -> Bool]()(renderer, r, g, b, a)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_draw_color(renderer: Ptr[Renderer, AnyOrigin[True]], r: Ptr[UInt8, AnyOrigin[True]], g: Ptr[UInt8, AnyOrigin[True]], b: Ptr[UInt8, AnyOrigin[True]], a: Ptr[UInt8, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderDrawColor", fn (renderer: Ptr[Renderer, AnyOrigin[True]], r: Ptr[UInt8, AnyOrigin[True]], g: Ptr[UInt8, AnyOrigin[True]], b: Ptr[UInt8, AnyOrigin[True]], a: Ptr[UInt8, AnyOrigin[True]]) -> Bool]()(renderer, r, g, b, a)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_draw_color_float(renderer: Ptr[Renderer, AnyOrigin[True]], r: Ptr[c_float, AnyOrigin[True]], g: Ptr[c_float, AnyOrigin[True]], b: Ptr[c_float, AnyOrigin[True]], a: Ptr[c_float, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderDrawColorFloat", fn (renderer: Ptr[Renderer, AnyOrigin[True]], r: Ptr[c_float, AnyOrigin[True]], g: Ptr[c_float, AnyOrigin[True]], b: Ptr[c_float, AnyOrigin[True]], a: Ptr[c_float, AnyOrigin[True]]) -> Bool]()(renderer, r, g, b, a)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_render_color_scale(renderer: Ptr[Renderer, AnyOrigin[True]], scale: c_float) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetRenderColorScale", fn (renderer: Ptr[Renderer, AnyOrigin[True]], scale: c_float) -> Bool]()(renderer, scale)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_color_scale(renderer: Ptr[Renderer, AnyOrigin[True]], scale: Ptr[c_float, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderColorScale", fn (renderer: Ptr[Renderer, AnyOrigin[True]], scale: Ptr[c_float, AnyOrigin[True]]) -> Bool]()(renderer, scale)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_render_draw_blend_mode(renderer: Ptr[Renderer, AnyOrigin[True]], blend_mode: BlendMode) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetRenderDrawBlendMode", fn (renderer: Ptr[Renderer, AnyOrigin[True]], blend_mode: BlendMode) -> Bool]()(renderer, blend_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_draw_blend_mode(renderer: Ptr[Renderer, AnyOrigin[True]], blend_mode: Ptr[BlendMode, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderDrawBlendMode", fn (renderer: Ptr[Renderer, AnyOrigin[True]], blend_mode: Ptr[BlendMode, AnyOrigin[True]]) -> Bool]()(renderer, blend_mode)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_clear(renderer: Ptr[Renderer, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderClear", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> Bool]()(renderer)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_point(renderer: Ptr[Renderer, AnyOrigin[True]], x: c_float, y: c_float) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderPoint", fn (renderer: Ptr[Renderer, AnyOrigin[True]], x: c_float, y: c_float) -> Bool]()(renderer, x, y)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_points(renderer: Ptr[Renderer, AnyOrigin[True]], points: Ptr[FPoint, AnyOrigin[False]], count: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderPoints", fn (renderer: Ptr[Renderer, AnyOrigin[True]], points: Ptr[FPoint, AnyOrigin[False]], count: c_int) -> Bool]()(renderer, points, count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_line(renderer: Ptr[Renderer, AnyOrigin[True]], x1: c_float, y1: c_float, x2: c_float, y2: c_float) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderLine", fn (renderer: Ptr[Renderer, AnyOrigin[True]], x1: c_float, y1: c_float, x2: c_float, y2: c_float) -> Bool]()(renderer, x1, y1, x2, y2)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_lines(renderer: Ptr[Renderer, AnyOrigin[True]], points: Ptr[FPoint, AnyOrigin[False]], count: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderLines", fn (renderer: Ptr[Renderer, AnyOrigin[True]], points: Ptr[FPoint, AnyOrigin[False]], count: c_int) -> Bool]()(renderer, points, count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_rect(renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[FRect, AnyOrigin[False]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderRect", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[FRect, AnyOrigin[False]]) -> Bool]()(renderer, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_rects(renderer: Ptr[Renderer, AnyOrigin[True]], rects: Ptr[FRect, AnyOrigin[False]], count: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderRects", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rects: Ptr[FRect, AnyOrigin[False]], count: c_int) -> Bool]()(renderer, rects, count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_fill_rect(renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[FRect, AnyOrigin[False]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderFillRect", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[FRect, AnyOrigin[False]]) -> Bool]()(renderer, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_fill_rects(renderer: Ptr[Renderer, AnyOrigin[True]], rects: Ptr[FRect, AnyOrigin[False]], count: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderFillRects", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rects: Ptr[FRect, AnyOrigin[False]], count: c_int) -> Bool]()(renderer, rects, count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_texture(renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], srcrect: Ptr[FRect, AnyOrigin[False]], dstrect: Ptr[FRect, AnyOrigin[False]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderTexture", fn (renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], srcrect: Ptr[FRect, AnyOrigin[False]], dstrect: Ptr[FRect, AnyOrigin[False]]) -> Bool]()(renderer, texture, srcrect, dstrect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_texture_rotated(renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], srcrect: Ptr[FRect, AnyOrigin[False]], dstrect: Ptr[FRect, AnyOrigin[False]], angle: c_double, center: Ptr[FPoint, AnyOrigin[False]], flip: FlipMode) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderTextureRotated", fn (renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], srcrect: Ptr[FRect, AnyOrigin[False]], dstrect: Ptr[FRect, AnyOrigin[False]], angle: c_double, center: Ptr[FPoint, AnyOrigin[False]], flip: FlipMode) -> Bool]()(renderer, texture, srcrect, dstrect, angle, center, flip)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_texture_affine(renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], srcrect: Ptr[FRect, AnyOrigin[False]], origin: Ptr[FPoint, AnyOrigin[False]], right: Ptr[FPoint, AnyOrigin[False]], down: Ptr[FPoint, AnyOrigin[False]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderTextureAffine", fn (renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], srcrect: Ptr[FRect, AnyOrigin[False]], origin: Ptr[FPoint, AnyOrigin[False]], right: Ptr[FPoint, AnyOrigin[False]], down: Ptr[FPoint, AnyOrigin[False]]) -> Bool]()(renderer, texture, srcrect, origin, right, down)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_texture_tiled(renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], srcrect: Ptr[FRect, AnyOrigin[False]], scale: c_float, dstrect: Ptr[FRect, AnyOrigin[False]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderTextureTiled", fn (renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], srcrect: Ptr[FRect, AnyOrigin[False]], scale: c_float, dstrect: Ptr[FRect, AnyOrigin[False]]) -> Bool]()(renderer, texture, srcrect, scale, dstrect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_texture_9grid(renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], srcrect: Ptr[FRect, AnyOrigin[False]], left_width: c_float, right_width: c_float, top_height: c_float, bottom_height: c_float, scale: c_float, dstrect: Ptr[FRect, AnyOrigin[False]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderTexture9Grid", fn (renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], srcrect: Ptr[FRect, AnyOrigin[False]], left_width: c_float, right_width: c_float, top_height: c_float, bottom_height: c_float, scale: c_float, dstrect: Ptr[FRect, AnyOrigin[False]]) -> Bool]()(renderer, texture, srcrect, left_width, right_width, top_height, bottom_height, scale, dstrect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_geometry(renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], vertices: Ptr[Vertex, AnyOrigin[False]], num_vertices: c_int, indices: Ptr[c_int, AnyOrigin[False]], num_indices: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderGeometry", fn (renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], vertices: Ptr[Vertex, AnyOrigin[False]], num_vertices: c_int, indices: Ptr[c_int, AnyOrigin[False]], num_indices: c_int) -> Bool]()(renderer, texture, vertices, num_vertices, indices, num_indices)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_geometry_raw(renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], xy: Ptr[c_float, AnyOrigin[False]], xy_stride: c_int, color: Ptr[FColor, AnyOrigin[False]], color_stride: c_int, uv: Ptr[c_float, AnyOrigin[False]], uv_stride: c_int, num_vertices: c_int, indices: Ptr[NoneType, AnyOrigin[False]], num_indices: c_int, size_indices: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderGeometryRaw", fn (renderer: Ptr[Renderer, AnyOrigin[True]], texture: Ptr[Texture, AnyOrigin[True]], xy: Ptr[c_float, AnyOrigin[False]], xy_stride: c_int, color: Ptr[FColor, AnyOrigin[False]], color_stride: c_int, uv: Ptr[c_float, AnyOrigin[False]], uv_stride: c_int, num_vertices: c_int, indices: Ptr[NoneType, AnyOrigin[False]], num_indices: c_int, size_indices: c_int) -> Bool]()(renderer, texture, xy, xy_stride, color, color_stride, uv, uv_stride, num_vertices, indices, num_indices, size_indices)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_read_pixels(renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]], out ret: Ptr[Surface, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderReadPixels", fn (renderer: Ptr[Renderer, AnyOrigin[True]], rect: Ptr[Rect, AnyOrigin[False]]) -> Ptr[Surface, AnyOrigin[True]]]()(renderer, rect)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_present(renderer: Ptr[Renderer, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderPresent", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> Bool]()(renderer)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn destroy_texture(texture: Ptr[Texture, AnyOrigin[True]]) raises -> None:
    """Destroy the specified texture.

    Passing NULL or an otherwise invalid texture will set the SDL error message
    to "Invalid texture".

    Args:
        texture: The texture to destroy.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyTexture.
    """

    return _get_dylib_function[lib, "SDL_DestroyTexture", fn (texture: Ptr[Texture, AnyOrigin[True]]) -> None]()(texture)


fn destroy_renderer(renderer: Ptr[Renderer, AnyOrigin[True]]) raises -> None:
    """Destroy the rendering context for a window and free all associated
    textures.

    This should be called before destroying the associated window.

    Args:
        renderer: The rendering context.

    Safety:
        This function should only be called on the main thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyRenderer.
    """

    return _get_dylib_function[lib, "SDL_DestroyRenderer", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> None]()(renderer)


fn flush_renderer(renderer: Ptr[Renderer, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_FlushRenderer", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> Bool]()(renderer)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_metal_layer(renderer: Ptr[Renderer, AnyOrigin[True]]) raises -> Ptr[NoneType, AnyOrigin[True]]:
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

    return _get_dylib_function[lib, "SDL_GetRenderMetalLayer", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> Ptr[NoneType, AnyOrigin[True]]]()(renderer)


fn get_render_metal_command_encoder(renderer: Ptr[Renderer, AnyOrigin[True]]) raises -> Ptr[NoneType, AnyOrigin[True]]:
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

    return _get_dylib_function[lib, "SDL_GetRenderMetalCommandEncoder", fn (renderer: Ptr[Renderer, AnyOrigin[True]]) -> Ptr[NoneType, AnyOrigin[True]]]()(renderer)


fn add_vulkan_render_semaphores(renderer: Ptr[Renderer, AnyOrigin[True]], wait_stage_mask: UInt32, wait_semaphore: Int64, signal_semaphore: Int64) raises:
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

    ret = _get_dylib_function[lib, "SDL_AddVulkanRenderSemaphores", fn (renderer: Ptr[Renderer, AnyOrigin[True]], wait_stage_mask: UInt32, wait_semaphore: Int64, signal_semaphore: Int64) -> Bool]()(renderer, wait_stage_mask, wait_semaphore, signal_semaphore)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_render_vsync(renderer: Ptr[Renderer, AnyOrigin[True]], vsync: c_int) raises:
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

    ret = _get_dylib_function[lib, "SDL_SetRenderVSync", fn (renderer: Ptr[Renderer, AnyOrigin[True]], vsync: c_int) -> Bool]()(renderer, vsync)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_render_vsync(renderer: Ptr[Renderer, AnyOrigin[True]], vsync: Ptr[c_int, AnyOrigin[True]]) raises:
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

    ret = _get_dylib_function[lib, "SDL_GetRenderVSync", fn (renderer: Ptr[Renderer, AnyOrigin[True]], vsync: Ptr[c_int, AnyOrigin[True]]) -> Bool]()(renderer, vsync)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn render_debug_text(renderer: Ptr[Renderer, AnyOrigin[True]], x: c_float, y: c_float, var str: String) raises:
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

    ret = _get_dylib_function[lib, "SDL_RenderDebugText", fn (renderer: Ptr[Renderer, AnyOrigin[True]], x: c_float, y: c_float, str: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(renderer, x, y, str.as_c_string_slice().unsafe_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))
