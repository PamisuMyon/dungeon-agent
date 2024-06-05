class_name AbilityConfig
extends Resource

enum AbilityType {
	NONE, SIMPLE_MELEE, SIMPLE_SHOOT
}

@export var id: String
@export var type: AbilityType
@export var act_range: int = 1
@export var cooldown: int = 1
@export var init_cooldown: int = 0
@export var priority: int
@export var extra: Dictionary

@export_group("Animation")
@export_enum("h1_melee_chop", "h1_melee_dia", "h1_melee_stab") var act_anim_name: String = "h1_melee_dia"
@export var act_pre_delay: float
# @export var act_duration: float
@export var act_post_delay: float
