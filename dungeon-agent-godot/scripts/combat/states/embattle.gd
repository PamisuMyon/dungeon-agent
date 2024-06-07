extends CombatState

const RAY_LENGTH := 1000.

@export_flags_3d_physics var mouse_collision_mask: int = 1

var is_placing: bool
var _placing_servant_index: int
var _is_placement_available: bool
# var _cam: Camera3D

var debug_mouse_pos: Vector3
var debug_cell_pos: Vector3i
var debug_cell_world_pos: Vector3i


# func on_initialize():
# 	super.on_initialize()
# 	_cam = get_viewport().get_camera_3d()
func on_enter():
	Events.combat_state_changed.emit(CombatBlackboard.SubState.EMBATTLE_NONE)


func on_exit():
	_exit_placing()


func on_process(_delta: float):
	if is_placing:
		var cell_pos = _get_mouse_cell_pos()
		var world_pos = p.floor_grid_map.map_to_local(cell_pos)
		debug_cell_pos = cell_pos
		debug_cell_world_pos = debug_cell_world_pos
		world_pos.y = 1.
		p.placement_dummy.global_position = world_pos

		var is_available = !p.placement_dummy.is_colliding \
		and p.floor_grid_map.map_rect.has_point(Vector2i(cell_pos.x, cell_pos.y)) \
		and !p.floor_grid_map.is_cell_solid(cell_pos)

		if _is_placement_available != is_available:
			_is_placement_available = is_available
			p.placement_dummy.set_model_materials(_is_placement_available)
		
		if Input.is_action_just_pressed("confirm"):
			if _is_placement_available:
				var spawn_pos = world_pos
				spawn_pos.y = 0
				p.spawn_character(p.bb.servants[_placing_servant_index], spawn_pos)
				p.bb.servants.remove_at(_placing_servant_index)
				_exit_placing()
				Events.servant_placed.emit()
			else:
				p.placement_dummy.animate_pop()
		elif Input.is_action_just_pressed("cancel"):
			_exit_placing()
			Events.servant_place_cancelled.emit()


func place_servant(index: int):
	if is_placing:
		return
	is_placing = true
	Events.combat_state_changed.emit(CombatBlackboard.SubState.EMBATTLE_PLACING)
	_placing_servant_index = index
	var config = p.bb.servants[index]
	assert(config.model_path, "model_path of config %s is null" % config.id)
	var model_scene = load(config.model_path) as PackedScene
	var model = model_scene.instantiate()
	p.placement_dummy.set_model(model)
	p.placement_dummy.set_model_materials(_is_placement_available)


func _get_mouse_cell_pos() -> Vector3i:
	var cam = p.stage.cam
	var mouse_pos = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = p.get_world_3d().direct_space_state
	var parameter = PhysicsRayQueryParameters3D.create(from, to, mouse_collision_mask)
	var result = space_state.intersect_ray(parameter)
	if result:
		var pos = result["position"]
		pos.y = max(0, pos.y) # avoid some negative y cases (tile gaps)
		debug_mouse_pos = pos
		var grid_pos = p.floor_grid_map.local_to_map(pos)
		return grid_pos
		# print("Mouse hit: ", pos, " ", grid_pos)
	# else:
		# print("Mouse hit nothing")
	return Vector3i(-1000, -1000, -1000)


func _exit_placing():
	if is_placing:
		is_placing = false
		_placing_servant_index = -1
		_is_placement_available = false
		p.placement_dummy.clear_model()
		Events.combat_state_changed.emit(CombatBlackboard.SubState.EMBATTLE_NONE)
