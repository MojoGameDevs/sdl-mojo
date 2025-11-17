# x--------------------------------------------------------------------------x #
# | SDL3 Bindings in Mojo
# x--------------------------------------------------------------------------x #
#
# This program translates SDL header files into mojo code.
#
# It pulls from the sdl github repo, and outputs to ./out/
#
# It's kind of a mess, Hopefully someone will make a general bind-gen sometime.
# (It's basically a bunch of regex matches and functional subs.)
#
import re
from urllib.request import urlopen
from shutil import rmtree
from pathlib import Path


repo = "https://raw.githubusercontent.com/libsdl-org/SDL/refs/heads/release-3.2.x/include/SDL3/"

includes = [
    # "SDL_stdinc.h",
    # "SDL_assert.h",
    # "SDL_asyncio.h",
    # "SDL_atomic.h",
    "SDL_audio.h",
    # "SDL_bits.h",
    "SDL_blendmode.h",
    "SDL_camera.h",
    "SDL_clipboard.h",
    # "SDL_cpuinfo.h",
    # "SDL_dialog.h",
    # "SDL_endian.h",
    "SDL_error.h",
    "SDL_events.h",
    "SDL_filesystem.h",
    "SDL_gamepad.h",
    "SDL_gpu.h",
    "SDL_guid.h",
    "SDL_haptic.h",
    # "SDL_hidapi.h",
    "SDL_hints.h",
    "SDL_init.h",
    "SDL_iostream.h",
    "SDL_joystick.h",
    "SDL_keyboard.h",
    "SDL_keycode.h",
    # "SDL_loadso.h",
    # "SDL_locale.h",
    "SDL_log.h",
    # "SDL_messagebox.h",
    # "SDL_metal.h",
    # "SDL_misc.h",
    "SDL_mouse.h",
    # "SDL_mutex.h",
    "SDL_pen.h",
    "SDL_pixels.h",
    # "SDL_platform.h",
    "SDL_power.h",
    # "SDL_process.h",
    "SDL_properties.h",
    "SDL_rect.h",
    "SDL_render.h",
    "SDL_scancode.h",
    "SDL_sensor.h",
    "SDL_storage.h",
    "SDL_surface.h",
    # "SDL_system.h",
    # "SDL_thread.h",
    "SDL_time.h",
    "SDL_timer.h",
    # "SDL_tray.h",
    "SDL_touch.h",
    "SDL_version.h",
    "SDL_video.h",
    # "SDL_oldnames.h",
]


def snake_case(string: str) -> str:
    # these do not follow the rules like the rest of the code or just would look weird otherwise
    special_cases = {
        "UVplane": "UVPlane",
        "UVpitch": "UVPitch",
        "Yplane": "YPlane",
        "Ypitch": "YPitch",
        "VSync": "Vsync",
        "9Grid": "_9grid",
    }
    for k, v in special_cases.items():
        if k not in string:
            continue
        string = string.replace(k, v)
    return re.sub(
        r"(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])", "_", string
    ).lower()


def capitalize(string: str) -> str:
    return (
        string.capitalize()
        if len(string) < 2
        else (string[0].capitalize() + string[1:])
    )


def drop_prefix(string: str) -> str:
    return string.replace("SDL_", "")


# +------( heading )------+ #
#
def translate_heading(m: re.Match) -> str:
    license = re.sub(r"^(?:  )?", r"# | ", m["license"], flags=re.MULTILINE)
    filedoc = re.sub(r"^ \* ?", r"", m["filedoc"], flags=re.MULTILINE)
    return f'''# x--------------------------------------------------------------------------x #
# | SDL3 Bindings in Mojo
# x--------------------------------------------------------------------------x #
{license}
# x--------------------------------------------------------------------------x #

"""{filedoc}
"""
'''


# +------( type )------+ #
#
type_map = {
    "void": "NoneType",
    "SDL_FunctionPointer": "fn () -> None",
    "SDL_Time": "Int64",
    "intptr_t": "Int",
    "char": "c_char",
    "unsigned char": "c_uint",
    "int": "c_int",
    "unsigned int": "c_uint",
    "short": "c_short",
    "unsigned short": "c_ushort",
    "long": "c_long",
    "long long": "c_long_long",
    "size_t": "c_size_t",
    "ssize_t": "c_ssize_t",
    "float": "c_float",
    "double": "c_double",
    "uint8_t": "UInt8",
    "Uint8": "UInt8",
    "uint16_t": "UInt16",
    "Uint16": "UInt16",
    "uint32_t": "UInt32",
    "Uint32": "UInt32",
    "uint64_t": "UInt64",
    "Uint64": "UInt64",
    "int8_t": "Int8",
    "Sint8": "Int8",
    "int16_t": "Int16",
    "Sint16": "Int16",
    "int32_t": "Int32",
    "Sint32": "Int32",
    "int64_t": "Int64",
    "Sint64": "Int64",
    "bool": "Bool",
}


def translate_type(m: re.Match) -> str:
    result = m["type"]
    result = result.replace(" *const", "").replace(" * const", "")
    result = type_map.get(result) or result

    if m.groupdict().get("ptrs"):
        for _ in range(len(m["ptrs"])):
            result = f"Ptr[{result}, AnyOrigin[{not bool(m['mut'])}]]"

    if m.groupdict().get("vecs"):
        result = f"ArrayHelper[{result}, {m['vecs']}, AnyOrigin[{not bool(m['mut'])}]].result"

    if m.groupdict().get("amnt"):
        result = f"InlineArray[{result}, {m['amnt']}]"

    return drop_prefix(result)


# +------( return )------+ #
#
def translate_return_type(m: re.Match) -> str:
    return "None" if m[0] == "void" else translate_type(m)


# +------( variable )------+ #
#
match_return = re.compile(
    r"^(?P<mut>const )?(?P<type>.+?) ?(?P<ptrs>\**)(?:\[(?P<vecs>.*?)\])?$"
)
match_variable = re.compile(
    r"^(?P<mut>const )?(?P<type>.+) (?P<ptrs>\**)(?P<name>\w+?)(?:\[(?P<vecs>.*?)\])?$"
)
match_function_pointer = re.compile(
    r"^(?P<ret>.*?) \(SDLCALL \*(?P<name>\w*)\)\((?P<args>.*?)\)"
)


def translate_variable(m: re.Match) -> str:
    return f"{snake_case(drop_prefix(m['name']))}: {translate_type(m)}"


def translate_function_pointer(m: re.Match) -> str:
    if m:
        ret = translate_return_type(re.match(match_return, m["ret"]))
        args = re.sub(match_argument, translate_argument, m["args"])
        return f"{snake_case(drop_prefix(m['name']))}: fn ({args}) -> {ret}"


# +------( docstring )------+ #
#
match_docblock_indent = re.compile(r"^ *\* ?", flags=re.MULTILINE)
match_docblock_category = re.compile(
    r"^\\(?P<cat>\w+) (?P<body>[^\n]*\n?(?: [^\n]*\n)*)", flags=re.MULTILINE
)


def doc_template(doc: str, name: str, ind: str = "") -> str:
    return f'''"""{doc}

{ind}Docs: https://wiki.libsdl.org/SDL3/{name}.
{ind}"""
'''


def format_docstring(string: str) -> str:
    if string:
        string = re.sub(match_docblock_indent, "", string)
        first_param = True

        def translate_category(category: re.Match) -> str:
            nonlocal first_param
            result: str
            match category.group("cat"):
                case "param":
                    first_space = category.group("body").find(" ")
                    name = snake_case(category.group("body")[:first_space])
                    body = capitalize(category.group("body")[first_space:].strip(" "))
                    body = re.sub(
                        r"\n +",
                        "\n" + (" " * (len(name) + 6)),
                        body,
                        flags=re.MULTILINE,
                    )
                    result = (
                        ("Args:\n" if first_param else "") + "    " + name + ": " + body
                    )
                    first_param = False
                case "returns":
                    result = f"\nReturns:\n    {re.sub(r'\n +', '\n    ', capitalize(category.group('body')), flags=re.MULTILINE)}"
                case "threadsafety":
                    result = f"Safety:\n    {re.sub(r'\n +', '\n    ', capitalize(category.group('body')), flags=re.MULTILINE)}"
                case _:
                    result = ""
            return result

        string = re.sub(match_docblock_category, translate_category, string)
        string = re.sub(r"\\", r"\\\\", string)
        string = re.sub(r"\n *\n *\n", r"\n\n", string.strip(), flags=re.MULTILINE)

        # Capitalize first character and add a period to the first sentence
        end = string.find("\n\n")
        end = len(string) if end == -1 else end
        if string[end - 1] != ".":
            string = string[:end] + "." + string[end:]
        return string[0].upper() + string[1:]


def format_docblock(string: str) -> str:
    if string:
        doc = re.sub(match_docblock_category, "", string).strip()
        doc = format_docstring(doc)
        return re.sub("\n", r"\n    ", doc, flags=re.MULTILINE)


def format_comblock(string: str) -> str:
    if string:
        doc = re.sub(match_docblock_category, "", string).strip()
        return re.sub("^", r"    # ", doc, flags=re.MULTILINE)


# +------( typedef )------+ #
#
match_typedef_defines = re.compile(
    r"#define (?P<name>\w+)(?:\((?P<params>[^\n]+?)\))??  *(?P<expr>.+?) *(?:/\*\*< (?P<doc>.*?) \*/)?\n"
)


def translate_typedef(m: re.Match) -> str:
    doc = format_docblock(m["doc"])
    type = type_map.get(m["td_type"]) or m["td_type"]
    name = m["td_name"]
    mojo_name = drop_prefix(name)
    ptr = m["td_ptr"]

    if ptr:
        return f"comptime {mojo_name} = Ptr[NoneType, AnyOrigin[True]]\n{doc_template(doc, name)}"

    def translate_def(m: re.Match) -> str:
        def_name = drop_prefix(m["name"])
        def_params = m["params"]
        def_expr = re.sub(r"SDL_UINT64_C\((\w*)\)", r"\1", m["expr"])
        def_expr = def_expr.replace("u", "").lstrip("(").rstrip(")")
        def_expr = re.sub(r"\bSDL(\w*)\b", r"Self.SDL\1.value", def_expr)
        def_expr = drop_prefix(def_expr)
        def_doc = format_docblock(m["doc"])
        if def_params:
            return f"""
    @always_inline
    @staticmethod
    fn {def_name}({def_params}: {type}) -> {type}:
        return {def_expr}

"""
        else:
            return (
                f"    comptime {def_name} = Self({def_expr})"
                + (f'\n    """{def_doc}"""' if def_doc else "")
                + "\n"
            )

    defs = re.sub(match_typedef_defines, translate_def, m["td_defs"])
    return f"""
@register_passable("trivial")
struct {mojo_name}(Intable):
    {doc_template(doc, name, "    ")}
    var value: {type}

    @always_inline
    fn __init__(out self, value: {type}):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __or__(lhs, rhs: Self) -> Self:
        return Self(lhs.value | rhs.value)

{defs}
"""


# +------( macros )------+ #
#


# +------( enums )------+ #
#
match_enum_types = re.compile(
    r"^    ([\w]+?)(?: *= (-?[\w]+?))?,?(?:\n|$| */\*(?:\*<)?(.*?)\*/)",
    flags=re.MULTILINE | re.DOTALL,
)
match_enum_comment = re.compile(
    r" */\*(?:([^\n]*)\*/\n|\*?(.*?)\*/)", flags=re.MULTILINE | re.DOTALL
)
running_enum_value = 0
running_enum_base = 0


def translate_enum_type(m: re.Match) -> str:
    global running_enum_value, running_enum_base
    name = m[1]
    name = re.sub("(^[0-9]+$)", r"N\1", name)
    value = m[2]
    if value:
        try:
            value = value.replace("u", "")
            running_enum_value = int(value, 0) + 1
            running_enum_base = 16 if value.startswith("0x") else 10
        except:
            value = "Self." + value
    else:
        value = (
            hex(running_enum_value)
            if running_enum_base == 16
            else str(running_enum_value)
        )
        running_enum_value += 1
    doc = format_docblock(m[3])
    if "Self." not in value:
        value = f"Self({value})"
    res = drop_prefix(f"    comptime {name} = {value}\n")
    if doc:
        return res + f'    """{doc}"""'
    return res


def translate_enum_comment(m: re.Match) -> str:
    if m[1]:
        # single-line comment
        if not re.search(r"@[\{\}]", m[1]):
            return format_comblock(m[1]) + "\n"
    elif m[2]:
        # multi-line comment
        return format_comblock(m[2])
    return ""


match_enum_if = re.compile(
    r"^    #if (?P<cond>[^\n]+)\n(?P<true>(?:[^\n]+\n)+?)    #else\n(?P<false>(?:[^\n]+\n)+?)    #endif",
    re.MULTILINE,
)
match_enum_if_type = re.compile(r"(?P<name>\w+) = (?P<val>\w+)")


def translate_enum_if(m: re.Match) -> str:
    cond = m["cond"]
    if cond == "SDL_BYTEORDER == SDL_BIG_ENDIAN":
        cond = "is_big_endian()"
    elif cond == "SDL_BYTEORDER == SDL_LIL_ENDIAN":
        cond = "is_little_endian()"

    true_iter = re.finditer(match_enum_if_type, m["true"])
    false_iter = re.finditer(match_enum_if_type, m["false"])
    result = ""
    for false, true in zip(true_iter, false_iter):
        result += f"    comptime {false.group('name')} = Self.{false.group('val')} if {cond} else Self.{true.group('val')}\n"
    return drop_prefix(result)


def translate_enum(m: re.Match) -> str:
    global running_enum_value
    running_enum_value = 0
    doc = format_docblock(m["doc"])
    name = m["te_name"]
    body = m["te_body"]
    # types = re.sub(f'(?:{name.upper()}|EVENT|CAPITALIZE)_', '', match.group('enum_body'))
    body = re.sub(match_enum_if, translate_enum_if, body)
    body = re.sub(match_enum_types, translate_enum_type, body)
    body = re.sub(match_enum_comment, translate_enum_comment, body)
    return f"""
@register_passable("trivial")
struct {drop_prefix(name)}(Indexer, Intable):
    {doc_template(doc, name, "    ")}
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
{body}
"""


# +------( field )------+ #
#
match_field = re.compile(
    r"(?:^ */\*\*?\s*(?P<pre_doc>[\S\s]*?)\s*\*/\n)?    (?P<field>.+?); *(?:/\*\*< (?P<post_doc>[\S\s]*?) \*/)?",
    re.MULTILINE,
)
match_multi_field = re.compile(r"    (.+?)((?: \*?\w+?,)+ \w+;)")


def translate_field(field: re.Match) -> str:
    var = translate_function_pointer(
        re.match(match_function_pointer, field.group("field"))
    ) or translate_variable(re.match(match_variable, field.group("field")))
    doc = format_docblock(field.group("pre_doc") or field.group("post_doc"))
    return f"    var {var}" + (f'\n    """{doc}"""' if doc else "")


def split_multifield(multifield: re.Match) -> str:
    result = ""
    for field in re.finditer(r" (\w+?)[,;]", multifield.group(2)):
        result += f"    {multifield.group(1)} {field.group(1)};\n"
    return result


# +------( struct )------+ #
#
def translate_struct(m: re.Match) -> str:
    doc = format_docblock(m["doc"])
    name = m["s_name"]
    body = re.sub(match_field, translate_field, m["s_body"])
    return f"""
@fieldwise_init
struct {drop_prefix(name)}(ImplicitlyCopyable, Movable):
    {doc_template(doc, name, "    ")}

{body}
"""


# +------( opaque struct )------+ #
#
def translate_opaque_struct(m: re.Match) -> str:
    return f"""
@fieldwise_init
struct {drop_prefix(m["os_name"])}(ImplicitlyCopyable, Movable):
    {doc_template(format_docblock(m["doc"]), drop_prefix(m["os_name"]), "    ")}
    pass
"""


# +------( ptr struct )------+ #
#
def translate_ptr_struct(m: re.Match) -> str:
    return f"""
comptime {drop_prefix(m["ps_name"])} = Ptr[NoneType, AnyOrigin[True]]
{doc_template(format_docblock(m["doc"]), drop_prefix(m["ps_name"]))}
"""


# +------( typedef struct )------+ #
#
def translate_typedef_struct(m: re.Match) -> str:
    doc = format_docblock(m["doc"])
    name = drop_prefix(m["ts_name"])

    if name == "GamepadBinding":
        return translate_gamepadbinding(doc)

    body = m["ts_body"]
    body = re.sub(match_multi_field, split_multifield, body)
    body = re.sub(match_field, translate_field, body)
    if name == "StorageInterface":
        body = body.replace("var copy: fn", "var copy_file: fn")
    return f"""
@fieldwise_init
struct {name}(ImplicitlyCopyable, Movable):
    {doc_template(doc, name, "    ")}

{body}
"""


# +------( union )------+ #
#
match_union_member = re.compile(
    r"^    (?P<type>\w+) (?P<name>\w+)(?:\[(?P<amnt>\d+)\])?.*?$", re.MULTILINE
)


def translate_union(m: re.Match) -> str:
    name = m["tu_name"]
    body = ""
    for member in re.finditer(match_union_member, m["tu_body"]):
        body += "    " + translate_type(member) + ", `, `,\n"
    body = body.removesuffix(" `, `,\n")
    return f"""
struct {drop_prefix(name)}:
    comptime _mlir_type = __mlir_type[`!pop.union<`,
{body}
    `>`]
    var _impl: Self._mlir_type

    @implicit
    fn __init__[T: AnyType](out self, value: T):
        self._impl = rebind[Self._mlir_type](value)

    fn __getitem__[T: AnyType](ref self) -> ref [self._impl] T:
        return rebind[Ptr[T, origin_of(self._impl)]](Ptr(to=self._impl))[]
"""


# +------( argument )------+ #
#
match_argument = re.compile(r"(?:(?<=,)|^)\s*(.+?)(?:(?=,)|$)")
match_string_argument = re.compile(r"(\w+): Ptr\[c_char, AnyOrigin\[False\]\]")
match_argument_names = re.compile(r"(, ?)?(\w+):.*?(?:(?=, \w*?:)|$)")


def translate_argument(arg: re.Match) -> str:
    return (
        ""
        if arg.group() == "void"
        else (" " + translate_variable(re.match(match_variable, arg.group(1))))
    )


# +------( function )------+ #
#
def fn_raises_template(
    doc: str, sdl_name: str, mojo_name: str, args: str, ret: str, call: str
) -> str:
    return f"""
fn {mojo_name}({args}{", " * bool(args) * (ret != "None")}{f"out ret: {ret}" * (ret != "None")}) raises:
    {doc_template(doc, sdl_name, "    ")}
    ret = {call}
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))

"""


def fn_template(
    doc: str, sdl_name: str, mojo_name: str, args: str, ret: str, call: str
) -> str:
    return f"""
fn {mojo_name}({args}) raises -> {ret}:
    {doc_template(doc, sdl_name, "    ")}
    return {call}

"""


def translate_function(m: re.Match):
    if m.group("f_attr") and ("VARARG" in m.group("f_attr")):
        # handle variadic functions
        return ""
    doc = format_docblock(m["doc"])
    sdl_name = m.group("f_name")
    mojo_name = snake_case(drop_prefix(sdl_name))
    sdl_ret = translate_return_type(re.match(match_return, m.group("f_ret")))
    mojo_ret = re.sub(match_string_argument, r"String", sdl_ret)
    sdl_args = re.sub(
        match_argument, translate_argument, m.group("f_args")
    ).removeprefix(" ")
    mojo_args = re.sub(match_string_argument, r"var \1: String", sdl_args)
    pass_args = re.sub(match_argument_names, r"\1\2", sdl_args)
    for arg_name in re.finditer(r"\w+(?=: String)", mojo_args):
        pass_args = re.sub(
            r"\b" + arg_name[0] + r"\b", arg_name[0] + ".unsafe_cstr_ptr()", pass_args
        )
    call = f'_get_dylib_function[lib, "{m["f_name"]}", fn ({sdl_args}) -> {sdl_ret}]()({pass_args})'
    if mojo_ret == "String":
        call = "String(unsafe_from_utf8_ptr=" + call + ")"
    if re.search("Returns:\n        True on success", doc) and (mojo_ret == "Bool"):
        doc = doc.replace("Returns", "Raises")
        doc = re.sub(r"True on success.*?false (.*)", r"Raises \1", doc)
        mojo_ret = "None"
        return fn_raises_template(doc, sdl_name, mojo_name, mojo_args, mojo_ret, call)
    elif re.search(r"on failure;", doc, re.MULTILINE) and (
        mojo_ret.startswith("Ptr") or mojo_ret.startswith("String")
    ):
        return fn_raises_template(doc, sdl_name, mojo_name, mojo_args, mojo_ret, call)
    else:
        return fn_template(doc, sdl_name, mojo_name, mojo_args, mojo_ret, call)


# +------( typedef function )------+ #
#
def translate_typedef_function(m: re.Match):
    doc = format_docblock(m["doc"])
    name = m["tf_name"]
    ret = translate_return_type(re.match(match_return, m["tf_ret"]))
    args = re.sub(match_argument, translate_argument, m["tf_args"]).removeprefix(" ")
    f_type = f"fn ({args}) -> {ret}"
    if m["tf_ptr"]:
        f_type = f"Ptr[{f_type}, AnyOrigin[True]]"
    return f"""
comptime {drop_prefix(name)} = {f_type}
{doc_template(doc, name)}

"""


# +------( special cases )------+ #
#
# These are things this doesn't currently handle
def translate_gamepadbinding(doc: str) -> str:
    # nested structs
    return f'''
@fieldwise_init
@register_passable("trivial")
struct GamepadBindingInputAxis(ImplicitlyCopyable, Movable):
    var axis: c_int
    var axis_min: c_int
    var axis_max: c_int


@fieldwise_init
@register_passable("trivial")
struct GamepadBindingInputHat(ImplicitlyCopyable, Movable):
    var hat: c_int
    var hat_mask: c_int


@fieldwise_init
@register_passable("trivial")
struct GamepadBindingInput(ImplicitlyCopyable, Movable):
    comptime _mlir_type = __mlir_type[`!pop.union<`, GamepadBindingInputAxis, `, `, GamepadBindingInputHat, `>`]
    var _impl: Self._mlir_type

    @implicit
    fn __init__[T: AnyType](out self, value: T):
        self._impl = rebind[Self._mlir_type](value)

    fn __getitem__[T: AnyType](ref self) -> ref [self._impl] T:
        return rebind[Ptr[T, origin_of(self._impl)]](Ptr(to=self._impl))[]


@fieldwise_init
@register_passable("trivial")
struct GamepadBindingOutputAxis(ImplicitlyCopyable, Movable):
    var axis: GamepadAxis
    var axis_min: c_int
    var axis_max: c_int


@fieldwise_init
@register_passable("trivial")
struct GamepadBindingOutput(ImplicitlyCopyable, Movable):
    comptime _mlir_type = __mlir_type[`!pop.union<`, GamepadButton, `, `, GamepadBindingOutputAxis, `>`]
    var _impl: Self._mlir_type

    @implicit
    fn __init__[T: AnyType](out self, value: T):
        self._impl = rebind[Self._mlir_type](value)

    fn __getitem__[T: AnyType](ref self) -> ref [self._impl] T:
        return rebind[Ptr[T, origin_of(self._impl)]](Ptr(to=self._impl))[]


@fieldwise_init
@register_passable("trivial")
struct GamepadBinding(ImplicitlyCopyable, Movable):
    """{doc}

    Docs: https://wiki.libsdl.org/SDL3/SDL_GamepadBinding.
    """
    var input_type: GamepadBindingType
    var input: GamepadBindingInput

    var output_type: GamepadBindingType
    var output: GamepadBindingOutput
'''


# +------( translate )------+ #
#
patterns = {
    "heading": (
        r"\A/\*\n(?P<license>.*?)\n\*/\n.*?\n/\*\*\n \* # Category(?P<filedoc>.*?)\n \*/",
        translate_heading,
    ),
    "typedef": (
        r"^typedef (?P<td_type>\w+) (?P<td_ptr>\*)?(?P<td_name>\w+);\n*(?P<td_defs>(#define.*?\n)*)",
        translate_typedef,
    ),
    "typedef_enum": (
        r"^typedef enum (?P<te_name>\w+?)\n\{\n(?P<te_body>.*?)\n\} (?P=te_name);",
        translate_enum,
    ),
    "struct": (
        r"^struct (?P<s_name>\w+?)[\n| ]\{\n(?P<s_body>.*?)\n\};(?:\n#endif /\* !SDL_INTERNAL \*/\n\ntypedef struct (?P=s_name) (?P=s_name);)?",
        translate_struct,
    ),
    "opaque_struct": (
        r"^typedef struct (?P<os_name>\w+?) (?P=os_name);",
        translate_opaque_struct,
    ),
    "ptr_struct": (
        r"^typedef struct (?P<ps_type>\w+) \*(?P<ps_name>\w+);",
        translate_ptr_struct,
    ),
    "typedef_struct": (
        r"^typedef struct (?P<ts_name>\w+?)[\n| ]\{\n(?P<ts_body>.+?)\n\} (?P=ts_name);",
        translate_typedef_struct,
    ),
    "typedef_union": (
        r"^typedef union (?P<tu_name>\w+?)\n\{\n(?P<tu_body>.+?)\n\} (?P=tu_name);",
        translate_union,
    ),
    "function": (
        r"^extern SDL_DECLSPEC (?P<f_ret>.+?) SDLCALL (?P<f_name>\w+?)\((?P<f_args>.+?)\)(?P<f_attr> [^\n]*)?;",
        translate_function,
    ),
    "typedef_function": (
        r"^typedef (?:const )?(?P<tf_ret>.+?) ?(?P<tf_ptr>\*)?\(SDLCALL \*(?P<tf_name>\w+)\)\((?P<tf_args>.+?)\);",
        translate_typedef_function,
    ),
}

regex = re.compile(
    r"(?:^/\*\*\n(?>(?P<doc>.*?)\n \*/\n))?(?:"
    + "|".join("(?P<%s>%s)" % (key, val[0]) for (key, val) in patterns.items())
    + ")",
    flags=re.MULTILINE | re.DOTALL,
)


def translate_src(src_url: str, out_path: Path):
    with urlopen(src_url) as src:
        with open(out_path, "w") as out:
            for match in re.finditer(regex, src.read().decode("utf-8")):
                _ = out.write(patterns[str(match.lastgroup)][1](match))


out_dir = Path('src/')
rmtree(out_dir, ignore_errors=True)
out_dir.mkdir(exist_ok=True)

imports = ""
for include in includes:
    out_path = out_dir / (include.lower().removesuffix(".h") + ".mojo")
    print("translating " + str(out_path))
    translate_src(repo + include, out_path)
    imports += f"from .{out_path.stem} import *\n"

with open(out_dir / "__init__.mojo", "w") as imp:
    _ = imp.write(f'''
# +--------------------------------------------------------------------------+ #
# | SDL3 Bindings in Mojo
# +--------------------------------------------------------------------------+ #

"""SDL3 Bindings in Mojo"""

{imports}

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


struct ArrayHelper[type: ImplicitlyCopyable & Movable, size: Int, origin: Origin]:
    comptime result = Ptr[InlineArray[type, size], origin]
''')
