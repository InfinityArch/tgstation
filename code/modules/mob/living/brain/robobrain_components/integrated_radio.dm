// integrated radio module
/obj/item/robobrain_component/integrated_radio
	name = "integrated radio"
	icon_state = "integrated_radio"
	id = "radio"
	var/obj/item/radio/linked_radio = /obj/item/radio

/obj/item/robobrain_component/integrated_radio/Initialize()
	. = ..()
	if(linked_radio)
		linked_radio = new()
		linked_radio.forceMove(src)
		linked_radio.canhear_range = 0

/obj/item/robobrain_component/integrated_radio/Destroy()
	if(linked_radio)
		QDEL_NULL(linked_radio)
	. = ..()

/obj/item/robobrain_component/integrated_radio/transfer_to_owner(silent = FALSE)
	. = ..()
	var/mob/living/brain_owner = get_brain_owner()
	if(brain_owner && linked_radio)
		brain_owner.AddComponent(/datum/component/integrated_radio, linked_radio)

/obj/item/robobrain_component/integrated_radio/transfer_to_brain()
	var/mob/living/brain_owner = get_brain_owner()
	if(brain_owner)
		var/datum/component/integrated_radio/I = brain_owner.GetComponent(/datum/component/integrated_radio)
		if(I)
			qdel(I)
	. = ..()

/obj/item/robobrain_component/integrated_radio/on_uninstall(mob/living/user)
	var/mob/living/brain_owner = get_brain_owner()
	if(brain_owner)
		var/datum/component/integrated_radio/I = brain_owner.GetComponent(/datum/component/integrated_radio)
		if(I)
			qdel(I)
	. = ..()

