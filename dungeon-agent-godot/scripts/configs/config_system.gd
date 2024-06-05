class_name ConfigSystem
extends Node

@export var servant_list: Array[CharacterConfig]
@export var default_servants: Array[CharacterConfig]

var servant_dict: Dictionary


func _ready() -> void:
	for it in servant_list:
		servant_dict[it.id] = it
