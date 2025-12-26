## A recursive document type for building structured documents.
##
## Doc represents a tree of document elements that can be nested
## and composed together, then rendered to various formats.
module [
    Doc,
    empty,
    text,
    line,
    concat,
    nest,
    group,
    section,
    code,
    code_block,
    bold,
    italic,
    link,
    bullet_list,
    numbered_list,
    blockquote,
    horizontal_rule,
    table,
    render,
]

## A recursive document type representing structured content.
## Uses a nominal type with Box for proper recursion.
Doc := [
    Empty,
    Text(Str),
    Line,
    Concat(Box(Doc), Box(Doc)),
    Nest(U64, Box(Doc)),
    Group(Box(Doc)),
    Section(Str, Box(Doc)),
    Code(Str),
    CodeBlock(Str, Str),
    Bold(Box(Doc)),
    Italic(Box(Doc)),
    Link(Str, Str),
    BulletList(List(Box(Doc))),
    NumberedList(List(Box(Doc))),
    Blockquote(Box(Doc)),
    HorizontalRule,
    Table(List(Str), List(List(Box(Doc)))),
].{}

## Creates an empty document.
empty : Doc
empty = Empty

## Creates a document containing plain text.
text : Str -> Doc
text = |s| Text(s)

## Creates a line break.
line : Doc
line = Line

## Concatenates two documents together.
concat : Doc, Doc -> Doc
concat = |a, b| {
    match (a, b) {
        (Empty, _) => b
        (_, Empty) => a
        _ => Concat(Box.box(a), Box.box(b))
    }
}

## Nests a document with the given indentation level.
nest : U64, Doc -> Doc
nest = |indent, doc| {
    match doc {
        Empty => Empty
        _ => Nest(indent, Box.box(doc))
    }
}

## Groups a document (for potential line breaking).
group : Doc -> Doc
group = |doc| Group(Box.box(doc))

## Creates a section with a title and body.
section : Str, Doc -> Doc
section = |title, body| Section(title, Box.box(body))

## Creates inline code.
code : Str -> Doc
code = |s| Code(s)

## Creates a code block with language annotation.
code_block : Str, Str -> Doc
code_block = |lang, content| CodeBlock(lang, content)

## Makes a document bold.
bold : Doc -> Doc
bold = |doc| Bold(Box.box(doc))

## Makes a document italic.
italic : Doc -> Doc
italic = |doc| Italic(Box.box(doc))

## Creates a link with display text and URL.
link : Str, Str -> Doc
link = |display, url| Link(display, url)

## Creates a bullet list from a list of documents.
bullet_list : List(Doc) -> Doc
bullet_list = |items| {
    var $boxed = []
    for item in items {
        $boxed = List.append($boxed, Box.box(item))
    }
    BulletList($boxed)
}

## Creates a numbered list from a list of documents.
numbered_list : List(Doc) -> Doc
numbered_list = |items| {
    var $boxed = []
    for item in items {
        $boxed = List.append($boxed, Box.box(item))
    }
    NumberedList($boxed)
}

## Creates a blockquote containing a document.
blockquote : Doc -> Doc
blockquote = |doc| Blockquote(Box.box(doc))

## Creates a horizontal rule.
horizontal_rule : Doc
horizontal_rule = HorizontalRule

## Creates a table with headers and rows.
table : List(Str), List(List(Doc)) -> Doc
table = |headers, rows| {
    var $boxed_rows = []
    for row in rows {
        var $boxed_row = []
        for cell in row {
            $boxed_row = List.append($boxed_row, Box.box(cell))
        }
        $boxed_rows = List.append($boxed_rows, $boxed_row)
    }
    Table(headers, $boxed_rows)
}

## Renders a document to a Markdown string.
render : Doc -> Str
render = |doc|
    render_with_indent(doc, 0)

render_with_indent : Doc, U64 -> Str
render_with_indent = |doc, indent| {
    indent_str = Str.repeat(" ", indent)
    match doc {
        Empty => ""
        Text(s) => s
        Line => Str.concat("\n", indent_str)
        Concat(a, b) =>
            Str.concat(render_with_indent(Box.unbox(a), indent), render_with_indent(Box.unbox(b), indent))
        Nest(n, inner) =>
            render_with_indent(Box.unbox(inner), indent + n)
        Group(inner) =>
            render_with_indent(Box.unbox(inner), indent)
        Section(title, body) => {
            rendered_body = render_with_indent(Box.unbox(body), indent)
            "## ${title}\n\n${rendered_body}"
        }
        Code(s) =>
            "`${s}`"
        CodeBlock(lang, content) =>
            "```${lang}\n${content}\n```"
        Bold(inner) => {
            rendered = render_with_indent(Box.unbox(inner), indent)
            "**${rendered}**"
        }
        Italic(inner) => {
            rendered = render_with_indent(Box.unbox(inner), indent)
            "*${rendered}*"
        }
        Link(display, url) =>
            "[${display}](${url})"
        BulletList(items) => {
            mapped = List.map(items, |item| Str.concat("- ", render_with_indent(Box.unbox(item), indent)))
            Str.join_with(mapped, "\n")
        }
        NumberedList(items) => {
            var $idx = 1u64
            var $lines = []
            for item in items {
                num_str = $idx.to_str()
                rendered_item = render_with_indent(Box.unbox(item), indent)
                new_line = "${num_str}. ${rendered_item}"
                $lines = List.append($lines, new_line)
                $idx = $idx + 1
            }
            Str.join_with($lines, "\n")
        }
        Blockquote(inner) => {
            rendered = render_with_indent(Box.unbox(inner), indent)
            lines = Str.split_on(rendered, "\n")
            quoted_lines = List.map(lines, |line_str| Str.concat("> ", line_str))
            Str.join_with(quoted_lines, "\n")
        }
        HorizontalRule =>
            "---"
        Table(headers, rows) => {
            header_row = Str.concat("| ", Str.concat(Str.join_with(headers, " | "), " |"))
            separator_parts = List.map(headers, |_| "---")
            separator = Str.concat("| ", Str.concat(Str.join_with(separator_parts, " | "), " |"))
            data_rows = List.map(rows, |row| {
                cells = List.map(row, |cell| render_with_indent(Box.unbox(cell), indent))
                Str.concat("| ", Str.concat(Str.join_with(cells, " | "), " |"))
            })
            data_rows_str = Str.join_with(data_rows, "\n")
            "${header_row}\n${separator}\n${data_rows_str}"
        }
    }
}
