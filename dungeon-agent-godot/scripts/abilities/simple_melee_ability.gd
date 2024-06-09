extends Ability


func activate():
	if not target:
		printerr("Ability %s activate failed: target is null" % config.id)
		return

	state = AbilityState.ACTIVE
	p.model.anim_tree.set(GlobalConst.TRANS_REQ_ACTION, config.act_anim_name)
	p.model.anim_tree.set(GlobalConst.REQ_ACTION_SHOT, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await p.get_tree().create_timer(config.act_pre_delay).timeout
	if state != AbilityState.ACTIVE:
		return
	cooldown = config.cooldown

	var damage = p.attr_comp.get_value(Schema.AttributeType.DAMAGE)
	var is_critical := false
	if "damage_scale" in config.extra:
		damage *= config.extra["damage_scale"]
		is_critical = true
	target.attr_comp.change_health(-damage)
	Events.req_show_damage_text.emit(target.global_position, damage, is_critical)
	# print("Perform attack")

	await p.get_tree().create_timer(config.act_post_delay).timeout
	if state != AbilityState.ACTIVE:
		return
	state = AbilityState.INACTIVE
	performed.emit()


func cancel():
	state = AbilityState.INACTIVE
