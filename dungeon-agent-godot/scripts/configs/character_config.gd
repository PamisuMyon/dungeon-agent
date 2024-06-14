class_name CharacterConfig
extends Resource

enum Type {
	NONE, ADVENTURER, SERVANT
}

@export_file("*.tscn") var scene_path: String
@export var id: String
@export var type: Type = Type.NONE
@export_range(1, 4) var tier: int = 1
@export var attack_ability: AbilityConfig
@export var skill_abilities: Array[AbilityConfig]

@export_group("Attributes")
@export var max_health: float = 5.
@export var energy: float
@export var damage: float = 1.
@export var initiative: float
@export var move: int = 2

var attributes: Dictionary

@export_group("Display")
@export var display_name: String
@export_file("*.png") var icon_path: String
@export_file("*.tscn") var model_path: String

@export_group("Shop")
@export var base_price: int


func initialize():
	attributes.clear()
	attributes[Schema.AttributeType.MAX_HEALTH] = max_health
	attributes[Schema.AttributeType.ENERGY] = energy
	attributes[Schema.AttributeType.DAMAGE] = damage
	attributes[Schema.AttributeType.INITIATIVE] = initiative
	attributes[Schema.AttributeType.MOVE] = move
