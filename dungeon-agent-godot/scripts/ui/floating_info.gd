extends Control

var chara: Character

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	# set_process(false)


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


func bind(p_chara: Character):
	visible = true
	chara = p_chara
	set_process(true)


func unbind(p_chara: Character) -> bool:
	if chara == null:
		return true
	if chara != p_chara:
		printerr("FloatingInfo unbind wrong character")
		return false
	chara = null
	set_process(false)
	return true


func _on_mouse_entered() -> void:
	if chara:
		Events.req_show_character_info_card.emit(chara)


func _on_mouse_exited() -> void:
	if chara:
		Events.req_hide_character_info_card.emit()
