extends Control

signal card_selected

enum State {
	NORMAL, DISABLED, SELECTED
}

@export var selection_offset_y: float = -20.

var _state = State.NORMAL

@onready var body: Control = $Body
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
		print("Clicked")
		pass


func _on_mouse_exited():
	if _state == State.NORMAL:
		body.position = Vector2.ZERO


func change_state(p_state: State):
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
