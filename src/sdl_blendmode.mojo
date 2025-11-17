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

"""Blendmode

Blend modes decide how two colors will mix together. There are both
standard modes for basic needs and a means to create custom modes,
dictating what sort of math to do on what color components.
"""


@register_passable("trivial")
struct BlendMode(Intable):
    """A set of blend modes used in drawing operations.

    These predefined blend modes are supported everywhere.

    Additional values may be obtained from SDL_ComposeCustomBlendMode.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlendMode.
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

    comptime BLENDMODE_NONE = Self(0x00000000)
    """No blending: dstRGBA = srcRGBA."""
    comptime BLENDMODE_BLEND = Self(0x00000001)
    """Alpha blending: dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA)), dstA = srcA + (dstA * (1-srcA))."""
    comptime BLENDMODE_BLEND_PREMULTIPLIED = Self(0x00000010)
    """Pre-multiplied alpha blending: dstRGBA = srcRGBA + (dstRGBA * (1-srcA))."""
    comptime BLENDMODE_ADD = Self(0x00000002)
    """Additive blending: dstRGB = (srcRGB * srcA) + dstRGB, dstA = dstA."""
    comptime BLENDMODE_ADD_PREMULTIPLIED = Self(0x00000020)
    """Pre-multiplied additive blending: dstRGB = srcRGB + dstRGB, dstA = dstA."""
    comptime BLENDMODE_MOD = Self(0x00000004)
    """Color modulate: dstRGB = srcRGB * dstRGB, dstA = dstA."""
    comptime BLENDMODE_MUL = Self(0x00000008)
    """Color multiply: dstRGB = (srcRGB * dstRGB) + (dstRGB * (1-srcA)), dstA = dstA."""
    comptime BLENDMODE_INVALID = Self(0x7FFFFFFF)


@register_passable("trivial")
struct BlendOperation(Indexer, Intable):
    """The blend operation used when combining source and destination pixel
    components.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlendOperation.
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

    comptime BLENDOPERATION_ADD = Self(0x1)
    """Dst + src: supported by all renderers."""
    comptime BLENDOPERATION_SUBTRACT = Self(0x2)
    """Src - dst : supported by D3D, OpenGL, OpenGLES, and Vulkan."""
    comptime BLENDOPERATION_REV_SUBTRACT = Self(0x3)
    """Dst - src : supported by D3D, OpenGL, OpenGLES, and Vulkan."""
    comptime BLENDOPERATION_MINIMUM = Self(0x4)
    """Min(dst, src) : supported by D3D, OpenGL, OpenGLES, and Vulkan."""
    comptime BLENDOPERATION_MAXIMUM = Self(0x5)
    """Max(dst, src) : supported by D3D, OpenGL, OpenGLES, and Vulkan."""


@register_passable("trivial")
struct BlendFactor(Indexer, Intable):
    """The normalized factor used to multiply pixel components.

    The blend factors are multiplied with the pixels from a drawing operation
    (src) and the pixels from the render target (dst) before the blend
    operation. The comma-separated factors listed above are always applied in
    the component order red, green, blue, and alpha.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlendFactor.
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

    comptime BLENDFACTOR_ZERO = Self(0x1)
    """0, 0, 0, 0."""
    comptime BLENDFACTOR_ONE = Self(0x2)
    """1, 1, 1, 1."""
    comptime BLENDFACTOR_SRC_COLOR = Self(0x3)
    """SrcR, srcG, srcB, srcA."""
    comptime BLENDFACTOR_ONE_MINUS_SRC_COLOR = Self(0x4)
    """1-srcR, 1-srcG, 1-srcB, 1-srcA."""
    comptime BLENDFACTOR_SRC_ALPHA = Self(0x5)
    """SrcA, srcA, srcA, srcA."""
    comptime BLENDFACTOR_ONE_MINUS_SRC_ALPHA = Self(0x6)
    """1-srcA, 1-srcA, 1-srcA, 1-srcA."""
    comptime BLENDFACTOR_DST_COLOR = Self(0x7)
    """DstR, dstG, dstB, dstA."""
    comptime BLENDFACTOR_ONE_MINUS_DST_COLOR = Self(0x8)
    """1-dstR, 1-dstG, 1-dstB, 1-dstA."""
    comptime BLENDFACTOR_DST_ALPHA = Self(0x9)
    """DstA, dstA, dstA, dstA."""
    comptime BLENDFACTOR_ONE_MINUS_DST_ALPHA = Self(0xA)
    """1-dstA, 1-dstA, 1-dstA, 1-dstA."""


fn compose_custom_blend_mode(src_color_factor: BlendFactor, dst_color_factor: BlendFactor, color_operation: BlendOperation, src_alpha_factor: BlendFactor, dst_alpha_factor: BlendFactor, alpha_operation: BlendOperation) raises -> BlendMode:
    """Compose a custom blend mode for renderers.

    The functions SDL_SetRenderDrawBlendMode and SDL_SetTextureBlendMode accept
    the SDL_BlendMode returned by this function if the renderer supports it.

    A blend mode controls how the pixels from a drawing operation (source) get
    combined with the pixels from the render target (destination). First, the
    components of the source and destination pixels get multiplied with their
    blend factors. Then, the blend operation takes the two products and
    calculates the result that will get stored in the render target.

    Expressed in pseudocode, it would look like this:

    ```c
    dstRGB = colorOperation(srcRGB * srcColorFactor, dstRGB * dstColorFactor);
    dstA = alphaOperation(srcA * srcAlphaFactor, dstA * dstAlphaFactor);
    ```

    Where the functions `colorOperation(src, dst)` and `alphaOperation(src,
    dst)` can return one of the following:

    - `src + dst`
    - `src - dst`
    - `dst - src`
    - `min(src, dst)`
    - `max(src, dst)`

    The red, green, and blue components are always multiplied with the first,
    second, and third components of the SDL_BlendFactor, respectively. The
    fourth component is not used.

    The alpha component is always multiplied with the fourth component of the
    SDL_BlendFactor. The other components are not used in the alpha
    calculation.

    Support for these blend modes varies for each renderer. To check if a
    specific SDL_BlendMode is supported, create a renderer and pass it to
    either SDL_SetRenderDrawBlendMode or SDL_SetTextureBlendMode. They will
    return with an error if the blend mode is not supported.

    This list describes the support of custom blend modes for each renderer.
    All renderers support the four blend modes listed in the SDL_BlendMode
    enumeration.

    - **direct3d**: Supports all operations with all factors. However, some
      factors produce unexpected results with `SDL_BLENDOPERATION_MINIMUM` and
      `SDL_BLENDOPERATION_MAXIMUM`.
    - **direct3d11**: Same as Direct3D 9.
    - **opengl**: Supports the `SDL_BLENDOPERATION_ADD` operation with all
      factors. OpenGL versions 1.1, 1.2, and 1.3 do not work correctly here.
    - **opengles2**: Supports the `SDL_BLENDOPERATION_ADD`,
      `SDL_BLENDOPERATION_SUBTRACT`, `SDL_BLENDOPERATION_REV_SUBTRACT`
      operations with all factors.
    - **psp**: No custom blend mode support.
    - **software**: No custom blend mode support.

    Some renderers do not provide an alpha component for the default render
    target. The `SDL_BLENDFACTOR_DST_ALPHA` and
    `SDL_BLENDFACTOR_ONE_MINUS_DST_ALPHA` factors do not have an effect in this
    case.

    Args:
        src_color_factor: The SDL_BlendFactor applied to the red, green, and
                          blue components of the source pixels.
        dst_color_factor: The SDL_BlendFactor applied to the red, green, and
                          blue components of the destination pixels.
        color_operation: The SDL_BlendOperation used to combine the red,
                         green, and blue components of the source and
                         destination pixels.
        src_alpha_factor: The SDL_BlendFactor applied to the alpha component of
                          the source pixels.
        dst_alpha_factor: The SDL_BlendFactor applied to the alpha component of
                          the destination pixels.
        alpha_operation: The SDL_BlendOperation used to combine the alpha
                         component of the source and destination pixels.

    Returns:
        An SDL_BlendMode that represents the chosen factors and
        operations.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ComposeCustomBlendMode.
    """

    return _get_dylib_function[lib, "SDL_ComposeCustomBlendMode", fn (src_color_factor: BlendFactor, dst_color_factor: BlendFactor, color_operation: BlendOperation, src_alpha_factor: BlendFactor, dst_alpha_factor: BlendFactor, alpha_operation: BlendOperation) -> BlendMode]()(src_color_factor, dst_color_factor, color_operation, src_alpha_factor, dst_alpha_factor, alpha_operation)
