app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import Doc

main! = |_args| {
    Stdout.line!("=== Doc Module Demo ===")
    Stdout.line!("")

    # Build a comprehensive document
    doc =
        Doc.concat(
            Doc.section(
                "Welcome to the Doc Module",
                Doc.concat(
                    Doc.text("This demonstrates a "),
                    Doc.concat(
                        Doc.bold(Doc.text("recursive document type")),
                        Doc.text(" for building structured Markdown."),
                    ),
                ),
            ),
            Doc.concat(
                Doc.line,
                Doc.concat(
                    Doc.line,
                    Doc.concat(
                        Doc.section(
                            "Text Formatting",
                            Doc.bullet_list([
                                Doc.concat(Doc.bold(Doc.text("Bold")), Doc.text(" text")),
                                Doc.concat(Doc.italic(Doc.text("Italic")), Doc.text(" text")),
                                Doc.concat(Doc.text("Inline "), Doc.code("code")),
                                Doc.link("Links to websites", "https://roc-lang.org"),
                            ]),
                        ),
                        Doc.concat(
                            Doc.line,
                            Doc.concat(
                                Doc.line,
                                Doc.concat(
                                    Doc.section(
                                        "Code Example",
                                        Doc.code_block(
                                            "roc",
                                            "main! = |_args| {\n    Stdout.line!(\"Hello, World!\")\n    Ok({})\n}",
                                        ),
                                    ),
                                    Doc.concat(
                                        Doc.line,
                                        Doc.concat(
                                            Doc.line,
                                            Doc.concat(
                                                Doc.section(
                                                    "Numbered Steps",
                                                    Doc.numbered_list([
                                                        Doc.text("Install Roc"),
                                                        Doc.text("Create your first app"),
                                                        Doc.text("Run and enjoy!"),
                                                    ]),
                                                ),
                                                Doc.concat(
                                                    Doc.line,
                                                    Doc.concat(
                                                        Doc.line,
                                                        Doc.concat(
                                                            Doc.horizontal_rule,
                                                            Doc.concat(
                                                                Doc.line,
                                                                Doc.blockquote(
                                                                    Doc.concat(
                                                                        Doc.italic(Doc.text("Roc")),
                                                                        Doc.text(" - A fast, friendly, functional language."),
                                                                    ),
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                            ),
                        ),
                    ),
                ),
            ),
        )

    # Render and display
    markdown = Doc.render(doc)
    Stdout.line!(markdown)

    Ok({})
}
