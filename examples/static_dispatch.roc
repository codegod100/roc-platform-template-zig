app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

# Demonstrate Roc's static dispatch by attaching method implementations
# directly to nominal and record types.

Vec2 := [Vec2(F64, F64)].{
    length_squared = |self| match self {
        Vec2(x, y) => x * x + y * y
    }

    dot = |self, other| match (self, other) {
        (Vec2(ax, ay), Vec2(bx, by)) => ax * bx + ay * by
    }

    describe = |self| match self {
        Vec2(x, y) => "Vec2(${x.to_str()}, ${y.to_str()})"
    }
}

Shape := [Circle(F64), Rectangle(F64, F64)].{
    describe = |shape| match shape {
        Circle(radius) => "Circle(radius: ${radius.to_str()})"
        Rectangle(width, height) => "Rectangle(${width.to_str()}×${height.to_str()})"
    }
}

# Static dispatch also works when you wrap records in tag unions.
Material := [Material(Str, F64)].{
    describe = |self| match self {
        Material(name, density) => "${name} @ ${density.to_str()} g/cm^3"
    }
}

Person := [Person(Str, Str, U64)].{
    full_name = |self| match self {
        Person(first, last, _) => "${first} ${last}"
    }

    is_adult = |self| match self {
        Person(_, _, age) => age >= 18
    }

    greet = |self| match self {
        Person(first, _, _) => "Hello, ${first}!"
    }

    describe = |self| match self {
        Person(first, last, age) => "Person: ${first} ${last}, age ${age.to_str()}"
    }
}

Counter := [CounterVal(I64)].{
    increment = |self| match self {
        CounterVal(n) => CounterVal(n + 1)
    }

    decrement = |self| match self {
        CounterVal(n) => CounterVal(n - 1)
    }

    reset = |_self| CounterVal(0)

    value = |self| match self {
        CounterVal(n) => n
    }

    describe = |self| match self {
        CounterVal(n) => "Counter: ${n.to_str()}"
    }
}

Color := [Rgb(U8, U8, U8)].{
    to_hex = |self| match self {
        Rgb(r, g, b) => "#${r.to_str()}${g.to_str()}${b.to_str()}" # Simplified hex representation
    }

    brightness = |self| match self {
        Rgb(r, g, b) => (U8.to_f64(r) + U8.to_f64(g) + U8.to_f64(b)) / 3.0f64
    }

    mix = |self, other| match (self, other) {
        (Rgb(r1, g1, b1), Rgb(r2, g2, b2)) => Rgb((r1 + r2) // 2, (g1 + g2) // 2, (b1 + b2) // 2)
    }

    describe = |self| match self {
        Rgb(r, g, b) => "Color: rgb(${r.to_str()}, ${g.to_str()}, ${b.to_str()})"
    }
}

# Generic helper that requires its argument to expose a describe method.
print_description! : a => {} where [a.describe : a -> Str]
print_description! = |value| Stdout.line!(value.describe())

main! = |_args| {
    steel : Material
    steel = Material("Steel", 7.85f64)

    aluminum : Material
    aluminum = Material("Aluminum", 2.70f64)

    Stdout.line!("=== Materials via static dispatch ===")
    print_description!(steel)
    print_description!(aluminum)

    Stdout.line!("\n=== Shapes via static dispatch ===")
    circle : Shape
    circle = Circle(3.5f64)
    rect : Shape
    rect = Rectangle(4.0f64, 2.0f64)

    Stdout.line!(Shape.describe(circle))
    circle_area_str =
        match circle {
            Circle(radius) => (3.141592653589793f64 * radius * radius).to_str()
            Rectangle(_, _) => "n/a"
        }
    Stdout.line!("Circle area: ${circle_area_str}")

    Stdout.line!(Shape.describe(rect))
    rect_area_str =
        match rect {
            Rectangle(width, height) => (width * height).to_str()
            Circle(_) => "n/a"
        }
    Stdout.line!("Rectangle area: ${rect_area_str}")

    Stdout.line!("\n=== Working with Vec2 methods ===")
    a : Vec2
    a = Vec2(3.0f64, 4.0f64)

    b : Vec2
    b = Vec2(-2.0f64, 5.0f64)

    Stdout.line!(a.describe())
    Stdout.line!(b.describe())
    Stdout.line!("length²(a) = ${a.length_squared().to_str()}")
    Stdout.line!("dot(a, b) = ${a.dot(b).to_str()}")

    Stdout.line!("\n=== Static dispatch + generics ===")
    describe_all!([circle, rect])
    describe_all!([steel, aluminum])

    Stdout.line!("\n=== Persons via static dispatch ===")
    person1 : Person
    person1 = Person("John", "Doe", 25)
    person2 : Person
    person2 = Person("Jane", "Smith", 17)

    print_description!(person1)
    print_description!(person2)
    adult_str = if person1.is_adult() "true" else "false"
    Stdout.line!("${person1.full_name()} is adult: ${adult_str}")
    Stdout.line!(person1.greet())

    Stdout.line!("\n=== Counter via static dispatch ===")
    counter : Counter
    counter = CounterVal(5)
    Stdout.line!(counter.describe())
    new_counter = counter.increment()
    Stdout.line!(Counter.describe(new_counter))
    reset_counter = Counter.reset(new_counter)
    Stdout.line!(Counter.describe(reset_counter))

    Stdout.line!("\n=== Colors via static dispatch ===")
    red : Color
    red = Rgb(255u8, 0u8, 0u8)
    blue : Color
    blue = Rgb(0u8, 0u8, 255u8)

    Stdout.line!(Color.describe(red))
    Stdout.line!(Color.describe(blue))
    mixed = Color.mix(red, blue)
    Stdout.line!(Color.describe(mixed))
    Stdout.line!("Red hex: ${red.to_hex()}")
    Stdout.line!("Red brightness: ${red.brightness().to_str()}")

    Stdout.line!("\n=== More generics ===")
    describe_all!([person1, person2])
    describe_all!([red, blue, mixed])

    Ok({})
}

describe_all! : List(val) => {} where [val.describe : val -> Str]
describe_all! = |items| {
    for item in items {
        Stdout.line!(item.describe())
    }
}
