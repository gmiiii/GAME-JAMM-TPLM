extends CanvasLayer

# Transisi fade hitam antar-scene. Sebagai autoload ia tetap hidup saat scene
# diganti, sehingga bisa fade-in lagi setelah scene baru selesai dimuat.

var _rect: ColorRect
var _busy: bool = false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 0.0)
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)


func change_scene_to(path: String) -> void:
	if _busy:
		return
	_busy = true
	Audio.stop_sfx()                       # hentikan sting game-over dll.
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade(1.0)
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await _fade(0.0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false


func reload() -> void:
	if _busy:
		return
	_busy = true
	Audio.stop_sfx()                       # hentikan sting game-over dll.
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade(1.0)
	get_tree().paused = false
	get_tree().reload_current_scene()
	await _fade(0.0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false


func _fade(target_a: float) -> void:
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", target_a, 0.3)
	await tw.finished
