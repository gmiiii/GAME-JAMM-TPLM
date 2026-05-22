extends Area2D
## Bot car: gerak mulus horizontal kecepatan konstan. Hanya jadi bahaya bagi pemain.
## BotManager yang mengatur posisi & recycle; di sini hanya visual + bentuk tabrakan.

var width_cells: int = 2
var speed: float = 120.0
var color: Color = Color.WHITE
var dir: int = 1

@onready var _shape: CollisionShape2D = CollisionShape2D.new()


func _ready() -> void:
	# Layer 2 = bot car. Tidak perlu memantau apa pun (pemain yang mendeteksi).
	collision_layer = 2
	collision_mask = 0
	monitoring = false
	add_child(_shape)


func setup(type_key: String, lane_dir: int) -> void:
	var data: Dictionary = GameConfig.CARS[type_key]
	width_cells = int(data["w"])
	speed = float(data["speed"])
	color = data["color"]
	dir = lane_dir
	var rect := RectangleShape2D.new()
	rect.size = Vector2(width_cells * GameConfig.CELL - 4, GameConfig.CELL - 6)
	_shape.shape = rect
	_shape.position = Vector2(width_cells * GameConfig.CELL * 0.5, GameConfig.CELL * 0.5)
	queue_redraw()


func width_px() -> float:
	return width_cells * GameConfig.CELL


func _draw() -> void:
	var w := width_px()
	var h := float(GameConfig.CELL)
	var body := Rect2(2, 3, w - 4, h - 6)
	draw_rect(body, color, true)
	draw_rect(body, Color(0, 0, 0, 0.35), false, 1.5)
	# kaca depan menghadap arah jalan
	var glass_w := w * 0.22
	var gx := (w - glass_w - 6.0) if dir > 0 else 6.0
	draw_rect(Rect2(gx, 8, glass_w, h - 16), Color(0.7, 0.85, 1.0, 0.55), true)
	# roda
	var wheel := Color(0.1, 0.1, 0.1)
	draw_rect(Rect2(w * 0.15, h - 6, w * 0.18, 5), wheel, true)
	draw_rect(Rect2(w * 0.67, h - 6, w * 0.18, 5), wheel, true)
