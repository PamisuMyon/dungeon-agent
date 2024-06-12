extends Control

const ServantCardScene: PackedScene = preload("res://scenes/ui/hud/servant_card.tscn")

var card_pool: NodePool
var cards: Array[ServantCard] = [] # cards in use
var _selected_index: int = -1


func _ready() -> void:
	card_pool = NodePool.new()
	card_pool.init_by_scene(self, ServantCardScene)
	_refresh()
	Events.servant_placed.connect(_on_servant_placed)
	Events.servant_place_cancelled.connect(_on_servant_place_cancelled)
	Events.inventory_servants_changed.connect(_on_inventory_servants_changed)
	Events.combat_state_changed.connect(_on_combat_state_changed)


func _refresh():
	for it in cards:
		it.card_selected.disconnect(_on_card_selected)
	cards.clear()
	card_pool.release_all_in_use()

	var servants = App.combat_controller.bb.inventory_servants
	for i in range(servants.size()):
		var config = servants[i]
		var card = card_pool.spawn() as ServantCard
		move_child(card, 0)
		card.set_data(config)
		card.change_state(ServantCard.CardState.NORMAL)
		card.card_selected.connect(_on_card_selected)
		cards.push_back(card)


func _on_card_selected(card: ServantCard):
	for i in range(cards.size()):
		if cards[i] == card:
			_selected_index = i
			cards[i].change_state(ServantCard.CardState.SELECTED)
		else:
			cards[i].change_state(ServantCard.CardState.DISABLED)
	App.combat_controller.place_servant(_selected_index)


func _on_servant_placed():
	var card = cards[_selected_index]
	cards.remove_at(_selected_index)
	card_pool.release(card)
	_selected_index = -1


func _on_servant_place_cancelled():
	_selected_index = -1


func _on_inventory_servants_changed():
	_refresh()


func _on_combat_state_changed(state: CombatBlackboard.SubState):
	if state == CombatBlackboard.SubState.BATTLE:
		for i in range(cards.size()):
			cards[i].change_state(ServantCard.CardState.DISABLED)
	elif state == CombatBlackboard.SubState.EMBATTLE_NONE:
		for i in range(cards.size()):
			cards[i].change_state(ServantCard.CardState.NORMAL)
