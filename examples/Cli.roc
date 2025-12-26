app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

## A simple CLI argument parsing demonstration.
##
## Run with:
##   roc examples/Cli.roc -- --help
##   roc examples/Cli.roc -- init myproject
##   roc examples/Cli.roc -- init myproject --force
##   roc examples/Cli.roc -- build --release -v
##   roc examples/Cli.roc -- run script.roc --watch

# ============================================================================
# Types (defined first to avoid forward reference issues)
# ============================================================================

ArgDef : {
    name : Str,
    description : Str,
    required : Bool,
}

FlagDef : {
    long : Str,
    short : Str,
    description : Str,
    takes_value : Bool,
}

# For recursive Command type, we use a simple record without self-reference
# Each command stores subcommands as a flat list structure
CommandData : {
    name : Str,
    description : Str,
    args : List(ArgDef),
    flags : List(FlagDef),
}

ParsedArgs : {
    command_path : List(Str),
    args : List({ name : Str, value : Str }),
    flags : List({ name : Str, value : Str }),
    positional : List(Str),
    errors : List(Str),
}

# ============================================================================
# Main Demo
# ============================================================================

main! = |args| {
    # Build the CLI structure - main command and subcommands as separate lists
    main_cmd : CommandData
    main_cmd = {
        name: "myapp",
        description: "A demo CLI application",
        args: [],
        flags: [],
    }

    init_cmd : CommandData
    init_cmd = {
        name: "init",
        description: "Initialize a new project",
        args: [{ name: "name", description: "Project name", required: True }],
        flags: [
            { long: "force", short: "f", description: "Force initialization", takes_value: False },
            { long: "template", short: "t", description: "Template to use", takes_value: True },
        ],
    }

    build_cmd : CommandData
    build_cmd = {
        name: "build",
        description: "Build the project",
        args: [],
        flags: [
            { long: "release", short: "r", description: "Build in release mode", takes_value: False },
            { long: "verbose", short: "v", description: "Verbose output", takes_value: False },
            { long: "output", short: "o", description: "Output directory", takes_value: True },
        ],
    }

    run_cmd : CommandData
    run_cmd = {
        name: "run",
        description: "Run a script",
        args: [{ name: "file", description: "Script file to run", required: True }],
        flags: [
            { long: "watch", short: "w", description: "Watch for changes", takes_value: False },
        ],
    }

    subcommands : List(CommandData)
    subcommands = [init_cmd, build_cmd, run_cmd]

    # Check for --help
    help_requested = has_help_arg(args)
    if help_requested {
        Stdout.line!(build_help(main_cmd, subcommands))
        return Ok({})
    } else {
        {}
    }

    # Parse arguments
    parsed = parse(main_cmd, subcommands, args)

    # Check for errors
    has_errors = List.len(parsed.errors) > 0
    if has_errors {
        for err in parsed.errors {
            Stdout.line!("Error: ${err}")
        }
        Stdout.line!("")
        Stdout.line!(build_help(main_cmd, subcommands))
        return Err(Exit(1))
    } else {
        {}
    }

    # Handle based on subcommand
    subcmd = get_subcommand(parsed)
    if subcmd == Some("init") {
        handle_init!(parsed)
    } else if subcmd == Some("build") {
        handle_build!(parsed)
    } else if subcmd == Some("run") {
        handle_run!(parsed)
    } else {
        match subcmd {
            Some(other) => {
                Stdout.line!("Unknown subcommand: ${other}")
                Err(Exit(1))
            }
            None => {
                Stdout.line!("No subcommand provided. Use --help for usage.")
                Ok({})
            }
        }
    }
}

# ============================================================================
# Parsing
# ============================================================================

parse : CommandData, List(CommandData), List(Str) -> ParsedArgs
parse = |cmd, subcommands, raw_args| {
    args_to_parse = skip_program_name(raw_args)
    do_parse(cmd, subcommands, args_to_parse)
}

skip_program_name : List(Str) -> List(Str)
skip_program_name = |args| {
    match List.first(args) {
        Ok(first) => {
            is_path = Str.contains(first, "/") or Str.contains(first, "\\")
            if is_path { List.drop_first(args, 1) } else { args }
        }
        Err(_) => args
    }
}

do_parse : CommandData, List(CommandData), List(Str) -> ParsedArgs
do_parse = |cmd, subcommands, args| {
    var $cmd_path = [cmd.name]
    var $parsed_args = []
    var $parsed_flags = []
    var $positional = []
    var $errors = []
    var $arg_idx = 0u64
    var $i = 0u64
    var $skip_next = False
    var $current_cmd = cmd
    var $current_subcommands = subcommands

    total = List.len(args)

    while $i < total {
        if $skip_next {
            $skip_next = False
            $i = $i + 1
        } else {
            match List.get(args, $i) {
                Ok(current_arg) => {
                    is_long_flag = Str.starts_with(current_arg, "--")
                    is_short_flag = Str.starts_with(current_arg, "-") and Str.count_utf8_bytes(current_arg) > 1

                    if is_long_flag {
                        # Long flag
                        flag_part = Str.drop_prefix(current_arg, "--")
                        # Check for --flag=value syntax
                        has_equals = Str.contains(flag_part, "=")
                        if has_equals {
                            parts = Str.split_on(flag_part, "=")
                            flag_name = match List.get(parts, 0) {
                                Ok(n) => n
                                Err(_) => flag_part
                            }
                            flag_val = match List.get(parts, 1) {
                                Ok(v) => v
                                Err(_) => ""
                            }
                            $parsed_flags = List.append($parsed_flags, { name: flag_name, value: flag_val })
                        } else {
                            flag_takes = takes_value($current_cmd.flags, flag_part)
                            if flag_takes {
                                match List.get(args, $i + 1) {
                                    Ok(next_val) => {
                                        $parsed_flags = List.append($parsed_flags, { name: flag_part, value: next_val })
                                        $skip_next = True
                                    }
                                    Err(_) => {
                                        $parsed_flags = List.append($parsed_flags, { name: flag_part, value: "" })
                                    }
                                }
                            } else {
                                $parsed_flags = List.append($parsed_flags, { name: flag_part, value: "" })
                            }
                        }
                        $i = $i + 1
                    } else if is_short_flag {
                        # Short flag
                        flag_chars = Str.drop_prefix(current_arg, "-")
                        long_name = short_to_long($current_cmd.flags, flag_chars)
                        flag_takes = takes_value($current_cmd.flags, long_name)
                        if flag_takes {
                            match List.get(args, $i + 1) {
                                Ok(next_val) => {
                                    $parsed_flags = List.append($parsed_flags, { name: long_name, value: next_val })
                                    $skip_next = True
                                }
                                Err(_) => {
                                    $parsed_flags = List.append($parsed_flags, { name: long_name, value: "" })
                                }
                            }
                        } else {
                            # Could be combined flags like -abc
                            chars = Str.to_utf8(flag_chars)
                            for char_byte in chars {
                                char_str = match Str.from_utf8([char_byte]) {
                                    Ok(s) => s
                                    Err(_) => ""
                                }
                                ln = short_to_long($current_cmd.flags, char_str)
                                $parsed_flags = List.append($parsed_flags, { name: ln, value: "" })
                            }
                        }
                        $i = $i + 1
                    } else {
                        # Check for subcommand
                        subcmd_result = find_subcommand($current_subcommands, current_arg)
                        match subcmd_result {
                            Some(subcmd) => {
                                $cmd_path = List.append($cmd_path, subcmd.name)
                                $current_cmd = subcmd
                                $current_subcommands = []
                                $arg_idx = 0u64
                            }
                            None => {
                                # Positional argument
                                arg_count = List.len($current_cmd.args)
                                if $arg_idx < arg_count {
                                    match List.get($current_cmd.args, $arg_idx) {
                                        Ok(arg_def) => {
                                            $parsed_args = List.append($parsed_args, { name: arg_def.name, value: current_arg })
                                            $arg_idx = $arg_idx + 1
                                        }
                                        Err(_) => {
                                            $positional = List.append($positional, current_arg)
                                        }
                                    }
                                } else {
                                    $positional = List.append($positional, current_arg)
                                }
                            }
                        }
                        $i = $i + 1
                    }
                }
                Err(_) => {
                    $i = $i + 1
                }
            }
        }
    }

    # Check for missing required args
    total_args = List.len($current_cmd.args)
    while $arg_idx < total_args {
        match List.get($current_cmd.args, $arg_idx) {
            Ok(arg_def) => {
                if arg_def.required {
                    $errors = List.append($errors, "Missing required argument: ${arg_def.name}")
                } else {
                    {}
                }
            }
            Err(_) => {}
        }
        $arg_idx = $arg_idx + 1
    }

    {
        command_path: $cmd_path,
        args: $parsed_args,
        flags: $parsed_flags,
        positional: $positional,
        errors: $errors,
    }
}

find_subcommand : List(CommandData), Str -> [Some(CommandData), None]
find_subcommand = |subcommands, name| {
    var $result = None
    for subcmd in subcommands {
        if subcmd.name == name {
            $result = Some(subcmd)
        } else {
            {}
        }
    }
    $result
}

takes_value : List(FlagDef), Str -> Bool
takes_value = |flags, long_name| {
    var $result = False
    for f in flags {
        if f.long == long_name and f.takes_value {
            $result = True
        } else {
            {}
        }
    }
    $result
}

short_to_long : List(FlagDef), Str -> Str
short_to_long = |flags, short_name| {
    var $result = short_name
    for f in flags {
        if f.short == short_name {
            $result = f.long
        } else {
            {}
        }
    }
    $result
}

# ============================================================================
# Accessors
# ============================================================================

get_subcommand : ParsedArgs -> [Some(Str), None]
get_subcommand = |parsed| {
    path_len = List.len(parsed.command_path)
    if path_len > 1 {
        match List.last(parsed.command_path) {
            Ok(last) => Some(last)
            Err(_) => None
        }
    } else {
        None
    }
}

get_arg : ParsedArgs, Str -> [Some(Str), None]
get_arg = |parsed, name| {
    var $result = None
    for a in parsed.args {
        if a.name == name {
            $result = Some(a.value)
        } else {
            {}
        }
    }
    $result
}

has_flag : ParsedArgs, Str -> Bool
has_flag = |parsed, name| {
    var $result = False
    for f in parsed.flags {
        if f.name == name {
            $result = True
        } else {
            {}
        }
    }
    $result
}

get_flag_value : ParsedArgs, Str -> [Some(Str), None]
get_flag_value = |parsed, name| {
    var $result = None
    for f in parsed.flags {
        has_value = Str.is_empty(f.value) == False
        if f.name == name and has_value {
            $result = Some(f.value)
        } else {
            {}
        }
    }
    $result
}

# ============================================================================
# Help Text
# ============================================================================

build_help : CommandData, List(CommandData) -> Str
build_help = |cmd, subcommands| {
    var $lines = []

    $lines = List.append($lines, "${cmd.name} - ${cmd.description}")
    $lines = List.append($lines, "")

    # Subcommands
    has_subcommands = List.len(subcommands) > 0
    if has_subcommands {
        $lines = List.append($lines, "SUBCOMMANDS:")
        for subcmd in subcommands {
            $lines = List.append($lines, "    ${subcmd.name}    ${subcmd.description}")
        }
        $lines = List.append($lines, "")
    } else {
        {}
    }

    # Arguments
    has_args = List.len(cmd.args) > 0
    if has_args {
        $lines = List.append($lines, "ARGUMENTS:")
        for a in cmd.args {
            req = if a.required { "(required)" } else { "(optional)" }
            $lines = List.append($lines, "    <${a.name}> ${req}    ${a.description}")
        }
        $lines = List.append($lines, "")
    } else {
        {}
    }

    # Flags
    has_flags = List.len(cmd.flags) > 0
    if has_flags {
        $lines = List.append($lines, "FLAGS:")
        for f in cmd.flags {
            short_part = if Str.is_empty(f.short) { "    " } else { "-${f.short}, " }
            $lines = List.append($lines, "    ${short_part}--${f.long}    ${f.description}")
        }
    } else {
        {}
    }

    Str.join_with($lines, "\n")
}

# ============================================================================
# Helpers
# ============================================================================

has_help_arg : List(Str) -> Bool
has_help_arg = |args| {
    var $found = False
    for a in args {
        is_help = a == "--help" or a == "-h"
        if is_help {
            $found = True
        } else {
            {}
        }
    }
    $found
}

# ============================================================================
# Command Handlers
# ============================================================================

handle_init! : ParsedArgs => Try({}, [Exit(I32)])
handle_init! = |parsed| {
    Stdout.line!("=== INIT Command ===")

    name_result = get_arg(parsed, "name")
    has_name = match name_result {
        Some(_) => True
        None => False
    }

    if has_name {
        name = match name_result {
            Some(n) => n
            None => ""
        }
        Stdout.line!("Initializing project: ${name}")

        force_set = has_flag(parsed, "force")
        if force_set {
            Stdout.line!("  --force flag set")
        } else {
            {}
        }

        Stdout.line!("Done!")
        Ok({})
    } else {
        Stdout.line!("Error: Project name required")
        Err(Exit(1))
    }
}

handle_build! : ParsedArgs => Try({}, [Exit(I32)])
handle_build! = |parsed| {
    Stdout.line!("=== BUILD Command ===")

    is_release = has_flag(parsed, "release")
    mode = if is_release { "release" } else { "debug" }
    Stdout.line!("Building in ${mode} mode...")

    is_verbose = has_flag(parsed, "verbose")
    if is_verbose {
        Stdout.line!("  [verbose] Compiling...")
        Stdout.line!("  [verbose] Linking...")
    } else {
        {}
    }

    Stdout.line!("  Output: ./build")
    Stdout.line!("Build complete!")
    Ok({})
}

handle_run! : ParsedArgs => Try({}, [Exit(I32)])
handle_run! = |parsed| {
    Stdout.line!("=== RUN Command ===")

    file_result = get_arg(parsed, "file")
    has_file = match file_result {
        Some(_) => True
        None => False
    }

    if has_file {
        file = match file_result {
            Some(f) => f
            None => ""
        }
        Stdout.line!("Running: ${file}")

        watch_mode = has_flag(parsed, "watch")
        if watch_mode {
            Stdout.line!("  Watch mode enabled")
        } else {
            {}
        }

        Stdout.line!("Execution complete!")
        Ok({})
    } else {
        Stdout.line!("Error: Script file required")
        Err(Exit(1))
    }
}
