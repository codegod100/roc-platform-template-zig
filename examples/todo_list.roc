app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

# A simple Todo List example demonstrating Roc syntax features

# Tag union for todo item priority
Priority : [Low, Medium, High, Critical]

# Record type for a todo item
TodoItem : { title : Str, priority : Priority, completed : Bool }

# Get a string representation of priority
priority_to_str : Priority -> Str
priority_to_str = |priority| {
    match priority {
        Low => "Low"
        Medium => "Medium"
        High => "High"
        Critical => "Critical"
    }
}

# Get priority as a numeric value for sorting
priority_value : Priority -> U64
priority_value = |priority| {
    match priority {
        Low => 1
        Medium => 2
        High => 3
        Critical => 4
    }
}

# Format a single todo item for display
format_todo : TodoItem -> Str
format_todo = |todo| {
    status = if todo.completed "[x]" else "[ ]"
    priority_str = priority_to_str(todo.priority)
    "${status} ${todo.title} (${priority_str})"
}

# Count completed todos using a for loop with mutable variable
count_completed : List(TodoItem) -> U64
count_completed = |todos| {
    var $count = 0

    for todo in todos {
        if todo.completed {
            $count = $count + 1
        }
    }

    $count
}

# Count todos by priority
count_by_priority : List(TodoItem), Priority -> U64
count_by_priority = |todos, target_priority| {
    var $count = 0

    for todo in todos {
        if priority_value(todo.priority) == priority_value(target_priority) {
            $count = $count + 1
        }
    }

    $count
}

# Calculate total priority score
total_priority_score : List(TodoItem) -> U64
total_priority_score = |todos| {
    var $score = 0

    for todo in todos {
        if !todo.completed {
            $score = $score + priority_value(todo.priority)
        }
    }

    $score
}

# Mark a todo as completed (record update syntax)
complete_todo : TodoItem -> TodoItem
complete_todo = |todo| {
    { ..todo, completed: Bool.True }
}

# Change priority of a todo
set_priority : TodoItem, Priority -> TodoItem
set_priority = |todo, new_priority| {
    { ..todo, priority: new_priority }
}

# Print a todo item
print_todo! : TodoItem => {}
print_todo! = |todo| {
    Stdout.line!(format_todo(todo))
}

# Print all todos with a header
print_todos! : Str, List(TodoItem) => {}
print_todos! = |header, todos| {
    Stdout.line!(header)
    Stdout.line!("─".repeat(40))

    for todo in todos {
        print_todo!(todo)
    }

    Stdout.line!("")
}

# Print statistics about the todo list
print_stats! : List(TodoItem) => {}
print_stats! = |todos| {
    total = List.len(todos)
    completed = count_completed(todos)
    remaining = total - completed
    score = total_priority_score(todos)

    Stdout.line!("📊 Statistics:")
    Stdout.line!("─".repeat(40))
    Stdout.line!("Total tasks:     ${Num.to_str(total)}")
    Stdout.line!("Completed:       ${Num.to_str(completed)}")
    Stdout.line!("Remaining:       ${Num.to_str(remaining)}")
    Stdout.line!("Priority score:  ${Num.to_str(score)} (lower is better!)")
    Stdout.line!("")
}

main! = |_args| {
    # Create some todo items
    todos : List(TodoItem)
    todos = [
        { title: "Learn Roc basics", priority: High, completed: Bool.True },
        { title: "Build a platform", priority: Critical, completed: Bool.False },
        { title: "Write documentation", priority: Medium, completed: Bool.False },
        { title: "Add more examples", priority: Low, completed: Bool.False },
        { title: "Set up CI/CD", priority: High, completed: Bool.True },
    ]

    Stdout.line!("🗒️  Todo List Manager")
    Stdout.line!("═".repeat(40))
    Stdout.line!("")

    # Print all todos
    print_todos!("📋 All Tasks:", todos)

    # Print statistics
    print_stats!(todos)

    # Demonstrate record updates
    Stdout.line!("✨ Demonstrating record updates:")
    Stdout.line!("─".repeat(40))

    original = { title: "Test task", priority: Low, completed: Bool.False }
    Stdout.line!("Original: ${format_todo(original)}")

    updated = complete_todo(original)
    Stdout.line!("After completing: ${format_todo(updated)}")

    with_new_priority = set_priority(original, Critical)
    Stdout.line!("With new priority: ${format_todo(with_new_priority)}")

    Stdout.line!("")

    # Demonstrate pattern matching on priority
    Stdout.line!("🎯 Priority breakdown:")
    Stdout.line!("─".repeat(40))

    for priority in [Low, Medium, High, Critical] {
        count = count_by_priority(todos, priority)
        label = priority_to_str(priority)
        Stdout.line!("${label}: ${Num.to_str(count)} task(s)")
    }

    Ok({})
}

# Tests using expect
expect priority_value(Low) == 1
expect priority_value(Critical) == 4
expect priority_to_str(High) == "High"

expect {
    todo = { title: "Test", priority: Medium, completed: Bool.False }
    completed = complete_todo(todo)
    completed.completed == Bool.True
}

expect {
    todos = [
        { title: "A", priority: Low, completed: Bool.True },
        { title: "B", priority: High, completed: Bool.False },
    ]
    count_completed(todos) == 1
}
