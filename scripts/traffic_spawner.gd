extends Node3D

# Spawn mobil traffic di lane acak dengan jeda acak (makin rapat seiring kesulitan).
# Tidak spawn bila titik spawn di lane itu masih terisi (cegah tumpukan/tembus).

var _scene: PackedScene
var _timer: float = 0.0
var _next: float = 1.0


func setup(scene: PackedScene) -> void:
	_scene = scene
	_next = _roll_interval()


func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
	_timer += delta
	if _timer >= _next:
		_timer = 0.0
		_next = _roll_interval()
		_spawn()


func _roll_interval() -> float:
	return randf_range(GameConfig.TRAFFIC_SPAWN_MIN, GameConfig.TRAFFIC_SPAWN_MAX) \
		* GameState.spawn_interval_mult()


func _spawn() -> void:
	var lane := randi_range(GameConfig.FIRST_LANE, GameConfig.LAST_LANE)
	if not _spawn_clear(lane):
		return                              # lane padat di titik spawn -> tunda
	var key: String = GameConfig.CAR_KEYS[randi() % GameConfig.CAR_KEYS.size()]
	var car = _scene.instantiate()
	car.setup(key, lane)
	add_child(car)


func _spawn_clear(lane: int) -> bool:
	var lx := GridUtils.col_x(lane)
	for c in get_tree().get_nodes_in_group("traffic"):
		if absf(c.position.x - lx) > GameConfig.LANE_W * 0.5:
			continue
		if absf(c.position.z - GameConfig.TRAFFIC_SPAWN_Z) < GameConfig.TRAFFIC_SPAWN_CLEAR:
			return false
	return true
