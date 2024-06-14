class_name ShopItemView
extends Control

signal buy_button_pressed(item: ShopItem)

@export var name_label: Label
@export var icon: TextureRect
@export var ability_item: AbilityItem
@export var buy_button: Button
@export var price_label: Label

@export_category("Stats")
@export var health: StatTag
@export var damage: StatTag
@export var move: StatTag

var _item: ShopItem


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)
	Events.consumable_changed.connect(_on_consumable_changed)


func _on_buy_button_pressed():
	buy_button_pressed.emit(_item)


func _on_consumable_changed(type: Schema.ConsumableType, new_value, _delta):
	if type == Schema.ConsumableType.GOLD:
		_refresh_buy_button(_item.price, new_value)


func set_data(item: ShopItem):
	_item = item
	name_label.text = item.config.display_name

	if item.config.skill_abilities.is_empty():
		ability_item.visible = false
		size.y = 100
	else:
		ability_item.visible = true
		ability_item.set_data(item.config.skill_abilities[0])

	health.set_value(item.config.max_health)
	damage.set_value(item.config.damage)
	move.set_value(item.config.move)

	if item.config.icon_path:
		icon.visible = true
		icon.texture = load(item.config.icon_path)
	else:
		icon.visible = false

	_refresh_buy_button(item.price, App.save.runtime.gold)


func _refresh_buy_button(price: int, gold: int):
	var can_buy = price <= App.save.runtime.gold
	buy_button.disabled = not can_buy
	price_label.text = str(price)
	price_label.set("theme_override_colors/font_color", GlobalConst.PRICE_TAG_COLOR_AVAILABLE if can_buy else GlobalConst.PRICE_TAG_COLOR_UNAVAILABLE)
