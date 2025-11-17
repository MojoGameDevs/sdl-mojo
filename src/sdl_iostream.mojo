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

"""IOStream

SDL provides an abstract interface for reading and writing data streams. It
offers implementations for files, memory, etc, and the app can provide
their own implementations, too.

SDL_IOStream is not related to the standard C++ iostream class, other than
both are abstract interfaces to read/write data.
"""


@register_passable("trivial")
struct IOStatus(Indexer, Intable):
    """SDL_IOStream status, set by a read or write operation.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IOStatus.
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

    comptime IO_STATUS_READY = Self(0)
    """Everything is ready (no errors and not EOF)."""
    comptime IO_STATUS_ERROR = Self(1)
    """Read or write I/O error."""
    comptime IO_STATUS_EOF = Self(2)
    """End of file."""
    comptime IO_STATUS_NOT_READY = Self(3)
    """Non blocking I/O, not ready."""
    comptime IO_STATUS_READONLY = Self(4)
    """Tried to write a read-only buffer."""
    comptime IO_STATUS_WRITEONLY = Self(5)
    """Tried to read a write-only buffer."""


@register_passable("trivial")
struct IOWhence(Indexer, Intable):
    """Possible `whence` values for SDL_IOStream seeking.

    These map to the same "whence" concept that `fseek` or `lseek` use in the
    standard C runtime.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IOWhence.
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

    comptime IO_SEEK_SET = Self(0)
    """Seek from the beginning of data."""
    comptime IO_SEEK_CUR = Self(1)
    """Seek relative to current read point."""
    comptime IO_SEEK_END = Self(2)
    """Seek relative to the end of data."""


@fieldwise_init
struct IOStreamInterface(ImplicitlyCopyable, Movable):
    """The function pointers that drive an SDL_IOStream.

    Applications can provide this struct to SDL_OpenIO() to create their own
    implementation of SDL_IOStream. This is not necessarily required, as SDL
    already offers several common types of I/O streams, via functions like
    SDL_IOFromFile() and SDL_IOFromMem().

    This structure should be initialized using SDL_INIT_INTERFACE()

    Docs: https://wiki.libsdl.org/SDL3/IOStreamInterface.
    """

    var version: UInt32
    """The version of this interface."""

    var size: fn (userdata: Ptr[NoneType, AnyOrigin[True]]) -> Int64
    """Return the number of bytes in this SDL_IOStream.
    
     \\return the total size of the data stream, or -1 on error."""

    var seek: fn (userdata: Ptr[NoneType, AnyOrigin[True]], offset: Int64, whence: IOWhence) -> Int64
    """Seek to `offset` relative to `whence`, one of stdio's whence values:
     SDL_IO_SEEK_SET, SDL_IO_SEEK_CUR, SDL_IO_SEEK_END.
    
     \\return the final offset in the data stream, or -1 on error."""

    var read: fn (userdata: Ptr[NoneType, AnyOrigin[True]], ptr: Ptr[NoneType, AnyOrigin[True]], size: c_size_t, status: Ptr[IOStatus, AnyOrigin[True]]) -> c_size_t
    """Read up to `size` bytes from the data stream to the area pointed
     at by `ptr`.
    
     On an incomplete read, you should set `*status` to a value from the
     SDL_IOStatus enum. You do not have to explicitly set this on
     a complete, successful read.
    
     \\return the number of bytes read"""

    var write: fn (userdata: Ptr[NoneType, AnyOrigin[True]], ptr: Ptr[NoneType, AnyOrigin[False]], size: c_size_t, status: Ptr[IOStatus, AnyOrigin[True]]) -> c_size_t
    """Write exactly `size` bytes from the area pointed at by `ptr`
     to data stream.
    
     On an incomplete write, you should set `*status` to a value from the
     SDL_IOStatus enum. You do not have to explicitly set this on
     a complete, successful write.
    
     \\return the number of bytes written"""

    var flush: fn (userdata: Ptr[NoneType, AnyOrigin[True]], status: Ptr[IOStatus, AnyOrigin[True]]) -> Bool
    """If the stream is buffering, make sure the data is written out.
    
     On failure, you should set `*status` to a value from the
     SDL_IOStatus enum. You do not have to explicitly set this on
     a successful flush.
    
     \\return true if successful or false on write error when flushing data."""

    var close: fn (userdata: Ptr[NoneType, AnyOrigin[True]]) -> Bool
    """Close and free any allocated resources.
    
     This does not guarantee file writes will sync to physical media; they
     can be in the system's file cache, waiting to go to disk.
    
     The SDL_IOStream is still destroyed even if this fails, so clean up anything
     even if flushing buffers, etc, returns an error.
    
     \\return true if successful or false on write error when flushing data."""


@fieldwise_init
struct IOStream(ImplicitlyCopyable, Movable):
    """The read/write operation structure.

    This operates as an opaque handle. There are several APIs to create various
    types of I/O streams, or an app can supply an SDL_IOStreamInterface to
    SDL_OpenIO() to provide their own stream implementation behind this
    struct's abstract interface.

    Docs: https://wiki.libsdl.org/SDL3/IOStream.
    """

    pass


fn io_from_file(var file: String, var mode: String) raises -> Ptr[IOStream, AnyOrigin[True]]:
    """Use this function to create a new SDL_IOStream structure for reading from
    and/or writing to a named file.

    The `mode` string is treated roughly the same as in a call to the C
    library's fopen(), even if SDL doesn't happen to use fopen() behind the
    scenes.

    Available `mode` strings:

    - "r": Open a file for reading. The file must exist.
    - "w": Create an empty file for writing. If a file with the same name
      already exists its content is erased and the file is treated as a new
      empty file.
    - "a": Append to a file. Writing operations append data at the end of the
      file. The file is created if it does not exist.
    - "r+": Open a file for update both reading and writing. The file must
      exist.
    - "w+": Create an empty file for both reading and writing. If a file with
      the same name already exists its content is erased and the file is
      treated as a new empty file.
    - "a+": Open a file for reading and appending. All writing operations are
      performed at the end of the file, protecting the previous content to be
      overwritten. You can reposition (fseek, rewind) the internal pointer to
      anywhere in the file for reading, but writing operations will move it
      back to the end of file. The file is created if it does not exist.

    **NOTE**: In order to open a file as a binary file, a "b" character has to
    be included in the `mode` string. This additional "b" character can either
    be appended at the end of the string (thus making the following compound
    modes: "rb", "wb", "ab", "r+b", "w+b", "a+b") or be inserted between the
    letter and the "+" sign for the mixed modes ("rb+", "wb+", "ab+").
    Additional characters may follow the sequence, although they should have no
    effect. For example, "t" is sometimes appended to make explicit the file is
    a text file.

    This function supports Unicode filenames, but they must be encoded in UTF-8
    format, regardless of the underlying operating system.

    In Android, SDL_IOFromFile() can be used to open content:// URIs. As a
    fallback, SDL_IOFromFile() will transparently open a matching filename in
    the app's `assets`.

    Closing the SDL_IOStream will close SDL's internal file handle.

    The following properties may be set at creation time by SDL:

    - `SDL_PROP_IOSTREAM_WINDOWS_HANDLE_POINTER`: a pointer, that can be cast
      to a win32 `HANDLE`, that this SDL_IOStream is using to access the
      filesystem. If the program isn't running on Windows, or SDL used some
      other method to access the filesystem, this property will not be set.
    - `SDL_PROP_IOSTREAM_STDIO_FILE_POINTER`: a pointer, that can be cast to a
      stdio `FILE *`, that this SDL_IOStream is using to access the filesystem.
      If SDL used some other method to access the filesystem, this property
      will not be set. PLEASE NOTE that if SDL is using a different C runtime
      than your app, trying to use this pointer will almost certainly result in
      a crash! This is mostly a problem on Windows; make sure you build SDL and
      your app with the same compiler and settings to avoid it.
    - `SDL_PROP_IOSTREAM_FILE_DESCRIPTOR_NUMBER`: a file descriptor that this
      SDL_IOStream is using to access the filesystem.
    - `SDL_PROP_IOSTREAM_ANDROID_AASSET_POINTER`: a pointer, that can be cast
      to an Android NDK `AAsset *`, that this SDL_IOStream is using to access
      the filesystem. If SDL used some other method to access the filesystem,
      this property will not be set.

    Args:
        file: A UTF-8 string representing the filename to open.
        mode: An ASCII string representing the mode to be used for opening
              the file.

    Returns:
        A pointer to the SDL_IOStream structure that is created or NULL on
        failure; call SDL_GetError() for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IOFromFile.
    """

    return _get_dylib_function[lib, "SDL_IOFromFile", fn (file: Ptr[c_char, AnyOrigin[False]], mode: Ptr[c_char, AnyOrigin[False]]) -> Ptr[IOStream, AnyOrigin[True]]]()(file.unsafe_cstr_ptr(), mode.unsafe_cstr_ptr())


fn io_from_mem(mem: Ptr[NoneType, AnyOrigin[True]], size: c_size_t, out ret: Ptr[IOStream, AnyOrigin[True]]) raises:
    """Use this function to prepare a read-write memory buffer for use with
    SDL_IOStream.

    This function sets up an SDL_IOStream struct based on a memory area of a
    certain size, for both read and write access.

    This memory buffer is not copied by the SDL_IOStream; the pointer you
    provide must remain valid until you close the stream. Closing the stream
    will not free the original buffer.

    If you need to make sure the SDL_IOStream never writes to the memory
    buffer, you should use SDL_IOFromConstMem() with a read-only buffer of
    memory instead.

    The following properties will be set at creation time by SDL:

    - `SDL_PROP_IOSTREAM_MEMORY_POINTER`: this will be the `mem` parameter that
      was passed to this function.
    - `SDL_PROP_IOSTREAM_MEMORY_SIZE_NUMBER`: this will be the `size` parameter
      that was passed to this function.

    Args:
        mem: A pointer to a buffer to feed an SDL_IOStream stream.
        size: The buffer size, in bytes.

    Returns:
        A pointer to a new SDL_IOStream structure or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IOFromMem.
    """

    ret = _get_dylib_function[lib, "SDL_IOFromMem", fn (mem: Ptr[NoneType, AnyOrigin[True]], size: c_size_t) -> Ptr[IOStream, AnyOrigin[True]]]()(mem, size)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn io_from_const_mem(mem: Ptr[NoneType, AnyOrigin[False]], size: c_size_t, out ret: Ptr[IOStream, AnyOrigin[True]]) raises:
    """Use this function to prepare a read-only memory buffer for use with
    SDL_IOStream.

    This function sets up an SDL_IOStream struct based on a memory area of a
    certain size. It assumes the memory area is not writable.

    Attempting to write to this SDL_IOStream stream will report an error
    without writing to the memory buffer.

    This memory buffer is not copied by the SDL_IOStream; the pointer you
    provide must remain valid until you close the stream. Closing the stream
    will not free the original buffer.

    If you need to write to a memory buffer, you should use SDL_IOFromMem()
    with a writable buffer of memory instead.

    The following properties will be set at creation time by SDL:

    - `SDL_PROP_IOSTREAM_MEMORY_POINTER`: this will be the `mem` parameter that
      was passed to this function.
    - `SDL_PROP_IOSTREAM_MEMORY_SIZE_NUMBER`: this will be the `size` parameter
      that was passed to this function.

    Args:
        mem: A pointer to a read-only buffer to feed an SDL_IOStream stream.
        size: The buffer size, in bytes.

    Returns:
        A pointer to a new SDL_IOStream structure or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IOFromConstMem.
    """

    ret = _get_dylib_function[lib, "SDL_IOFromConstMem", fn (mem: Ptr[NoneType, AnyOrigin[False]], size: c_size_t) -> Ptr[IOStream, AnyOrigin[True]]]()(mem, size)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn io_from_dynamic_mem(out ret: Ptr[IOStream, AnyOrigin[True]]) raises:
    """Use this function to create an SDL_IOStream that is backed by dynamically
    allocated memory.

    This supports the following properties to provide access to the memory and
    control over allocations:

    - `SDL_PROP_IOSTREAM_DYNAMIC_MEMORY_POINTER`: a pointer to the internal
      memory of the stream. This can be set to NULL to transfer ownership of
      the memory to the application, which should free the memory with
      SDL_free(). If this is done, the next operation on the stream must be
      SDL_CloseIO().
    - `SDL_PROP_IOSTREAM_DYNAMIC_CHUNKSIZE_NUMBER`: memory will be allocated in
      multiples of this size, defaulting to 1024.

    Returns:
        A pointer to a new SDL_IOStream structure or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IOFromDynamicMem.
    """

    ret = _get_dylib_function[lib, "SDL_IOFromDynamicMem", fn () -> Ptr[IOStream, AnyOrigin[True]]]()()
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn open_io(iface: Ptr[IOStreamInterface, AnyOrigin[False]], userdata: Ptr[NoneType, AnyOrigin[True]], out ret: Ptr[IOStream, AnyOrigin[True]]) raises:
    """Create a custom SDL_IOStream.

    Applications do not need to use this function unless they are providing
    their own SDL_IOStream implementation. If you just need an SDL_IOStream to
    read/write a common data source, you should use the built-in
    implementations in SDL, like SDL_IOFromFile() or SDL_IOFromMem(), etc.

    This function makes a copy of `iface` and the caller does not need to keep
    it around after this call.

    Args:
        iface: The interface that implements this SDL_IOStream, initialized
               using SDL_INIT_INTERFACE().
        userdata: The pointer that will be passed to the interface functions.

    Returns:
        A pointer to the allocated memory on success or NULL on failure;
        call SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenIO.
    """

    ret = _get_dylib_function[lib, "SDL_OpenIO", fn (iface: Ptr[IOStreamInterface, AnyOrigin[False]], userdata: Ptr[NoneType, AnyOrigin[True]]) -> Ptr[IOStream, AnyOrigin[True]]]()(iface, userdata)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn close_io(context: Ptr[IOStream, AnyOrigin[True]]) raises:
    """Close and free an allocated SDL_IOStream structure.

    SDL_CloseIO() closes and cleans up the SDL_IOStream stream. It releases any
    resources used by the stream and frees the SDL_IOStream itself. This
    returns true on success, or false if the stream failed to flush to its
    output (e.g. to disk).

    Note that if this fails to flush the stream for any reason, this function
    reports an error, but the SDL_IOStream is still invalid once this function
    returns.

    This call flushes any buffered writes to the operating system, but there
    are no guarantees that those writes have gone to physical media; they might
    be in the OS's file cache, waiting to go to disk later. If it's absolutely
    crucial that writes go to disk immediately, so they are definitely stored
    even if the power fails before the file cache would have caught up, one
    should call SDL_FlushIO() before closing. Note that flushing takes time and
    makes the system and your app operate less efficiently, so do so sparingly.

    Args:
        context: SDL_IOStream structure to close.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CloseIO.
    """

    ret = _get_dylib_function[lib, "SDL_CloseIO", fn (context: Ptr[IOStream, AnyOrigin[True]]) -> Bool]()(context)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_io_properties(context: Ptr[IOStream, AnyOrigin[True]]) raises -> PropertiesID:
    """Get the properties associated with an SDL_IOStream.

    Args:
        context: A pointer to an SDL_IOStream structure.

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetIOProperties.
    """

    return _get_dylib_function[lib, "SDL_GetIOProperties", fn (context: Ptr[IOStream, AnyOrigin[True]]) -> PropertiesID]()(context)


fn get_io_status(context: Ptr[IOStream, AnyOrigin[True]]) raises -> IOStatus:
    """Query the stream status of an SDL_IOStream.

    This information can be useful to decide if a short read or write was due
    to an error, an EOF, or a non-blocking operation that isn't yet ready to
    complete.

    An SDL_IOStream's status is only expected to change after a SDL_ReadIO or
    SDL_WriteIO call; don't expect it to change if you just call this query
    function in a tight loop.

    Args:
        context: The SDL_IOStream to query.

    Returns:
        An SDL_IOStatus enum with the current state.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetIOStatus.
    """

    return _get_dylib_function[lib, "SDL_GetIOStatus", fn (context: Ptr[IOStream, AnyOrigin[True]]) -> IOStatus]()(context)


fn get_io_size(context: Ptr[IOStream, AnyOrigin[True]]) raises -> Int64:
    """Use this function to get the size of the data stream in an SDL_IOStream.

    Args:
        context: The SDL_IOStream to get the size of the data stream from.

    Returns:
        The size of the data stream in the SDL_IOStream on success or a
        negative error code on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetIOSize.
    """

    return _get_dylib_function[lib, "SDL_GetIOSize", fn (context: Ptr[IOStream, AnyOrigin[True]]) -> Int64]()(context)


fn seek_io(context: Ptr[IOStream, AnyOrigin[True]], offset: Int64, whence: IOWhence) raises -> Int64:
    """Seek within an SDL_IOStream data stream.

    This function seeks to byte `offset`, relative to `whence`.

    `whence` may be any of the following values:

    - `SDL_IO_SEEK_SET`: seek from the beginning of data
    - `SDL_IO_SEEK_CUR`: seek relative to current read point
    - `SDL_IO_SEEK_END`: seek relative to the end of data

    If this stream can not seek, it will return -1.

    Args:
        context: A pointer to an SDL_IOStream structure.
        offset: An offset in bytes, relative to `whence` location; can be
                negative.
        whence: Any of `SDL_IO_SEEK_SET`, `SDL_IO_SEEK_CUR`,
                `SDL_IO_SEEK_END`.

    Returns:
        The final offset in the data stream after the seek or -1 on
        failure; call SDL_GetError() for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SeekIO.
    """

    return _get_dylib_function[lib, "SDL_SeekIO", fn (context: Ptr[IOStream, AnyOrigin[True]], offset: Int64, whence: IOWhence) -> Int64]()(context, offset, whence)


fn tell_io(context: Ptr[IOStream, AnyOrigin[True]]) raises -> Int64:
    """Determine the current read/write offset in an SDL_IOStream data stream.

    SDL_TellIO is actually a wrapper function that calls the SDL_IOStream's
    `seek` method, with an offset of 0 bytes from `SDL_IO_SEEK_CUR`, to
    simplify application development.

    Args:
        context: An SDL_IOStream data stream object from which to get the
                 current offset.

    Returns:
        The current offset in the stream, or -1 if the information can not
        be determined.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_TellIO.
    """

    return _get_dylib_function[lib, "SDL_TellIO", fn (context: Ptr[IOStream, AnyOrigin[True]]) -> Int64]()(context)


fn read_io(context: Ptr[IOStream, AnyOrigin[True]], ptr: Ptr[NoneType, AnyOrigin[True]], size: c_size_t) raises -> c_size_t:
    """Read from a data source.

    This function reads up `size` bytes from the data source to the area
    pointed at by `ptr`. This function may read less bytes than requested.

    This function will return zero when the data stream is completely read, and
    SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If zero is returned and
    the stream is not at EOF, SDL_GetIOStatus() will return a different error
    value and SDL_GetError() will offer a human-readable message.

    Args:
        context: A pointer to an SDL_IOStream structure.
        ptr: A pointer to a buffer to read data into.
        size: The number of bytes to read from the data source.

    Returns:
        The number of bytes read, or 0 on end of file or other failure;
        call SDL_GetError() for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadIO.
    """

    return _get_dylib_function[lib, "SDL_ReadIO", fn (context: Ptr[IOStream, AnyOrigin[True]], ptr: Ptr[NoneType, AnyOrigin[True]], size: c_size_t) -> c_size_t]()(context, ptr, size)


fn write_io(context: Ptr[IOStream, AnyOrigin[True]], ptr: Ptr[NoneType, AnyOrigin[False]], size: c_size_t) raises -> c_size_t:
    """Write to an SDL_IOStream data stream.

    This function writes exactly `size` bytes from the area pointed at by `ptr`
    to the stream. If this fails for any reason, it'll return less than `size`
    to demonstrate how far the write progressed. On success, it returns `size`.

    On error, this function still attempts to write as much as possible, so it
    might return a positive value less than the requested write size.

    The caller can use SDL_GetIOStatus() to determine if the problem is
    recoverable, such as a non-blocking write that can simply be retried later,
    or a fatal error.

    Args:
        context: A pointer to an SDL_IOStream structure.
        ptr: A pointer to a buffer containing data to write.
        size: The number of bytes to write.

    Returns:
        The number of bytes written, which will be less than `size` on
        failure; call SDL_GetError() for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteIO.
    """

    return _get_dylib_function[lib, "SDL_WriteIO", fn (context: Ptr[IOStream, AnyOrigin[True]], ptr: Ptr[NoneType, AnyOrigin[False]], size: c_size_t) -> c_size_t]()(context, ptr, size)


fn flush_io(context: Ptr[IOStream, AnyOrigin[True]]) raises:
    """Flush any buffered data in the stream.

    This function makes sure that any buffered data is written to the stream.
    Normally this isn't necessary but if the stream is a pipe or socket it
    guarantees that any pending data is sent.

    Args:
        context: SDL_IOStream structure to flush.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FlushIO.
    """

    ret = _get_dylib_function[lib, "SDL_FlushIO", fn (context: Ptr[IOStream, AnyOrigin[True]]) -> Bool]()(context)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn load_file_io(src: Ptr[IOStream, AnyOrigin[True]], datasize: Ptr[c_size_t, AnyOrigin[True]], closeio: Bool, out ret: Ptr[NoneType, AnyOrigin[True]]) raises:
    """Load all the data from an SDL data stream.

    The data is allocated with a zero byte at the end (null terminated) for
    convenience. This extra byte is not included in the value reported via
    `datasize`.

    The data should be freed with SDL_free().

    Args:
        src: The SDL_IOStream to read all available data from.
        datasize: A pointer filled in with the number of bytes read, may be
                  NULL.
        closeio: If true, calls SDL_CloseIO() on `src` before returning, even
                 in the case of an error.

    Returns:
        The data or NULL on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LoadFile_IO.
    """

    ret = _get_dylib_function[lib, "SDL_LoadFile_IO", fn (src: Ptr[IOStream, AnyOrigin[True]], datasize: Ptr[c_size_t, AnyOrigin[True]], closeio: Bool) -> Ptr[NoneType, AnyOrigin[True]]]()(src, datasize, closeio)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn load_file(var file: String, datasize: Ptr[c_size_t, AnyOrigin[True]], out ret: Ptr[NoneType, AnyOrigin[True]]) raises:
    """Load all the data from a file path.

    The data is allocated with a zero byte at the end (null terminated) for
    convenience. This extra byte is not included in the value reported via
    `datasize`.

    The data should be freed with SDL_free().

    Args:
        file: The path to read all available data from.
        datasize: If not NULL, will store the number of bytes read.

    Returns:
        The data or NULL on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LoadFile.
    """

    ret = _get_dylib_function[lib, "SDL_LoadFile", fn (file: Ptr[c_char, AnyOrigin[False]], datasize: Ptr[c_size_t, AnyOrigin[True]]) -> Ptr[NoneType, AnyOrigin[True]]]()(file.unsafe_cstr_ptr(), datasize)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn save_file_io(src: Ptr[IOStream, AnyOrigin[True]], data: Ptr[NoneType, AnyOrigin[False]], datasize: c_size_t, closeio: Bool) raises:
    """Save all the data into an SDL data stream.

    Args:
        src: The SDL_IOStream to write all data to.
        data: The data to be written. If datasize is 0, may be NULL or a
              invalid pointer.
        datasize: The number of bytes to be written.
        closeio: If true, calls SDL_CloseIO() on `src` before returning, even
                 in the case of an error.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SaveFile_IO.
    """

    ret = _get_dylib_function[lib, "SDL_SaveFile_IO", fn (src: Ptr[IOStream, AnyOrigin[True]], data: Ptr[NoneType, AnyOrigin[False]], datasize: c_size_t, closeio: Bool) -> Bool]()(src, data, datasize, closeio)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn save_file(var file: String, data: Ptr[NoneType, AnyOrigin[False]], datasize: c_size_t) raises:
    """Save all the data into a file path.

    Args:
        file: The path to write all available data into.
        data: The data to be written. If datasize is 0, may be NULL or a
              invalid pointer.
        datasize: The number of bytes to be written.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SaveFile.
    """

    ret = _get_dylib_function[lib, "SDL_SaveFile", fn (file: Ptr[c_char, AnyOrigin[False]], data: Ptr[NoneType, AnyOrigin[False]], datasize: c_size_t) -> Bool]()(file.unsafe_cstr_ptr(), data, datasize)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_u8(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt8, AnyOrigin[True]]) raises:
    """Use this function to read a byte from an SDL_IOStream.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The SDL_IOStream to read from.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure or EOF; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadU8.
    """

    ret = _get_dylib_function[lib, "SDL_ReadU8", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt8, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_s8(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int8, AnyOrigin[True]]) raises:
    """Use this function to read a signed byte from an SDL_IOStream.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The SDL_IOStream to read from.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadS8.
    """

    ret = _get_dylib_function[lib, "SDL_ReadS8", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int8, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_u16_le(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt16, AnyOrigin[True]]) raises:
    """Use this function to read 16 bits of little-endian data from an
    SDL_IOStream and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadU16LE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadU16LE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt16, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_s16_le(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int16, AnyOrigin[True]]) raises:
    """Use this function to read 16 bits of little-endian data from an
    SDL_IOStream and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadS16LE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadS16LE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int16, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_u16_be(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt16, AnyOrigin[True]]) raises:
    """Use this function to read 16 bits of big-endian data from an SDL_IOStream
    and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadU16BE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadU16BE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt16, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_s16_be(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int16, AnyOrigin[True]]) raises:
    """Use this function to read 16 bits of big-endian data from an SDL_IOStream
    and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadS16BE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadS16BE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int16, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_u32_le(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt32, AnyOrigin[True]]) raises:
    """Use this function to read 32 bits of little-endian data from an
    SDL_IOStream and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadU32LE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadU32LE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt32, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_s32_le(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int32, AnyOrigin[True]]) raises:
    """Use this function to read 32 bits of little-endian data from an
    SDL_IOStream and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadS32LE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadS32LE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int32, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_u32_be(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt32, AnyOrigin[True]]) raises:
    """Use this function to read 32 bits of big-endian data from an SDL_IOStream
    and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadU32BE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadU32BE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt32, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_s32_be(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int32, AnyOrigin[True]]) raises:
    """Use this function to read 32 bits of big-endian data from an SDL_IOStream
    and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadS32BE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadS32BE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int32, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_u64_le(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt64, AnyOrigin[True]]) raises:
    """Use this function to read 64 bits of little-endian data from an
    SDL_IOStream and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadU64LE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadU64LE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt64, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_s64_le(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int64, AnyOrigin[True]]) raises:
    """Use this function to read 64 bits of little-endian data from an
    SDL_IOStream and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadS64LE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadS64LE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int64, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_u64_be(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt64, AnyOrigin[True]]) raises:
    """Use this function to read 64 bits of big-endian data from an SDL_IOStream
    and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadU64BE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadU64BE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[UInt64, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn read_s64_be(src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int64, AnyOrigin[True]]) raises:
    """Use this function to read 64 bits of big-endian data from an SDL_IOStream
    and return in native format.

    SDL byteswaps the data only if necessary, so the data returned will be in
    the native byte order.

    This function will return false when the data stream is completely read,
    and SDL_GetIOStatus() will return SDL_IO_STATUS_EOF. If false is returned
    and the stream is not at EOF, SDL_GetIOStatus() will return a different
    error value and SDL_GetError() will offer a human-readable message.

    Args:
        src: The stream from which to read data.
        value: A pointer filled in with the data read.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadS64BE.
    """

    ret = _get_dylib_function[lib, "SDL_ReadS64BE", fn (src: Ptr[IOStream, AnyOrigin[True]], value: Ptr[Int64, AnyOrigin[True]]) -> Bool]()(src, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_u8(dst: Ptr[IOStream, AnyOrigin[True]], value: UInt8) raises:
    """Use this function to write a byte to an SDL_IOStream.

    Args:
        dst: The SDL_IOStream to write to.
        value: The byte value to write.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteU8.
    """

    ret = _get_dylib_function[lib, "SDL_WriteU8", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: UInt8) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_s8(dst: Ptr[IOStream, AnyOrigin[True]], value: Int8) raises:
    """Use this function to write a signed byte to an SDL_IOStream.

    Args:
        dst: The SDL_IOStream to write to.
        value: The byte value to write.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteS8.
    """

    ret = _get_dylib_function[lib, "SDL_WriteS8", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: Int8) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_u16_le(dst: Ptr[IOStream, AnyOrigin[True]], value: UInt16) raises:
    """Use this function to write 16 bits in native format to an SDL_IOStream as
    little-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in little-endian
    format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteU16LE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteU16LE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: UInt16) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_s16_le(dst: Ptr[IOStream, AnyOrigin[True]], value: Int16) raises:
    """Use this function to write 16 bits in native format to an SDL_IOStream as
    little-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in little-endian
    format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteS16LE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteS16LE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: Int16) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_u16_be(dst: Ptr[IOStream, AnyOrigin[True]], value: UInt16) raises:
    """Use this function to write 16 bits in native format to an SDL_IOStream as
    big-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in big-endian format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteU16BE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteU16BE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: UInt16) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_s16_be(dst: Ptr[IOStream, AnyOrigin[True]], value: Int16) raises:
    """Use this function to write 16 bits in native format to an SDL_IOStream as
    big-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in big-endian format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteS16BE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteS16BE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: Int16) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_u32_le(dst: Ptr[IOStream, AnyOrigin[True]], value: UInt32) raises:
    """Use this function to write 32 bits in native format to an SDL_IOStream as
    little-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in little-endian
    format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteU32LE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteU32LE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: UInt32) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_s32_le(dst: Ptr[IOStream, AnyOrigin[True]], value: Int32) raises:
    """Use this function to write 32 bits in native format to an SDL_IOStream as
    little-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in little-endian
    format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteS32LE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteS32LE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: Int32) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_u32_be(dst: Ptr[IOStream, AnyOrigin[True]], value: UInt32) raises:
    """Use this function to write 32 bits in native format to an SDL_IOStream as
    big-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in big-endian format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteU32BE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteU32BE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: UInt32) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_s32_be(dst: Ptr[IOStream, AnyOrigin[True]], value: Int32) raises:
    """Use this function to write 32 bits in native format to an SDL_IOStream as
    big-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in big-endian format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteS32BE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteS32BE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: Int32) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_u64_le(dst: Ptr[IOStream, AnyOrigin[True]], value: UInt64) raises:
    """Use this function to write 64 bits in native format to an SDL_IOStream as
    little-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in little-endian
    format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteU64LE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteU64LE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: UInt64) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_s64_le(dst: Ptr[IOStream, AnyOrigin[True]], value: Int64) raises:
    """Use this function to write 64 bits in native format to an SDL_IOStream as
    little-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in little-endian
    format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteS64LE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteS64LE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: Int64) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_u64_be(dst: Ptr[IOStream, AnyOrigin[True]], value: UInt64) raises:
    """Use this function to write 64 bits in native format to an SDL_IOStream as
    big-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in big-endian format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteU64BE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteU64BE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: UInt64) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn write_s64_be(dst: Ptr[IOStream, AnyOrigin[True]], value: Int64) raises:
    """Use this function to write 64 bits in native format to an SDL_IOStream as
    big-endian data.

    SDL byteswaps the data only if necessary, so the application always
    specifies native format, and the data written will be in big-endian format.

    Args:
        dst: The stream to which data will be written.
        value: The data to be written, in native format.

    Raises:
        Raises on failure; call SDL_GetError()
        for more information.

    Safety:
        This function is not thread safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteS64BE.
    """

    ret = _get_dylib_function[lib, "SDL_WriteS64BE", fn (dst: Ptr[IOStream, AnyOrigin[True]], value: Int64) -> Bool]()(dst, value)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))
