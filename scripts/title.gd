extends Node3D

# Menu awal: menampilkan dunia game (jalan, langit, mobil) dalam keadaan DIAM
# sebagai latar, dengan tombol PLAY + toggle audio di atasnya.

const PlayerScene := preload("res://scenes/player.tscn")
const ChunkScene := preload("res://scenes/road_chunk.tscn")
const BTN_PLAY := preload("res://assets/ui/btn_play.png")
const BTN_AUDIO_ON := preload("res://assets/ui/btn_audio_on.png")
const BTN_AUDIO_OFF := preload("res://assets/ui/btn_audio_off.png")
const GAME_SCENE := "res://scenes/main.tscn"

var _audio_btn: TextureButton


func _ready() -> void:
	GameState.reset()                 # scroll_speed = 0 -> dunia diam (backdrop)
	WorldBuilder.setup_environment(self)
	WorldBuilder.setup_camera(self)
	WorldBuilder.setup_road(self, ChunkScene)
	_add_static_player()
	_add_menu_ui()
	Audio.play_music(Audio.MUSIC_MENU)


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

	var btn := UiText.texture_button(BTN_PLAY, 280.0)
	btn.position = (vp - btn.size) * 0.5
	btn.pressed.connect(_on_play)
	layer.add_child(btn)

	_audio_btn = UiText.texture_button(_audio_tex(), 130.0)
	_audio_btn.position = Vector2(vp.x - _audio_btn.size.x - 24.0, 24.0)
	_audio_btn.pressed.connect(_on_audio)
	layer.add_child(_audio_btn)


func _audio_tex() -> Texture2D:
	return BTN_AUDIO_ON if Audio.is_music_on() else BTN_AUDIO_OFF


func _on_audio() -> void:
	Audio.toggle_music()
	_audio_btn.texture_normal = _audio_tex()


func _on_play() -> void:
	Transition.change_scene_to(GAME_SCENE)
