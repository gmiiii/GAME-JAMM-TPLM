extends Node

# State global + skor. Diakses semua sistem.

signal game_over_changed(is_over: bool)
signal score_changed
signal escalation_changed(step: int)

var scroll_speed: float = 0.0          # kecepatan dunia bergerak ke pemain (di-set player)
var distance: float = 0.0              # total jarak tempuh (meter)
var time_survived: float = 0.0
var escalation_step: int = 0           # tingkat kesulitan saat ini
var high_score: int = 0
var is_game_over: bool = false
var death_cause: String = ""           # "car" atau "chicken"


func reset() -> void:
	scroll_speed = 0.0
	distance = 0.0
	time_survived = 0.0
	escalation_step = 0
	is_game_over = false
	death_cause = ""


func add_distance(d: float) -> void:
	distance += d
	var new_step := int(distance / GameConfig.ESCALATE_EVERY)
	if new_step != escalation_step:
		escalation_step = new_step
		escalation_changed.emit(escalation_step)
	score_changed.emit()


func trigger_game_over(cause: String) -> void:
	if is_game_over:
		return
	is_game_over = true
	death_cause = cause
	var s := score()
	if s > high_score:
		high_score = s
	game_over_changed.emit(true)


func score() -> int:
	return int(distance) + int(time_survived) * 2


# Pengali interval spawn: makin tinggi kesulitan, makin kecil (spawn makin rapat).
func spawn_interval_mult() -> float:
	return maxf(GameConfig.DIFFICULTY_SPAWN_FLOOR,
		1.0 - escalation_step * GameConfig.DIFFICULTY_SPAWN_FACTOR)
