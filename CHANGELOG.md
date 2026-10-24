# Changelog

## 1.0.0 — Initial stable release (2026-10-24)

- Independently verified on Godot 4.7.2, including script compilation, demo import, runtime smoke tests, and automated editor end-to-end checks.
- Launched the unmodified public repository in the visible Godot graphical editor and inspected the demonstration scene.
- All critical RC1 fixes are included: demo scene parser correction, initialization-safe smoke test and safe AnimationPlayer state capture.
- Mouse-driven gizmo interaction still requires a separate manual acceptance check; see [validation report](tests/VALIDATION.md).


## 1.0.0-rc1 — Initial public release candidate

- Standalone editor dock, pose markers, and pose profile resources.
- Calibration on existing scene characters, animation pose preview, and automatic restoration.
- Optional snap-to-ground while dragging.
- Reusable template offsets, example scene, runtime helper, and bilingual documentation.

This repository begins with a complete first release. Subsequent releases will document actual public bug fixes and enhancements.

- Validation: Godot 4.7.2 headless editor loading, script smoke tests, and isolated editor integration workflow passed. Visual mouse-driven checking remains pending.
- Fixed a malformed node declaration in the demo scene.
- Deferred smoke tests until scene tree initialization.
- Guarded the AnimationPlayer playback-position query when no animation is active.
