// Note: these only work in humans. They use human-specific parameters and rely on human code for displaying.

/obj/item/organ/external
	var/list/mutant_bodyparts = list()
	var/no_update = FALSE // when true, the associated bodypart's appearance is locked, useful for world-spawned external bodyparts, and augmented bodyparts
	var/animated_feature = FALSE

/obj/item/organ/external/Insert(mob/living/carbon/C, special = 0, drop_if_replaced = FALSE)
	. = ..()
	if(C == original_owner)
		update_from_features(C)
	else
		no_update = TRUE
	C.update_body()

/obj/item/organ/external/Remove(mob/living/carbon/C, special = 0)
	update_icon()
	. = ..()
	animated_feature = FALSE
	C.update_body()

/obj/item/organ/external/update_icon()
	. = ..()
	if(no_update)
		return
	icon_state = initial(icon_state)
	if(owner && ishuman(owner) && mutant_bodyparts.len)
		var/obj/item/bodypart/BP = owner.get_bodypart(zone)
		if(!BP)
			BP = loc
		if(!istype(BP))
			return
		if(BP.get_augtype() || (initial(status) == ORGAN_ROBOTIC))
			icon_state += "_aug"
		var/datum/sprite_accessory/S = get_feature_list(mutant_bodyparts[1])[mutant_bodyparts[mutant_bodyparts[1]]]
		if(istype(S) && !(S.name = "None"))
			var/mob/living/carbon/human/H = owner
			switch(S.color_src)
				if(MUTCOLORS)
					color = "#[H.dna.features["mcolor"]]"
				if(HAIR)
					if(H.hair_color == "mutcolor")
						color = "#[H.dna.features["mcolor"]]"
					else if(H.hair_color == "skin_tone")
						color = "#" + sprite_color2hex(H.skin_tone, GLOB.skin_tones_list)
					else
						color = "#[H.hair_color]"
				if(FACEHAIR)
					color = "#[H.facial_hair_color]"
				if(EYECOLOR)
					color = "#[H.eye_color]"
				if(SKIN_TONE)
					color = "#" + sprite_color2hex(H.skin_tone, GLOB.skin_tones_list)
				if(AUG_COLOR)
					if(is_type_in_typecache(S, GLOB.head_mut_parts_typecache))
						BP = H.get_bodypart(BODY_ZONE_HEAD)
					else
						BP = H.get_bodypart(BODY_ZONE_CHEST)
					var/aug_color = BP && BP.aug_color ? BP.aug_color : AUG_COLOR_DEFAULT
					color = "#" + sprite_color2hex(aug_color, GLOB.aug_colors_list)


/obj/item/organ/external/proc/update_from_features(mob/living/carbon/C, forced = FALSE, clear_empty = TRUE) //pulls the sprite accessory from features, use this after sanitizing features on a mob
	if(no_update && !forced)
		return
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/H = C
	var/obj/item/bodypart/parent_bodypart = H.get_bodypart(zone)
	if(!parent_bodypart)
		return
	var/aug_type = parent_bodypart.get_augtype()
	if(aug_type || (initial(status) == ORGAN_ROBOTIC))
		status = ORGAN_ROBOTIC
		organ_flags |= ORGAN_SYNTHETIC
	else
		status = ORGAN_ORGANIC
		organ_flags &= ~(ORGAN_SYNTHETIC|ORGAN_SYNTHETIC_EMP)

	for(var/feature in H.dna.features)
		if(feature in mutant_bodyparts)
			var/feature_to_add = (parent_bodypart.draw_state >= BODYPART_DRAW_ROBOTIC) ? mutant_bodyparts[feature] : H.dna.features[feature]
			feature_to_add = check_feature_by_index(feature_to_add, H.dna.species.features_id, feature, parent_bodypart.draw_state, TRUE)
			mutant_bodyparts[feature] = feature_to_add

	update_icon()
	if(initial(no_update) && !no_update)
		required_bodypart_status = FALSE //this is a contingency against world spawned external organs like cat tails which can also spawn at roundstart due to their types being used for meme content

/obj/item/organ/external/proc/get_sprite_accessory_list(mob/living/carbon/human/H)
	. = list()
	if(istype(H))
		var/obj/item/bodypart/parent_bodypart = H.get_bodypart(zone)
		if(!parent_bodypart)
			return
		if(parent_bodypart.draw_state == BODYPART_DRAW_ANDROID_SKELETAL)
			return
		for(var/feature in mutant_bodyparts)
			if((mutant_bodyparts[feature] != "None") && H.dna.species.should_display_feature(H, feature))
				if(parent_bodypart.draw_state != BODYPART_DRAW_ANDROID_SKELETAL)
					.[feature] = mutant_bodyparts[feature]

////////
//TAIL//
////////

/obj/item/organ/external/tail
	name = "tail"
	slot = ORGAN_SLOT_TAIL
	icon_state = "severedtail"
	mutant_bodyparts = list("tail" = "None", "tail_accessory" = "None")
	desc = "a severed tail."

//snowflake tails for the felinid/lizard discrimination memes!
/obj/item/organ/external/tail/cat
	name = "cat tail"
	mutant_bodyparts = list("tail" = "Cat", "tail_accessory" = "None")
	no_update = TRUE
	required_bodypart_status = BODYPART_ORGANIC

/obj/item/organ/external/tail/lizard
	name = "lizard tail"
	mutant_bodyparts = list("tail" = "Smooth", "tail_accessory" = "None")
	no_update = TRUE
	required_bodypart_status = BODYPART_ORGANIC

/obj/item/organ/external/tail/proc/wag()
	animated_feature = !animated_feature
	if(owner)
		owner.update_body()

/obj/item/organ/external/tail/proc/can_wag()
	return owner && !owner.stat && (owner.mobility_flags & MOBILITY_STAND)

/obj/item/organ/external/tail/get_sprite_accessory_list(mob/living/carbon/human/H)
	. = list()
	if(istype(H))
		var/obj/item/bodypart/parent_bodypart = owner.get_bodypart(zone)
		if(parent_bodypart.draw_state == BODYPART_DRAW_ANDROID_SKELETAL)
			return
		for(var/feature in mutant_bodyparts)
			if((mutant_bodyparts[feature] != "None") && H.dna.species.should_display_feature(H, feature))
				if(animated_feature)
					.["wagging" + feature] = mutant_bodyparts[feature]
				else
					.[feature] = mutant_bodyparts[feature]
/////////
//WINGS//
/////////

/obj/item/organ/external/wings
	name = "wings"
	desc = "a pair of severed wings"
	slot = ORGAN_SLOT_WINGS
	mutant_bodyparts = list("wings" = "None")
	icon_state = "severed_wings"
	actions_types = list(/datum/action/item_action/organ_action/toggle_flight)

/datum/action/item_action/organ_action/toggle_flight
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/toggle_flight/New(Target)
	..()
	name = "Toggle Flight"

/obj/item/organ/external/wings/proc/toggle_flight(mob/living/carbon/C)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.is_flying())
			H.dna.species.ToggleFlight(H)
		else if(H.dna.species.CanFly(H))
			H.dna.species.ToggleFlight(H)


/obj/item/organ/organ/external/wings/ui_action_click()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner

		if(H.is_flying())
			H.dna.species.ToggleFlight(H)
		else if(H.dna.species.CanFly(H))
			H.dna.species.ToggleFlight(H)

		if(H.is_flying())
			to_chat(H, "<span class='notice'>You beat your wings and begin to hover gently above the ground...</span>")
		else
			to_chat(H, "<span class='notice'>You settle gently back onto the ground...</span>")



/obj/item/organ/external/wings/Insert(mob/living/carbon/C, special = 0, drop_if_replaced = FALSE)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!H.dna.species.flying_species)
			H.dna.species.flying_species = TRUE

/obj/item/organ/external/wings/Remove(mob/living/carbon/C, special = FALSE)
	. = ..()
	if(C.is_flying())
		toggle_flight(C)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.dna.species.flying_species = FALSE
