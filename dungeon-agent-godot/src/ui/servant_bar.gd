extends Control

const ServantCardScene: PackedScene = preload("res://scenes/ui/servant_card.tscn")

var card_pool: NodePool
var cards: Array[ServantCard] = []


func _ready() -> void:
	card_pool = NodePool.new()
	card_pool.init_by_scene(self, ServantCardScene)
	_refresh()
	

func _refresh():
	for it in cards:
		it.card_selected.disconnect(_on_card_selected)
	cards.clear()
	card_pool.release_all_in_use()

	var servants = App.combat_controller.data.servants
	for i in range(servants.size()):
		var config = servants[i]
		var card = card_pool.spawn() as ServantCard
		card.set_data(i, config)
		card.change_state(ServantCard.State.NORMAL)
		card.card_selected.connect(_on_card_selected)
		cards.push_back(card)


func _on_card_selected(index: int, config: CharacterConfig):
	for i in range(cards.size()):
		if i == index:
			cards[i].change_state(ServantCard.State.SELECTED)
		else:
			cards[i].change_state(ServantCard.State.DISABLED)
