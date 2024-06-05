class_name CommonUtils
extends RefCounted

#region Engine

static func get_child_of_type(node: Node, child_type, recursive := false):
	for i in range(node.get_child_count()):
		var child = node.get_child(i)
		if is_instance_of(child, child_type):
			return child
		if recursive:
			var child_node = get_child_of_type(child, child_type, recursive)
			if child_node:
				return child_node


static func get_children_of_type(node: Node, child_type, out_list: Array, recursive := false):
	for i in range(node.get_child_count()):
		var child = node.get_child(i)
		if is_instance_of(child, child_type):
			out_list.append(child)
		if recursive:
			get_children_of_type(child, child_type, out_list, recursive)
	return out_list


static func rotate_towards(from: Quaternion, to: Quaternion, max_degrees_delta: float) -> Quaternion:
	var angle = from.angle_to(to)
	if is_zero_approx(angle):
		return to
	else:
		var weight = min(1., deg_to_rad(max_degrees_delta) / angle)
		return from.slerp(to, weight)


static func smooth_look_at_3d(node: Node3D, dir: Vector3, delta: float, speed_degree: float, up: Vector3 = Vector3.UP, use_model_front: bool = false) -> bool:
	if dir.is_equal_approx(Vector3.ZERO):
		return true
	var target_quat = Basis.looking_at(dir, Vector3.UP, use_model_front).get_rotation_quaternion()
	var new_quat = rotate_towards(node.quaternion, target_quat, speed_degree * delta)
	node.quaternion = new_quat
	return new_quat.is_equal_approx(target_quat)

#endregion

#region Random

static func random_item(arr: Array):
	var i = randi_range(0, arr.size() - 1)
	return arr[i]


static func random_y_rotation() -> Quaternion:
	var angle = randf_range(0, 2 * PI)
	return Quaternion.from_euler(Vector3(0, angle, 0))


static func random_inside_circle(radius: float = 1.) -> Vector2:
	var r = sqrt(randf_range(0, radius))
	var theta = randf_range(0, 2 * PI)
	return Vector2(r * cos(theta), r * sin(theta))


## ICDF(x) = √(x*(rmax^2 - rmin^2)+rmin^2)
static func random_inside_annulus(min_radius: float, max_radius: float) -> Vector2:
	var dir = random_inside_circle().normalized()
	var min_r2 = min_radius * min_radius
	var max_r2 = max_radius * max_radius
	return dir * sqrt(randf() * (max_r2 - min_r2) + min_r2)


static func random_point_on_nav_map_3d(map: RID, center: Vector3, min_radius: float, max_radius: float) -> Vector3:
	var random_point: Vector2
	if min_radius == 0:
		random_point = random_inside_circle(max_radius)
	else:
		random_point = random_inside_annulus(min_radius, max_radius)
	var point = center + Vector3(random_point.x, 0, random_point.y)
	return NavigationServer3D.map_get_closest_point(map, point)

#endregion
