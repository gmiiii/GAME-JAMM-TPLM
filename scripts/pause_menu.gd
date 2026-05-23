extends CanvasLayer

# Overlay jeda. Esc untuk pause/lanjut; tombol PLAY untuk lanjut.
# process_mode = ALWAYS supaya tetap menerima input meski pohon scene di-pause.

const PLAY_TEX := preload("res://assets/ui/play_button.png")

var _paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	_build()
	visible = false


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var btn := TextureButton.new()
	btn.texture_normal = PLAY_TEX
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	var ts := PLAY_TEX.get_size()
	var w := 280.0
	var h := w * ts.y / ts.x
	btn.size = Vector2(w, h)
	btn.position = (get_viewport().get_visible_rect().size - btn.size) * 0.5
	btn.pressed.connect(_resume)
	add_child(btn)


func _unhandled_input(event: InputEvent) -> void:
	if GameState.is_game_over:
		return
	if event.is_action_pressed("pause"):
		if _paused:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()


func _pause() -> void:
	_paused = true
	visible = true
	get_tree().paused = true


func _resume() -> void:
	_paused = false
	visible = false
	get_tree().paused = false
