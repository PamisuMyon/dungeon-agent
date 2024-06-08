extends CharacterState


func on_enter():
	p.model.anim_tree.set(GlobalConst.TRANS_REQ_STATE, "death")
	# hard-code
	await p.get_tree().create_timer(1.).timeout
	p.died.emit(p)


# func _sink():
# 	# hard-code
# 	await p.get_tree().create_timer(1.5).timeout

# 	var tween = p.get_tree().create_tween()
# 	var target_pos = p.position
# 	target_pos.y = target_pos.y - p.model.visual_height - .5
# 	tween.tween_property(p, "position", target_pos, 1.)
# 	await tween.finished
# 	p.died.emit(p)
