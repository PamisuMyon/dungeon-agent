extends CombatState


func on_enter():
	p.bb.sub_state = CombatBlackboard.SubState.PREPARE
	var scene = load(p.bb.level_config.stage_path) as PackedScene
	p.stage = scene.instantiate()
	p.get_parent().add_child(p.stage)
	p.floor_grid_map = p.stage.floor_grid_map
	_spawn_enemies()
	machine.change_state("Embattle")


func _spawn_enemies():
	var points = p.stage.spawn_points.duplicate()
	for config in p.bb.level_config.enemies:
		var ri = randi_range(0, points.size() - 1)
		var cell_pos = points[ri]
		points.remove_at(ri)
		var cc = p.spawn_character_at_cell(config, cell_pos)
		var map_center_pos = p.floor_grid_map.map_to_local(p.stage.map_center)
		GameplayUtils.hard_look_at_grid_pos(cc.chara.model, map_center_pos, true)
	pass
