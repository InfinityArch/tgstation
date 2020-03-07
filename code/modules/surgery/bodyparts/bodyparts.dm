/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/mob/human_parts.dmi'
	icon_state = ""
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	var/mob/living/carbon/owner = null
	var/mob/living/carbon/original_owner = null
	var/status = BODYPART_ORGANIC // is the bodypart robotic or organic?
	var/draw_state = BODYPART_ORGANIC
	var/bodypart_status_flags = 0 // bitfield for status flags
	var/needs_processing = FALSE

	//sprite accessories
	var/list/mutant_bodyparts = list() // an association list of sprite accessories names that are attached to this bodypart indexed by their mutant feature name
	var/body_zone //BODY_ZONE_CHEST, BODY_ZONE_L_ARM, etc , used for def_zone
	var/aux_zone // used for hands and feet
	var/aux_layer // if defined, the bodypart will render its aux_zone as an overlay on this layer
	var/body_part = null //bitflag used to check which clothes cover this bodypart
	var/use_digitigrade = NOT_DIGITIGRADE //Used for alternate legs, useless elsewhere
	var/list/embedded_objects = list()
	var/held_index = 0 //are we a hand? if so, which one!
	var/is_pseudopart = FALSE //For limbs that don't really exist, eg chainsaws

	var/disabled = BODYPART_NOT_DISABLED //If disabled, limb is as good as missing
	var/body_damage_coeff = 1 //Multiplier of the limb's damage that gets applied to the mob
	var/stam_damage_coeff = 0.75
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/stamina_dam = 0
	var/max_stamina_damage = 0
	var/max_damage = 0

	var/cremation_progress = 0 //Gradually increases while burning when at full damage, destroys the limb when at 100

	var/brute_reduction = 0 //Subtracted to brute damage taken
	var/burn_reduction = 0	//Subtracted to burn damage taken

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/body_gender = ""
	var/species_id = ""// name of the iconbase used for organic limbs
	var/aug_id = "" // name of the iconbase used for robotic limbs
	var/should_draw_gender = FALSE
	var/should_draw_greyscale = FALSE
	var/should_draw_husked = FALSE
	var/species_color = ""
	var/mutation_color = ""
	var/aux_color = "" // color to use for aux parts, if any
	var/decal_color = "" // color for an independently colored area of this part, rendered as an overlay on top of the bodypart and if applicable its aux layer
	var/aug_color = "" // color to use for robotic parts
	var/no_update = 0

	var/animal_origin = null //for nonhuman bodypart (e.g. monkey)
	var/dismemberable = 1 //whether it can be dismembered with a weapon.

	var/px_x = 0
	var/px_y = 0

	var/species_flags_list = list()
	var/dmg_overlay_type //the type of damage overlay (if any) to use when this bodypart is bruised/burned.

	//Damage messages used by help_shake_act()
	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/light_burn_msg = "numb"
	var/medium_burn_msg = "blistered"
	var/heavy_burn_msg = "peeling away"

/obj/item/bodypart/examine(mob/user)
	. = ..()
	if(brute_dam > DAMAGE_PRECISION)
		. += "<span class='warning'>This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.</span>"
	if(burn_dam > DAMAGE_PRECISION)
		. += "<span class='warning'>This limb has [burn_dam > 30 ? "severe" : "minor"] burns.</span>"

/obj/item/bodypart/blob_act()
	take_damage(max_damage)

/obj/item/bodypart/Destroy()
	if(owner)
		owner.bodyparts -= src
		owner = null
	return ..()

/obj/item/bodypart/attack(mob/living/carbon/C, mob/user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(HAS_TRAIT(C, TRAIT_LIMBATTACHMENT))
			if(!H.get_bodypart(body_zone) && !animal_origin)
				if(H == user)
					H.visible_message("<span class='warning'>[H] jams [src] into [H.p_their()] empty socket!</span>",\
					"<span class='notice'>You force [src] into your empty socket, and it locks into place!</span>")
				else
					H.visible_message("<span class='warning'>[user] jams [src] into [H]'s empty socket!</span>",\
					"<span class='notice'>[user] forces [src] into your empty socket, and it locks into place!</span>")
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				attach_limb(C)
				return
	..()

/obj/item/bodypart/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness() && is_organic_limb())
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, "<span class='warning'>There is nothing left inside [src]!</span>")
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, TRUE, -1)
		user.visible_message("<span class='warning'>[user] begins to cut open [src].</span>",\
			"<span class='notice'>You begin to cut open [src]...</span>")
		if(do_after(user, 54, target = src))
			drop_organs(user, TRUE)
	else if(W.tool_behaviour == TOOL_SCREWDRIVER && !is_organic_limb())
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, "<span class='warning'>There is nothing left inside [src]!</span>")
			return
		playsound(loc, 'sound/items/screwdriver.ogg', 50, TRUE, -1)
		user.visible_message("<span class='warning'>[user] begins to screw open [src]'s access panel.</span>",\
			"<span class='notice'>You begin to screw open [src]'s access panel...</span>")
		if(do_after(user, 54, target = src))
			drop_organs(user, TRUE)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(is_organic_limb())
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, TRUE, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user, violent_removal)
	var/turf/T = get_turf(src)
	if(is_organic_limb())
		playsound(T, 'sound/misc/splort.ogg', 50, TRUE, -1)
	for(var/obj/item/I in src)
		if(isorgan(I))
			var/obj/item/organ/O = I
			if(O.organ_flags & ORGAN_ABSTRACT)
				continue
		I.forceMove(T)

/obj/item/bodypart/proc/consider_processing()
	if(stamina_dam > DAMAGE_PRECISION)
		. = TRUE
	//else if.. else if.. so on.
	else
		. = FALSE
	needs_processing = .

//Return TRUE to get whatever mob this is in to update health.
/obj/item/bodypart/proc/on_life(stam_regen)
	if(stamina_dam > DAMAGE_PRECISION && stam_regen)					//DO NOT update health here, it'll be done in the carbon's life.
		heal_damage(0, 0, INFINITY, null, FALSE)
		. |= BODYPART_LIFE_UPDATE_HEALTH

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null)
	var/hit_percent = (100-blocked)/100
	if((!brute && !burn && !stamina) || hit_percent <= 0)
		return FALSE
	if(owner && (owner.status_flags & GODMODE))
		return FALSE	//godmode

	if(required_status && status != required_status)
		return FALSE
	var/dmg_mlt = CONFIG_GET(number/damage_multiplier) * hit_percent
	brute = round(max(brute * dmg_mlt, 0),DAMAGE_PRECISION)
	burn = round(max(burn * dmg_mlt, 0),DAMAGE_PRECISION)
	stamina = round(max(stamina * dmg_mlt, 0),DAMAGE_PRECISION)
	brute = max(0, brute - brute_reduction)
	burn = max(0, burn - burn_reduction)
	//No stamina scaling.. for now..

	if(!brute && !burn && !stamina)
		return FALSE

	switch(animal_origin)
		if(ALIEN_BODYPART,LARVA_BODYPART) //aliens take double burn //nothing can burn with so much snowflake code around
			burn *= 2

	var/can_inflict = max_damage - get_damage()
	if(can_inflict <= 0)
		return FALSE

	var/total_damage = brute + burn

	if(total_damage > can_inflict)
		brute = round(brute * (can_inflict / total_damage),DAMAGE_PRECISION)
		burn = round(burn * (can_inflict / total_damage),DAMAGE_PRECISION)

	brute_dam += brute
	burn_dam += burn

	//We've dealt the physical damages, if there's room lets apply the stamina damage.
	stamina_dam += round(CLAMP(stamina, 0, max_stamina_damage - stamina_dam), DAMAGE_PRECISION)


	if(owner && updating_health)
		owner.updatehealth()
		if(stamina > DAMAGE_PRECISION)
			owner.update_stamina()
			owner.stam_regen_start_time = world.time + STAMINA_REGEN_BLOCK_TIME
			. = TRUE
	consider_processing()
	update_disabled()
	return update_bodypart_damage_state() || .

//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, required_status, updating_health = TRUE)

	if(required_status && status != required_status)
		return
	brute_dam	= round(max(brute_dam - brute, 0), DAMAGE_PRECISION)
	burn_dam	= round(max(burn_dam - burn, 0), DAMAGE_PRECISION)
	stamina_dam = round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION)
	if(owner && updating_health)
		owner.updatehealth()
	consider_processing()
	update_disabled()
	cremation_progress = min(0, cremation_progress - ((brute_dam + burn_dam)*(100/max_damage)))
	return update_bodypart_damage_state()

//Returns total damage.
/obj/item/bodypart/proc/get_damage(include_stamina = FALSE)
	var/total = brute_dam + burn_dam
	if(include_stamina)
		total = max(total, stamina_dam)
	return total

//Checks disabled status thresholds
/obj/item/bodypart/proc/update_disabled()
	set_disabled(is_disabled())

/obj/item/bodypart/proc/is_disabled()
	if(HAS_TRAIT(src, TRAIT_PARALYSIS))
		return BODYPART_DISABLED_PARALYSIS
	if(can_dismember() && !HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
		. = disabled //inertia, to avoid limbs healing 0.1 damage and being re-enabled
		if((get_damage(TRUE) >= max_damage) || (HAS_TRAIT(owner, TRAIT_EASYLIMBDISABLE) && (get_damage(TRUE) >= (max_damage * 0.6)))) //Easy limb disable disables the limb at 40% health instead of 0%
			return BODYPART_DISABLED_DAMAGE
		if(disabled && (get_damage(TRUE) <= (max_damage * 0.5)))
			return BODYPART_NOT_DISABLED
	else
		return BODYPART_NOT_DISABLED

/obj/item/bodypart/proc/set_disabled(new_disabled)
	if(disabled == new_disabled)
		return
	disabled = new_disabled
	owner.update_health_hud() //update the healthdoll
	owner.update_body()
	owner.update_mobility()
	return TRUE //if there was a change.

//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
	var/tburn	= round( (burn_dam/max_damage)*3, 1 )
	if((tbrute != brutestate) || (tburn != burnstate))
		. = TRUE
		brutestate = tbrute
		burnstate = tburn
		if((draw_state == BODYPART_DRAW_ANDROID) && (tbrute + tburn > 3))
			draw_state = BODYPART_DRAW_ANDROID_SKELETAL
			if(owner)
				to_chat(owner, "<span class='warning'>The synthetic flesh on your damaged [src] sloughs off!</span>")
				owner.update_body()
			else if(original_owner)
				update_limb(TRUE, original_owner)

//Proc for modifying the bodypart's status
/obj/item/bodypart/proc/change_bodypart_status(new_limb_status, heal_limb, change_icon_to_default, aug_style_target, aug_type = AUG_TYPE_ROBOTIC, aug_color_target, aug_decal_target)
	if(new_limb_status)
		status = new_limb_status
	if(owner)
		for(var/obj/item/organ/O in owner.internal)
			if(O.required_bodypart_status && (status != O.required_bodypart_status))
				O.Remove(owner)
				if(owner.drop_location())
					O.forceMove(owner.drop_location())
				else
					QDEL_NULL(src)
		if(!no_update)
			update_sprite_accessories(owner)

	else
		for(var/obj/item/organ/O in contents)
			if(O.required_bodypart_status && (status != O.required_bodypart_status))
				if(drop_location())
					O.forceMove(drop_location())
				else
					QDEL_NULL(src)

	if(is_organic_limb())
		aug_id = ""
		aug_color = ""
		decal_color = ""
		draw_state = BODYPART_DRAW_ORGANIC
		bodypart_status_flags &= ~BODYPART_STATUS_EMAGGED
		light_brute_msg = "bruised"
		medium_brute_msg = "battered"
		heavy_brute_msg = "mangled"
		light_burn_msg = "numb"
		medium_burn_msg = "blistered"
		heavy_burn_msg = "peeling away"
	else
		switch(aug_type)
			if(AUG_TYPE_MONITOR)
				draw_state = BODYPART_DRAW_MONITOR
			if(AUG_TYPE_ANDROID)
				draw_state = BODYPART_DRAW_ANDROID
			else
				draw_state = BODYPART_DRAW_ROBOTIC

		if("legs" in mutant_bodyparts)
			mutant_bodyparts["legs"] = aug_type == AUG_TYPE_DIGITIGRADE ? "Digitigrade Legs" : "None"
			if(mutant_bodyparts["legs"] != "None")
				use_digitigrade = FULL_DIGITIGRADE
			else
				use_digitigrade = NOT_DIGITIGRADE

		light_brute_msg = "marred"
		medium_brute_msg = "dented"
		heavy_brute_msg = "falling apart"
		light_burn_msg = "scorched"
		medium_burn_msg = "charred"
		heavy_burn_msg = "smoldering"
		if(aug_color_target)
			aug_color = aug_color_target
		else if(!aug_color)
			aug_color = AUG_COLOR_DEFAULT
		decal_color = aug_decal_target ? aug_decal_target : ""
		var/datum/sprite_accessory/augmentation/augstyle = aug_style_target ? GLOB.augmentation_styles_list[aug_style_target] : GLOB.augmentation_styles_list[AUG_STYLE_DEFAULT]
		aug_id = augstyle.species

	if(heal_limb)
		burn_dam = 0
		brute_dam = 0
		brutestate = 0
		burnstate = 0
		bodypart_status_flags = initial(bodypart_status_flags)
		update_disabled()

	if(owner)
		owner.updatehealth()
		owner.update_body() //if our head becomes robotic, we remove the lizard horns and human hair.
		owner.update_hair()
		owner.update_damage_overlays()

/obj/item/bodypart/proc/is_organic_limb()
	return status == BODYPART_ORGANIC

//we inform the bodypart of the changes that happened to the owner, or give it the informations from a source mob.
/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/C
	if(source)
		C = source
		if(!original_owner)
			original_owner = source
		if(source == original_owner)
			no_update = FALSE
	else
		C = owner
		if(original_owner && owner != original_owner) //Foreign limb
			no_update = TRUE
		else
			no_update = FALSE
			update_sprite_accessories(C)

	if(HAS_TRAIT(C, TRAIT_HUSK) && is_organic_limb())
		should_draw_husked = TRUE
		dmg_overlay_type = ""
		if(!ishuman(C))
			species_id = "husk" //overrides species_id
			should_draw_gender = FALSE
			should_draw_greyscale = FALSE
			no_update = TRUE
	else if(should_draw_husked && !(HAS_TRAIT(C, TRAIT_HUSK))) //if the limb is husked but doesn't have the trait, husk visuals get removed
		should_draw_husked = FALSE
		no_update = FALSE

	if(no_update)
		return

	if(!animal_origin)
		var/mob/living/carbon/human/H = C
		should_draw_greyscale = FALSE

		var/datum/species/S = H.dna.species
		species_id = S.limbs_id
		species_flags_list = H.dna.species.species_traits
		if((NO_BONES in species_flags_list) || !is_organic_limb())
			bodypart_status_flags &= ~(BODYPART_STATUS_BROKEN_BONES|BODYPART_STATUS_SPLINTED_BONES)
		if(SKIN_TONE in S.species_traits)
			skin_tone = H.skin_tone
			should_draw_greyscale = TRUE
		else
			skin_tone = ""
		body_gender = H.gender
		should_draw_gender = S.sexes

		if((MUTCOLORS in S.species_traits) || (DYNCOLORS in S.species_traits))
			if(S.fixed_mut_color)
				species_color = S.fixed_mut_color
			else
				species_color = H.dna.features["mcolor"]
			should_draw_greyscale = TRUE
		else
			species_color = ""
		if(!dropping_limb && H.dna.check_mutation(HULK) && is_organic_limb())
			mutation_color = "00aa00"
		else
			mutation_color = ""

		if(is_organic_limb())
			dmg_overlay_type = should_draw_husked ? "" : S.damage_overlay_type
			decal_color = S.limb_decal_color ? S.limb_decal_color : ""


		else
			should_draw_greyscale = TRUE
			dmg_overlay_type = "[aug_id]_[draw_state]"

	else if(animal_origin == MONKEY_BODYPART) //currently monkeys are the only non human mob to have damage overlays.
		dmg_overlay_type = animal_origin

	//else if(animal_origin == CYBORG_BODYPART)
		//dmg_overlay_type = "[aug_id]_[draw_state]"
		//should_draw_greyscale = FALSE

	if(dropping_limb || should_draw_husked)
		no_update = TRUE //when attached, the limb won't be affected by the appearance changes of its mob owner.

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	cut_overlays()
	var/list/standing = get_limb_icon(1)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	add_overlay(standing)

//Gives you a proper icon appearance for the dismembered limb
/obj/item/bodypart/proc/get_limb_icon(dropped)
	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", -DAMAGE_LAYER, image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", -DAMAGE_LAYER, image_dir)

	var/image/limb = image(layer = -BODYPARTS_LAYER, dir = image_dir)
	var/image/aux
	. += limb

	if(animal_origin)
		if(is_organic_limb())
			limb.icon = 'icons/mob/animal_parts.dmi'
			if(species_id == "husk")
				limb.icon_state = "[animal_origin]_husk_[body_zone]"
			else
				limb.icon_state = "[animal_origin]_[body_zone]"
		else
			limb.icon = 'icons/mob/augmentation/augments.dmi'
			limb.icon_state = "[animal_origin]_[body_zone]"
		return

	if(should_draw_husked)
		limb.icon = 'icons/mob/human_parts.dmi'
		limb.icon_state = "husk_[body_zone]"
		if(aux_layer)
			aux = image(limb.icon, "husk_[aux_zone]", -aux_layer, image_dir)
			. += aux
		return

	var/icon_gender = (body_gender == FEMALE) ? "f" : "m" //gender of the icon, if applicable
	var/android = (draw_state == BODYPART_DRAW_ANDROID) ? TRUE : FALSE // if we need extra layers to handle android augmentations
	var/image/augmentation
	var/image/augmentation_aux
	var/image/limb_decal
	var/image/aux_decal
	var/draw_color

	if((body_zone != BODY_ZONE_HEAD) && (body_zone != BODY_ZONE_CHEST))
		should_draw_gender = FALSE

	if(should_draw_greyscale)
		if(draw_state >= BODYPART_DRAW_ANDROID_SKELETAL)
			draw_color = sprite_color2hex(aug_color, GLOB.aug_colors_list)
			limb.icon = file("icons/mob/augmentation/[aug_id].dmi")
			limb.icon_state = "[body_zone]_[draw_state]"
			if(aux_zone)
				aux = image(limb.icon, "[aux_zone]_[draw_state]", -aux_layer, image_dir)
				. += aux
		else
			draw_color = mutation_color || species_color || (skin_tone && sprite_color2hex(skin_tone, GLOB.skin_tones_list))
			limb.icon = file("icons/mob/bodyparts/[species_id].dmi")
			limb.icon_state = should_draw_gender ? "[body_zone]_[icon_gender]" : "[body_zone]"
			if(aux_zone)
				aux = image(limb.icon, "[aux_zone]", -aux_layer, image_dir)
				. += aux
		limb.color = "#[draw_color]"
		if(aux)
			aux.color = aux_color ? "#[aux_color]" : "#[draw_color]"
	else
		limb.icon = 'icons/mob/human_parts.dmi'
		limb.icon_state = should_draw_gender ? "[species_id]_[body_zone]_[icon_gender]" : "[species_id]_[body_zone]"

	if(use_digitigrade)
		limb.icon_state = "digitigrade_[use_digitigrade]_[limb.icon_state]"

	if(android)
		augmentation = image(layer = -BODYPARTS_LAYER, dir = image_dir)
		augmentation.icon = file("icons/mob/augmentation/[aug_id].dmi")
		if((body_zone == BODY_ZONE_HEAD) || (body_zone == BODY_ZONE_CHEST))
			augmentation.icon_state = should_draw_gender ? "[body_zone]_[icon_gender]_[draw_state]" : "[body_zone]_m_[draw_state]"
		else
			augmentation.icon_state = "[body_zone]_[draw_state]"
		augmentation.color = "#" + sprite_color2hex(aug_color, GLOB.aug_colors_list)
		. += augmentation
		if(aux_zone)
			augmentation_aux = image(augmentation.icon, "[aux_zone]_[draw_state]", -aux_layer, image_dir)
			augmentation_aux.color = "#" + sprite_color2hex(aug_color, GLOB.aug_colors_list)
			. += augmentation_aux

	if(decal_color)
		var/image/target_image = android ? augmentation : limb
		limb_decal = image(target_image.icon, icon_state = "[target_image.icon_state]_dcolor", layer = -BODYPARTS_LAYER, dir = image_dir)
		limb_decal.color = "#[decal_color]"
		. += limb_decal
		if(aux_zone)
			target_image = android ? augmentation_aux : aux
			aux_decal = image(target_image.icon, icon_state = "[target_image.icon_state]_dcolor", layer = -aux_layer, dir = image_dir)
			aux_decal.color = limb_decal.color
			. += aux_decal



//pulls the correct mutant bodyparts from a mob's features
/obj/item/bodypart/proc/update_sprite_accessories(mob/living/carbon/source)
	if(!source || !ishuman(source) || no_update)
		return
	for(var/feature in source.dna.features)
		if(feature in mutant_bodyparts)
			if(feature == "legs")
				if((get_augtype() == AUG_TYPE_DIGITIGRADE) || (DIGITIGRADE in source.dna.species.species_traits))
					mutant_bodyparts["legs"] = "Digitgrade Legs"
				else
					mutant_bodyparts["legs"] = "None"
				continue
			var/feature_to_add = (draw_state >= BODYPART_DRAW_ROBOTIC) ? mutant_bodyparts[feature] : source.dna.features[feature]
			feature_to_add = check_feature_by_index(feature_to_add, source.dna.species.features_id, feature, draw_state, TRUE)
			mutant_bodyparts[feature] = feature_to_add

/obj/item/bodypart/proc/get_sprite_accessory_list(mob/living/carbon/human/H)
	. = list()
	if(!istype(H))
		return
	for(var/feature in mutant_bodyparts)
		if((mutant_bodyparts[feature] != "None") && draw_state != (BODYPART_DRAW_ANDROID_SKELETAL) && H.dna.species.should_display_feature(H, feature))
			.[feature] = mutant_bodyparts[feature]

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	drop_organs()
	qdel(src)

/obj/item/bodypart/proc/get_augtype()
	if(is_organic_limb())
		return
	switch(draw_state)
		if(BODYPART_DRAW_ANDROID to BODYPART_DRAW_ANDROID_SKELETAL)
			return AUG_TYPE_ANDROID
		if(BODYPART_DRAW_MONITOR)
			return AUG_TYPE_MONITOR
		else
			return use_digitigrade ? AUG_TYPE_DIGITIGRADE : AUG_TYPE_ROBOTIC


/obj/item/bodypart/chest
	name = BODY_ZONE_CHEST
	desc = "It's impolite to stare at a person's chest."
	icon_state = "default_human_chest"
	max_damage = 200
	body_zone = BODY_ZONE_CHEST
	body_part = CHEST
	status = BODYPART_ORGANIC
	px_x = 0
	px_y = 0
	stam_damage_coeff = 1
	max_stamina_damage = 120
	var/obj/item/cavity_item
	mutant_bodyparts = list("body_markings" = "None")

/obj/item/bodypart/chest/can_dismember(obj/item/I)
	if(!((owner.stat == DEAD) || owner.InFullCritical()))
		return FALSE
	return ..()

/obj/item/bodypart/chest/Destroy()
	QDEL_NULL(cavity_item)
	return ..()

/obj/item/bodypart/chest/drop_organs(mob/user, violent_removal)
	if(cavity_item)
		cavity_item.forceMove(drop_location())
		cavity_item = null
	..()

/obj/item/bodypart/chest/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_chest"
	animal_origin = MONKEY_BODYPART

/obj/item/bodypart/chest/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_chest"
	dismemberable = 0
	max_damage = 500
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/chest/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "larva_chest"
	dismemberable = 0
	max_damage = 50
	animal_origin = LARVA_BODYPART

/obj/item/bodypart/l_arm
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	attack_verb = list("slapped", "punched")
	max_damage = 50
	max_stamina_damage = 50
	body_zone = BODY_ZONE_L_ARM
	status = BODYPART_ORGANIC
	body_part = ARM_LEFT
	aux_zone = BODY_ZONE_PRECISE_L_HAND
	aux_layer = HANDS_PART_LAYER
	body_damage_coeff = 0.75
	held_index = 1
	px_x = -6
	px_y = 0

/obj/item/bodypart/l_arm/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
		return BODYPART_DISABLED_PARALYSIS
	return ..()

/obj/item/bodypart/l_arm/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(disabled == BODYPART_DISABLED_DAMAGE)
		if(owner.stat < UNCONSCIOUS)
			owner.emote("scream")
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>Your [name] is too damaged to function!</span>")
		if(held_index)
			owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(disabled == BODYPART_DISABLED_PARALYSIS)
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>You can't feel your [name]!</span>")
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	if(owner.hud_used)
		var/obj/screen/inventory/hand/L = owner.hud_used.hand_slots["[held_index]"]
		if(L)
			L.update_icon()

/obj/item/bodypart/l_arm/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_arm"
	animal_origin = MONKEY_BODYPART
	px_x = -5
	px_y = -3

/obj/item/bodypart/l_arm/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_l_arm"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/l_arm/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/r_arm
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	icon_state = "default_human_r_arm"
	attack_verb = list("slapped", "punched")
	max_damage = 50
	body_zone = BODY_ZONE_R_ARM
	status = BODYPART_ORGANIC
	body_part = ARM_RIGHT
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	aux_layer = HANDS_PART_LAYER
	body_damage_coeff = 0.75
	held_index = 2
	px_x = 6
	px_y = 0
	max_stamina_damage = 50

/obj/item/bodypart/r_arm/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_ARM))
		return BODYPART_DISABLED_PARALYSIS
	return ..()

/obj/item/bodypart/r_arm/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(disabled == BODYPART_DISABLED_DAMAGE)
		if(owner.stat < UNCONSCIOUS)
			owner.emote("scream")
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>Your [name] is too damaged to function!</span>")
		if(held_index)
			owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(disabled == BODYPART_DISABLED_PARALYSIS)
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>You can't feel your [name]!</span>")
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	if(owner.hud_used)
		var/obj/screen/inventory/hand/R = owner.hud_used.hand_slots["[held_index]"]
		if(R)
			R.update_icon()

/obj/item/bodypart/r_arm/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_arm"
	animal_origin = MONKEY_BODYPART
	px_x = 5
	px_y = -3

/obj/item/bodypart/r_arm/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_r_arm"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/r_arm/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/l_leg
	name = "left leg"
	desc = "Some athletes prefer to tie their left shoelaces first for good \
		luck. In this instance, it probably would not have helped."
	icon_state = "default_human_l_leg"
	attack_verb = list("kicked", "stomped")
	max_damage = 50
	body_zone = BODY_ZONE_L_LEG
	status = BODYPART_ORGANIC
	body_part = LEG_LEFT
	mutant_bodyparts = list("legs" = "None")
	aux_zone = BODY_ZONE_PRECISE_L_FOOT
	body_damage_coeff = 0.75
	px_x = -2
	px_y = 12
	max_stamina_damage = 50

/obj/item/bodypart/l_leg/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_LEG))
		return BODYPART_DISABLED_PARALYSIS
	return ..()

/obj/item/bodypart/l_leg/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(disabled == BODYPART_DISABLED_DAMAGE)
		if(owner.stat < UNCONSCIOUS)
			owner.emote("scream")
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>Your [name] is too damaged to function!</span>")
	else if(disabled == BODYPART_DISABLED_PARALYSIS)
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>You can't feel your [name]!</span>")

/obj/item/bodypart/l_leg/digitigrade
	name = "left digitigrade leg"
	use_digitigrade = FULL_DIGITIGRADE

/obj/item/bodypart/l_leg/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_leg"
	animal_origin = MONKEY_BODYPART
	px_y = 4

/obj/item/bodypart/l_leg/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_l_leg"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/l_leg/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/r_leg
	name = "right leg"
	desc = "You put your right leg in, your right leg out. In, out, in, out, \
		shake it all about. And apparently then it detaches.\n\
		The hokey pokey has certainly changed a lot since space colonisation."
	// alternative spellings of 'pokey' are availible
	icon_state = "default_human_r_leg"
	attack_verb = list("kicked", "stomped")
	max_damage = 50
	body_zone = BODY_ZONE_R_LEG
	status = BODYPART_ORGANIC
	body_part = LEG_RIGHT
	mutant_bodyparts = list("legs" = "None")
	aux_zone = BODY_ZONE_PRECISE_R_FOOT
	body_damage_coeff = 0.75
	px_x = 2
	px_y = 12
	max_stamina_damage = 50

/obj/item/bodypart/r_leg/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_LEG))
		return BODYPART_DISABLED_PARALYSIS
	return ..()

/obj/item/bodypart/r_leg/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(disabled == BODYPART_DISABLED_DAMAGE)
		if(owner.stat < UNCONSCIOUS)
			owner.emote("scream")
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>Your [name] is too damaged to function!</span>")
	else if(disabled == BODYPART_DISABLED_PARALYSIS)
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>You can't feel your [name]!</span>")

/obj/item/bodypart/r_leg/digitigrade
	name = "right digitigrade leg"
	use_digitigrade = FULL_DIGITIGRADE

/obj/item/bodypart/r_leg/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_leg"
	animal_origin = MONKEY_BODYPART
	px_y = 4

/obj/item/bodypart/r_leg/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_r_leg"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/r_leg/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART
