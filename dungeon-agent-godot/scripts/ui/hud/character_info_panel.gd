class_name CharacterInfoPanel
extends Control

@export var background_normal: Control
@export var background_red: Control
@export var info_view: CharacterInfoView

var current_chara: Character
var is_pinned: bool = false


func show_by_character(chara: Character):
	if is_pinned:
		return
	visible = true
	unbind()
	bind(chara)
	info_view.inflate_by_character(chara)

	background_normal.visible = false
	background_red.visible = false
	if chara.config.type == CharacterConfig.Type.ADVENTURER:
		background_red.visible = true
	else:
		background_normal.visible = true


func show_by_config(config: CharacterConfig, pinned: bool = false):
	if is_pinned:
		return
	is_pinned = pinned
	visible = true
	unbind()
	info_view.inflate_by_config(config)

	background_normal.visible = false
	background_red.visible = false
	if config.type == CharacterConfig.Type.ADVENTURER:
		background_red.visible = true
	else:
		background_normal.visible = true


func hide_info(force: bool = false):
	if is_pinned and not force:
		return
	unbind()
	is_pinned = false
	visible = false


func refresh():
	info_view.refresh_by_character(current_chara)


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
