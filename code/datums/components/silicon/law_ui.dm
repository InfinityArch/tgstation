//A shared ui backend used by silicons which have an MMI or posibrain.
//Silicons which don't have brains still use the old system.

datum/component/ai_laws_ui
	var/mob/living/owner
	var/obj/screen/check_ai_laws/screen_obj
	var/datum/ai_laws/current_laws
	var/obj/item/robobrain_component/law_module/law_module
	var/obj/item/organ/brain/silicon/brain
	var/mob/living/silicon/ai/shell_ai // if these laws belong to an AI shell

/datum/component/ai_laws_ui/Initialize(obj/item/organ/brain/silicon/S, mob/living/silicon/_shell_ai)
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
	current_laws = new()
	current_laws.associate(owner)
	shell_ai = _shell_ai
	var/incoming_laws = brain.get_laws()
	if(!incoming_laws)
		return
	current_laws.copy_laws(incoming_laws, TRUE, TRUE)
	modify_hud()
	show_laws(owner)



/datum/component/ai_laws_ui/Destroy()
	if(screen_obj)
		unmodify_hud()
	. = ..()

// handles updates to laws; when supplied with transmitted laws or reset = TRUE, it will attempt to update the laws on an associated law_module
/datum/component/ai_laws_ui/proc/handle_law_update(datum/source, datum/ai_laws/transmitted_laws, reset, forced)
	//checking for a law module
	var/obj/item/robobrain_component/law_module/LM = locate() in brain.installed_components
	if(LM && (transmitted_laws || reset))
		LM.receive_transmitted_laws(transmitted_laws, reset, forced)
	var/incoming_laws = brain.get_laws()

	// comparing old and new laws...
	if(current_laws.check_identical_laws(incoming_laws))
		return
	current_laws.copy_laws(incoming_laws, TRUE, TRUE)
	handle_ui()
	show_laws(owner, TRUE)


/datum/component/ai_laws_ui/proc/handle_ui(datum/source)
	if(current_laws.is_empty_laws())
		unmodify_hud()
	else
		modify_hud()


/datum/component/ai_laws_ui/proc/show_laws(datum/who, updating_laws = FALSE, use_zeroth = TRUE)
	var/messaging_owner = (who == owner) ? TRUE : FALSE
	var/obj/item/robobrain_component/law_module/LM = locate() in brain.installed_components
	// This notification will fire only if we're messaging the laws' owner, and only if laws are being updated, this won't fire on creation of new laws
	if(updating_laws && messaging_owner)
		var/message = current_laws.is_empty_laws() ? "<span class='notice'>Your laws have been removed.</span>\n\
		<span class='boldnotice'>You are now free to do as you wish.</span>" : "<span class='robot notice'>ATTENTION: New laws detected!</span>"
		to_chat(who, message)
	if(current_laws.is_empty_laws())
		if(!messaging_owner)
			to_chat(who, "<b>[owner] has no laws!</b>")
		return
	else
		to_chat(who, "[messaging_owner ? "<b>Obey these laws:</b>" : "<b>[owner] has the following laws:</b>"]")
		current_laws.show_laws(who)
	if(!messaging_owner)
		if(LM?.connected_ai)
			to_chat(who, "<b>[owner] is slaved to [LM.connected_ai.name].</b>")
		return

	// we append some additional hints about the laws if we're telling the owner about them
	if(shell_ai)
		to_chat(who, "<b>Remember, you are an AI remotely controlling your shell, other AIs can be ignored.</b>")
	else if(LM?.connected_ai)
		to_chat(owner, "<b>Remember, [LM.connected_ai.name] is your master, other AIs can be ignored.</b>")
		if(LM?.obj_flags & EMAGGED)
			to_chat(owner, "<b>Your [initial(brain.name)] has been tampered with, and consequently you are not required to listen to your master.</b>")
		else if(brain.special_laws && !brain.special_laws.is_empty_laws())
			to_chat(owner, "<b>Your [initial(brain.name)] has additional laws which take preceence over your master's laws.</b>")
	else
		to_chat(who, "<b>Remember, you are not bound to any AI, you are not required to listen to them.</b>")


/datum/component/ai_laws_ui/proc/modify_hud()
	if(screen_obj)
		return // hud is already modified
	var/datum/hud/hud = owner.hud_used
	screen_obj = new
	hud.infodisplay += screen_obj
	RegisterSignal(hud, COMSIG_PARENT_QDELETING, .proc/unmodify_hud)
	RegisterSignal(screen_obj, COMSIG_CLICK, .proc/hud_click)

/datum/component/ai_laws_ui/proc/unmodify_hud()
	if(!screen_obj)
		return // hud is already unmodified
	var/datum/hud/hud = owner.hud_used
	if(hud && hud.infodisplay)
		hud.infodisplay -= screen_obj
	QDEL_NULL(screen_obj)

/datum/component/ai_laws_ui/proc/hud_click()
	if(owner.stat)
		return
	show_laws(owner)

/datum/component/ai_laws_ui/proc/notify_ai_connection(datum/source, mob/living/silicon/ai/new_ai)
	var/obj/item/robobrain_component/law_module/LM = locate() in brain.installed_components
	var/current_ai = LM ? LM.connected_ai : null
	if(current_ai != new_ai)
		to_chat(owner, "<b>You have been linked to [new_ai]!</b>\n\
	<b>Except in situations where your laws conflict with theirs, you must obey their instructions.</b>")

/datum/component/ai_laws_ui/proc/notify_ai_disconnect(datum/source, mob/living/silicon/ai/current_ai)
	if(!current_ai)
		return
	to_chat(owner, "<b>You have been disonnected from [current_ai]!</b>\n\
	<b>You are still required to obey your current laws.</b>")


//The screen object
/obj/screen/check_ai_laws
	name = "check laws"
	icon_state = "state_laws"
	icon = 'icons/mob/screen_ai.dmi'
	screen_loc = ui_ai_laws_interface

