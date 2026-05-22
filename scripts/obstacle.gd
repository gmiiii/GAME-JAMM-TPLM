extends Node2D
## Obstacle statis (pohon/batu/cone). Memblokir gerak pemain & ayam; murni hiasan.

var kind: String = "tree"


func setup(obstacle_kind: String, col: int, row: int) -> void:
	kind = obstacle_kind
	position = GridUtils.cell_to_world(col, row)
	GameState.add_blocked(col, row)
	queue_redraw()


func _draw() -> void:
	var s := float(GameConfig.CELL)
	match kind:
		"tree":
			draw_rect(Rect2(s * 0.42, s * 0.55, s * 0.16, s * 0.35), Color("6b4a2b"), true)
			draw_circle(Vector2(s * 0.5, s * 0.42), s * 0.30, GameConfig.COLOR_TREE)
		"rock":
			var pts := PackedVector2Array([
				Vector2(s * 0.20, s * 0.78), Vector2(s * 0.32, s * 0.42),
				Vector2(s * 0.55, s * 0.30), Vector2(s * 0.80, s * 0.50),
				Vector2(s * 0.82, s * 0.78),
			])
			draw_colored_polygon(pts, GameConfig.COLOR_ROCK)
		"cone":
			var tri := PackedVector2Array([
				Vector2(s * 0.5, s * 0.18), Vector2(s * 0.28, s * 0.80), Vector2(s * 0.72, s * 0.80),
			])
			draw_colored_polygon(tri, GameConfig.COLOR_CONE)
			draw_rect(Rect2(s * 0.20, s * 0.80, s * 0.60, s * 0.10), GameConfig.COLOR_CONE, true)
			draw_rect(Rect2(s * 0.36, s * 0.42, s * 0.28, s * 0.10), Color.WHITE, true)
