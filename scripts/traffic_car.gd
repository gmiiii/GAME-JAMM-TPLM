extends Area3D

# Mobil lain di jalan. Bergerak +Z (ke arah kamera) di frame pemain.
# Searah  -> net = scroll - own (pemain menyalip perlahan)
# Lawan   -> net = scroll + own (mendekat cepat)

var own_speed: float = 6.0
var oncoming: bool = false
var length: float = 4.0                 # panjang (Z), dipakai logika ayam


func setup(type_key: String, lane_col: int) -> void:
	var data: Dictionary = GameConfig.CARS[type_key]
	var size: Vector3 = data["size"]
	length = size.z
	add_child(Build3D.box(size, data["color"]))
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	add_child(cs)
	oncoming = GridUtils.is_oncoming(lane_col)
	own_speed = randf_range(GameConfig.TRAFFIC_OWN_SPEED_MIN, GameConfig.TRAFFIC_OWN_SPEED_MAX)
	position = Vector3(GridUtils.col_x(lane_col), size.y * 0.5, GameConfig.TRAFFIC_SPAWN_Z)
	if oncoming:
		rotation.y = PI


func _ready() -> void:
	add_to_group("traffic")
	collision_layer = 2
	collision_mask = 0


func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
	var net := GameState.scroll_speed + (own_speed if oncoming else -own_speed)
	position.z += net * delta
	if position.z > GameConfig.TRAFFIC_DESPAWN_Z:
		queue_free()
