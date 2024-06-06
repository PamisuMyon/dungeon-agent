class_name CombatState
extends State

var p: CombatController


func on_initialize():
	p = machine.get_parent() as CombatController
