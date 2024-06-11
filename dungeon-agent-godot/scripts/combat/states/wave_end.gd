extends CombatState

var is_win: bool


func on_enter():
	_finish_wave()


func _finish_wave():
	await get_tree().create_timer(2.).timeout
	# withdraw servants
	if not p.bb.servants_on_stage.is_empty():
		# TODO anim
		for it in p.bb.servants_on_stage:
			p.bb.inventory_servants.push_back(it.chara.config)
			it.queue_free()
		p.bb.servants_on_stage.clear()
	Events.inventory_servants_changed.emit()

	# clear adventurers
	if not p.bb.adventurers_on_stage.is_empty():
		# TODO anim
		for it in p.bb.adventurers_on_stage:
			it.queue_free()
		p.bb.adventurers_on_stage.clear()
	
	p.bb.char_on_stage.clear()

	if is_win:
		_wave_win()
	else:
		_wave_lose()


func _wave_win():
	if p.bb.wave_index == p.bb.level_config.waves.size() - 1\
	and p.bb.level_index == p.config.levels.size() - 1:
		# last wave of last level finished, game clear
		# TODO
		pass
	
	# show shop
	
	pass


func _wave_lose():
	# dungeon health change
	pass
