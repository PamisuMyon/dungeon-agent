class_name ServantCard
extends Control

signal card_selected(card: ServantCard)

enum State {
	NORMAL, DISABLED, SELECTED
}

@export var selection_offset_y: float = -20.

var index: int
var config: CharacterConfig
var _state = State.NORMAL

@onready var body: Control = $Body
@onready var icon: TextureRect = $Body/Icon
@onready var highlight: Control = $Body/HighLight
@onready var disabled_mask: Control = $Body/DisabledMask


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered():
	if _state == State.NORMAL:
		# TODO Animation
		var pos = body.position
		pos.y = selection_offset_y
		body.position = pos


func _gui_input(event: InputEvent) -> void:
	if _state != State.NORMAL:
		return
	if event is InputEventMouseButton \
	and event.is_pressed() \
	and event.button_index == MOUSE_BUTTON_LEFT:
		card_selected.emit(self)


func _on_mouse_exited():
	if _state == State.NORMAL:
		body.position = Vector2.ZERO


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


func change_state(p_state: ServantCard.State):
	if _state == p_state:
		return
	_state = p_state
	if _state == State.NORMAL:
		highlight.visible = false
		disabled_mask.visible = false
		body.position = Vector2.ZERO
	elif _state == State.DISABLED:
		highlight.visible = false
		disabled_mask.visible = true
		body.position = Vector2.ZERO
	elif _state == State.SELECTED:
		highlight.visible = true
