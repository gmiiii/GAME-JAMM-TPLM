class_name GridUtils
extends RefCounted

# Konversi index kolom -> posisi X dunia (3D).
# Kolom 0..7 (0 = bahu kiri, 7 = bahu kanan), dipusatkan di X=0.

static func col_x(col: int) -> float:
	return (float(col) - float(GameConfig.TOTAL_COLS - 1) / 2.0) * GameConfig.LANE_W


static func x_to_col(x: float) -> int:
	return int(round(x / GameConfig.LANE_W + float(GameConfig.TOTAL_COLS - 1) / 2.0))


static func is_drive_lane(col: int) -> bool:
	return col >= GameConfig.FIRST_LANE and col <= GameConfig.LAST_LANE


static func is_oncoming(col: int) -> bool:
	return col >= GameConfig.ONCOMING_FROM_LANE
