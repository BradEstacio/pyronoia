extends Control


func _on_back_pressed() -> void:
	CloseButtonSfx.play()
	%Control.show()
	hide()
