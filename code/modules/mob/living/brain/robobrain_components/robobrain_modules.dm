///////////////////////
///ROBOBRAIN MODULES///
///////////////////////

/obj/item/robobrain_component
	name = "robot brain module"
	icon_state = "mainboard"
	icon = 'icons/obj/module.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/organ/brain/silicon/brain
	var/id = ""
	var/no_removal = FALSE //whether this module can be removed from a robobrain
	var/stealth_module = FALSE //whether this module will be hidden to normal scans

/obj/item/robobrain_component/proc/get_brain_owner()
	if(!brain)
		return
	if(brain.owner)
		return brain.owner
	if(brain.brainmob)
		return brain.brainmob

/obj/item/robobrain_component/proc/install(obj/item/organ/brain/silicon/S, mob/living/user)
	if(!S) //sanity check is needed for surgery installation
		return
	message_admins("HEEEEY")
	if(user)
		if(!(user.transferItemToLoc(src, S)))
			return
		playsound(user, 'sound/items/deconstruct.ogg', 50, TRUE)
	else
		forceMove(S)
	brain = S
	brain.installed_components |= src
	on_install(user)


/obj/item/robobrain_component/proc/uninstall(mob/living/user, silent = FALSE)
	if(user)
		user.put_in_hands(src)
		playsound(user, 'sound/items/crowbar.ogg', 50, TRUE)
	else if(brain.owner)
		forceMove(brain.owner.drop_location())
	else
		forceMove(brain.drop_location())
	on_uninstall(user, silent)

//moves the component to the carbon mob this brain has
//been installed in if one is present, and returns that
//mob for downstream use. This hack is required for the
// objects to be interactable, since internal organs actually
//live in nullspace while "inside" of a mob...for some reason
/obj/item/robobrain_component/proc/transfer_to_owner(silent = FALSE)
	if(brain.owner)
		forceMove(brain.owner)
		return brain.owner
	if(brain.brainmob)
		forceMove(brain)
		return brain

/obj/item/robobrain_component/proc/transfer_to_brain()
	forceMove(brain)

/obj/item/robobrain_component/proc/on_install(mob/living/user)
	if(user)
		user.visible_message("<span class='notice'>[user] installs \a [src] into [brain].</span>",
				"<span class='notice'>You install [src] into [brain].</span>")
	if(brain.owner || brain.brainmob)
		transfer_to_owner()

/obj/item/robobrain_component/proc/on_uninstall(mob/living/user, silent = FALSE)
	if(user && !silent)
		user.visible_message("<span class='notice'>[user] removes \a [src] from [brain].</span>",
				"<span class='notice'>You remove [src] from [brain].</span>")
	brain.installed_components -= src
	brain = null

/obj/item/robobrain_component/Destroy()
	on_uninstall()
	. = ..()
