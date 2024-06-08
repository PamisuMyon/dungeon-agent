class_name CombatBlackboard
extends RefCounted

enum SubState {
	INIT,
	WAVE_BEGIN, 
	EMBATTLE_NONE, 
	EMBATTLE_PLACING,
	BATTLE,
}

var level_index: int = -1
var level_config: LevelConfig
var wave_index: int = 0
var inventory_servants: Array[CharacterConfig] = []

var char_on_stage: Array[CharacterController]
var _sub_state: CombatBlackboard.SubState = SubState.INIT
var sub_state: CombatBlackboard.SubState:
	get:
		return _sub_state
	set(value):
		_sub_state = value
		Events.combat_state_changed.emit(_sub_state)
