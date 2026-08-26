# x--------------------------------------------------------------------------x #
# | SDL3 Bindings in Mojo
# x--------------------------------------------------------------------------x #

"""Shared declarations for the SDL3 bindings."""

from std.ffi import CStringSlice, _Global, OwnedDLHandle, c_char
from std.os.env import getenv
from std.sys import CompilationTarget

comptime Ptr = Pointer
comptime OptPtr[mut: Bool, //, type: AnyType, origin: Origin[mut=mut]] = Optional[Ptr[type, origin]]
comptime ArrayHelper[type: ImplicitlyCopyable, size: Int, origin: Origin] = Ptr[Array[type, size], origin]

comptime lib = _Global["SDL", _init_sdl_handle]()

comptime SDL_LIBRARY = "libSDL3.dylib" if CompilationTarget.is_macos() else "libSDL3.so"


def _init_sdl_handle() -> OwnedDLHandle:
    comptime assert CompilationTarget.is_macos() or CompilationTarget.is_linux(), "OS is not supported"
    var prefix = getenv("CONDA_PREFIX")
    if prefix:
        try:
            return OwnedDLHandle(prefix + "/lib/" + SDL_LIBRARY)
        except:
            pass
    try:
        return OwnedDLHandle(SDL_LIBRARY)
    except:
        print(SDL_LIBRARY, "not found in $CONDA_PREFIX/lib or on the library search path")
        return _uninit[OwnedDLHandle]()


@always_inline
def _uninit[T: AnyType](out value: T):
    """Returns uninitialized data."""
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(value))


def c_string[origin: ImmOrigin, //](ptr: Ptr[mut=False, c_char, origin]) -> String:
    """Copies a null terminated C string owned by SDL into an owned String."""
    return String(StringSpan(unsafe_from_utf8=CStringSlice(unsafe_from_ptr=ptr)))
