extends Node3D

# Orkestrasi level 3D: environment, kamera statis, treadmill jalan, spawner,
# pemain, HUD, dan restart.

const PlayerScene := preload("res://scenes/player.tscn")
const TrafficScene := preload("res://scenes/traffic_car.tscn")
const ChickenScene := preload("res://scenes/chicken.tscn")
const ChunkScene := preload("res://scenes/road_chunk.tscn")
const HudScene := preload("res://scenes/hud.tscn")
const RoadManager := preload("res://scripts/road_manager.gd")
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


func _process(_delta: float) -> void:
	if GameState.is_game_over and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _setup_environment() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, -40, 0)
	light.light_energy = 1.1
	light.shadow_enabled = true
	add_child(light)

	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = GameConfig.COL_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.5
	we.environment = env
	add_child(we)


func _setup_camera() -> void:
	# Kamera STATIS gaya Crossy Road: ortografik + sudut tinggi. Tidak ikut hop lane.
	var cam := Camera3D.new()
	if GameConfig.CAM_ORTHOGRAPHIC:
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = GameConfig.CAM_ORTHO_SIZE
	else:
		cam.fov = GameConfig.CAM_FOV
	cam.position = GameConfig.CAM_POSITION
	add_child(cam)
	cam.look_at(GameConfig.CAM_LOOK_AT, Vector3.UP)
	cam.current = true


func _setup_road() -> void:
	var rm := RoadManager.new()
	add_child(rm)
	rm.setup(ChunkScene)


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
