extends Control


func _on_back_pressed() -> void:
	CloseButtonSfx.play()
	hide()
	%UI.show()


func _on_attributions_button_pressed() -> void:
	OpenButtonSfx.play()
	$Control.hide()
	$Attributions.show()
