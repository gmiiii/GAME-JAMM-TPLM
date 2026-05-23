extends Node

# ============================================================
# SUMBER TUNGGAL semua angka tunable. Ubah di sini, bukan di logika.
# Koordinat 3D: X = lane (kiri-kanan), Z = maju (endless), Y = atas.
# ============================================================

# --- Layout jalan ---
const LANE_W: float = 3.0              # lebar 1 lane (meter)
const DRIVE_LANES: int = 6             # jumlah lane jalan
const TOTAL_COLS: int = 8              # 6 lane + 2 bahu
# Index kolom: 0 = bahu kiri, 1..6 = lane jalan, 7 = bahu kanan
const LEFT_SHOULDER: int = 0
const RIGHT_SHOULDER: int = 7
const FIRST_LANE: int = 1
const LAST_LANE: int = 6
const PLAYER_START_COL: int = 3
# Lane 1..3 searah pemain, 4..6 berlawanan (oncoming)
const ONCOMING_FROM_LANE: int = 4

# --- Treadmill / kecepatan maju ---
const CRUISE_SPEED: float = 16.0       # kecepatan BASE (default & lantai rem)
const MAX_SPEED: float = 28.0          # gas penuh
const ACCEL: float = 14.0              # laju naik kecepatan
const BRAKE_DECEL: float = 26.0        # laju turun saat rem (hanya sampai base)

# --- Road chunk ---
const CHUNK_LEN: float = 6.0
const CHUNK_AHEAD: int = 16
const CHUNK_BEHIND: int = 4

# --- Pemain ---
const PLAYER_Z: float = 0.0            # posisi maju tetap (treadmill)
const HOP_LERP: float = 14.0           # kehalusan geser antar-lane

# --- Traffic ---
const TRAFFIC_SPAWN_MIN: float = 0.6
const TRAFFIC_SPAWN_MAX: float = 1.6
const TRAFFIC_SPAWN_Z: float = -90.0
const TRAFFIC_DESPAWN_Z: float = 22.0
const TRAFFIC_OWN_SPEED_MIN: float = 4.0
const TRAFFIC_OWN_SPEED_MAX: float = 8.0
const CARS := {
	"family":  {"size": Vector3(2.2, 1.4, 4.4), "color": Color("e8e8e8")},
	"formula": {"size": Vector3(2.0, 1.0, 5.0), "color": Color("d23b3b")},
	"truck":   {"size": Vector3(2.6, 2.6, 7.0), "color": Color("3b6fd2")},
	"fancy":   {"size": Vector3(2.2, 1.5, 4.6), "color": Color("1c1c1c")},
}
const CAR_KEYS := ["family", "formula", "truck", "fancy"]

# --- Ayam ---
const CHICKEN_SPEED_START: float = 11.0
const CHICKEN_SPEED_MAX: float = 20.0
const CHICKEN_SPAWN_MIN: float = 2.0
const CHICKEN_SPAWN_MAX: float = 4.0
const CHICKEN_MAX_ALIVE: int = 3
const CHICKEN_RESPAWN_DELAY: float = 1.5
const CHICKEN_TICK: float = 0.25           # interval re-plan pathfinding (A*)
const CHICKEN_RANDOM_CHANCE: float = 0.18  # peluang langkah acak/nekat (abaikan bahaya -> bisa ketabrak)
const CHICKEN_DANGER_Z: float = 3.5        # margin bahaya di sekitar mobil (untuk blokir sel)
const CHICKEN_DESPAWN_Z: float = 24.0      # tertinggal di belakang -> hilang
const CHICKEN_CELL_Z: float = 3.0          # ukuran sel grid arah Z
# Posisi spawn acak: samping (bahu), depan (jauh, dlm area render), belakang pemain
const CHICKEN_FRONT_Z_MIN: float = -75.0   # depan terjauh (masih ter-render)
const CHICKEN_FRONT_Z_MAX: float = -38.0
const CHICKEN_BEHIND_Z_MIN: float = 6.0
const CHICKEN_BEHIND_Z_MAX: float = 14.0
const CHICKEN_SIDE_Z_MIN: float = -12.0
const CHICKEN_SIDE_Z_MAX: float = 2.0
const CHICKEN_SPAWN_CLEAR: float = 3.0     # radius wajib bebas mobil saat spawn

# --- Eskalasi kesulitan ---
const ESCALATE_EVERY: float = 200.0    # tiap N meter, kesulitan naik 1 langkah
const SCROLL_BONUS_PER_STEP: float = 1.5
const CHICKEN_SPEED_BONUS_PER_STEP: float = 0.6

# --- Warna placeholder ---
const COL_GRASS := Color("4a8a3a")
const COL_ROAD := Color("3a3a40")
const COL_SHOULDER := Color("8a8a6a")
const COL_LINE := Color("e8e860")
const COL_PLAYER := Color("ffd23b")
const COL_CHICKEN := Color("fafafa")
const COL_COMB := Color("d23b3b")
const COL_BEAK := Color("e8a020")
const COL_SKY := Color("8fd0ff")

# --- Koreksi arah hadap model FBX (derajat, sesuaikan bila model menghadap salah) ---
const MODEL_YAW_CAR: float = 180.0
const MODEL_YAW_CHICKEN: float = 180.0

# --- Kamera (gaya Crossy Road: ortografik, sudut tinggi & statis) ---
const CAM_ORTHOGRAPHIC: bool = true
const CAM_POSITION := Vector3(-16, 28, 16)   # belakang-kiri-atas
const CAM_LOOK_AT := Vector3(0, 1, -8)
const CAM_ORTHO_SIZE: float = 24.0           # kecil = lebih zoom-in
const CAM_FOV: float = 55.0                   # dipakai bila ortografik = false


func _ready() -> void:
	_register_input()


func _register_input() -> void:
	_add_action("gas", [KEY_W, KEY_UP])
	_add_action("brake", [KEY_S, KEY_DOWN])
	_add_action("lane_left", [KEY_A, KEY_LEFT])
	_add_action("lane_right", [KEY_D, KEY_RIGHT])
	_add_action("restart", [KEY_R, KEY_ENTER, KEY_SPACE])


func _add_action(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
