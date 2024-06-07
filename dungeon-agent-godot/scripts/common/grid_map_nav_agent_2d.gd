class_name GridMapNavAgent2D
extends Node3D

@export var region: GridMapNavRegion2D
@export var is_self_solid: bool = true
@export var use_local_as_global: bool = false

var current_cell: Vector3i:
	set(value):
		is_target_reached = value == _target_cell
		if _current_cell == value:
			return
		if is_self_solid:
			region.set_cell_solid(_current_cell, false)
			region.set_cell_solid(value, true)
		_current_cell = value
	get:
		return _current_cell

var target_cell: Vector3i:
	set(value):
		_target_cell = value
		if value == _current_cell:
			is_target_reached = true
			return
		_path = region.get_path_by_cell(_current_cell, _target_cell)
		has_path = _path and _path.size() > 0
		_path_index = 0
		is_target_reached = false
	get:
		return _target_cell
	
var has_path: bool
var is_target_reached: bool
var _current_cell: Vector3i
var _target_cell: Vector3i
var _path: Array[Vector2i]
var _path_index: int


func _ready() -> void:
	if region:
		initialize()


func initialize():
	if use_local_as_global:
		_current_cell = region.local_to_map(global_position)
	else:
		_current_cell = region.local_to_map(region.to_local(global_position))
	if is_self_solid:
		region.set_cell_solid(_current_cell, true)


func set_target_position(target: Vector3):
	target.y = region.global_position.y
	var cell = region.local_to_map(region.to_local(target))
	target_cell = cell
	# print("Target cell: ", _target_cell)


func next_cell() -> Vector3i:
	if not has_path:
		printerr("GridMapNavAgent2D no path found")
		return Vector3i.ZERO
	# Add the index in advance because the first element of the path is current cell
	_path_index = min(_path_index + 1, _path.size() - 1)
	var id = _path[_path_index]
	# print("Weight scale: ", region._astar_grid.get_point_weight_scale(id))
	return Vector3i(id.x, 0, id.y)


func cell_to_global(cell: Vector3i) -> Vector3:
	if use_local_as_global:
		return region.map_to_local(cell)
	else:
		return region.to_global(region.map_to_local(cell))


func global_to_cell(pos: Vector3) -> Vector3i:
	pos.y = region.global_position.y
	if use_local_as_global:
		return region.local_to_map(pos)
	else:
		return region.local_to_map(region.to_local(pos))
