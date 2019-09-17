/datum/species/tajaran
	// Khajit in SPESS
	name = "tajaran"
	id = "tajaran"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list("ears", "snout", "tail")
	mutantears = /obj/item/organ/ears/cat/tajaran
	//mutanttongue = /obj/item/organ/tongue/lizard
	mutanttail = /obj/item/organ/tail/tajaran
	default_features = list("mcolor" = "0F0", "snout" = "Normal", "ears" = "Pointed", "tail" = "Wingler")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = "T"
	disliked_food = GRAIN | DAIRY
	liked_food = GROSS | MEAT
	inert_mutation = DWARFISM
	deathsound = 'sound/voice/lizard/deathsound.ogg'

//datum/species/lizard/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	//H.grant_language(/datum/language/draconic)

//datum/species/lizard/random_name(gender,unique,lastname)
	//if(unique)
		//return random_unique_lizard_name(gender)

	//var/randname = lizard_name(gender)

	//if(lastname)
		//randname += " [lastname]"

	//return randname

//I wag in death
/datum/species/tajaran/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

datum/species/tajaran/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = ..()

datum/species/tajaran/can_wag_tail(mob/living/carbon/human/H)
	return ("tail" in mutant_bodyparts) || ("waggingtail" in mutant_bodyparts)

datum/species/tajaran/is_wagging_tail(mob/living/carbon/human/H)
	return ("waggingtail" in mutant_bodyparts)

datum/species/tajaran/start_wagging_tail(mob/living/carbon/human/H)
	if("tail" in mutant_bodyparts)
		mutant_bodyparts -= "tail"
		mutant_bodyparts -= "tail_accessory"
		mutant_bodyparts |= "waggingtail"
		mutant_bodyparts |= "waggingtail_accessory"
	H.update_body()

datum/species/tajaran/stop_wagging_tail(mob/living/carbon/human/H)
	if("waggingtail" in mutant_bodyparts)
		mutant_bodyparts -= "waggingtail"
		mutant_bodyparts -= "waggingtail_accessory"
		mutant_bodyparts |= "tail"
		mutant_bodyparts |= "tail_accessory"
	H.update_body()
