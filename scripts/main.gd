extends Node2D
## Orkestrasi level: bangun field, spawn obstacle/bot/pemain/ayam, cek tabrakan ayam, restart.

const PlayerScene: PackedScene = preload("res://scenes/player.tscn")
const ChickenScene: PackedScene = preload("res://scenes/chicken.tscn")
const BotCarScene: PackedScene = preload("res://scenes/bot_car.tscn")
const ObstacleScene: PackedScene = preload("res://scenes/obstacle.tscn")
const HudScene: PackedScene = preload("res://scenes/hud.tscn")

var _player: Area2D
var _chicken: Node2D


func _ready() -> void:
	GameState.reset()
	queue_redraw()
	_spawn_obstacles()
	_spawn_actors()
	_spawn_bots()
	add_child(HudScene.instantiate())


func _spawn_obstacles() -> void:
	# Pohon & batu di strip rumput (baris 0 & 6), cone di tengah lane.
	var top := 0
	var bottom := GameConfig.GRID_ROWS - 1
	_add_obstacle("tree", 2, top)
	_add_obstacle("tree", 6, top)
	_add_obstacle("rock", 11, top)
	_add_obstacle("tree", 15, top)
	_add_obstacle("rock", 3, bottom)
	_add_obstacle("tree", 12, bottom)
	_add_obstacle("rock", 16, bottom)
	_add_obstacle("cone", 13, 4)  # cone di tengah lane 4 (hindari kolom respawn 8-9)


func _add_obstacle(kind: String, col: int, row: int) -> void:
	var ob: Node2D = ObstacleScene.instantiate()
	add_child(ob)
	ob.setup(kind, col, row)


func _spawn_actors() -> void:
	_player = PlayerScene.instantiate()
	add_child(_player)

	_chicken = ChickenScene.instantiate()
	add_child(_chicken)
	_chicken.set_cell(GameConfig.CHICKEN_SPAWN_COL, GameConfig.GRID_ROWS - 1)
	_chicken.set_player(_player)


func _spawn_bots() -> void:
	var manager := BotManager.new()
	add_child(manager)
	manager.setup(BotCarScene)


func _process(_delta: float) -> void:
	if GameState.is_game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return
	# Kalah jika sel ayam menumpuk salah satu sel pemain.
	if _player != null and _chicken != null:
		var ccell := Vector2i(_chicken.col, _chicken.row)
		if ccell in _player.get_cells():
			GameState.trigger_game_over()


func _draw() -> void:
	var cell := GameConfig.CELL
	var w := GameConfig.field_width_px()
	# rumput & jalan per baris
	for r in range(GameConfig.GRID_ROWS):
		var is_grass := (r == 0 or r == GameConfig.GRID_ROWS - 1)
		var base := GameConfig.COLOR_GRASS if is_grass else GameConfig.COLOR_ROAD
		draw_rect(Rect2(0, r * cell, w, cell), base, true)
		if is_grass:
			# garis-garis rumput tipis
			for c in range(GameConfig.GRID_COLS):
				if (c + r) % 2 == 0:
					draw_rect(Rect2(c * cell, r * cell, cell, cell), GameConfig.COLOR_GRASS_DARK, true)
	# garis pembatas lane (putus-putus)
	for i in range(GameConfig.LANES.size() + 1):
		var y := (1 + i) * cell
		var dash := cell * 0.5
		var x := 0.0
		while x < w:
			draw_rect(Rect2(x, y - 1, dash, 2), GameConfig.COLOR_ROAD_LINE, true)
			x += dash * 2.0
	# panah arah tiap lane
	for lane in GameConfig.LANES:
		var row: int = int(lane["row"])
		var dir: int = int(lane["dir"])
		var cy := row * cell + cell * 0.5
		var ax := (w - cell * 0.5) if dir > 0 else (cell * 0.5)
		var tip := ax + (cell * 0.18 * dir)
		var pts := PackedVector2Array([
			Vector2(tip, cy), Vector2(ax - cell * 0.18 * dir, cy - cell * 0.12),
			Vector2(ax - cell * 0.18 * dir, cy + cell * 0.12),
		])
		draw_colored_polygon(pts, Color(1, 1, 1, 0.18))
