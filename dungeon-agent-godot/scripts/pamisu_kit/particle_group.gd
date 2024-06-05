@tool
class_name ParticleGroup
extends Node3D

signal finished

@export var debug_restart: bool:
	set(value):
		for child in get_children():
			if child is GPUParticles3D:
				child.restart()

var particles: Array[GPUParticles3D]
var _emitting_count: int = -1


func _ready():
	for child in get_children():
		if child is GPUParticles3D:
			child.finished.connect(_on_child_finished)
			particles.append(child)


func _on_child_finished():
	_emitting_count -= 1
	if _emitting_count == 0:
		finished.emit()
		_emitting_count = -1


func restart():
	if particles.size() == 0:
		return
	_emitting_count = 0
	for it in particles:
		it.restart()
		_emitting_count += 1


func set_emitting(is_enabled: bool):
	if particles.size() == 0:
		return
	_emitting_count = 0
	for it in particles:
		it.emitting = is_enabled
		_emitting_count += 1


func is_emitting():
	return _emitting_count > 0
