app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import Range

# Demonstrates the Range module with Julia-style range syntax

main! = |_args| {
    Stdout.line!("=== Range Demo (Julia-style syntax) ===\n")

    # Basic range: equivalent to Julia's 1:10
    basic_range = Range.new(1, 10)
    Stdout.line!("Range.new(1, 10) - equivalent to Julia's 1:10")
    Stdout.line!("  to_list: ${Str.inspect(Range.to_list(basic_range))}")
    Stdout.line!("  len: ${U64.to_str(Range.len(basic_range))}")
    Stdout.line!("")

    # Range with step: equivalent to Julia's 1:2:10
    stepped_range = Range.with_step(1, 2, 10)
    Stdout.line!("Range.with_step(1, 2, 10) - equivalent to Julia's 1:2:10")
    Stdout.line!("  to_list: ${Str.inspect(Range.to_list(stepped_range))}")
    Stdout.line!("  len: ${U64.to_str(Range.len(stepped_range))}")
    Stdout.line!("")

    # Alternative: step of 3
    stepped_range2 = Range.with_step(1, 3, 15)
    Stdout.line!("Range.with_step(1, 3, 15) - start=1, step=3, end=15")
    Stdout.line!("  to_list: ${Str.inspect(Range.to_list(stepped_range2))}")
    Stdout.line!("")

    # Descending range: equivalent to Julia's 10:-1:1
    desc_range = Range.with_step(10, -1, 1)
    Stdout.line!("Range.with_step(10, -1, 1) - equivalent to Julia's 10:-1:1")
    Stdout.line!("  to_list: ${Str.inspect(Range.to_list(desc_range))}")
    Stdout.line!("")

    # Contains check
    range = Range.with_step(1, 2, 10)
    Stdout.line!("Range.with_step(1, 2, 10) contains checks:")
    Stdout.line!("  contains(5): ${Str.inspect(Range.contains(range, 5))}")  # True (odd)
    Stdout.line!("  contains(4): ${Str.inspect(Range.contains(range, 4))}")  # False (even)
    Stdout.line!("")

    # First and last
    range_1_9_by_3 = Range.with_step(1, 3, 9)
    Stdout.line!("first and last:")
    Stdout.line!("  Range.with_step(1, 3, 9).first(): ${Str.inspect(Range.first(range_1_9_by_3))}")
    Stdout.line!("  Range.with_step(1, 3, 9).last(): ${Str.inspect(Range.last(range_1_9_by_3))}")
    Stdout.line!("")

    # nth element
    range_1_10 = Range.new(1, 10)
    range_1_10_by_2 = Range.with_step(1, 2, 10)
    Stdout.line!("nth element:")
    Stdout.line!("  Range.new(1, 10).nth(0): ${Str.inspect(Range.nth(range_1_10, 0))}")
    Stdout.line!("  Range.new(1, 10).nth(4): ${Str.inspect(Range.nth(range_1_10, 4))}")
    Stdout.line!("  Range.with_step(1, 2, 10).nth(2): ${Str.inspect(Range.nth(range_1_10_by_2, 2))}")
    Stdout.line!("")

    # Map
    mapped = Range.map(Range.new(1, 5), |x| x * x)
    Stdout.line!("Range.map(Range.new(1, 5), |x| x * x): ${Str.inspect(mapped)}")
    Stdout.line!("")

    # Fold (sum)
    sum = Range.fold(Range.new(1, 10), 0, |acc, x| acc + x)
    Stdout.line!("Range.fold(Range.new(1, 10), 0, |acc, x| acc + x): ${I64.to_str(sum)}")
    Stdout.line!("")

    # Filter
    evens = Range.filter(Range.new(1, 10), |x| x % 2 == 0)
    Stdout.line!("Range.filter(Range.new(1, 10), |x| x % 2 == 0): ${Str.inspect(evens)}")
    Stdout.line!("")

    # Reversed
    reversed = Range.to_list(Range.reversed(Range.new(1, 5)))
    Stdout.line!("Range.to_list(Range.reversed(Range.new(1, 5))): ${Str.inspect(reversed)}")
    Stdout.line!("")

    # Practical example: FizzBuzz using range
    Stdout.line!("=== FizzBuzz using Range (1-15) ===")
    fizzbuzz_list = Range.map(Range.new(1, 15), fizzbuzz)
    Stdout.line!("${Str.inspect(fizzbuzz_list)}")

    Ok({})
}

fizzbuzz : I64 -> Str
fizzbuzz = |n| {
    divisible_by_3 = (n % 3) == 0
    divisible_by_5 = (n % 5) == 0
    match (divisible_by_3, divisible_by_5) {
        (True, True) => "FizzBuzz"
        (True, False) => "Fizz"
        (False, True) => "Buzz"
        (False, False) => I64.to_str(n)
    }
}
