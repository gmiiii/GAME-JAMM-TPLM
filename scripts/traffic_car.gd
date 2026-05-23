extends Area3D

# Mobil lain di jalan. Bergerak +Z (ke arah kamera) di frame pemain.
# Searah  -> net = scroll - own (pemain menyalip perlahan)
# Lawan   -> net = scroll + own (mendekat cepat)

const CarModel := preload("res://assets/models/vehicles/Car.FBX")
const TruckModel := preload("res://assets/models/vehicles/Truck.FBX")

var own_speed: float = 6.0
var oncoming: bool = false
var length: float = 4.0                 # panjang (Z), dipakai logika ayam


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
	position.z += net * delta
	if position.z > GameConfig.TRAFFIC_DESPAWN_Z:
		queue_free()
