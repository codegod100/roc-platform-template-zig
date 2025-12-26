## A truly recursive Doc type inspired by Unison's Doc type.

app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

WrapStyle := [Bold, Italic, Code, Section(Str), Link(Str), Blockquote]

Doc := [
    Text(Str),
    Wrapped(WrapStyle, Box(Doc)),
    Items(List(Doc)),
]

to_markdown : Doc -> Str
to_markdown = |doc| match doc {
    Text(s) => s
    Wrapped(style, boxed) => {
        inner = to_markdown(Box.unbox(boxed))
        match style {
            Bold => "**${inner}**"
            Italic => "*${inner}*"
            Code => "`${inner}`"
            Section(title) => "## ${title}\n\n${inner}"
            Link(url) => "[${inner}](${url})"
            Blockquote => "> ${inner}"
        }
    }
    Items(docs) => {
        rendered = List.map(docs, |d| to_markdown(d))
        Str.join_with(rendered, "")
    }
}

text : Str -> Doc
text = |s| Doc.Text(s)

bold : Doc -> Doc
bold = |inner| Doc.Wrapped(WrapStyle.Bold, Box.box(inner))

italic : Doc -> Doc
italic = |inner| Doc.Wrapped(WrapStyle.Italic, Box.box(inner))

code : Str -> Doc
code = |s| Doc.Wrapped(WrapStyle.Code, Box.box(Doc.Text(s)))

link : Doc, Str -> Doc
link = |label, url| Doc.Wrapped(WrapStyle.Link(url), Box.box(label))

blockquote : Doc -> Doc
blockquote = |inner| Doc.Wrapped(WrapStyle.Blockquote, Box.box(inner))

section : Str, Doc -> Doc
section = |title, content| Doc.Wrapped(WrapStyle.Section(title), Box.box(content))

join : List(Doc) -> Doc
join = |docs| Doc.Items(docs)

main! = |_args| {
    document = join([
        section(
            "Roc Platform Template",
            join([
                text("A template for creating "),
                bold(text("Roc platforms")),
                text(" using "),
                italic(text("Zig")),
            ])
        ),
        text("\n"),
        section(
            "Features", 
            join([
                text("- "),
                bold(text("Cross-platform")),
                text("\n- Built with "),
                link(text("Zig"), "https://ziglang.org"),
                text("\n- Includes "),
                code("Stdout"),
            ])
        ),
        text("\n---\n"),
        blockquote(join([
            italic(text("Note: ")),
            text("Uses "),
            bold(text("true recursion")),
        ])),
    ])

    Stdout.line!(to_markdown(document))
    Ok({})
}
