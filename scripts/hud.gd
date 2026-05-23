extends CanvasLayer

# Skor live (kiri-atas) + presentasi kalah:
#   - mati ayam  -> koran berputar (newspaper_popup)
#   - mati mobil -> panel teks
# Setelah presentasi selesai: klik / tombol apa pun -> main lagi.

const FONT := preload("res://assets/fonts/8bit_wonder.ttf")
const NewspaperPopup := preload("res://scripts/newspaper_popup.gd")

var _score_label: Label
var _panel: ColorRect
var _panel_label: Label
var _hint: Label
var _can_restart: bool = false


func _ready() -> void:
	_score_label = Label.new()
	_score_label.position = Vector2(18, 14)
	_score_label.add_theme_font_override("font", FONT)
	_score_label.add_theme_font_size_override("font_size", 22)
	add_child(_score_label)
	_build_panel()
	_build_hint()
	GameState.game_over_changed.connect(_on_game_over)


func _process(_delta: float) -> void:
	if not GameState.is_game_over:
		_score_label.text = "JARAK %d M\nSKOR %d\nTERBAIK %d" % [
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
	_panel_label.add_theme_font_override("font", FONT)
	_panel_label.add_theme_font_size_override("font_size", 28)
	_panel.add_child(_panel_label)


func _build_hint() -> void:
	_hint = Label.new()
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_hint.offset_top = -70.0
	_hint.offset_bottom = -30.0
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint.add_theme_font_override("font", FONT)
	_hint.add_theme_font_size_override("font_size", 20)
	_hint.text = "TEKAN R / KLIK UNTUK MAIN LAGI"
	_hint.visible = false
	add_child(_hint)


func _on_game_over(is_over: bool) -> void:
	if not is_over:
		return
	if GameState.death_cause == "chicken":
		var koran := NewspaperPopup.new()
		add_child(koran)
		koran.finished.connect(_on_present_done)
		koran.play()
	else:
		_panel_label.text = "CRASH!\nKAMU MENABRAK MOBIL LAIN.\n\nSKOR %d   TERBAIK %d" % [
			GameState.score(), GameState.high_score]
		_panel.visible = true
		await get_tree().create_timer(0.6).timeout
		_on_present_done()


func _on_present_done() -> void:
	_can_restart = true
	move_child(_hint, get_child_count() - 1)   # tampil di atas koran/panel
	_hint.visible = true


func _unhandled_input(event: InputEvent) -> void:
	# Main lagi: tombol R (aksi "restart") ATAU klik kiri. Berlaku untuk
	# kalah karena ayam maupun mobil.
	if not GameState.is_game_over or not _can_restart:
		return
	var clicked: bool = event is InputEventMouseButton and event.pressed \
		and event.button_index == MOUSE_BUTTON_LEFT
	if clicked or event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
