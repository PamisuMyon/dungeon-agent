extends CombatState

var _dead_char_controllers: Array[CharacterController] = []
var _alive_adventure_count = 0
var _alive_monster_count = 0
var _is_acting: bool = false


func on_enter():
	p.bb.sub_state = CombatBlackboard.SubState.BATTLE
	_act()


func on_exit():
	_is_acting = false


func _act():
	if p.bb.char_controllers.size() == 0:
		print("CombatController no characters to act")
		return
	_is_acting = true

	p.bb.char_controllers.sort_custom(_sort_by_initiative)
	_dead_char_controllers.clear()

	_alive_adventure_count = 0
	_alive_monster_count = 0
	for cc in p.bb.char_controllers:
		if not cc.chara.is_alive():
			continue
		if cc is AdventurerController:
			_alive_adventure_count += 1
		elif cc is CharacterController:
			_alive_monster_count += 1
		cc.died.connect(_on_character_died)

	while _is_acting:
		for cc in p.bb.char_controllers:
			if not cc.chara.is_alive():
				_dead_char_controllers.push_back(cc)
				continue
			cc.on_turn_begin()

		for cc in p.bb.char_controllers:
			if not cc.chara.is_alive():
				_dead_char_controllers.push_back(cc)
				continue
			print("CombatController %s acting" % cc.name)
			cc.act()
			await cc.act_finished
		
		for i in range(p.bb.char_controllers.size() - 1, -1, -1):
			if p.bb.char_controllers[i] in _dead_char_controllers:
				p.bb.char_controllers.remove_at(i)


func _sort_by_initiative(a: CharacterController, b: CharacterController) -> bool:
	var ia = a.chara.attr_comp.get_value(Schema.AttributeType.INITIATIVE)
	var ib = b.chara.attr_comp.get_value(Schema.AttributeType.INITIATIVE)
	return ia - ib > 0


func _on_character_died(cc: CharacterController):
	if cc is AdventurerController:
		_alive_adventure_count -= 1
	elif cc is CharacterController:
		_alive_monster_count -= 1

	if _alive_adventure_count == 0:
		_is_acting = false
		print("battle win")
	elif _alive_monster_count == 0:
		_is_acting = false
		print("battle lose")
