class_name DungeonHealthBar
extends Control

signal animation_finished

const HeartScene: PackedScene = preload("res://scenes/ui/common/heart_texture.tscn")

@export var heart_anim_duration := .8;
@export var heart_size: Vector2 = Vector2(56, 56)

var is_animating := false
var _hearts: Array[Control] = []


func set_value(health: int, is_anim: bool = true):
	if health == _hearts.size():
		return
	if health > _hearts.size():
		for i in range(_hearts.size(), health):
			var heart = HeartScene.instantiate() as TextureRect
			heart.custom_minimum_size = heart_size
			add_child(heart)
			_hearts.push_back(heart)
			if is_anim:
				heart.self_modulate = Color(1, 1, 1, 0)
				var tween = create_tween()
				tween.tween_property(heart, "self_modulate", Color.WHITE, heart_anim_duration)
	else:
		is_animating = true
		for i in range(_hearts.size() - 1, health - 1, -1):
			var heart = _hearts[i]
			_hearts.remove_at(i)
			if is_anim:
				var tween = create_tween()
				tween.tween_property(heart, "self_modulate", Color(1, 1, 1, 0), heart_anim_duration)
				await tween.finished
			heart.queue_free()
		is_animating = false
		if is_anim:
			animation_finished.emit()
