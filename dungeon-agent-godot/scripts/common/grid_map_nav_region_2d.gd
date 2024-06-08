@tool
class_name GridMapNavRegion2D
extends GridMap

enum SolidMode { SOLID, HIGH_WEIGHT }

const SOLID_WEIGHT: float = 1000000000.

## used for instantiated from a packed scene
@export var delay_initialize: bool = true
@export var solid_cells: Array[Vector3i]
@export var agent_cast: ShapeCast3D
@export var diagonal_mode: AStarGrid2D.DiagonalMode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
@export var heuristic: AStarGrid2D.Heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
@export var solid_mode: SolidMode = SolidMode.SOLID
@export var is_baked: bool = false
@export var editor_bake: bool:
	set(value):
		if not Engine.is_editor_hint():
			return
		_refresh_solid_cells()

var map_rect: Rect2i
var _astar_grid: AStarGrid2D


func _ready():
	if delay_initialize:
		await get_tree().process_frame
	_initialize()


func _initialize():
	map_rect = Rect2i()
	var used_cells = get_used_cells()
	for cell in used_cells:
		map_rect = map_rect.expand(Vector2i(cell.x, cell.z))
	map_rect.size += Vector2i.ONE

	_astar_grid = AStarGrid2D.new()
	_astar_grid.diagonal_mode = diagonal_mode
	_astar_grid.default_compute_heuristic = heuristic
	_astar_grid.default_estimate_heuristic = heuristic
	_astar_grid.region = map_rect
	_astar_grid.cell_size = Vector2(cell_size.x, cell_size.z)
	if not is_baked:
		_refresh_solid_cells()
	_astar_grid.update()
	if solid_cells.size() > 0:
		for cell in solid_cells:
			set_cell_solid(cell, true)


func _refresh_solid_cells():
	solid_cells.clear()
	agent_cast.enabled = true
	var agent_y = agent_cast.position.y
	for cell in get_used_cells():
		var local_pos = map_to_local(cell)
		local_pos.y = agent_y
		agent_cast.position = local_pos
		agent_cast.force_shapecast_update()
		if agent_cast.is_colliding():
			solid_cells.append(cell)
	agent_cast.enabled = false


func set_cell_solid(cell: Vector3i, is_solid: bool):
	if solid_mode == SolidMode.HIGH_WEIGHT:
		_astar_grid.set_point_weight_scale(Vector2i(cell.x, cell.z), SOLID_WEIGHT if is_solid else 1.)
	else:
		_astar_grid.set_point_solid(Vector2i(cell.x, cell.z), is_solid)


func is_cell_solid(cell: Vector3i) -> bool:
	if solid_mode == SOLID_WEIGHT:
		return _astar_grid.get_point_weight_scale(Vector2i(cell.x, cell.z)) == SOLID_WEIGHT
	else:
		return _astar_grid.is_point_solid(Vector2i(cell.x, cell.z))


func get_path_by_cell(from: Vector3i, to: Vector3i) -> Array[Vector2i]:
	return _astar_grid.get_id_path(Vector2i(from.x, from.z), Vector2i(to.x, to.z))
