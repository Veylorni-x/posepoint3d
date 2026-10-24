# Smoke test

With Godot 4.7.2 available on your system, run from this repository's root:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/smoke_test.gd
```

First command imports editor scripts and enables the plugin; the second checks resource offsets, template reuse, scale preservation and absent poses. See [VALIDATION.md](VALIDATION.md) for the independent Godot 4.7.2 verification results. Visual mouse-driven editing remains a separate acceptance test.
