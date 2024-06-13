extends Control

@export var background_normal: Control
@export var background_red: Control
@export var name_label: Label
@export var icon: TextureRect
@export var ability_item: AbilityItem

@export_category("Stats")
@export var health: StatTag
@export var energy: StatTag
@export var damage: StatTag
@export var move: StatTag

var current_chara: Character


func show_info(chara: Character):
	visible = true
	unbind()
	bind(chara)
	name_label.text = chara.config.display_name
	background_normal.visible = false
	background_red.visible = false
	if chara.config.type == CharacterConfig.Type.ADVENTURER:
		background_red.visible = true
	else:
		background_normal.visible = true

	if chara.config.skill_abilities.is_empty():
		ability_item.visible = false
		size.y = 100
	else:
		ability_item.visible = true
		ability_item.set_data(chara.config.skill_abilities[0])
	
	refresh()

	if chara.config.icon_path:
		icon.visible = true
		icon.texture = load(chara.config.icon_path)
	else:
		icon.visible = false


func hide_info():
	unbind()
	visible = false


func refresh():
	var attr_comp = current_chara.attr_comp
	# TODO Range
	# var attack_range = 0
	# if current_chara.attack_ability:
	# 	attack_range = current_chara.attack_ability.config.act_range
	health.set_value(attr_comp.get_value(Schema.AttributeType.HEALTH))
	energy.set_value(attr_comp.get_value(Schema.AttributeType.ENERGY))
	damage.set_value(attr_comp.get_value(Schema.AttributeType.DAMAGE))
	move.set_value(attr_comp.get_value(Schema.AttributeType.MOVE))


func bind(chara: Character):
	current_chara = chara
	current_chara.attr_comp.attribute_value_changed.connect(_on_attribute_value_changed)


func unbind():
	if not current_chara:
		return
	current_chara.attr_comp.attribute_value_changed.disconnect(_on_attribute_value_changed)
	current_chara = null


func _on_attribute_value_changed(_type: Schema.AttributeType, _new_value: float, _old_value: float):
	refresh()
