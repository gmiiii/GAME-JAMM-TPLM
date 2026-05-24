class_name CameraShake
extends Camera3D

# Getaran kamera singkat (rotasi acak yang meluruh) untuk momen tabrakan.
# Script ini dipasang ke Camera3D oleh WorldBuilder.setup_camera().

var _time: float = 0.0
var _dur: float = 0.0
var _strength: float = 0.0
var _base_rot: Vector3


func shake(strength: float, duration: float) -> void:
	_base_rot = rotation          # tangkap arah pandang saat ini
	_strength = strength
	_dur = duration
	_time = duration


func _process(delta: float) -> void:
	if _time <= 0.0:
		return
	_time -= delta
	var k: float = clampf(_time / _dur, 0.0, 1.0)    # 1 -> 0 (meluruh)
	var amt: float = _strength * k
	rotation = _base_rot + Vector3(
		randf_range(-amt, amt),
		randf_range(-amt, amt),
		randf_range(-amt, amt))
	if _time <= 0.0:
		rotation = _base_rot
