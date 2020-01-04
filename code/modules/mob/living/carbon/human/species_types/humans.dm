/datum/species/human
	name = "human"
	id = "human"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS, SKIN_TONE)
	default_features = list("mcolor" = "FFF", "wings" = "None")
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW | SENTIENT
	liked_food = JUNKFOOD | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	quirk_budget = QUIRK_POINTS_HUMAN
/datum/species/human/qualifies_for_rank(rank, list/features)
	return TRUE	//Pure humans are always allowed in all roles.
