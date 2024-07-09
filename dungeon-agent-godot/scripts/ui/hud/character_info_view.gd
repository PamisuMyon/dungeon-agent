class_name CharacterInfoView
extends Control

@export var name_label: Label
@export var icon: TextureRect
@export var desc_label: RichTextLabel

@export_category("Stats")
@export var health: StatTag
@export var damage: StatTag
@export var initiative: StatTag
@export var move: StatTag
@export var act_range: StatTag


func inflate_by_character(chara: Character):
	name_label.text = chara.config.display_name
	desc_label.text = chara.config.description

	refresh_by_character(chara)

	if chara.config.icon_path:
		icon.visible = true
		icon.texture = load(chara.config.icon_path)
	else:
		icon.visible = false


func refresh_by_character(chara: Character):
	var attr_comp = chara.attr_comp
	health.set_value(attr_comp.get_value(Schema.AttributeType.HEALTH))
	initiative.set_value(attr_comp.get_value(Schema.AttributeType.INITIATIVE))
	damage.set_value(attr_comp.get_value(Schema.AttributeType.DAMAGE))
	move.set_value(attr_comp.get_value(Schema.AttributeType.MOVE))
	var act_range_value = 0
	if chara.attack_ability:
		act_range_value = chara.attack_ability.config.act_range
	act_range.set_value(act_range_value)


func inflate_by_config(config: CharacterConfig):
	name_label.text = config.display_name
	desc_label.text = config.description

	health.set_value(config.max_health)
	initiative.set_value(config.initiative)
	damage.set_value(config.damage)
	move.set_value(config.move)
	var act_range_value = 0
	if config.attack_ability:
		act_range_value = config.attack_ability.act_range
	act_range.set_value(act_range_value)

	if config.icon_path:
		icon.visible = true
		icon.texture = load(config.icon_path)
	else:
		icon.visible = false
