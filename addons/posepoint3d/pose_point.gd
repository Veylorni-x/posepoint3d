@tool
class_name PosePoint3DMarker
extends Marker3D

## Points with the same template key reuse saved character/animation offsets.
## Leave empty to calibrate the point separately on each scene.
@export var template_key: String = ""
