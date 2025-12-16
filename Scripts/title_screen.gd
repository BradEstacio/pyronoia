extends Control


func _on_start_pressed() -> void:
	# Play sfx
	# get_tree().change_scene_to_file(...)
	pass

func _on_credits_pressed() -> void:
	$CreditsScreen.show()
