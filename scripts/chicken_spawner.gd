extends Node3D

# Spawn ayam dari 2 bahu jalan, maksimal CHICKEN_MAX_ALIVE hidup sekaligus.

var _scene: PackedScene
var _player: Node3D
var _timer: float = 0.0
var _next: float = 2.0


func setup(scene: PackedScene, player: Node3D) -> void:
	_scene = scene
	_player = player
	_next = randf_range(GameConfig.CHICKEN_SPAWN_MIN, GameConfig.CHICKEN_SPAWN_MAX)


func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
	if _alive_count() >= GameConfig.CHICKEN_MAX_ALIVE:
		return
	_timer += delta
	if _timer >= _next:
		_timer = 0.0
		_next = randf_range(GameConfig.CHICKEN_SPAWN_MIN, GameConfig.CHICKEN_SPAWN_MAX)
		_spawn()


func _alive_count() -> int:
	var n := 0
	for c in get_tree().get_nodes_in_group("chicken"):
		if not c.is_in_group("dead_chicken"):
			n += 1
	return n


func _spawn() -> void:
	var pos := _pick_position()
	if pos == Vector3.INF:
		return                                  # tidak dapat titik bebas, coba lagi nanti
	var ch = _scene.instantiate()
	ch.set_player(_player)
	ch.position = pos
	add_child(ch)


# Pilih posisi acak: samping (bahu), depan (jauh, dlm area render), atau belakang.
# Coba beberapa kali sampai dapat titik yang bebas dari mobil.
func _pick_position() -> Vector3:
	for _attempt in range(8):
		var mode := randi() % 3
		var x: float
		var z: float
		match mode:
			0:  # samping: dari salah satu bahu
				var sh := GameConfig.LEFT_SHOULDER if randf() < 0.5 else GameConfig.RIGHT_SHOULDER
				x = GridUtils.col_x(sh)
				z = randf_range(GameConfig.CHICKEN_SIDE_Z_MIN, GameConfig.CHICKEN_SIDE_Z_MAX)
			1:  # depan: jauh di depan, kolom mana saja
				x = GridUtils.col_x(randi_range(GameConfig.LEFT_SHOULDER, GameConfig.RIGHT_SHOULDER))
				z = randf_range(GameConfig.CHICKEN_FRONT_Z_MIN, GameConfig.CHICKEN_FRONT_Z_MAX)
			_:  # belakang pemain
				x = GridUtils.col_x(randi_range(GameConfig.LEFT_SHOULDER, GameConfig.RIGHT_SHOULDER))
				z = randf_range(GameConfig.CHICKEN_BEHIND_Z_MIN, GameConfig.CHICKEN_BEHIND_Z_MAX)
		var p := Vector3(x, 0.0, z)
		if _is_clear(p):
			return p
	return Vector3.INF


func _is_clear(p: Vector3) -> bool:
	for car in get_tree().get_nodes_in_group("traffic"):
		var d: Vector3 = car.global_position - p
		d.y = 0.0
		if d.length() < GameConfig.CHICKEN_SPAWN_CLEAR + car.length * 0.5:
			return false
	return true
