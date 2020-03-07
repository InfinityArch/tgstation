/datum/species/tajaran
	// Khajit in SPESS
	name = "tajaran"
	id = "tajaran"
	naming_convention = APO_NAME_REV
	names_id = "lizard"
	default_color = "00FF00"
	species_traits = list(SKIN_TONE, HAIR, FACEHAIR,EYECOLOR,LIPS)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list("ears", "snout", "tail")
	mutantears = /obj/item/organ/external/ears/tajaran
	mutanttail = /obj/item/organ/external/tail
	hair_color = "skin_tone"
	feature_names = list("skin_tone" = "fur color", "snout" = "muzzle")
	mutanteyes = /obj/item/organ/eyes/tajaran
	default_features = list("mcolor" = "0F0", "snout" = "Light", "ears" = "Pointed", "tail" = "Wingler")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	species_language_holder = /datum/language_holder/tajaran
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/tajaran
	skinned_type = /obj/item/stack/sheet/animalhide/cat
	exotic_bloodtype = "T"
	disliked_food = GRAIN | GROSS | SENTIENT
	liked_food = DAIRY | MEAT
	deathsound = 'sound/voice/lizard/deathsound.ogg'

datum/species/tajaran/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/tajaran)

//I wag in death
/datum/species/tajaran/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

//datum/species/tajaran/spec_stun(mob/living/carbon/human/H,amount)
	//if(H)
	//	stop_wagging_tail(H)
	//. = ..()

//datum/species/tajaran/can_wag_tail(mob/living/carbon/human/H)
	//return ("tail" in mutant_bodyparts) || ("waggingtail" in mutant_bodyparts)

//datum/species/tajaran/is_wagging_tail(mob/living/carbon/human/H)
	//return ("waggingtail" in mutant_bodyparts)

//datum/species/tajaran/start_wagging_tail(mob/living/carbon/human/H)
	//if("tail" in mutant_bodyparts)
		//mutant_bodyparts -= "tail"
		//mutant_bodyparts -= "tail_accessory"
	//if("tail_accessory" in mutant_bodyparts)
		//mutant_bodyparts |= "waggingtail"
		//mutant_bodyparts |= "waggingtail_accessory"
	//H.update_body()

//datum/species/tajaran/stop_wagging_tail(mob/living/carbon/human/H)
	//if("waggingtail" in mutant_bodyparts)
		//mutant_bodyparts -= "waggingtail"
		//mutant_bodyparts -= "waggingtail_accessory"
	//if("waggingtail_accessory" in mutant_bodyparts)
		//mutant_bodyparts |= "tail"
		//mutant_bodyparts |= "tail_accessory"
	//H.update_body()
