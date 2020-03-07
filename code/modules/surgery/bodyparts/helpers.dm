
/mob/living/proc/get_bodypart(zone)
	return

/mob/living/carbon/get_bodypart(zone)
	if(!zone)
		zone = BODY_ZONE_CHEST
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		if(L.body_zone == zone)
			return L

/mob/living/carbon/has_hand_for_held_index(i)
	if(i)
		var/obj/item/bodypart/L = hand_bodyparts[i]
		if(L && !L.disabled)
			return L
	return FALSE




/mob/proc/has_left_hand(check_disabled = TRUE)
	return TRUE

/mob/living/carbon/has_left_hand(check_disabled = TRUE)
	for(var/obj/item/bodypart/L in hand_bodyparts)
		if(L.held_index % 2)
			if(!check_disabled || !L.disabled)
				return TRUE
	return FALSE

/mob/living/carbon/alien/larva/has_left_hand()
	return 1


/mob/proc/has_right_hand(check_disabled = TRUE)
	return TRUE

/mob/living/carbon/has_right_hand(check_disabled = TRUE)
	for(var/obj/item/bodypart/L in hand_bodyparts)
		if(!(L.held_index % 2))
			if(!check_disabled || !L.disabled)
				return TRUE
	return FALSE

/mob/living/carbon/alien/larva/has_right_hand()
	return 1



//Limb numbers
/mob/proc/get_num_arms(check_disabled = TRUE)
	return 2

/mob/living/carbon/get_num_arms(check_disabled = TRUE)
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == ARM_RIGHT)
			if(!check_disabled || !affecting.disabled)
				.++
		if(affecting.body_part == ARM_LEFT)
			if(!check_disabled || !affecting.disabled)
				.++


//sometimes we want to ignore that we don't have the required amount of arms.
/mob/proc/get_arm_ignore()
	return 0

/mob/living/carbon/alien/larva/get_arm_ignore()
	return 1 //so we can still handcuff larvas.


/mob/proc/get_num_legs(check_disabled = TRUE)
	return 2

/mob/living/carbon/get_num_legs(check_disabled = TRUE)
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == LEG_RIGHT)
			if(!check_disabled || !affecting.disabled)
				.++
		if(affecting.body_part == LEG_LEFT)
			if(!check_disabled || !affecting.disabled)
				.++

//sometimes we want to ignore that we don't have the required amount of legs.
/mob/proc/get_leg_ignore()
	return FALSE

/mob/living/carbon/alien/larva/get_leg_ignore()
	return TRUE

/mob/living/carbon/human/get_leg_ignore()
	if(movement_type & (FLYING | FLOATING))
		return TRUE
	return FALSE

/mob/living/proc/get_missing_limbs()
	return list()

/mob/living/carbon/get_missing_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

/mob/living/carbon/alien/larva/get_missing_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST)
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

/mob/living/proc/get_disabled_limbs()
	return list()

/mob/living/carbon/get_disabled_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/list/disabled = list()
	for(var/zone in full)
		var/obj/item/bodypart/affecting = get_bodypart(zone)
		if(affecting && affecting.disabled)
			disabled += zone
	return disabled

/mob/living/carbon/alien/larva/get_disabled_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST)
	var/list/disabled = list()
	for(var/zone in full)
		var/obj/item/bodypart/affecting = get_bodypart(zone)
		if(affecting && affecting.disabled)
			disabled += zone
	return disabled

//Remove all embedded objects from all limbs on the carbon mob
/mob/living/carbon/proc/remove_all_embedded_objects()
	var/turf/T = get_turf(src)

	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/obj/item/I in L.embedded_objects)
			L.embedded_objects -= I
			I.forceMove(T)
			I.unembedded()

	clear_alert("embeddedobject")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "embedded")

/mob/living/carbon/proc/has_embedded_objects()
	. = FALSE
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/obj/item/I in L.embedded_objects)
			return TRUE


//Helper for quickly creating a new limb - used by augment code in species.dm spec_attacked_by
/mob/living/carbon/proc/newBodyPart(zone, robotic, fixed_icon, aug_style_target = AUG_STYLE_DEFAULT, aug_type = AUG_TYPE_ROBOTIC, aug_color_target = AUG_COLOR_DEFAULT, aug_decal_target)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_L_ARM)
			L = new /obj/item/bodypart/l_arm()
		if(BODY_ZONE_R_ARM)
			L = new /obj/item/bodypart/r_arm()
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head()
		if(BODY_ZONE_L_LEG)
			L = new /obj/item/bodypart/l_leg()
		if(BODY_ZONE_R_LEG)
			L = new /obj/item/bodypart/r_leg()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE, aug_style_target, aug_type, aug_color_target, aug_decal_target)
	. = L

/mob/living/carbon/monkey/newBodyPart(zone, robotic, fixed_icon, aug_style_target = AUG_STYLE_DEFAULT, aug_type = AUG_TYPE_ROBOTIC, aug_color_target = AUG_COLOR_DEFAULT)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_L_ARM)
			L = new /obj/item/bodypart/l_arm/monkey()
		if(BODY_ZONE_R_ARM)
			L = new /obj/item/bodypart/r_arm/monkey()
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head/monkey()
		if(BODY_ZONE_L_LEG)
			L = new /obj/item/bodypart/l_leg/monkey()
		if(BODY_ZONE_R_LEG)
			L = new /obj/item/bodypart/r_leg/monkey()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest/monkey()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE)
	. = L

/mob/living/carbon/alien/larva/newBodyPart(zone, robotic, fixed_icon, aug_style_target = AUG_STYLE_DEFAULT, aug_type = AUG_TYPE_ROBOTIC, aug_color_target = AUG_COLOR_DEFAULT)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head/larva()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest/larva()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE)
	. = L

/mob/living/carbon/alien/humanoid/newBodyPart(zone, robotic, fixed_icon, aug_style_target = AUG_STYLE_DEFAULT, aug_type = AUG_TYPE_ROBOTIC, aug_color_target = AUG_COLOR_DEFAULT)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_L_ARM)
			L = new /obj/item/bodypart/l_arm/alien()
		if(BODY_ZONE_R_ARM)
			L = new /obj/item/bodypart/r_arm/alien()
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head/alien()
		if(BODY_ZONE_L_LEG)
			L = new /obj/item/bodypart/l_leg/alien()
		if(BODY_ZONE_R_LEG)
			L = new /obj/item/bodypart/r_leg/alien()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest/alien()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE)
	. = L


/proc/skintone2hex(skin_tone)
	. = 0
	switch(skin_tone)
		if("caucasian1")
			. = "ffe0d1"
		if("caucasian2")
			. = "fcccb3"
		if("caucasian3")
			. = "e8b59b"
		if("latino")
			. = "d9ae96"
		if("mediterranean")
			. = "c79b8b"
		if("asian1")
			. = "ffdeb3"
		if("asian2")
			. = "e3ba84"
		if("arab")
			. = "c4915e"
		if("indian")
			. = "b87840"
		if("african1")
			. = "754523"
		if("african2")
			. = "471c18"
		if("albino")
			. = "fff4e6"
		if("orange")
			. = "ffc905"

/mob/living/carbon/proc/Digitigrade_Leg_Swap(swap_back, swap_augmented)
	var/body_plan_changed = FALSE
	for(var/obj/item/bodypart/BP in bodyparts)
		if(!("legs" in BP.mutant_bodyparts) || BP.no_update || ((BP.get_augtype() == AUG_TYPE_DIGITIGRADE) && !swap_augmented))
			continue
		if(swap_back && BP.use_digitigrade)
			BP.use_digitigrade = NOT_DIGITIGRADE
			BP.mutant_bodyparts["legs"] = "None"
			body_plan_changed = TRUE
		else if(!BP.use_digitigrade)
			BP.mutant_bodyparts["legs"] = "Digitigrade Legs"
			body_plan_changed = TRUE

	if(body_plan_changed && ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/clothing/under/U = H.w_uniform
		if(U && U.mutantrace_variation)
			U.adjusted = swap_back ? NORMAL_STYLE : DIGITIGRADE_STYLE
			H.update_inv_w_uniform()
		if(H.shoes && !swap_back)
			H.dropItemToGround(H.shoes)
		H.update_mutant_bodyparts()

/mob/living/carbon/proc/has_digitigrade_legs()
	for(var/obj/item/bodypart/BP in bodyparts)
		if(BP.use_digitigrade)
			return TRUE

/proc/aug_id2augstyle(aug_id)
	switch(aug_id)
		if("nanotrasen")
			return "Nanotrasen Robotics Division"
		if("bishop")
			return "Bishop Cybernetics"
		if("wt-medical")
			return "Ward-Takahashi Robotics Medical Line"
		if("wt-industrial")
			return "Ward-Takahashi Robotics Industrial Line"
		if("wt-shellguard")
			return "Ward-Takahashi Robotics Shellguard Line"
		if("wt-prosthetic")
			return "Ward-Takahashi Robotics Prosthetics Line"

/proc/get_eligible_augmentation_types(augname, body_zone)
	var/datum/sprite_accessory/augmentation/S = GLOB.augmentation_styles_list[augname]
	if(!istype(S))
		return
	return S.eligible_bodyparts[body_zone]


