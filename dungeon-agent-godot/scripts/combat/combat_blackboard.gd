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
var _sub_state: CombatBlackboard.SubState = SubState.PREPARE
var sub_state: CombatBlackboard.SubState:
	get:
		return _sub_state
	set(value):
		_sub_state = value
		Events.combat_state_changed.emit(_sub_state)
