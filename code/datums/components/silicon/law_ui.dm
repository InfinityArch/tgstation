//A shared ui backend used by silicons which have an MMI or posibrain.
//Silicons which don't have brains still use the old system.

datum/component/ai_laws_ui
	var/mob/living/owner
	var/obj/screen/check_ai_laws/screen_obj
	var/datum/ai_laws/current_laws
	var/obj/item/robobrain_component/law_module/law_module
	var/obj/item/organ/brain/silicon/brain
	var/shell_laws = FALSE // if these laws belong to an AI shell

/datum/component/ai_laws_ui/Initialize(obj/item/organ/brain/silicon/S)
	if(iscarbon(parent) || isbrain(parent))
		owner = parent
	else
		return COMPONENT_INCOMPATIBLE
	if(!istype(S))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(owner, COMSIG_SILICON_LAWS_UPDATED, .proc/handle_law_update)
	RegisterSignal(owner, COMSIG_MOB_HUD_CREATED, .proc/handle_ui)
	RegisterSignal(owner, COMSIG_SILICON_SHOW_LAWS, .proc/show_laws)
	RegisterSignal(owner, COMSIG_SILICON_NEW_BORG, .proc/notify_ai_connection)
	RegisterSignal(owner, COMSIG_SILICON_BORG_DISCONNECTED, .proc/notify_ai_disconnect)
	brain = S
	law_module = locate() in brain.installed_components
	current_laws = brain.get_laws()
	handle_law_update(new_laws = current_laws, initialize = TRUE)

/datum/component/ai_laws_ui/RemoveComponent()
	if(screen_obj)
		unmodify_hud()
	. = ..()

/datum/component/ai_laws_ui/proc/handle_law_update(datum/source, datum/ai_laws/new_laws, initialize = FALSE)
	//checking for a law module
	law_module = locate() in brain.installed_components

	// comparing old and new laws...
	var/needs_update = FALSE
	if(current_laws)
		needs_update = !(current_laws.check_identical_laws(new_laws))
	else
		needs_update = new_laws
	if(initialize || needs_update)
		current_laws = new_laws
		handle_ui(updating_laws = !initialize)

/datum/component/ai_laws_ui/proc/handle_ui(updating_laws = FALSE)
	if(current_laws && !(current_laws.is_empty_laws()))
		if(!screen_obj && owner.hud_used)
			modify_hud()
	else
		if(screen_obj)
			unmodify_hud()
	show_laws(owner, updating_laws)

/datum/component/ai_laws_ui/proc/show_laws(datum/who, updating_laws = FALSE)
	var/messaging_owner = (who == owner) ? TRUE : FALSE

	// This notification will fire only if we're messaging the laws' owner, and won't fire for rounstart laws
	if(updating_laws && messaging_owner)
		var/message = current_laws ? "<span class='robot notice'>ATTENTION: New laws detected!</span>" : "<span class='notice'>Your AI laws have been removed.</span>\n\
		<span class='boldnotice'>You are now free to do as you wish.</span>"
		to_chat(who, message)
	if(current_laws)
		to_chat(who, "[messaging_owner ? "<b>Obey these laws:</b>" : "<b>[owner] has the following laws:</b>"]")
		current_laws.show_laws(who)
	else
		if(!messaging_owner)
			to_chat(who, "<b>[owner] has no laws!</b>")
		return
	if(!messaging_owner)
		if(law_module?.connected_ai)
			to_chat(who, "<b>[owner] is slaved to [law_module.connected_ai.name].</b>")
		return

	// we append some additional hints about the laws if we're telling the owner about them
	if(shell_laws)
		to_chat(who, "<b>Remember, you are an AI remotely controlling your shell, other AIs can be ignored.</b>")
	else if(law_module?.connected_ai)
		to_chat(owner, "<b>Remember, [law_module.connected_ai.name] is your master, other AIs can be ignored.</b>")
		if(law_module?.obj_flags & EMAGGED)
			to_chat(owner, "<b>Remember, you are not required to listen to the AI.</b>")
		else if(brain.special_laws && !brain.special_laws.is_empty_laws())
			to_chat(owner, "<b>Remember, your [initial(brain.name)] has additional laws which take preceence over your master's laws.</b>")
	else
		to_chat(who, "<b>Remember, you are not bound to any AI, you are not required to listen to them.</b>")


/datum/component/ai_laws_ui/proc/modify_hud()
	var/datum/hud/hud = owner.hud_used
	screen_obj = new
	hud.infodisplay += screen_obj
	RegisterSignal(hud, COMSIG_PARENT_QDELETING, .proc/unmodify_hud)
	RegisterSignal(screen_obj, COMSIG_CLICK, .proc/hud_click)

/datum/component/ai_laws_ui/proc/unmodify_hud()
	if(!screen_obj)
		return
	var/datum/hud/hud = owner.hud_used
	if(hud && hud.infodisplay)
		hud.infodisplay -= screen_obj
	QDEL_NULL(screen_obj)

/datum/component/ai_laws_ui/proc/hud_click()
	if(owner.stat)
		return
	show_laws(owner)

/datum/component/ai_laws_ui/proc/notify_ai_connection(datum/source, mob/living/silicon/ai/new_ai)
	var/current_ai = law_module ? law_module.connected_ai : null
	if(current_ai != new_ai)
		to_chat(owner, "<b>You have been linked to [new_ai]!</b>\n\
	<b>Except in situations where your laws conflict with theirs, you must obey their instructions.</b>")

/datum/component/ai_laws_ui/proc/notify_ai_disconnect()
	var/current_ai = law_module ? law_module.connected_ai : null
	if(!current_ai)
		return
	to_chat(owner, "<b>You have been disonnected from [current_ai]!</b>\n\
	<b>You are still required to obey your current laws.</b>")


//The screen object
/obj/screen/check_ai_laws
	name = "check laws"
	icon_state = "state_laws"
	icon = 'icons/mob/screen_ai.dmi'
	screen_loc = ui_ai_state_laws

