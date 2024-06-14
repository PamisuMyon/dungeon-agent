extends Control

const ShopItemViewScene = preload("res://scenes/ui/shop/shop_item_view.tscn")

@export var item_container: Control
@export var reroll_button: Button
@export var reroll_label: Label
@export var reroll_price_label: Label

var _item_pool: NodePool
var _items: Array[ShopItemView] = [] # items in use


func _ready() -> void:
	_item_pool = NodePool.new()
	_item_pool.init_by_scene(item_container, ShopItemViewScene)

	reroll_button.pressed.connect(_on_reroll_button_pressed)

	Events.shop_items_updated.connect(_on_shop_items_updated)
	Events.shop_reroll_price_changed.connect(_on_shop_reroll_price_changed)
	Events.req_show_shop_view.connect(show_shop)
	Events.req_hide_shop_view.connect(hide_shop)


func _on_reroll_button_pressed():
	Events.req_shop_reroll.emit()


func _on_shop_items_updated(items: Array[ShopItem]):
	refresh_items(items)


func _on_shop_reroll_price_changed(price: int):
	refresh_reroll_button(price)


func show_shop():
	visible = true


func hide_shop():
	visible = false


func refresh_reroll_button(price: int):
	var can_reroll = App.shop_manager.can_reroll()
	reroll_button.disabled = not can_reroll
	reroll_label.set("theme_override_colors/font_color", Color.WHITE if can_reroll else GlobalConst.PRICE_TAG_COLOR_UNAVAILABLE)
	reroll_price_label.set("theme_override_colors/font_color", GlobalConst.PRICE_TAG_COLOR_AVAILABLE if can_reroll else GlobalConst.PRICE_TAG_COLOR_UNAVAILABLE)
	reroll_price_label.text = str(price)


func refresh_items(items: Array[ShopItem]):
	_items.clear()
	_item_pool.release_all_in_use()
	for it in items:
		var item_view = _item_pool.spawn() as ShopItemView
		item_view.set_data(it)
		_items.push_back(item_view)
