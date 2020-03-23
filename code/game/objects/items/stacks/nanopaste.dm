//nanopaste
/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanopaste"
	icon_state = "nanopaste"
	desc = "A slurry of advanced nanites capable of repairing severe damage to synthetic lifeforms."
	gender = PLURAL
	icon = 'icons/obj/stack_objects.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount = 20
	max_amount = 20
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	max_integrity = 40
	custom_materials = list(/datum/material/iron = 500, /datum/material/glass = 2500)
	novariants = FALSE
	item_flags = NOBLUDGEON
	tool_behaviour = TOOL_NANOPASTE

/obj/item/stack/nanopaste/attack(mob/living/carbon/human/C, mob/user)
	if(!istype(C))
		return ..()

	var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
	if(affecting && !affecting.is_organic_limb())
		if(!affecting.get_damage())
			to_chat(user, "<span class='notice'>[user = C ? "your" : "[C]'s"] [affecting.name] is already in good condition.</span>")
			return
		var/repair_timer = 25
		if(user == C)
			repair_timer *= 2
		user.visible_message("<span class='notice'>[user] starts to apply nanopaste to [C]'s [affecting.name].</span>", "<span class='notice'>You start applying nanopaste to [C == user ? "your" : "[C]'s"] [affecting.name].</span>")
		if(!do_mob(user, C, repair_timer))
			return
		if(item_heal_robotic(C, user, 30, 30))
			use(1)
		return
	else
		return ..()
