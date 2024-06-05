class_name AttributeComponent
extends Node

signal attribute_value_changed(type: Schema.AttributeType, new_value: float, old_value: float)
signal health_changed(delta: float, new_health: float)

@export var debug_lock_health := false

var attributes: Dictionary
var p: Character


func initialize(character: Character):
	p = character


func get_value(attr: Schema.AttributeType, default: float = 0) -> float:
	return attributes.get(attr, default)


func set_value(attr: Schema.AttributeType, value: float):
	var old_value = attributes[attr] if attr in attributes else 0
	attributes[attr] = value
	attribute_value_changed.emit(attr, value, old_value)


func set_max_value(attr: Schema.AttributeType, max_attr: Schema.AttributeType, new_max_value: float, keep_ratio: bool = true):
	if keep_ratio:
		var max_value = get_value(max_attr)
		var value = get_value(attr)
		var ratio = value / max_value
		max_value = new_max_value
		value = max_value * ratio
		set_value(max_attr, max_value)
		set_value(attr, value)
	else:
		set_value(max_attr, new_max_value)


func set_max_health(new_max_health: float, keep_ratio: bool = true):
	set_max_value(Schema.AttributeType.HEALTH, Schema.AttributeType.MAX_HEALTH, new_max_health, keep_ratio)


func change_health(delta: float):
	var health = get_value(Schema.AttributeType.HEALTH)
	var new_health = health + delta
	if delta < 0:
		new_health = max(0, new_health)
	elif delta > 0:
		var max_health = get_value(Schema.AttributeType.MAX_HEALTH)
		new_health = min(new_health, max_health)
	
	if OS.is_debug_build() and debug_lock_health:
		health_changed.emit(delta, health)
	else:
		set_value(Schema.AttributeType.HEALTH, new_health)
		health_changed.emit(delta, new_health)


func revive():
	var health = get_value(Schema.AttributeType.MAX_HEALTH)
	set_value(Schema.AttributeType.HEALTH, health)
	health_changed.emit(0, health)
