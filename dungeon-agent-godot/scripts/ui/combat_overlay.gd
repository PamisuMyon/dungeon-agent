extends Control

const FloatingInfoScene: PackedScene = preload("res://scenes/ui/floating_info.tscn")
const FloatingTextScene: PackedScene = preload("res://scenes/ui/floating_text.tscn")

@export var normal_damage_text_color: Color = Color(.86, .86, .86)
@export var critical_damage_text_color: Color = Color(1, .79, .11)

var _floating_info_pool: NodePool
var _damage_text_pool: NodePool


func _ready() -> void:
	_floating_info_pool = NodePool.new()
	_floating_info_pool.init_by_scene(self, FloatingInfoScene)
	_damage_text_pool = NodePool.new()
	_damage_text_pool.init_by_scene(self, FloatingTextScene)

	Events.req_bind_character_floating_info.connect(_bind_character_floating_info)
	Events.req_unbind_character_floating_info.connect(_unbind_character_floating_info)
	Events.req_show_damage_text.connect(_show_damage_text)


func _bind_character_floating_info(chara: Character):
	var info = _floating_info_pool.spawn()
	if info:
		info.bind(chara)


func _unbind_character_floating_info(chara: Character):
	for it in _floating_info_pool.in_use_instances:
		if it.chara == chara:
			it.unbind()
			_floating_info_pool.release(it)


func _show_damage_text(world_pos: Vector3, value: float, is_critical: bool):
	var text = _damage_text_pool.spawn() as FloatingText
	if text:
		text.popup_finished.connect(_on_damage_text_popup_finished, CONNECT_ONE_SHOT)
		var color = critical_damage_text_color if is_critical else normal_damage_text_color
		text.popup_at_world_pos_3d(world_pos, str(value), color)


func _on_damage_text_popup_finished(text: FloatingText):
	_damage_text_pool.release(text)
	