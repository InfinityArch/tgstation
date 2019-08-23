//contains the basics of psioncs, and of telepathic communication for a WIP system

/datum/action/innate/psionic
	icon_icon = 'icons/mob/actions/actions_psionic.dmi'
	background_icon_state = "bg_psionic"
	buttontooltipstyle = "psionic"
	check_flags = AB_CHECK_STUN|AB_CHECK_CONSCIOUS

/datum/action/innate/psionic/IsAvailable()
	if(!HAS_TRAIT(owner, TRAIT_PSYCHIC)
		return FALSE
	return ..()

/datum/action/innate/psionic/telepath_com
	name = "Project Mind"
	desc = "Broadcasts your thoughts for all psychically sensitive beings in the area to hear."
	button_icon_state = "telepath_comms"

/datum/action/innate/cult/comm/Activate()
	var/input = stripped_input(usr, "Please choose a message to broadtcast telepathically", "Voice of Blood", "")
	if(!input || !IsAvailable())
		return

	telepathic_broadcast(usr, input)

/datum/action/innate/psionic/proc/telepathic_broadtcast(mob/living/user, message)
	var/my_message
	if(!message)
		return
	var/span = "psionic"
	if(user.mind && (user.mind.has_antag_datum(/datum/antagonist/abductor || user.mind.has_antag_datum(/datum/antagonist/ethereal))
		span = "psionic_large"
		my_message = "<span class='[span]'><b>[findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"

	else
		my_message = "<span class='[span]'><b>[findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(ispsychic(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="telepathy")
