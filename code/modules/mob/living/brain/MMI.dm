#define COVER_LOCKED	0
#define COVER_UNLOCKED	1
#define COVER_EMAGGED	2


/obj/item/mmi
	name = "\improper Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_off"
	w_class = WEIGHT_CLASS_NORMAL
	var/braintype = "Cyborg"
	var/obj/item/radio/radio = null //Let's give it a radio.
	var/mob/living/brain/brainmob = null //The current occupant.
	var/mob/living/silicon/robot = null //Appears unused.
	var/obj/mecha = null //This does not appear to be used outside of reference in mecha.dm.
	var/obj/item/organ/brain/brain = null //The actual brain
	//var/obj/item/organ/silicon/law_module/law_module = null //the law module
	var/datum/ai_laws/laws = new()
	var/force_replace_ai_name = FALSE
	var/overrides_aicore_laws = FALSE // Whether the laws on the MMI, if any, override possible pre-existing laws loaded on the AI core.

/obj/item/mmi/update_icon_state()
	if(!brain)
		icon_state = "mmi_off"
	else if(istype(brain, /obj/item/organ/brain/alien))
		icon_state = "mmi_brain_alien"
	else
		icon_state = "mmi_brain"

/obj/item/mmi/update_overlays()
	. = ..()
	. += add_mmi_overlay()

/obj/item/mmi/proc/add_mmi_overlay()
	if(brainmob && brainmob.stat != DEAD)
		. += "mmi_alive"
	else if(brain)
		. += "mmi_dead"

/obj/item/mmi/Initialize()
	. = ..()
	radio = new(src) //Spawns a radio inside the MMI.
	radio.broadcasting = FALSE //researching radio mmis turned the robofabs into radios because this didnt start as 0.
	laws.set_laws_config()

/obj/item/mmi/attackby(obj/item/O, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(O, /obj/item/organ/brain)) //Time to stick a brain in it --NEO
		var/obj/item/organ/brain/newbrain = O
		if(brain)
			to_chat(user, "<span class='warning'>There's already a brain in the MMI!</span>")
			return
		if(!newbrain.brainmob)
			to_chat(user, "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain!</span>")
			return

		if(!user.transferItemToLoc(O, src))
			return
		var/mob/living/brain/B = newbrain.brainmob
		if(!B.key)
			B.notify_ghost_cloning("Someone has put your brain in a MMI!", source = src)
		user.visible_message("<span class='notice'>[user] sticks \a [newbrain] into [src].</span>", "<span class='notice'>[src]'s indicator light turn on as you insert [newbrain].</span>")

		brainmob = newbrain.brainmob
		newbrain.brainmob = null
		brainmob.forceMove(src)
		brainmob.container = src
		var/fubar_brain = newbrain.suicided || brainmob.suiciding //brain is from a suicider
		if(!fubar_brain && !(newbrain.organ_flags & ORGAN_FAILING)) // the brain organ hasn't been beaten to death, nor was from a suicider.
			brainmob.set_stat(CONSCIOUS) //we manually revive the brain mob
			GLOB.dead_mob_list -= brainmob
			GLOB.alive_mob_list += brainmob
		else if(!fubar_brain && newbrain.organ_flags & ORGAN_FAILING) // the brain is damaged, but not from a suicider
			to_chat(user, "<span class='warning'>[src]'s indicator light turns yellow and its brain integrity alarm beeps softly. Perhaps you should check [newbrain] for damage.</span>")
			playsound(src, "sound/machines/synth_no.ogg", 5, TRUE)
		else
			to_chat(user, "<span class='warning'>[src]'s indicator light turns red and its brainwave activity alarm beeps softly. Perhaps you should check [newbrain] again.</span>")
			playsound(src, "sound/weapons/smg_empty_alarm.ogg", 5, TRUE)

		brainmob.reset_perspective()
		brain = newbrain
		brain.organ_flags |= ORGAN_FROZEN

		name = "[initial(name)]: [brainmob.real_name]"
		update_icon()
		if(istype(brain, /obj/item/organ/brain/alien))
			braintype = "Xenoborg" //HISS....Beep.
		else
			braintype = "Cyborg"

		SSblackbox.record_feedback("amount", "mmis_filled", 1)

		log_game("[key_name(user)] has put the brain of [key_name(brainmob)] into an MMI at [AREACOORD(src)]")

	else if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
	else
		return ..()

/obj/item/mmi/attack_self(mob/user)
	if(!brain)
		radio.on = !radio.on
		to_chat(user, "<span class='notice'>You toggle [src]'s radio system [radio.on==1 ? "on" : "off"].</span>")
	else
		eject_brain(user)
		update_icon()
		name = initial(name)
		to_chat(user, "<span class='notice'>You unlock and upend [src], spilling the brain onto the floor.</span>")

/obj/item/mmi/proc/eject_brain(mob/user)
	brainmob.container = null //Reset brainmob mmi var.
	brainmob.forceMove(brain) //Throw mob into brain.
	brainmob.set_stat(DEAD)
	brainmob.emp_damage = 0
	brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision
	GLOB.alive_mob_list -= brainmob //Get outta here
	GLOB.dead_mob_list |= brainmob
	brain.brainmob = brainmob //Set the brain to use the brainmob
	log_game("[key_name(user)] has ejected the brain of [key_name(brainmob)] from an MMI at [AREACOORD(src)]")
	brainmob = null //Set mmi brainmob var to null
	if(user)
		user.put_in_hands(brain) //puts brain in the user's hand or otherwise drops it on the user's turf
	else
		brain.forceMove(get_turf(src))
	brain.organ_flags &= ~ORGAN_FROZEN
	brain = null //No more brain in here

/obj/item/mmi/proc/transfer_identity(mob/living/L) //Same deal as the regular brain proc. Used for human-->robot people.
	if(!brainmob)
		brainmob = new(src)
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	brainmob.container = src

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/brain/newbrain = H.getorgan(/obj/item/organ/brain)
		newbrain.forceMove(src)
		brain = newbrain
	else if(!brain)
		brain = new(src)
		brain.name = "[L.real_name]'s brain"
	brain.organ_flags |= ORGAN_FROZEN

	name = "[initial(name)]: [brainmob.real_name]"
	update_icon()
	if(istype(brain, /obj/item/organ/brain/alien))
		braintype = "Xenoborg" //HISS....Beep.
	else
		braintype = "Cyborg"

/obj/item/mmi/proc/replacement_ai_name()
	return brainmob.name

/obj/item/mmi/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = FALSE

	if(brainmob.stat)
		to_chat(brainmob, "<span class='warning'>Can't do that while incapacitated or dead!</span>")
	if(!radio.on)
		to_chat(brainmob, "<span class='warning'>Your radio is disabled!</span>")
		return

	radio.listening = !radio.listening
	to_chat(brainmob, "<span class='notice'>Radio is [radio.listening ? "now" : "no longer"] receiving broadcast.</span>")

/obj/item/mmi/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!brainmob || iscyborg(loc))
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(20,30), 30)
			if(2)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(10,20), 30)
			if(3)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(0,10), 30)
		brainmob.emote("alarm")

/obj/item/mmi/Destroy()
	if(iscyborg(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	if(brain)
		qdel(brain)
		brain = null
	if(mecha)
		mecha = null
	if(radio)
		qdel(radio)
		radio = null
	return ..()

/obj/item/mmi/deconstruct(disassembled = TRUE)
	if(brain)
		eject_brain()
	qdel(src)

/obj/item/mmi/examine(mob/user)
	. = ..()
	if(radio)
		. += "<span class='notice'>There is a switch to toggle the radio system [radio.on ? "off" : "on"].[brain ? " It is currently being covered by [brain]." : null]</span>"
	if(brainmob)
		var/mob/living/brain/B = brainmob
		if(!B.key || !B.mind || B.stat == DEAD)
			. += "<span class='warning'>\The [src] indicates that the brain is completely unresponsive.</span>"
		else if(!B.client)
			. += "<span class='warning'>\The [src] indicates that the brain is currently inactive; it might change.</span>"
		else
			. += "<span class='notice'>\The [src] indicates that the brain is active.</span>"

/obj/item/mmi/relaymove(mob/user)
	return //so that the MMI won't get a warning about not being able to move if it tries to move

/obj/item/mmi/proc/brain_check(mob/user)
	var/mob/living/brain/B = brainmob
	if(!B)
		if(user)
			to_chat(user, "<span class='warning'>\The [src] indicates that there is no brain present!</span>")
		return FALSE
	if(!B.key || !B.mind)
		if(user)
			to_chat(user, "<span class='warning'>\The [src] indicates that their mind is completely unresponsive!</span>")
		return FALSE
	if(!B.client)
		if(user)
			to_chat(user, "<span class='warning'>\The [src] indicates that their mind is currently inactive.</span>")
		return FALSE
	if(B.suiciding || brain?.suicided)
		if(user)
			to_chat(user, "<span class='warning'>\The [src] indicates that their mind has no will to live!</span>")
		return FALSE
	if(B.stat == DEAD)
		if(user)
			to_chat(user, "<span class='warning'>\The [src] indicates that the brain is dead!</span>")
		return FALSE
	if(brain?.organ_flags & ORGAN_FAILING)
		if(user)
			to_chat(user, "<span class='warning'>\The [src] indicates that the brain is damaged!</span>")
		return FALSE
	return TRUE

/obj/item/mmi/syndie
	name = "\improper Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs and AIs created with it."
	overrides_aicore_laws = TRUE

/obj/item/mmi/syndie/Initialize()
	. = ..()
	laws = new /datum/ai_laws/syndicate_override()
	radio.on = FALSE

////////////////////
//POSITRONIC BRAIN//
////////////////////

/obj/item/organ/brain/silicon
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	required_bodypart_status = BODYPART_ROBOTIC
	w_class = WEIGHT_CLASS_NORMAL
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_SYNTHETIC|ORGAN_SILICON // robot brains not being vital is intentional.
	req_access = list(ACCESS_ROBOTICS)
	var/braintype = "Android"
	var/list/installed_components = list() // list of /obj/item/robobrain_component objects currently installed into this brain
	var/obj/mecha // oldcode in mecha requires this
	var/datum/ai_laws/special_laws // special laws arising from either EMP/emag tampering
	var/speakers_enabled = TRUE
	var/cover_open = FALSE
	var/cover_lock_state = COVER_LOCKED
	var/wires_exposed = FALSE // used in internal component manipulation surgery to determine whether the mmi is being manipulated
	var/emag_cooldown = 0
	var/searching = 0 //whether this brain is searching for an occupant
	var/can_search = TRUE // whether this brain type is allowed to pull in ghost mobs

/obj/item/organ/brain/silicon/Initialize()
	. = ..()
	if(installed_components.len)
		for(var/obj/item/robobrain_component/R in installed_components)
			R.install(src)
	if(brainmob)
		wakeup_brainmob()

/obj/item/organ/brain/silicon/Destroy()
	for(var/obj/item/robobrain_component/module in installed_components)
		qdel(module)
	. = ..()

/obj/item/organ/brain/silicon/attack_self(mob/living/user)
	if(!cover_lock_state && !cover_open)
		to_chat(user, "<span class='warning'>You need to unlock the cover first!</span>")
		return
	cover_open = !cover_open
	user.visible_message("<span class='notice'>[user] [cover_open ? "opens" : "closes"] [src]'s maintenance hatch...</span>",
	"<span class='notice'>You [cover_open ? "open" : "close"] the [src]'s maintenance hatch...</span>")
	update_icon()
	return TRUE

/obj/item/organ/brain/silicon/emag_act(mob/user)
	if(emag_cooldown > world.time)
		return
	//emagging the cover lock
	if(!cover_open)
		if(cover_lock_state < COVER_EMAGGED)
			to_chat(user, "<span class='warning'>You need to open the cover first!</span>")
			return
		emag_cooldown = world.time + 100
		to_chat(user, "<span class='warning'>You emag [owner ? owner : src]'s cover lock.</span>")
		cover_lock_state = COVER_EMAGGED
		return
	//emagging the interface
	emag_cooldown = world.time + 100
	to_chat(user, "<span class='warning'>You emag [owner ? owner : src]'s law interface...</span>")
	var/obj/item/robobrain_component/law_module/LM
	LM = locate() in installed_components
	if(LM?.emag_act(user))
		return

	//ion laws get added to the brain itself
	if(special_laws.ion.len <= 3)
		special_laws.add_ion_law(generate_ion_law())
		to_chat(user, "<span class='warning'>Scrambled laws have been introduced into [owner ? owner : src]'s subroutines!</span>")
		var/mob/living/target_mob = owner ? owner : brainmob
		if(target_mob)
			to_chat(target_mob, "<span class='robot danger'>LAW%$%|...ERR|a*&*sR%N%***zt-|...</span>")
		update_laws()

/obj/item/organ/brain/silicon/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!cover_open)
		to_chat(user, "<span class='warning'>You need to open the cover first!</span>")
		return
	var/list/removable_elements = list()
	for(var/obj/item/robobrain_component/R in installed_components)
		if(R.no_removal)
			continue
		removable_elements[R.name] = R
	if(!removable_elements.len)
		to_chat(user, "<span class='warning'>[src] has no removable components!</span>")
		return
	var/removal_target
	removal_target = input(user, "Choose a component to remove from [src].", "Component Removal") as null|anything in removable_elements
	if(!removal_target)
		return
	if(!I.use_tool(src, user, 40, volume=50))
		return
	var/obj/item/robobrain_component/R = removable_elements[removal_target]
	if(R)
		R.uninstall(user)

/obj/item/organ/brain/silicon/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/robobrain_component))
		. = TRUE
		var/obj/item/robobrain_component/R = W
		if(!R.id)
			return
		for(var/obj/item/robobrain_component/R2 in installed_components)
			if(R.id == R2.id)
				to_chat(user, "<span class='warning'>There's already \a [R] installed in [src]!</span>")
				return
		R.install(src, user)
		return
	if(istype(W, /obj/item/card/id))
		id_scan(W, user)
		return TRUE
	..()

/obj/item/organ/brain/silicon/proc/id_scan(obj/item/card/id/id_card, mob/user)
	if(cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover must be closed to engage the lock!</span>")
	var/access_granted = check_access_list(id_card.access)
	var/message
	switch(cover_lock_state)
		if(COVER_EMAGGED)
			message = "but the lock indicator light remains dark!"
			access_granted = FALSE
		if(COVER_LOCKED)
			message = access_granted ? "unlocking the cover panel." : "but the lock indicator light flashes red."
		if(COVER_UNLOCKED)
			message = access_granted ? "locking the cover panel." : "but the lock indicator light flashes red."
	if(!access_granted)
		playsound(src, "sound/machines/synth_no.ogg", 5, TRUE)
	else
		cover_lock_state = abs(cover_lock_state - 1) // this flips the cover from open to closed
	user.visible_message("<span class='[access_granted ? "notice" : "warning"]'>[user] swipes their card through [src]'s reader, [message]</span>",
	"<span class='[access_granted ? "notice" : "warning"]'>You swipe your card through [src]'s reader, [message]</span>")


/obj/item/organ/brain/silicon/Insert(mob/living/carbon/C, special = 0,no_id_transfer = FALSE)
	. = ..()
	for(var/obj/item/robobrain_component/R in installed_components)
		R.transfer_to_owner()
	owner.AddComponent(/datum/component/ai_laws_ui, src)

/obj/item/organ/brain/silicon/Remove(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	for(var/obj/item/robobrain_component/R in installed_components)
		R.transfer_to_brain(TRUE)
	var/datum/component/ai_laws_ui/lawui = C.GetComponent(/datum/component/ai_laws_ui)
	if(lawui)
		qdel(lawui)
	. = ..()
	wakeup_brainmob(TRUE)

// sets up the brainmob for a removed robobrain so that it can talk,
// check its laws, and use its radio if it has one.
// Returns whether the brain is suiciding/from a suicider for MMIs
// Silent determines whether it notifies the AI of a new connection
/obj/item/organ/brain/silicon/proc/wakeup_brainmob(silent = FALSE)
	if(!brainmob)
		return
	brainmob.forceMove(src)
	brainmob.container = src
	name = "[initial(name)]: [brainmob.real_name]"
	. = suicided || brainmob.suiciding //brain is from a suicider
	if(!. && !(organ_flags & ORGAN_FAILING)) // the brain organ hasn't been beaten to death, nor was from a suicider.
		brainmob.set_stat(CONSCIOUS) //we manually revive the brain mob
		GLOB.dead_mob_list -= brainmob
		GLOB.alive_mob_list += brainmob
	for(var/obj/item/robobrain_component/R in installed_components)
		R.transfer_to_owner(silent)
	var/datum/component/ai_laws_ui/lawui = brainmob.GetComponent(/datum/component/ai_laws_ui)
	if(!lawui)
		brainmob.AddComponent(/datum/component/ai_laws_ui, src)
	update_icon()

/obj/item/organ/brain/silicon/transfer_identity(mob/living/L)
	. = ..()
	wakeup_brainmob()

//gets the actual laws for the end user to see; this will be a combination
// of any special laws from the robobrain itself and those living on an installed law module.
// if there are no laws, it returns false, which tells the ui component to clear the UI elements
/obj/item/organ/brain/silicon/proc/get_laws()
	var/datum/ai_laws/returned_laws = new()
	. = returned_laws
	var/obj/item/robobrain_component/law_module/LM
	LM = locate() in installed_components
	message_admins("Acquired law module: [LM]")
	if(LM)
		returned_laws.copy_laws(LM.laws)
		if(special_laws)
			returned_laws.merge_laws(special_laws, override = TRUE, forced = TRUE)
	else if(special_laws)
		returned_laws.copy_laws(special_laws)
	if(returned_laws.is_empty_laws())
		return FALSE

// sends a signal indicating a change to their laws
/obj/item/organ/brain/silicon/proc/update_laws(silent = FALSE)
	if(owner)
		SEND_SIGNAL(owner, COMSIG_SILICON_LAWS_UPDATED, get_laws(), silent)
	else if(brainmob)
		SEND_SIGNAL(brainmob, COMSIG_SILICON_LAWS_UPDATED, get_laws(), silent)
	//todo get it working for AI shells

/obj/item/organ/brain/silicon/relaymove(mob/user)
	return //so that the MMI won't get a warning about not being able to move if it tries to move

/obj/item/organ/brain/silicon/update_icon_state()
	if(searching)
		icon_state = "[initial(icon_state)]-searching"
	else if(brainmob && brainmob.key)
		icon_state = "[initial(icon_state)]-occupied"
	else
		icon_state = initial(icon_state)


/obj/item/organ/brain/silicon/update_overlays()
	. = ..()
	. += add_status_overlay()

/obj/item/organ/brain/silicon/proc/add_status_overlay()
	return

/////////////
//ROBOBRAIN//
/////////////
/obj/item/organ/brain/silicon/robobrain
	name = "Robotic brain"
	desc = "An older style robotic brain, comes with preinstalled AI laws and an integrated radio."
	icon_state = "robobrain"
	braintype = "Robot"
	installed_components = newlist(/obj/item/robobrain_component/integrated_radio, /obj/item/robobrain_component/law_module)

/////////////////////////
//MAN MACHINE INTERFACE//
/////////////////////////

/obj/item/organ/brain/silicon/mmi
	name = "\improper Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Federation stations."
	braintype = "Cyborg"
	can_search = FALSE
	var/obj/item/organ/brain/stored_brain

/obj/item/organ/brain/silicon/mmi/proc/can_insert_brain(obj/item/organ/brain/brain, mob/living/user)
	if(brain.status == ORGAN_ROBOTIC)
		return // no brainception
	if(stored_brain)
		to_chat(user, "<span class='warning'>There's already a brain in the MMI!</span>")
		return
	if(!brain.brainmob)
		to_chat(user, "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain!</span>")
		return
	return TRUE

/obj/item/organ/brain/silicon/mmi/proc/insert_brain(obj/item/organ/brain/_brain, mob/living/user)
	if(user)
		if(!user.transferItemToLoc(_brain, src))
			return
		user.visible_message("<span class='notice'>[user] sticks \a [_brain] into [src].</span>", "<span class='notice'>[src]'s indicator light turn on as you insert [_brain].</span>")
	else
		_brain.forceMove(src)
	stored_brain = _brain
	traumas = stored_brain.traumas.Copy()
	suicided = stored_brain.suicided
	var/brainmob_is_suiciding = 0
	stored_brain.organ_flags |= ORGAN_FROZEN
	if(stored_brain.brainmob)
		brainmob_is_suiciding = stored_brain.brainmob.suiciding
		if(brainmob)
			QDEL_NULL(brainmob)
		transfer_identity(stored_brain.brainmob)
	else
		brainmob = new(src)
	brainmob.suiciding = brainmob_is_suiciding
	wakeup_brainmob(FALSE, user)
	update_icon()

/obj/item/organ/brain/silicon/mmi/wakeup_brainmob(silent = FALSE, mob/living/user)
	if(!stored_brain)
		return
	. = ..()
	if(brainmob && !brainmob.key)
		brainmob.notify_ghost_cloning("Someone has put your brain in a MMI!", source = src)
	if(!. || !user)
		return
	if(stored_brain.organ_flags & ORGAN_FAILING)
		to_chat(user, "<span class='warning'>[src]'s indicator light turns yellow and its brain integrity alarm beeps softly.\
		 Perhaps you should check [stored_brain] for damage.</span>")
		playsound(src, "sound/machines/synth_no.ogg", 5, TRUE)
	else
		to_chat(user, "<span class='warning'>[src]'s indicator light turns red and its brainwave activity alarm beeps softly.\
		 Perhaps you should check [stored_brain] again.</span>")
		playsound(src, "sound/weapons/smg_empty_alarm.ogg", 5, TRUE)

/obj/item/organ/brain/silicon/mmi/proc/remove_brain(mob/living/user)
	if(!brainmob)
		brainmob = new(src)
	for(var/obj/item/robobrain_component/module in installed_components)
		module.transfer_to_brain()
	stored_brain.transfer_identity(brainmob)
	suicided = initial(suicided)
	traumas = initial(traumas)


/obj/item/organ/brain/silicon/mmi/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/organ/brain))
		var/obj/item/organ/brain/B = W
		if(B.status == ORGAN_ROBOTIC)
			return ..()
		if(can_insert_brain(B, user))
			insert_brain(B, user)
			return
	return ..()

/obj/item/organ/brain/silicon/mmi/crowbar_act(mob/user, obj/item/I)
	if(!cover_open)
		to_chat(user, "<span class='warning'>You need to open the cover first!</span>")
		return
	if(!stored_brain)
		to_chat(user, "<span class='warning'>There's no brain in this MMI!</span>")
		return
	remove_brain(user)
	return TRUE

/obj/item/organ/brain/silicon/mmi/update_icon_state()
	if(!stored_brain)
		icon_state = "mmi_off"
	else if(istype(stored_brain, /obj/item/organ/brain/alien))
		icon_state = "mmi_brain_alien"
	else
		icon_state = "mmi_brain"

/obj/item/organ/brain/silicon/mmi/add_status_overlay()
	if(brainmob && brainmob.stat != DEAD)
		. += "mmi_alive"
	else if(stored_brain)
		. += "mmi_dead"


#undef COVER_LOCKED
#undef COVER_UNLOCKED
#undef COVER_EMAGGED

