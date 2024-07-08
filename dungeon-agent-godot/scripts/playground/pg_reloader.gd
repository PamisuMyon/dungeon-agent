extends Node


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_R:
			App.save.reset()
			get_tree().reload_current_scene()
