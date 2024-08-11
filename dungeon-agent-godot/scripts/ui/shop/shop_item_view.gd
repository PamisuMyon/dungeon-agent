class_name ShopItemView
extends Control

@export var buy_button: Button
@export var price_label: Label
@export var char_info: CharacterInfoView

var _index: int
var _item: ShopItem


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)
	Events.consumable_changed.connect(_on_consumable_changed)


func on_spawn():
	visible = true


func on_release():
	visible = false


func _on_buy_button_pressed():
	Events.req_shop_buy_item.emit(_index)


func _on_consumable_changed(type: Schema.ConsumableType, new_value, _delta):
	if type == Schema.ConsumableType.GOLD:
		_refresh_buy_button(_item.price, new_value)


func set_data(index: int, item: ShopItem):
	_index = index
	_item = item
	char_info.inflate_by_config(item.config)

	_refresh_buy_button(item.price, App.save.runtime.gold)


func _refresh_buy_button(price: int, gold: int):
	var can_buy = price <= App.save.runtime.gold
	buy_button.disabled = not can_buy
	price_label.text = str(price)
	price_label.set("theme_override_colors/font_color", GlobalConst.PRICE_TAG_COLOR_AVAILABLE if can_buy else GlobalConst.PRICE_TAG_COLOR_UNAVAILABLE)
