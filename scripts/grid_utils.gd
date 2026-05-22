class_name GridUtils
extends RefCounted
## Helper grid statis dipakai bersama oleh pemain & ayam (konversi koordinat + cek sel).

## Koordinat dunia sudut kiri-atas sebuah sel.
static func cell_to_world(col: int, row: int) -> Vector2:
	return Vector2(col * GameConfig.CELL, row * GameConfig.CELL)


static func col_in_bounds(col: int) -> bool:
	return col >= 0 and col < GameConfig.GRID_COLS


static func row_in_bounds(row: int) -> bool:
	return row >= 0 and row < GameConfig.GRID_ROWS


static func is_blocked(col: int, row: int) -> bool:
	return GameState.blocked_cells.has(Vector2i(col, row))


## Sel bebas untuk ditempati (di dalam field & tidak ada obstacle).
static func cell_free(col: int, row: int) -> bool:
	return col_in_bounds(col) and row_in_bounds(row) and not is_blocked(col, row)
