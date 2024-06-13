extends CombatState

var _dead_chars: Array[CharacterController] = []
# var _alive_adventurer_count = 0
# var _alive_servant_count = 0
var _is_acting: bool = false


func on_enter():
	p.bb.sub_state = CombatBlackboard.SubState.BATTLE
	if not _check_battle_finished():
		_act()


func on_exit():
	_is_acting = false


func _act():
	if p.bb.char_on_stage.size() == 0:
		print("CombatManager no characters to act")
		return
	_is_acting = true

	p.bb.char_on_stage.sort_custom(_sort_by_initiative)
	_dead_chars.clear()

	for cc in p.bb.char_on_stage:
		if not cc.chara.is_alive:
			continue
		cc.die.connect(_on_character_die)

	while _is_acting:
		for cc in p.bb.char_on_stage:
			if not _check_char_alive(cc):
				continue
			cc.on_turn_begin()

		for cc in p.bb.char_on_stage:
			if not _check_char_alive(cc):
				continue
			# print("CombatManager %s acting" % cc.name)
			cc.act()
			await cc.act_finished
		
		if not _dead_chars.is_empty():
			for i in range(p.bb.char_on_stage.size() - 1, -1, -1):
				if p.bb.char_on_stage[i] in _dead_chars:
					p.bb.char_on_stage.remove_at(i)
			_dead_chars.clear()


func _check_char_alive(cc: CharacterController) -> bool:
	if not cc.chara.is_alive:
		_dead_chars.push_back(cc)
		return false
	return true


func _sort_by_initiative(a: CharacterController, b: CharacterController) -> bool:
	var ia = a.chara.attr_comp.get_value(Schema.AttributeType.INITIATIVE)
	var ib = b.chara.attr_comp.get_value(Schema.AttributeType.INITIATIVE)
	return ia - ib > 0


func _on_character_die(cc: CharacterController):
	cc.die.disconnect(_on_character_die)
	if cc.has_meta(GlobalConst.ADVENTURER):
		p.bb.adventurers_on_stage.erase(cc)
	elif cc.has_meta(GlobalConst.SERVANT):
		p.bb.servants_on_stage.erase(cc)
	_check_battle_finished()


func _check_battle_finished() -> bool:
	if p.bb.adventurers_on_stage.size() == 0:
		_is_acting = false
		machine.states["WaveEnd"].is_win = true
		machine.change_state("WaveEnd")
		return true
	elif p.bb.servants_on_stage.size() == 0:
		_is_acting = false
		machine.states["WaveEnd"].is_win = true
		machine.change_state("WaveEnd")
		return true
	return false
