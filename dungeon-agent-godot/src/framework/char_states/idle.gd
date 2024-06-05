extends CharacterState


func on_enter():
	p.model.anim_tree.set(GlobalConst.TRANS_REQ_STATE, "idle")
