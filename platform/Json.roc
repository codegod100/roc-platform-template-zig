Json := [].{
    parse_array_field! : List(U8), Str => List(List(U8))
    parse_number_field! : List(U8), Str => Str
    parse_string_field! : List(U8), Str => Str
    parse_u64_array! : List(U8), U64 => List(U64)
}
