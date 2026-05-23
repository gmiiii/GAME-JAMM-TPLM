class_name WorldBuilder

# Pembangun dunia (lingkungan, kamera, jalan) dipakai bersama oleh gameplay
# (main) dan menu awal (title) supaya tampilannya identik.

const RoadManager := preload("res://scripts/road_manager.gd")


static func setup_environment(parent: Node) -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, -40, 0)
	light.light_energy = 1.1
	light.shadow_enabled = true
	parent.add_child(light)

	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = GameConfig.COL_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.5
	we.environment = env
	parent.add_child(we)


static func setup_camera(parent: Node) -> void:
	var cam := Camera3D.new()
	if GameConfig.CAM_ORTHOGRAPHIC:
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = GameConfig.CAM_ORTHO_SIZE
	else:
		cam.fov = GameConfig.CAM_FOV
	cam.position = GameConfig.CAM_POSITION
	parent.add_child(cam)
	cam.look_at(GameConfig.CAM_LOOK_AT, Vector3.UP)
	cam.current = true


static func setup_road(parent: Node, chunk_scene: PackedScene) -> Node:
	var rm := RoadManager.new()
	parent.add_child(rm)
	rm.setup(chunk_scene)
	return rm
