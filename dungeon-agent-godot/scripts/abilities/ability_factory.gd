class_name AbilityFactory
extends Node

const SimpleMeleeAbility = preload("res://scripts/abilities/simple_melee_ability.gd")


static func create(config: AbilityConfig) -> Ability:
	var ability: Ability = null
	var type = config.type
	if type == AbilityConfig.AbilityType.SIMPLE_MELEE:
		ability = SimpleMeleeAbility.new(config)

	if not ability:
		printerr("AbilityFactory Ability of type '%s' not found." % type)
	return ability
