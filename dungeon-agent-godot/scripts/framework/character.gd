class_name Character
extends Node3D

@export var config: CharacterConfig
# @export var is_auto_initialize: bool = false

var attack_ability: Ability

@onready var model: CharacterModel = $Model
@onready var attr_comp: AttributeComponent = $AttributeComponent
@onready var ability_comp: AbilityComponent = $AbilityComponent


# func _ready() -> void:
# 	if is_auto_initialize:
# 		initialize()


func initialize():
	attr_comp.initialize(self)
	# attr_comp.health_changed.connect(_on_health_changed)
	ability_comp.initiate(self)

	config.initialize()
	for attr in config.attributes:
		attr_comp.set_value(attr, config.attributes[attr])
	attr_comp.revive()

	if config.attack_ability:
		attack_ability = AbilityFactory.create(config.attack_ability)
		if attack_ability:
			ability_comp.grant_ability(attack_ability)
	if config.skill_abilities:
		for it in config.skill_abilities:
			var ability = AbilityFactory.create(it)
			if ability:
				ability_comp.grant_ability(ability)


# func _on_health_changed(delta: float, new_health: float):


func is_alive() -> bool:
	return attr_comp.get_value(Schema.AttributeType.HEALTH) > 0
