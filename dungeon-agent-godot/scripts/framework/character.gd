class_name Character
extends Node3D

@export var config: CharacterConfig
# @export var is_auto_initialize: bool = false

var _is_alive: bool
var is_alive: bool:
	get:
		return _is_alive
var attack_ability: Ability

@onready var model: CharacterModel = $Model
@onready var attr_comp: AttributeComponent = $AttributeComponent
@onready var ability_comp: AbilityComponent = $AbilityComponent


# func _ready() -> void:
# 	if is_auto_initialize:
# 		initialize()


func initialize():
	attr_comp.initialize(self)
	attr_comp.health_changed.connect(_on_health_changed)
	ability_comp.initiate(self)

	config.initialize()
	for attr in config.attributes:
		attr_comp.set_value(attr, config.attributes[attr])
	revive()

	if config.attack_ability:
		attack_ability = AbilityFactory.create(config.attack_ability)
		if attack_ability:
			ability_comp.grant_ability(attack_ability)
	if config.skill_abilities:
		for it in config.skill_abilities:
			var ability = AbilityFactory.create(it)
			if ability:
				ability_comp.grant_ability(ability)


func _on_health_changed(_delta: float, new_health: float):
	if new_health <= 0 and _is_alive:
		_is_alive = false


func revive():
	attr_comp.revive()
	_is_alive = attr_comp.get_value(Schema.AttributeType.HEALTH) > 0
