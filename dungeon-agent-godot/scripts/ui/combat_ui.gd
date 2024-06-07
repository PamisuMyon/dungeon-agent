extends Control

const FloatingInfoScene: PackedScene = preload("res://scenes/ui/floating_info.tscn")
const FloatingTextScene: PackedScene = preload("res://scenes/ui/floating_text.tscn")

@export var normal_damage_text_color: Color = Color(.86, .86, .86)
@export var critical_damage_text_color: Color = Color(1, .79, .11)
@export var character_info_panel: Control

var _floating_info_pool: NodePool
var _damage_text_pool: NodePool

@onready var start_button: Button = $StartButton


func _ready() -> void:
	_floating_info_pool = NodePool.new()
	_floating_info_pool.init_by_scene(self, FloatingInfoScene)
	_damage_text_pool = NodePool.new()
	_damage_text_pool.init_by_scene(self, FloatingTextScene)
	character_info_panel.hide_info()
	start_button.pressed.connect(_on_start_button_pressed)

	Events.combat_state_changed.connect(_on_combat_state_changed)
	Events.req_bind_character_floating_info.connect(_bind_character_floating_info)
	Events.req_unbind_character_floating_info.connect(_unbind_character_floating_info)
	Events.req_show_damage_text.connect(_show_damage_text)
	Events.req_show_character_info_card.connect(_show_character_info_card)
	Events.req_hide_character_info_card.connect(_hide_character_info_card)


func _on_combat_state_changed(state: CombatBlackboard.SubState):
	if state == CombatBlackboard.SubState.PREPARE \
	or state == CombatBlackboard.SubState.EMBATTLE_PLACING \
	or state == CombatBlackboard.SubState.BATTLE:
		start_button.disabled = true
	elif state == CombatBlackboard.SubState.EMBATTLE_NONE:
		start_button.disabled = false


func _bind_character_floating_info(chara: Character):
	var info = _floating_info_pool.spawn()
	if info:
		info.bind(chara)


func _unbind_character_floating_info(chara: Character):
	for it in _floating_info_pool.in_use_instances:
		if it.chara == chara:
			it.unbind(chara)
			_floating_info_pool.release(it)


func _show_damage_text(world_pos: Vector3, value: float, is_critical: bool):
	var text = _damage_text_pool.spawn() as FloatingText
	if text:
		text.popup_finished.connect(_on_damage_text_popup_finished, CONNECT_ONE_SHOT)
		var color = critical_damage_text_color if is_critical else normal_damage_text_color
		text.popup_at_world_pos_3d(world_pos, str(value), color)


func _on_damage_text_popup_finished(text: FloatingText):
	_damage_text_pool.release(text)


func _show_character_info_card(chara: Character):
	character_info_panel.show_info(chara)


func _hide_character_info_card():
	character_info_panel.hide_info()


func _on_start_button_pressed():
	Events.req_next_wave.emit()
