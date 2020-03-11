/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "unathi"
	id = "lizard"
	naming_convention = HYPHEN_NAME
	say_mod = "hisses"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	mutant_bodyparts = list("tail", "snout", "tail_accessory", "horns", "frills", "body_markings", "legs")
	mutanttongue = /obj/item/organ/tongue/lizard
	mutanttail = /obj/item/organ/external/tail/lizard
	coldmod = 1.5
	heatmod = 0.67
	default_features = list("mcolor" = "0F0", "tail" = "Smooth", "snout" = "Round", "horns" = "None", "frills" = "None", "tail_accessory" = "None", "body_markings" = "None", "legs" = "None")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = "L"
	disliked_food = GRAIN | DAIRY
	liked_food = GROSS | MEAT | SENTIENT
	inert_mutation = FIREBREATH
	deathsound = 'sound/voice/lizard/deathsound.ogg'
	species_language_holder = /datum/language_holder/lizard
	// Lizards are coldblooded and can stand a greater temperature range than humans
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT + 20) // This puts lizards 10 above lavaland max heat for ash lizards.
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 10)

/// Lizards are cold blooded and do not stabilize body temperature naturally
/datum/species/lizard/natural_bodytemperature_stabilization(datum/gas_mixture/environment, mob/living/carbon/human/H)
	return

//I wag in death
//datum/species/lizard/spec_death(gibbed, mob/living/carbon/human/H)
	//if(H)
		//stop_wagging_tail(H)

//datum/species/lizard/spec_stun(mob/living/carbon/human/H,amount)
	//if(H)
		//stop_wagging_tail(H)
	//. = ..()

//datum/species/lizard/can_wag_tail(mob/living/carbon/human/H)
	//return ("tail" in mutant_bodyparts) || ("waggingtail" in mutant_bodyparts)

//datum/species/lizard/is_wagging_tail(mob/living/carbon/human/H)
	//return ("waggingtail" in mutant_bodyparts)

//datum/species/lizard/start_wagging_tail(mob/living/carbon/human/H)
	//if("tail" in mutant_bodyparts)
		//mutant_bodyparts -= "tail"
		//mutant_bodyparts -= "tail_accessory"
		//mutant_bodyparts |= "waggingtail"
		//mutant_bodyparts |= "waggingtail_accessory"
	//H.update_body()

//datum/species/lizard/stop_wagging_tail(mob/living/carbon/human/H)
	//if("waggingtail" in mutant_bodyparts)
		//mutant_bodyparts -= "waggingtail"
		//mutant_bodyparts -= "waggingtail_accessory"
		//mutant_bodyparts |= "tail"
		//mutant_bodyparts |= "tail_accessory"
	//H.update_body()

/*
 Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = "ashlizard"
	limbs_id = "lizard"
	force_digitigrade = TRUE
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,DIGITIGRADE)
	inherent_traits = list(TRAIT_CHUNKYFINGERS,TRAIT_NOBREATH)
	species_language_holder = /datum/language_holder/lizard/ash
