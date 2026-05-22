extends Node2D
## Ayam: gerak grid-stepped otomatis mengejar pemain (jarak Manhattan, prioritas horizontal).
## Tidak menghindari bot car. Hanya diblokir obstacle statis & batas field.

var col: int = 0
var row: int = 0
var facing: Vector2i = Vector2i(1, 0)  ## arah hadap terakhir
var _timer: float = 0.0
var _player: Node = null


func set_cell(c: int, r: int) -> void:
	col = c
	row = r
	position = GridUtils.cell_to_world(col, row)


func set_player(p: Node) -> void:
	_player = p


func _process(delta: float) -> void:
	if GameState.is_game_over or _player == null:
		return
	_timer += delta
	if _timer >= GameConfig.CHICKEN_TICK:
		_timer -= GameConfig.CHICKEN_TICK
		_step()


func _step() -> void:
	var target: Vector2i = _nearest_player_cell()
	var dx: int = target.x - col
	var dy: int = target.y - row
	if dx == 0 and dy == 0:
		return

	# Urutan coba: sumbu dengan jarak lebih besar dulu; seri -> horizontal dulu.
	var steps: Array = []
	var horiz := Vector2i(signi(dx), 0)
	var vert := Vector2i(0, signi(dy))
	if absi(dx) >= absi(dy):
		if dx != 0: steps.append(horiz)
		if dy != 0: steps.append(vert)
	else:
		if dy != 0: steps.append(vert)
		if dx != 0: steps.append(horiz)

	for s in steps:
		if GridUtils.cell_free(col + s.x, row + s.y):
			facing = s
			set_cell(col + s.x, row + s.y)
			queue_redraw()
			return
	# kedua arah terblokir -> diam


func _nearest_player_cell() -> Vector2i:
	var cells: Array = _player.get_cells()
	var best: Vector2i = cells[0]
	var best_d: int = _manhattan(best)
	for i in range(1, cells.size()):
		var d: int = _manhattan(cells[i])
		if d < best_d:
			best_d = d
			best = cells[i]
	return best


func _manhattan(cell: Vector2i) -> int:
	return absi(cell.x - col) + absi(cell.y - row)


func _draw() -> void:
	var s := float(GameConfig.CELL)
	# badan ayam
	var body := Rect2(s * 0.18, s * 0.22, s * 0.64, s * 0.62)
	draw_rect(body, GameConfig.COLOR_CHICKEN, true)
	draw_rect(body, Color(0, 0, 0, 0.35), false, 1.5)
	# jengger
	draw_rect(Rect2(s * 0.40, s * 0.10, s * 0.20, s * 0.14), GameConfig.COLOR_CHICKEN_COMB, true)
	# paruh menunjuk arah hadap
	var cx := s * 0.5
	var cy := s * 0.5
	var beak: PackedVector2Array
	if facing == Vector2i(1, 0):
		beak = PackedVector2Array([Vector2(s * 0.82, cy), Vector2(s * 0.66, cy - s * 0.08), Vector2(s * 0.66, cy + s * 0.08)])
	elif facing == Vector2i(-1, 0):
		beak = PackedVector2Array([Vector2(s * 0.18, cy), Vector2(s * 0.34, cy - s * 0.08), Vector2(s * 0.34, cy + s * 0.08)])
	elif facing == Vector2i(0, -1):
		beak = PackedVector2Array([Vector2(cx, s * 0.14), Vector2(cx - s * 0.08, s * 0.30), Vector2(cx + s * 0.08, s * 0.30)])
	else:
		beak = PackedVector2Array([Vector2(cx, s * 0.86), Vector2(cx - s * 0.08, s * 0.70), Vector2(cx + s * 0.08, s * 0.70)])
	draw_colored_polygon(beak, GameConfig.COLOR_CHICKEN_BEAK)
