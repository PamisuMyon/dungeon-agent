extends Node


#region Misc

signal dungeon_health_changed(new_health: int)

signal consumable_changed(type: Schema.ConsumableType, new_value, delta)

signal inventory_servants_changed

#endregion

#region Combat

# signal req_change_grid_map_solid_cell(pos: Vector2i)

signal combat_state_changed(state: CombatBlackboard.SubState)

signal servant_placed

signal servant_place_cancelled

signal req_start_battle

signal req_next_battle

#endregion

#region Shop

signal shop_items_updated(items: Array[ShopItem])

signal req_shop_reroll

signal req_shop_buy_item

signal shop_reroll_price_changed(price: int)

#endregion

#region UI

signal req_bind_character_floating_info(chara: Character)

signal req_unbind_character_floating_info(chara: Character)

signal req_show_damage_text(world_pos: Vector3, value: float, is_critical: bool)

signal req_show_character_info_card(chara: Character)

signal req_hide_character_info_card

signal req_show_shop_view

signal req_hide_shop_view

signal req_show_defeated_view

signal req_show_victory_view

signal req_show_dungeon_health_detail_view

signal dungeon_health_detail_view_anim_finished

#endregion
