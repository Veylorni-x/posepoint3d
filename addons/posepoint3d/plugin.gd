@tool
extends EditorPlugin

const Dock = preload("res://addons/posepoint3d/pose_dock.gd")
var _dock: Control

func _enter_tree() -> void:
	_dock = Dock.new()
	_dock.name = "PosePoint3D"
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)
	_dock.call("setup", self)

func _exit_tree() -> void:
	if is_instance_valid(_dock):
		_dock.call("finish_preview")
		remove_control_from_docks(_dock)
		_dock.queue_free()
	_dock = null

func _apply_changes() -> void:
	# The preview is temporary. Never serialize a dragged character into the map.
	if is_instance_valid(_dock):
		_dock.call("finish_preview")
