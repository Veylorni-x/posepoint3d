@tool
extends VBoxContainer

const Profile = preload("res://addons/posepoint3d/pose_profile.gd")
const Point = preload("res://addons/posepoint3d/pose_point.gd")

const GROUND_MASK := 1
const GROUND_RAY_UP := 0.25
const GROUND_RAY_DOWN := 4.0
const GROUND_MAX_STEP_UP := 0.2
const GROUND_MIN_NORMAL_Y := 0.65

var _plugin: EditorPlugin
var _characters: Array[Node3D] = []
var _points: Array[Marker3D] = []
var _character_option: OptionButton
var _point_option: OptionButton
var _animation_option: OptionButton
var _snap_toggle: CheckBox
var _status: Label
var _active_character: Node3D
var _active_point: Marker3D
var _active_animation: String = ""
var _player: AnimationPlayer
var _previous: Dictionary = {}
var _foot_marker: Node3D
var _profile: PosePoint3DProfile
var _reference_ground_y := 0.0
var _last_origin := Vector3.ZERO
var _scene_identity := ""

func setup(plugin: EditorPlugin) -> void:
	_plugin = plugin
	refresh_scene()

func _ready() -> void:
	add_theme_constant_override("separation", 7)
	var header := Label.new()
	header.text = "PosePoint3D"
	header.add_theme_font_size_override("font_size", 18)
	add_child(header)
	var refresh := Button.new()
	refresh.text = "Refresh scene"
	refresh.pressed.connect(refresh_scene)
	add_child(refresh)
	_character_option = _option("Character", _on_character_selected)
	_point_option = _option("Pose marker", _on_point_selected)
	_animation_option = _option("Animation", _on_animation_selected)
	var add_marker := Button.new()
	add_marker.text = "Add marker at character"
	add_marker.pressed.connect(_add_marker)
	add_child(add_marker)
	_snap_toggle = CheckBox.new()
	_snap_toggle.text = "Snap to ground while dragging"
	_snap_toggle.button_pressed = true
	add_child(_snap_toggle)
	var start := Button.new()
	start.text = "Begin calibration"
	start.pressed.connect(begin_preview)
	add_child(start)
	var save := Button.new()
	save.text = "Save pose offset"
	save.pressed.connect(save_pose)
	add_child(save)
	var stop := Button.new()
	stop.text = "End preview / restore character"
	stop.pressed.connect(finish_preview)
	add_child(stop)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status)
	_status.text = "Open a saved 3D scene, then refresh."
	set_process(true)

func _option(title: String, callback: Callable) -> OptionButton:
	var label := Label.new()
	label.text = title
	add_child(label)
	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.item_selected.connect(callback)
	add_child(option)
	return option

func refresh_scene() -> void:
	finish_preview()
	if not is_instance_valid(_character_option):
		return
	_characters.clear()
	_points.clear()
	_character_option.clear()
	_point_option.clear()
	_animation_option.clear()
	var root := EditorInterface.get_edited_scene_root()
	if not root is Node3D:
		_say("Open a 3D scene before using the editor.")
		return
	_collect(root)
	for character in _characters:
		_character_option.add_item(str(root.get_path_to(character)))
	for point in _points:
		_point_option.add_item(str(root.get_path_to(point)))
	if not _characters.is_empty():
		_on_character_selected(0)
	if not _points.is_empty():
		_point_option.select(0)
	_say("%d characters; %d markers." % [_characters.size(), _points.size()])

func _collect(root: Node) -> void:
	for child in root.get_children():
		if child is Node3D:
			if child is PosePoint3DMarker:
				_points.append(child)
			if _find_player(child) != null and not _has_character_ancestor(child):
				_characters.append(child)
		_collect(child)

func _has_character_ancestor(child: Node) -> bool:
	var parent := child.get_parent()
	while parent != null:
		if parent in _characters:
			return true
		parent = parent.get_parent()
	return false

func _find_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root
	for child in root.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null

func _on_character_selected(index: int) -> void:
	finish_preview()
	_animation_option.clear()
	if index < 0 or index >= _characters.size():
		return
	var player := _find_player(_characters[index])
	if player == null:
		return
	for anim in player.get_animation_list():
		_animation_option.add_item(str(anim))
	if _animation_option.item_count > 0:
		_animation_option.select(0)

func _on_point_selected(_index: int) -> void:
	finish_preview()

func _on_animation_selected(_index: int) -> void:
	finish_preview()

func _add_marker() -> void:
	finish_preview()
	var root := EditorInterface.get_edited_scene_root() as Node3D
	if root == null:
		_say("Open a 3D scene first.")
		return
	var point := Point.new()
	point.name = "PoseMarker"
	root.add_child(point, true)
	point.owner = root
	if _character_option.selected >= 0 and _character_option.selected < _characters.size():
		var original := _characters[_character_option.selected].global_transform
		point.global_transform = Transform3D(original.basis.orthonormalized(), original.origin)
	EditorInterface.mark_scene_as_unsaved()
	refresh_scene()
	for index in _points.size():
		if _points[index] == point:
			_point_option.select(index)
			break
	_say("Marker created. Save the scene to keep it.")

func _selected_context() -> bool:
	if _character_option.selected < 0 or _character_option.selected >= _characters.size():
		_say("Select a character with an AnimationPlayer.")
		return false
	if _point_option.selected < 0 or _point_option.selected >= _points.size():
		_say("Add or select a PosePoint3D marker.")
		return false
	if _animation_option.selected < 0:
		_say("Select an animation.")
		return false
	var root := EditorInterface.get_edited_scene_root()
	if root == null or root.scene_file_path.is_empty():
		_say("Save your scene before calibrating.")
		return false
	return true

func _profile_path() -> String:
	var root := EditorInterface.get_edited_scene_root()
	var path := root.scene_file_path
	var suffix := path.sha256_text().substr(0, 10)
	return "res://posepoint3d_profiles/%s_%s.tres" % [path.get_file().get_basename(), suffix]

func _load_profile() -> PosePoint3DProfile:
	var path := _profile_path()
	if ResourceLoader.exists(path):
		return load(path) as PosePoint3DProfile
	return Profile.new()

func _context_ids() -> Array[String]:
	var root := EditorInterface.get_edited_scene_root()
	var npc_key := str(_active_character.get_meta("posepoint_character_id", _active_character.name))
	var point_key := str(root.get_path_to(_active_point))
	return [root.scene_file_path, npc_key, point_key]

func begin_preview() -> void:
	finish_preview()
	if not _selected_context():
		return
	_active_character = _characters[_character_option.selected]
	_active_point = _points[_point_option.selected]
	_active_animation = _animation_option.get_item_text(_animation_option.selected)
	_player = _find_player(_active_character)
	if not is_instance_valid(_player) or not _player.has_animation(_active_animation):
		_say("Selected animation is not available.")
		_active_character = null
		return
	_profile = _load_profile()
	if _profile == null:
		_say("The stored profile uses an incompatible resource type.")
		_active_character = null
		return
	_save_character_state()
	_scene_identity = EditorInterface.get_edited_scene_root().scene_file_path
	var keys := _context_ids()
	var offset: Variant = _profile.get_pose(keys[0], keys[1], keys[2], _template_key(), _active_animation)
	var scale := _active_character.global_transform.basis.get_scale()
	var target := _active_point.global_transform
	if offset is Transform3D:
		target = target * Transform3D(offset)
	_active_character.global_transform = Transform3D(target.basis.orthonormalized().scaled(scale), target.origin)
	_player.play(_active_animation)
	_player.seek(0.0, true)
	_player.pause()
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	_foot_marker = _active_character.find_child("FootMarker", true, false) as Node3D
	_last_origin = _active_character.global_position
	_reference_ground_y = _foot_position().y
	EditorInterface.set_main_screen_editor("3D")
	var selected := EditorInterface.get_selection()
	selected.clear()
	selected.add_node(_active_character)
	_say("Move/rotate the character using Godot's 3D gizmo, then save. Scale is not stored.")

func _template_key() -> String:
	if _active_point is PosePoint3DMarker:
		return (_active_point as PosePoint3DMarker).template_key.strip_edges()
	return ""

func _save_character_state() -> void:
	_previous = {
		"global": _active_character.global_transform,
		"player_animation": _player.current_animation,
		"player_position": _player.current_animation_position if not _player.current_animation.is_empty() else 0.0,
		"player_playing": _player.is_playing(),
		"player_process_mode": _player.process_mode,
		"nodes": {},
		"bones": {},
	}
	for node in _active_character.find_children("*", "Node3D", true, false):
		_previous["nodes"][node] = (node as Node3D).transform
		if node is Skeleton3D:
			var values: Array[Transform3D] = []
			for bone in (node as Skeleton3D).get_bone_count():
				values.append((node as Skeleton3D).get_bone_pose(bone))
			_previous["bones"][node] = values
	# Keep editor animation sampling functional; pause after seeking.

func save_pose() -> void:
	if not is_instance_valid(_active_character) or not is_instance_valid(_active_point) or _profile == null:
		_say("Begin calibration first.")
		return
	var keys := _context_ids()
	var world := Transform3D(_active_character.global_transform.basis.orthonormalized(), _active_character.global_position)
	var relative := _active_point.global_transform.affine_inverse() * world
	var old_points := _profile.point_poses.duplicate(true)
	var old_templates := _profile.template_poses.duplicate(true)
	_profile.put_pose(keys[0], keys[1], keys[2], _template_key(), _active_animation, relative)
	var path := _profile_path()
	var directory := path.get_base_dir()
	var err := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	if err == OK:
		err = ResourceSaver.save(_profile, path)
	if err != OK:
		_profile.point_poses = old_points
		_profile.template_poses = old_templates
		_say("Save failed (error %d). The preview is still active." % err)
		return
	finish_preview()
	_say("Saved: %s. The original character has been restored." % path)

func finish_preview() -> void:
	if not is_instance_valid(_active_character):
		_active_character = null
		_active_point = null
		_player = null
		_previous.clear()
		return
	var character := _active_character
	if not _previous.is_empty():
		if is_instance_valid(_player):
			var anim := str(_previous.get("player_animation", ""))
			if not anim.is_empty() and _player.has_animation(anim):
				_player.play(anim)
				_player.seek(float(_previous.get("player_position", 0.0)), true)
				if not bool(_previous.get("player_playing", false)):
					_player.pause()
			else:
				_player.stop()
			_player.process_mode = int(_previous.get("player_process_mode", Node.PROCESS_MODE_INHERIT))
		for node in _previous.get("nodes", {}):
			if is_instance_valid(node):
				(node as Node3D).transform = _previous["nodes"][node]
		for rig in _previous.get("bones", {}):
			if is_instance_valid(rig):
				var values: Array = _previous["bones"][rig]
				for i in values.size():
					(rig as Skeleton3D).set_bone_pose(i, values[i])
		character.global_transform = _previous.get("global", character.global_transform)
	_active_character = null
	_active_point = null
	_player = null
	_previous.clear()

func _process(_delta: float) -> void:
	if not is_instance_valid(_active_character) or not is_instance_valid(_active_point):
		return
	var root := EditorInterface.get_edited_scene_root()
	if root == null or root.scene_file_path != _scene_identity or not root.is_ancestor_of(_active_character):
		finish_preview()
		return
	var current := _active_character.global_position
	if current.is_equal_approx(_last_origin):
		return
	if _snap_toggle.button_pressed:
		_snap_to_ground()
	_last_origin = _active_character.global_position

func _foot_position() -> Vector3:
	if is_instance_valid(_foot_marker):
		return _foot_marker.global_position
	return _active_character.global_position

func _snap_to_ground() -> void:
	var world := _active_character.get_world_3d()
	if world == null:
		return
	var foot := _foot_position()
	var start := Vector3(foot.x, _reference_ground_y + GROUND_RAY_UP, foot.z)
	var finish := Vector3(foot.x, _reference_ground_y - GROUND_RAY_DOWN, foot.z)
	var exclusions: Array[RID] = []
	if _active_character is CollisionObject3D:
		exclusions.append((_active_character as CollisionObject3D).get_rid())
	for child in _active_character.find_children("*", "CollisionObject3D", true, false):
		exclusions.append((child as CollisionObject3D).get_rid())
	for attempt in 6:
		var query := PhysicsRayQueryParameters3D.create(start, finish, GROUND_MASK, exclusions)
		var hit := world.direct_space_state.intersect_ray(query)
		if hit.is_empty():
			return
		var normal: Vector3 = hit.get("normal", Vector3.ZERO)
		var position: Vector3 = hit.get("position", Vector3.ZERO)
		if normal.y >= GROUND_MIN_NORMAL_Y and position.y <= _reference_ground_y + GROUND_MAX_STEP_UP:
			var transform_value := _active_character.global_transform
			transform_value.origin.y += position.y - foot.y
			_active_character.global_transform = transform_value
			_reference_ground_y = position.y
			return
		var collider: Variant = hit.get("collider")
		if not collider is CollisionObject3D:
			return
		exclusions.append((collider as CollisionObject3D).get_rid())

func _say(message: String) -> void:
	if is_instance_valid(_status):
		_status.text = message
