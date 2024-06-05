extends Node3D

const RAY_LENGTH := 1000.

@export var grid_map: GridMap
@export var pawns: Array[Character]
@export var cam: Camera3D
@export_flags_3d_physics var collision_mask: int = 1

var _pawn: Node3D


func _ready() -> void:
	if not pawns.is_empty():
		_pawn = pawns[0]


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var mouse_pos = get_viewport().get_mouse_position()
		var from = cam.project_ray_origin(mouse_pos)
		var to = from + cam.project_ray_normal(mouse_pos) * RAY_LENGTH
		var space_state = get_world_3d().direct_space_state
		var parameter = PhysicsRayQueryParameters3D.create(from, to, collision_mask)
		var result = space_state.intersect_ray(parameter)
		if result:
			var pos = result["position"]
			print("Mouse hit: ", pos, " ", grid_map.local_to_map(pos))
			if (_pawn):
				_pawn.set_target(pos)
		else:
			print("Mouse hit nothing")
		return
	
	if event is InputEventKey and event.is_pressed():
		var index = 0
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			index = event.keycode - KEY_1
		if index < pawns.size():
			_pawn = pawns[index]
			print("Select pawn: %d, %s", [index, _pawn.name])
