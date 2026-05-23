extends Node3D

# Spawn mobil traffic di lane acak dengan jeda acak.

var _scene: PackedScene
var _timer: float = 0.0
var _next: float = 1.0


func setup(scene: PackedScene) -> void:
	_scene = scene
	_next = randf_range(GameConfig.TRAFFIC_SPAWN_MIN, GameConfig.TRAFFIC_SPAWN_MAX)


func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
	_timer += delta
	if _timer >= _next:
		_timer = 0.0
		_next = randf_range(GameConfig.TRAFFIC_SPAWN_MIN, GameConfig.TRAFFIC_SPAWN_MAX)
		_spawn()


func _spawn() -> void:
	var lane := randi_range(GameConfig.FIRST_LANE, GameConfig.LAST_LANE)
	var key: String = GameConfig.CAR_KEYS[randi() % GameConfig.CAR_KEYS.size()]
	var car = _scene.instantiate()
	car.setup(key, lane)
	add_child(car)
