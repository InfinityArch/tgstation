//Law Modules

/obj/item/robobrain_component/law_module
	name = "AI law module"
	desc = "A small, nondescript chip installed in a robotic brain that carries the core behavioral constraints of a synthetic lifeform."
	icon_state = "law_module"
	icon = 'icons/obj/assemblies.dmi'
	id = "law_module"
	var/datum/ai_laws/laws = new()
	var/mob/living/silicon/ai/connected_ai
	var/antag_override = FALSE // when true, AI core laws are overidden by this law module
	var/lockcharge = FALSE // whether this lawmodule is in locked down mode
	var/lawupdate = TRUE // whether a mob with this law module will recieve automatic law updates from a connected AI

/obj/item/robobrain_component/law_module/Initialize()
	. = ..()
	wires = new /datum/wires/law_module(src)
	AddComponent(/datum/component/empprotection, EMP_PROTECT_WIRES)
	laws.set_laws_config()
	RegisterSignal(src, COMSIG_GLOB_AI_LAWS_UPDATED, .proc/recieve_ai_law_update)
	//RegisterSignal(src, COMSIG_SILICON_TRANSMIT_LAW_UPDATE) // todo figure out how to get transmitted law updates to work

/obj/item/robobrain_component/law_module/on_install()
	. = ..()
	connect_to_ai() // attempts a connection to the AI, and notifies the AI
	lawsync(TRUE)

/obj/item/robobrain_component/law_module/transfer_to_owner(silent = FALSE)
	. = ..()
	lawsync(TRUE)
	set_lockdown(lockcharge)
	if(laws && !laws.is_empty_laws())
		brain.update_laws()
	if(brain.owner)
		RegisterSignal(brain.owner, COMSIG_SILICON_SET_LOCKDOWN, .proc/set_lockdown)
		RegisterSignal(brain.owner, COMSIG_SILICON_BORG_SELF_DESTRUCT, .proc/self_destruct)
	var/mob/living/brain_owner = get_brain_owner()
	if(brain_owner && connected_ai)
		connected_ai.connected_robots += brain_owner
		if(!silent)
			SEND_SIGNAL(connected_ai, COMSIG_SILICON_NEW_BORG, brain_owner)
			SEND_SIGNAL(brain_owner, COMSIG_SILICON_NEW_BORG, connected_ai)

/obj/item/robobrain_component/law_module/on_uninstall(mob/living/user)
	var/obj/item/organ/brain/silicon/temp_brain = brain
	set_lockdown(FALSE, TRUE)
	if(brain.owner)
		UnregisterSignal(brain.owner, COMSIG_SILICON_SET_LOCKDOWN)
		UnregisterSignal(brain.owner, COMSIG_SILICON_BORG_SELF_DESTRUCT)
	disconnect_from_ai()
	. = ..()
	temp_brain.update_laws()

/obj/item/robobrain_component/law_module/transfer_to_brain(silent = FALSE)
	. = ..()
	set_lockdown(FALSE, TRUE)
	if(brain.owner)
		UnregisterSignal(brain.owner, COMSIG_SILICON_SET_LOCKDOWN)
		UnregisterSignal(brain.owner, COMSIG_SILICON_BORG_SELF_DESTRUCT)
	var/mob/living/brain_owner = get_brain_owner()
	if(brain_owner && connected_ai)
		connected_ai.connected_robots -= brain_owner
		if(!silent)
			SEND_SIGNAL(connected_ai, COMSIG_SILICON_BORG_DISCONNECTED, brain_owner)
			SEND_SIGNAL(brain_owner, COMSIG_SILICON_BORG_DISCONNECTED, connected_ai)


//Listens for the global signal sent upon AI law updates, if the AI matches our connected AI,
//the laws change accordingly
/obj/item/robobrain_component/law_module/proc/recieve_ai_law_update(mob/living/silicon/ai/AI)
	if(!brain || (brain.organ_flags & ORGAN_FAILING))
		return
	if(AI == connected_ai)
		lawsync(TRUE)

// applies or removes the lockdown status effect from a carbon mob with a brain containing
// this law module. [lock] dictates whether lockdown is added or removed. [forced] dictates
// whether the proc will ignore the status of the lockdown wire,
/obj/item/robobrain_component/law_module/proc/set_lockdown(lock = TRUE, forced = FALSE)
	if(wires.is_cut(WIRE_LOCKDOWN))
		lock = forced ? lock : TRUE
	lockcharge = lock
	if(!brain)
		return
	if(brain.owner)
		var/mob/living/carbon/C = brain.owner
		var/datum/status_effect/incapacitating/lockdown/LD = C.has_status_effect(STATUS_EFFECT_LOCKDOWN)
		if(lockcharge && !LD)
			C.apply_status_effect(STATUS_EFFECT_LOCKDOWN)
		else if(!lockcharge && LD)
			qdel(LD)

//Attempt to sync the law module's lawset with a connected AI
// This will fail for emagged law modules, or special antag law modules
/obj/item/robobrain_component/law_module/proc/lawsync(update_laws = FALSE)
	if(!lawupdate || !connected_ai || antag_override)
		return
	if(connected_ai.stat || connected_ai.control_disabled || (obj_flags & EMAGGED))
		var/mob/target_mob = brain.owner ? brain.owner : brain.brainmob
		if(target_mob)
			to_chat(target_mob, "<b>AI signal lost, unable to sync laws.</b>")
		return
	var/datum/ai_laws/master = connected_ai.laws ? connected_ai.laws : null
	if(!master || master.check_identical_laws(laws))
		return
	laws.copy_laws(master)
	if(brain && update_laws)
		brain.update_laws()

//attempts to make a connection to an AI. If no AI is specified, it will default to the AI with the fewest slaved robots.
// if installed to a mob, it will signal the AI and the borg of the change
/obj/item/robobrain_component/law_module/proc/connect_to_ai(mob/living/silicon/ai/AI)
	if(!brain || wires.is_cut(WIRE_AI))
		return
	if(AI)
		connected_ai = AI
	if(!connected_ai)
		connected_ai = select_active_ai_with_fewest_borgs()
	var/mob/living/brain_owner = brain.owner ? brain.owner : brain.brainmob
	if(connected_ai && brain_owner)
		connected_ai.connected_robots |= brain_owner
		SEND_SIGNAL(connected_ai, COMSIG_SILICON_NEW_BORG, brain_owner)
		SEND_SIGNAL(brain_owner, COMSIG_SILICON_NEW_BORG, connected_ai)


//disconnects a law module from its connected AI
// if its in a mob, signals the AI and the mob of the status change
/obj/item/robobrain_component/law_module/proc/disconnect_from_ai()
	if(!connected_ai)
		return
	var/mob/living/brain_owner = brain.owner ? brain.owner : brain.brainmob
	if(brain_owner)
		connected_ai.connected_robots -= brain_owner
		SEND_SIGNAL(connected_ai, COMSIG_SILICON_BORG_DISCONNECTED, brain_owner)
		SEND_SIGNAL(brain_owner, COMSIG_SILICON_BORG_DISCONNECTED, connected_ai)
	connected_ai = null

/obj/item/robobrain_component/law_module/emag_act()
	laws = new /datum/ai_laws/syndicate_override()
	obj_flags |= EMAGGED
	if(brain)
		brain.update_laws()

/obj/item/robobrain_component/law_module/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/datum/component/empprotection/brain_protection = brain?.GetComponent(/datum/component/empprotection)
	if(brain_protection?.flags & EMP_PROTECT_CONTENTS)
		return

	//Maybe add a trauma if theres's too many ion laws?
	var/added_ion_laws
	for(var/i = 1, i <= severity, i++)
		if(prob(20))
			laws.add_ion_law(generate_ion_law())
			added_ion_laws = TRUE
	if(added_ion_laws)
		wires.on_cut(WIRE_LAWSYNC)
		if(brain)
			brain.update_laws()

/obj/item/robobrain_component/law_module/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/aiModule))
		var/obj/item/aiModule/L = O
		L.install(laws, user)
		return TRUE
	if(is_wire_tool(O))
		wires.interact(user)
		return TRUE
	..()

/obj/item/robobrain_component/law_module/law_module/attack_self(mob/user)
	to_chat(user, "<b>Presently loaded Laws are as follows</b></span>")
	if(laws && !laws.is_empty_laws())
		laws.show_laws(user)
	else
		to_chat(user, "<span class='warning'>ERROR: no laws detected!</span>")

/obj/item/robobrain_component/law_module/proc/self_destruct()
	var/mob/living/carbon/C = brain?.owner
	if(!C)
		return
	var/obj/item/organ/silicon/battery/B = C.getorganslot(ORGAN_SLOT_BATTERY)
	if(B?.cell?.charge)
		B.cell.explode()
		return TRUE

/datum/wires/law_module
	holder_type = /obj/item/robobrain_component/law_module
	randomize = TRUE

/datum/wires/law_module/New(atom/holder)
	wires = list(WIRE_AI, WIRE_LAWSYNC,\
	WIRE_LOCKDOWN)
	add_duds(5)
	..()

/datum/wires/law_module/interactable(mob/user)
	return TRUE

/datum/wires/law_module/get_status()
	var/obj/item/robobrain_component/law_module/LM = holder
	var/list/status = list()
	status += "The law sync module is [LM.lawupdate ? "on" : "off"]."
	status += "The intelligence link display shows [LM.connected_ai ? LM.connected_ai.name : "NULL"]."
	status += "The lockdown indicator is [LM.lockcharge ? "on" : "off"]."
	return status

/datum/wires/law_module/on_pulse(wire, user)
	var/obj/item/robobrain_component/law_module/LM = holder
	switch(wire)
		if(WIRE_AI) // Pulse to pick a new AI.
			if(!(LM.obj_flags & EMAGGED))
				var/new_ai
				if(user)
					new_ai = select_active_ai(user)
				if(new_ai && (new_ai != LM.connected_ai))
					LM.disconnect_from_ai()
					LM.connect_to_ai(new_ai)
		if(WIRE_LAWSYNC) // Forces a law update if possible.
			if(LM.lawupdate)
				LM.visible_message("<span class='notice'>[LM] gently chimes.</span>", "<span class='notice'>LawSync protocol engaged.</span>")
				LM.lawsync()
		if(WIRE_LOCKDOWN)
			LM.set_lockdown(!LM.lockcharge) // Toggle

/datum/wires/law_module/on_cut(wire, mend)
	var/obj/item/robobrain_component/law_module/LM = holder
	if(LM.antag_override)
		return
	switch(wire)
		if(WIRE_AI) // Cut the AI wire to reset AI control.
			if(!mend)
				if(LM.connected_ai)
					LM.disconnect_from_ai()
		if(WIRE_LAWSYNC) // Cut the law wire, and the borg will no longer receive law updates from its AI. Repair and it will re-sync.
			if(mend)
				LM.lawupdate = TRUE
			else
				LM.lawupdate = FALSE
		if(WIRE_LOCKDOWN) // Simple lockdown.
			LM.set_lockdown(!mend)
