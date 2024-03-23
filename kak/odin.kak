# http://odinoune.org
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*[.](odin) %{
    set-option buffer filetype odin
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=odin %~
    require-module odin

    set-option window static_words %opt{odin_static_words}

    hook window InsertChar \n -group odin-insert odin-insert-on-new-line
    hook window InsertChar \n -group odin-indent odin-indent-on-new-line
    hook window InsertChar [>)}\]] -group odin-indent odin-indent-on-closing-matching
    hook window InsertChar (?![[{(<>)}\]])[^\s\w] -group odin-indent odin-indent-on-closing-char
    # cleanup trailing whitespaces on current line insert end
    hook window ModeChange pop:insert:.* -group odin-trim-indent %{ try %{ execute-keys -draft <semicolon> x s ^\h+$ <ret> d } }
    set-option buffer extra_word_chars '_' '-'

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window odin-.+ }
~

hook -group odin-highlight global WinSetOption filetype=odin %{
    add-highlighter window/odin ref odin
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/odin }
}

provide-module odin %§

require-module sh

# Highlighters & Completion
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/odin regions
add-highlighter shared/odin/code default-region group
add-highlighter shared/odin/comment region (^|\h)\K// $ fill comment
add-highlighter shared/odin/multicomment region /\* \*/ fill comment
add-highlighter shared/odin/string region -recurse %{(?<!")("")+(?!")} %{(^|\h)\K"} %{"(?!")} group
add-highlighter shared/odin/char region -recurse %{(?<!')('')+(?!')} %{(^|\h)\K'} %{'(?!')} group
add-highlighter shared/odin/rawstring region -recurse %{(?<!`)(``)+(?!`)} %{(^|\h)\K`} %{`(?!`)} group

evaluate-commands %sh{
    # Grammar
    keywords="asm auto_cast bit_set break case cast context continue defer distinct do dynamic else enum
              fallthrough for foreign if import in map not_in or_else or_return package proc return struct
              switch transmute typeid union using when where"
    attributes=""
    types="bool b8 b16 b32 b64
           int  i8 i16 i32 i64 i128
           uint u8 u16 u32 u64 u128 uintptr
           i16le i32le i64le i128le u16le u32le u64le u128le
           i16be i32be i64be i128be u16be u32be u64be u128be
           f16 f32 f64
           f16le f32le f64le
           f16be f32be f64be
           complex32 complex64 complex128
           quaternion64 quaternion128 quaternion256
           rune
           string cstring
           rawptr
           typeid
           any"
    values="false true nil ---"

    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

    # Add the language's grammar to the static completion list
    printf %s\\n "declare-option str-list odin_static_words $(join "${keywords} ${attributes} ${types} ${values}" ' ')'"

    # Highlight keywords (which are always surrounded by whitespace)
    printf '%s\n' "add-highlighter shared/odin/code/keywords regex (?:\s|\A)\K($(join "${keywords}" '|'))(?:(?=\s)|\z) 0:keyword
                   add-highlighter shared/odin/code/attributes regex (?:\s|\A)\K($(join "${attributes}" '|'))(?:(?=\s)|\z) 0:attribute
                   add-highlighter shared/odin/code/types regex (?:\s|\A)\K($(join "${types}" '|'))(?:(?=\s)|\z) 0:type
                   add-highlighter shared/odin/code/values regex (?:\s|\A)\K($(join "${values}" '|'))(?:(?=\s)|\z) 0:value"
}

add-highlighter shared/odin/code/colors regex \b(rgb:[0-9a-fA-F]{6}|rgba:[0-9a-fA-F]{8})\b 0:value
add-highlighter shared/odin/code/numbers regex \b\d+\b 0:value

add-highlighter shared/odin/string/fill fill string
add-highlighter shared/odin/string/escape regex '""' 0:default+b
add-highlighter shared/odin/char/fill fill string
add-highlighter shared/odin/char/escape regex "''" 0:default+b
add-highlighter shared/odin/rawstring/fill fill string
add-highlighter shared/odin/rawstring/escape regex "''" 0:default+b

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden odin-insert-on-new-line %~
    evaluate-commands -draft -itersel %=
        # copy '//' comment prefix and following white spaces
        try %{ execute-keys -draft k x s ^\h*//\h* <ret> y jgh P }
    =
~

define-command -hidden odin-indent-on-new-line %~
    evaluate-commands -draft -itersel %=
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon> K <a-&> }
        # cleanup trailing whitespaces from previous line
        try %{ execute-keys -draft k x s \h+$ <ret> d }
        # indent after line ending with %\w*[^\s\w]
        try %{ execute-keys -draft k x <a-k> \%\w*[^\s\w]$ <ret> j <a-gt> }
        # deindent closing brace when after cursor
        try %_ execute-keys -draft -itersel x <a-k> ^\h*([>)}\]]) <ret> gh / <c-r>1 <ret> m <a-S> 1<a-&> _
        # deindent closing char(s) 
        try %{ execute-keys -draft -itersel x <a-k> ^\h*([^\s\w]) <ret> gh / <c-r>1 <ret> <a-?> <c-r>1 <ret> <a-T>% <a-k> \w*<c-r>1$ <ret> <a-S> 1<a-&> }
    =
~

define-command -hidden odin-indent-on-closing-matching %~
    # align to opening matching brace when alone on a line
    try %= execute-keys -draft -itersel <a-h><a-k>^\h*\Q %val{hook_param} \E$<ret> mGi s \A|.\z<ret> 1<a-&> =
~

define-command -hidden odin-indent-on-closing-char %{
    # align to opening matching character when alone on a line
    try %{ execute-keys -draft -itersel <a-h><a-k>^\h*\Q %val{hook_param} \E$<ret>gi<a-f> %val{hook_param} <a-T>%<a-k>\w*\Q %val{hook_param} \E$<ret> s \A|.\z<ret> gi 1<a-&> }
}

§
