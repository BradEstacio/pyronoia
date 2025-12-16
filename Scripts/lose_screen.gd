extends Control


func _on_restart_pressed() -> void:
	pass # Replace with function body.


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
