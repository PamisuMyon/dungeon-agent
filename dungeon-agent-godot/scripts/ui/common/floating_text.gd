class_name FloatingText
extends Control

signal popup_finished(floating_text: FloatingText)

var _cam: Camera3D
var cam: Camera3D:
	get:
		if _cam == null:
			_cam = get_viewport().get_camera_3d()
		return _cam
	

@onready var label: Label = $Label


func show_at_world_pos_3d(world_pos: Vector3, content: String):
	if cam.is_position_behind(world_pos):
		return
	label.text = content
	var viewport_pos = cam.unproject_position(world_pos)
	global_position = viewport_pos


# TODO animation
func popup_at_world_pos_3d(world_pos: Vector3, content: String, color: Color, duration: float = 1.):
	if cam.is_position_behind(world_pos):
		return
	visible = true
	label.text = content
	label.set("theme_override_colors/font_color", color)
	var viewport_pos = cam.unproject_position(world_pos)
	global_position = viewport_pos
	await get_tree().create_timer(duration).timeout
	visible = false
	popup_finished.emit(self)
