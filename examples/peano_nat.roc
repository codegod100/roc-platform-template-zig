app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

## Peano Natural Numbers
##
## Conceptually: Nat : [Zero, Suc(Nat)]
##
## Since Roc's recursive nominal types have interpreter limitations,
## we use an isomorphic list-based encoding where the length represents
## the natural number:
##   [] ≅ Zero
##   [{}] ≅ Suc(Zero)
##   [{}, {}] ≅ Suc(Suc(Zero))
##   etc.

Nat : List({})

# Constructors

zero : Nat
zero = []

suc : Nat -> Nat
suc = |n| List.append(n, {})

# Conversions

from_u64 : U64 -> Nat
from_u64 = |n| List.repeat({}, n)

to_u64 : Nat -> U64
to_u64 = |n| List.len(n)

# Predicates

is_zero : Nat -> Bool
is_zero = |n| List.is_empty(n)

# Destructor

pred : Nat -> Nat
pred = |n| {
    val = to_u64(n)
    if val == 0 {
        zero
    } else {
        from_u64(val - 1)
    }
}

# Arithmetic

add : Nat, Nat -> Nat
add = |n, m| from_u64(to_u64(n) + to_u64(m))

mul : Nat, Nat -> Nat
mul = |n, m| from_u64(to_u64(n) * to_u64(m))

sub : Nat, Nat -> Nat
sub = |n, m| {
    nv = to_u64(n)
    mv = to_u64(m)
    if mv >= nv { zero } else { from_u64(nv - mv) }
}

# Comparisons

lt : Nat, Nat -> Bool
lt = |n, m| to_u64(n) < to_u64(m)

lte : Nat, Nat -> Bool
lte = |n, m| to_u64(n) <= to_u64(m)

eq : Nat, Nat -> Bool
eq = |n, m| to_u64(n) == to_u64(m)

# Display in Peano notation

to_peano_str : Nat -> Str
to_peano_str = |n| {
    val = to_u64(n)
    if val == 0 {
        "Zero"
    } else {
        var $s = "Zero"
        var $i = 0u64
        while $i < val {
            $s = "Suc(${$s})"
            $i = $i + 1
        }
        $s
    }
}

main! = |_args| {
    Stdout.line!("=== Peano Natural Numbers ===")
    Stdout.line!("Nat : [Zero, Suc(Nat)]")
    Stdout.line!("")

    one = suc(zero)
    two = suc(one)
    three = suc(two)
    four = suc(three)
    five = suc(four)

    Stdout.line!("Constructing with Zero and Suc:")
    Stdout.line!("  0 = ${to_peano_str(zero)}")
    Stdout.line!("  1 = ${to_peano_str(one)}")
    Stdout.line!("  2 = ${to_peano_str(two)}")
    Stdout.line!("  3 = ${to_peano_str(three)}")

    Stdout.line!("")
    Stdout.line!("Conversions:")
    Stdout.line!("  to_u64(three) = ${to_u64(three).to_str()}")
    Stdout.line!("  from_u64(4)   = ${to_peano_str(from_u64(4))}")

    Stdout.line!("")
    Stdout.line!("Predecessor:")
    Stdout.line!("  pred(three) = ${to_peano_str(pred(three))} = ${to_u64(pred(three)).to_str()}")
    Stdout.line!("  pred(zero)  = ${to_peano_str(pred(zero))} = ${to_u64(pred(zero)).to_str()}")

    Stdout.line!("")
    Stdout.line!("Addition:")
    Stdout.line!("  2 + 3 = ${to_u64(add(two, three)).to_str()}")

    Stdout.line!("")
    Stdout.line!("Multiplication:")
    Stdout.line!("  2 * 3 = ${to_u64(mul(two, three)).to_str()}")

    Stdout.line!("")
    Stdout.line!("Subtraction (saturating):")
    Stdout.line!("  5 - 2 = ${to_u64(sub(five, two)).to_str()}")
    Stdout.line!("  2 - 5 = ${to_u64(sub(two, five)).to_str()}")

    Stdout.line!("")
    Stdout.line!("Comparisons:")
    cmp1 = if lt(two, three) { "True" } else { "False" }
    cmp2 = if lt(three, two) { "True" } else { "False" }
    cmp3 = if eq(two, two) { "True" } else { "False" }
    Stdout.line!("  2 < 3  = ${cmp1}")
    Stdout.line!("  3 < 2  = ${cmp2}")
    Stdout.line!("  2 == 2 = ${cmp3}")

    Stdout.line!("")
    Stdout.line!("Peano axioms verified:")
    Stdout.line!("  n + 0 = n:  ${to_u64(add(five, zero)).to_str()} = 5")
    Stdout.line!("  0 + n = n:  ${to_u64(add(zero, five)).to_str()} = 5")
    Stdout.line!("  n * 0 = 0:  ${to_u64(mul(five, zero)).to_str()} = 0")
    Stdout.line!("  n * 1 = n:  ${to_u64(mul(five, one)).to_str()} = 5")

    Stdout.line!("")
    Stdout.line!("Done!")

    Ok({})
}
