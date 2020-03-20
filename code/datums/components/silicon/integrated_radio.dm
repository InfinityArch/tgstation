// the ui and action hooks for borg integrated radios

/datum/component/integrated_radio
	var/obj/item/radio/linked_radio
	var/mob/living/owner
	var/obj/screen/integrated_radio/screen_obj

/datum/component/integrated_radio/Initialize(obj/item/radio/_radio)
	owner = parent
	if(!istype(owner))
		return COMPONENT_INCOMPATIBLE
	linked_radio = _radio
	if(owner.hud_used)
		modify_hud()
	RegisterSignal(owner, COMSIG_MOB_HUD_CREATED, .proc/modify_hud)

/datum/component/integrated_radio/Destroy()
	unmodify_hud()
	return ..()

/datum/component/integrated_radio/proc/modify_hud()
	var/datum/hud/hud = owner.hud_used
	screen_obj = new
	hud.infodisplay += screen_obj
	RegisterSignal(hud, COMSIG_PARENT_QDELETING, .proc/unmodify_hud)
	RegisterSignal(screen_obj, COMSIG_CLICK, .proc/hud_click)

/datum/component/integrated_radio/proc/unmodify_hud()
	if(!screen_obj)
		return
	var/datum/hud/hud = owner.hud_used
	if(hud && hud.infodisplay)
		hud.infodisplay -= screen_obj
	QDEL_NULL(screen_obj)

/datum/component/integrated_radio/proc/hud_click()
	linked_radio.ui_interact(owner, "main", null, FALSE, null, GLOB.deep_inventory_state)

/obj/screen/integrated_radio
	name = "radio"
	icon_state = "radio"
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_integrated_radio


