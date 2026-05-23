class_name Build3D
extends RefCounted

# Helper bikin mesh placeholder (kotak berwarna). Dipakai semua entitas.
# Saat asset FBX masuk, node Model tinggal di-swap tanpa ubah logika.

static func box(size: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = size
	mi.mesh = m
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mi.material_override = mat
	return mi
