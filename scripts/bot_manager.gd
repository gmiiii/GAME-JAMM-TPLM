class_name BotManager
extends Node2D
## Membangkitkan & mengelola bot car tiap lane: jalan selalu penuh, dengan celah untuk lewat.

var _bot_scene: PackedScene
var _lanes: Array = []  ## tiap elemen: { "dir": int, "cars": Array[Area2D] }


func setup(bot_scene: PackedScene) -> void:
	_bot_scene = bot_scene
	for i in range(GameConfig.LANES.size()):
		_build_lane(i)


func _build_lane(index: int) -> void:
	var lane: Dictionary = GameConfig.LANES[index]
	var row: int = int(lane["row"])
	var dir: int = int(lane["dir"])
	var types: Array = GameConfig.LANE_CARS[index]
	var y := float(row * GameConfig.CELL)
	var field_w := float(GameConfig.field_width_px())

	var cars: Array = []
	# Isi dari sebelum tepi kiri sampai melewati tepi kanan agar mulus saat recycle.
	var x := -float(GameConfig.CELL * (randi() % GameConfig.CAR_GAP_MAX))
	var guard := 0
	while x < field_w + GameConfig.CELL and guard < 64:
		guard += 1
		var type_key: String = types[randi() % types.size()]
		var car := _spawn_car(type_key, dir, x, y)
		cars.append(car)
		var gap := GameConfig.CAR_GAP_MIN + (randi() % (GameConfig.CAR_GAP_MAX - GameConfig.CAR_GAP_MIN + 1))
		x += car.width_px() + gap * GameConfig.CELL

	_lanes.append({ "dir": dir, "cars": cars })


func _spawn_car(type_key: String, dir: int, x: float, y: float) -> Area2D:
	var car: Area2D = _bot_scene.instantiate()
	add_child(car)
	car.setup(type_key, dir)
	car.position = Vector2(x, y)
	return car


func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
	var field_w := float(GameConfig.field_width_px())
	for lane in _lanes:
		var dir: int = lane["dir"]
		var cars: Array = lane["cars"]
		for car in cars:
			car.position.x += car.speed * dir * delta
		# Recycle mobil yang sudah keluar layar ke ujung barisan.
		for car in cars:
			if dir > 0 and car.position.x > field_w:
				car.position.x = _train_min_x(cars) - car.width_px() - _gap_px()
			elif dir < 0 and car.position.x + car.width_px() < 0.0:
				car.position.x = _train_max_x(cars) + _gap_px()


func _gap_px() -> float:
	var gap := GameConfig.CAR_GAP_MIN + (randi() % (GameConfig.CAR_GAP_MAX - GameConfig.CAR_GAP_MIN + 1))
	return gap * GameConfig.CELL


func _train_min_x(cars: Array) -> float:
	var m := INF
	for car in cars:
		m = minf(m, car.position.x)
	return m


func _train_max_x(cars: Array) -> float:
	var m := -INF
	for car in cars:
		m = maxf(m, car.position.x + car.width_px())
	return m
