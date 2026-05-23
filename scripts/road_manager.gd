extends Node3D

# Treadmill jalan: chunk bergerak +Z mengikuti scroll, lalu di-recycle ke depan.

var _chunk_scene: PackedScene
var _chunks: Array = []


func setup(chunk_scene: PackedScene) -> void:
	_chunk_scene = chunk_scene
	var start_z := GameConfig.CHUNK_LEN * GameConfig.CHUNK_BEHIND
	var total := GameConfig.CHUNK_AHEAD + GameConfig.CHUNK_BEHIND
	for i in range(total):
		_add_chunk(start_z - i * GameConfig.CHUNK_LEN)


func _add_chunk(z: float) -> void:
	var c = _chunk_scene.instantiate()
	add_child(c)
	c.build()
	c.position.z = z
	_chunks.append(c)


func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
	var move := GameState.scroll_speed * delta
	# Pass 1: geser semua chunk dulu (posisi konsisten).
	for c in _chunks:
		c.position.z += move
	# Pass 2: recycle chunk yang lewat batas belakang ke paling depan.
	var behind_limit := GameConfig.CHUNK_LEN * GameConfig.CHUNK_BEHIND
	for c in _chunks:
		if c.position.z > behind_limit:
			c.position.z = _front_z() - GameConfig.CHUNK_LEN


func _front_z() -> float:
	var m := INF
	for c in _chunks:
		m = min(m, c.position.z)
	return m
