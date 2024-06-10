extends CombatState

var _dead_chars: Array[CharacterController] = []
# var _alive_adventurer_count = 0
# var _alive_servant_count = 0
var _is_acting: bool = false


func on_enter():
	p.bb.sub_state = CombatBlackboard.SubState.BATTLE
	_act()


func on_exit():
	_is_acting = false


func _act():
	if p.bb.char_on_stage.size() == 0:
		print("CombatController no characters to act")
		return
	_is_acting = true

	p.bb.char_on_stage.sort_custom(_sort_by_initiative)
	_dead_chars.clear()

	# _alive_adventurer_count = 0
	# _alive_servant_count = 0
	for cc in p.bb.char_on_stage:
		if not cc.chara.is_alive:
			continue
		# if cc is AdventurerController:
		# 	_alive_adventurer_count += 1
		# elif cc is CharacterController:
		# 	_alive_servant_count += 1
		cc.die.connect(_on_character_die)

	while _is_acting:
		for cc in p.bb.char_on_stage:
			if not _check_char_alive(cc):
				continue
			cc.on_turn_begin()

		for cc in p.bb.char_on_stage:
			if not _check_char_alive(cc):
				continue
			# print("CombatController %s acting" % cc.name)
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
	# if cc is AdventurerController:
	# 	_alive_adventurer_count -= 1
	# elif cc is MonsterController:
	# 	_alive_servant_count -= 1

	if p.bb.adventurers_on_stage.size() == 0:
		_is_acting = false
		machine.states["WaveEnd"].is_win = true
		machine.change_state("WaveEnd")
	elif p.bb.servants_on_stage.size() == 0:
		_is_acting = false
		machine.states["WaveEnd"].is_win = true
		machine.change_state("WaveEnd")

	# if _alive_adventurer_count == 0:
	# 	_is_acting = false
	# 	print("battle win")
	# elif _alive_servant_count == 0:
	# 	_is_acting = false
	# 	print("battle lose")
