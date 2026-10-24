extends SceneTree

const Profile = preload("res://addons/posepoint3d/pose_profile.gd")
const Marker = preload("res://addons/posepoint3d/pose_point.gd")
const Placement = preload("res://addons/posepoint3d/pose_runtime.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var profile: PosePoint3DProfile = Profile.new()
	var character := Node3D.new()
	var marker: Marker3D = Marker.new()
	get_root().add_child(character)
	get_root().add_child(marker)
	character.scale = Vector3(2, 2, 2)
	marker.position = Vector3(4, 0, 0)
	profile.put_pose("scene", "npc", "chair", "", "sit", Transform3D(Basis.IDENTITY, Vector3(0, 1, 0)))
	assert(Placement.place(character, marker, profile, "scene", "npc", "chair", "sit"))
	assert(character.global_position.is_equal_approx(Vector3(4, 1, 0)))
	assert(character.global_transform.basis.get_scale().is_equal_approx(Vector3(2, 2, 2)))
	assert(not Placement.place(character, marker, profile, "scene", "npc", "chair", "missing"))
	(marker as PosePoint3DMarker).template_key = "chair_basic"
	profile.put_pose("scene", "npc", "ignored", "chair_basic", "sit", Transform3D(Basis.IDENTITY, Vector3(0, 0, 2)))
	assert(Placement.place(character, marker, profile, "another_scene", "npc", "another_point", "sit"))
	assert(character.global_position.is_equal_approx(Vector3(4, 0, 2)))
	print("PosePoint3D smoke tests passed")
	quit(0)
