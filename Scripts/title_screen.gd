extends Control


func _on_start_pressed() -> void:
	OpenButtonSfx.play()
	await OpenButtonSfx.finished
	get_tree().change_scene_to_file("res://Scenes/main_map.tscn")
	pass

func _on_credits_pressed() -> void:
	OpenButtonSfx.play()
	%UI.hide()
	$CreditsScreen.show()
