extends Area2D
## Mobil pemain: gerak grid-stepped 2x1, deteksi menyeberang tepi, tabrakan vs bot car.

signal crossed  ## pemain melewati tepi kiri/kanan

var col: int = 0
var row: int = 0
var facing: int = 1  ## 1 = hadap kanan, -1 = hadap kiri
var _grace: float = 0.0  ## sisa waktu kebal tabrakan bot saat spawn/respawn

@onready var _shape: CollisionShape2D = CollisionShape2D.new()


func _ready() -> void:
	# Layer 1 = pemain, mask 2 = bot car (pemain mendeteksi bot).
	collision_layer = 1
	collision_mask = 2
	monitoring = true
	var rect := RectangleShape2D.new()
	rect.size = Vector2(GameConfig.PLAYER_W * GameConfig.CELL - 4, GameConfig.CELL - 4)
	_shape.shape = rect
	_shape.position = Vector2(GameConfig.PLAYER_W * GameConfig.CELL * 0.5, GameConfig.CELL * 0.5)
	add_child(_shape)
	area_entered.connect(_on_area_entered)
	set_cell(GameConfig.PLAYER_SPAWN_COL, GameConfig.PLAYER_SPAWN_ROW)
	_grace = GameConfig.SPAWN_GRACE


func set_cell(c: int, r: int) -> void:
	col = c
	row = r
	position = GridUtils.cell_to_world(col, row)


## Dua sel grid yang ditempati mobil (lebar 2).
func get_cells() -> Array:
	return [Vector2i(col, row), Vector2i(col + 1, row)]


func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
	if _grace > 0.0:
		_grace -= delta
		# saat grace habis, pastikan tidak sedang menumpuk bot car
		if _grace <= 0.0 and not get_overlapping_areas().is_empty():
			GameState.trigger_game_over()
			return
	if Input.is_action_just_pressed("move_left"):
		_try_horizontal(-1)
	elif Input.is_action_just_pressed("move_right"):
		_try_horizontal(1)
	elif Input.is_action_just_pressed("move_up"):
		_try_vertical(-1)
	elif Input.is_action_just_pressed("move_down"):
		_try_vertical(1)


func _try_horizontal(dir: int) -> void:
	facing = dir
	if dir < 0:
		# leading cell baru = col - 1
		if col - 1 < 0:
			_cross()
			return
		if not GridUtils.is_blocked(col - 1, row):
			set_cell(col - 1, row)
	else:
		# leading cell baru = col + 2 (mobil pindah ke col+1)
		if col + 2 > GameConfig.GRID_COLS - 1:
			_cross()
			return
		if not GridUtils.is_blocked(col + 2, row):
			set_cell(col + 1, row)
	queue_redraw()


func _try_vertical(dir: int) -> void:
	var nr := row + dir
	if not GridUtils.row_in_bounds(nr):
		return
	# kedua sel target harus bebas
	if GridUtils.cell_free(col, nr) and GridUtils.cell_free(col + 1, nr):
		set_cell(col, nr)


func _cross() -> void:
	GameState.add_crossing()
	# respawn di lane acak, kolom tengah; ayam TIDAK direset.
	var lane: Dictionary = GameConfig.LANES[randi() % GameConfig.LANES.size()]
	set_cell(GameConfig.PLAYER_RESPAWN_COL, int(lane["row"]))
	_grace = GameConfig.SPAWN_GRACE
	crossed.emit()
	queue_redraw()


func _on_area_entered(_area: Area2D) -> void:
	# satu-satunya area yang bisa dideteksi adalah bot car (mask=2)
	if _grace > 0.0:
		return
	GameState.trigger_game_over()


func _draw() -> void:
	var w := GameConfig.PLAYER_W * GameConfig.CELL
	var h := GameConfig.CELL
	var body := Rect2(2, 4, w - 4, h - 8)
	draw_rect(body, GameConfig.COLOR_PLAYER, true)
	draw_rect(body, GameConfig.COLOR_PLAYER_DARK, false, 2.0)
	# kabin
	draw_rect(Rect2(w * 0.30, 8, w * 0.40, h - 16), GameConfig.COLOR_PLAYER_DARK, true)
	# indikator arah hadap (segitiga)
	var tip_x := float(w - 6) if facing > 0 else 6.0
	var back_x := float(w * 0.62) if facing > 0 else float(w * 0.38)
	var pts := PackedVector2Array([
		Vector2(tip_x, h * 0.5),
		Vector2(back_x, h * 0.30),
		Vector2(back_x, h * 0.70),
	])
	draw_colored_polygon(pts, GameConfig.COLOR_PLAYER_DARK)
