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


# Instansiasi model impor, auto-skala agar footprint (maks X/Z) = target_footprint,
# alas di y=0 & terpusat pada x/z. yaw_deg memutar model (untuk koreksi arah hadap).
static func model(scene: PackedScene, target_footprint: float, yaw_deg: float = 0.0) -> Node3D:
	var inst: Node3D = scene.instantiate()
	_hide_collision_meshes(inst)
	var aabb := _local_aabb(inst)
	var fp: float = maxf(aabb.size.x, aabb.size.z)
	var s: float = target_footprint / fp if fp > 0.0001 else 1.0
	inst.scale = Vector3(s, s, s)
	var center := aabb.position + aabb.size * 0.5
	inst.position = Vector3(-center.x * s, -aabb.position.y * s, -center.z * s)
	var holder := Node3D.new()         # holder memutar (yaw) di sekitar titik pusat
	holder.add_child(inst)
	holder.rotation.y = deg_to_rad(yaw_deg)
	return holder


# Sembunyikan mesh collision proxy bawaan FBX (prefix "UCX_") agar tidak terender.
static func _hide_collision_meshes(root: Node3D) -> void:
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var n := String(mi.name).to_upper()
		if n.begins_with("UCX") or n.contains("COLLISION"):
			mi.visible = false


static func _local_aabb(root: Node3D) -> AABB:
	var result := AABB()
	var first := true
	for vi in root.find_children("*", "VisualInstance3D", true, false):
		if vi is GeometryInstance3D and not (vi as GeometryInstance3D).visible:
			continue
		var a: AABB = vi.get_aabb()
		var rel := _rel_xform(root, vi)
		for i in range(8):
			var p: Vector3 = rel * a.get_endpoint(i)
			if first:
				result = AABB(p, Vector3.ZERO)
				first = false
			else:
				result = result.expand(p)
	return result


static func _rel_xform(root: Node3D, node: Node3D) -> Transform3D:
	var t := Transform3D.IDENTITY
	var n: Node = node
	while n != null and n != root:
		if n is Node3D:
			t = (n as Node3D).transform * t
		n = n.get_parent()
	return t
