class_name Ability
extends RefCounted

signal performed

enum AbilityState {
	NONE, DISABLED, INACTIVE, ACTIVE
}

var config: AbilityConfig
var comp: AbilityComponent
var p: Character
var state: AbilityState
var cooldown: float
var is_cooldown_managed := true
var enable_process := false

var target	# could be Character or Array[Character] or something else


func _init(abi_config: AbilityConfig):
	config = abi_config


func on_process(delta: float):
	pass


func on_granted(ability_comp: AbilityComponent):
	comp = ability_comp
	p = comp.p
	state = AbilityState.INACTIVE
	cooldown = config.init_cooldown


func on_revoked():
	cancel()
	comp = null
	p = null
	state = AbilityState.NONE


func can_activate() -> bool:
	return state == AbilityState.INACTIVE \
		and check_tags() \
		and check_cost() \
		and check_cooldown()


func check_tags() -> bool:
	return true


func check_cost() -> bool:
	return true


func check_cooldown() -> bool:
	return cooldown <= 0


func try_activate() -> bool:
	if not can_activate():
		return false
	activate()
	return true


func activate():
	pass


func cancel():
	pass


func set_target(new_target):
	target = new_target


func clear_target():
	target = null
