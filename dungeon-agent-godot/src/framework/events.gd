extends Node

signal req_change_grid_map_solid_cell(pos: Vector2i)


#region UI

signal req_bind_character_floating_info(chara: Character)

signal req_unbind_character_floating_info(chara: Character)

signal req_show_damage_text(world_pos: Vector3, value: float, is_critical: bool)

signal req_show_character_info_card(chara: Character)

signal req_hide_character_info_card

#endregion
