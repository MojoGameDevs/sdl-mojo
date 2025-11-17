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

"""GPU

The GPU API offers a cross-platform way for apps to talk to modern graphics
hardware. It offers both 3D graphics and compute support, in the style of
Metal, Vulkan, and Direct3D 12.

A basic workflow might be something like this:

The app creates a GPU device with SDL_CreateGPUDevice(), and assigns it to
a window with SDL_ClaimWindowForGPUDevice()--although strictly speaking you
can render offscreen entirely, perhaps for image processing, and not use a
window at all.

Next, the app prepares static data (things that are created once and used
over and over). For example:

- Shaders (programs that run on the GPU): use SDL_CreateGPUShader().
- Vertex buffers (arrays of geometry data) and other rendering data: use
  SDL_CreateGPUBuffer() and SDL_UploadToGPUBuffer().
- Textures (images): use SDL_CreateGPUTexture() and
  SDL_UploadToGPUTexture().
- Samplers (how textures should be read from): use SDL_CreateGPUSampler().
- Render pipelines (precalculated rendering state): use
  SDL_CreateGPUGraphicsPipeline()

To render, the app creates one or more command buffers, with
SDL_AcquireGPUCommandBuffer(). Command buffers collect rendering
instructions that will be submitted to the GPU in batch. Complex scenes can
use multiple command buffers, maybe configured across multiple threads in
parallel, as long as they are submitted in the correct order, but many apps
will just need one command buffer per frame.

Rendering can happen to a texture (what other APIs call a "render target")
or it can happen to the swapchain texture (which is just a special texture
that represents a window's contents). The app can use
SDL_WaitAndAcquireGPUSwapchainTexture() to render to the window.

Rendering actually happens in a Render Pass, which is encoded into a
command buffer. One can encode multiple render passes (or alternate between
render and compute passes) in a single command buffer, but many apps might
simply need a single render pass in a single command buffer. Render Passes
can render to up to four color textures and one depth texture
simultaneously. If the set of textures being rendered to needs to change,
the Render Pass must be ended and a new one must be begun.

The app calls SDL_BeginGPURenderPass(). Then it sets states it needs for
each draw:

- SDL_BindGPUGraphicsPipeline()
- SDL_SetGPUViewport()
- SDL_BindGPUVertexBuffers()
- SDL_BindGPUVertexSamplers()
- etc

Then, make the actual draw commands with these states:

- SDL_DrawGPUPrimitives()
- SDL_DrawGPUPrimitivesIndirect()
- SDL_DrawGPUIndexedPrimitivesIndirect()
- etc

After all the drawing commands for a pass are complete, the app should call
SDL_EndGPURenderPass(). Once a render pass ends all render-related state is
reset.

The app can begin new Render Passes and make new draws in the same command
buffer until the entire scene is rendered.

Once all of the render commands for the scene are complete, the app calls
SDL_SubmitGPUCommandBuffer() to send it to the GPU for processing.

If the app needs to read back data from texture or buffers, the API has an
efficient way of doing this, provided that the app is willing to tolerate
some latency. When the app uses SDL_DownloadFromGPUTexture() or
SDL_DownloadFromGPUBuffer(), submitting the command buffer with
SDL_SubmitGPUCommandBufferAndAcquireFence() will return a fence handle that
the app can poll or wait on in a thread. Once the fence indicates that the
command buffer is done processing, it is safe to read the downloaded data.
Make sure to call SDL_ReleaseGPUFence() when done with the fence.

The API also has "compute" support. The app calls SDL_BeginGPUComputePass()
with compute-writeable textures and/or buffers, which can be written to in
a compute shader. Then it sets states it needs for the compute dispatches:

- SDL_BindGPUComputePipeline()
- SDL_BindGPUComputeStorageBuffers()
- SDL_BindGPUComputeStorageTextures()

Then, dispatch compute work:

- SDL_DispatchGPUCompute()

For advanced users, this opens up powerful GPU-driven workflows.

Graphics and compute pipelines require the use of shaders, which as
mentioned above are small programs executed on the GPU. Each backend
(Vulkan, Metal, D3D12) requires a different shader format. When the app
creates the GPU device, the app lets the device know which shader formats
the app can provide. It will then select the appropriate backend depending
on the available shader formats and the backends available on the platform.
When creating shaders, the app must provide the correct shader format for
the selected backend. If you would like to learn more about why the API
works this way, there is a detailed
[blog post](https://moonside.games/posts/layers-all-the-way-down/)
explaining this situation.

It is optimal for apps to pre-compile the shader formats they might use,
but for ease of use SDL provides a separate project,
[SDL_shadercross](https://github.com/libsdl-org/SDL_shadercross)
, for performing runtime shader cross-compilation. It also has a CLI
interface for offline precompilation as well.

This is an extremely quick overview that leaves out several important
details. Already, though, one can see that GPU programming can be quite
complex! If you just need simple 2D graphics, the
[Render API](https://wiki.libsdl.org/SDL3/CategoryRender)
is much easier to use but still hardware-accelerated. That said, even for
2D applications the performance benefits and expressiveness of the GPU API
are significant.

The GPU API targets a feature set with a wide range of hardware support and
ease of portability. It is designed so that the app won't have to branch
itself by querying feature support. If you need cutting-edge features with
limited hardware support, this API is probably not for you.

Examples demonstrating proper usage of this API can be found
[here](https://github.com/TheSpydog/SDL_gpu_examples)
.

## Performance considerations

Here are some basic tips for maximizing your rendering performance.

- Beginning a new render pass is relatively expensive. Use as few render
  passes as you can.
- Minimize the amount of state changes. For example, binding a pipeline is
  relatively cheap, but doing it hundreds of times when you don't need to
  will slow the performance significantly.
- Perform your data uploads as early as possible in the frame.
- Don't churn resources. Creating and releasing resources is expensive.
  It's better to create what you need up front and cache it.
- Don't use uniform buffers for large amounts of data (more than a matrix
  or so). Use a storage buffer instead.
- Use cycling correctly. There is a detailed explanation of cycling further
  below.
- Use culling techniques to minimize pixel writes. The less writing the GPU
  has to do the better. Culling can be a very advanced topic but even
  simple culling techniques can boost performance significantly.

In general try to remember the golden rule of performance: doing things is
more expensive than not doing things. Don't Touch The Driver!

## FAQ

**Question: When are you adding more advanced features, like ray tracing or
mesh shaders?**

Answer: We don't have immediate plans to add more bleeding-edge features,
but we certainly might in the future, when these features prove worthwhile,
and reasonable to implement across several platforms and underlying APIs.
So while these things are not in the "never" category, they are definitely
not "near future" items either.

**Question: Why is my shader not working?**

Answer: A common oversight when using shaders is not properly laying out
the shader resources/registers correctly. The GPU API is very strict with
how it wants resources to be laid out and it's difficult for the API to
automatically validate shaders to see if they have a compatible layout. See
the documentation for SDL_CreateGPUShader() and
SDL_CreateGPUComputePipeline() for information on the expected layout.

Another common issue is not setting the correct number of samplers,
textures, and buffers in SDL_GPUShaderCreateInfo. If possible use shader
reflection to extract the required information from the shader
automatically instead of manually filling in the struct's values.

**Question: My application isn't performing very well. Is this the GPU
API's fault?**

Answer: No. Long answer: The GPU API is a relatively thin layer over the
underlying graphics API. While it's possible that we have done something
inefficiently, it's very unlikely especially if you are relatively
inexperienced with GPU rendering. Please see the performance tips above and
make sure you are following them. Additionally, tools like RenderDoc can be
very helpful for diagnosing incorrect behavior and performance issues.

## System Requirements

**Vulkan:** Supported on Windows, Linux, Nintendo Switch, and certain
Android devices. Requires Vulkan 1.0 with the following extensions and
device features:

- `VK_KHR_swapchain`
- `VK_KHR_maintenance1`
- `independentBlend`
- `imageCubeArray`
- `depthClamp`
- `shaderClipDistance`
- `drawIndirectFirstInstance`

**D3D12:** Supported on Windows 10 or newer, Xbox One (GDK), and Xbox
Series X|S (GDK). Requires a GPU that supports DirectX 12 Feature Level 11_0 and
Resource Binding Tier 2 or above.

**Metal:** Supported on macOS 10.14+ and iOS/tvOS 13.0+. Hardware
requirements vary by operating system:

- macOS requires an Apple Silicon or
  [Intel Mac2 family](https://developer.apple.com/documentation/metal/mtlfeatureset/mtlfeatureset_macos_gpufamily2_v1?language=objc)
  GPU
- iOS/tvOS requires an A9 GPU or newer
- iOS Simulator and tvOS Simulator are unsupported

## Uniform Data

Uniforms are for passing data to shaders. The uniform data will be constant
across all executions of the shader.

There are 4 available uniform slots per shader stage (where the stages are
vertex, fragment, and compute). Uniform data pushed to a slot on a stage
keeps its value throughout the command buffer until you call the relevant
Push function on that slot again.

For example, you could write your vertex shaders to read a camera matrix
from uniform binding slot 0, push the camera matrix at the start of the
command buffer, and that data will be used for every subsequent draw call.

It is valid to push uniform data during a render or compute pass.

Uniforms are best for pushing small amounts of data. If you are pushing
more than a matrix or two per call you should consider using a storage
buffer instead.

## A Note On Cycling

When using a command buffer, operations do not occur immediately - they
occur some time after the command buffer is submitted.

When a resource is used in a pending or active command buffer, it is
considered to be "bound". When a resource is no longer used in any pending
or active command buffers, it is considered to be "unbound".

If data resources are bound, it is unspecified when that data will be
unbound unless you acquire a fence when submitting the command buffer and
wait on it. However, this doesn't mean you need to track resource usage
manually.

All of the functions and structs that involve writing to a resource have a
"cycle" bool. SDL_GPUTransferBuffer, SDL_GPUBuffer, and SDL_GPUTexture all
effectively function as ring buffers on internal resources. When cycle is
true, if the resource is bound, the cycle rotates to the next unbound
internal resource, or if none are available, a new one is created. This
means you don't have to worry about complex state tracking and
synchronization as long as cycling is correctly employed.

For example: you can call SDL_MapGPUTransferBuffer(), write texture data,
SDL_UnmapGPUTransferBuffer(), and then SDL_UploadToGPUTexture(). The next
time you write texture data to the transfer buffer, if you set the cycle
param to true, you don't have to worry about overwriting any data that is
not yet uploaded.

Another example: If you are using a texture in a render pass every frame,
this can cause a data dependency between frames. If you set cycle to true
in the SDL_GPUColorTargetInfo struct, you can prevent this data dependency.

Cycling will never undefine already bound data. When cycling, all data in
the resource is considered to be undefined for subsequent commands until
that data is written again. You must take care not to read undefined data.

Note that when cycling a texture, the entire texture will be cycled, even
if only part of the texture is used in the call, so you must consider the
entire texture to contain undefined data after cycling.

You must also take care not to overwrite a section of data that has been
referenced in a command without cycling first. It is OK to overwrite
unreferenced data in a bound resource without cycling, but overwriting a
section of data that has already been referenced will produce unexpected
results.
"""


@fieldwise_init
struct GPUDevice(ImplicitlyCopyable, Movable):
    """An opaque handle representing the SDL_GPU context.

    Docs: https://wiki.libsdl.org/SDL3/GPUDevice.
    """

    pass


@fieldwise_init
struct GPUBuffer(ImplicitlyCopyable, Movable):
    """An opaque handle representing a buffer.

    Used for vertices, indices, indirect draw commands, and general compute
    data.

    Docs: https://wiki.libsdl.org/SDL3/GPUBuffer.
    """

    pass


@fieldwise_init
struct GPUTransferBuffer(ImplicitlyCopyable, Movable):
    """An opaque handle representing a transfer buffer.

    Used for transferring data to and from the device.

    Docs: https://wiki.libsdl.org/SDL3/GPUTransferBuffer.
    """

    pass


@fieldwise_init
struct GPUTexture(ImplicitlyCopyable, Movable):
    """An opaque handle representing a texture.

    Docs: https://wiki.libsdl.org/SDL3/GPUTexture.
    """

    pass


@fieldwise_init
struct GPUSampler(ImplicitlyCopyable, Movable):
    """An opaque handle representing a sampler.

    Docs: https://wiki.libsdl.org/SDL3/GPUSampler.
    """

    pass


@fieldwise_init
struct GPUShader(ImplicitlyCopyable, Movable):
    """An opaque handle representing a compiled shader object.

    Docs: https://wiki.libsdl.org/SDL3/GPUShader.
    """

    pass


@fieldwise_init
struct GPUComputePipeline(ImplicitlyCopyable, Movable):
    """An opaque handle representing a compute pipeline.

    Used during compute passes.

    Docs: https://wiki.libsdl.org/SDL3/GPUComputePipeline.
    """

    pass


@fieldwise_init
struct GPUGraphicsPipeline(ImplicitlyCopyable, Movable):
    """An opaque handle representing a graphics pipeline.

    Used during render passes.

    Docs: https://wiki.libsdl.org/SDL3/GPUGraphicsPipeline.
    """

    pass


@fieldwise_init
struct GPUCommandBuffer(ImplicitlyCopyable, Movable):
    """An opaque handle representing a command buffer.

    Most state is managed via command buffers. When setting state using a
    command buffer, that state is local to the command buffer.

    Commands only begin execution on the GPU once SDL_SubmitGPUCommandBuffer is
    called. Once the command buffer is submitted, it is no longer valid to use
    it.

    Command buffers are executed in submission order. If you submit command
    buffer A and then command buffer B all commands in A will begin executing
    before any command in B begins executing.

    In multi-threading scenarios, you should only access a command buffer on
    the thread you acquired it from.

    Docs: https://wiki.libsdl.org/SDL3/GPUCommandBuffer.
    """

    pass


@fieldwise_init
struct GPURenderPass(ImplicitlyCopyable, Movable):
    """An opaque handle representing a render pass.

    This handle is transient and should not be held or referenced after
    SDL_EndGPURenderPass is called.

    Docs: https://wiki.libsdl.org/SDL3/GPURenderPass.
    """

    pass


@fieldwise_init
struct GPUComputePass(ImplicitlyCopyable, Movable):
    """An opaque handle representing a compute pass.

    This handle is transient and should not be held or referenced after
    SDL_EndGPUComputePass is called.

    Docs: https://wiki.libsdl.org/SDL3/GPUComputePass.
    """

    pass


@fieldwise_init
struct GPUCopyPass(ImplicitlyCopyable, Movable):
    """An opaque handle representing a copy pass.

    This handle is transient and should not be held or referenced after
    SDL_EndGPUCopyPass is called.

    Docs: https://wiki.libsdl.org/SDL3/GPUCopyPass.
    """

    pass


@fieldwise_init
struct GPUFence(ImplicitlyCopyable, Movable):
    """An opaque handle representing a fence.

    Docs: https://wiki.libsdl.org/SDL3/GPUFence.
    """

    pass


@register_passable("trivial")
struct GPUPrimitiveType(Indexer, Intable):
    """Specifies the primitive topology of a graphics pipeline.

    If you are using POINTLIST you must include a point size output in the
    vertex shader.

    - For HLSL compiling to SPIRV you must decorate a float output with
      [[vk::builtin("PointSize")]].
    - For GLSL you must set the gl_PointSize builtin.
    - For MSL you must include a float output with the [[point_size]]
      decorator.

    Note that sized point topology is totally unsupported on D3D12. Any size
    other than 1 will be ignored. In general, you should avoid using point
    topology for both compatibility and performance reasons. You WILL regret
    using it.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUPrimitiveType.
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

    comptime GPU_PRIMITIVETYPE_TRIANGLELIST = Self(0)
    """A series of separate triangles."""
    comptime GPU_PRIMITIVETYPE_TRIANGLESTRIP = Self(1)
    """A series of connected triangles."""
    comptime GPU_PRIMITIVETYPE_LINELIST = Self(2)
    """A series of separate lines."""
    comptime GPU_PRIMITIVETYPE_LINESTRIP = Self(3)
    """A series of connected lines."""
    comptime GPU_PRIMITIVETYPE_POINTLIST = Self(4)
    """A series of separate points."""


@register_passable("trivial")
struct GPULoadOp(Indexer, Intable):
    """Specifies how the contents of a texture attached to a render pass are
    treated at the beginning of the render pass.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPULoadOp.
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

    comptime GPU_LOADOP_LOAD = Self(0)
    """The previous contents of the texture will be preserved."""
    comptime GPU_LOADOP_CLEAR = Self(1)
    """The contents of the texture will be cleared to a color."""
    comptime GPU_LOADOP_DONT_CARE = Self(2)
    """The previous contents of the texture need not be preserved. The contents will be undefined."""


@register_passable("trivial")
struct GPUStoreOp(Indexer, Intable):
    """Specifies how the contents of a texture attached to a render pass are
    treated at the end of the render pass.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUStoreOp.
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

    comptime GPU_STOREOP_STORE = Self(0)
    """The contents generated during the render pass will be written to memory."""
    comptime GPU_STOREOP_DONT_CARE = Self(1)
    """The contents generated during the render pass are not needed and may be discarded. The contents will be undefined."""
    comptime GPU_STOREOP_RESOLVE = Self(2)
    """The multisample contents generated during the render pass will be resolved to a non-multisample texture. The contents in the multisample texture may then be discarded and will be undefined."""
    comptime GPU_STOREOP_RESOLVE_AND_STORE = Self(3)
    """The multisample contents generated during the render pass will be resolved to a non-multisample texture. The contents in the multisample texture will be written to memory."""


@register_passable("trivial")
struct GPUIndexElementSize(Indexer, Intable):
    """Specifies the size of elements in an index buffer.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUIndexElementSize.
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

    comptime GPU_INDEXELEMENTSIZE_16BIT = Self(0)
    """The index elements are 16-bit."""
    comptime GPU_INDEXELEMENTSIZE_32BIT = Self(1)
    """The index elements are 32-bit."""


@register_passable("trivial")
struct GPUTextureFormat(Indexer, Intable):
    """Specifies the pixel format of a texture.

    Texture format support varies depending on driver, hardware, and usage
    flags. In general, you should use SDL_GPUTextureSupportsFormat to query if
    a format is supported before using it. However, there are a few guaranteed
    formats.

    FIXME: Check universal support for 32-bit component formats FIXME: Check
    universal support for SIMULTANEOUS_READ_WRITE

    For SAMPLER usage, the following formats are universally supported:

    - R8G8B8A8_UNORM
    - B8G8R8A8_UNORM
    - R8_UNORM
    - R8_SNORM
    - R8G8_UNORM
    - R8G8_SNORM
    - R8G8B8A8_SNORM
    - R16_FLOAT
    - R16G16_FLOAT
    - R16G16B16A16_FLOAT
    - R32_FLOAT
    - R32G32_FLOAT
    - R32G32B32A32_FLOAT
    - R11G11B10_UFLOAT
    - R8G8B8A8_UNORM_SRGB
    - B8G8R8A8_UNORM_SRGB
    - D16_UNORM

    For COLOR_TARGET usage, the following formats are universally supported:

    - R8G8B8A8_UNORM
    - B8G8R8A8_UNORM
    - R8_UNORM
    - R16_FLOAT
    - R16G16_FLOAT
    - R16G16B16A16_FLOAT
    - R32_FLOAT
    - R32G32_FLOAT
    - R32G32B32A32_FLOAT
    - R8_UINT
    - R8G8_UINT
    - R8G8B8A8_UINT
    - R16_UINT
    - R16G16_UINT
    - R16G16B16A16_UINT
    - R8_INT
    - R8G8_INT
    - R8G8B8A8_INT
    - R16_INT
    - R16G16_INT
    - R16G16B16A16_INT
    - R8G8B8A8_UNORM_SRGB
    - B8G8R8A8_UNORM_SRGB

    For STORAGE usages, the following formats are universally supported:

    - R8G8B8A8_UNORM
    - R8G8B8A8_SNORM
    - R16G16B16A16_FLOAT
    - R32_FLOAT
    - R32G32_FLOAT
    - R32G32B32A32_FLOAT
    - R8G8B8A8_UINT
    - R16G16B16A16_UINT
    - R8G8B8A8_INT
    - R16G16B16A16_INT

    For DEPTH_STENCIL_TARGET usage, the following formats are universally
    supported:

    - D16_UNORM
    - Either (but not necessarily both!) D24_UNORM or D32_FLOAT
    - Either (but not necessarily both!) D24_UNORM_S8_UINT or D32_FLOAT_S8_UINT

    Unless D16_UNORM is sufficient for your purposes, always check which of
    D24/D32 is supported before creating a depth-stencil texture!

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUTextureFormat.
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

    comptime GPU_TEXTUREFORMAT_INVALID = Self(0)

    # Unsigned Normalized Float Color Formats
    comptime GPU_TEXTUREFORMAT_A8_UNORM = Self(1)
    comptime GPU_TEXTUREFORMAT_R8_UNORM = Self(2)
    comptime GPU_TEXTUREFORMAT_R8G8_UNORM = Self(3)
    comptime GPU_TEXTUREFORMAT_R8G8B8A8_UNORM = Self(4)
    comptime GPU_TEXTUREFORMAT_R16_UNORM = Self(5)
    comptime GPU_TEXTUREFORMAT_R16G16_UNORM = Self(6)
    comptime GPU_TEXTUREFORMAT_R16G16B16A16_UNORM = Self(7)
    comptime GPU_TEXTUREFORMAT_R10G10B10A2_UNORM = Self(8)
    comptime GPU_TEXTUREFORMAT_B5G6R5_UNORM = Self(9)
    comptime GPU_TEXTUREFORMAT_B5G5R5A1_UNORM = Self(10)
    comptime GPU_TEXTUREFORMAT_B4G4R4A4_UNORM = Self(11)
    comptime GPU_TEXTUREFORMAT_B8G8R8A8_UNORM = Self(12)
    # Compressed Unsigned Normalized Float Color Formats
    comptime GPU_TEXTUREFORMAT_BC1_RGBA_UNORM = Self(13)
    comptime GPU_TEXTUREFORMAT_BC2_RGBA_UNORM = Self(14)
    comptime GPU_TEXTUREFORMAT_BC3_RGBA_UNORM = Self(15)
    comptime GPU_TEXTUREFORMAT_BC4_R_UNORM = Self(16)
    comptime GPU_TEXTUREFORMAT_BC5_RG_UNORM = Self(17)
    comptime GPU_TEXTUREFORMAT_BC7_RGBA_UNORM = Self(18)
    # Compressed Signed Float Color Formats
    comptime GPU_TEXTUREFORMAT_BC6H_RGB_FLOAT = Self(19)
    # Compressed Unsigned Float Color Formats
    comptime GPU_TEXTUREFORMAT_BC6H_RGB_UFLOAT = Self(20)
    # Signed Normalized Float Color Formats
    comptime GPU_TEXTUREFORMAT_R8_SNORM = Self(21)
    comptime GPU_TEXTUREFORMAT_R8G8_SNORM = Self(22)
    comptime GPU_TEXTUREFORMAT_R8G8B8A8_SNORM = Self(23)
    comptime GPU_TEXTUREFORMAT_R16_SNORM = Self(24)
    comptime GPU_TEXTUREFORMAT_R16G16_SNORM = Self(25)
    comptime GPU_TEXTUREFORMAT_R16G16B16A16_SNORM = Self(26)
    # Signed Float Color Formats
    comptime GPU_TEXTUREFORMAT_R16_FLOAT = Self(27)
    comptime GPU_TEXTUREFORMAT_R16G16_FLOAT = Self(28)
    comptime GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT = Self(29)
    comptime GPU_TEXTUREFORMAT_R32_FLOAT = Self(30)
    comptime GPU_TEXTUREFORMAT_R32G32_FLOAT = Self(31)
    comptime GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT = Self(32)
    # Unsigned Float Color Formats
    comptime GPU_TEXTUREFORMAT_R11G11B10_UFLOAT = Self(33)
    # Unsigned Integer Color Formats
    comptime GPU_TEXTUREFORMAT_R8_UINT = Self(34)
    comptime GPU_TEXTUREFORMAT_R8G8_UINT = Self(35)
    comptime GPU_TEXTUREFORMAT_R8G8B8A8_UINT = Self(36)
    comptime GPU_TEXTUREFORMAT_R16_UINT = Self(37)
    comptime GPU_TEXTUREFORMAT_R16G16_UINT = Self(38)
    comptime GPU_TEXTUREFORMAT_R16G16B16A16_UINT = Self(39)
    comptime GPU_TEXTUREFORMAT_R32_UINT = Self(40)
    comptime GPU_TEXTUREFORMAT_R32G32_UINT = Self(41)
    comptime GPU_TEXTUREFORMAT_R32G32B32A32_UINT = Self(42)
    # Signed Integer Color Formats
    comptime GPU_TEXTUREFORMAT_R8_INT = Self(43)
    comptime GPU_TEXTUREFORMAT_R8G8_INT = Self(44)
    comptime GPU_TEXTUREFORMAT_R8G8B8A8_INT = Self(45)
    comptime GPU_TEXTUREFORMAT_R16_INT = Self(46)
    comptime GPU_TEXTUREFORMAT_R16G16_INT = Self(47)
    comptime GPU_TEXTUREFORMAT_R16G16B16A16_INT = Self(48)
    comptime GPU_TEXTUREFORMAT_R32_INT = Self(49)
    comptime GPU_TEXTUREFORMAT_R32G32_INT = Self(50)
    comptime GPU_TEXTUREFORMAT_R32G32B32A32_INT = Self(51)
    # SRGB Unsigned Normalized Color Formats
    comptime GPU_TEXTUREFORMAT_R8G8B8A8_UNORM_SRGB = Self(52)
    comptime GPU_TEXTUREFORMAT_B8G8R8A8_UNORM_SRGB = Self(53)
    # Compressed SRGB Unsigned Normalized Color Formats
    comptime GPU_TEXTUREFORMAT_BC1_RGBA_UNORM_SRGB = Self(54)
    comptime GPU_TEXTUREFORMAT_BC2_RGBA_UNORM_SRGB = Self(55)
    comptime GPU_TEXTUREFORMAT_BC3_RGBA_UNORM_SRGB = Self(56)
    comptime GPU_TEXTUREFORMAT_BC7_RGBA_UNORM_SRGB = Self(57)
    # Depth Formats
    comptime GPU_TEXTUREFORMAT_D16_UNORM = Self(58)
    comptime GPU_TEXTUREFORMAT_D24_UNORM = Self(59)
    comptime GPU_TEXTUREFORMAT_D32_FLOAT = Self(60)
    comptime GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT = Self(61)
    comptime GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT = Self(62)
    # Compressed ASTC Normalized Float Color Formats
    comptime GPU_TEXTUREFORMAT_ASTC_4x4_UNORM = Self(63)
    comptime GPU_TEXTUREFORMAT_ASTC_5x4_UNORM = Self(64)
    comptime GPU_TEXTUREFORMAT_ASTC_5x5_UNORM = Self(65)
    comptime GPU_TEXTUREFORMAT_ASTC_6x5_UNORM = Self(66)
    comptime GPU_TEXTUREFORMAT_ASTC_6x6_UNORM = Self(67)
    comptime GPU_TEXTUREFORMAT_ASTC_8x5_UNORM = Self(68)
    comptime GPU_TEXTUREFORMAT_ASTC_8x6_UNORM = Self(69)
    comptime GPU_TEXTUREFORMAT_ASTC_8x8_UNORM = Self(70)
    comptime GPU_TEXTUREFORMAT_ASTC_10x5_UNORM = Self(71)
    comptime GPU_TEXTUREFORMAT_ASTC_10x6_UNORM = Self(72)
    comptime GPU_TEXTUREFORMAT_ASTC_10x8_UNORM = Self(73)
    comptime GPU_TEXTUREFORMAT_ASTC_10x10_UNORM = Self(74)
    comptime GPU_TEXTUREFORMAT_ASTC_12x10_UNORM = Self(75)
    comptime GPU_TEXTUREFORMAT_ASTC_12x12_UNORM = Self(76)
    # Compressed SRGB ASTC Normalized Float Color Formats
    comptime GPU_TEXTUREFORMAT_ASTC_4x4_UNORM_SRGB = Self(77)
    comptime GPU_TEXTUREFORMAT_ASTC_5x4_UNORM_SRGB = Self(78)
    comptime GPU_TEXTUREFORMAT_ASTC_5x5_UNORM_SRGB = Self(79)
    comptime GPU_TEXTUREFORMAT_ASTC_6x5_UNORM_SRGB = Self(80)
    comptime GPU_TEXTUREFORMAT_ASTC_6x6_UNORM_SRGB = Self(81)
    comptime GPU_TEXTUREFORMAT_ASTC_8x5_UNORM_SRGB = Self(82)
    comptime GPU_TEXTUREFORMAT_ASTC_8x6_UNORM_SRGB = Self(83)
    comptime GPU_TEXTUREFORMAT_ASTC_8x8_UNORM_SRGB = Self(84)
    comptime GPU_TEXTUREFORMAT_ASTC_10x5_UNORM_SRGB = Self(85)
    comptime GPU_TEXTUREFORMAT_ASTC_10x6_UNORM_SRGB = Self(86)
    comptime GPU_TEXTUREFORMAT_ASTC_10x8_UNORM_SRGB = Self(87)
    comptime GPU_TEXTUREFORMAT_ASTC_10x10_UNORM_SRGB = Self(88)
    comptime GPU_TEXTUREFORMAT_ASTC_12x10_UNORM_SRGB = Self(89)
    comptime GPU_TEXTUREFORMAT_ASTC_12x12_UNORM_SRGB = Self(90)
    # Compressed ASTC Signed Float Color Formats
    comptime GPU_TEXTUREFORMAT_ASTC_4x4_FLOAT = Self(91)
    comptime GPU_TEXTUREFORMAT_ASTC_5x4_FLOAT = Self(92)
    comptime GPU_TEXTUREFORMAT_ASTC_5x5_FLOAT = Self(93)
    comptime GPU_TEXTUREFORMAT_ASTC_6x5_FLOAT = Self(94)
    comptime GPU_TEXTUREFORMAT_ASTC_6x6_FLOAT = Self(95)
    comptime GPU_TEXTUREFORMAT_ASTC_8x5_FLOAT = Self(96)
    comptime GPU_TEXTUREFORMAT_ASTC_8x6_FLOAT = Self(97)
    comptime GPU_TEXTUREFORMAT_ASTC_8x8_FLOAT = Self(98)
    comptime GPU_TEXTUREFORMAT_ASTC_10x5_FLOAT = Self(99)
    comptime GPU_TEXTUREFORMAT_ASTC_10x6_FLOAT = Self(100)
    comptime GPU_TEXTUREFORMAT_ASTC_10x8_FLOAT = Self(101)
    comptime GPU_TEXTUREFORMAT_ASTC_10x10_FLOAT = Self(102)
    comptime GPU_TEXTUREFORMAT_ASTC_12x10_FLOAT = Self(103)
    comptime GPU_TEXTUREFORMAT_ASTC_12x12_FLOAT = Self(104)


@register_passable("trivial")
struct GPUTextureUsageFlags(Intable):
    """Specifies how a texture is intended to be used by the client.

    A texture must have at least one usage flag. Note that some usage flag
    combinations are invalid.

    With regards to compute storage usage, READ | WRITE means that you can have
    shader A that only writes into the texture and shader B that only reads
    from the texture and bind the same texture to either shader respectively.
    SIMULTANEOUS means that you can do reads and writes within the same shader
    or compute pass. It also implies that atomic ops can be used, since those
    are read-modify-write operations. If you use SIMULTANEOUS, you are
    responsible for avoiding data races, as there is no data synchronization
    within a compute pass. Note that SIMULTANEOUS usage is only supported by a
    limited number of texture formats.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUTextureUsageFlags.
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

    comptime GPU_TEXTUREUSAGE_SAMPLER = Self(1 << 0)
    """Texture supports sampling."""
    comptime GPU_TEXTUREUSAGE_COLOR_TARGET = Self(1 << 1)
    """Texture is a color render target."""
    comptime GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET = Self(1 << 2)
    """Texture is a depth stencil target."""
    comptime GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ = Self(1 << 3)
    """Texture supports storage reads in graphics stages."""
    comptime GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ = Self(1 << 4)
    """Texture supports storage reads in the compute stage."""
    comptime GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE = Self(1 << 5)
    """Texture supports storage writes in the compute stage."""
    comptime GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE = Self(1 << 6)
    """Texture supports reads and writes in the same compute shader. This is NOT equivalent to READ | WRITE."""


@register_passable("trivial")
struct GPUTextureType(Indexer, Intable):
    """Specifies the type of a texture.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUTextureType.
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

    comptime GPU_TEXTURETYPE_2D = Self(0)
    """The texture is a 2-dimensional image."""
    comptime GPU_TEXTURETYPE_2D_ARRAY = Self(1)
    """The texture is a 2-dimensional array image."""
    comptime GPU_TEXTURETYPE_3D = Self(2)
    """The texture is a 3-dimensional image."""
    comptime GPU_TEXTURETYPE_CUBE = Self(3)
    """The texture is a cube image."""
    comptime GPU_TEXTURETYPE_CUBE_ARRAY = Self(4)
    """The texture is a cube array image."""


@register_passable("trivial")
struct GPUSampleCount(Indexer, Intable):
    """Specifies the sample count of a texture.

    Used in multisampling. Note that this value only applies when the texture
    is used as a render target.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUSampleCount.
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

    comptime GPU_SAMPLECOUNT_1 = Self(0)
    """No multisampling."""
    comptime GPU_SAMPLECOUNT_2 = Self(1)
    """MSAA 2x."""
    comptime GPU_SAMPLECOUNT_4 = Self(2)
    """MSAA 4x."""
    comptime GPU_SAMPLECOUNT_8 = Self(3)
    """MSAA 8x."""


@register_passable("trivial")
struct GPUCubeMapFace(Indexer, Intable):
    """Specifies the face of a cube map.

    Can be passed in as the layer field in texture-related structs.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUCubeMapFace.
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

    comptime GPU_CUBEMAPFACE_POSITIVEX = Self(0)
    comptime GPU_CUBEMAPFACE_NEGATIVEX = Self(1)
    comptime GPU_CUBEMAPFACE_POSITIVEY = Self(2)
    comptime GPU_CUBEMAPFACE_NEGATIVEY = Self(3)
    comptime GPU_CUBEMAPFACE_POSITIVEZ = Self(4)
    comptime GPU_CUBEMAPFACE_NEGATIVEZ = Self(5)


@register_passable("trivial")
struct GPUBufferUsageFlags(Intable):
    """Specifies how a buffer is intended to be used by the client.

    A buffer must have at least one usage flag. Note that some usage flag
    combinations are invalid.

    Unlike textures, READ | WRITE can be used for simultaneous read-write
    usage. The same data synchronization concerns as textures apply.

    If you use a STORAGE flag, the data in the buffer must respect std140
    layout conventions. In practical terms this means you must ensure that vec3
    and vec4 fields are 16-byte aligned.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUBufferUsageFlags.
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

    comptime GPU_BUFFERUSAGE_VERTEX = Self(1 << 0)
    """Buffer is a vertex buffer."""
    comptime GPU_BUFFERUSAGE_INDEX = Self(1 << 1)
    """Buffer is an index buffer."""
    comptime GPU_BUFFERUSAGE_INDIRECT = Self(1 << 2)
    """Buffer is an indirect buffer."""
    comptime GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ = Self(1 << 3)
    """Buffer supports storage reads in graphics stages."""
    comptime GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ = Self(1 << 4)
    """Buffer supports storage reads in the compute stage."""
    comptime GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE = Self(1 << 5)
    """Buffer supports storage writes in the compute stage."""


@register_passable("trivial")
struct GPUTransferBufferUsage(Indexer, Intable):
    """Specifies how a transfer buffer is intended to be used by the client.

    Note that mapping and copying FROM an upload transfer buffer or TO a
    download transfer buffer is undefined behavior.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUTransferBufferUsage.
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

    comptime GPU_TRANSFERBUFFERUSAGE_UPLOAD = Self(0)
    comptime GPU_TRANSFERBUFFERUSAGE_DOWNLOAD = Self(1)


@register_passable("trivial")
struct GPUShaderStage(Indexer, Intable):
    """Specifies which stage a shader program corresponds to.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUShaderStage.
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

    comptime GPU_SHADERSTAGE_VERTEX = Self(0)
    comptime GPU_SHADERSTAGE_FRAGMENT = Self(1)


@register_passable("trivial")
struct GPUShaderFormat(Intable):
    """Specifies the format of shader code.

    Each format corresponds to a specific backend that accepts it.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUShaderFormat.
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

    comptime GPU_SHADERFORMAT_INVALID = Self(0)
    comptime GPU_SHADERFORMAT_PRIVATE = Self(1 << 0)
    """Shaders for NDA'd platforms."""
    comptime GPU_SHADERFORMAT_SPIRV = Self(1 << 1)
    """SPIR-V shaders for Vulkan."""
    comptime GPU_SHADERFORMAT_DXBC = Self(1 << 2)
    """DXBC SM5_1 shaders for D3D12."""
    comptime GPU_SHADERFORMAT_DXIL = Self(1 << 3)
    """DXIL SM6_0 shaders for D3D12."""
    comptime GPU_SHADERFORMAT_MSL = Self(1 << 4)
    """MSL shaders for Metal."""
    comptime GPU_SHADERFORMAT_METALLIB = Self(1 << 5)
    """Precompiled metallib shaders for Metal."""


@register_passable("trivial")
struct GPUVertexElementFormat(Indexer, Intable):
    """Specifies the format of a vertex attribute.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUVertexElementFormat.
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

    comptime GPU_VERTEXELEMENTFORMAT_INVALID = Self(0)

    # 32-bit Signed Integers
    comptime GPU_VERTEXELEMENTFORMAT_INT = Self(1)
    comptime GPU_VERTEXELEMENTFORMAT_INT2 = Self(2)
    comptime GPU_VERTEXELEMENTFORMAT_INT3 = Self(3)
    comptime GPU_VERTEXELEMENTFORMAT_INT4 = Self(4)

    # 32-bit Unsigned Integers
    comptime GPU_VERTEXELEMENTFORMAT_UINT = Self(5)
    comptime GPU_VERTEXELEMENTFORMAT_UINT2 = Self(6)
    comptime GPU_VERTEXELEMENTFORMAT_UINT3 = Self(7)
    comptime GPU_VERTEXELEMENTFORMAT_UINT4 = Self(8)

    # 32-bit Floats
    comptime GPU_VERTEXELEMENTFORMAT_FLOAT = Self(9)
    comptime GPU_VERTEXELEMENTFORMAT_FLOAT2 = Self(10)
    comptime GPU_VERTEXELEMENTFORMAT_FLOAT3 = Self(11)
    comptime GPU_VERTEXELEMENTFORMAT_FLOAT4 = Self(12)

    # 8-bit Signed Integers
    comptime GPU_VERTEXELEMENTFORMAT_BYTE2 = Self(13)
    comptime GPU_VERTEXELEMENTFORMAT_BYTE4 = Self(14)

    # 8-bit Unsigned Integers
    comptime GPU_VERTEXELEMENTFORMAT_UBYTE2 = Self(15)
    comptime GPU_VERTEXELEMENTFORMAT_UBYTE4 = Self(16)

    # 8-bit Signed Normalized
    comptime GPU_VERTEXELEMENTFORMAT_BYTE2_NORM = Self(17)
    comptime GPU_VERTEXELEMENTFORMAT_BYTE4_NORM = Self(18)

    # 8-bit Unsigned Normalized
    comptime GPU_VERTEXELEMENTFORMAT_UBYTE2_NORM = Self(19)
    comptime GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM = Self(20)

    # 16-bit Signed Integers
    comptime GPU_VERTEXELEMENTFORMAT_SHORT2 = Self(21)
    comptime GPU_VERTEXELEMENTFORMAT_SHORT4 = Self(22)

    # 16-bit Unsigned Integers
    comptime GPU_VERTEXELEMENTFORMAT_USHORT2 = Self(23)
    comptime GPU_VERTEXELEMENTFORMAT_USHORT4 = Self(24)

    # 16-bit Signed Normalized
    comptime GPU_VERTEXELEMENTFORMAT_SHORT2_NORM = Self(25)
    comptime GPU_VERTEXELEMENTFORMAT_SHORT4_NORM = Self(26)

    # 16-bit Unsigned Normalized
    comptime GPU_VERTEXELEMENTFORMAT_USHORT2_NORM = Self(27)
    comptime GPU_VERTEXELEMENTFORMAT_USHORT4_NORM = Self(28)

    # 16-bit Floats
    comptime GPU_VERTEXELEMENTFORMAT_HALF2 = Self(29)
    comptime GPU_VERTEXELEMENTFORMAT_HALF4 = Self(30)


@register_passable("trivial")
struct GPUVertexInputRate(Indexer, Intable):
    """Specifies the rate at which vertex attributes are pulled from buffers.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUVertexInputRate.
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

    comptime GPU_VERTEXINPUTRATE_VERTEX = Self(0)
    """Attribute addressing is a function of the vertex index."""
    comptime GPU_VERTEXINPUTRATE_INSTANCE = Self(1)
    """Attribute addressing is a function of the instance index."""


@register_passable("trivial")
struct GPUFillMode(Indexer, Intable):
    """Specifies the fill mode of the graphics pipeline.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUFillMode.
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

    comptime GPU_FILLMODE_FILL = Self(0)
    """Polygons will be rendered via rasterization."""
    comptime GPU_FILLMODE_LINE = Self(1)
    """Polygon edges will be drawn as line segments."""


@register_passable("trivial")
struct GPUCullMode(Indexer, Intable):
    """Specifies the facing direction in which triangle faces will be culled.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUCullMode.
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

    comptime GPU_CULLMODE_NONE = Self(0)
    """No triangles are culled."""
    comptime GPU_CULLMODE_FRONT = Self(1)
    """Front-facing triangles are culled."""
    comptime GPU_CULLMODE_BACK = Self(2)
    """Back-facing triangles are culled."""


@register_passable("trivial")
struct GPUFrontFace(Indexer, Intable):
    """Specifies the vertex winding that will cause a triangle to be determined to
    be front-facing.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUFrontFace.
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

    comptime GPU_FRONTFACE_COUNTER_CLOCKWISE = Self(0)
    """A triangle with counter-clockwise vertex winding will be considered front-facing."""
    comptime GPU_FRONTFACE_CLOCKWISE = Self(1)
    """A triangle with clockwise vertex winding will be considered front-facing."""


@register_passable("trivial")
struct GPUCompareOp(Indexer, Intable):
    """Specifies a comparison operator for depth, stencil and sampler operations.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUCompareOp.
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

    comptime GPU_COMPAREOP_INVALID = Self(0)
    comptime GPU_COMPAREOP_NEVER = Self(1)
    """The comparison always evaluates false."""
    comptime GPU_COMPAREOP_LESS = Self(2)
    """The comparison evaluates reference < test."""
    comptime GPU_COMPAREOP_EQUAL = Self(3)
    """The comparison evaluates reference == test."""
    comptime GPU_COMPAREOP_LESS_OR_EQUAL = Self(4)
    """The comparison evaluates reference <= test."""
    comptime GPU_COMPAREOP_GREATER = Self(5)
    """The comparison evaluates reference > test."""
    comptime GPU_COMPAREOP_NOT_EQUAL = Self(6)
    """The comparison evaluates reference != test."""
    comptime GPU_COMPAREOP_GREATER_OR_EQUAL = Self(7)
    """The comparison evaluates reference >= test."""
    comptime GPU_COMPAREOP_ALWAYS = Self(8)
    """The comparison always evaluates true."""


@register_passable("trivial")
struct GPUStencilOp(Indexer, Intable):
    """Specifies what happens to a stored stencil value if stencil tests fail or
    pass.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUStencilOp.
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

    comptime GPU_STENCILOP_INVALID = Self(0)
    comptime GPU_STENCILOP_KEEP = Self(1)
    """Keeps the current value."""
    comptime GPU_STENCILOP_ZERO = Self(2)
    """Sets the value to 0."""
    comptime GPU_STENCILOP_REPLACE = Self(3)
    """Sets the value to reference."""
    comptime GPU_STENCILOP_INCREMENT_AND_CLAMP = Self(4)
    """Increments the current value and clamps to the maximum value."""
    comptime GPU_STENCILOP_DECREMENT_AND_CLAMP = Self(5)
    """Decrements the current value and clamps to 0."""
    comptime GPU_STENCILOP_INVERT = Self(6)
    """Bitwise-inverts the current value."""
    comptime GPU_STENCILOP_INCREMENT_AND_WRAP = Self(7)
    """Increments the current value and wraps back to 0."""
    comptime GPU_STENCILOP_DECREMENT_AND_WRAP = Self(8)
    """Decrements the current value and wraps to the maximum value."""


@register_passable("trivial")
struct GPUBlendOp(Indexer, Intable):
    """Specifies the operator to be used when pixels in a render target are
    blended with existing pixels in the texture.

    The source color is the value written by the fragment shader. The
    destination color is the value currently existing in the texture.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUBlendOp.
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

    comptime GPU_BLENDOP_INVALID = Self(0)
    comptime GPU_BLENDOP_ADD = Self(1)
    """(source * source_factor) + (destination * destination_factor)."""
    comptime GPU_BLENDOP_SUBTRACT = Self(2)
    """(source * source_factor) - (destination * destination_factor)."""
    comptime GPU_BLENDOP_REVERSE_SUBTRACT = Self(3)
    """(destination * destination_factor) - (source * source_factor)."""
    comptime GPU_BLENDOP_MIN = Self(4)
    """Min(source, destination)."""
    comptime GPU_BLENDOP_MAX = Self(5)
    """Max(source, destination)."""


@register_passable("trivial")
struct GPUBlendFactor(Indexer, Intable):
    """Specifies a blending factor to be used when pixels in a render target are
    blended with existing pixels in the texture.

    The source color is the value written by the fragment shader. The
    destination color is the value currently existing in the texture.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUBlendFactor.
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

    comptime GPU_BLENDFACTOR_INVALID = Self(0)
    comptime GPU_BLENDFACTOR_ZERO = Self(1)
    """0."""
    comptime GPU_BLENDFACTOR_ONE = Self(2)
    """1."""
    comptime GPU_BLENDFACTOR_SRC_COLOR = Self(3)
    """Source color."""
    comptime GPU_BLENDFACTOR_ONE_MINUS_SRC_COLOR = Self(4)
    """1 - source color."""
    comptime GPU_BLENDFACTOR_DST_COLOR = Self(5)
    """Destination color."""
    comptime GPU_BLENDFACTOR_ONE_MINUS_DST_COLOR = Self(6)
    """1 - destination color."""
    comptime GPU_BLENDFACTOR_SRC_ALPHA = Self(7)
    """Source alpha."""
    comptime GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA = Self(8)
    """1 - source alpha."""
    comptime GPU_BLENDFACTOR_DST_ALPHA = Self(9)
    """Destination alpha."""
    comptime GPU_BLENDFACTOR_ONE_MINUS_DST_ALPHA = Self(10)
    """1 - destination alpha."""
    comptime GPU_BLENDFACTOR_CONSTANT_COLOR = Self(11)
    """Blend constant."""
    comptime GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR = Self(12)
    """1 - blend constant."""
    comptime GPU_BLENDFACTOR_SRC_ALPHA_SATURATE = Self(13)
    """Min(source alpha, 1 - destination alpha)."""


@register_passable("trivial")
struct GPUColorComponentFlags(Intable):
    """Specifies which color components are written in a graphics pipeline.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUColorComponentFlags.
    """

    var value: UInt8

    @always_inline
    fn __init__(out self, value: UInt8):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __or__(lhs, rhs: Self) -> Self:
        return Self(lhs.value | rhs.value)

    comptime GPU_COLORCOMPONENT_R = Self(1 << 0)
    """The red component."""
    comptime GPU_COLORCOMPONENT_G = Self(1 << 1)
    """The green component."""
    comptime GPU_COLORCOMPONENT_B = Self(1 << 2)
    """The blue component."""
    comptime GPU_COLORCOMPONENT_A = Self(1 << 3)
    """The alpha component."""


@register_passable("trivial")
struct GPUFilter(Indexer, Intable):
    """Specifies a filter operation used by a sampler.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUFilter.
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

    comptime GPU_FILTER_NEAREST = Self(0)
    """Point filtering."""
    comptime GPU_FILTER_LINEAR = Self(1)
    """Linear filtering."""


@register_passable("trivial")
struct GPUSamplerMipmapMode(Indexer, Intable):
    """Specifies a mipmap mode used by a sampler.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUSamplerMipmapMode.
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

    comptime GPU_SAMPLERMIPMAPMODE_NEAREST = Self(0)
    """Point filtering."""
    comptime GPU_SAMPLERMIPMAPMODE_LINEAR = Self(1)
    """Linear filtering."""


@register_passable("trivial")
struct GPUSamplerAddressMode(Indexer, Intable):
    """Specifies behavior of texture sampling when the coordinates exceed the 0-1
    range.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUSamplerAddressMode.
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

    comptime GPU_SAMPLERADDRESSMODE_REPEAT = Self(0)
    """Specifies that the coordinates will wrap around."""
    comptime GPU_SAMPLERADDRESSMODE_MIRRORED_REPEAT = Self(1)
    """Specifies that the coordinates will wrap around mirrored."""
    comptime GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE = Self(2)
    """Specifies that the coordinates will clamp to the 0-1 range."""


@register_passable("trivial")
struct GPUPresentMode(Indexer, Intable):
    """Specifies the timing that will be used to present swapchain textures to the
    OS.

    VSYNC mode will always be supported. IMMEDIATE and MAILBOX modes may not be
    supported on certain systems.

    It is recommended to query SDL_WindowSupportsGPUPresentMode after claiming
    the window if you wish to change the present mode to IMMEDIATE or MAILBOX.

    - VSYNC: Waits for vblank before presenting. No tearing is possible. If
      there is a pending image to present, the new image is enqueued for
      presentation. Disallows tearing at the cost of visual latency.
    - IMMEDIATE: Immediately presents. Lowest latency option, but tearing may
      occur.
    - MAILBOX: Waits for vblank before presenting. No tearing is possible. If
      there is a pending image to present, the pending image is replaced by the
      new image. Similar to VSYNC, but with reduced visual latency.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUPresentMode.
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

    comptime GPU_PRESENTMODE_VSYNC = Self(0)
    comptime GPU_PRESENTMODE_IMMEDIATE = Self(1)
    comptime GPU_PRESENTMODE_MAILBOX = Self(2)


@register_passable("trivial")
struct GPUSwapchainComposition(Indexer, Intable):
    """Specifies the texture format and colorspace of the swapchain textures.

    SDR will always be supported. Other compositions may not be supported on
    certain systems.

    It is recommended to query SDL_WindowSupportsGPUSwapchainComposition after
    claiming the window if you wish to change the swapchain composition from
    SDR.

    - SDR: B8G8R8A8 or R8G8B8A8 swapchain. Pixel values are in sRGB encoding.
    - SDR_LINEAR: B8G8R8A8_SRGB or R8G8B8A8_SRGB swapchain. Pixel values are
      stored in memory in sRGB encoding but accessed in shaders in "linear
      sRGB" encoding which is sRGB but with a linear transfer function.
    - HDR_EXTENDED_LINEAR: R16G16B16A16_FLOAT swapchain. Pixel values are in
      extended linear sRGB encoding and permits values outside of the [0, 1]
      range.
    - HDR10_ST2084: A2R10G10B10 or A2B10G10R10 swapchain. Pixel values are in
      BT.2020 ST2084 (PQ) encoding.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUSwapchainComposition.
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

    comptime GPU_SWAPCHAINCOMPOSITION_SDR = Self(0)
    comptime GPU_SWAPCHAINCOMPOSITION_SDR_LINEAR = Self(1)
    comptime GPU_SWAPCHAINCOMPOSITION_HDR_EXTENDED_LINEAR = Self(2)
    comptime GPU_SWAPCHAINCOMPOSITION_HDR10_ST2084 = Self(3)


@fieldwise_init
struct GPUViewport(ImplicitlyCopyable, Movable):
    """A structure specifying a viewport.

    Docs: https://wiki.libsdl.org/SDL3/GPUViewport.
    """

    var x: c_float
    """The left offset of the viewport."""
    var y: c_float
    """The top offset of the viewport."""
    var w: c_float
    """The width of the viewport."""
    var h: c_float
    """The height of the viewport."""
    var min_depth: c_float
    """The minimum depth of the viewport."""
    var max_depth: c_float
    """The maximum depth of the viewport."""


@fieldwise_init
struct GPUTextureTransferInfo(ImplicitlyCopyable, Movable):
    """A structure specifying parameters related to transferring data to or from a
    texture.

    Docs: https://wiki.libsdl.org/SDL3/GPUTextureTransferInfo.
    """

    var transfer_buffer: Ptr[GPUTransferBuffer, AnyOrigin[True]]
    """The transfer buffer used in the transfer operation."""
    var offset: UInt32
    """The starting byte of the image data in the transfer buffer."""
    var pixels_per_row: UInt32
    """The number of pixels from one row to the next."""
    var rows_per_layer: UInt32
    """The number of rows from one layer/depth-slice to the next."""


@fieldwise_init
struct GPUTransferBufferLocation(ImplicitlyCopyable, Movable):
    """A structure specifying a location in a transfer buffer.

    Used when transferring buffer data to or from a transfer buffer.

    Docs: https://wiki.libsdl.org/SDL3/GPUTransferBufferLocation.
    """

    var transfer_buffer: Ptr[GPUTransferBuffer, AnyOrigin[True]]
    """The transfer buffer used in the transfer operation."""
    var offset: UInt32
    """The starting byte of the buffer data in the transfer buffer."""


@fieldwise_init
struct GPUTextureLocation(ImplicitlyCopyable, Movable):
    """A structure specifying a location in a texture.

    Used when copying data from one texture to another.

    Docs: https://wiki.libsdl.org/SDL3/GPUTextureLocation.
    """

    var texture: Ptr[GPUTexture, AnyOrigin[True]]
    """The texture used in the copy operation."""
    var mip_level: UInt32
    """The mip level index of the location."""
    var layer: UInt32
    """The layer index of the location."""
    var x: UInt32
    """The left offset of the location."""
    var y: UInt32
    """The top offset of the location."""
    var z: UInt32
    """The front offset of the location."""


@fieldwise_init
struct GPUTextureRegion(ImplicitlyCopyable, Movable):
    """A structure specifying a region of a texture.

    Used when transferring data to or from a texture.

    Docs: https://wiki.libsdl.org/SDL3/GPUTextureRegion.
    """

    var texture: Ptr[GPUTexture, AnyOrigin[True]]
    """The texture used in the copy operation."""
    var mip_level: UInt32
    """The mip level index to transfer."""
    var layer: UInt32
    """The layer index to transfer."""
    var x: UInt32
    """The left offset of the region."""
    var y: UInt32
    """The top offset of the region."""
    var z: UInt32
    """The front offset of the region."""
    var w: UInt32
    """The width of the region."""
    var h: UInt32
    """The height of the region."""
    var d: UInt32
    """The depth of the region."""


@fieldwise_init
struct GPUBlitRegion(ImplicitlyCopyable, Movable):
    """A structure specifying a region of a texture used in the blit operation.

    Docs: https://wiki.libsdl.org/SDL3/GPUBlitRegion.
    """

    var texture: Ptr[GPUTexture, AnyOrigin[True]]
    """The texture."""
    var mip_level: UInt32
    """The mip level index of the region."""
    var layer_or_depth_plane: UInt32
    """The layer index or depth plane of the region. This value is treated as a layer index on 2D array and cube textures, and as a depth plane on 3D textures."""
    var x: UInt32
    """The left offset of the region."""
    var y: UInt32
    """The top offset of the region."""
    var w: UInt32
    """The width of the region."""
    var h: UInt32
    """The height of the region."""


@fieldwise_init
struct GPUBufferLocation(ImplicitlyCopyable, Movable):
    """A structure specifying a location in a buffer.

    Used when copying data between buffers.

    Docs: https://wiki.libsdl.org/SDL3/GPUBufferLocation.
    """

    var buffer: Ptr[GPUBuffer, AnyOrigin[True]]
    """The buffer."""
    var offset: UInt32
    """The starting byte within the buffer."""


@fieldwise_init
struct GPUBufferRegion(ImplicitlyCopyable, Movable):
    """A structure specifying a region of a buffer.

    Used when transferring data to or from buffers.

    Docs: https://wiki.libsdl.org/SDL3/GPUBufferRegion.
    """

    var buffer: Ptr[GPUBuffer, AnyOrigin[True]]
    """The buffer."""
    var offset: UInt32
    """The starting byte within the buffer."""
    var size: UInt32
    """The size in bytes of the region."""


@fieldwise_init
struct GPUIndirectDrawCommand(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of an indirect draw command.

    Note that the `first_vertex` and `first_instance` parameters are NOT
    compatible with built-in vertex/instance ID variables in shaders (for
    example, SV_VertexID); GPU APIs and shader languages do not define these
    built-in variables consistently, so if your shader depends on them, the
    only way to keep behavior consistent and portable is to always pass 0 for
    the correlating parameter in the draw calls.

    Docs: https://wiki.libsdl.org/SDL3/GPUIndirectDrawCommand.
    """

    var num_vertices: UInt32
    """The number of vertices to draw."""
    var num_instances: UInt32
    """The number of instances to draw."""
    var first_vertex: UInt32
    """The index of the first vertex to draw."""
    var first_instance: UInt32
    """The ID of the first instance to draw."""


@fieldwise_init
struct GPUIndexedIndirectDrawCommand(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of an indexed indirect draw command.

    Note that the `first_vertex` and `first_instance` parameters are NOT
    compatible with built-in vertex/instance ID variables in shaders (for
    example, SV_VertexID); GPU APIs and shader languages do not define these
    built-in variables consistently, so if your shader depends on them, the
    only way to keep behavior consistent and portable is to always pass 0 for
    the correlating parameter in the draw calls.

    Docs: https://wiki.libsdl.org/SDL3/GPUIndexedIndirectDrawCommand.
    """

    var num_indices: UInt32
    """The number of indices to draw per instance."""
    var num_instances: UInt32
    """The number of instances to draw."""
    var first_index: UInt32
    """The base index within the index buffer."""
    var vertex_offset: Int32
    """The value added to the vertex index before indexing into the vertex buffer."""
    var first_instance: UInt32
    """The ID of the first instance to draw."""


@fieldwise_init
struct GPUIndirectDispatchCommand(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of an indexed dispatch command.

    Docs: https://wiki.libsdl.org/SDL3/GPUIndirectDispatchCommand.
    """

    var groupcount_x: UInt32
    """The number of local workgroups to dispatch in the X dimension."""
    var groupcount_y: UInt32
    """The number of local workgroups to dispatch in the Y dimension."""
    var groupcount_z: UInt32
    """The number of local workgroups to dispatch in the Z dimension."""


@fieldwise_init
struct GPUSamplerCreateInfo(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of a sampler.

    Note that mip_lod_bias is a no-op for the Metal driver. For Metal, LOD bias
    must be applied via shader instead.

    Docs: https://wiki.libsdl.org/SDL3/GPUSamplerCreateInfo.
    """

    var min_filter: GPUFilter
    """The minification filter to apply to lookups."""
    var mag_filter: GPUFilter
    """The magnification filter to apply to lookups."""
    var mipmap_mode: GPUSamplerMipmapMode
    """The mipmap filter to apply to lookups."""
    var address_mode_u: GPUSamplerAddressMode
    """The addressing mode for U coordinates outside [0, 1)."""
    var address_mode_v: GPUSamplerAddressMode
    """The addressing mode for V coordinates outside [0, 1)."""
    var address_mode_w: GPUSamplerAddressMode
    """The addressing mode for W coordinates outside [0, 1)."""
    var mip_lod_bias: c_float
    """The bias to be added to mipmap LOD calculation."""
    var max_anisotropy: c_float
    """The anisotropy value clamp used by the sampler. If enable_anisotropy is false, this is ignored."""
    var compare_op: GPUCompareOp
    """The comparison operator to apply to fetched data before filtering."""
    var min_lod: c_float
    """Clamps the minimum of the computed LOD value."""
    var max_lod: c_float
    """Clamps the maximum of the computed LOD value."""
    var enable_anisotropy: Bool
    """True to enable anisotropic filtering."""
    var enable_compare: Bool
    """True to enable comparison against a reference value during lookups."""
    var padding1: UInt8
    var padding2: UInt8

    var props: PropertiesID
    """A properties ID for extensions. Should be 0 if no extensions are needed."""


@fieldwise_init
struct GPUVertexBufferDescription(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of vertex buffers used in a graphics
    pipeline.

    When you call SDL_BindGPUVertexBuffers, you specify the binding slots of
    the vertex buffers. For example if you called SDL_BindGPUVertexBuffers with
    a first_slot of 2 and num_bindings of 3, the binding slots 2, 3, 4 would be
    used by the vertex buffers you pass in.

    Vertex attributes are linked to buffers via the buffer_slot field of
    SDL_GPUVertexAttribute. For example, if an attribute has a buffer_slot of
    0, then that attribute belongs to the vertex buffer bound at slot 0.

    Docs: https://wiki.libsdl.org/SDL3/GPUVertexBufferDescription.
    """

    var slot: UInt32
    """The binding slot of the vertex buffer."""
    var pitch: UInt32
    """The size of a single element + the offset between elements."""
    var input_rate: GPUVertexInputRate
    """Whether attribute addressing is a function of the vertex index or instance index."""
    var instance_step_rate: UInt32
    """Reserved for future use. Must be set to 0."""


@fieldwise_init
struct GPUVertexAttribute(ImplicitlyCopyable, Movable):
    """A structure specifying a vertex attribute.

    All vertex attribute locations provided to an SDL_GPUVertexInputState must
    be unique.

    Docs: https://wiki.libsdl.org/SDL3/GPUVertexAttribute.
    """

    var location: UInt32
    """The shader input location index."""
    var buffer_slot: UInt32
    """The binding slot of the associated vertex buffer."""
    var format: GPUVertexElementFormat
    """The size and type of the attribute data."""
    var offset: UInt32
    """The byte offset of this attribute relative to the start of the vertex element."""


@fieldwise_init
struct GPUVertexInputState(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of a graphics pipeline vertex input
    state.

    Docs: https://wiki.libsdl.org/SDL3/GPUVertexInputState.
    """

    var vertex_buffer_descriptions: Ptr[GPUVertexBufferDescription, AnyOrigin[False]]
    """A pointer to an array of vertex buffer descriptions."""
    var num_vertex_buffers: UInt32
    """The number of vertex buffer descriptions in the above array."""
    var vertex_attributes: Ptr[GPUVertexAttribute, AnyOrigin[False]]
    """A pointer to an array of vertex attribute descriptions."""
    var num_vertex_attributes: UInt32
    """The number of vertex attribute descriptions in the above array."""


@fieldwise_init
struct GPUStencilOpState(ImplicitlyCopyable, Movable):
    """A structure specifying the stencil operation state of a graphics pipeline.

    Docs: https://wiki.libsdl.org/SDL3/GPUStencilOpState.
    """

    var fail_op: GPUStencilOp
    """The action performed on samples that fail the stencil test."""
    var pass_op: GPUStencilOp
    """The action performed on samples that pass the depth and stencil tests."""
    var depth_fail_op: GPUStencilOp
    """The action performed on samples that pass the stencil test and fail the depth test."""
    var compare_op: GPUCompareOp
    """The comparison operator used in the stencil test."""


@fieldwise_init
struct GPUColorTargetBlendState(ImplicitlyCopyable, Movable):
    """A structure specifying the blend state of a color target.

    Docs: https://wiki.libsdl.org/SDL3/GPUColorTargetBlendState.
    """

    var src_color_blendfactor: GPUBlendFactor
    """The value to be multiplied by the source RGB value."""
    var dst_color_blendfactor: GPUBlendFactor
    """The value to be multiplied by the destination RGB value."""
    var color_blend_op: GPUBlendOp
    """The blend operation for the RGB components."""
    var src_alpha_blendfactor: GPUBlendFactor
    """The value to be multiplied by the source alpha."""
    var dst_alpha_blendfactor: GPUBlendFactor
    """The value to be multiplied by the destination alpha."""
    var alpha_blend_op: GPUBlendOp
    """The blend operation for the alpha component."""
    var color_write_mask: GPUColorComponentFlags
    """A bitmask specifying which of the RGBA components are enabled for writing. Writes to all channels if enable_color_write_mask is false."""
    var enable_blend: Bool
    """Whether blending is enabled for the color target."""
    var enable_color_write_mask: Bool
    """Whether the color write mask is enabled."""
    var padding1: UInt8
    var padding2: UInt8


@fieldwise_init
struct GPUShaderCreateInfo(ImplicitlyCopyable, Movable):
    """A structure specifying code and metadata for creating a shader object.

    Docs: https://wiki.libsdl.org/SDL3/GPUShaderCreateInfo.
    """

    var code_size: c_size_t
    """The size in bytes of the code pointed to."""
    var code: Ptr[UInt8, AnyOrigin[False]]
    """A pointer to shader code."""
    var entrypoint: Ptr[c_char, AnyOrigin[False]]
    """A pointer to a null-terminated UTF-8 string specifying the entry point function name for the shader."""
    var format: GPUShaderFormat
    """The format of the shader code."""
    var stage: GPUShaderStage
    """The stage the shader program corresponds to."""
    var num_samplers: UInt32
    """The number of samplers defined in the shader."""
    var num_storage_textures: UInt32
    """The number of storage textures defined in the shader."""
    var num_storage_buffers: UInt32
    """The number of storage buffers defined in the shader."""
    var num_uniform_buffers: UInt32
    """The number of uniform buffers defined in the shader."""

    var props: PropertiesID
    """A properties ID for extensions. Should be 0 if no extensions are needed."""


@fieldwise_init
struct GPUTextureCreateInfo(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of a texture.

    Usage flags can be bitwise OR'd together for combinations of usages. Note
    that certain usage combinations are invalid, for example SAMPLER and
    GRAPHICS_STORAGE.

    Docs: https://wiki.libsdl.org/SDL3/GPUTextureCreateInfo.
    """

    var type: GPUTextureType
    """The base dimensionality of the texture."""
    var format: GPUTextureFormat
    """The pixel format of the texture."""
    var usage: GPUTextureUsageFlags
    """How the texture is intended to be used by the client."""
    var width: UInt32
    """The width of the texture."""
    var height: UInt32
    """The height of the texture."""
    var layer_count_or_depth: UInt32
    """The layer count or depth of the texture. This value is treated as a layer count on 2D array textures, and as a depth value on 3D textures."""
    var num_levels: UInt32
    """The number of mip levels in the texture."""
    var sample_count: GPUSampleCount
    """The number of samples per texel. Only applies if the texture is used as a render target."""

    var props: PropertiesID
    """A properties ID for extensions. Should be 0 if no extensions are needed."""


@fieldwise_init
struct GPUBufferCreateInfo(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of a buffer.

    Usage flags can be bitwise OR'd together for combinations of usages. Note
    that certain combinations are invalid, for example VERTEX and INDEX.

    Docs: https://wiki.libsdl.org/SDL3/GPUBufferCreateInfo.
    """

    var usage: GPUBufferUsageFlags
    """How the buffer is intended to be used by the client."""
    var size: UInt32
    """The size in bytes of the buffer."""

    var props: PropertiesID
    """A properties ID for extensions. Should be 0 if no extensions are needed."""


@fieldwise_init
struct GPUTransferBufferCreateInfo(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of a transfer buffer.

    Docs: https://wiki.libsdl.org/SDL3/GPUTransferBufferCreateInfo.
    """

    var usage: GPUTransferBufferUsage
    """How the transfer buffer is intended to be used by the client."""
    var size: UInt32
    """The size in bytes of the transfer buffer."""

    var props: PropertiesID
    """A properties ID for extensions. Should be 0 if no extensions are needed."""


@fieldwise_init
struct GPURasterizerState(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of the graphics pipeline rasterizer
    state.

    Note that SDL_GPU_FILLMODE_LINE is not supported on many Android devices.
    For those devices, the fill mode will automatically fall back to FILL.

    Also note that the D3D12 driver will enable depth clamping even if
    enable_depth_clip is true. If you need this clamp+clip behavior, consider
    enabling depth clip and then manually clamping depth in your fragment
    shaders on Metal and Vulkan.

    Docs: https://wiki.libsdl.org/SDL3/GPURasterizerState.
    """

    var fill_mode: GPUFillMode
    """Whether polygons will be filled in or drawn as lines."""
    var cull_mode: GPUCullMode
    """The facing direction in which triangles will be culled."""
    var front_face: GPUFrontFace
    """The vertex winding that will cause a triangle to be determined as front-facing."""
    var depth_bias_constant_factor: c_float
    """A scalar factor controlling the depth value added to each fragment."""
    var depth_bias_clamp: c_float
    """The maximum depth bias of a fragment."""
    var depth_bias_slope_factor: c_float
    """A scalar factor applied to a fragment's slope in depth calculations."""
    var enable_depth_bias: Bool
    """True to bias fragment depth values."""
    var enable_depth_clip: Bool
    """True to enable depth clip, false to enable depth clamp."""
    var padding1: UInt8
    var padding2: UInt8


@fieldwise_init
struct GPUMultisampleState(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of the graphics pipeline multisample
    state.

    Docs: https://wiki.libsdl.org/SDL3/GPUMultisampleState.
    """

    var sample_count: GPUSampleCount
    """The number of samples to be used in rasterization."""
    var sample_mask: UInt32
    """Reserved for future use. Must be set to 0."""
    var enable_mask: Bool
    """Reserved for future use. Must be set to false."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8


@fieldwise_init
struct GPUDepthStencilState(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of the graphics pipeline depth
    stencil state.

    Docs: https://wiki.libsdl.org/SDL3/GPUDepthStencilState.
    """

    var compare_op: GPUCompareOp
    """The comparison operator used for depth testing."""
    var back_stencil_state: GPUStencilOpState
    """The stencil op state for back-facing triangles."""
    var front_stencil_state: GPUStencilOpState
    """The stencil op state for front-facing triangles."""
    var compare_mask: UInt8
    """Selects the bits of the stencil values participating in the stencil test."""
    var write_mask: UInt8
    """Selects the bits of the stencil values updated by the stencil test."""
    var enable_depth_test: Bool
    """True enables the depth test."""
    var enable_depth_write: Bool
    """True enables depth writes. Depth writes are always disabled when enable_depth_test is false."""
    var enable_stencil_test: Bool
    """True enables the stencil test."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8


@fieldwise_init
struct GPUColorTargetDescription(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of color targets used in a graphics
    pipeline.

    Docs: https://wiki.libsdl.org/SDL3/GPUColorTargetDescription.
    """

    var format: GPUTextureFormat
    """The pixel format of the texture to be used as a color target."""
    var blend_state: GPUColorTargetBlendState
    """The blend state to be used for the color target."""


@fieldwise_init
struct GPUGraphicsPipelineTargetInfo(ImplicitlyCopyable, Movable):
    """A structure specifying the descriptions of render targets used in a
    graphics pipeline.

    Docs: https://wiki.libsdl.org/SDL3/GPUGraphicsPipelineTargetInfo.
    """

    var color_target_descriptions: Ptr[GPUColorTargetDescription, AnyOrigin[False]]
    """A pointer to an array of color target descriptions."""
    var num_color_targets: UInt32
    """The number of color target descriptions in the above array."""
    var depth_stencil_format: GPUTextureFormat
    """The pixel format of the depth-stencil target. Ignored if has_depth_stencil_target is false."""
    var has_depth_stencil_target: Bool
    """True specifies that the pipeline uses a depth-stencil target."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8


@fieldwise_init
struct GPUGraphicsPipelineCreateInfo(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of a graphics pipeline state.

    Docs: https://wiki.libsdl.org/SDL3/GPUGraphicsPipelineCreateInfo.
    """

    var vertex_shader: Ptr[GPUShader, AnyOrigin[True]]
    """The vertex shader used by the graphics pipeline."""
    var fragment_shader: Ptr[GPUShader, AnyOrigin[True]]
    """The fragment shader used by the graphics pipeline."""
    var vertex_input_state: GPUVertexInputState
    """The vertex layout of the graphics pipeline."""
    var primitive_type: GPUPrimitiveType
    """The primitive topology of the graphics pipeline."""
    var rasterizer_state: GPURasterizerState
    """The rasterizer state of the graphics pipeline."""
    var multisample_state: GPUMultisampleState
    """The multisample state of the graphics pipeline."""
    var depth_stencil_state: GPUDepthStencilState
    """The depth-stencil state of the graphics pipeline."""
    var target_info: GPUGraphicsPipelineTargetInfo
    """Formats and blend modes for the render targets of the graphics pipeline."""

    var props: PropertiesID
    """A properties ID for extensions. Should be 0 if no extensions are needed."""


@fieldwise_init
struct GPUComputePipelineCreateInfo(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of a compute pipeline state.

    Docs: https://wiki.libsdl.org/SDL3/GPUComputePipelineCreateInfo.
    """

    var code_size: c_size_t
    """The size in bytes of the compute shader code pointed to."""
    var code: Ptr[UInt8, AnyOrigin[False]]
    """A pointer to compute shader code."""
    var entrypoint: Ptr[c_char, AnyOrigin[False]]
    """A pointer to a null-terminated UTF-8 string specifying the entry point function name for the shader."""
    var format: GPUShaderFormat
    """The format of the compute shader code."""
    var num_samplers: UInt32
    """The number of samplers defined in the shader."""
    var num_readonly_storage_textures: UInt32
    """The number of readonly storage textures defined in the shader."""
    var num_readonly_storage_buffers: UInt32
    """The number of readonly storage buffers defined in the shader."""
    var num_readwrite_storage_textures: UInt32
    """The number of read-write storage textures defined in the shader."""
    var num_readwrite_storage_buffers: UInt32
    """The number of read-write storage buffers defined in the shader."""
    var num_uniform_buffers: UInt32
    """The number of uniform buffers defined in the shader."""
    var threadcount_x: UInt32
    """The number of threads in the X dimension. This should match the value in the shader."""
    var threadcount_y: UInt32
    """The number of threads in the Y dimension. This should match the value in the shader."""
    var threadcount_z: UInt32
    """The number of threads in the Z dimension. This should match the value in the shader."""

    var props: PropertiesID
    """A properties ID for extensions. Should be 0 if no extensions are needed."""


@fieldwise_init
struct GPUColorTargetInfo(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of a color target used by a render
    pass.

    The load_op field determines what is done with the texture at the beginning
    of the render pass.

    - LOAD: Loads the data currently in the texture. Not recommended for
      multisample textures as it requires significant memory bandwidth.
    - CLEAR: Clears the texture to a single color.
    - DONT_CARE: The driver will do whatever it wants with the texture memory.
      This is a good option if you know that every single pixel will be touched
      in the render pass.

    The store_op field determines what is done with the color results of the
    render pass.

    - STORE: Stores the results of the render pass in the texture. Not
      recommended for multisample textures as it requires significant memory
      bandwidth.
    - DONT_CARE: The driver will do whatever it wants with the texture memory.
      This is often a good option for depth/stencil textures.
    - RESOLVE: Resolves a multisample texture into resolve_texture, which must
      have a sample count of 1. Then the driver may discard the multisample
      texture memory. This is the most performant method of resolving a
      multisample target.
    - RESOLVE_AND_STORE: Resolves a multisample texture into the
      resolve_texture, which must have a sample count of 1. Then the driver
      stores the multisample texture's contents. Not recommended as it requires
      significant memory bandwidth.

    Docs: https://wiki.libsdl.org/SDL3/GPUColorTargetInfo.
    """

    var texture: Ptr[GPUTexture, AnyOrigin[True]]
    """The texture that will be used as a color target by a render pass."""
    var mip_level: UInt32
    """The mip level to use as a color target."""
    var layer_or_depth_plane: UInt32
    """The layer index or depth plane to use as a color target. This value is treated as a layer index on 2D array and cube textures, and as a depth plane on 3D textures."""
    var clear_color: FColor
    """The color to clear the color target to at the start of the render pass. Ignored if SDL_GPU_LOADOP_CLEAR is not used."""
    var load_op: GPULoadOp
    """What is done with the contents of the color target at the beginning of the render pass."""
    var store_op: GPUStoreOp
    """What is done with the results of the render pass."""
    var resolve_texture: Ptr[GPUTexture, AnyOrigin[True]]
    """The texture that will receive the results of a multisample resolve operation. Ignored if a RESOLVE* store_op is not used."""
    var resolve_mip_level: UInt32
    """The mip level of the resolve texture to use for the resolve operation. Ignored if a RESOLVE* store_op is not used."""
    var resolve_layer: UInt32
    """The layer index of the resolve texture to use for the resolve operation. Ignored if a RESOLVE* store_op is not used."""
    var cycle: Bool
    """True cycles the texture if the texture is bound and load_op is not LOAD."""
    var cycle_resolve_texture: Bool
    """True cycles the resolve texture if the resolve texture is bound. Ignored if a RESOLVE* store_op is not used."""
    var padding1: UInt8
    var padding2: UInt8


@fieldwise_init
struct GPUDepthStencilTargetInfo(ImplicitlyCopyable, Movable):
    """A structure specifying the parameters of a depth-stencil target used by a
    render pass.

    The load_op field determines what is done with the depth contents of the
    texture at the beginning of the render pass.

    - LOAD: Loads the depth values currently in the texture.
    - CLEAR: Clears the texture to a single depth.
    - DONT_CARE: The driver will do whatever it wants with the memory. This is
      a good option if you know that every single pixel will be touched in the
      render pass.

    The store_op field determines what is done with the depth results of the
    render pass.

    - STORE: Stores the depth results in the texture.
    - DONT_CARE: The driver will do whatever it wants with the depth results.
      This is often a good option for depth/stencil textures that don't need to
      be reused again.

    The stencil_load_op field determines what is done with the stencil contents
    of the texture at the beginning of the render pass.

    - LOAD: Loads the stencil values currently in the texture.
    - CLEAR: Clears the stencil values to a single value.
    - DONT_CARE: The driver will do whatever it wants with the memory. This is
      a good option if you know that every single pixel will be touched in the
      render pass.

    The stencil_store_op field determines what is done with the stencil results
    of the render pass.

    - STORE: Stores the stencil results in the texture.
    - DONT_CARE: The driver will do whatever it wants with the stencil results.
      This is often a good option for depth/stencil textures that don't need to
      be reused again.

    Note that depth/stencil targets do not support multisample resolves.

    Docs: https://wiki.libsdl.org/SDL3/GPUDepthStencilTargetInfo.
    """

    var texture: Ptr[GPUTexture, AnyOrigin[True]]
    """The texture that will be used as the depth stencil target by the render pass."""
    var clear_depth: c_float
    """The value to clear the depth component to at the beginning of the render pass. Ignored if SDL_GPU_LOADOP_CLEAR is not used."""
    var load_op: GPULoadOp
    """What is done with the depth contents at the beginning of the render pass."""
    var store_op: GPUStoreOp
    """What is done with the depth results of the render pass."""
    var stencil_load_op: GPULoadOp
    """What is done with the stencil contents at the beginning of the render pass."""
    var stencil_store_op: GPUStoreOp
    """What is done with the stencil results of the render pass."""
    var cycle: Bool
    """True cycles the texture if the texture is bound and any load ops are not LOAD."""
    var clear_stencil: UInt8
    """The value to clear the stencil component to at the beginning of the render pass. Ignored if SDL_GPU_LOADOP_CLEAR is not used."""
    var padding1: UInt8
    var padding2: UInt8


@fieldwise_init
struct GPUBlitInfo(ImplicitlyCopyable, Movable):
    """A structure containing parameters for a blit command.

    Docs: https://wiki.libsdl.org/SDL3/GPUBlitInfo.
    """

    var source: GPUBlitRegion
    """The source region for the blit."""
    var destination: GPUBlitRegion
    """The destination region for the blit."""
    var load_op: GPULoadOp
    """What is done with the contents of the destination before the blit."""
    var clear_color: FColor
    """The color to clear the destination region to before the blit. Ignored if load_op is not SDL_GPU_LOADOP_CLEAR."""
    var flip_mode: FlipMode
    """The flip mode for the source region."""
    var filter: GPUFilter
    """The filter mode used when blitting."""
    var cycle: Bool
    """True cycles the destination texture if it is already bound."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8


@fieldwise_init
struct GPUBufferBinding(ImplicitlyCopyable, Movable):
    """A structure specifying parameters in a buffer binding call.

    Docs: https://wiki.libsdl.org/SDL3/GPUBufferBinding.
    """

    var buffer: Ptr[GPUBuffer, AnyOrigin[True]]
    """The buffer to bind. Must have been created with SDL_GPU_BUFFERUSAGE_VERTEX for SDL_BindGPUVertexBuffers, or SDL_GPU_BUFFERUSAGE_INDEX for SDL_BindGPUIndexBuffer."""
    var offset: UInt32
    """The starting byte of the data to bind in the buffer."""


@fieldwise_init
struct GPUTextureSamplerBinding(ImplicitlyCopyable, Movable):
    """A structure specifying parameters in a sampler binding call.

    Docs: https://wiki.libsdl.org/SDL3/GPUTextureSamplerBinding.
    """

    var texture: Ptr[GPUTexture, AnyOrigin[True]]
    """The texture to bind. Must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER."""
    var sampler: Ptr[GPUSampler, AnyOrigin[True]]
    """The sampler to bind."""


@fieldwise_init
struct GPUStorageBufferReadWriteBinding(ImplicitlyCopyable, Movable):
    """A structure specifying parameters related to binding buffers in a compute
    pass.

    Docs: https://wiki.libsdl.org/SDL3/GPUStorageBufferReadWriteBinding.
    """

    var buffer: Ptr[GPUBuffer, AnyOrigin[True]]
    """The buffer to bind. Must have been created with SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE."""
    var cycle: Bool
    """True cycles the buffer if it is already bound."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8


@fieldwise_init
struct GPUStorageTextureReadWriteBinding(ImplicitlyCopyable, Movable):
    """A structure specifying parameters related to binding textures in a compute
    pass.

    Docs: https://wiki.libsdl.org/SDL3/GPUStorageTextureReadWriteBinding.
    """

    var texture: Ptr[GPUTexture, AnyOrigin[True]]
    """The texture to bind. Must have been created with SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE or SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE."""
    var mip_level: UInt32
    """The mip level index to bind."""
    var layer: UInt32
    """The layer index to bind."""
    var cycle: Bool
    """True cycles the texture if it is already bound."""
    var padding1: UInt8
    var padding2: UInt8
    var padding3: UInt8


fn gpu_supports_shader_formats(format_flags: GPUShaderFormat, var name: String) raises -> Bool:
    """Checks for GPU runtime support.

    Args:
        format_flags: A bitflag indicating which shader formats the app is
                      able to provide.
        name: The preferred GPU driver, or NULL to let SDL pick the optimal
              driver.

    Returns:
        True if supported, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUSupportsShaderFormats.
    """

    return _get_dylib_function[lib, "SDL_GPUSupportsShaderFormats", fn (format_flags: GPUShaderFormat, name: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(format_flags, name.unsafe_cstr_ptr())


fn gpu_supports_properties(props: PropertiesID) raises -> Bool:
    """Checks for GPU runtime support.

    Args:
        props: The properties to use.

    Returns:
        True if supported, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUSupportsProperties.
    """

    return _get_dylib_function[lib, "SDL_GPUSupportsProperties", fn (props: PropertiesID) -> Bool]()(props)


fn create_gpu_device(format_flags: GPUShaderFormat, debug_mode: Bool, var name: String, out ret: Ptr[GPUDevice, AnyOrigin[True]]) raises:
    """Creates a GPU context.

    Args:
        format_flags: A bitflag indicating which shader formats the app is
                      able to provide.
        debug_mode: Enable debug mode properties and validations.
        name: The preferred GPU driver, or NULL to let SDL pick the optimal
              driver.

    Returns:
        A GPU context on success or NULL on failure; call SDL_GetError()
        for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateGPUDevice.
    """

    ret = _get_dylib_function[lib, "SDL_CreateGPUDevice", fn (format_flags: GPUShaderFormat, debug_mode: Bool, name: Ptr[c_char, AnyOrigin[False]]) -> Ptr[GPUDevice, AnyOrigin[True]]]()(format_flags, debug_mode, name.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_gpu_device_with_properties(props: PropertiesID, out ret: Ptr[GPUDevice, AnyOrigin[True]]) raises:
    """Creates a GPU context.

    These are the supported properties:

    - `SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOLEAN`: enable debug mode
      properties and validations, defaults to true.
    - `SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOLEAN`: enable to prefer
      energy efficiency over maximum GPU performance, defaults to false.
    - `SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING`: the name of the GPU driver to
      use, if a specific one is desired.

    These are the current shader format properties:

    - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOLEAN`: The app is able to
      provide shaders for an NDA platform.
    - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN`: The app is able to
      provide SPIR-V shaders if applicable.
    - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOLEAN`: The app is able to
      provide DXBC shaders if applicable
    - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN`: The app is able to
      provide DXIL shaders if applicable.
    - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN`: The app is able to
      provide MSL shaders if applicable.
    - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOLEAN`: The app is able to
      provide Metal shader libraries if applicable.

    With the D3D12 renderer:

    - `SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING`: the prefix to
      use for all vertex semantics, default is "TEXCOORD".

    Args:
        props: The properties to use.

    Returns:
        A GPU context on success or NULL on failure; call SDL_GetError()
        for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateGPUDeviceWithProperties.
    """

    ret = _get_dylib_function[lib, "SDL_CreateGPUDeviceWithProperties", fn (props: PropertiesID) -> Ptr[GPUDevice, AnyOrigin[True]]]()(props)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn destroy_gpu_device(device: Ptr[GPUDevice, AnyOrigin[True]]) raises -> None:
    """Destroys a GPU context previously returned by SDL_CreateGPUDevice.

    Args:
        device: A GPU Context to destroy.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyGPUDevice.
    """

    return _get_dylib_function[lib, "SDL_DestroyGPUDevice", fn (device: Ptr[GPUDevice, AnyOrigin[True]]) -> None]()(device)


fn get_num_gpu_drivers() raises -> c_int:
    """Get the number of GPU drivers compiled into SDL.

    Returns:
        The number of built in GPU drivers.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumGPUDrivers.
    """

    return _get_dylib_function[lib, "SDL_GetNumGPUDrivers", fn () -> c_int]()()


fn get_gpu_driver(index: c_int) raises -> Ptr[c_char, AnyOrigin[False]]:
    """Get the name of a built in GPU driver.

    The GPU drivers are presented in the order in which they are normally
    checked during initialization.

    The names of drivers are all simple, low-ASCII identifiers, like "vulkan",
    "metal" or "direct3d12". These never have Unicode characters, and are not
    meant to be proper names.

    Args:
        index: The index of a GPU driver.

    Returns:
        The name of the GPU driver with the given **index**.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGPUDriver.
    """

    return _get_dylib_function[lib, "SDL_GetGPUDriver", fn (index: c_int) -> Ptr[c_char, AnyOrigin[False]]]()(index)


fn get_gpu_device_driver(device: Ptr[GPUDevice, AnyOrigin[True]]) raises -> Ptr[c_char, AnyOrigin[False]]:
    """Returns the name of the backend used to create this GPU context.

    Args:
        device: A GPU context to query.

    Returns:
        The name of the device's driver, or NULL on error.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGPUDeviceDriver.
    """

    return _get_dylib_function[lib, "SDL_GetGPUDeviceDriver", fn (device: Ptr[GPUDevice, AnyOrigin[True]]) -> Ptr[c_char, AnyOrigin[False]]]()(device)


fn get_gpu_shader_formats(device: Ptr[GPUDevice, AnyOrigin[True]]) raises -> GPUShaderFormat:
    """Returns the supported shader formats for this GPU context.

    Args:
        device: A GPU context to query.

    Returns:
        A bitflag indicating which shader formats the driver is able to
        consume.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGPUShaderFormats.
    """

    return _get_dylib_function[lib, "SDL_GetGPUShaderFormats", fn (device: Ptr[GPUDevice, AnyOrigin[True]]) -> GPUShaderFormat]()(device)


fn create_gpu_compute_pipeline(device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUComputePipelineCreateInfo, AnyOrigin[False]], out ret: Ptr[GPUComputePipeline, AnyOrigin[True]]) raises:
    """Creates a pipeline object to be used in a compute workflow.

    Shader resource bindings must be authored to follow a particular order
    depending on the shader format.

    For SPIR-V shaders, use the following resource sets:

    - 0: Sampled textures, followed by read-only storage textures, followed by
      read-only storage buffers
    - 1: Read-write storage textures, followed by read-write storage buffers
    - 2: Uniform buffers

    For DXBC and DXIL shaders, use the following register order:

    - (t[n], space0): Sampled textures, followed by read-only storage textures,
      followed by read-only storage buffers
    - (u[n], space1): Read-write storage textures, followed by read-write
      storage buffers
    - (b[n], space2): Uniform buffers

    For MSL/metallib, use the following order:

    - [[buffer]]: Uniform buffers, followed by read-only storage buffers,
      followed by read-write storage buffers
    - [[texture]]: Sampled textures, followed by read-only storage textures,
      followed by read-write storage textures

    There are optional properties that can be provided through `props`. These
    are the supported properties:

    - `SDL_PROP_GPU_COMPUTEPIPELINE_CREATE_NAME_STRING`: a name that can be
      displayed in debugging tools.

    Args:
        device: A GPU Context.
        createinfo: A struct describing the state of the compute pipeline to
                    create.

    Returns:
        A compute pipeline object on success, or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateGPUComputePipeline.
    """

    ret = _get_dylib_function[lib, "SDL_CreateGPUComputePipeline", fn (device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUComputePipelineCreateInfo, AnyOrigin[False]]) -> Ptr[GPUComputePipeline, AnyOrigin[True]]]()(device, createinfo)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_gpu_graphics_pipeline(device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUGraphicsPipelineCreateInfo, AnyOrigin[False]], out ret: Ptr[GPUGraphicsPipeline, AnyOrigin[True]]) raises:
    """Creates a pipeline object to be used in a graphics workflow.

    There are optional properties that can be provided through `props`. These
    are the supported properties:

    - `SDL_PROP_GPU_GRAPHICSPIPELINE_CREATE_NAME_STRING`: a name that can be
      displayed in debugging tools.

    Args:
        device: A GPU Context.
        createinfo: A struct describing the state of the graphics pipeline to
                    create.

    Returns:
        A graphics pipeline object on success, or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateGPUGraphicsPipeline.
    """

    ret = _get_dylib_function[lib, "SDL_CreateGPUGraphicsPipeline", fn (device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUGraphicsPipelineCreateInfo, AnyOrigin[False]]) -> Ptr[GPUGraphicsPipeline, AnyOrigin[True]]]()(device, createinfo)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_gpu_sampler(device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUSamplerCreateInfo, AnyOrigin[False]], out ret: Ptr[GPUSampler, AnyOrigin[True]]) raises:
    """Creates a sampler object to be used when binding textures in a graphics
    workflow.

    There are optional properties that can be provided through `props`. These
    are the supported properties:

    - `SDL_PROP_GPU_SAMPLER_CREATE_NAME_STRING`: a name that can be displayed
      in debugging tools.

    Args:
        device: A GPU Context.
        createinfo: A struct describing the state of the sampler to create.

    Returns:
        A sampler object on success, or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateGPUSampler.
    """

    ret = _get_dylib_function[lib, "SDL_CreateGPUSampler", fn (device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUSamplerCreateInfo, AnyOrigin[False]]) -> Ptr[GPUSampler, AnyOrigin[True]]]()(device, createinfo)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_gpu_shader(device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUShaderCreateInfo, AnyOrigin[False]], out ret: Ptr[GPUShader, AnyOrigin[True]]) raises:
    """Creates a shader to be used when creating a graphics pipeline.

    Shader resource bindings must be authored to follow a particular order
    depending on the shader format.

    For SPIR-V shaders, use the following resource sets:

    For vertex shaders:

    - 0: Sampled textures, followed by storage textures, followed by storage
      buffers
    - 1: Uniform buffers

    For fragment shaders:

    - 2: Sampled textures, followed by storage textures, followed by storage
      buffers
    - 3: Uniform buffers

    For DXBC and DXIL shaders, use the following register order:

    For vertex shaders:

    - (t[n], space0): Sampled textures, followed by storage textures, followed
      by storage buffers
    - (s[n], space0): Samplers with indices corresponding to the sampled
      textures
    - (b[n], space1): Uniform buffers

    For pixel shaders:

    - (t[n], space2): Sampled textures, followed by storage textures, followed
      by storage buffers
    - (s[n], space2): Samplers with indices corresponding to the sampled
      textures
    - (b[n], space3): Uniform buffers

    For MSL/metallib, use the following order:

    - [[texture]]: Sampled textures, followed by storage textures
    - [[sampler]]: Samplers with indices corresponding to the sampled textures
    - [[buffer]]: Uniform buffers, followed by storage buffers. Vertex buffer 0
      is bound at [[buffer(14)]], vertex buffer 1 at [[buffer(15)]], and so on.
      Rather than manually authoring vertex buffer indices, use the
      [[stage_in]] attribute which will automatically use the vertex input
      information from the SDL_GPUGraphicsPipeline.

    Shader semantics other than system-value semantics do not matter in D3D12
    and for ease of use the SDL implementation assumes that non system-value
    semantics will all be TEXCOORD. If you are using HLSL as the shader source
    language, your vertex semantics should start at TEXCOORD0 and increment
    like so: TEXCOORD1, TEXCOORD2, etc. If you wish to change the semantic
    prefix to something other than TEXCOORD you can use
    SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING with
    SDL_CreateGPUDeviceWithProperties().

    There are optional properties that can be provided through `props`. These
    are the supported properties:

    - `SDL_PROP_GPU_SHADER_CREATE_NAME_STRING`: a name that can be displayed in
      debugging tools.

    Args:
        device: A GPU Context.
        createinfo: A struct describing the state of the shader to create.

    Returns:
        A shader object on success, or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateGPUShader.
    """

    ret = _get_dylib_function[lib, "SDL_CreateGPUShader", fn (device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUShaderCreateInfo, AnyOrigin[False]]) -> Ptr[GPUShader, AnyOrigin[True]]]()(device, createinfo)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_gpu_texture(device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUTextureCreateInfo, AnyOrigin[False]], out ret: Ptr[GPUTexture, AnyOrigin[True]]) raises:
    """Creates a texture object to be used in graphics or compute workflows.

    The contents of this texture are undefined until data is written to the
    texture.

    Note that certain combinations of usage flags are invalid. For example, a
    texture cannot have both the SAMPLER and GRAPHICS_STORAGE_READ flags.

    If you request a sample count higher than the hardware supports, the
    implementation will automatically fall back to the highest available sample
    count.

    There are optional properties that can be provided through
    SDL_GPUTextureCreateInfo's `props`. These are the supported properties:

    - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_R_FLOAT`: (Direct3D 12 only) if
      the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
      to a color with this red intensity. Defaults to zero.
    - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_G_FLOAT`: (Direct3D 12 only) if
      the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
      to a color with this green intensity. Defaults to zero.
    - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_B_FLOAT`: (Direct3D 12 only) if
      the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
      to a color with this blue intensity. Defaults to zero.
    - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_A_FLOAT`: (Direct3D 12 only) if
      the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
      to a color with this alpha intensity. Defaults to zero.
    - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_DEPTH_FLOAT`: (Direct3D 12 only)
      if the texture usage is SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET, clear
      the texture to a depth of this value. Defaults to zero.
    - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_STENCIL_NUMBER`: (Direct3D 12
      only) if the texture usage is SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET,
      clear the texture to a stencil of this Uint8 value. Defaults to zero.
    - `SDL_PROP_GPU_TEXTURE_CREATE_NAME_STRING`: a name that can be displayed
      in debugging tools.

    Args:
        device: A GPU Context.
        createinfo: A struct describing the state of the texture to create.

    Returns:
        A texture object on success, or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateGPUTexture.
    """

    ret = _get_dylib_function[lib, "SDL_CreateGPUTexture", fn (device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUTextureCreateInfo, AnyOrigin[False]]) -> Ptr[GPUTexture, AnyOrigin[True]]]()(device, createinfo)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_gpu_buffer(device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUBufferCreateInfo, AnyOrigin[False]], out ret: Ptr[GPUBuffer, AnyOrigin[True]]) raises:
    """Creates a buffer object to be used in graphics or compute workflows.

    The contents of this buffer are undefined until data is written to the
    buffer.

    Note that certain combinations of usage flags are invalid. For example, a
    buffer cannot have both the VERTEX and INDEX flags.

    If you use a STORAGE flag, the data in the buffer must respect std140
    layout conventions. In practical terms this means you must ensure that vec3
    and vec4 fields are 16-byte aligned.

    For better understanding of underlying concepts and memory management with
    SDL GPU API, you may refer
    [this blog post](https://moonside.games/posts/sdl-gpu-concepts-cycling/)
    .

    There are optional properties that can be provided through `props`. These
    are the supported properties:

    - `SDL_PROP_GPU_BUFFER_CREATE_NAME_STRING`: a name that can be displayed in
      debugging tools.

    Args:
        device: A GPU Context.
        createinfo: A struct describing the state of the buffer to create.

    Returns:
        A buffer object on success, or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateGPUBuffer.
    """

    ret = _get_dylib_function[lib, "SDL_CreateGPUBuffer", fn (device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUBufferCreateInfo, AnyOrigin[False]]) -> Ptr[GPUBuffer, AnyOrigin[True]]]()(device, createinfo)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn create_gpu_transfer_buffer(device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUTransferBufferCreateInfo, AnyOrigin[False]], out ret: Ptr[GPUTransferBuffer, AnyOrigin[True]]) raises:
    """Creates a transfer buffer to be used when uploading to or downloading from
    graphics resources.

    Download buffers can be particularly expensive to create, so it is good
    practice to reuse them if data will be downloaded regularly.

    There are optional properties that can be provided through `props`. These
    are the supported properties:

    - `SDL_PROP_GPU_TRANSFERBUFFER_CREATE_NAME_STRING`: a name that can be
      displayed in debugging tools.

    Args:
        device: A GPU Context.
        createinfo: A struct describing the state of the transfer buffer to
                    create.

    Returns:
        A transfer buffer on success, or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateGPUTransferBuffer.
    """

    ret = _get_dylib_function[lib, "SDL_CreateGPUTransferBuffer", fn (device: Ptr[GPUDevice, AnyOrigin[True]], createinfo: Ptr[GPUTransferBufferCreateInfo, AnyOrigin[False]]) -> Ptr[GPUTransferBuffer, AnyOrigin[True]]]()(device, createinfo)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn set_gpu_buffer_name(device: Ptr[GPUDevice, AnyOrigin[True]], buffer: Ptr[GPUBuffer, AnyOrigin[True]], var text: String) raises -> None:
    """Sets an arbitrary string constant to label a buffer.

    You should use SDL_PROP_GPU_BUFFER_CREATE_NAME_STRING with
    SDL_CreateGPUBuffer instead of this function to avoid thread safety issues.

    Args:
        device: A GPU Context.
        buffer: A buffer to attach the name to.
        text: A UTF-8 string constant to mark as the name of the buffer.

    Safety:
        This function is not thread safe, you must make sure the
        buffer is not simultaneously used by any other thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGPUBufferName.
    """

    return _get_dylib_function[lib, "SDL_SetGPUBufferName", fn (device: Ptr[GPUDevice, AnyOrigin[True]], buffer: Ptr[GPUBuffer, AnyOrigin[True]], text: Ptr[c_char, AnyOrigin[False]]) -> None]()(device, buffer, text.unsafe_cstr_ptr())


fn set_gpu_texture_name(device: Ptr[GPUDevice, AnyOrigin[True]], texture: Ptr[GPUTexture, AnyOrigin[True]], var text: String) raises -> None:
    """Sets an arbitrary string constant to label a texture.

    You should use SDL_PROP_GPU_TEXTURE_CREATE_NAME_STRING with
    SDL_CreateGPUTexture instead of this function to avoid thread safety
    issues.

    Args:
        device: A GPU Context.
        texture: A texture to attach the name to.
        text: A UTF-8 string constant to mark as the name of the texture.

    Safety:
        This function is not thread safe, you must make sure the
        texture is not simultaneously used by any other thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGPUTextureName.
    """

    return _get_dylib_function[lib, "SDL_SetGPUTextureName", fn (device: Ptr[GPUDevice, AnyOrigin[True]], texture: Ptr[GPUTexture, AnyOrigin[True]], text: Ptr[c_char, AnyOrigin[False]]) -> None]()(device, texture, text.unsafe_cstr_ptr())


fn insert_gpu_debug_label(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], var text: String) raises -> None:
    """Inserts an arbitrary string label into the command buffer callstream.

    Useful for debugging.

    Args:
        command_buffer: A command buffer.
        text: A UTF-8 string constant to insert as the label.

    Docs: https://wiki.libsdl.org/SDL3/SDL_InsertGPUDebugLabel.
    """

    return _get_dylib_function[lib, "SDL_InsertGPUDebugLabel", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], text: Ptr[c_char, AnyOrigin[False]]) -> None]()(command_buffer, text.unsafe_cstr_ptr())


fn push_gpu_debug_group(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], var name: String) raises -> None:
    """Begins a debug group with an arbitrary name.

    Used for denoting groups of calls when viewing the command buffer
    callstream in a graphics debugging tool.

    Each call to SDL_PushGPUDebugGroup must have a corresponding call to
    SDL_PopGPUDebugGroup.

    On some backends (e.g. Metal), pushing a debug group during a
    render/blit/compute pass will create a group that is scoped to the native
    pass rather than the command buffer. For best results, if you push a debug
    group during a pass, always pop it in the same pass.

    Args:
        command_buffer: A command buffer.
        name: A UTF-8 string constant that names the group.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PushGPUDebugGroup.
    """

    return _get_dylib_function[lib, "SDL_PushGPUDebugGroup", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], name: Ptr[c_char, AnyOrigin[False]]) -> None]()(command_buffer, name.unsafe_cstr_ptr())


fn pop_gpu_debug_group(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]]) raises -> None:
    """Ends the most-recently pushed debug group.

    Args:
        command_buffer: A command buffer.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PopGPUDebugGroup.
    """

    return _get_dylib_function[lib, "SDL_PopGPUDebugGroup", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]]) -> None]()(command_buffer)


fn release_gpu_texture(device: Ptr[GPUDevice, AnyOrigin[True]], texture: Ptr[GPUTexture, AnyOrigin[True]]) raises -> None:
    """Frees the given texture as soon as it is safe to do so.

    You must not reference the texture after calling this function.

    Args:
        device: A GPU context.
        texture: A texture to be destroyed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReleaseGPUTexture.
    """

    return _get_dylib_function[lib, "SDL_ReleaseGPUTexture", fn (device: Ptr[GPUDevice, AnyOrigin[True]], texture: Ptr[GPUTexture, AnyOrigin[True]]) -> None]()(device, texture)


fn release_gpu_sampler(device: Ptr[GPUDevice, AnyOrigin[True]], sampler: Ptr[GPUSampler, AnyOrigin[True]]) raises -> None:
    """Frees the given sampler as soon as it is safe to do so.

    You must not reference the sampler after calling this function.

    Args:
        device: A GPU context.
        sampler: A sampler to be destroyed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReleaseGPUSampler.
    """

    return _get_dylib_function[lib, "SDL_ReleaseGPUSampler", fn (device: Ptr[GPUDevice, AnyOrigin[True]], sampler: Ptr[GPUSampler, AnyOrigin[True]]) -> None]()(device, sampler)


fn release_gpu_buffer(device: Ptr[GPUDevice, AnyOrigin[True]], buffer: Ptr[GPUBuffer, AnyOrigin[True]]) raises -> None:
    """Frees the given buffer as soon as it is safe to do so.

    You must not reference the buffer after calling this function.

    Args:
        device: A GPU context.
        buffer: A buffer to be destroyed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReleaseGPUBuffer.
    """

    return _get_dylib_function[lib, "SDL_ReleaseGPUBuffer", fn (device: Ptr[GPUDevice, AnyOrigin[True]], buffer: Ptr[GPUBuffer, AnyOrigin[True]]) -> None]()(device, buffer)


fn release_gpu_transfer_buffer(device: Ptr[GPUDevice, AnyOrigin[True]], transfer_buffer: Ptr[GPUTransferBuffer, AnyOrigin[True]]) raises -> None:
    """Frees the given transfer buffer as soon as it is safe to do so.

    You must not reference the transfer buffer after calling this function.

    Args:
        device: A GPU context.
        transfer_buffer: A transfer buffer to be destroyed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReleaseGPUTransferBuffer.
    """

    return _get_dylib_function[lib, "SDL_ReleaseGPUTransferBuffer", fn (device: Ptr[GPUDevice, AnyOrigin[True]], transfer_buffer: Ptr[GPUTransferBuffer, AnyOrigin[True]]) -> None]()(device, transfer_buffer)


fn release_gpu_compute_pipeline(device: Ptr[GPUDevice, AnyOrigin[True]], compute_pipeline: Ptr[GPUComputePipeline, AnyOrigin[True]]) raises -> None:
    """Frees the given compute pipeline as soon as it is safe to do so.

    You must not reference the compute pipeline after calling this function.

    Args:
        device: A GPU context.
        compute_pipeline: A compute pipeline to be destroyed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReleaseGPUComputePipeline.
    """

    return _get_dylib_function[lib, "SDL_ReleaseGPUComputePipeline", fn (device: Ptr[GPUDevice, AnyOrigin[True]], compute_pipeline: Ptr[GPUComputePipeline, AnyOrigin[True]]) -> None]()(device, compute_pipeline)


fn release_gpu_shader(device: Ptr[GPUDevice, AnyOrigin[True]], shader: Ptr[GPUShader, AnyOrigin[True]]) raises -> None:
    """Frees the given shader as soon as it is safe to do so.

    You must not reference the shader after calling this function.

    Args:
        device: A GPU context.
        shader: A shader to be destroyed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReleaseGPUShader.
    """

    return _get_dylib_function[lib, "SDL_ReleaseGPUShader", fn (device: Ptr[GPUDevice, AnyOrigin[True]], shader: Ptr[GPUShader, AnyOrigin[True]]) -> None]()(device, shader)


fn release_gpu_graphics_pipeline(device: Ptr[GPUDevice, AnyOrigin[True]], graphics_pipeline: Ptr[GPUGraphicsPipeline, AnyOrigin[True]]) raises -> None:
    """Frees the given graphics pipeline as soon as it is safe to do so.

    You must not reference the graphics pipeline after calling this function.

    Args:
        device: A GPU context.
        graphics_pipeline: A graphics pipeline to be destroyed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReleaseGPUGraphicsPipeline.
    """

    return _get_dylib_function[lib, "SDL_ReleaseGPUGraphicsPipeline", fn (device: Ptr[GPUDevice, AnyOrigin[True]], graphics_pipeline: Ptr[GPUGraphicsPipeline, AnyOrigin[True]]) -> None]()(device, graphics_pipeline)


fn acquire_gpu_command_buffer(device: Ptr[GPUDevice, AnyOrigin[True]], out ret: Ptr[GPUCommandBuffer, AnyOrigin[True]]) raises:
    """Acquire a command buffer.

    This command buffer is managed by the implementation and should not be
    freed by the user. The command buffer may only be used on the thread it was
    acquired on. The command buffer should be submitted on the thread it was
    acquired on.

    It is valid to acquire multiple command buffers on the same thread at once.
    In fact a common design pattern is to acquire two command buffers per frame
    where one is dedicated to render and compute passes and the other is
    dedicated to copy passes and other preparatory work such as generating
    mipmaps. Interleaving commands between the two command buffers reduces the
    total amount of passes overall which improves rendering performance.

    Args:
        device: A GPU context.

    Returns:
        A command buffer, or NULL on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AcquireGPUCommandBuffer.
    """

    ret = _get_dylib_function[lib, "SDL_AcquireGPUCommandBuffer", fn (device: Ptr[GPUDevice, AnyOrigin[True]]) -> Ptr[GPUCommandBuffer, AnyOrigin[True]]]()(device)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn push_gpu_vertex_uniform_data(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], slot_index: UInt32, data: Ptr[NoneType, AnyOrigin[False]], length: UInt32) raises -> None:
    """Pushes data to a vertex uniform slot on the command buffer.

    Subsequent draw calls will use this uniform data.

    The data being pushed must respect std140 layout conventions. In practical
    terms this means you must ensure that vec3 and vec4 fields are 16-byte
    aligned.

    Args:
        command_buffer: A command buffer.
        slot_index: The vertex uniform slot to push data to.
        data: Client data to write.
        length: The length of the data to write.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PushGPUVertexUniformData.
    """

    return _get_dylib_function[lib, "SDL_PushGPUVertexUniformData", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], slot_index: UInt32, data: Ptr[NoneType, AnyOrigin[False]], length: UInt32) -> None]()(command_buffer, slot_index, data, length)


fn push_gpu_fragment_uniform_data(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], slot_index: UInt32, data: Ptr[NoneType, AnyOrigin[False]], length: UInt32) raises -> None:
    """Pushes data to a fragment uniform slot on the command buffer.

    Subsequent draw calls will use this uniform data.

    The data being pushed must respect std140 layout conventions. In practical
    terms this means you must ensure that vec3 and vec4 fields are 16-byte
    aligned.

    Args:
        command_buffer: A command buffer.
        slot_index: The fragment uniform slot to push data to.
        data: Client data to write.
        length: The length of the data to write.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PushGPUFragmentUniformData.
    """

    return _get_dylib_function[lib, "SDL_PushGPUFragmentUniformData", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], slot_index: UInt32, data: Ptr[NoneType, AnyOrigin[False]], length: UInt32) -> None]()(command_buffer, slot_index, data, length)


fn push_gpu_compute_uniform_data(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], slot_index: UInt32, data: Ptr[NoneType, AnyOrigin[False]], length: UInt32) raises -> None:
    """Pushes data to a uniform slot on the command buffer.

    Subsequent draw calls will use this uniform data.

    The data being pushed must respect std140 layout conventions. In practical
    terms this means you must ensure that vec3 and vec4 fields are 16-byte
    aligned.

    Args:
        command_buffer: A command buffer.
        slot_index: The uniform slot to push data to.
        data: Client data to write.
        length: The length of the data to write.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PushGPUComputeUniformData.
    """

    return _get_dylib_function[lib, "SDL_PushGPUComputeUniformData", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], slot_index: UInt32, data: Ptr[NoneType, AnyOrigin[False]], length: UInt32) -> None]()(command_buffer, slot_index, data, length)


fn begin_gpu_render_pass(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], color_target_infos: Ptr[GPUColorTargetInfo, AnyOrigin[False]], num_color_targets: UInt32, depth_stencil_target_info: Ptr[GPUDepthStencilTargetInfo, AnyOrigin[False]]) raises -> Ptr[GPURenderPass, AnyOrigin[True]]:
    """Begins a render pass on a command buffer.

    A render pass consists of a set of texture subresources (or depth slices in
    the 3D texture case) which will be rendered to during the render pass,
    along with corresponding clear values and load/store operations. All
    operations related to graphics pipelines must take place inside of a render
    pass. A default viewport and scissor state are automatically set when this
    is called. You cannot begin another render pass, or begin a compute pass or
    copy pass until you have ended the render pass.

    Args:
        command_buffer: A command buffer.
        color_target_infos: An array of texture subresources with
                            corresponding clear values and load/store ops.
        num_color_targets: The number of color targets in the
                           color_target_infos array.
        depth_stencil_target_info: A texture subresource with corresponding
                                   clear value and load/store ops, may be
                                   NULL.

    Returns:
        A render pass handle.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BeginGPURenderPass.
    """

    return _get_dylib_function[lib, "SDL_BeginGPURenderPass", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], color_target_infos: Ptr[GPUColorTargetInfo, AnyOrigin[False]], num_color_targets: UInt32, depth_stencil_target_info: Ptr[GPUDepthStencilTargetInfo, AnyOrigin[False]]) -> Ptr[GPURenderPass, AnyOrigin[True]]]()(command_buffer, color_target_infos, num_color_targets, depth_stencil_target_info)


fn bind_gpu_graphics_pipeline(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], graphics_pipeline: Ptr[GPUGraphicsPipeline, AnyOrigin[True]]) raises -> None:
    """Binds a graphics pipeline on a render pass to be used in rendering.

    A graphics pipeline must be bound before making any draw calls.

    Args:
        render_pass: A render pass handle.
        graphics_pipeline: The graphics pipeline to bind.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUGraphicsPipeline.
    """

    return _get_dylib_function[lib, "SDL_BindGPUGraphicsPipeline", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], graphics_pipeline: Ptr[GPUGraphicsPipeline, AnyOrigin[True]]) -> None]()(render_pass, graphics_pipeline)


fn set_gpu_viewport(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], viewport: Ptr[GPUViewport, AnyOrigin[False]]) raises -> None:
    """Sets the current viewport state on a command buffer.

    Args:
        render_pass: A render pass handle.
        viewport: The viewport to set.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGPUViewport.
    """

    return _get_dylib_function[lib, "SDL_SetGPUViewport", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], viewport: Ptr[GPUViewport, AnyOrigin[False]]) -> None]()(render_pass, viewport)


fn set_gpu_scissor(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], scissor: Ptr[Rect, AnyOrigin[False]]) raises -> None:
    """Sets the current scissor state on a command buffer.

    Args:
        render_pass: A render pass handle.
        scissor: The scissor area to set.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGPUScissor.
    """

    return _get_dylib_function[lib, "SDL_SetGPUScissor", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], scissor: Ptr[Rect, AnyOrigin[False]]) -> None]()(render_pass, scissor)


fn set_gpu_blend_constants(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], blend_constants: FColor) raises -> None:
    """Sets the current blend constants on a command buffer.

    Args:
        render_pass: A render pass handle.
        blend_constants: The blend constant color.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGPUBlendConstants.
    """

    return _get_dylib_function[lib, "SDL_SetGPUBlendConstants", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], blend_constants: FColor) -> None]()(render_pass, blend_constants)


fn set_gpu_stencil_reference(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], reference: UInt8) raises -> None:
    """Sets the current stencil reference value on a command buffer.

    Args:
        render_pass: A render pass handle.
        reference: The stencil reference value to set.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGPUStencilReference.
    """

    return _get_dylib_function[lib, "SDL_SetGPUStencilReference", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], reference: UInt8) -> None]()(render_pass, reference)


fn bind_gpu_vertex_buffers(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, bindings: Ptr[GPUBufferBinding, AnyOrigin[False]], num_bindings: UInt32) raises -> None:
    """Binds vertex buffers on a command buffer for use with subsequent draw
    calls.

    Args:
        render_pass: A render pass handle.
        first_slot: The vertex buffer slot to begin binding from.
        bindings: An array of SDL_GPUBufferBinding structs containing vertex
                  buffers and offset values.
        num_bindings: The number of bindings in the bindings array.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUVertexBuffers.
    """

    return _get_dylib_function[lib, "SDL_BindGPUVertexBuffers", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, bindings: Ptr[GPUBufferBinding, AnyOrigin[False]], num_bindings: UInt32) -> None]()(render_pass, first_slot, bindings, num_bindings)


fn bind_gpu_index_buffer(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], binding: Ptr[GPUBufferBinding, AnyOrigin[False]], index_element_size: GPUIndexElementSize) raises -> None:
    """Binds an index buffer on a command buffer for use with subsequent draw
    calls.

    Args:
        render_pass: A render pass handle.
        binding: A pointer to a struct containing an index buffer and offset.
        index_element_size: Whether the index values in the buffer are 16- or
                            32-bit.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUIndexBuffer.
    """

    return _get_dylib_function[lib, "SDL_BindGPUIndexBuffer", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], binding: Ptr[GPUBufferBinding, AnyOrigin[False]], index_element_size: GPUIndexElementSize) -> None]()(render_pass, binding, index_element_size)


fn bind_gpu_vertex_samplers(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, texture_sampler_bindings: Ptr[GPUTextureSamplerBinding, AnyOrigin[False]], num_bindings: UInt32) raises -> None:
    """Binds texture-sampler pairs for use on the vertex shader.

    The textures must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.

    Be sure your shader is set up according to the requirements documented in
    SDL_CreateGPUShader().

    Args:
        render_pass: A render pass handle.
        first_slot: The vertex sampler slot to begin binding from.
        texture_sampler_bindings: An array of texture-sampler binding
                                  structs.
        num_bindings: The number of texture-sampler pairs to bind from the
                      array.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUVertexSamplers.
    """

    return _get_dylib_function[lib, "SDL_BindGPUVertexSamplers", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, texture_sampler_bindings: Ptr[GPUTextureSamplerBinding, AnyOrigin[False]], num_bindings: UInt32) -> None]()(render_pass, first_slot, texture_sampler_bindings, num_bindings)


fn bind_gpu_vertex_storage_textures(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, storage_textures: Ptr[GPUTexture, AnyOrigin[True]], num_bindings: UInt32) raises -> None:
    """Binds storage textures for use on the vertex shader.

    These textures must have been created with
    SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ.

    Be sure your shader is set up according to the requirements documented in
    SDL_CreateGPUShader().

    Args:
        render_pass: A render pass handle.
        first_slot: The vertex storage texture slot to begin binding from.
        storage_textures: An array of storage textures.
        num_bindings: The number of storage texture to bind from the array.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUVertexStorageTextures.
    """

    return _get_dylib_function[lib, "SDL_BindGPUVertexStorageTextures", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, storage_textures: Ptr[GPUTexture, AnyOrigin[True]], num_bindings: UInt32) -> None]()(render_pass, first_slot, storage_textures, num_bindings)


fn bind_gpu_vertex_storage_buffers(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, storage_buffers: Ptr[GPUBuffer, AnyOrigin[True]], num_bindings: UInt32) raises -> None:
    """Binds storage buffers for use on the vertex shader.

    These buffers must have been created with
    SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ.

    Be sure your shader is set up according to the requirements documented in
    SDL_CreateGPUShader().

    Args:
        render_pass: A render pass handle.
        first_slot: The vertex storage buffer slot to begin binding from.
        storage_buffers: An array of buffers.
        num_bindings: The number of buffers to bind from the array.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUVertexStorageBuffers.
    """

    return _get_dylib_function[lib, "SDL_BindGPUVertexStorageBuffers", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, storage_buffers: Ptr[GPUBuffer, AnyOrigin[True]], num_bindings: UInt32) -> None]()(render_pass, first_slot, storage_buffers, num_bindings)


fn bind_gpu_fragment_samplers(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, texture_sampler_bindings: Ptr[GPUTextureSamplerBinding, AnyOrigin[False]], num_bindings: UInt32) raises -> None:
    """Binds texture-sampler pairs for use on the fragment shader.

    The textures must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.

    Be sure your shader is set up according to the requirements documented in
    SDL_CreateGPUShader().

    Args:
        render_pass: A render pass handle.
        first_slot: The fragment sampler slot to begin binding from.
        texture_sampler_bindings: An array of texture-sampler binding
                                  structs.
        num_bindings: The number of texture-sampler pairs to bind from the
                      array.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUFragmentSamplers.
    """

    return _get_dylib_function[lib, "SDL_BindGPUFragmentSamplers", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, texture_sampler_bindings: Ptr[GPUTextureSamplerBinding, AnyOrigin[False]], num_bindings: UInt32) -> None]()(render_pass, first_slot, texture_sampler_bindings, num_bindings)


fn bind_gpu_fragment_storage_textures(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, storage_textures: Ptr[GPUTexture, AnyOrigin[True]], num_bindings: UInt32) raises -> None:
    """Binds storage textures for use on the fragment shader.

    These textures must have been created with
    SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ.

    Be sure your shader is set up according to the requirements documented in
    SDL_CreateGPUShader().

    Args:
        render_pass: A render pass handle.
        first_slot: The fragment storage texture slot to begin binding from.
        storage_textures: An array of storage textures.
        num_bindings: The number of storage textures to bind from the array.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUFragmentStorageTextures.
    """

    return _get_dylib_function[lib, "SDL_BindGPUFragmentStorageTextures", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, storage_textures: Ptr[GPUTexture, AnyOrigin[True]], num_bindings: UInt32) -> None]()(render_pass, first_slot, storage_textures, num_bindings)


fn bind_gpu_fragment_storage_buffers(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, storage_buffers: Ptr[GPUBuffer, AnyOrigin[True]], num_bindings: UInt32) raises -> None:
    """Binds storage buffers for use on the fragment shader.

    These buffers must have been created with
    SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ.

    Be sure your shader is set up according to the requirements documented in
    SDL_CreateGPUShader().

    Args:
        render_pass: A render pass handle.
        first_slot: The fragment storage buffer slot to begin binding from.
        storage_buffers: An array of storage buffers.
        num_bindings: The number of storage buffers to bind from the array.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUFragmentStorageBuffers.
    """

    return _get_dylib_function[lib, "SDL_BindGPUFragmentStorageBuffers", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], first_slot: UInt32, storage_buffers: Ptr[GPUBuffer, AnyOrigin[True]], num_bindings: UInt32) -> None]()(render_pass, first_slot, storage_buffers, num_bindings)


fn draw_gpu_indexed_primitives(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], num_indices: UInt32, num_instances: UInt32, first_index: UInt32, vertex_offset: Int32, first_instance: UInt32) raises -> None:
    """Draws data using bound graphics state with an index buffer and instancing
    enabled.

    You must not call this function before binding a graphics pipeline.

    Note that the `first_vertex` and `first_instance` parameters are NOT
    compatible with built-in vertex/instance ID variables in shaders (for
    example, SV_VertexID); GPU APIs and shader languages do not define these
    built-in variables consistently, so if your shader depends on them, the
    only way to keep behavior consistent and portable is to always pass 0 for
    the correlating parameter in the draw calls.

    Args:
        render_pass: A render pass handle.
        num_indices: The number of indices to draw per instance.
        num_instances: The number of instances to draw.
        first_index: The starting index within the index buffer.
        vertex_offset: Value added to vertex index before indexing into the
                       vertex buffer.
        first_instance: The ID of the first instance to draw.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DrawGPUIndexedPrimitives.
    """

    return _get_dylib_function[lib, "SDL_DrawGPUIndexedPrimitives", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], num_indices: UInt32, num_instances: UInt32, first_index: UInt32, vertex_offset: Int32, first_instance: UInt32) -> None]()(render_pass, num_indices, num_instances, first_index, vertex_offset, first_instance)


fn draw_gpu_primitives(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], num_vertices: UInt32, num_instances: UInt32, first_vertex: UInt32, first_instance: UInt32) raises -> None:
    """Draws data using bound graphics state.

    You must not call this function before binding a graphics pipeline.

    Note that the `first_vertex` and `first_instance` parameters are NOT
    compatible with built-in vertex/instance ID variables in shaders (for
    example, SV_VertexID); GPU APIs and shader languages do not define these
    built-in variables consistently, so if your shader depends on them, the
    only way to keep behavior consistent and portable is to always pass 0 for
    the correlating parameter in the draw calls.

    Args:
        render_pass: A render pass handle.
        num_vertices: The number of vertices to draw.
        num_instances: The number of instances that will be drawn.
        first_vertex: The index of the first vertex to draw.
        first_instance: The ID of the first instance to draw.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DrawGPUPrimitives.
    """

    return _get_dylib_function[lib, "SDL_DrawGPUPrimitives", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], num_vertices: UInt32, num_instances: UInt32, first_vertex: UInt32, first_instance: UInt32) -> None]()(render_pass, num_vertices, num_instances, first_vertex, first_instance)


fn draw_gpu_primitives_indirect(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], buffer: Ptr[GPUBuffer, AnyOrigin[True]], offset: UInt32, draw_count: UInt32) raises -> None:
    """Draws data using bound graphics state and with draw parameters set from a
    buffer.

    The buffer must consist of tightly-packed draw parameter sets that each
    match the layout of SDL_GPUIndirectDrawCommand. You must not call this
    function before binding a graphics pipeline.

    Args:
        render_pass: A render pass handle.
        buffer: A buffer containing draw parameters.
        offset: The offset to start reading from the draw buffer.
        draw_count: The number of draw parameter sets that should be read
                    from the draw buffer.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DrawGPUPrimitivesIndirect.
    """

    return _get_dylib_function[lib, "SDL_DrawGPUPrimitivesIndirect", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], buffer: Ptr[GPUBuffer, AnyOrigin[True]], offset: UInt32, draw_count: UInt32) -> None]()(render_pass, buffer, offset, draw_count)


fn draw_gpu_indexed_primitives_indirect(render_pass: Ptr[GPURenderPass, AnyOrigin[True]], buffer: Ptr[GPUBuffer, AnyOrigin[True]], offset: UInt32, draw_count: UInt32) raises -> None:
    """Draws data using bound graphics state with an index buffer enabled and with
    draw parameters set from a buffer.

    The buffer must consist of tightly-packed draw parameter sets that each
    match the layout of SDL_GPUIndexedIndirectDrawCommand. You must not call
    this function before binding a graphics pipeline.

    Args:
        render_pass: A render pass handle.
        buffer: A buffer containing draw parameters.
        offset: The offset to start reading from the draw buffer.
        draw_count: The number of draw parameter sets that should be read
                    from the draw buffer.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DrawGPUIndexedPrimitivesIndirect.
    """

    return _get_dylib_function[lib, "SDL_DrawGPUIndexedPrimitivesIndirect", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]], buffer: Ptr[GPUBuffer, AnyOrigin[True]], offset: UInt32, draw_count: UInt32) -> None]()(render_pass, buffer, offset, draw_count)


fn end_gpu_render_pass(render_pass: Ptr[GPURenderPass, AnyOrigin[True]]) raises -> None:
    """Ends the given render pass.

    All bound graphics state on the render pass command buffer is unset. The
    render pass handle is now invalid.

    Args:
        render_pass: A render pass handle.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EndGPURenderPass.
    """

    return _get_dylib_function[lib, "SDL_EndGPURenderPass", fn (render_pass: Ptr[GPURenderPass, AnyOrigin[True]]) -> None]()(render_pass)


fn begin_gpu_compute_pass(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], storage_texture_bindings: Ptr[GPUStorageTextureReadWriteBinding, AnyOrigin[False]], num_storage_texture_bindings: UInt32, storage_buffer_bindings: Ptr[GPUStorageBufferReadWriteBinding, AnyOrigin[False]], num_storage_buffer_bindings: UInt32) raises -> Ptr[GPUComputePass, AnyOrigin[True]]:
    """Begins a compute pass on a command buffer.

    A compute pass is defined by a set of texture subresources and buffers that
    may be written to by compute pipelines. These textures and buffers must
    have been created with the COMPUTE_STORAGE_WRITE bit or the
    COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE bit. If you do not create a texture
    with COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE, you must not read from the
    texture in the compute pass. All operations related to compute pipelines
    must take place inside of a compute pass. You must not begin another
    compute pass, or a render pass or copy pass before ending the compute pass.

    A VERY IMPORTANT NOTE - Reads and writes in compute passes are NOT
    implicitly synchronized. This means you may cause data races by both
    reading and writing a resource region in a compute pass, or by writing
    multiple times to a resource region. If your compute work depends on
    reading the completed output from a previous dispatch, you MUST end the
    current compute pass and begin a new one before you can safely access the
    data. Otherwise you will receive unexpected results. Reading and writing a
    texture in the same compute pass is only supported by specific texture
    formats. Make sure you check the format support!

    Args:
        command_buffer: A command buffer.
        storage_texture_bindings: An array of writeable storage texture
                                  binding structs.
        num_storage_texture_bindings: The number of storage textures to bind
                                      from the array.
        storage_buffer_bindings: An array of writeable storage buffer binding
                                 structs.
        num_storage_buffer_bindings: The number of storage buffers to bind
                                     from the array.

    Returns:
        A compute pass handle.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BeginGPUComputePass.
    """

    return _get_dylib_function[lib, "SDL_BeginGPUComputePass", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], storage_texture_bindings: Ptr[GPUStorageTextureReadWriteBinding, AnyOrigin[False]], num_storage_texture_bindings: UInt32, storage_buffer_bindings: Ptr[GPUStorageBufferReadWriteBinding, AnyOrigin[False]], num_storage_buffer_bindings: UInt32) -> Ptr[GPUComputePass, AnyOrigin[True]]]()(command_buffer, storage_texture_bindings, num_storage_texture_bindings, storage_buffer_bindings, num_storage_buffer_bindings)


fn bind_gpu_compute_pipeline(compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], compute_pipeline: Ptr[GPUComputePipeline, AnyOrigin[True]]) raises -> None:
    """Binds a compute pipeline on a command buffer for use in compute dispatch.

    Args:
        compute_pass: A compute pass handle.
        compute_pipeline: A compute pipeline to bind.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUComputePipeline.
    """

    return _get_dylib_function[lib, "SDL_BindGPUComputePipeline", fn (compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], compute_pipeline: Ptr[GPUComputePipeline, AnyOrigin[True]]) -> None]()(compute_pass, compute_pipeline)


fn bind_gpu_compute_samplers(compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], first_slot: UInt32, texture_sampler_bindings: Ptr[GPUTextureSamplerBinding, AnyOrigin[False]], num_bindings: UInt32) raises -> None:
    """Binds texture-sampler pairs for use on the compute shader.

    The textures must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.

    Be sure your shader is set up according to the requirements documented in
    SDL_CreateGPUShader().

    Args:
        compute_pass: A compute pass handle.
        first_slot: The compute sampler slot to begin binding from.
        texture_sampler_bindings: An array of texture-sampler binding
                                  structs.
        num_bindings: The number of texture-sampler bindings to bind from the
                      array.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUComputeSamplers.
    """

    return _get_dylib_function[lib, "SDL_BindGPUComputeSamplers", fn (compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], first_slot: UInt32, texture_sampler_bindings: Ptr[GPUTextureSamplerBinding, AnyOrigin[False]], num_bindings: UInt32) -> None]()(compute_pass, first_slot, texture_sampler_bindings, num_bindings)


fn bind_gpu_compute_storage_textures(compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], first_slot: UInt32, storage_textures: Ptr[GPUTexture, AnyOrigin[True]], num_bindings: UInt32) raises -> None:
    """Binds storage textures as readonly for use on the compute pipeline.

    These textures must have been created with
    SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ.

    Be sure your shader is set up according to the requirements documented in
    SDL_CreateGPUShader().

    Args:
        compute_pass: A compute pass handle.
        first_slot: The compute storage texture slot to begin binding from.
        storage_textures: An array of storage textures.
        num_bindings: The number of storage textures to bind from the array.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUComputeStorageTextures.
    """

    return _get_dylib_function[lib, "SDL_BindGPUComputeStorageTextures", fn (compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], first_slot: UInt32, storage_textures: Ptr[GPUTexture, AnyOrigin[True]], num_bindings: UInt32) -> None]()(compute_pass, first_slot, storage_textures, num_bindings)


fn bind_gpu_compute_storage_buffers(compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], first_slot: UInt32, storage_buffers: Ptr[GPUBuffer, AnyOrigin[True]], num_bindings: UInt32) raises -> None:
    """Binds storage buffers as readonly for use on the compute pipeline.

    These buffers must have been created with
    SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ.

    Be sure your shader is set up according to the requirements documented in
    SDL_CreateGPUShader().

    Args:
        compute_pass: A compute pass handle.
        first_slot: The compute storage buffer slot to begin binding from.
        storage_buffers: An array of storage buffer binding structs.
        num_bindings: The number of storage buffers to bind from the array.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindGPUComputeStorageBuffers.
    """

    return _get_dylib_function[lib, "SDL_BindGPUComputeStorageBuffers", fn (compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], first_slot: UInt32, storage_buffers: Ptr[GPUBuffer, AnyOrigin[True]], num_bindings: UInt32) -> None]()(compute_pass, first_slot, storage_buffers, num_bindings)


fn dispatch_gpu_compute(compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], groupcount_x: UInt32, groupcount_y: UInt32, groupcount_z: UInt32) raises -> None:
    """Dispatches compute work.

    You must not call this function before binding a compute pipeline.

    A VERY IMPORTANT NOTE If you dispatch multiple times in a compute pass, and
    the dispatches write to the same resource region as each other, there is no
    guarantee of which order the writes will occur. If the write order matters,
    you MUST end the compute pass and begin another one.

    Args:
        compute_pass: A compute pass handle.
        groupcount_x: Number of local workgroups to dispatch in the X
                      dimension.
        groupcount_y: Number of local workgroups to dispatch in the Y
                      dimension.
        groupcount_z: Number of local workgroups to dispatch in the Z
                      dimension.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DispatchGPUCompute.
    """

    return _get_dylib_function[lib, "SDL_DispatchGPUCompute", fn (compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], groupcount_x: UInt32, groupcount_y: UInt32, groupcount_z: UInt32) -> None]()(compute_pass, groupcount_x, groupcount_y, groupcount_z)


fn dispatch_gpu_compute_indirect(compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], buffer: Ptr[GPUBuffer, AnyOrigin[True]], offset: UInt32) raises -> None:
    """Dispatches compute work with parameters set from a buffer.

    The buffer layout should match the layout of
    SDL_GPUIndirectDispatchCommand. You must not call this function before
    binding a compute pipeline.

    A VERY IMPORTANT NOTE If you dispatch multiple times in a compute pass, and
    the dispatches write to the same resource region as each other, there is no
    guarantee of which order the writes will occur. If the write order matters,
    you MUST end the compute pass and begin another one.

    Args:
        compute_pass: A compute pass handle.
        buffer: A buffer containing dispatch parameters.
        offset: The offset to start reading from the dispatch buffer.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DispatchGPUComputeIndirect.
    """

    return _get_dylib_function[lib, "SDL_DispatchGPUComputeIndirect", fn (compute_pass: Ptr[GPUComputePass, AnyOrigin[True]], buffer: Ptr[GPUBuffer, AnyOrigin[True]], offset: UInt32) -> None]()(compute_pass, buffer, offset)


fn end_gpu_compute_pass(compute_pass: Ptr[GPUComputePass, AnyOrigin[True]]) raises -> None:
    """Ends the current compute pass.

    All bound compute state on the command buffer is unset. The compute pass
    handle is now invalid.

    Args:
        compute_pass: A compute pass handle.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EndGPUComputePass.
    """

    return _get_dylib_function[lib, "SDL_EndGPUComputePass", fn (compute_pass: Ptr[GPUComputePass, AnyOrigin[True]]) -> None]()(compute_pass)


fn map_gpu_transfer_buffer(device: Ptr[GPUDevice, AnyOrigin[True]], transfer_buffer: Ptr[GPUTransferBuffer, AnyOrigin[True]], cycle: Bool) raises -> Ptr[NoneType, AnyOrigin[True]]:
    """Maps a transfer buffer into application address space.

    You must unmap the transfer buffer before encoding upload commands. The
    memory is owned by the graphics driver - do NOT call SDL_free() on the
    returned pointer.

    Args:
        device: A GPU context.
        transfer_buffer: A transfer buffer.
        cycle: If true, cycles the transfer buffer if it is already bound.

    Returns:
        The address of the mapped transfer buffer memory, or NULL on
        failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_MapGPUTransferBuffer.
    """

    return _get_dylib_function[lib, "SDL_MapGPUTransferBuffer", fn (device: Ptr[GPUDevice, AnyOrigin[True]], transfer_buffer: Ptr[GPUTransferBuffer, AnyOrigin[True]], cycle: Bool) -> Ptr[NoneType, AnyOrigin[True]]]()(device, transfer_buffer, cycle)


fn unmap_gpu_transfer_buffer(device: Ptr[GPUDevice, AnyOrigin[True]], transfer_buffer: Ptr[GPUTransferBuffer, AnyOrigin[True]]) raises -> None:
    """Unmaps a previously mapped transfer buffer.

    Args:
        device: A GPU context.
        transfer_buffer: A previously mapped transfer buffer.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UnmapGPUTransferBuffer.
    """

    return _get_dylib_function[lib, "SDL_UnmapGPUTransferBuffer", fn (device: Ptr[GPUDevice, AnyOrigin[True]], transfer_buffer: Ptr[GPUTransferBuffer, AnyOrigin[True]]) -> None]()(device, transfer_buffer)


fn begin_gpu_copy_pass(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]]) raises -> Ptr[GPUCopyPass, AnyOrigin[True]]:
    """Begins a copy pass on a command buffer.

    All operations related to copying to or from buffers or textures take place
    inside a copy pass. You must not begin another copy pass, or a render pass
    or compute pass before ending the copy pass.

    Args:
        command_buffer: A command buffer.

    Returns:
        A copy pass handle.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BeginGPUCopyPass.
    """

    return _get_dylib_function[lib, "SDL_BeginGPUCopyPass", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]]) -> Ptr[GPUCopyPass, AnyOrigin[True]]]()(command_buffer)


fn upload_to_gpu_texture(copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUTextureTransferInfo, AnyOrigin[False]], destination: Ptr[GPUTextureRegion, AnyOrigin[False]], cycle: Bool) raises -> None:
    """Uploads data from a transfer buffer to a texture.

    The upload occurs on the GPU timeline. You may assume that the upload has
    finished in subsequent commands.

    You must align the data in the transfer buffer to a multiple of the texel
    size of the texture format.

    Args:
        copy_pass: A copy pass handle.
        source: The source transfer buffer with image layout information.
        destination: The destination texture region.
        cycle: If true, cycles the texture if the texture is bound, otherwise
               overwrites the data.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UploadToGPUTexture.
    """

    return _get_dylib_function[lib, "SDL_UploadToGPUTexture", fn (copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUTextureTransferInfo, AnyOrigin[False]], destination: Ptr[GPUTextureRegion, AnyOrigin[False]], cycle: Bool) -> None]()(copy_pass, source, destination, cycle)


fn upload_to_gpu_buffer(copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUTransferBufferLocation, AnyOrigin[False]], destination: Ptr[GPUBufferRegion, AnyOrigin[False]], cycle: Bool) raises -> None:
    """Uploads data from a transfer buffer to a buffer.

    The upload occurs on the GPU timeline. You may assume that the upload has
    finished in subsequent commands.

    Args:
        copy_pass: A copy pass handle.
        source: The source transfer buffer with offset.
        destination: The destination buffer with offset and size.
        cycle: If true, cycles the buffer if it is already bound, otherwise
               overwrites the data.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UploadToGPUBuffer.
    """

    return _get_dylib_function[lib, "SDL_UploadToGPUBuffer", fn (copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUTransferBufferLocation, AnyOrigin[False]], destination: Ptr[GPUBufferRegion, AnyOrigin[False]], cycle: Bool) -> None]()(copy_pass, source, destination, cycle)


fn copy_gpu_texture_to_texture(copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUTextureLocation, AnyOrigin[False]], destination: Ptr[GPUTextureLocation, AnyOrigin[False]], w: UInt32, h: UInt32, d: UInt32, cycle: Bool) raises -> None:
    """Performs a texture-to-texture copy.

    This copy occurs on the GPU timeline. You may assume the copy has finished
    in subsequent commands.

    Args:
        copy_pass: A copy pass handle.
        source: A source texture region.
        destination: A destination texture region.
        w: The width of the region to copy.
        h: The height of the region to copy.
        d: The depth of the region to copy.
        cycle: If true, cycles the destination texture if the destination
               texture is bound, otherwise overwrites the data.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CopyGPUTextureToTexture.
    """

    return _get_dylib_function[lib, "SDL_CopyGPUTextureToTexture", fn (copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUTextureLocation, AnyOrigin[False]], destination: Ptr[GPUTextureLocation, AnyOrigin[False]], w: UInt32, h: UInt32, d: UInt32, cycle: Bool) -> None]()(copy_pass, source, destination, w, h, d, cycle)


fn copy_gpu_buffer_to_buffer(copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUBufferLocation, AnyOrigin[False]], destination: Ptr[GPUBufferLocation, AnyOrigin[False]], size: UInt32, cycle: Bool) raises -> None:
    """Performs a buffer-to-buffer copy.

    This copy occurs on the GPU timeline. You may assume the copy has finished
    in subsequent commands.

    Args:
        copy_pass: A copy pass handle.
        source: The buffer and offset to copy from.
        destination: The buffer and offset to copy to.
        size: The length of the buffer to copy.
        cycle: If true, cycles the destination buffer if it is already bound,
               otherwise overwrites the data.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CopyGPUBufferToBuffer.
    """

    return _get_dylib_function[lib, "SDL_CopyGPUBufferToBuffer", fn (copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUBufferLocation, AnyOrigin[False]], destination: Ptr[GPUBufferLocation, AnyOrigin[False]], size: UInt32, cycle: Bool) -> None]()(copy_pass, source, destination, size, cycle)


fn download_from_gpu_texture(copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUTextureRegion, AnyOrigin[False]], destination: Ptr[GPUTextureTransferInfo, AnyOrigin[False]]) raises -> None:
    """Copies data from a texture to a transfer buffer on the GPU timeline.

    This data is not guaranteed to be copied until the command buffer fence is
    signaled.

    Args:
        copy_pass: A copy pass handle.
        source: The source texture region.
        destination: The destination transfer buffer with image layout
                     information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DownloadFromGPUTexture.
    """

    return _get_dylib_function[lib, "SDL_DownloadFromGPUTexture", fn (copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUTextureRegion, AnyOrigin[False]], destination: Ptr[GPUTextureTransferInfo, AnyOrigin[False]]) -> None]()(copy_pass, source, destination)


fn download_from_gpu_buffer(copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUBufferRegion, AnyOrigin[False]], destination: Ptr[GPUTransferBufferLocation, AnyOrigin[False]]) raises -> None:
    """Copies data from a buffer to a transfer buffer on the GPU timeline.

    This data is not guaranteed to be copied until the command buffer fence is
    signaled.

    Args:
        copy_pass: A copy pass handle.
        source: The source buffer with offset and size.
        destination: The destination transfer buffer with offset.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DownloadFromGPUBuffer.
    """

    return _get_dylib_function[lib, "SDL_DownloadFromGPUBuffer", fn (copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]], source: Ptr[GPUBufferRegion, AnyOrigin[False]], destination: Ptr[GPUTransferBufferLocation, AnyOrigin[False]]) -> None]()(copy_pass, source, destination)


fn end_gpu_copy_pass(copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]]) raises -> None:
    """Ends the current copy pass.

    Args:
        copy_pass: A copy pass handle.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EndGPUCopyPass.
    """

    return _get_dylib_function[lib, "SDL_EndGPUCopyPass", fn (copy_pass: Ptr[GPUCopyPass, AnyOrigin[True]]) -> None]()(copy_pass)


fn generate_mipmaps_for_gpu_texture(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], texture: Ptr[GPUTexture, AnyOrigin[True]]) raises -> None:
    """Generates mipmaps for the given texture.

    This function must not be called inside of any pass.

    Args:
        command_buffer: A command_buffer.
        texture: A texture with more than 1 mip level.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GenerateMipmapsForGPUTexture.
    """

    return _get_dylib_function[lib, "SDL_GenerateMipmapsForGPUTexture", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], texture: Ptr[GPUTexture, AnyOrigin[True]]) -> None]()(command_buffer, texture)


fn blit_gpu_texture(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], info: Ptr[GPUBlitInfo, AnyOrigin[False]]) raises -> None:
    """Blits from a source texture region to a destination texture region.

    This function must not be called inside of any pass.

    Args:
        command_buffer: A command buffer.
        info: The blit info struct containing the blit parameters.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BlitGPUTexture.
    """

    return _get_dylib_function[lib, "SDL_BlitGPUTexture", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], info: Ptr[GPUBlitInfo, AnyOrigin[False]]) -> None]()(command_buffer, info)


fn window_supports_gpu_swapchain_composition(device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]], swapchain_composition: GPUSwapchainComposition) raises -> Bool:
    """Determines whether a swapchain composition is supported by the window.

    The window must be claimed before calling this function.

    Args:
        device: A GPU context.
        window: An SDL_Window.
        swapchain_composition: The swapchain composition to check.

    Returns:
        True if supported, false if unsupported.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WindowSupportsGPUSwapchainComposition.
    """

    return _get_dylib_function[lib, "SDL_WindowSupportsGPUSwapchainComposition", fn (device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]], swapchain_composition: GPUSwapchainComposition) -> Bool]()(device, window, swapchain_composition)


fn window_supports_gpu_present_mode(device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]], present_mode: GPUPresentMode) raises -> Bool:
    """Determines whether a presentation mode is supported by the window.

    The window must be claimed before calling this function.

    Args:
        device: A GPU context.
        window: An SDL_Window.
        present_mode: The presentation mode to check.

    Returns:
        True if supported, false if unsupported.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WindowSupportsGPUPresentMode.
    """

    return _get_dylib_function[lib, "SDL_WindowSupportsGPUPresentMode", fn (device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]], present_mode: GPUPresentMode) -> Bool]()(device, window, present_mode)


fn claim_window_for_gpu_device(device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]]) raises:
    """Claims a window, creating a swapchain structure for it.

    This must be called before SDL_AcquireGPUSwapchainTexture is called using
    the window. You should only call this function from the thread that created
    the window.

    The swapchain will be created with SDL_GPU_SWAPCHAINCOMPOSITION_SDR and
    SDL_GPU_PRESENTMODE_VSYNC. If you want to have different swapchain
    parameters, you must call SDL_SetGPUSwapchainParameters after claiming the
    window.

    Args:
        device: A GPU context.
        window: An SDL_Window.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called from the thread that
        created the window.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ClaimWindowForGPUDevice.
    """

    ret = _get_dylib_function[lib, "SDL_ClaimWindowForGPUDevice", fn (device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(device, window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn release_window_from_gpu_device(device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]]) raises -> None:
    """Unclaims a window, destroying its swapchain structure.

    Args:
        device: A GPU context.
        window: An SDL_Window that has been claimed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReleaseWindowFromGPUDevice.
    """

    return _get_dylib_function[lib, "SDL_ReleaseWindowFromGPUDevice", fn (device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]]) -> None]()(device, window)


fn set_gpu_swapchain_parameters(device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]], swapchain_composition: GPUSwapchainComposition, present_mode: GPUPresentMode) raises -> Bool:
    """Changes the swapchain parameters for the given claimed window.

    This function will fail if the requested present mode or swapchain
    composition are unsupported by the device. Check if the parameters are
    supported via SDL_WindowSupportsGPUPresentMode /
    SDL_WindowSupportsGPUSwapchainComposition prior to calling this function.

    SDL_GPU_PRESENTMODE_VSYNC with SDL_GPU_SWAPCHAINCOMPOSITION_SDR are always
    supported.

    Args:
        device: A GPU context.
        window: An SDL_Window that has been claimed.
        swapchain_composition: The desired composition of the swapchain.
        present_mode: The desired present mode for the swapchain.

    Returns:
        True if successful, false on error; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGPUSwapchainParameters.
    """

    return _get_dylib_function[lib, "SDL_SetGPUSwapchainParameters", fn (device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]], swapchain_composition: GPUSwapchainComposition, present_mode: GPUPresentMode) -> Bool]()(device, window, swapchain_composition, present_mode)


fn set_gpu_allowed_frames_in_flight(device: Ptr[GPUDevice, AnyOrigin[True]], allowed_frames_in_flight: UInt32) raises -> Bool:
    """Configures the maximum allowed number of frames in flight.

    The default value when the device is created is 2. This means that after
    you have submitted 2 frames for presentation, if the GPU has not finished
    working on the first frame, SDL_AcquireGPUSwapchainTexture() will fill the
    swapchain texture pointer with NULL, and
    SDL_WaitAndAcquireGPUSwapchainTexture() will block.

    Higher values increase throughput at the expense of visual latency. Lower
    values decrease visual latency at the expense of throughput.

    Note that calling this function will stall and flush the command queue to
    prevent synchronization issues.

    The minimum value of allowed frames in flight is 1, and the maximum is 3.

    Args:
        device: A GPU context.
        allowed_frames_in_flight: The maximum number of frames that can be
                                  pending on the GPU.

    Returns:
        True if successful, false on error; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetGPUAllowedFramesInFlight.
    """

    return _get_dylib_function[lib, "SDL_SetGPUAllowedFramesInFlight", fn (device: Ptr[GPUDevice, AnyOrigin[True]], allowed_frames_in_flight: UInt32) -> Bool]()(device, allowed_frames_in_flight)


fn get_gpu_swapchain_texture_format(device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]]) raises -> GPUTextureFormat:
    """Obtains the texture format of the swapchain for the given window.

    Note that this format can change if the swapchain parameters change.

    Args:
        device: A GPU context.
        window: An SDL_Window that has been claimed.

    Returns:
        The texture format of the swapchain.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetGPUSwapchainTextureFormat.
    """

    return _get_dylib_function[lib, "SDL_GetGPUSwapchainTextureFormat", fn (device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]]) -> GPUTextureFormat]()(device, window)


fn acquire_gpu_swapchain_texture(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]], swapchain_texture: Ptr[Ptr[GPUTexture, AnyOrigin[True]], AnyOrigin[True]], swapchain_texture_width: Ptr[UInt32, AnyOrigin[True]], swapchain_texture_height: Ptr[UInt32, AnyOrigin[True]]) raises:
    """Acquire a texture to use in presentation.

    When a swapchain texture is acquired on a command buffer, it will
    automatically be submitted for presentation when the command buffer is
    submitted. The swapchain texture should only be referenced by the command
    buffer used to acquire it.

    This function will fill the swapchain texture handle with NULL if too many
    frames are in flight. This is not an error.

    If you use this function, it is possible to create a situation where many
    command buffers are allocated while the rendering context waits for the GPU
    to catch up, which will cause memory usage to grow. You should use
    SDL_WaitAndAcquireGPUSwapchainTexture() unless you know what you are doing
    with timing.

    The swapchain texture is managed by the implementation and must not be
    freed by the user. You MUST NOT call this function from any thread other
    than the one that created the window.

    Args:
        command_buffer: A command buffer.
        window: A window that has been claimed.
        swapchain_texture: A pointer filled in with a swapchain texture
                           handle.
        swapchain_texture_width: A pointer filled in with the swapchain
                                 texture width, may be NULL.
        swapchain_texture_height: A pointer filled in with the swapchain
                                  texture height, may be NULL.

    Raises:
        Raises on error; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called from the thread that
        created the window.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AcquireGPUSwapchainTexture.
    """

    ret = _get_dylib_function[lib, "SDL_AcquireGPUSwapchainTexture", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]], swapchain_texture: Ptr[Ptr[GPUTexture, AnyOrigin[True]], AnyOrigin[True]], swapchain_texture_width: Ptr[UInt32, AnyOrigin[True]], swapchain_texture_height: Ptr[UInt32, AnyOrigin[True]]) -> Bool]()(command_buffer, window, swapchain_texture, swapchain_texture_width, swapchain_texture_height)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn wait_for_gpu_swapchain(device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]]) raises:
    """Blocks the thread until a swapchain texture is available to be acquired.

    Args:
        device: A GPU context.
        window: A window that has been claimed.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called from the thread that
        created the window.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WaitForGPUSwapchain.
    """

    ret = _get_dylib_function[lib, "SDL_WaitForGPUSwapchain", fn (device: Ptr[GPUDevice, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]]) -> Bool]()(device, window)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn wait_and_acquire_gpu_swapchain_texture(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]], swapchain_texture: Ptr[Ptr[GPUTexture, AnyOrigin[True]], AnyOrigin[True]], swapchain_texture_width: Ptr[UInt32, AnyOrigin[True]], swapchain_texture_height: Ptr[UInt32, AnyOrigin[True]]) raises:
    """Blocks the thread until a swapchain texture is available to be acquired,
    and then acquires it.

    When a swapchain texture is acquired on a command buffer, it will
    automatically be submitted for presentation when the command buffer is
    submitted. The swapchain texture should only be referenced by the command
    buffer used to acquire it. It is an error to call
    SDL_CancelGPUCommandBuffer() after a swapchain texture is acquired.

    This function can fill the swapchain texture handle with NULL in certain
    cases, for example if the window is minimized. This is not an error. You
    should always make sure to check whether the pointer is NULL before
    actually using it.

    The swapchain texture is managed by the implementation and must not be
    freed by the user. You MUST NOT call this function from any thread other
    than the one that created the window.

    The swapchain texture is write-only and cannot be used as a sampler or for
    another reading operation.

    Args:
        command_buffer: A command buffer.
        window: A window that has been claimed.
        swapchain_texture: A pointer filled in with a swapchain texture
                           handle.
        swapchain_texture_width: A pointer filled in with the swapchain
                                 texture width, may be NULL.
        swapchain_texture_height: A pointer filled in with the swapchain
                                  texture height, may be NULL.

    Raises:
        Raises on error; call SDL_GetError() for more
        information.

    Safety:
        This function should only be called from the thread that
        created the window.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WaitAndAcquireGPUSwapchainTexture.
    """

    ret = _get_dylib_function[lib, "SDL_WaitAndAcquireGPUSwapchainTexture", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], window: Ptr[Window, AnyOrigin[True]], swapchain_texture: Ptr[Ptr[GPUTexture, AnyOrigin[True]], AnyOrigin[True]], swapchain_texture_width: Ptr[UInt32, AnyOrigin[True]], swapchain_texture_height: Ptr[UInt32, AnyOrigin[True]]) -> Bool]()(command_buffer, window, swapchain_texture, swapchain_texture_width, swapchain_texture_height)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn submit_gpu_command_buffer(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]]) raises:
    """Submits a command buffer so its commands can be processed on the GPU.

    It is invalid to use the command buffer after this is called.

    This must be called from the thread the command buffer was acquired on.

    All commands in the submission are guaranteed to begin executing before any
    command in a subsequent submission begins executing.

    Args:
        command_buffer: A command buffer.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SubmitGPUCommandBuffer.
    """

    ret = _get_dylib_function[lib, "SDL_SubmitGPUCommandBuffer", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]]) -> Bool]()(command_buffer)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn submit_gpu_command_buffer_and_acquire_fence(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]], out ret: Ptr[GPUFence, AnyOrigin[True]]) raises:
    """Submits a command buffer so its commands can be processed on the GPU, and
    acquires a fence associated with the command buffer.

    You must release this fence when it is no longer needed or it will cause a
    leak. It is invalid to use the command buffer after this is called.

    This must be called from the thread the command buffer was acquired on.

    All commands in the submission are guaranteed to begin executing before any
    command in a subsequent submission begins executing.

    Args:
        command_buffer: A command buffer.

    Returns:
        A fence associated with the command buffer, or NULL on failure;
        call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SubmitGPUCommandBufferAndAcquireFence.
    """

    ret = _get_dylib_function[lib, "SDL_SubmitGPUCommandBufferAndAcquireFence", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]]) -> Ptr[GPUFence, AnyOrigin[True]]]()(command_buffer)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn cancel_gpu_command_buffer(command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]]) raises:
    """Cancels a command buffer.

    None of the enqueued commands are executed.

    It is an error to call this function after a swapchain texture has been
    acquired.

    This must be called from the thread the command buffer was acquired on.

    You must not reference the command buffer after calling this function.

    Args:
        command_buffer: A command buffer.

    Raises:
        Raises on error; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CancelGPUCommandBuffer.
    """

    ret = _get_dylib_function[lib, "SDL_CancelGPUCommandBuffer", fn (command_buffer: Ptr[GPUCommandBuffer, AnyOrigin[True]]) -> Bool]()(command_buffer)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn wait_for_gpu_idle(device: Ptr[GPUDevice, AnyOrigin[True]]) raises:
    """Blocks the thread until the GPU is completely idle.

    Args:
        device: A GPU context.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WaitForGPUIdle.
    """

    ret = _get_dylib_function[lib, "SDL_WaitForGPUIdle", fn (device: Ptr[GPUDevice, AnyOrigin[True]]) -> Bool]()(device)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn wait_for_gpu_fences(device: Ptr[GPUDevice, AnyOrigin[True]], wait_all: Bool, fences: Ptr[GPUFence, AnyOrigin[True]], num_fences: UInt32) raises:
    """Blocks the thread until the given fences are signaled.

    Args:
        device: A GPU context.
        wait_all: If 0, wait for any fence to be signaled, if 1, wait for all
                  fences to be signaled.
        fences: An array of fences to wait on.
        num_fences: The number of fences in the fences array.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WaitForGPUFences.
    """

    ret = _get_dylib_function[lib, "SDL_WaitForGPUFences", fn (device: Ptr[GPUDevice, AnyOrigin[True]], wait_all: Bool, fences: Ptr[GPUFence, AnyOrigin[True]], num_fences: UInt32) -> Bool]()(device, wait_all, fences, num_fences)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn query_gpu_fence(device: Ptr[GPUDevice, AnyOrigin[True]], fence: Ptr[GPUFence, AnyOrigin[True]]) raises -> Bool:
    """Checks the status of a fence.

    Args:
        device: A GPU context.
        fence: A fence.

    Returns:
        True if the fence is signaled, false if it is not.

    Docs: https://wiki.libsdl.org/SDL3/SDL_QueryGPUFence.
    """

    return _get_dylib_function[lib, "SDL_QueryGPUFence", fn (device: Ptr[GPUDevice, AnyOrigin[True]], fence: Ptr[GPUFence, AnyOrigin[True]]) -> Bool]()(device, fence)


fn release_gpu_fence(device: Ptr[GPUDevice, AnyOrigin[True]], fence: Ptr[GPUFence, AnyOrigin[True]]) raises -> None:
    """Releases a fence obtained from SDL_SubmitGPUCommandBufferAndAcquireFence.

    You must not reference the fence after calling this function.

    Args:
        device: A GPU context.
        fence: A fence.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReleaseGPUFence.
    """

    return _get_dylib_function[lib, "SDL_ReleaseGPUFence", fn (device: Ptr[GPUDevice, AnyOrigin[True]], fence: Ptr[GPUFence, AnyOrigin[True]]) -> None]()(device, fence)


fn gpu_texture_format_texel_block_size(format: GPUTextureFormat) raises -> UInt32:
    """Obtains the texel block size for a texture format.

    Args:
        format: The texture format you want to know the texel size of.

    Returns:
        The texel block size of the texture format.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUTextureFormatTexelBlockSize.
    """

    return _get_dylib_function[lib, "SDL_GPUTextureFormatTexelBlockSize", fn (format: GPUTextureFormat) -> UInt32]()(format)


fn gpu_texture_supports_format(device: Ptr[GPUDevice, AnyOrigin[True]], format: GPUTextureFormat, type: GPUTextureType, usage: GPUTextureUsageFlags) raises -> Bool:
    """Determines whether a texture format is supported for a given type and
    usage.

    Args:
        device: A GPU context.
        format: The texture format to check.
        type: The type of texture (2D, 3D, Cube).
        usage: A bitmask of all usage scenarios to check.

    Returns:
        Whether the texture format is supported for this type and usage.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUTextureSupportsFormat.
    """

    return _get_dylib_function[lib, "SDL_GPUTextureSupportsFormat", fn (device: Ptr[GPUDevice, AnyOrigin[True]], format: GPUTextureFormat, type: GPUTextureType, usage: GPUTextureUsageFlags) -> Bool]()(device, format, type, usage)


fn gpu_texture_supports_sample_count(device: Ptr[GPUDevice, AnyOrigin[True]], format: GPUTextureFormat, sample_count: GPUSampleCount) raises -> Bool:
    """Determines if a sample count for a texture format is supported.

    Args:
        device: A GPU context.
        format: The texture format to check.
        sample_count: The sample count to check.

    Returns:
        Whether the sample count is supported for this texture format.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GPUTextureSupportsSampleCount.
    """

    return _get_dylib_function[lib, "SDL_GPUTextureSupportsSampleCount", fn (device: Ptr[GPUDevice, AnyOrigin[True]], format: GPUTextureFormat, sample_count: GPUSampleCount) -> Bool]()(device, format, sample_count)


fn calculate_gpu_texture_format_size(format: GPUTextureFormat, width: UInt32, height: UInt32, depth_or_layer_count: UInt32) raises -> UInt32:
    """Calculate the size in bytes of a texture format with dimensions.

    Args:
        format: A texture format.
        width: Width in pixels.
        height: Height in pixels.
        depth_or_layer_count: Depth for 3D textures or layer count otherwise.

    Returns:
        The size of a texture with this format and dimensions.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CalculateGPUTextureFormatSize.
    """

    return _get_dylib_function[lib, "SDL_CalculateGPUTextureFormatSize", fn (format: GPUTextureFormat, width: UInt32, height: UInt32, depth_or_layer_count: UInt32) -> UInt32]()(format, width, height, depth_or_layer_count)


fn gdk_suspend_gpu(device: Ptr[GPUDevice, AnyOrigin[True]]) raises -> None:
    """Call this to suspend GPU operation on Xbox when you receive the
    SDL_EVENT_DID_ENTER_BACKGROUND event.

    Do NOT call any SDL_GPU functions after calling this function! This must
    also be called before calling SDL_GDKSuspendComplete.

    Args:
        device: A GPU context.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GDKSuspendGPU.
    """

    return _get_dylib_function[lib, "SDL_GDKSuspendGPU", fn (device: Ptr[GPUDevice, AnyOrigin[True]]) -> None]()(device)


fn gdk_resume_gpu(device: Ptr[GPUDevice, AnyOrigin[True]]) raises -> None:
    """Call this to resume GPU operation on Xbox when you receive the
    SDL_EVENT_WILL_ENTER_FOREGROUND event.

    When resuming, this function MUST be called before calling any other
    SDL_GPU functions.

    Args:
        device: A GPU context.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GDKResumeGPU.
    """

    return _get_dylib_function[lib, "SDL_GDKResumeGPU", fn (device: Ptr[GPUDevice, AnyOrigin[True]]) -> None]()(device)
