class_name CombatController
extends Node3D

@export var include_scene_characters: bool = false # for debug
@export var floor_grid_map: GridMapNavRegion2D

var data: CombatData
var ccs: Array[CharacterController]
var dead_ccs: Array[CharacterController]
var alive_adventure_count: int
var alive_monster_count: int
var is_acting: bool

@onready var fsm: StateMachine = $StateMachine
@onready var placement_dummy: PlacementDummy = $PlacementDummy


func _ready() -> void:
	App.combat_controller = self
	
	data = CombatData.new()
	for it in App.config.default_servants:
		data.servants.push_back(it)

	if include_scene_characters:
		for node in get_parent().get_children():
			if node is CharacterController:
				ccs.push_back(node)
	
	fsm.initialize()
	fsm.change_state("Embattle")

	# await get_tree().process_frame
	# await get_tree().process_frame
	# _act()


func _process(delta: float) -> void:
	if fsm.is_initialized:
		fsm.on_process(delta)


func _input(event: InputEvent) -> void:
	if fsm.is_initialized:
		fsm.on_input(event)


func place_servant(index: int):
	if fsm.current_state.name != "Embattle":
		return
	fsm.current_state.place_servant(index)


func spawn_character(config: CharacterConfig, pos: Vector3):
	assert(config.scene_path, "scene_path of config %s is null" % config.id)
	var scene = load(config.scene_path) as PackedScene
	var cc = scene.instantiate() as CharacterController
	get_parent().add_child(cc)
	cc.global_position = pos
	ccs.push_back(cc)


func _act():
	if ccs.size() == 0:
		print("CombatController no characters to act")
		return
	if is_acting:
		return
	is_acting = true

	ccs.sort_custom(_sort_by_initiative)
	dead_ccs.clear()

	alive_adventure_count = 0
	alive_monster_count = 0
	for cc in ccs:
		if not cc.chara.is_alive():
			continue
		if cc is AdventurerController:
			alive_adventure_count += 1
		elif cc is CharacterController:
			alive_monster_count += 1
		cc.died.connect(_on_character_died)

	while is_acting:
		for cc in ccs:
			if not cc.chara.is_alive():
				dead_ccs.push_back(cc)
				continue
			cc.on_turn_begin()

		for cc in ccs:
			if not cc.chara.is_alive():
				dead_ccs.push_back(cc)
				continue
			print("CombatController %s acting" % cc.name)
			cc.act()
			await cc.act_finished
		
		for i in range(ccs.size() - 1, -1, -1):
			if ccs[i] in dead_ccs:
				ccs.remove_at(i)


func _sort_by_initiative(a: CharacterController, b: CharacterController) -> bool:
	var ia = a.chara.attr_comp.get_value(Schema.AttributeType.INITIATIVE)
	var ib = b.chara.attr_comp.get_value(Schema.AttributeType.INITIATIVE)
	return ia - ib > 0


func _on_character_died(cc: CharacterController):
	if cc is AdventurerController:
		alive_adventure_count -= 1
	elif cc is CharacterController:
		alive_monster_count -= 1

	if alive_adventure_count == 0:
		is_acting = false
		print("battle win")
	elif alive_monster_count == 0:
		is_acting = false
		print("battle loose")
