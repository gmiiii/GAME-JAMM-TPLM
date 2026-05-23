extends Node3D

# Satu potong jalan: aspal + bahu + rumput + marka lane + dekorasi. Visual saja.

const TreeModel := preload("res://assets/models/environment/props/bigtree.FBX")
const RockModel := preload("res://assets/models/environment/props/rock.FBX")
const LogModel := preload("res://assets/models/environment/props/log.FBX")


func build() -> void:
	var road_w := GameConfig.DRIVE_LANES * GameConfig.LANE_W
	var sh_w := GameConfig.LANE_W
	var grass_w := 24.0
	var l := GameConfig.CHUNK_LEN
	var lz := l + 0.15            # sedikit lebih panjang -> overlap, tak ada celah di sambungan

	# Aspal
	var road := Build3D.box(Vector3(road_w, 0.1, lz), GameConfig.COL_ROAD)
	add_child(road)

	# Bahu kiri & kanan (tempat ayam spawn)
	var ls := Build3D.box(Vector3(sh_w, 0.12, lz), GameConfig.COL_SHOULDER)
	ls.position = Vector3(-(road_w * 0.5 + sh_w * 0.5), 0, 0)
	add_child(ls)
	var rs := Build3D.box(Vector3(sh_w, 0.12, lz), GameConfig.COL_SHOULDER)
	rs.position = Vector3(road_w * 0.5 + sh_w * 0.5, 0, 0)
	add_child(rs)

	# Rumput di luar bahu
	var lg := Build3D.box(Vector3(grass_w, 0.08, lz), GameConfig.COL_GRASS)
	lg.position = Vector3(-(road_w * 0.5 + sh_w + grass_w * 0.5), -0.02, 0)
	add_child(lg)
	var rg := Build3D.box(Vector3(grass_w, 0.08, lz), GameConfig.COL_GRASS)
	rg.position = Vector3(road_w * 0.5 + sh_w + grass_w * 0.5, -0.02, 0)
	add_child(rg)

	# Marka antar-lane
	for i in range(1, GameConfig.DRIVE_LANES):
		var lx := -road_w * 0.5 + i * GameConfig.LANE_W
		var line := Build3D.box(Vector3(0.12, 0.02, l * 0.6), GameConfig.COL_LINE)
		line.position = Vector3(lx, 0.07, 0)
		add_child(line)

	_scatter_props(road_w, sh_w, grass_w, l)


# Sebar dekorasi (pohon/batu/log) di rumput, di luar bahu jalan.
func _scatter_props(road_w: float, sh_w: float, grass_w: float, l: float) -> void:
	var inner := road_w * 0.5 + sh_w
	var models := [TreeModel, RockModel, LogModel]
	var footprints := [3.0, 1.6, 2.2]
	for side in [-1.0, 1.0]:
		var sign_x: float = side
		for _i in range(randi_range(0, 2)):
			var pick := randi() % models.size()
			var prop := Build3D.model(models[pick], footprints[pick], randf() * 360.0)
			var px: float = sign_x * randf_range(inner + 1.5, inner + grass_w - 3.0)
			prop.position = Vector3(px, 0.0, randf_range(-l * 0.5, l * 0.5))
			add_child(prop)
