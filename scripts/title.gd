extends Node3D

# Menu awal: menampilkan dunia game (jalan, langit, mobil) dalam keadaan DIAM
# sebagai latar, dengan tombol PLAY di atasnya. PLAY -> masuk gameplay.

const PlayerScene := preload("res://scenes/player.tscn")
const ChunkScene := preload("res://scenes/road_chunk.tscn")
const PLAY_TEX := preload("res://assets/ui/play_button.png")
const GAME_SCENE := "res://scenes/main.tscn"


func _ready() -> void:
	GameState.reset()                 # scroll_speed = 0 -> dunia diam (backdrop)
	WorldBuilder.setup_environment(self)
	WorldBuilder.setup_camera(self)
	WorldBuilder.setup_road(self, ChunkScene)
	_add_static_player()
	_add_menu_ui()


func _add_static_player() -> void:
	var p: Node = PlayerScene.instantiate()
	add_child(p)
	# Matikan logika agar mobil diam (tidak baca input / tidak menggerakkan dunia).
	p.set_process(false)
	p.set_physics_process(false)


func _add_menu_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var btn := TextureButton.new()
	btn.texture_normal = PLAY_TEX
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	var ts := PLAY_TEX.get_size()
	var w := 280.0
	var h := w * ts.y / ts.x
	btn.size = Vector2(w, h)
	btn.position = (get_viewport().get_visible_rect().size - btn.size) * 0.5
	btn.pressed.connect(_on_play)
	layer.add_child(btn)


func _on_play() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
