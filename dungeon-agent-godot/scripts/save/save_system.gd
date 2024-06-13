class_name SaveSystem
extends Node

var runtime: RuntimeData


func _ready() -> void:
	runtime = RuntimeData.new()


class RuntimeData:
	#region combat
	var level_index: int = -1
	var level_config: LevelConfig
	var wave_index: int = 0
	#endregion

	#region inventory
	var gold: int
	var servants: Array[CharacterConfig] = []
	#endregion

	func change_gold(delta: int, notify: bool = true):
		gold = max(0, gold + delta)
		if notify:
			Events.consumable_changed.emit(Schema.ConsumableType.GOLD, gold, delta)
