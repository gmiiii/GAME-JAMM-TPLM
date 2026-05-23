extends Node3D

# Satu potong jalan: aspal + bahu + rumput + marka lane. Visual saja.

func build() -> void:
	var road_w := GameConfig.DRIVE_LANES * GameConfig.LANE_W
	var sh_w := GameConfig.LANE_W
	var grass_w := 24.0
	var l := GameConfig.CHUNK_LEN

	# Aspal
	var road := Build3D.box(Vector3(road_w, 0.1, l), GameConfig.COL_ROAD)
	add_child(road)

	# Bahu kiri & kanan (tempat ayam spawn)
	var ls := Build3D.box(Vector3(sh_w, 0.12, l), GameConfig.COL_SHOULDER)
	ls.position = Vector3(-(road_w * 0.5 + sh_w * 0.5), 0, 0)
	add_child(ls)
	var rs := Build3D.box(Vector3(sh_w, 0.12, l), GameConfig.COL_SHOULDER)
	rs.position = Vector3(road_w * 0.5 + sh_w * 0.5, 0, 0)
	add_child(rs)

	# Rumput di luar bahu
	var lg := Build3D.box(Vector3(grass_w, 0.08, l), GameConfig.COL_GRASS)
	lg.position = Vector3(-(road_w * 0.5 + sh_w + grass_w * 0.5), -0.02, 0)
	add_child(lg)
	var rg := Build3D.box(Vector3(grass_w, 0.08, l), GameConfig.COL_GRASS)
	rg.position = Vector3(road_w * 0.5 + sh_w + grass_w * 0.5, -0.02, 0)
	add_child(rg)

	# Marka antar-lane
	for i in range(1, GameConfig.DRIVE_LANES):
		var lx := -road_w * 0.5 + i * GameConfig.LANE_W
		var line := Build3D.box(Vector3(0.12, 0.02, l * 0.6), GameConfig.COL_LINE)
		line.position = Vector3(lx, 0.07, 0)
		add_child(line)
