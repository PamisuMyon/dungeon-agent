extends Control

@export var character_info_panel: Control

@onready var start_button: Button = $StartButton
@onready var defeated_view: Control = $DefeatedView
@onready var win_view: Control = $WinView


func _ready() -> void:
	character_info_panel.hide_info()
	start_button.pressed.connect(_on_start_button_pressed)

	Events.combat_state_changed.connect(_on_combat_state_changed)

	Events.req_show_character_info_card.connect(_show_character_info_card)
	Events.req_hide_character_info_card.connect(_hide_character_info_card)


func _on_combat_state_changed(state: CombatBlackboard.SubState):
	if state == CombatBlackboard.SubState.WAVE_BEGIN:
		start_button.text = "Start"
		start_button.disabled = false
	elif state == CombatBlackboard.SubState.BATTLE:
		start_button.text = "Battling"
		start_button.disabled = true
	elif state == CombatBlackboard.SubState.EMBATTLE_NONE:
		start_button.disabled = false
	elif state == CombatBlackboard.SubState.EMBATTLE_PLACING:
		start_button.disabled = true


func _show_character_info_card(chara: Character):
	character_info_panel.show_info(chara)


func _hide_character_info_card():
	character_info_panel.hide_info()


func _on_start_button_pressed():
	Events.req_start_battle.emit()
