/datum/surgery/brain_surgery
	name = "Brain surgery"
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/fix_brain,
	/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_HEAD)
	required_biotypes = MOB_ORGANIC|MOB_MINERAL
	requires_bodypart_type = 0

/datum/surgery_step/fix_brain
	name = "fix brain"
	implements = list(TOOL_HEMOSTAT = 85, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15) //don't worry, pouring some alcohol on their open brain will get that chance to 100
	time = 120 //long and complicated

/datum/surgery/brain_surgery/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B || !B.zone == BODY_ZONE_HEAD)
		return FALSE
	return TRUE

/datum/surgery_step/fix_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to fix [target]'s brain...</span>",
		"<span class='notice'>[user] begins to fix [target]'s brain.</span>",
		"<span class='notice'>[user] begins to perform surgery on [target]'s brain.</span>")

/datum/surgery_step/fix_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You succeed in fixing [target]'s brain.</span>",
		"<span class='notice'>[user] successfully fixes [target]'s brain!</span>",
		"<span class='notice'>[user] completes the surgery on [target]'s brain.</span>")
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/brainwashed))
		target.mind.remove_antag_datum(/datum/antagonist/brainwashed)
	target.setOrganLoss(ORGAN_SLOT_BRAIN, target.getOrganLoss(ORGAN_SLOT_BRAIN) - 60)	//we set damage in this case in order to clear the "failing" flag
	target.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	return TRUE

/datum/surgery_step/fix_brain/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		display_results(user, target, "<span class='warning'>You screw up, causing more damage!</span>",
			"<span class='warning'>[user] screws up, causing brain damage!</span>",
			"<span class='notice'>[user] completes the surgery on [target]'s brain.</span>")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	else
		user.visible_message("<span class='warning'>[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore.</span>", "<span class='warning'>You suddenly notice that the brain you were working on is not there anymore.</span>")
	return FALSE


/datum/surgery/brain_surgery/silicon
	name = "Synthetic brain repair"
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/fix_brain/silicon,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close
		)
	required_biotypes = MOB_ROBOTIC

/datum/surgery_step/fix_brain
	name = "repair synthetic brain"
	implements = list(TOOL_MULTITOOL = 100, TOOL_WIRECUTTERS = 70)
	time = 120

/datum/surgery_step/fix_brain/silicon/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You carefully begin to repair [target]'s damaged [target.getorganslot(ORGAN_SLOT_BRAIN)]...</span>",
		"<span class='notice'>[user] carefully begins to repair [target]'s damaged [target.getorganslot(ORGAN_SLOT_BRAIN)].</span>",
		"<span class='notice'>[user] begins working on [target]'s [target.getorganslot(ORGAN_SLOT_BRAIN)].</span>")

/datum/surgery_step/fix_brain/silicon/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You succesfully repair [target]'s [target.getorganslot(ORGAN_SLOT_BRAIN)].</span>",
		"<span class='notice'>[user] successfully fixes [target]'s [target.getorganslot(ORGAN_SLOT_BRAIN)]!</span>",
		"<span class='notice'>[user] completes the work on [target]'s [target.getorganslot(ORGAN_SLOT_BRAIN)].</span>")
	//if(target.mind && target.mind.has_antag_datum(/datum/antagonist/hacked))
		//target.mind.remove_antag_datum(/datum/antagonist/hacked)
	target.setOrganLoss(ORGAN_SLOT_BRAIN, 0)
	target.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	return TRUE

/datum/surgery_step/fix_brain/silicon/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		display_results(user, target, "<span class='warning'>You screw up, causing more damage!</span>",
			"<span class='warning'>[user] screws up, severely damaging the [target.getorganslot(ORGAN_SLOT_BRAIN)]!</span>",
			"<span class='notice'>[user] completes the work on [target]'s [target.getorganslot(ORGAN_SLOT_BRAIN)].</span>")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	else
		user.visible_message("<span class='warning'>[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore.</span>", "<span class='warning'>You suddenly notice that the brain you were working on is not there anymore.</span>")
	return FALSE
