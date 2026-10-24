# PosePoint3D

A standalone **Godot 4 editor plugin** for calibrating a 3D character's position and orientation against reusable action markers (chairs, beds, counters, etc.). Designed for projects using an `AnimationPlayer`, without a required NPC framework.

## Features

- Find scene characters with an `AnimationPlayer`; works with `Node3D` and `CharacterBody3D` roots.
- Create and place `PosePoint3DMarker` nodes in any 3D scene.
- Preview a selected animation pose on the **existing scene character**, then reposition it with Godot's built-in 3D gizmo.
- Optional ground snapping (collision layer 1).
- Save the offset relative to the marker as a `.tres` resource; scale is excluded.
- Reuse pose offsets between matching markers within a saved scene profile using their `template_key` values.
- End preview restores the scene character and animation state rather than saving a temporary offset into the map.
- Optional runtime utility to apply saved offsets.

## Compatibility

Release status: **1.0.0 (Godot 4.7.2)**. Automated editor loading, runtime smoke tests, editor integration workflow, and visible GUI startup passed. Manual mouse-driven gizmo interaction is not yet independently verified.

The plugin targets **Godot 4.7.2**. Older 4.x versions use similar APIs, but they have not yet been validated. Test the plugin in a disposable project before production use.

## Install

1. Copy `addons/posepoint3d` into your Godot project's `res://addons/` folder.
2. Enable **PosePoint3D** under **Project > Project Settings > Plugins**.
3. Open a saved 3D scene with a character containing an `AnimationPlayer`.
4. Add a `PosePoint3DMarker` in the scene tree (or use **Add marker at character**). A marker can be parented to a furniture node so it follows that furniture.
5. Open the PosePoint3D dock and click **Refresh scene**.
6. Choose a character, marker, and animation; click **Begin calibration**.
7. Use the editor's 3D move/rotate tools to adjust the character, then click **Save pose offset**.

Calibration resources are written to `res://posepoint3d_profiles/`. Commit these resources to your project so runtime scenes can reuse them.

## Demo

For executable checks and recorded results, see [validation report](tests/VALIDATION.md).

This repository is also a minimal Godot project. Open `demo/demo.tscn`, enable the plugin, select `DemoCharacter`, `PoseMarker` and the `sit` animation. Calibrate against the sample chair. No third-party assets are required.

## Runtime integration

The plugin doesn't impose a particular NPC controller. Invoke the helper when an NPC arrives at an interaction marker:

```gdscript
const PoseRuntime = preload("res://addons/posepoint3d/pose_runtime.gd")
var profile: PosePoint3DProfile = load("res://posepoint3d_profiles/<your-scene-profile>.tres")
PoseRuntime.place(character, marker, profile, scene_path, character.name, str(scene_root.get_path_to(marker)), "sit")
```

For reusable furniture markers, set their `template_key` in the inspector and use the **same character identifier** and animation name. To stabilize character identifiers after renaming nodes, set node metadata `posepoint_character_id` to your chosen ID before calibration.

## Behavior and limitations

- Saves offset and rotation (not scale); it does not retarget or generate animations.
- Ground snapping requires floor colliders on physics layer 1. It operates only while the NPC's position is dragged during a calibration session.
- The plugin previews the first animation frame. Skeleton and child node transforms are restored when a session ends; project-specific scripts that modify characters inside the editor should be disabled while calibrating.
- Character names and marker paths are identifiers. Keep them stable or recalibrate after renaming; template keys are reusable across scenes.
- Profiles are saved per source scene; the demo is a small example and does not include a scheduling system.

## License

MIT License. See [LICENSE](LICENSE).

## Contributing

Bug reports, reproducible test scenes, and compatibility improvements are welcome through GitHub issues and pull requests.
