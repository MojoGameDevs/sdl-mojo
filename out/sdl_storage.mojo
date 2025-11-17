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

"""Storage

The storage API is a high-level API designed to abstract away the
portability issues that come up when using something lower-level (in SDL's
case, this sits on top of the [Filesystem](CategoryFilesystem) and
[IOStream](CategoryIOStream) subsystems). It is significantly more
restrictive than a typical filesystem API, for a number of reasons:

1. **What to Access:** A common pitfall with existing filesystem APIs is
the assumption that all storage is monolithic. However, many other
platforms (game consoles in particular) are more strict about what _type_
of filesystem is being accessed; for example, game content and user data
are usually two separate storage devices with entirely different
characteristics (and possibly different low-level APIs altogether!).

2. **How to Access:** Another common mistake is applications assuming that
all storage is universally writeable - again, many platforms treat game
content and user data as two separate storage devices, and only user data
is writeable while game content is read-only.

3. **When to Access:** The most common portability issue with filesystem
access is _timing_ - you cannot always assume that the storage device is
always accessible all of the time, nor can you assume that there are no
limits to how long you have access to a particular device.

Consider the following example:

```c
void ReadGameData(void)
{
    extern char** fileNames;
    extern size_t numFiles;
    for (size_t i = 0; i < numFiles; i += 1) {
        FILE *data = fopen(fileNames[i], "rwb");
        if (data == NULL) {
            // Something bad happened!
        } else {
            // A bunch of stuff happens here
            fclose(data);
        }
    }
}

void ReadSave(void)
{
    FILE *save = fopen("saves/save0.sav", "rb");
    if (save == NULL) {
        // Something bad happened!
    } else {
        // A bunch of stuff happens here
        fclose(save);
    }
}

void WriteSave(void)
{
    FILE *save = fopen("saves/save0.sav", "wb");
    if (save == NULL) {
        // Something bad happened!
    } else {
        // A bunch of stuff happens here
        fclose(save);
    }
}
```

Going over the bullet points again:

1. **What to Access:** This code accesses a global filesystem; game data
and saves are all presumed to be in the current working directory (which
may or may not be the game's installation folder!).

2. **How to Access:** This code assumes that content paths are writeable,
and that save data is also writeable despite being in the same location as
the game data.

3. **When to Access:** This code assumes that they can be called at any
time, since the filesystem is always accessible and has no limits on how
long the filesystem is being accessed.

Due to these assumptions, the filesystem code is not portable and will fail
under these common scenarios:

- The game is installed on a device that is read-only, both content loading
  and game saves will fail or crash outright
- Game/User storage is not implicitly mounted, so no files will be found
  for either scenario when a platform requires explicitly mounting
  filesystems
- Save data may not be safe since the I/O is not being flushed or
  validated, so an error occurring elsewhere in the program may result in
  missing/corrupted save data

When using SDL_Storage, these types of problems are virtually impossible to
trip over:

```c
void ReadGameData(void)
{
    extern char** fileNames;
    extern size_t numFiles;

    SDL_Storage *title = SDL_OpenTitleStorage(NULL, 0);
    if (title == NULL) {
        // Something bad happened!
    }
    while (!SDL_StorageReady(title)) {
        SDL_Delay(1);
    }

    for (size_t i = 0; i < numFiles; i += 1) {
        void* dst;
        Uint64 dstLen = 0;

        if (SDL_GetStorageFileSize(title, fileNames[i], &dstLen) && dstLen > 0) {
            dst = SDL_malloc(dstLen);
            if (SDL_ReadStorageFile(title, fileNames[i], dst, dstLen)) {
                // A bunch of stuff happens here
            } else {
                // Something bad happened!
            }
            SDL_free(dst);
        } else {
            // Something bad happened!
        }
    }

    SDL_CloseStorage(title);
}

void ReadSave(void)
{
    SDL_Storage *user = SDL_OpenUserStorage("libsdl", "Storage Example", 0);
    if (user == NULL) {
        // Something bad happened!
    }
    while (!SDL_StorageReady(user)) {
        SDL_Delay(1);
    }

    Uint64 saveLen = 0;
    if (SDL_GetStorageFileSize(user, "save0.sav", &saveLen) && saveLen > 0) {
        void* dst = SDL_malloc(saveLen);
        if (SDL_ReadStorageFile(user, "save0.sav", dst, saveLen)) {
            // A bunch of stuff happens here
        } else {
            // Something bad happened!
        }
        SDL_free(dst);
    } else {
        // Something bad happened!
    }

    SDL_CloseStorage(user);
}

void WriteSave(void)
{
    SDL_Storage *user = SDL_OpenUserStorage("libsdl", "Storage Example", 0);
    if (user == NULL) {
        // Something bad happened!
    }
    while (!SDL_StorageReady(user)) {
        SDL_Delay(1);
    }

    extern void *saveData; // A bunch of stuff happened here...
    extern Uint64 saveLen;
    if (!SDL_WriteStorageFile(user, "save0.sav", saveData, saveLen)) {
        // Something bad happened!
    }

    SDL_CloseStorage(user);
}
```

Note the improvements that SDL_Storage makes:

1. **What to Access:** This code explicitly reads from a title or user
storage device based on the context of the function.

2. **How to Access:** This code explicitly uses either a read or write
function based on the context of the function.

3. **When to Access:** This code explicitly opens the device when it needs
to, and closes it when it is finished working with the filesystem.

The result is an application that is significantly more robust against the
increasing demands of platforms and their filesystems!

A publicly available example of an SDL_Storage backend is the
[Steam Cloud](https://partner.steamgames.com/doc/features/cloud)
backend - you can initialize Steamworks when starting the program, and then
SDL will recognize that Steamworks is initialized and automatically use
ISteamRemoteStorage when the application opens user storage. More
importantly, when you _open_ storage it knows to begin a "batch" of
filesystem operations, and when you _close_ storage it knows to end and
flush the batch. This is used by Steam to support
[Dynamic Cloud Sync](https://steamcommunity.com/groups/steamworks/announcements/detail/3142949576401813670)
; users can save data on one PC, put the device to sleep, and then continue
playing on another PC (and vice versa) with the save data fully
synchronized across all devices, allowing for a seamless experience without
having to do full restarts of the program.

## Notes on valid paths

All paths in the Storage API use Unix-style path separators ('/'). Using a
different path separator will not work, even if the underlying platform
would otherwise accept it. This is to keep code using the Storage API
portable between platforms and Storage implementations and simplify app
code.

Paths with relative directories ("." and "..") are forbidden by the Storage
API.

All valid UTF-8 strings (discounting the NULL terminator character and the
'/' path separator) are usable for filenames, however, an underlying
Storage implementation may not support particularly strange sequences and
refuse to create files with those names, etc.
"""


@fieldwise_init
struct StorageInterface(ImplicitlyCopyable, Movable):
    """Function interface for SDL_Storage.

    Apps that want to supply a custom implementation of SDL_Storage will fill
    in all the functions in this struct, and then pass it to SDL_OpenStorage to
    create a custom SDL_Storage object.

    It is not usually necessary to do this; SDL provides standard
    implementations for many things you might expect to do with an SDL_Storage.

    This structure should be initialized using SDL_INIT_INTERFACE()

    Docs: https://wiki.libsdl.org/SDL3/StorageInterface.
    """

    var version: UInt32
    """The version of this interface."""

    var close: fn (userdata: Ptr[NoneType, AnyOrigin[True]]) -> Bool
    """Called when the storage is closed."""

    var ready: fn (userdata: Ptr[NoneType, AnyOrigin[True]]) -> Bool
    """Optional, returns whether the storage is currently ready for access."""

    var enumerate: fn (userdata: Ptr[NoneType, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]], callback: EnumerateDirectoryCallback, callback_userdata: Ptr[NoneType, AnyOrigin[True]]) -> Bool
    """Enumerate a directory, optional for write-only storage."""

    var info: fn (userdata: Ptr[NoneType, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]], info: Ptr[PathInfo, AnyOrigin[True]]) -> Bool
    """Get path information, optional for write-only storage."""

    var read_file: fn (userdata: Ptr[NoneType, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]], destination: Ptr[NoneType, AnyOrigin[True]], length: UInt64) -> Bool
    """Read a file from storage, optional for write-only storage."""

    var write_file: fn (userdata: Ptr[NoneType, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]], source: Ptr[NoneType, AnyOrigin[False]], length: UInt64) -> Bool
    """Write a file to storage, optional for read-only storage."""

    var mkdir: fn (userdata: Ptr[NoneType, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]]) -> Bool
    """Create a directory, optional for read-only storage."""

    var remove: fn (userdata: Ptr[NoneType, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]]) -> Bool
    """Remove a file or empty directory, optional for read-only storage."""

    var rename: fn (userdata: Ptr[NoneType, AnyOrigin[True]], oldpath: Ptr[c_char, AnyOrigin[False]], newpath: Ptr[c_char, AnyOrigin[False]]) -> Bool
    """Rename a path, optional for read-only storage."""

    var copy_file: fn (userdata: Ptr[NoneType, AnyOrigin[True]], oldpath: Ptr[c_char, AnyOrigin[False]], newpath: Ptr[c_char, AnyOrigin[False]]) -> Bool
    """Copy a file, optional for read-only storage."""

    var space_remaining: fn (userdata: Ptr[NoneType, AnyOrigin[True]]) -> UInt64
    """Get the space remaining, optional for read-only storage."""


@fieldwise_init
struct Storage(ImplicitlyCopyable, Movable):
    """An abstract interface for filesystem access.

    This is an opaque datatype. One can create this object using standard SDL
    functions like SDL_OpenTitleStorage or SDL_OpenUserStorage, etc, or create
    an object with a custom implementation using SDL_OpenStorage.

    Docs: https://wiki.libsdl.org/SDL3/Storage.
    """

    pass


fn open_title_storage(var override: String, props: PropertiesID, out ret: Ptr[Storage, AnyOrigin[True]]) raises:
    """Opens up a read-only container for the application's filesystem.

    Args:
        override: A path to override the backend's default title root.
        props: A property list that may contain backend-specific information.

    Returns:
        A title storage container on success or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenTitleStorage.
    """

    ret = _get_dylib_function[lib, "SDL_OpenTitleStorage", fn (override: Ptr[c_char, AnyOrigin[False]], props: PropertiesID) -> Ptr[Storage, AnyOrigin[True]]]()(override.unsafe_cstr_ptr(), props)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn open_user_storage(var org: String, var app: String, props: PropertiesID, out ret: Ptr[Storage, AnyOrigin[True]]) raises:
    """Opens up a container for a user's unique read/write filesystem.

    While title storage can generally be kept open throughout runtime, user
    storage should only be opened when the client is ready to read/write files.
    This allows the backend to properly batch file operations and flush them
    when the container has been closed; ensuring safe and optimal save I/O.

    Args:
        org: The name of your organization.
        app: The name of your application.
        props: A property list that may contain backend-specific information.

    Returns:
        A user storage container on success or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenUserStorage.
    """

    ret = _get_dylib_function[lib, "SDL_OpenUserStorage", fn (org: Ptr[c_char, AnyOrigin[False]], app: Ptr[c_char, AnyOrigin[False]], props: PropertiesID) -> Ptr[Storage, AnyOrigin[True]]]()(org.unsafe_cstr_ptr(), app.unsafe_cstr_ptr(), props)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn open_file_storage(var path: String, out ret: Ptr[Storage, AnyOrigin[True]]) raises:
    """Opens up a container for local filesystem storage.

    This is provided for development and tools. Portable applications should
    use SDL_OpenTitleStorage() for access to game data and
    SDL_OpenUserStorage() for access to user data.

    Args:
        path: The base path prepended to all storage paths, or NULL for no
              base path.

    Returns:
        A filesystem storage container on success or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenFileStorage.
    """

    ret = _get_dylib_function[lib, "SDL_OpenFileStorage", fn (path: Ptr[c_char, AnyOrigin[False]]) -> Ptr[Storage, AnyOrigin[True]]]()(path.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn open_storage(iface: Ptr[StorageInterface, AnyOrigin[False]], userdata: Ptr[NoneType, AnyOrigin[True]], out ret: Ptr[Storage, AnyOrigin[True]]) raises:
    """Opens up a container using a client-provided storage interface.

    Applications do not need to use this function unless they are providing
    their own SDL_Storage implementation. If you just need an SDL_Storage, you
    should use the built-in implementations in SDL, like SDL_OpenTitleStorage()
    or SDL_OpenUserStorage().

    This function makes a copy of `iface` and the caller does not need to keep
    it around after this call.

    Args:
        iface: The interface that implements this storage, initialized using
               SDL_INIT_INTERFACE().
        userdata: The pointer that will be passed to the interface functions.

    Returns:
        A storage container on success or NULL on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenStorage.
    """

    ret = _get_dylib_function[lib, "SDL_OpenStorage", fn (iface: Ptr[StorageInterface, AnyOrigin[False]], userdata: Ptr[NoneType, AnyOrigin[True]]) -> Ptr[Storage, AnyOrigin[True]]]()(iface, userdata)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn close_storage(storage: Ptr[Storage, AnyOrigin[True]]) raises -> Bool:
    """Closes and frees a storage container.

    Args:
        storage: A storage container to close.

    Returns:
        True if the container was freed with no errors, false otherwise;
        call SDL_GetError() for more information. Even if the function
        returns an error, the container data will be freed; the error is
        only for informational purposes.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CloseStorage.
    """

    return _get_dylib_function[lib, "SDL_CloseStorage", fn (storage: Ptr[Storage, AnyOrigin[True]]) -> Bool]()(storage)


fn storage_ready(storage: Ptr[Storage, AnyOrigin[True]]) raises -> Bool:
    """Checks if the storage container is ready to use.

    This function should be called in regular intervals until it returns true -
    however, it is not recommended to spinwait on this call, as the backend may
    depend on a synchronous message loop. You might instead poll this in your
    game's main loop while processing events and drawing a loading screen.

    Args:
        storage: A storage container to query.

    Returns:
        True if the container is ready, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_StorageReady.
    """

    return _get_dylib_function[lib, "SDL_StorageReady", fn (storage: Ptr[Storage, AnyOrigin[True]]) -> Bool]()(storage)


fn get_storage_file_size(storage: Ptr[Storage, AnyOrigin[True]], var path: String, length: Ptr[UInt64, AnyOrigin[True]]) raises -> Bool:
    """Query the size of a file within a storage container.

    Args:
        storage: A storage container to query.
        path: The relative path of the file to query.
        length: A pointer to be filled with the file's length.

    Returns:
        True if the file could be queried or false on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetStorageFileSize.
    """

    return _get_dylib_function[lib, "SDL_GetStorageFileSize", fn (storage: Ptr[Storage, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]], length: Ptr[UInt64, AnyOrigin[True]]) -> Bool]()(storage, path.unsafe_cstr_ptr(), length)


fn read_storage_file(storage: Ptr[Storage, AnyOrigin[True]], var path: String, destination: Ptr[NoneType, AnyOrigin[True]], length: UInt64) raises -> Bool:
    """Synchronously read a file from a storage container into a client-provided
    buffer.

    The value of `length` must match the length of the file exactly; call
    SDL_GetStorageFileSize() to get this value. This behavior may be relaxed in
    a future release.

    Args:
        storage: A storage container to read from.
        path: The relative path of the file to read.
        destination: A client-provided buffer to read the file into.
        length: The length of the destination buffer.

    Returns:
        True if the file was read or false on failure; call SDL_GetError()
        for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ReadStorageFile.
    """

    return _get_dylib_function[lib, "SDL_ReadStorageFile", fn (storage: Ptr[Storage, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]], destination: Ptr[NoneType, AnyOrigin[True]], length: UInt64) -> Bool]()(storage, path.unsafe_cstr_ptr(), destination, length)


fn write_storage_file(storage: Ptr[Storage, AnyOrigin[True]], var path: String, source: Ptr[NoneType, AnyOrigin[False]], length: UInt64) raises -> Bool:
    """Synchronously write a file from client memory into a storage container.

    Args:
        storage: A storage container to write to.
        path: The relative path of the file to write.
        source: A client-provided buffer to write from.
        length: The length of the source buffer.

    Returns:
        True if the file was written or false on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_WriteStorageFile.
    """

    return _get_dylib_function[lib, "SDL_WriteStorageFile", fn (storage: Ptr[Storage, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]], source: Ptr[NoneType, AnyOrigin[False]], length: UInt64) -> Bool]()(storage, path.unsafe_cstr_ptr(), source, length)


fn create_storage_directory(storage: Ptr[Storage, AnyOrigin[True]], var path: String) raises:
    """Create a directory in a writable storage container.

    Args:
        storage: A storage container.
        path: The path of the directory to create.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateStorageDirectory.
    """

    ret = _get_dylib_function[lib, "SDL_CreateStorageDirectory", fn (storage: Ptr[Storage, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(storage, path.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn enumerate_storage_directory(storage: Ptr[Storage, AnyOrigin[True]], var path: String, callback: EnumerateDirectoryCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) raises:
    """Enumerate a directory in a storage container through a callback function.

    This function provides every directory entry through an app-provided
    callback, called once for each directory entry, until all results have been
    provided or the callback returns either SDL_ENUM_SUCCESS or
    SDL_ENUM_FAILURE.

    This will return false if there was a system problem in general, or if a
    callback returns SDL_ENUM_FAILURE. A successful return means a callback
    returned SDL_ENUM_SUCCESS to halt enumeration, or all directory entries
    were enumerated.

    If `path` is NULL, this is treated as a request to enumerate the root of
    the storage container's tree. An empty string also works for this.

    Args:
        storage: A storage container.
        path: The path of the directory to enumerate, or NULL for the root.
        callback: A function that is called for each entry in the directory.
        userdata: A pointer that is passed to `callback`.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EnumerateStorageDirectory.
    """

    ret = _get_dylib_function[lib, "SDL_EnumerateStorageDirectory", fn (storage: Ptr[Storage, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]], callback: EnumerateDirectoryCallback, userdata: Ptr[NoneType, AnyOrigin[True]]) -> Bool]()(storage, path.unsafe_cstr_ptr(), callback, userdata)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn remove_storage_path(storage: Ptr[Storage, AnyOrigin[True]], var path: String) raises:
    """Remove a file or an empty directory in a writable storage container.

    Args:
        storage: A storage container.
        path: The path of the directory to enumerate.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RemoveStoragePath.
    """

    ret = _get_dylib_function[lib, "SDL_RemoveStoragePath", fn (storage: Ptr[Storage, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(storage, path.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn rename_storage_path(storage: Ptr[Storage, AnyOrigin[True]], var oldpath: String, var newpath: String) raises:
    """Rename a file or directory in a writable storage container.

    Args:
        storage: A storage container.
        oldpath: The old path.
        newpath: The new path.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenameStoragePath.
    """

    ret = _get_dylib_function[lib, "SDL_RenameStoragePath", fn (storage: Ptr[Storage, AnyOrigin[True]], oldpath: Ptr[c_char, AnyOrigin[False]], newpath: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(storage, oldpath.unsafe_cstr_ptr(), newpath.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn copy_storage_file(storage: Ptr[Storage, AnyOrigin[True]], var oldpath: String, var newpath: String) raises:
    """Copy a file in a writable storage container.

    Args:
        storage: A storage container.
        oldpath: The old path.
        newpath: The new path.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CopyStorageFile.
    """

    ret = _get_dylib_function[lib, "SDL_CopyStorageFile", fn (storage: Ptr[Storage, AnyOrigin[True]], oldpath: Ptr[c_char, AnyOrigin[False]], newpath: Ptr[c_char, AnyOrigin[False]]) -> Bool]()(storage, oldpath.unsafe_cstr_ptr(), newpath.unsafe_cstr_ptr())
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_storage_path_info(storage: Ptr[Storage, AnyOrigin[True]], var path: String, info: Ptr[PathInfo, AnyOrigin[True]]) raises:
    """Get information about a filesystem path in a storage container.

    Args:
        storage: A storage container.
        path: The path to query.
        info: A pointer filled in with information about the path, or NULL to
              check for the existence of a file.

    Raises:
        Raises if the file doesn't exist, or another
        failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetStoragePathInfo.
    """

    ret = _get_dylib_function[lib, "SDL_GetStoragePathInfo", fn (storage: Ptr[Storage, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]], info: Ptr[PathInfo, AnyOrigin[True]]) -> Bool]()(storage, path.unsafe_cstr_ptr(), info)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_storage_space_remaining(storage: Ptr[Storage, AnyOrigin[True]]) raises -> UInt64:
    """Queries the remaining space in a storage container.

    Args:
        storage: A storage container to query.

    Returns:
        The amount of remaining space, in bytes.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetStorageSpaceRemaining.
    """

    return _get_dylib_function[lib, "SDL_GetStorageSpaceRemaining", fn (storage: Ptr[Storage, AnyOrigin[True]]) -> UInt64]()(storage)


fn glob_storage_directory(storage: Ptr[Storage, AnyOrigin[True]], var path: String, var pattern: String, flags: GlobFlags, count: Ptr[c_int, AnyOrigin[True]], out ret: Ptr[Ptr[c_char, AnyOrigin[True]], AnyOrigin[True]]) raises:
    """Enumerate a directory tree, filtered by pattern, and return a list.

    Files are filtered out if they don't match the string in `pattern`, which
    may contain wildcard characters `*` (match everything) and `?` (match one
    character). If pattern is NULL, no filtering is done and all results are
    returned. Subdirectories are permitted, and are specified with a path
    separator of '/'. Wildcard characters `*` and `?` never match a path
    separator.

    `flags` may be set to SDL_GLOB_CASEINSENSITIVE to make the pattern matching
    case-insensitive.

    The returned array is always NULL-terminated, for your iterating
    convenience, but if `count` is non-NULL, on return it will contain the
    number of items in the array, not counting the NULL terminator.

    If `path` is NULL, this is treated as a request to enumerate the root of
    the storage container's tree. An empty string also works for this.

    Args:
        storage: A storage container.
        path: The path of the directory to enumerate, or NULL for the root.
        pattern: The pattern that files in the directory must match. Can be
                 NULL.
        flags: `SDL_GLOB_*` bitflags that affect this search.
        count: On return, will be set to the number of items in the returned
               array. Can be NULL.

    Returns:
        An array of strings on success or NULL on failure; call
        SDL_GetError() for more information. The caller should pass the
        returned pointer to SDL_free when done with it. This is a single
        allocation that should be freed with SDL_free() when it is no
        longer needed.

    Safety:
        It is safe to call this function from any thread, assuming
        the `storage` object is thread-safe.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GlobStorageDirectory.
    """

    ret = _get_dylib_function[lib, "SDL_GlobStorageDirectory", fn (storage: Ptr[Storage, AnyOrigin[True]], path: Ptr[c_char, AnyOrigin[False]], pattern: Ptr[c_char, AnyOrigin[False]], flags: GlobFlags, count: Ptr[c_int, AnyOrigin[True]]) -> Ptr[Ptr[c_char, AnyOrigin[True]], AnyOrigin[True]]]()(storage, path.unsafe_cstr_ptr(), pattern.unsafe_cstr_ptr(), flags, count)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))
