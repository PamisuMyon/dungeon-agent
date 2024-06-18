class_name SaveSystem
extends Node

var runtime: RuntimeData


func _ready() -> void:
	runtime = RuntimeData.new()


class RuntimeData:
	#region combat
	var dungeon_health: int
	var level_index: int = -1
	var level_config: LevelConfig
	var wave_index: int = 0
	#endregion

	#region inventory
	var gold: int
	var servants: Array[CharacterConfig] = []
	#endregion

	func change_dungeon_health(delta: int, notify: bool = true):
		dungeon_health = max(0, dungeon_health + delta)
		if notify:
			Events.dungeon_health_changed.emit(dungeon_health)


	func change_gold(delta: int, notify: bool = true):
		gold = max(0, gold + delta)
		if notify:
			Events.consumable_changed.emit(Schema.ConsumableType.GOLD, gold, delta)


