class_name StateMachine
extends Node

var states: Dictionary
var previous_state: State
var current_state: State
var is_initialized: bool = false

func initialize():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.machine = self
			child.on_initialize()
	is_initialized = true


func change_state(state_name: String):
	if not states.has(state_name):
		printerr("StateMachine change_state: state %s not exists" % state_name)
		return

	var new_state = states[state_name]
	if current_state == new_state:
		return

	previous_state = current_state
	current_state = new_state
	if previous_state:
		previous_state.on_exit()
	current_state.on_enter()


func on_process(delta: float):
	if current_state:
		current_state.on_process(delta)


func on_physics_process(delta: float):
	if current_state:
		current_state.on_physics_process(delta)


func on_input(event: InputEvent):
	if current_state:
		current_state.on_input(event)
