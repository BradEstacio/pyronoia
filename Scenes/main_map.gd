extends Node3D

var eye : Node
var eye_tween : Tween

func _ready() -> void:
	eye = get_node("Map3_Final-fix").get_node("Cube_014")

func _process(delta: float) -> void:
	if eye_tween:
		eye_tween.kill()
		
	if eye.position != Vector3(317.6, 316.6, -377.4):
		eye_tween = create_tween()
		eye_tween.tween_property(eye, 'position',Vector3(317.6, 316.6, -377.4), 220)
