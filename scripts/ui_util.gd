class_name UiText
extends RefCounted

# Helper UI bersama: stroke/outline hitam untuk Label, dan tombol bertekstur
# yang sudah dilengkapi efek hover + bounce + bunyi klik.

# Stroke ala Crossy Road: teks putih, garis tepi hitam.
static func outline(label: Label, size: int = 6) -> void:
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", size)


# Buat TextureButton dengan lebar tetap (tinggi mengikuti rasio aspek) + efek.
static func texture_button(tex: Texture2D, width: float) -> TextureButton:
	var b := TextureButton.new()
	b.texture_normal = tex
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	var ts := tex.get_size()
	var h: float = width * ts.y / ts.x
	b.custom_minimum_size = Vector2(width, h)
	b.size = Vector2(width, h)
	b.pivot_offset = Vector2(width, h) * 0.5
	button_juice(b)
	return b


# Pasang efek: membesar saat hover, "punch" + bunyi klik saat ditekan.
static func button_juice(btn: Control) -> void:
	btn.mouse_entered.connect(func() -> void: _scale_to(btn, Vector2(1.08, 1.08)))
	btn.mouse_exited.connect(func() -> void: _scale_to(btn, Vector2.ONE))
	if btn is BaseButton:
		(btn as BaseButton).pressed.connect(func() -> void:
			Audio.play_sfx(Audio.SFX_CLICK)
			_punch(btn))


static func _scale_to(node: Control, s: Vector2) -> void:
	var tw := node.create_tween()
	tw.tween_property(node, "scale", s, 0.1).set_trans(Tween.TRANS_QUAD)


static func _punch(node: Control) -> void:
	var tw := node.create_tween()
	tw.tween_property(node, "scale", Vector2(1.15, 1.15), 0.06).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(node, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)
