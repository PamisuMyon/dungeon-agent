class_name CharacterConfig
extends Resource

enum Type {
	None, Adventurer, Servant
}


@export var id: String
@export var type: Type = Type.None
@export var display_name: String
@export var attack_ability: AbilityConfig
@export var skill_abilities: Array[AbilityConfig]

@export_group("Attributes")
@export var max_health: float = 5.
@export var damage: float = 1.
@export var initiative: float
@export var move: int = 2

var attributes: Dictionary


func initialize():
	attributes.clear()
	attributes[Schema.AttributeType.MAX_HEALTH] = max_health
	attributes[Schema.AttributeType.DAMAGE] = damage
	attributes[Schema.AttributeType.INITIATIVE] = initiative
	attributes[Schema.AttributeType.MOVE] = move
