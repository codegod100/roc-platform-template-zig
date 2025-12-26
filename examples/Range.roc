## A Range type supporting Julia-style range syntax.
##
## In Julia:
## - `1:10` means range from 1 to 10 (inclusive) with step 1
## - `1:2:10` means range from 1 to 10 (inclusive) with step 2
##
## In Roc, we provide a clean API:
## ```
## # Equivalent to Julia's 1:10
## range = Range.new(1, 10)
##
## # Equivalent to Julia's 1:2:10 (start:step:end)
## range = Range.with_step(1, 2, 10)
## ```
module [
    Range,
    new,
    with_step,
    to_list,
    map,
    fold,
    filter,
    len,
    contains,
    first,
    last,
    nth,
    reversed,
    start,
    end,
    step,
    is_empty,
]

## A Range representing a sequence of integers with a start, end, and step.
Range : { start : I64, step : I64, end : I64 }

## Create a new range from start to end (inclusive) with step 1.
## Equivalent to Julia's `start:end`.
new : I64, I64 -> Range
new = |start_val, end_val|
    { start: start_val, step: 1, end: end_val }

## Create a new range with explicit start, step, and end values.
## Equivalent to Julia's `start:step:end`.
with_step : I64, I64, I64 -> Range
with_step = |start_val, step_val, end_val|
    { start: start_val, step: step_val, end: end_val }

## Get the start value of the range.
start : Range -> I64
start = |r| r.start

## Get the end value of the range.
end : Range -> I64
end = |r| r.end

## Get the step value of the range.
step : Range -> I64
step = |r| r.step

## Check if the range is empty.
is_empty : Range -> Bool
is_empty = |r|
    if r.step == 0 True else if r.step > 0 r.start > r.end else r.start < r.end

## Calculate the number of elements in the range.
len : Range -> U64
len = |r|
    if r.step > 0 len_ascending(r.start, r.step, r.end)
    else if r.step < 0 len_descending(r.start, r.step, r.end)
    else 0u64

len_ascending : I64, I64, I64 -> U64
len_ascending = |start_val, step_val, end_val| {
    var $count = 0u64
    var $current = start_val

    while $current <= end_val {
        $count = $count + 1u64
        $current = $current + step_val
    }

    $count
}

len_descending : I64, I64, I64 -> U64
len_descending = |start_val, step_val, end_val| {
    var $count = 0u64
    var $current = start_val

    while $current >= end_val {
        $count = $count + 1u64
        $current = $current + step_val
    }

    $count
}

## Get the first element of the range.
first : Range -> [Ok(I64), Err([Empty])]
first = |r|
    match is_empty(r) {
        True => Err(Empty)
        False => Ok(r.start)
    }

## Get the last element that would actually be produced by the range.
last : Range -> [Ok(I64), Err([Empty])]
last = |r|
    match len(r) == 0 {
        True => Err(Empty)
        False =>
            match nth(r, len(r) - 1) {
                Ok(val) => Ok(val)
                Err(_) => Err(Empty)
            }
    }

## Get the nth element of the range (0-indexed).
nth : Range, U64 -> [Ok(I64), Err([OutOfBounds])]
nth = |r, index|
    match index >= len(r) {
        True => Err(OutOfBounds)
        False => Ok(r.start + (r.step * index_to_i64(index)))
    }

index_to_i64 : U64 -> I64
index_to_i64 = |index| {
    # Simple loop-based conversion: count from 0 to index
    var $result = 0i64
    var $count = 0u64
    while $count < index {
        $result = $result + 1i64
        $count = $count + 1u64
    }
    $result
}

## Check if a value is contained in the range.
contains : Range, I64 -> Bool
contains = |r, value|
    if r.step == 0 False
    else if r.step > 0 contains_ascending(r.start, r.step, r.end, value)
    else contains_descending(r.start, r.step, r.end, value)

contains_ascending : I64, I64, I64, I64 -> Bool
contains_ascending = |start_val, step_val, end_val, value|
    if value < start_val or value > end_val False
    else (value - start_val) % step_val == 0

contains_descending : I64, I64, I64, I64 -> Bool
contains_descending = |start_val, step_val, end_val, value|
    if value > start_val or value < end_val False
    else (start_val - value) % (-step_val) == 0

## Convert the range to a list of values.
to_list : Range -> List(I64)
to_list = |r|
    if r.step > 0 to_list_ascending(r.start, r.step, r.end)
    else if r.step < 0 to_list_descending(r.start, r.step, r.end)
    else []

to_list_ascending : I64, I64, I64 -> List(I64)
to_list_ascending = |start_val, step_val, end_val| {
    var $values = []
    var $current = start_val

    while $current <= end_val {
        $values = List.append($values, $current)
        $current = $current + step_val
    }

    $values
}

to_list_descending : I64, I64, I64 -> List(I64)
to_list_descending = |start_val, step_val, end_val| {
    var $values = []
    var $current = start_val

    while $current >= end_val {
        $values = List.append($values, $current)
        $current = $current + step_val
    }

    $values
}

## Create a reversed range.
reversed : Range -> Range
reversed = |r| {
    match last(r) {
        Ok(last_val) =>
            { start: last_val, step: -(r.step), end: r.start }

        Err(_) =>
            r
    }
}

## Apply a function to each element of the range, producing a list.
map : Range, (I64 -> a) -> List(a)
map = |r, f|
    List.map(to_list(r), f)

## Fold over the range, accumulating a result.
fold : Range, state, (state, I64 -> state) -> state
fold = |r, initial, f| {
    var $acc = initial
    for val in to_list(r) {
        $acc = f($acc, val)
    }
    $acc
}

## Filter the range, keeping only elements that satisfy the predicate.
filter : Range, (I64 -> Bool) -> List(I64)
filter = |r, predicate|
    List.keep_if(to_list(r), predicate)
