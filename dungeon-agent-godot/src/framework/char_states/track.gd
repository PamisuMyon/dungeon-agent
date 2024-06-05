extends CharacterState


func on_enter():
	if (not p.set_move_target_cell(p.target_cell)):
		# TODO
		machine.change_state("Idle")
		return
	p.model.anim_tree.set(GlobalConst.TRANS_REQ_STATE, "running")


func on_process(delta: float):
	p.handle_movement(delta)
	if p.agent.is_target_reached:
		if p.current_ability and p.current_ability.check_cooldown():
			machine.change_state("Attack")
		else:
			p.finish_acting()
	elif p.move_points == 0:
		p.finish_acting()
