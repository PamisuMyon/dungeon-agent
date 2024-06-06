class_name FloatingText
extends Control

signal popup_finished(floating_text: FloatingText)

var _cam: Camera3D

@onready var label: Label = $Label


func _ready() -> void:
	_cam = get_viewport().get_camera_3d()


func show_at_world_pos_3d(world_pos: Vector3, content: String):
	if _cam.is_position_behind(world_pos):
		return
	label.text = content
	var viewport_pos = _cam.unproject_position(world_pos)
	global_position = viewport_pos


# TODO animation
func popup_at_world_pos_3d(world_pos: Vector3, content: String, color: Color, duration: float = 1.):
	if _cam.is_position_behind(world_pos):
		return
	visible = true
	label.text = content
	label.set("theme_override_colors/font_color", color)
	var viewport_pos = _cam.unproject_position(world_pos)
	global_position = viewport_pos
	await get_tree().create_timer(duration).timeout
	visible = false
	popup_finished.emit(self)
