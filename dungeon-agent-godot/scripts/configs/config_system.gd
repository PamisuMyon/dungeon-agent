class_name ConfigSystem
extends Node

@export var all_servants: Array[CharacterConfig]
@export var default_servants: Array[CharacterConfig]

var servant_dict: Dictionary


func _ready() -> void:
	for it in all_servants:
		servant_dict[it.id] = it
