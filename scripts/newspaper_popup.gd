extends Control

# Koran "BREAKING NEWS" yang muncul saat kalah karena ayam.
# Animasi: mulai kecil di tengah, berputar cepat, lalu menempel ke layar
# dengan sedikit overshoot ("slam & settle"). Emit `finished` setelah mantap.

signal finished

const NEWS_TEX := preload("res://assets/ui/newspaper.png")

# Tekstur koran; di-set oleh pemanggil sebelum add_child (default = mati ayam).
var tex: Texture2D = NEWS_TEX

var _dim: ColorRect
var _paper: TextureRect


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0.0)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)

	var vp := get_viewport_rect().size
	var ts := tex.get_size()
	var fit := minf(vp.x * 0.82 / ts.x, vp.y * 0.82 / ts.y)
	var paper_size := ts * fit

	_paper = TextureRect.new()
	_paper.texture = tex
	_paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_paper.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_paper.size = paper_size
	_paper.pivot_offset = paper_size * 0.5
	_paper.position = (vp - paper_size) * 0.5
	add_child(_paper)


# Posisi Y batas bawah koran (untuk menempatkan tombol di bawahnya).
func paper_bottom() -> float:
	return _paper.position.y + _paper.size.y


func play() -> void:
	Audio.play_sfx(Audio.SFX_NEWSPAPER)
	_paper.scale = Vector2(0.02, 0.02)
	_paper.rotation_degrees = -1080.0     # ~3 putaran

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_dim, "color", Color(0, 0, 0, 0.6), 0.3)
	tw.tween_property(_paper, "rotation_degrees", 0.0, 0.6) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(_paper, "scale", Vector2.ONE, 0.6) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.set_parallel(false)
	tw.tween_callback(func() -> void: finished.emit())
