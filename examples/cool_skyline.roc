app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Random

# Render a simple procedural "skyline" using deterministic pseudo-random widths/heights.
print_skyline! : U64 => {}
print_skyline! = |seed| {
	# Tiny LCG for repeatable pseudo-randomness without extra imports.
	step = |s| {
		# Keep values small to avoid integer overflow in multiplication.
		s_mod = s % 2147483648u64
		(1103515245u64 * s_mod + 12345u64) % 2147483648u64
	}

	width = 42u64
	sky_height = 5u64
	building_height = 8u64
	total_height = sky_height + building_height

	moon_col = seed % width
	moon_row = seed % sky_height

	height_at = |col| {
		var $i = 0u64
		var $s = seed

		while $i < col {
			$s = step($s)
			$i = $i + 1u64
		}

		if ($s % 7u64) == 0u64 {
			0u64
		} else {
			($s % building_height) + 1u64
		}
	}

	cell_rand = |row, col| {
		base = seed % 2147483648u64
		row_term = (row * 131u64) % 2147483648u64
		col_term = (col * 977u64) % 2147483648u64
		step((base + row_term + col_term) % 2147483648u64)
	}

	var $row = 0u64

	while $row < total_height {
		var $col = 0u64
		var $line = ""
		is_sky = $row < sky_height

		while $col < width {
			rand = cell_rand($row, $col)
			is_star = is_sky and ((rand % 13u64) == 0u64)
			is_moon = is_sky and ($row == moon_row) and ($col == moon_col)
			col_height = height_at($col)
			is_building =
				if is_sky {
					Bool.False
				} else {
					building_row = $row - sky_height
					(col_height > 0u64) and (building_row >= (building_height - col_height))
				}
			is_window = is_building and ((rand % 7u64) == 0u64)
			char =
				if is_moon {
					"o"
				} else if is_star {
					"*"
				} else if is_window {
					"."
				} else if is_building {
					"█"
				} else {
					" "
				}

			$line = Str.concat($line, char)
			$col = $col + 1u64
		}

		Stdout.line!($line)
		$row = $row + 1u64
	}
}

main! = |_args| {
	seed = Random.seed_u64!({})
	Stdout.line!("Procedural skyline:")
	print_skyline!(seed)

	Ok({})
}
