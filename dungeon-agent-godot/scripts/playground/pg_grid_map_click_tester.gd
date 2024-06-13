extends Node3D

const RAY_LENGTH := 1000.

@export_flags_3d_physics var collision_mask: int = 1

var _floor_grid_map: GridMapNavRegion2D


func _ready() -> void:
	Events.combat_state_changed.connect(_on_combat_state_changed)


func _on_combat_state_changed(state: CombatBlackboard.SubState):
	if state == CombatBlackboard.SubState.WAVE_BEGIN:
		Events.combat_state_changed.disconnect(_on_combat_state_changed)
		await get_tree().process_frame
		_floor_grid_map = App.combat_manager.floor_grid_map


func _input(event: InputEvent) -> void:
	var cam = get_viewport().get_camera_3d()
	if event is InputEventMouseButton and event.is_pressed():
		var mouse_pos = get_viewport().get_mouse_position()
		var from = cam.project_ray_origin(mouse_pos)
		var to = from + cam.project_ray_normal(mouse_pos) * RAY_LENGTH
		var space_state = get_world_3d().direct_space_state
		var parameter = PhysicsRayQueryParameters3D.create(from, to, collision_mask)
		var result = space_state.intersect_ray(parameter)
		if result:
			var pos = result["position"]
			var cell_pos = _floor_grid_map.local_to_map(pos)
			var is_solid = _floor_grid_map.is_cell_solid(cell_pos)
			print("Mouse hit cell %s solid %s" % [cell_pos, is_solid])
		else:
			print("Mouse hit nothing")
