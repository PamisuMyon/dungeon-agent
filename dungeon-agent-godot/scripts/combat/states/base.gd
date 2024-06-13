class_name CombatState
extends State

var p: CombatManager


func on_initialize():
	p = machine.get_parent() as CombatManager
