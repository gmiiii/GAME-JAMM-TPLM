extends Node
## Sumber tunggal seluruh angka & warna yang bisa di-tuning.
## Ubah nilai di sini untuk menyesuaikan kesulitan/tata letak tanpa menyentuh logika.

# --- Grid ---
const CELL: int = 48               # ukuran satu blok grid (px)
const GRID_COLS: int = 18          # lebar field dalam sel
const GRID_ROWS: int = 7           # tinggi field: baris 0 rumput, 1..5 lane, 6 rumput

# --- Ayam ---
const CHICKEN_TICK: float = 0.6    # detik per langkah ayam (tunable)

# --- Pemain ---
const PLAYER_W: int = 2            # lebar mobil pemain (sel)
const PLAYER_SPAWN_COL: int = 0
const PLAYER_SPAWN_ROW: int = 3
const PLAYER_RESPAWN_COL: int = 8  # kolom tengah saat respawn setelah menyeberang
const SPAWN_GRACE: float = 0.6     # detik kebal tabrakan bot saat spawn/respawn (set 0 utk mode ketat)

# --- Ayam spawn ---
const CHICKEN_SPAWN_COL: int = 4

# --- Lane: row = baris grid, dir = +1 (ke kanan) / -1 (ke kiri) ---
const LANES: Array = [
	{ "row": 1, "dir": 1 },
	{ "row": 2, "dir": 1 },
	{ "row": 3, "dir": -1 },
	{ "row": 4, "dir": -1 },
	{ "row": 5, "dir": -1 },
]

# Tipe mobil yang boleh muncul di tiap lane (paralel dengan LANES).
const LANE_CARS: Array = [
	["family", "fancy"],
	["formula", "fancy"],
	["truck", "family"],
	["family", "fancy"],
	["formula", "truck"],
]

# Definisi tiap tipe mobil bot: w = lebar (sel), speed = px/detik, color = placeholder.
const CARS: Dictionary = {
	"family":  { "w": 2, "speed": 120.0, "color": Color("e8e8e8") },  # MPV putih
	"formula": { "w": 3, "speed": 210.0, "color": Color("d23b3b") },  # merah, cepat
	"truck":   { "w": 4, "speed": 105.0, "color": Color("3b6fd2") },  # truk biru
	"fancy":   { "w": 2, "speed": 140.0, "color": Color("1c1c1c") },  # sedan hitam
}

# Jarak antar kendaraan (sel) saat dibangkitkan/di-recycle agar pemain bisa lewat.
const CAR_GAP_MIN: int = 3
const CAR_GAP_MAX: int = 6

# --- Warna placeholder ---
const COLOR_GRASS: Color = Color("5a8f3c")
const COLOR_GRASS_DARK: Color = Color("4f7e35")
const COLOR_ROAD: Color = Color("33363b")
const COLOR_ROAD_LINE: Color = Color("c8c84066")
const COLOR_PLAYER: Color = Color("f2c12e")
const COLOR_PLAYER_DARK: Color = Color("c79a18")
const COLOR_CHICKEN: Color = Color("fafafa")
const COLOR_CHICKEN_BEAK: Color = Color("f5a623")
const COLOR_CHICKEN_COMB: Color = Color("d23b3b")
const COLOR_TREE: Color = Color("2f6b2f")
const COLOR_ROCK: Color = Color("8a8a8a")
const COLOR_CONE: Color = Color("ff7a1a")

# --- Turunan ---
static func field_width_px() -> int:
	return GRID_COLS * CELL

static func field_height_px() -> int:
	return GRID_ROWS * CELL


func _ready() -> void:
	_register_input()


func _register_input() -> void:
	_add_action("move_up", [KEY_UP, KEY_W])
	_add_action("move_down", [KEY_DOWN, KEY_S])
	_add_action("move_left", [KEY_LEFT, KEY_A])
	_add_action("move_right", [KEY_RIGHT, KEY_D])
	_add_action("restart", [KEY_R, KEY_ENTER, KEY_SPACE])


func _add_action(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
