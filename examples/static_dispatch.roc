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

    Ok({})
}

describe_all! : List(val) => {} where [val.describe : val -> Str]
describe_all! = |items| {
    for item in items {
        Stdout.line!(item.describe())
    }
}
