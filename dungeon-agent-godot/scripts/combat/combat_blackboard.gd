class_name CombatBlackboard
extends RefCounted

var level_index: int = -1
var level_config: LevelConfig
var servants: Array[CharacterConfig] = []
var char_controllers: Array[CharacterController]
