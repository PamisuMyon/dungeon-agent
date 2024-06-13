extends Node

@onready var config: ConfigSystem = $ConfigSystem
@onready var save: SaveSystem = $SaveSystem

var combat_manager: CombatManager
var shop_manager: ShopManager
