class_name StatTag
extends Control

@onready var attr_type: Schema.AttributeType
@onready var icon: TextureRect = $Icon
@onready var value_label: Label = $ValueLabel


func set_value(value: float):
	value_label.text = str(floori(value))


func set_value_str(value: String):
	value_label.text = value
