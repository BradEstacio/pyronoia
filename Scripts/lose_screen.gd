extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_restart_pressed() -> void:
	OpenButtonSfx.play()
	await OpenButtonSfx.finished
	get_tree().change_scene_to_file("res://Scenes/map.tscn")


func _on_main_menu_pressed() -> void:
	CloseButtonSfx.play()
	await CloseButtonSfx.finished
	get_tree().change_scene_to_file("res://Scenes/Screens/title_scene.tscn")
