## @deprecated
class_name AbilityItem
extends Control

@export var icon: TextureRect
@export var name_label: Label
@export var energy_stat: StatTag
@export var desc_label: RichTextLabel


func set_data(config: AbilityConfig):
	icon.texture = config.icon
	name_label.text = config.display_name
	desc_label.text = config.description
	if config.cost > 0:
		energy_stat.visible = true
		energy_stat.set_value(config.cost)
	else:
		energy_stat.visible = false
