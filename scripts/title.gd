extends Node3D

# Menu awal: menampilkan dunia game (jalan, langit, mobil) dalam keadaan DIAM
# sebagai latar, dengan tombol PLAY + toggle audio di atasnya.

const PlayerScene := preload("res://scenes/player.tscn")
const ChunkScene := preload("res://scenes/road_chunk.tscn")
const BTN_PLAY := preload("res://assets/ui/btn_play.png")
const BTN_AUDIO_ON := preload("res://assets/ui/btn_audio_on.png")
const BTN_AUDIO_OFF := preload("res://assets/ui/btn_audio_off.png")
const LOGO := preload("res://assets/ui/logo.png")
const GAME_SCENE := "res://scenes/main.tscn"

var _audio_btn: TextureButton


func _ready() -> void:
	GameState.reset()                 # scroll_speed = 0 -> dunia diam (backdrop)
	_set_window_icon()
	WorldBuilder.setup_environment(self)
	WorldBuilder.setup_camera(self)
	WorldBuilder.setup_road(self, ChunkScene)
	_add_static_player()
	_add_menu_ui()
	Audio.play_music(Audio.MUSIC_MENU)


func _set_window_icon() -> void:
	var img := LOGO.get_image()
	if img == null:
		return
	if img.is_compressed():
		img.decompress()
	img.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	DisplayServer.set_icon(img)


func _add_static_player() -> void:
	var p: Node = PlayerScene.instantiate()
	add_child(p)
	# Matikan logika agar mobil diam (tidak baca input / tidak menggerakkan dunia,
	# dan suara engine tidak dimulai karena dijalankan dari _process).
	p.set_process(false)
	p.set_physics_process(false)


func _add_menu_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var vp := get_viewport().get_visible_rect().size

	# Logo besar di tengah (sedikit ke atas), dengan animasi goyang + naik-turun.
	var logo := TextureRect.new()
	logo.texture = LOGO
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ls := 460.0
	logo.size = Vector2(ls, ls)
	logo.position = Vector2((vp.x - ls) * 0.5, vp.y * 0.40 - ls * 0.5)
	layer.add_child(logo)
	_animate_logo(logo)

	# PLAY di bagian bawah layar.
	var btn := UiText.texture_button(BTN_PLAY, 280.0)
	btn.position = Vector2((vp.x - btn.size.x) * 0.5, vp.y - btn.size.y - 40.0)
	btn.pressed.connect(_on_play)
	layer.add_child(btn)

	_audio_btn = UiText.texture_button(_audio_tex(), 130.0)
	_audio_btn.position = Vector2(vp.x - _audio_btn.size.x - 24.0, 24.0)
	_audio_btn.pressed.connect(_on_audio)
	layer.add_child(_audio_btn)


func _animate_logo(logo: TextureRect) -> void:
	logo.pivot_offset = logo.size * 0.5
	var base_y := logo.position.y
	# Goyang (rotasi) bolak-balik.
	var rot := create_tween().set_loops()
	rot.tween_property(logo, "rotation_degrees", 3.0, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	rot.tween_property(logo, "rotation_degrees", -3.0, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Naik-turun (bob).
	var bob := create_tween().set_loops()
	bob.tween_property(logo, "position:y", base_y - 12.0, 1.1) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(logo, "position:y", base_y + 12.0, 1.1) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _audio_tex() -> Texture2D:
	return BTN_AUDIO_ON if Audio.is_music_on() else BTN_AUDIO_OFF


func _on_audio() -> void:
	Audio.toggle_music()
	_audio_btn.texture_normal = _audio_tex()


func _on_play() -> void:
	Transition.change_scene_to(GAME_SCENE)
