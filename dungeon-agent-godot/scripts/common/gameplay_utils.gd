class_name GameplayUtils
extends RefCounted


static func distance_manhattan(from: Vector3i, to: Vector3i) -> int:
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	var dz = abs(to.z - from.z)
	return dx + dy + dz


static func distance_chebyshev(from: Vector3i, to: Vector3i) -> int:
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	var dz = abs(to.z - from.z)
	return max(max(dx, dy), dz)


static func is_cell_reachable(region: GridMapNavRegion2D, cell: Vector3i) -> bool:
	var point = Vector2i(cell.x, cell.z)
	if not region.map_rect.has_point(point):
		return false
	return not region.is_cell_solid(cell)


static func find_nearest_reachable_cell(region: GridMapNavRegion2D, from: Vector3i, to: Vector3i, radius: int = 1):
	var min_cell = Vector3i(to.x - radius, 0, to.z - radius)
	var max_cell = Vector3i(to.x + radius, 0, to.z + radius)
	var has_valid_cell: bool = false
	var nearest: Vector3i
	var nearest_dis: float = 1000000.

	for x in range(min_cell.x, max_cell.x + 1):
		for z in range(min_cell.z, max_cell.z + 1):
			if not region.map_rect.has_point(Vector2i(x, z)):
				continue
			var cell = Vector3i(x, 0, z)
			if region.is_cell_solid(cell):
				continue

			has_valid_cell = true
			var dis = (cell - from).length_squared()
			if dis < nearest_dis:
				nearest = cell
				nearest_dis = dis
	
	return [has_valid_cell, nearest]


static func find_nearest_reachable_cell_in_range(region: GridMapNavRegion2D, from: Vector3i, to: Vector3i, min_radius: int, max_radius: int):
	for r in range(min_radius, max_radius + 1):
		var result = find_nearest_reachable_cell(region, from, to, r)
		if result[0]:
			return result
	return [false, Vector3i.ZERO]


# static func find_nearest_cell_neighbor(region: GridMapNavRegion2D, from: Vector3i, target: Vector3i) -> Vector3i:
# 	var frontier: Array[Vector3i] = []
# 	frontier.push_back(target)
# 	var reached: Array[Vector3i] = []
# 	var candidates: Array[Vector3i] = []
# 	var dis_to_target: float = -1
# 	var is_search_finished: bool = false

# 	while not frontier.is_empty() and not is_search_finished:
# 		var current = frontier.pop_front()
# 		for next in cell_neighbors(region, current):
# 			if next not in reached:
# 				frontier.push_back(next)
# 				reached.push_back(next)
				
# 				var new_dis_to_target = distance_manhattan(next, target)
# 				if dis_to_target == -1:
# 					dis_to_target = new_dis_to_target
# 				elif new_dis_to_target > dis_to_target \
# 				and not candidates.is_empty():
# 					is_search_finished = true
# 					break
				
# 				if not region.is_cell_solid(next):
# 					candidates.push_back(next)
	
# 	var nearest: Vector3i
# 	var nearest_dis: float = 1000000.
# 	for it in candidates:
# 		var dis = distance_manhattan(it, from)
# 		if dis < nearest_dis:
# 			nearest = it
# 			nearest_dis = dis
	
# 	return nearest


# static func cell_neighbors(region: GridMapNavRegion2D, cell: Vector3i, include_solid: bool = true) -> Array[Vector3i]:
# 	var neighbors: Array[Vector3i] = [
# 		Vector3i(cell.x + 1, cell.y, cell.z), 
# 		Vector3i(cell.x, cell.y, cell.z + 1), 
# 		Vector3i(cell.x - 1, cell.y, cell.z), 
# 		Vector3i(cell.x, cell.y, cell.z - 1) 
# 	]
# 	for i in range(neighbors.size() - 1, -1, -1):
# 		var it = neighbors[i]
# 		if not region.map_rect.has_point(Vector2i(it.x, it.z)):
# 			neighbors.remove_at(i)
# 		if not include_solid and region.is_cell_solid(it):
# 			neighbors.remove_at(i)
# 	return neighbors

