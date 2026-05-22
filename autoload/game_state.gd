extends Node
## State global yang bertahan saat scene di-reload (skor tertinggi, dsb).

signal game_over_changed(is_over: bool)
signal score_changed

# Sel grid yang diblokir obstacle statis. Key: Vector2i(col, row).
var blocked_cells: Dictionary = {}

var crossings: int = 0          # berapa kali pemain berhasil menyeberang
var time_survived: float = 0.0  # detik bertahan
var high_score: int = 0
var is_game_over: bool = false


func _process(delta: float) -> void:
	if not is_game_over:
		time_survived += delta
		score_changed.emit()


## Dipanggil Main di awal tiap ronde (termasuk setelah restart).
func reset() -> void:
	blocked_cells.clear()
	crossings = 0
	time_survived = 0.0
	is_game_over = false


func add_blocked(col: int, row: int) -> void:
	blocked_cells[Vector2i(col, row)] = true


func add_crossing() -> void:
	crossings += 1
	score_changed.emit()


func score() -> int:
	return crossings * 10 + int(time_survived)


func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	var s := score()
	if s > high_score:
		high_score = s
	game_over_changed.emit(true)
