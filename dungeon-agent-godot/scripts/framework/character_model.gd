class_name CharacterModel
extends Node3D

@export var visual_radius := 1.
@export var visual_height := 2.5
@export var anim_tree: AnimationTree
@export_enum("idle", "dual_wield", "blocking") var anim_idle_variant: String = "idle"


func _ready() -> void:
	anim_tree.set(GlobalConst.TRANS_REQ_IDLE_VARIANT, anim_idle_variant)
