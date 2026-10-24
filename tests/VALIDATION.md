# PosePoint3D validation report

Date: 2026-10-24
Engine: Godot 4.7.2 stable (official), Windows x86_64
Repository: public `main` branch, independently cloned for testing.

## Automated checks

| Check | Result |
| --- | --- |
| Fresh clone: `godot --headless --path . --editor --quit` | PASS (exit 0) |
| Fresh clone: `godot --headless --path . --script res://tests/smoke_test.gd` | PASS (exit 0, `PosePoint3D smoke tests passed`) |
| Editor plugin installation and dock discovery | PASS |
| Demo scene character and marker discovery | PASS |
| Begin calibration on existing character | PASS |
| Move character, save offset to `.tres`, restore original transform | PASS |
| Reload saved offset into a new calibration preview | PASS |
| End preview and restore original transform | PASS |
| Cast ground-snapping ray against the demonstration floor collider | PASS |

The editor end-to-end checks used a **temporary test plugin in an isolated clone**, enabled only for validation. The temporary test plugin and generated pose data are not part of the public release.

## Fixed issues identified by actual engine execution

1. Demo scene contained an incomplete `.tscn` node header. Corrected.
2. Smoke test read global transforms before the SceneTree was initialized. Deferred assertions until idle initialization.
3. Preview state capture accessed `AnimationPlayer.current_animation_position` even when no animation had been started. Guarded the query.

## Remaining acceptance check

Mouse-driven GUI interaction in a visible Godot editor (dragging with the gizmo, toggling the snap-to-ground control, and visual inspection) has not been independently completed. Engine-executed editor automation covered the related save/restore and ground-ray code paths.
