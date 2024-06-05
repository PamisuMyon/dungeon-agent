extends CharacterState

enum AttackState {
	NONE,
	AIM,
	ATTACK,
}

var state := AttackState.NONE


func on_enter():
	p.model.anim_tree.set(GlobalConst.TRANS_REQ_STATE, "idle")
	state = AttackState.AIM
	p.current_ability.performed.connect(_on_ability_performed)


func on_exit():
	state = AttackState.NONE
	if p.current_ability.performed.is_connected(_on_ability_performed):
		p.current_ability.performed.disconnect(_on_ability_performed)
	p.current_ability.cancel()
	p.current_ability.clear_target()


func on_process(delta):
	if state == AttackState.AIM:
		var dir: Vector3 = p.target.global_position - p.global_position
		if p.smooth_look_at(dir.normalized(), delta):
			if p.current_ability.can_activate():
				p.current_ability.set_target(p.target.chara)
				p.current_ability.activate()
				p.attack_points -= 1
				state = AttackState.ATTACK


func _on_ability_performed():
	# if p.attack_points <= 0:
	# 	p.finish_acting()
	# else:
	# 	state = AttackState.AIM
	p.finish_acting()
