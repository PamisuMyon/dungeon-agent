class_name NodePooler
extends Node
 
@export var root: Node

## key: pool id, value: NodePool
var pool_dic: Dictionary
## key: instance id, value: NodePool
var _instances_to_pool_dic: Dictionary


func _ready():
	if not root:
		# printerr("NodePooler _ready: please set root node.")
		root = self


func spawn_by_scene(p_scene: PackedScene, p_max_capacity: int = -1) -> Node:
	var pool: NodePool
	if not pool_dic.has(p_scene.resource_path):
		pool = NodePool.new()
		pool.init_by_scene(root, p_scene, p_max_capacity)
		pool_dic[p_scene.resource_path] = pool
	else:
		pool = pool_dic[p_scene.resource_path]
	
	var node = pool.spawn()
	if node:
		_instances_to_pool_dic[node.get_instance_id()] = pool

	return node


func spawn_by_scene_path(p_scene_path: String, p_max_capacity: int = -1) -> Node:
	var pool: NodePool
	if not pool_dic.has(p_scene_path):
		pool = NodePool.new()
		pool.init_by_scene_path(root, p_scene_path, p_max_capacity)
		pool_dic[p_scene_path] = pool
	else:
		pool = pool_dic[p_scene_path]

	var node = pool.spawn()
	if node:
		_instances_to_pool_dic[node.get_instance_id()] = node

	return node


func release(node: Node):
	var id = node.get_instance_id()
	if _instances_to_pool_dic.has(id):
		_instances_to_pool_dic[id].release(node)
	else:
		node.queue_free()
		print_debug("NodePooler release: pool not found for instance(name:%s, id:%s)" % [node.name, id])
