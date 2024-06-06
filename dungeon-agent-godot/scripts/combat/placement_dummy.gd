class_name PlacementDummy
extends Node3D

@export var available_material: Material
@export var unavailable_material: Material

var model: Node3D
var is_colliding: bool
var geometry_instances: Array[GeometryInstance3D] = []

@onready var obstacle_cast: ShapeCast3D = $ObstacleCast
@onready var model_root: Node3D = $ModelRoot


func _ready() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if not model:
		return
	is_colliding = obstacle_cast.is_colliding()


func set_model(p_model: Node3D):
	clear_model()
	model = p_model
	model_root.add_child(model)
	geometry_instances.clear()
	_init_geometries(model, geometry_instances)
	obstacle_cast.enabled = true
	set_physics_process(true)

	# animate model
	model_root.scale = Vector3(.1, .1, .1)
	var tweener = create_tween().tween_property(model_root, "scale", Vector3.ONE, .2)
	tweener.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func clear_model():
	if model:
		model.queue_free()
		model = null
	is_colliding = false
	obstacle_cast.enabled = false
	set_physics_process(false)


func _init_geometries(p_node: Node3D, list: Array[GeometryInstance3D]):
	if p_node is GeometryInstance3D:
		list.push_back(p_node)
	if p_node.get_child_count() == 0:
		return
	for it in p_node.get_children():
		if it is Node3D:
			_init_geometries(it, list)


# func set_model_materials(p_model: Node3D, p_is_available: bool):
# 	if p_model is GeometryInstance3D:
# 		p_model.material_override = available_material if p_is_available else unavailable_material
# 	if p_model.get_child_count() == 0:
# 		return
# 	for it in p_model.get_children():
# 		set_model_materials(it, p_is_available)


func set_model_materials(p_is_available: bool):
	for it in geometry_instances:
		# it.material_override = available_material if p_is_available else unavailable_material
		it.material_overlay = available_material if p_is_available else unavailable_material


func animate_pop():
	var tween = create_tween()
	tween.tween_property(model_root, "scale", Vector3(1.2, 1.2, 1.2), .09)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(model_root, "scale", Vector3.ONE, .09)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
