extends CombatState


func on_enter():
	p.bb.sub_state = CombatBlackboard.SubState.LEVEL_BEGIN
	if p.stage:
		p.stage.queue_free()
	var scene = load(App.save.runtime.level_config.stage_path) as PackedScene
	p.stage = scene.instantiate()
	p.get_parent().add_child(p.stage)
	p.floor_grid_map = p.stage.floor_grid_map
	machine.change_state("WaveBegin")
