extends CharacterState


func on_enter():
	p.model.anim_tree.set(GlobalConst.TRANS_REQ_STATE, "death")
	p.die.emit(p)
	p.floor_grid_map.set_cell_solid(p.agent.current_cell, false)
	_sink()


func _sink():
	# hard-code
	await p.get_tree().create_timer(1.2).timeout
	Events.req_unbind_character_floating_info.emit(p.chara)

	var tween = p.get_tree().create_tween()
	var target_pos = p.position
	target_pos.y = target_pos.y - p.model.visual_height - .1
	tween.tween_property(p, "position", target_pos, 1.)
	await tween.finished
	p.died.emit(p)
	p.visible = false
	# p.queue_free()
