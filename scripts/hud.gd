extends CanvasLayer

# Skor + panel game over (pesan beda untuk ayam vs mobil).

var _score_label: Label
var _panel: ColorRect
var _panel_label: Label


func _ready() -> void:
	_score_label = Label.new()
	_score_label.position = Vector2(18, 14)
	_score_label.add_theme_font_size_override("font_size", 22)
	add_child(_score_label)
	_build_panel()
	GameState.game_over_changed.connect(_on_game_over)


func _process(_delta: float) -> void:
	if not GameState.is_game_over:
		_score_label.text = "Jarak: %d m\nSkor: %d\nTerbaik: %d" % [
			int(GameState.distance), GameState.score(), GameState.high_score]


func _build_panel() -> void:
	_panel = ColorRect.new()
	_panel.color = Color(0, 0, 0, 0.6)
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.visible = false
	add_child(_panel)
	_panel_label = Label.new()
	_panel_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_panel_label.add_theme_font_size_override("font_size", 30)
	_panel.add_child(_panel_label)


func _on_game_over(is_over: bool) -> void:
	if not is_over:
		return
	var head := "LAWSUIT!\nKamu menabrak ayam." if GameState.death_cause == "chicken" \
		else "CRASH!\nKamu menabrak mobil lain."
	_panel_label.text = "%s\n\nSkor: %d   Terbaik: %d\n\nTekan R untuk main lagi" % [
		head, GameState.score(), GameState.high_score]
	_panel.visible = true
