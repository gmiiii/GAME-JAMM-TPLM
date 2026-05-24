extends CanvasLayer

# Overlay jeda. Esc untuk pause; tombol play untuk lanjut (dengan hitung mundur
# 3-2-1), toggle audio (musik), dan tombol back ke menu judul.
# process_mode = ALWAYS supaya tetap aktif meski scene di-pause.

const BTN_PLAY := preload("res://assets/ui/btn_play.png")
const BTN_AUDIO_ON := preload("res://assets/ui/btn_audio_on.png")
const BTN_AUDIO_OFF := preload("res://assets/ui/btn_audio_off.png")
const BTN_HOME := preload("res://assets/ui/btn_home.png")
const FONT := preload("res://assets/fonts/8bit_wonder.ttf")
const TITLE_SCENE := "res://scenes/title.tscn"

var _paused: bool = false
var _counting: bool = false
var _dim: ColorRect
var _play_btn: TextureButton
var _audio_btn: TextureButton
var _back_btn: TextureButton
var _count_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	_build()
	_set_menu_visible(false)


func _build() -> void:
	var vp := get_viewport().get_visible_rect().size

	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0.55)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim)

	# Play di tengah layar.
	_play_btn = UiText.texture_button(BTN_PLAY, 200.0)
	_play_btn.position = Vector2((vp.x - _play_btn.size.x) * 0.5, (vp.y - _play_btn.size.y) * 0.5)
	_play_btn.pressed.connect(_resume)
	add_child(_play_btn)

	# Audio di pojok kanan atas.
	_audio_btn = UiText.texture_button(_audio_tex(), 120.0)
	_audio_btn.position = Vector2(vp.x - _audio_btn.size.x - 24.0, 24.0)
	_audio_btn.pressed.connect(_on_audio)
	add_child(_audio_btn)

	# Home (ke menu judul) di pojok kiri atas (ukuran sama dengan audio).
	_back_btn = UiText.texture_button(BTN_HOME, 120.0)
	_back_btn.position = Vector2(24.0, 24.0)
	_back_btn.pressed.connect(_on_back)
	add_child(_back_btn)

	_count_label = Label.new()
	_count_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count_label.add_theme_font_override("font", FONT)
	_count_label.add_theme_font_size_override("font_size", 120)
	UiText.outline(_count_label, 10)
	_count_label.visible = false
	add_child(_count_label)


func _set_menu_visible(v: bool) -> void:
	_dim.visible = v
	_play_btn.visible = v
	_audio_btn.visible = v
	_back_btn.visible = v


func _audio_tex() -> Texture2D:
	return BTN_AUDIO_ON if Audio.is_music_on() else BTN_AUDIO_OFF


func _on_audio() -> void:
	Audio.toggle_music()
	_audio_btn.texture_normal = _audio_tex()


func _on_back() -> void:
	_paused = false
	Transition.change_scene_to(TITLE_SCENE)


func _unhandled_input(event: InputEvent) -> void:
	if GameState.is_game_over or _counting:
		return
	if event.is_action_pressed("pause"):
		if _paused:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()


func _pause() -> void:
	_paused = true
	_set_menu_visible(true)
	get_tree().paused = true


# Lanjut dengan hitung mundur 3-2-1 (timer process_always -> jalan saat pause).
func _resume() -> void:
	if _counting:
		return
	_counting = true
	_set_menu_visible(false)
	_count_label.visible = true
	for n in [3, 2, 1]:
		_count_label.text = str(n)
		_count_label.pivot_offset = _count_label.size * 0.5
		_count_label.scale = Vector2(0.4, 0.4)
		var tw := _count_label.create_tween()
		tw.tween_property(_count_label, "scale", Vector2.ONE, 0.25) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		Audio.play_sfx(Audio.SFX_CLICK, 1.0 + float(3 - n) * 0.1)
		await get_tree().create_timer(1.0, true).timeout
	_count_label.visible = false
	_paused = false
	_counting = false
	get_tree().paused = false
