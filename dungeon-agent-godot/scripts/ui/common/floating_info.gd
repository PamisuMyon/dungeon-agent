extends Control

@export var health_bar: TextureProgressBar

var chara: Character

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	set_process(false)


func _process(_delta: float) -> void:
	if not chara:
		return
	var world_pos = chara.global_position
	var cam := get_viewport().get_camera_3d()
	if cam.is_position_behind(world_pos):
		return
	var viewport_pos = cam.unproject_position(world_pos)
	viewport_pos.x -= size.x * .5
	viewport_pos.y -= size.y
	global_position = viewport_pos


func _on_mouse_entered() -> void:
	if chara:
		Events.req_show_character_info.emit(chara)


func _on_mouse_exited() -> void:
	if chara:
		Events.req_hide_character_info.emit(false)


func _on_health_changed(_delta: float, new_health: float):
	update_health(new_health, chara.attr_comp.get_value(Schema.AttributeType.MAX_HEALTH))


func on_spawn():
	visible = true


func on_release():
	visible = false


func bind(p_chara: Character):
	visible = true
	chara = p_chara
	chara.attr_comp.health_changed.connect(_on_health_changed)
	update_health(chara.attr_comp.get_value(Schema.AttributeType.HEALTH), chara.attr_comp.get_value(Schema.AttributeType.MAX_HEALTH))
	set_process(true)


func unbind():
	if chara == null:
		return
	# if chara != p_chara:
	# 	printerr("FloatingInfo unbind wrong character")
	# 	return false
	chara.attr_comp.health_changed.disconnect(_on_health_changed)
	chara = null
	set_process(false)
	# return true


func update_health(value: float, max_value: float):
	var progress = value / max_value
	health_bar.value = progress
