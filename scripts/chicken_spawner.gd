extends Node3D

# Spawn ayam HANYA di bahu rumput samping (kiri/kanan), di DEPAN pemain
# (boleh sampai area yang belum ter-render). Tidak pernah di belakang pemain,
# tidak pernah di tengah jalan. Jumlah & frekuensi naik seiring kesulitan.

var _scene: PackedScene
var _player: Node3D
var _timer: float = 0.0
var _next: float = 2.0


func setup(scene: PackedScene, player: Node3D) -> void:
	_scene = scene
	_player = player
	_next = _roll_interval()


func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
	if _alive_count() >= _max_alive():
		return
	_timer += delta
	if _timer >= _next:
		_timer = 0.0
		_next = _roll_interval()
		_spawn()


func _roll_interval() -> float:
	return randf_range(GameConfig.CHICKEN_SPAWN_MIN, GameConfig.CHICKEN_SPAWN_MAX) \
		* GameState.spawn_interval_mult()


func _max_alive() -> int:
	var extra := GameState.escalation_step / GameConfig.CHICKEN_EXTRA_PER_STEPS
	return mini(GameConfig.CHICKEN_MAX_ALIVE_CAP, GameConfig.CHICKEN_MAX_ALIVE + extra)


func _alive_count() -> int:
	var n := 0
	for c in get_tree().get_nodes_in_group("chicken"):
		if not c.is_in_group("dead_chicken"):
			n += 1
	return n


func _spawn() -> void:
	var ch = _scene.instantiate()
	ch.set_player(_player)
	var shoulder := GameConfig.LEFT_SHOULDER if randf() < 0.5 else GameConfig.RIGHT_SHOULDER
	var z := randf_range(GameConfig.CHICKEN_SPAWN_Z_FAR, GameConfig.CHICKEN_SPAWN_Z_NEAR)
	ch.position = Vector3(GridUtils.col_x(shoulder), 0.0, z)
	add_child(ch)
