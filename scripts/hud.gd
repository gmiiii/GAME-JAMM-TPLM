extends CanvasLayer
## HUD: skor berjalan + panel game over. Node UI dibuat via kode (placeholder).

var _score_label: Label
var _gameover_panel: Control
var _final_label: Label


func _ready() -> void:
	_score_label = Label.new()
	_score_label.position = Vector2(10, 6)
	_score_label.add_theme_font_size_override("font_size", 16)
	add_child(_score_label)

	_gameover_panel = _build_gameover_panel()
	_gameover_panel.visible = false
	add_child(_gameover_panel)

	GameState.score_changed.connect(_update_score)
	GameState.game_over_changed.connect(_on_game_over)
	_update_score()


func _build_gameover_panel() -> Control:
	var root := ColorRect.new()
	root.color = Color(0, 0, 0, 0.55)
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	root.add_child(box)

	var title := Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	box.add_child(title)

	_final_label = Label.new()
	_final_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_final_label.add_theme_font_size_override("font_size", 18)
	box.add_child(_final_label)

	var hint := Label.new()
	hint.text = "Tekan R / Enter / Spasi untuk main lagi"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	box.add_child(hint)

	return root


func _update_score() -> void:
	_score_label.text = "Skor: %d   Menyeberang: %d   Waktu: %ds   Terbaik: %d" % [
		GameState.score(), GameState.crossings, int(GameState.time_survived), GameState.high_score,
	]


func _on_game_over(is_over: bool) -> void:
	if is_over:
		_final_label.text = "Skor akhir: %d    Terbaik: %d" % [GameState.score(), GameState.high_score]
		_gameover_panel.visible = true
