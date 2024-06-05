class_name AbilityComponent
extends Node

var p: Character
var ability_dic: Dictionary
var abilities: Array[Ability]


func initiate(character: Character):
	p = character


# func _process(delta: float):
# 	if abilities.size() == 0:
# 		return
# 	for it in abilities:
# 		if it.is_cooldown_managed \
# 			and it.state == Ability.AbilityState.INACTIVE \
# 			and it.cooldown > 0:
# 			it.cooldown -= delta
# 		if it.enable_process:
# 			it.on_process(delta)

func process_cooldown(delta: float):
	for it in abilities:
		if it.is_cooldown_managed \
			and it.state == Ability.AbilityState.INACTIVE \
			and it.cooldown > 0:
			it.cooldown -= delta


func grant_ability(ability: Ability) -> bool:
	if ability_dic.has(ability.config.id):
		printerr("Try to grant ability that already exists: %s" % ability.config.id)
		return false
	ability_dic[ability.config.id] = ability
	abilities.append(ability)
	ability.on_granted(self)
	return true


func revoke_ability(ability: Ability) -> bool:
	var b = ability_dic.erase(ability)
	if b:
		abilities.erase(ability)
		ability.on_revoked()
	return b


func get_ability(id: String) -> Ability:
	return ability_dic.get(id)


func try_activate_ability(id: String) -> bool:
	var ability = ability_dic.get(id)
	if ability:
		return ability.try_activate()
	return false
