extends Node3D

# Orkestrasi level 3D: environment, kamera statis, treadmill jalan, spawner,
# pemain, HUD, dan restart.

const PlayerScene := preload("res://scenes/player.tscn")
const TrafficScene := preload("res://scenes/traffic_car.tscn")
const ChickenScene := preload("res://scenes/chicken.tscn")
const ChunkScene := preload("res://scenes/road_chunk.tscn")
const HudScene := preload("res://scenes/hud.tscn")
const PauseMenu := preload("res://scripts/pause_menu.gd")
const TrafficSpawner := preload("res://scripts/traffic_spawner.gd")
const ChickenSpawner := preload("res://scripts/chicken_spawner.gd")

var _player: Node3D


func _ready() -> void:
	GameState.reset()
	_setup_environment()
	_setup_camera()
	_setup_road()
	_setup_player()
	_setup_spawners()
	add_child(HudScene.instantiate())
	add_child(PauseMenu.new())
	Audio.play_music(Audio.MUSIC_INGAME)


func _setup_environment() -> void:
	WorldBuilder.setup_environment(self)


func _setup_camera() -> void:
	WorldBuilder.setup_camera(self)


func _setup_road() -> void:
	WorldBuilder.setup_road(self, ChunkScene)


func _setup_player() -> void:
	_player = PlayerScene.instantiate()
	add_child(_player)


func _setup_spawners() -> void:
	var ts := TrafficSpawner.new()
	add_child(ts)
	ts.setup(TrafficScene)

	var cs := ChickenSpawner.new()
	add_child(cs)
	cs.setup(ChickenScene, _player)
