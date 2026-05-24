extends Area3D

# Mobil pemain. Selalu maju (treadmill: dunia yang bergerak), gas/rem mengatur
# kecepatan scroll, geser kiri-kanan = hop antar-lane diskrit (visual halus).

const BODY := Vector3(2.0, 1.2, 4.0)
const CarModel := preload("res://assets/models/vehicles/Car.FBX")
const TILT_MAX := 0.25                 # kemiringan (radian) saat geser lane
const TILT_RECOVER := 8.0              # kecepatan kembali tegak
const TIRE_DB := -10.0                 # decit ban dibuat pelan
const ACCEL_DB := -4.0                 # suara akselerasi (loop selama gas ditahan)

var current_col: int = GameConfig.PLAYER_START_COL
var speed: float = 0.0
var _model: Node3D
var _engine: AudioStreamPlayer
var _accel: AudioStreamPlayer


func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask = 2 | 4          # deteksi traffic (2) & ayam (4)
	_build()
	speed = GameConfig.CRUISE_SPEED
	position = Vector3(GridUtils.col_x(current_col), 0.0, GameConfig.PLAYER_Z)
	area_entered.connect(_on_area_entered)
	GameState.game_over_changed.connect(func(over: bool) -> void:
		if over:
			if _engine != null:
				_engine.stop()
			if _accel != null:
				_accel.stop())
	_setup_engine()
	_setup_accel()


func _build() -> void:
	_model = Build3D.model(CarModel, BODY.z, GameConfig.MODEL_YAW_CAR)
	add_child(_model)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = BODY
	cs.shape = shape
	cs.position.y = BODY.y * 0.5
	add_child(cs)


func _setup_engine() -> void:
	_engine = AudioStreamPlayer.new()
	_engine.bus = "SFX"
	var s: AudioStream = Audio.SFX_ENGINE
	if s is AudioStreamWAV:
		(s as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	_engine.stream = s
	add_child(_engine)
	# Tidak di-play() di sini: dijalankan lazily di _process. Di menu judul
	# _process dimatikan, jadi suara engine tidak ikut berbunyi sebagai backdrop.


func _setup_accel() -> void:
	_accel = AudioStreamPlayer.new()
	_accel.bus = "SFX"
	_accel.volume_db = ACCEL_DB
	var s: AudioStream = Audio.SFX_ACCEL
	if s is AudioStreamWAV:
		var w := s as AudioStreamWAV          # loop selama gas ditahan
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * w.mix_rate)
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_accel.stream = s
	add_child(_accel)


func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
	if not _engine.playing:
		_engine.play()
	GameState.time_survived += delta

	# Gas naikkan ke max; rem HANYA turunkan sampai kecepatan base (CRUISE).
	var target := GameConfig.CRUISE_SPEED
	var rate := GameConfig.ACCEL
	if Input.is_action_pressed("gas"):
		target = GameConfig.MAX_SPEED
	elif Input.is_action_pressed("brake"):
		target = GameConfig.CRUISE_SPEED
		rate = GameConfig.BRAKE_DECEL
	speed = move_toward(speed, target, rate * delta)
	# Suara akselerasi hanya berbunyi selama tombol gas ditahan.
	if Input.is_action_just_pressed("gas"):
		_accel.play()
	if Input.is_action_just_released("gas"):
		_accel.stop()

	# Pitch engine mengikuti kecepatan (CRUISE -> MAX  =>  1.0 -> 1.5).
	var t := clampf((speed - GameConfig.CRUISE_SPEED) \
		/ (GameConfig.MAX_SPEED - GameConfig.CRUISE_SPEED), 0.0, 1.0)
	_engine.pitch_scale = lerpf(1.0, 1.5, t)

	var bonus := GameState.escalation_step * GameConfig.SCROLL_BONUS_PER_STEP
	GameState.scroll_speed = speed + bonus
	GameState.add_distance(GameState.scroll_speed * delta)

	# Hop antar-lane (diskrit) + decit ban + miring sesaat ke arah pindah.
	if Input.is_action_just_pressed("lane_left") and current_col > GameConfig.FIRST_LANE:
		current_col -= 1
		Audio.play_sfx(Audio.SFX_TIRE, 1.0, TIRE_DB)
		_model.rotation.z = TILT_MAX
	if Input.is_action_just_pressed("lane_right") and current_col < GameConfig.LAST_LANE:
		current_col += 1
		Audio.play_sfx(Audio.SFX_TIRE, 1.0, TIRE_DB)
		_model.rotation.z = -TILT_MAX
	var tx := GridUtils.col_x(current_col)
	position.x = lerp(position.x, tx, clampf(delta * GameConfig.HOP_LERP, 0.0, 1.0))
	_model.rotation.z = lerpf(_model.rotation.z, 0.0, clampf(delta * TILT_RECOVER, 0.0, 1.0))


func _on_area_entered(area: Area3D) -> void:
	if GameState.is_game_over:
		return
	if area.is_in_group("chicken"):
		GameState.trigger_game_over("chicken")
	elif area.is_in_group("traffic"):
		GameState.trigger_game_over("car")
