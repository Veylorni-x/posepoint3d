# Changelog

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
