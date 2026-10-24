@tool
class_name PosePoint3DRuntime
extends RefCounted

## Optional runtime helper: apply the same editor-calibrated offset.
## character_id should match the character's editor identifier (default: node name).
static func place(character: Node3D, point: Marker3D, profile: PosePoint3DProfile, scene_id: String, character_id: String, point_id: String, animation_name: String) -> bool:
	if character == null or point == null or profile == null:
		return false
	var template := ""
	if point is PosePoint3DMarker:
		template = (point as PosePoint3DMarker).template_key
	var offset: Variant = profile.get_pose(scene_id, character_id, point_id, template, animation_name)
	if not offset is Transform3D:
		return false
	var scale := character.global_transform.basis.get_scale()
	var target: Transform3D = point.global_transform * Transform3D(offset)
	character.global_transform = Transform3D(target.basis.orthonormalized().scaled(scale), target.origin)
	return true
