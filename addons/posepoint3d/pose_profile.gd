@tool
class_name PosePoint3DProfile
extends Resource

## The keys are internal scene/node identifiers, never local machine paths.
@export_storage var point_poses: Dictionary = {}
@export_storage var template_poses: Dictionary = {}

func get_pose(scene_id: String, character_id: String, point_id: String, template: String, animation: String) -> Variant:
	var key := _key(scene_id, character_id, point_id, template, animation)
	if not template.is_empty():
		return template_poses.get(key)
	return point_poses.get(key)

func put_pose(scene_id: String, character_id: String, point_id: String, template: String, animation: String, offset: Transform3D) -> void:
	var key := _key(scene_id, character_id, point_id, template, animation)
	var cleaned := Transform3D(offset.basis.orthonormalized(), offset.origin)
	if template.is_empty():
		point_poses[key] = cleaned
	else:
		template_poses[key] = cleaned
	emit_changed()

func _key(scene_id: String, character_id: String, point_id: String, template: String, animation: String) -> String:
	if not template.is_empty():
		return JSON.stringify([character_id, template, animation])
	return JSON.stringify([scene_id, character_id, point_id, animation])
