extends Area3D

# Mobil lain di jalan. Bergerak +Z (ke arah kamera) di frame pemain.
# Searah  -> net = scroll - own (pemain menyalip perlahan)
# Lawan   -> net = scroll + own (mendekat cepat)

const CarModel := preload("res://assets/models/vehicles/Car.FBX")
const TruckModel := preload("res://assets/models/vehicles/Truck.FBX")

var own_speed: float = 6.0
var oncoming: bool = false
var length: float = 4.0                 # panjang (Z), dipakai logika ayam
var _whooshed: bool = false             # whoosh hanya sekali, saat melewati pemain


func setup(type_key: String, lane_col: int) -> void:
	var data: Dictionary = GameConfig.CARS[type_key]
	var size: Vector3 = data["size"]
	length = size.z
	var model_scene: PackedScene = TruckModel if type_key == "truck" else CarModel
	add_child(Build3D.model(model_scene, size.z, GameConfig.MODEL_YAW_CAR))
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	cs.position.y = size.y * 0.5
	add_child(cs)
	oncoming = GridUtils.is_oncoming(lane_col)
	own_speed = randf_range(GameConfig.TRAFFIC_OWN_SPEED_MIN, GameConfig.TRAFFIC_OWN_SPEED_MAX)
	position = Vector3(GridUtils.col_x(lane_col), 0.0, GameConfig.TRAFFIC_SPAWN_Z)
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
	var dz := net * delta
	# Car-following: jangan menembus mobil di depan (selajur). Antre jaga jarak.
	var leader := _leader_ahead()
	if leader != null:
		var gap: float = leader.position.z - position.z - (length + leader.length) * 0.5
		dz = clampf(dz, 0.0, maxf(0.0, gap - GameConfig.TRAFFIC_MIN_GAP))
	position.z += dz
	_try_whoosh()
	if position.z > GameConfig.TRAFFIC_DESPAWN_Z:
		queue_free()


# Bunyi "whoosh" sekali saat mobil melintas dekat pemain (hanya lane sekitar
# pemain agar tidak terlalu ramai).
func _try_whoosh() -> void:
	if _whooshed or position.z < -2.0:
		return
	_whooshed = true
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if absf(global_position.x - player.global_position.x) <= GameConfig.LANE_W * 2.0:
		Audio.play_sfx(Audio.SFX_WHOOSH, randf_range(0.95, 1.1), -10.0)


# Mobil terdekat di depan (+Z) pada lane yang sama.
func _leader_ahead() -> Node3D:
	var best: Node3D = null
	var best_dz := INF
	for c in get_tree().get_nodes_in_group("traffic"):
		if c == self:
			continue
		if absf(c.position.x - position.x) > GameConfig.LANE_W * 0.5:
			continue
		var d: float = c.position.z - position.z
		if d > 0.0 and d < best_dz:
			best_dz = d
			best = c
	return best
