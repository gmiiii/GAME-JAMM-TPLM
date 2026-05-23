extends Area3D

# Mobil pemain. Selalu maju (treadmill: dunia yang bergerak), gas/rem mengatur
# kecepatan scroll, geser kiri-kanan = hop antar-lane diskrit (visual halus).

const BODY := Vector3(2.0, 1.2, 4.0)

var current_col: int = GameConfig.PLAYER_START_COL
var speed: float = 0.0


func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask = 2 | 4          # deteksi traffic (2) & ayam (4)
	_build()
	speed = GameConfig.CRUISE_SPEED
	position = Vector3(GridUtils.col_x(current_col), BODY.y * 0.5, GameConfig.PLAYER_Z)
	area_entered.connect(_on_area_entered)


func _build() -> void:
	add_child(Build3D.box(BODY, GameConfig.COL_PLAYER))
	var cabin := Build3D.box(Vector3(1.6, 0.8, 1.8), GameConfig.COL_PLAYER.darkened(0.25))
	cabin.position = Vector3(0, 0.9, -0.3)
	add_child(cabin)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = BODY
	cs.shape = shape
	add_child(cs)


func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
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

	var bonus := GameState.escalation_step * GameConfig.SCROLL_BONUS_PER_STEP
	GameState.scroll_speed = speed + bonus
	GameState.add_distance(GameState.scroll_speed * delta)

	# Hop antar-lane (diskrit), digerakkan halus secara visual.
	if Input.is_action_just_pressed("lane_left"):
		current_col = max(GameConfig.FIRST_LANE, current_col - 1)
	if Input.is_action_just_pressed("lane_right"):
		current_col = min(GameConfig.LAST_LANE, current_col + 1)
	var tx := GridUtils.col_x(current_col)
	position.x = lerp(position.x, tx, clampf(delta * GameConfig.HOP_LERP, 0.0, 1.0))


func _on_area_entered(area: Area3D) -> void:
	if GameState.is_game_over:
		return
	if area.is_in_group("chicken"):
		GameState.trigger_game_over("chicken")
	elif area.is_in_group("traffic"):
		GameState.trigger_game_over("car")
