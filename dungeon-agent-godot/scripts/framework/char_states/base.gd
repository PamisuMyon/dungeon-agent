class_name CharacterState
extends State

var p: CharacterController


func on_initialize():
	p = machine.get_parent() as CharacterController
