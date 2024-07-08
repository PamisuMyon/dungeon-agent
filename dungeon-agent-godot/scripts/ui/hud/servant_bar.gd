extends Control

const CharHandCardScene: PackedScene = preload("res://scenes/ui/hud/char_hand_card.tscn")

var _card_pool: NodePool
var _cards: Array[CharHandCard] = [] # cards in use
var _selected_index: int = -1
var _current_card_state: CharHandCard.CardState = CharHandCard.CardState.NORMAL


func _ready() -> void:
	_card_pool = NodePool.new()
	_card_pool.init_by_scene(self, CharHandCardScene)
	_refresh()
	Events.servant_placed.connect(_on_servant_placed)
	Events.servant_place_cancelled.connect(_on_servant_place_cancelled)
	Events.inventory_servants_changed.connect(_on_inventory_servants_changed)
	Events.combat_state_changed.connect(_on_combat_state_changed)


func _refresh():
	for it in _cards:
		it.card_selected.disconnect(_on_card_selected)
	_cards.clear()
	_card_pool.release_all_in_use()

	var servants = App.save.runtime.servants
	for i in range(servants.size()):
		var config = servants[i]
		var card = _card_pool.spawn() as CharHandCard
		move_child(card, 0)
		card.set_data(config)
		card.change_state(_current_card_state)
		if not card.card_selected.is_connected(_on_card_selected):
			card.card_selected.connect(_on_card_selected)
		_cards.push_back(card)
	
	# await get_tree().process_frame
	# for card in _cards:
	# 	card.scale = Vector2(.8, .8)


func _on_card_selected(card: CharHandCard):
	if App.combat_manager.bb.sub_state != CombatBlackboard.SubState.EMBATTLE_NONE:
		return
	for i in range(_cards.size()):
		if _cards[i] == card:
			_selected_index = i
			_cards[i].change_state(CharHandCard.CardState.SELECTED)
		else:
			_cards[i].change_state(CharHandCard.CardState.DISABLED)
	App.combat_manager.place_servant(_selected_index)


func _on_servant_placed():
	var card = _cards[_selected_index]
	_cards.remove_at(_selected_index)
	_card_pool.release(card)
	_selected_index = -1


func _on_servant_place_cancelled():
	_selected_index = -1


func _on_inventory_servants_changed():
	_refresh()


func _on_combat_state_changed(state: CombatBlackboard.SubState):
	if state == CombatBlackboard.SubState.BATTLE:
		_current_card_state = CharHandCard.CardState.DISABLED
	elif state == CombatBlackboard.SubState.EMBATTLE_NONE:
		_current_card_state = CharHandCard.CardState.NORMAL
	# TODO temp
	elif state == CombatBlackboard.SubState.WAVE_END_SHOP:
		_current_card_state = CharHandCard.CardState.NORMAL
	else:
		return

	for i in range(_cards.size()):
		_cards[i].change_state(_current_card_state)
