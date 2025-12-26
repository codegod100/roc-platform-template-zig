## ASCII art letters module

AsciiLetter : {
    rows : List(List(U8)),
    max_head_overlap : U8,
    max_tail_overlap : U8,
}

Letters := {
    char_to_ascii_letter : U8 -> AsciiLetter,
    empty_letter : AsciiLetter,
}

char_to_ascii_letter : U8 -> AsciiLetter
char_to_ascii_letter = |char|
    match char {
        'H' => upper_h
        'i' => lower_i
        ' ' => space_letter
        _ => empty_letter
    }

empty_letter : AsciiLetter
empty_letter = {
    rows: [[], [], [], [], [], []],
    max_head_overlap: 0,
    max_tail_overlap: 0,
}

space_letter : AsciiLetter
space_letter = {
    rows: [[32], [32], [32], [32], [32], [32]],
    max_head_overlap: 0,
    max_tail_overlap: 0,
}

upper_h : AsciiLetter
upper_h = {
    rows: [
        [' ', '_', ' ', ' ', ' ', '_', ' '],
        ['|', ' ', '|', ' ', '|', ' ', '|'],
        ['|', ' ', '|', '_', '|', ' ', '|'],
        ['|', ' ', ' ', '_', ' ', ' ', '|'],
        ['|', '_', '|', ' ', '|', '_', '|'],
        [' ', ' ', ' ', ' ', ' ', ' ', ' '],
    ],
    max_head_overlap: 7,
    max_tail_overlap: 7,
}

lower_i : AsciiLetter
lower_i = {
    rows: [
        [' ', '_', ' '],
        ['(', '_', ')'],
        ['|', ' ', '|'],
        ['|', ' ', '|'],
        ['|', '_', '|'],
        [' ', ' ', ' '],
    ],
    max_head_overlap: 3,
    max_tail_overlap: 3,
}
