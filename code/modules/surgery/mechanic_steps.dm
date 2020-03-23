//open shell
/datum/surgery_step/mechanic_open
	name = "unscrew shell"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		TOOL_SCALPEL 			= 75, // med borgs could try to unskrew shell with scalpel
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 24

/datum/surgery_step/mechanic_open/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to unscrew the shell of [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)].</span>")

/datum/surgery_step/mechanic_open/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You unscrew the shell of [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] unscrews the shell of [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] unscrews the shell of [target]'s [parse_zone(target_zone)].</span>")
	tool.play_tool_sound(target)
	user?.mind.adjust_experience(/datum/skill/robotics, round(experience_given))
	return TRUE

/datum/surgery_step/mechanic_open/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE

	return TRUE

//close shell
/datum/surgery_step/mechanic_close
	name = "screw shell"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		TOOL_SCALPEL 			= 75,
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 24

/datum/surgery_step/mechanic_close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to screw the shell of [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] begins to screw the shell of [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] begins to screw the shell of [target]'s [parse_zone(target_zone)].</span>")

/datum/surgery_step/mechanic_close/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE

	return TRUE

//prepare electronics
/datum/surgery_step/prepare_electronics
	name = "prepare electronics"
	implements = list(
		TOOL_MULTITOOL = 100,
		TOOL_HEMOSTAT = 10) // try to reboot internal controllers via short circuit with some conductor
	time = 24

/datum/surgery_step/prepare_electronics/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to prepare electronics in [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] begins to work on electronics in [target]'s [parse_zone(target_zone)].</span>")

/datum/surgery_step/prepare_electronics/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You finish preparing electronics in [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] finishes preparing electronics in [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] finishing working on electronics in [target]'s [parse_zone(target_zone)].</span>")
	tool.play_tool_sound(target)
	user?.mind.adjust_experience(/datum/skill/robotics, round(experience_given))
	return TRUE

//unwrench
/datum/surgery_step/mechanic_unwrench
	name = "unwrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 10)
	time = 24

/datum/surgery_step/mechanic_unwrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to unwrench some bolts in [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)].</span>")

/datum/surgery_step/mechanic_unwrench/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	display_results(user, target, "<span class='notice'>You unwrench the bolts [target]'s [parse_zone(target_zone)]...</span>",
		"<span class='notice'>[user] unwrenches the bolts in [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] unwrenches the bolts [target]'s [parse_zone(target_zone)].</span>")
	tool.play_tool_sound(target)
	user?.mind.adjust_experience(/datum/skill/robotics, round(experience_given))
	return TRUE



//wrench
/datum/surgery_step/mechanic_wrench
	name = "wrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 10)
	time = 24

/datum/surgery_step/mechanic_wrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to wrench the bolts in [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] begins to wrench the bolts in [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] begins to wrench the bolts in [target]'s [parse_zone(target_zone)].</span>")

/datum/surgery_step/mechanic_wrench/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	display_results(user, target, "<span class='notice'>You wrench the bolts [target]'s [parse_zone(target_zone)]...</span>",
		"<span class='notice'>[user] wrenches the bolts in [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] wrenches the bolts [target]'s [parse_zone(target_zone)].</span>")
	tool.play_tool_sound(target)
	user?.mind.adjust_experience(/datum/skill/robotics, round(experience_given))
	return TRUE


//open hatch
/datum/surgery_step/open_hatch
	name = "open maintenance hatch"
	accept_hand = 1
	time = 10

/datum/surgery_step/open_hatch/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to open the hatch holders in [target]'s [parse_zone(target_zone)]...</span>",
		"<span class='notice'>[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)].</span>")

/datum/surgery_step/open_hatch/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	//if(target_zone == BODY_ZONE_CHEST)
		//SEND_SIGNAL(target, COMSIG_SILICON_OPEN_HATCH)
	display_results(user, target, "<span class='notice'>You open the maintenance hatch in [target]'s [parse_zone(target_zone)]...</span>",
		"<span class='notice'>[user] opens the maintenance hatch in [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] opens the maintenance hatch in [target]'s [parse_zone(target_zone)].</span>")
	user?.mind.adjust_experience(/datum/skill/robotics, round(experience_given))
	return TRUE

//disconnect electronics
/datum/surgery_step/disconnect_electronics
	name = "disconnect electronics"
	implements = list(TOOL_WIRECUTTER = 100, TOOL_MULTITOOL = 70, TOOL_SCALPEL = 10)
	time = 24

/datum/surgery_step/disconnect_electronics/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to disconnect wires in [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] begins to disconnect wires in [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] begins to work on electronics in [target]'s [parse_zone(target_zone)].</span>")


/datum/surgery_step/disconnect_electronics/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You finish disconnecting wires in [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] finishes disconnecting wires in [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] finishes working on electronics in [target]'s [parse_zone(target_zone)].</span>")
	tool.play_tool_sound(target)
	user?.mind.adjust_experience(/datum/skill/robotics, round(experience_given))
	return TRUE
