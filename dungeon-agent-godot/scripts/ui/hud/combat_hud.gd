extends Control

@export var health_bar: DungeonHealthBar
@export var gold_label: Label
@export var character_info_panel: Control
@export var start_button: Button
@export var health_detail_view: Control
@export var detail_health_bar: DungeonHealthBar
@export var defeated_view: Control
@export var victory_view: Control


func _ready() -> void:
	#character_info_panel.hide_info()
	start_button.pressed.connect(_on_start_button_pressed)
	detail_health_bar.animation_finished.connect(_on_detail_health_bar_animation_finished)

	Events.combat_state_changed.connect(_on_combat_state_changed)
	Events.dungeon_health_changed.connect(_on_dungeon_health_changed)
	Events.consumable_changed.connect(_on_consumable_changed)

	Events.req_show_character_info_card.connect(_show_character_info_card)
	Events.req_hide_character_info_card.connect(_hide_character_info_card)
	Events.req_show_defeated_view.connect(_on_req_show_defeated_view)
	Events.req_show_victory_view.connect(_on_req_show_victory_view)
	Events.req_show_dungeon_health_detail_view.connect(_on_req_show_dungeon_health_detail_view)


func _on_start_button_pressed():
	Events.req_start_battle.emit()


func _on_detail_health_bar_animation_finished():
	await get_tree().create_timer(1).timeout
	Events.dungeon_health_detail_view_anim_finished.emit()


func _on_combat_state_changed(state: CombatBlackboard.SubState):
	if state == CombatBlackboard.SubState.WAVE_BEGIN:
		start_button.visible = true
		start_button.text = "Start Battle"
		start_button.disabled = false
	elif state == CombatBlackboard.SubState.BATTLE:
		start_button.text = "Battling"
		start_button.disabled = true
	elif state == CombatBlackboard.SubState.EMBATTLE_NONE:
		start_button.disabled = false
	elif state == CombatBlackboard.SubState.EMBATTLE_PLACING:
		start_button.disabled = true
	if state == CombatBlackboard.SubState.WAVE_END:
		# start_button.text = "Start Battle"
		# start_button.disabled = true
		start_button.visible = false


func _on_dungeon_health_changed(new_health: int):
	health_bar.set_value(new_health)
	detail_health_bar.set_value(new_health)


func _on_consumable_changed(type: Schema.ConsumableType, new_value, _delta):
	if type == Schema.ConsumableType.GOLD:
		gold_label.text = str(new_value)


func _show_character_info_card(chara: Character):
	character_info_panel.show_info(chara)
	pass


func _hide_character_info_card():
	character_info_panel.hide_info()
	pass


func _on_req_show_defeated_view():
	if health_detail_view.visible and detail_health_bar.is_animating:
		await detail_health_bar.animation_finished
	health_detail_view.visible = false
	defeated_view.visible = true


func _on_req_show_victory_view():
	victory_view.visible = true


func _on_req_show_dungeon_health_detail_view():
	health_detail_view.visible = true
