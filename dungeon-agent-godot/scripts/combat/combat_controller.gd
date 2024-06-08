class_name CombatController
extends Node3D

@export var is_debug: bool = false
@export var config: CombatConfig

var stage: Stage
var floor_grid_map: GridMapNavRegion2D
var bb: CombatBlackboard

@onready var fsm: StateMachine = $StateMachine
@onready var placement_dummy: PlacementDummy = $PlacementDummy


func _ready() -> void:
	App.combat_controller = self
	
	bb = CombatBlackboard.new()
	for it in App.config.default_servants:
		bb.inventory_servants.push_back(it)

	if is_debug:
		for node in get_parent().get_children():
			if node is CharacterController:
				bb.char_on_stage.push_back(node)
	
	fsm.initialize()
	await get_tree().process_frame
	_next_level()
	
	Events.req_start_battle.connect(_on_req_start_battle)


func _process(delta: float) -> void:
	if fsm.is_initialized:
		fsm.on_process(delta)


func _input(event: InputEvent) -> void:
	if fsm.is_initialized:
		fsm.on_input(event)


func _on_req_start_battle():
	# TODO TEMP
	if bb.sub_state == CombatBlackboard.SubState.EMBATTLE_NONE:
		fsm.change_state("Battle")


func _next_level():
	# TODO TEMP
	bb.level_index += 1
	bb.level_config = config.levels[bb.level_index]
	bb.wave_index = 0
	fsm.change_state("Init")


func place_servant(index: int):
	if fsm.current_state.name != "Embattle":
		return
	fsm.current_state.place_servant(index)


func spawn_character(p_config: CharacterConfig, pos: Vector3) -> CharacterController:
	assert(p_config.scene_path, "scene_path of config %s is null" % p_config.id)
	var scene = load(p_config.scene_path) as PackedScene
	var cc = scene.instantiate() as CharacterController
	get_parent().add_child(cc)
	cc.global_position = pos
	var cell_pos = floor_grid_map.local_to_map(pos)
	floor_grid_map.set_cell_solid(cell_pos, true)
	bb.char_on_stage.push_back(cc)
	return cc


func spawn_character_at_cell(p_config: CharacterConfig, cell_pos: Vector3i) -> CharacterController:
	assert(p_config.scene_path, "scene_path of config %s is null" % p_config.id)
	var scene = load(p_config.scene_path) as PackedScene
	var cc = scene.instantiate() as CharacterController
	get_parent().add_child(cc)
	cc.move_to_cell(cell_pos)
	# floor_grid_map.set_cell_solid(cell_pos, true)
	bb.char_on_stage.push_back(cc)
	return cc
