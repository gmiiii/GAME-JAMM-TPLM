extends Area3D

# Ayam penipu. Mengejar mobil pemain memakai A* pada grid (kolom x baris-Z),
# menavigasi celah di antara mobil (sel yang akan dilewati mobil = terblokir).
# Dunia bergerak maju (treadmill) -> ayam yang terhambat tersapu mundur & tertinggal.

const BODY := Vector3(0.8, 0.8, 0.9)
const DIRS := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const ChickenModel := preload("res://assets/models/chicken/chicken.FBX")

var _player: Node3D
var speed: float = 11.0
var _tick: float = 0.0
var _next_cell: Vector2i
var _dead: bool = false


func _ready() -> void:
	add_to_group("chicken")
	collision_layer = 4
	collision_mask = 2                  # deteksi traffic
	_build()
	_next_cell = _cell()
	area_entered.connect(_on_area_entered)


func _build() -> void:
	add_child(Build3D.model(ChickenModel, BODY.z, GameConfig.MODEL_YAW_CHICKEN))
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = BODY
	cs.shape = shape
	cs.position.y = BODY.y * 0.5
	add_child(cs)


func set_player(p: Node3D) -> void:
	_player = p


func _process(delta: float) -> void:
	if GameState.is_game_over or _player == null:
		return

	# Sudah mati (gepeng): berhenti mengejar, tapi TETAP ikut treadmill agar
	# hanyut mundur bersama jalan seperti objek lain, bukan diam di tempat.
	if _dead:
		global_position.z += GameState.scroll_speed * delta
		return

	speed = min(GameConfig.CHICKEN_SPEED_MAX,
		GameConfig.CHICKEN_SPEED_START + GameState.escalation_step * GameConfig.CHICKEN_SPEED_BONUS_PER_STEP)

	# Re-plan rute tiap tick.
	_tick += delta
	if _tick >= GameConfig.CHICKEN_TICK:
		_tick = 0.0
		_next_cell = _plan_step()

	# Gerak sendiri menuju sel berikutnya + carry oleh scroll (sumbu Z).
	var target := Vector3(GridUtils.col_x(_next_cell.x), global_position.y, _next_cell.y * GameConfig.CHICKEN_CELL_Z)
	var own := target - global_position
	own.y = 0.0
	if own.length() > 0.01:
		own = own.normalized() * speed
	else:
		own = Vector3.ZERO
	global_position.x += own.x * delta
	global_position.z += (own.z + GameState.scroll_speed) * delta

	# Hadap ke mobil.
	var face := _player.global_position - global_position
	face.y = 0.0
	if face.length() > 0.1:
		look_at(global_position + face, Vector3.UP)

	# Tertinggal di belakang -> hilang.
	if global_position.z > GameConfig.CHICKEN_DESPAWN_Z:
		queue_free()


func _cell() -> Vector2i:
	return Vector2i(
		clampi(GridUtils.x_to_col(global_position.x), GameConfig.LEFT_SHOULDER, GameConfig.RIGHT_SHOULDER),
		int(round(global_position.z / GameConfig.CHICKEN_CELL_Z)))


# A* -> kembalikan sel tetangga pertama menuju mobil (atau diam bila buntu).
func _plan_step() -> Vector2i:
	var start := _cell()
	var goal := Vector2i(_player.current_col, 0)

	# Langkah acak/nekat: kadang bergerak sembarang tanpa cek bahaya, sehingga
	# ayam bisa saja menabrak mobil lain. Tetap dominan pathfinding ke pemain.
	if randf() < GameConfig.CHICKEN_RANDOM_CHANCE:
		return _random_step(start)

	if start == goal:
		return goal

	var blocked := _blocked_cells()
	var y_min: int = mini(start.y, goal.y) - 8
	var y_max: int = maxi(start.y, goal.y) + 8

	var came := {}
	var g := {start: 0}
	var f := {start: _h(start, goal)}
	var open: Array = [start]
	var iter := 0

	while not open.is_empty() and iter < 600:
		iter += 1
		var cur: Vector2i = open[0]
		var ci := 0
		for i in range(1, open.size()):
			if float(f.get(open[i], INF)) < float(f.get(cur, INF)):
				cur = open[i]
				ci = i
		if cur == goal:
			break
		open.remove_at(ci)
		for d in DIRS:
			var nb: Vector2i = cur + d
			if nb.x < GameConfig.LEFT_SHOULDER or nb.x > GameConfig.RIGHT_SHOULDER:
				continue
			if nb.y < y_min or nb.y > y_max:
				continue
			if nb != goal and blocked.has(nb):
				continue
			var tg: int = int(g[cur]) + 1
			if tg < int(g.get(nb, 1 << 30)):
				came[nb] = cur
				g[nb] = tg
				f[nb] = tg + _h(nb, goal)
				if not open.has(nb):
					open.append(nb)

	if not came.has(goal):
		return _greedy_step(start, goal, blocked)

	# Telusuri balik ke langkah pertama dari start.
	var node := goal
	while came.get(node, start) != start:
		node = came[node]
	return node


# Fallback bila tak ada rute: melangkah ke arah mobil pada sel teraman.
func _greedy_step(start: Vector2i, goal: Vector2i, blocked: Dictionary) -> Vector2i:
	var best := start
	var best_h := 1 << 30
	for d in DIRS:
		var nb: Vector2i = start + d
		if nb.x < GameConfig.LEFT_SHOULDER or nb.x > GameConfig.RIGHT_SHOULDER:
			continue
		if blocked.has(nb):
			continue
		var hh := _h(nb, goal)
		if hh < best_h:
			best_h = hh
			best = nb
	return best


# Langkah acak ke salah satu tetangga (mengabaikan sel terblokir = berisiko).
func _random_step(start: Vector2i) -> Vector2i:
	var opts: Array = []
	for d in DIRS:
		var nb: Vector2i = start + d
		if nb.x >= GameConfig.LEFT_SHOULDER and nb.x <= GameConfig.RIGHT_SHOULDER:
			opts.append(nb)
	if opts.is_empty():
		return start
	return opts[randi() % opts.size()]


func _h(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


# Sel yang ditempati / akan dilewati mobil dalam waktu dekat = terblokir.
func _blocked_cells() -> Dictionary:
	var b := {}
	for car in get_tree().get_nodes_in_group("traffic"):
		var ccol := GridUtils.x_to_col(car.global_position.x)
		if ccol < GameConfig.FIRST_LANE or ccol > GameConfig.LAST_LANE:
			continue
		var net: float = GameState.scroll_speed + (car.own_speed if car.oncoming else -car.own_speed)
		var span: int = int(ceil((car.length * 0.5 + GameConfig.CHICKEN_DANGER_Z) / GameConfig.CHICKEN_CELL_Z))
		for step in 3:
			var z: float = car.global_position.z + net * GameConfig.CHICKEN_TICK * float(step)
			var row: int = int(round(z / GameConfig.CHICKEN_CELL_Z))
			for r in range(row - span, row + span + 1):
				b[Vector2i(ccol, r)] = true
	return b


func _on_area_entered(area: Area3D) -> void:
	if _dead:
		return
	if area.is_in_group("traffic"):
		_die()


func _die() -> void:
	_dead = true
	add_to_group("dead_chicken")
	collision_layer = 0
	set_deferred("monitorable", false)
	scale = Vector3(1.3, 0.15, 1.3)     # gepeng
	await get_tree().create_timer(GameConfig.CHICKEN_RESPAWN_DELAY).timeout
	queue_free()
