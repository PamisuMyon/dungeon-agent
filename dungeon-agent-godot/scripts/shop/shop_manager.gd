class_name ShopManager
extends Node

@export var capacity: int = 4

var current_items: Array[ShopItem] = []
var item_price_scale: float = 1.
var reroll_price: int
var _reroll_increase: int


func _ready() -> void:
	App.shop_manager = self
	Events.req_shop_reroll.connect(_on_req_shop_items_reroll)
	Events.req_shop_buy_item.connect(_on_req_shop_buy_item)
	

func _on_req_shop_items_reroll():
	# check cost
	if not can_reroll():
		print("shop reroll: not enough gold %d  price %f" % [App.save.runtime.gold, reroll_price])
		return
	App.save.runtime.change_gold(-reroll_price)
	reroll_price += _reroll_increase
	Events.shop_reroll_price_changed.emit(reroll_price)
	roll_items()


func _on_req_shop_buy_item(index: int):
	assert(index < current_items.size(), "shop buy item: index %d out of bounds" % index)
	var item = current_items[index]
	if App.save.runtime.gold < item.price:
		print("shop buy item: not enough gold %d  price %f" % [App.save.runtime.gold, item.price])
		return
	App.save.runtime.change_gold(-item.price)
	# add to inventory # TODO temp
	App.save.runtime.servants.push_back(item.config)
	Events.inventory_servants_changed.emit()
	# remove item
	current_items.remove_at(index)
	Events.shop_items_updated.emit(current_items)


func show_shop():
	var level_num = App.save.runtime.level_index + 1
	_reroll_increase = max(1, floori(.5 * level_num))
	reroll_price = level_num + _reroll_increase
	Events.shop_reroll_price_changed.emit(reroll_price)
	roll_items()
	Events.req_show_shop_view.emit()


func roll_items():
	# TODO Temp
	current_items.clear()
	for i in range(capacity):
		var item = ShopItem.new()
		item.config = App.config.all_servants.pick_random()
		item.price = item.config.base_price
		current_items.push_back(item)
	
	Events.shop_items_updated.emit(current_items)


func can_reroll() -> bool:
	return reroll_price <= App.save.runtime.gold
