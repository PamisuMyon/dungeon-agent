class_name CombatBlackboard
extends RefCounted

enum SubState {
	PREPARE, 
	EMBATTLE_NONE, 
	EMBATTLE_PLACING,
	BATTLE,
}

var level_index: int = -1
var level_config: LevelConfig
var servants: Array[CharacterConfig] = []
var char_controllers: Array[CharacterController]
