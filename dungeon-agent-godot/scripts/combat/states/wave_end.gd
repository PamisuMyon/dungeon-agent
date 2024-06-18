extends CombatState

var _is_win: bool


func on_enter():
	p.bb.sub_state = CombatBlackboard.SubState.WAVE_END
	_finish_wave()


func _finish_wave():
	if p.bb.adventurers_on_stage.size() == 0:
		_is_win = true
	else:
		_is_win = false

	await get_tree().create_timer(2.).timeout
	# withdraw servants
	if not p.bb.servants_on_stage.is_empty():
		# TODO anim
		for it in p.bb.servants_on_stage:
			App.save.runtime.servants.push_back(it.chara.config)
			it.free_self()
		p.bb.servants_on_stage.clear()
	Events.inventory_servants_changed.emit()

	if _is_win:
		_wave_win()
	else:
		_wave_lose()
	
	# clear adventurers
	if not p.bb.adventurers_on_stage.is_empty():
		# TODO anim
		for it in p.bb.adventurers_on_stage:
			it.free_self()
		p.bb.adventurers_on_stage.clear()
	
	p.bb.char_on_stage.clear()


func _wave_win():
	var data = App.save.runtime
	if data.wave_index == data.level_config.waves.size() - 1\
	and data.level_index == p.config.levels.size() - 1:
		# last wave of last level finished, game clear
		# TODO
		Events.req_show_victory_view.emit()
		return
	
	# show shop
	App.shop_manager.show_shop()


func _wave_lose():
	# dungeon health change 
	# TODO Temp
	var health_delta = -p.bb.adventurers_on_stage.size()
	Events.req_show_dungeon_health_detail_view.emit()
	App.save.runtime.change_dungeon_health(health_delta)
	await Events.dungeon_health_detail_view_anim_finished

	if App.save.runtime.dungeon_health == 0:
		Events.req_show_defeated_view.emit()
	else:
		# show shop
		App.shop_manager.show_shop()
