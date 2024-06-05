class_name NodePool
extends RefCounted

var root: Node
var scene: PackedScene
var max_capacity: int = -1
var available_instances: Array[Node]	# considering performance, use it as a stack instead of queue currently
var in_use_instances: Array[Node]


func init_by_scene(p_root: Node, p_scene: PackedScene, p_max_capacity: int = -1):
	root = p_root
	scene = p_scene
	max_capacity = p_max_capacity


func init_by_scene_path(p_root: Node, p_scene_path: String, p_max_capacity: int = -1):
	root = p_root
	scene = load(p_scene_path)
	max_capacity = p_max_capacity


func get_capacity() -> int:
	return available_instances.size() + in_use_instances.size()


func _create_instance() -> Node:
	return scene.instantiate()


func spawn() -> Node:
	if available_instances.size() == 0:
		if max_capacity != -1 and get_capacity() >= max_capacity:
			print_debug("NodePool spawn: max capacity reached, returning null.")
			return null
		var new_node = _create_instance()
		root.add_child(new_node)
		available_instances.push_back(new_node)
	
	var node = available_instances.pop_back()
	in_use_instances.append(node)
	
	if node.has_method("on_spawn"):
		node.call("on_spawn")

	return node


func release(node: Node):
	if node.has_method("on_release"):
		node.call("on_release")

	in_use_instances.erase(node)
	if max_capacity != -1 and get_capacity() >= max_capacity:
		print_debug("NodePool release: max capacity reached, freeing instance.")
		node.queue_free()
		return
	available_instances.push_back(node)


func release_all_in_use():
	if in_use_instances.is_empty():
		return
	var size = available_instances.size()
	for i in range(in_use_instances.size() - 1, -1, -1):
		var it = in_use_instances[i]
		in_use_instances.remove_at(i)

		if it.has_method("on_release"):
			it.call("on_release")

		if max_capacity != -1 and size >= max_capacity:
			print_debug("NodePool release: max capacity reached, freeing instance.")
			it.queue_free()
			continue
		available_instances.push_back(it)
		size += 1
