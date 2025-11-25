# +--------------------------------------------------------------------------+ #
# | SDL3 Bindings in Mojo
# +--------------------------------------------------------------------------+ #

"""SDL3 Bindings in Mojo"""

from .sdl_audio import *
from .sdl_blendmode import *
from .sdl_camera import *
from .sdl_clipboard import *
from .sdl_error import *
from .sdl_events import *
from .sdl_filesystem import *
from .sdl_gamepad import *
from .sdl_gpu import *
from .sdl_guid import *
from .sdl_haptic import *
from .sdl_hints import *
from .sdl_init import *
from .sdl_iostream import *
from .sdl_joystick import *
from .sdl_keyboard import *
from .sdl_keycode import *
from .sdl_log import *
from .sdl_mouse import *
from .sdl_pen import *
from .sdl_pixels import *
from .sdl_power import *
from .sdl_properties import *
from .sdl_rect import *
from .sdl_render import *
from .sdl_scancode import *
from .sdl_sensor import *
from .sdl_storage import *
from .sdl_surface import *
from .sdl_time import *
from .sdl_timer import *
from .sdl_touch import *
from .sdl_version import *
from .sdl_video import *


comptime AnyOrigin[mut: Bool] = __mlir_attr[`#lit.any.origin<`, mut._mlir_value, `>: !lit.origin<`, mut._mlir_value, `>`]
comptime Ptr = stdlib.memory.UnsafePointer


from sys import CompilationTarget, is_little_endian, is_big_endian
from sys.ffi import _Global, OwnedDLHandle, _get_dylib_function, c_char, c_uchar, c_int, c_uint, c_short, c_ushort, c_long, c_long_long, c_size_t, c_ssize_t, c_float, c_double

comptime lib = _Global["SDL", _init_sdl_handle]()


fn _init_sdl_handle() -> OwnedDLHandle:
    try:

        @parameter
        if CompilationTarget.is_macos():
            return OwnedDLHandle(".pixi/envs/default/lib/libSDL3.dylib")
        elif CompilationTarget.is_linux():
            return OwnedDLHandle(".pixi/envs/default/lib/libSDL3.so")
        else:
            constrained[False, "OS is not supported"]()
            return _uninit[OwnedDLHandle]()
    except:
        print("libSDL3 not found at .pixi/envs/default/lib/")
        return _uninit[OwnedDLHandle]()


@always_inline
fn _uninit[T: AnyType](out value: T):
    """Returns uninitialized data."""
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(value))


comptime ArrayHelper[type: ImplicitlyCopyable & Movable, size: Int, origin: Origin] = Ptr[InlineArray[type, size], origin]
