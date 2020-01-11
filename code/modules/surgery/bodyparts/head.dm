/obj/item/bodypart/head
	name = BODY_ZONE_HEAD
	desc = "Didn't make sense not to live for fun, your brain gets smart but your head gets dumb."
	icon = 'icons/mob/human_parts.dmi'
	icon_state = "default_human_head"
	max_damage = 200
	body_zone = BODY_ZONE_HEAD
	status = BODYPART_ORGANIC
	body_part = HEAD
	w_class = WEIGHT_CLASS_BULKY //Quite a hefty load
	slowdown = 1 //Balancing measure
	throw_range = 2 //No head bowling
	px_x = 0
	px_y = -8
	stam_damage_coeff = 1
	max_stamina_damage = 100

	var/mob/living/brain/brainmob = null //The current occupant.
	var/obj/item/organ/brain/brain = null //The brain organ
	var/obj/item/organ/eyes/eyes
	var/obj/item/organ/ears/ears
	var/obj/item/organ/tongue/tongue

	//Limb appearance info:
	var/real_name = "" //Replacement name
	//Hair colour and style
	var/hair_color = "000"
	var/hairstyle = "Bald"
	var/hair_alpha = 255
	//Facial hair colour and style
	var/facial_hair_color = "000"
	var/facial_hairstyle = "Shaved"
	//Eye Colouring
	var/eye_optics = ""
	var/monitor_state = ""

	var/lip_style = null
	var/lip_color = "white"

	//mutant bodyparts
	var/horns = ""
	var/facial_markings = ""
	var/snout = ""
	var/frills = ""

/obj/item/bodypart/head/Destroy()
	QDEL_NULL(brainmob) //order is sensitive, see warning in handle_atom_del() below
	QDEL_NULL(brain)
	QDEL_NULL(eyes)
	QDEL_NULL(ears)
	QDEL_NULL(tongue)
	return ..()

/obj/item/bodypart/head/handle_atom_del(atom/A)
	if(A == brain)
		brain = null
		update_icon_dropped()
		if(!QDELETED(brainmob)) //this shouldn't happen without badminnery.
			message_admins("Brainmob: ([ADMIN_LOOKUPFLW(brainmob)]) was left stranded in [src] at [ADMIN_VERBOSEJMP(src)] without a brain!")
			log_game("Brainmob: ([key_name(brainmob)]) was left stranded in [src] at [AREACOORD(src)] without a brain!")
	if(A == brainmob)
		brainmob = null
	if(A == eyes)
		eyes = null
		update_icon_dropped()
	if(A == ears)
		ears = null
	if(A == tongue)
		tongue = null
	return ..()

/obj/item/bodypart/head/examine(mob/user)
	. = ..()
	if(is_organic_limb() && !TORSO_BRAIN in species_flags_list)
		if(!brain)
			. += "<span class='info'>The brain has been removed from [src].</span>"
		else if(brain.suicided || brainmob?.suiciding)
			. += "<span class='info'>There's a pretty dumb expression on [real_name]'s face; they must have really hated life. There is no hope of recovery.</span>"
		else if(brain.brain_death || brainmob?.health <= HEALTH_THRESHOLD_DEAD)
			. += "<span class='info'>It seems to be leaking some kind of... clear fluid? The brain inside must be in pretty bad shape... There is no coming back from that.</span>"
		else if(brainmob)
			if(brainmob.get_ghost(FALSE, TRUE))
				. += "<span class='info'>Its muscles are still twitching slightly... It still seems to have a bit of life left to it.</span>"
			else
				. += "<span class='info'>It seems seems particularly lifeless. Perhaps there'll be a chance for them later.</span>"
		else if(brain?.decoy_override)
			. += "<span class='info'>It seems particularly lifeless. Perhaps there'll be a chance for them later.</span>"
		else
			. += "<span class='info'>It seems completely devoid of life.</span>"
	if(!eyes)
		. += "<span class='info'>[real_name]'s eyes appear to have been removed.</span>"

	if(!ears)
		. += "<span class='info'>[real_name]'s ears appear to have been removed.</span>"

	if(!tongue)
		. += "<span class='info'>[real_name]'s tongue appears to have been removed.</span>"

/obj/item/bodypart/head/can_dismember(obj/item/I)
	if(!((owner.stat == DEAD) || TORSO_BRAIN in species_flags_list || owner.InFullCritical()))
		return FALSE
	return ..()

/obj/item/bodypart/head/drop_organs(mob/user, violent_removal)
	var/turf/T = get_turf(src)
	if(is_organic_limb())
		playsound(T, 'sound/misc/splort.ogg', 50, TRUE, -1)
	for(var/obj/item/I in src)
		if(I == brain)
			if(user)
				user.visible_message("<span class='warning'>[user] saws [src] open and pulls out a brain!</span>", "<span class='notice'>You saw [src] open and pull out a brain.</span>")
			if(brainmob)
				brainmob.container = null
				brainmob.forceMove(brain)
				brain.brainmob = brainmob
				brainmob = null
			if(violent_removal && prob(rand(80, 100))) //ghetto surgery can damage the brain.
				to_chat(user, "<span class='warning'>[brain] was damaged in the process!</span>")
				brain.setOrganDamage(brain.maxHealth)
			brain.forceMove(T)
			brain = null
			update_icon_dropped()
		else
			if(istype(I, /obj/item/reagent_containers/pill))
				for(var/datum/action/item_action/hands_free/activate_pill/AP in I.actions)
					qdel(AP)
			I.forceMove(T)
	eyes = null
	ears = null
	tongue = null

/obj/item/bodypart/head/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/C
	if(source)
		C = source
	else
		C = owner

	real_name = C.real_name
	if(HAS_TRAIT(C, TRAIT_HUSK))
		real_name = "Unknown"
		hairstyle = "Bald"
		facial_hairstyle = "Shaved"
		lip_style = null

	else if(!animal_origin)
		var/mob/living/carbon/human/H = C
		var/datum/species/S = H.dna.species

		//Facial hair
		if(H.facial_hairstyle && (FACEHAIR in S.species_traits))
			facial_hairstyle = H.facial_hairstyle
			if(S.hair_color)
				if(S.hair_color == "mutcolor")
					facial_hair_color = H.dna.features["mcolor"]
				else if(S.hair_color == "skin_tone")
					facial_hair_color = "#" + sprite_color2hex(H.skin_tone, GLOB.skin_tones_list)
				else
					facial_hair_color = S.hair_color
			else
				facial_hair_color = H.facial_hair_color
			hair_alpha = S.hair_alpha
		else
			facial_hairstyle = "Shaved"
			facial_hair_color = "000"
			hair_alpha = 255
		//Hair
		if(H.hairstyle && (HAIR in S.species_traits))
			hairstyle = H.hairstyle
			if(S.hair_color)
				if(S.hair_color == "mutcolor")
					hair_color = H.dna.features["mcolor"]
				else if(S.hair_color == "skin_tone")
					hair_color = "#" + sprite_color2hex(H.skin_tone, GLOB.skin_tones_list)
				else
					hair_color = S.hair_color
			else
				hair_color = H.hair_color
			hair_alpha = S.hair_alpha
		else
			hairstyle = "Bald"
			hair_color = "000"
			hair_alpha = initial(hair_alpha)
		// lipstick
		if(H.lip_style && (LIPS in S.species_traits))
			lip_style = H.lip_style
			lip_color = H.lip_color
		else
			lip_style = null
			lip_color = "FFFFFF"
	..()

/obj/item/bodypart/head/change_bodypart_status(new_limb_status, heal_limb, change_icon_to_default, aug_style_target, aug_type = AUG_TYPE_ROBOTIC, aug_color_target)
	. = ..()
	var/datum/action/item_action/adjust_monitor_state/MS
	if(actions && actions.len)
		MS = actions.Find(/datum/action/item_action/adjust_monitor_state)
	var/augmentation_type = get_augtype()
	if(!augmentation_type) //if its an organic limb
		eye_optics = ""
		monitor_state = ""
		if(MS)
			qdel(MS)
		return
	else if(augmentation_type !=  AUG_TYPE_MONITOR)
		monitor_state = ""
		if(MS)
			qdel(MS)
	else
		if(!MS)
			MS = new /datum/action/item_action/adjust_monitor_state(src)
		if(owner)
			MS.Grant(owner)

	var/datum/sprite_accessory/augmentation/augmentation_style = GLOB.augmentation_styles_list[aug_id2augstyle(aug_id)]
	if(LAZYLEN(augmentation_style.optics_types) && augmentation_type in augmentation_style.optics_types)
		eye_optics = "[aug_id]_[augmentation_type]"
	else
		eye_optics = ""

/obj/item/bodypart/head/update_icon_dropped()
	var/list/standing = get_limb_icon(1)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	add_overlay(standing)

/obj/item/bodypart/head/get_limb_icon(dropped)
	cut_overlays()
	. = ..()
	if(dropped) //certain overlays only appear when the limb is being detached from its owner.

		if(draw_organic_features) //having a robotic head hides certain features.
			//facial hair
			if(facial_hairstyle)
				var/datum/sprite_accessory/S = GLOB.facial_hairstyles_list[facial_hairstyle]
				if(S)
					var/image/facial_overlay = image(S.icon, "[S.icon_state]", -HAIR_LAYER, SOUTH)
					facial_overlay.color = "#" + facial_hair_color
					facial_overlay.alpha = hair_alpha
					. += facial_overlay

			//Applies the debrained overlay if there is no brain
			if(!brain && !TORSO_BRAIN in species_flags_list && is_organic_limb())
				var/image/debrain_overlay = image(layer = -HAIR_LAYER, dir = SOUTH)
				if(animal_origin == ALIEN_BODYPART)
					debrain_overlay.icon = 'icons/mob/animal_parts.dmi'
					debrain_overlay.icon_state = "debrained_alien"
				else if(animal_origin == LARVA_BODYPART)
					debrain_overlay.icon = 'icons/mob/animal_parts.dmi'
					debrain_overlay.icon_state = "debrained_larva"
				else if(!(NOBLOOD in species_flags_list))
					debrain_overlay.icon = 'icons/mob/human_face.dmi'
					debrain_overlay.icon_state = "debrained"
				. += debrain_overlay
			else
				var/datum/sprite_accessory/S2 = GLOB.hairstyles_list[hairstyle]
				if(S2)
					var/image/hair_overlay = image(S2.icon, "[S2.icon_state]", -HAIR_LAYER, SOUTH)
					hair_overlay.color = "#" + hair_color
					hair_overlay.alpha = hair_alpha
					. += hair_overlay


			// lipstick
			if(lip_style)
				var/image/lips_overlay = image('icons/mob/sprite_accessories/lips.dmi', "[species_id]_lips_[lip_style]", -COSMETICS_LAYER, SOUTH)
				lips_overlay.color = "#" + lip_color
				. += lips_overlay

		// eyes
		var/image/eyes_overlay
		if(eye_optics)
			message_admins("here's why this shit is triggering: [eye_optics]")
			var/datum/sprite_accessory/optics/O = GLOB.augmentation_optics_list[eye_optics]
			if(O)//InfinityArch: TODO- actually make optics datums for the various robotic heads with alternate eye styles
				eyes_overlay = image('icons/mob/augmentation/aug_optics.dmi', O.icon_state, -BODY_LAYER, SOUTH)
				eyes_overlay.color = get_augtype() == AUG_TYPE_MONITOR ? AUG_OPTICS_DEFAULT_COLOR : eyes.eye_color
				. += eyes_overlay
		else if(eyes)
			eyes_overlay = image('icons/mob/human_face.dmi', eyes.eye_icon_state, -BODY_LAYER, SOUTH)
			if(eyes.eye_color)
				eyes_overlay.color = "#" + eyes.eye_color
			. += eyes_overlay
		else if(is_organic_limb())
			eyes_overlay = image('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER, SOUTH)
			. += eyes_overlay
		else
			eyes_overlay = image('icons/mob/human_face.dmi', "eyes_missing_robotic", -BODY_LAYER, SOUTH)
			. += eyes_overlay

/obj/item/bodypart/head/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_head"
	animal_origin = MONKEY_BODYPART

/obj/item/bodypart/head/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_head"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 500
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/head/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/head/larva
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "larva_head"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 50
	animal_origin = LARVA_BODYPART
