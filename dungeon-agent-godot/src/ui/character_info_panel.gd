extends Control

@export var background_normal: Control
@export var background_red: Control
@export var name_label: Label
@export var stats_label: RichTextLabel
@export var desc_label: RichTextLabel

var current_chara: Character


func show_info(chara: Character):
	visible = true
	unbind()
	bind(chara)
	background_normal.visible = false
	background_red.visible = false
	name_label.text = chara.config.display_name
	if chara.config.type == CharacterConfig.Type.Adventurer:
		background_red.visible = true
	else:
		background_normal.visible = true
	refresh()
	

func hide_info():
	unbind()
	visible = false


func refresh():
	var attr_comp = current_chara.attr_comp
	var attack_range = 0
	if current_chara.attack_ability:
		attack_range = current_chara.attack_ability.config.act_range
	var stats_text = """Health: {health}/{max_health}
Damage: {damage}
Move: {move}
Attack Range: {attak_range}""".format({ 
	"health": attr_comp.get_value(Schema.AttributeType.HEALTH),
	"max_health": attr_comp.get_value(Schema.AttributeType.MAX_HEALTH),
	"damage": attr_comp.get_value(Schema.AttributeType.DAMAGE),
	"move": attr_comp.get_value(Schema.AttributeType.MOVE),
	"attak_range": attack_range
	})
	stats_label.text = stats_text


func bind(chara: Character):
	current_chara = chara
	current_chara.attr_comp.attribute_value_changed.connect(_on_attribute_value_changed)


func unbind():
	if not current_chara:
		return
	current_chara.attr_comp.attribute_value_changed.disconnect(_on_attribute_value_changed)
	current_chara = null


func _on_attribute_value_changed(type: Schema.AttributeType, new_value: float, old_value: float):
	refresh()
