extends Control

## key: Schema.AttributeType  value: StatTag
var tag_dict: Dictionary


func _ready() -> void:
	for it in get_children():
		if it is StatTag:
			tag_dict[it.attr_type] = it


func set_data(attributes: Dictionary):
	for key in attributes:
		if key in tag_dict:
			tag_dict[key].set_value(str(floori(attributes[key])))
