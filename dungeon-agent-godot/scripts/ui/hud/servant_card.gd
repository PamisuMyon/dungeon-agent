class_name ServantCard
extends Control

signal card_selected(card: ServantCard)

enum CardState {
	NORMAL, DISABLED, SELECTED
}

@export var selection_offset_y: float = -20.
@export var body: Control
@export var icon: TextureRect
@export var highlight: Control
@export var disabled_mask: Control

var index: int
var config: CharacterConfig
var _state = CardState.NORMAL


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	if _state != CardState.NORMAL:
		return
	if event is InputEventMouseButton \
	and event.is_pressed() \
	and event.button_index == MOUSE_BUTTON_LEFT:
		card_selected.emit(self)


func _on_mouse_entered():
	if _state == CardState.NORMAL:
		# TODO Animation
		var pos = body.position
		pos.y = selection_offset_y
		body.position = pos
		Events.req_show_character_info_by_config.emit(config, false)


func _on_mouse_exited():
	if _state == CardState.NORMAL:
		body.position = Vector2.ZERO
		Events.req_hide_character_info.emit(false)


func on_spawn():
	visible = true


func on_release():
	visible = false
	config = null


func set_data(p_config: CharacterConfig):
	config = p_config
	if config.icon_path:
		icon.texture = load(config.icon_path)
	else:
		icon.texture = null


func change_state(p_state: ServantCard.CardState):
	# if _state == p_state:
	# 	return
	_state = p_state
	if _state == CardState.NORMAL:
		highlight.visible = false
		disabled_mask.visible = false
		body.position = Vector2.ZERO
	elif _state == CardState.DISABLED:
		highlight.visible = false
		disabled_mask.visible = true
		body.position = Vector2.ZERO
	elif _state == CardState.SELECTED:
		highlight.visible = true
