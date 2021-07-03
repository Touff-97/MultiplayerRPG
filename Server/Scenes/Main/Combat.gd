extends Node


func FetchSkillDamage(skill_name, player_id) -> int:
	var damage = ServerData.skill_data[skill_name].Damage * (0.1 * get_node("../" + str(player_id)).player_stats.Strength)
	return damage
