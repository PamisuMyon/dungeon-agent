class_name CharacterController
extends Node3D

signal die(cc: CharacterController)
signal died(cc: CharacterController)
signal act_finished	# dont emit in the same frame when act is called

@export var move_speed: float = 4.
@export var turn_speed: float = 720.

var next_cell: Vector3i
var next_cell_pos: Vector3
var move_points: int
var attack_points: int
var floor_grid_map: GridMapNavRegion2D
var combat_controller: CombatManager

#region Blackboard
var target: CharacterController
var target_cell: Vector3i
var current_ability: Ability
var _candidate_targets: Array[CharacterController] = []
var _temp_targets: Array[CharacterController] = []
#endregion

@onready var chara: Character = $Character
@onready var model: CharacterModel = $Character/Model
@onready var fsm: StateMachine = $StateMachine
@onready var agent: GridMapNavAgent2D = $Agent


func _ready() -> void:
	combat_controller = App.combat_manager
	floor_grid_map = combat_controller.floor_grid_map
	
	# if not chara.is_auto_initialize:
	chara.initialize()
	chara.attr_comp.health_changed.connect(_on_health_changed)

	agent.region = floor_grid_map
	agent.initialize()

	fsm.initialize()
	fsm.change_state("Idle")

	Events.req_bind_character_floating_info.emit(chara)


func _process(delta: float) -> void:
	if fsm.is_initialized:
		fsm.on_process(delta)


func _on_health_changed(_delta: float, new_health: float):
	if new_health <= 0 and fsm.current_state.name != "Death":
		fsm.change_state("Death")


func free_self():
	Events.req_unbind_character_floating_info.emit(chara)
	queue_free()


func move_to_cell(cell_pos: Vector3i):
	agent.current_cell = cell_pos
	var world_pos = agent.cell_to_global(cell_pos)
	global_position = world_pos


func handle_movement(delta: float):
	var dir = next_cell_pos - global_position
	smooth_look_at(dir, delta)
	if dir.length_squared() < 0.02:
		global_position = next_cell_pos
		agent.current_cell = next_cell
		if agent.is_target_reached:
			return
		next_cell = agent.next_cell()
		next_cell_pos = agent.cell_to_global(next_cell)
		move_points -= 1
		return
	global_position += move_speed * delta * dir.normalized()


func set_move_target(pos: Vector3) -> bool:
	agent.set_target_position(pos)
	if not agent.has_path:
		return false
	next_cell = agent.next_cell()
	next_cell_pos = agent.cell_to_global(next_cell)
	return true


func set_move_target_cell(cell: Vector3i) -> bool:
	agent.target_cell = cell
	if not agent.has_path:
		return false
	next_cell = agent.next_cell()
	next_cell_pos = agent.cell_to_global(next_cell)
	return true


func smooth_look_at(dir: Vector3, delta: float) -> bool:
	return CommonUtils.smooth_look_at_3d(chara.model, dir, delta, turn_speed, Vector3.UP, true)


func on_turn_begin():
	chara.ability_comp.process_cooldown(1)
	move_points = floor(chara.attr_comp.get_value(Schema.AttributeType.MOVE))
	attack_points = 1


func act():
	if chara.is_alive:
		select_ability()
		if (not select_target()):
			await get_tree().process_frame
			finish_acting()
	else:
		finish_acting()


func finish_acting():
	if chara.is_alive:
		fsm.change_state("Idle")
	act_finished.emit()


func select_ability():
	current_ability = null
	if chara.ability_comp.abilities.is_empty():
		return
	var max_priority = -100
	for it in chara.ability_comp.abilities:
		if not it.check_cooldown():
			continue
		if it.config.priority > max_priority:
			max_priority = it.config.priority
			current_ability = it


func select_target() -> bool:
	target = null
	var char_on_stage = combat_controller.bb.char_on_stage
	var min_distance = GameplayUtils.filter_by_best_criteria(char_on_stage, _candidate_targets, _min_distance_criteria, 1000000.)
	if _candidate_targets.is_empty():
		# print("CharacterController select_target no target")
		return false
	
	if _candidate_targets.size() == 1:
		target = _candidate_targets[0]
	else:
		GameplayUtils.filter_by_best_criteria(_candidate_targets, _temp_targets, _min_health_criteria, 1000000.)
		target = _temp_targets[0]

	if min_distance <= 1:
		if not current_ability:
			return false
		fsm.change_state("Attack")
		return true
	
	var act_range = min(min_distance, current_ability.config.act_range) if current_ability else min_distance
	var result = GameplayUtils.find_nearest_reachable_cell_in_range(agent.region, agent.current_cell, target.agent.current_cell, act_range, act_range + 2)
	if result[0]:
		target_cell = result[1]
		print("Target cell: ", target_cell)
		fsm.change_state("Track")
		return true
	
	print("Valid target cell not found, self: %s, target: %s" % [name, target.name])
	return false


func _min_distance_criteria(cc: CharacterController) -> float:
	if cc == self or not cc.chara.is_alive:
		return 1000001.
	if (chara.config.type == CharacterConfig.Type.ADVENTURER \
	and cc is MonsterController) \
	or (chara.config.type == CharacterConfig.Type.SERVANT \
	and cc is AdventurerController):
		var distance = GameplayUtils.distance_chebyshev(agent.current_cell, cc.agent.current_cell)
		return distance
	return 1000001.


func _min_health_criteria(cc: CharacterController) -> float:
	if cc == self or not cc.chara.is_alive:
		return 1000001.
	return cc.chara.attr_comp.get_value(Schema.AttributeType.HEALTH)
