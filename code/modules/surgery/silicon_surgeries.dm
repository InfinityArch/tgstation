#define MMI_MANIPULATION	"manipulate_mmi"
#define CELL_MANIPULATION	"manipulate_cell"
#define EXTRACT_COMPONENT	"extract_component"
#define INSTALL_COMPONENT	"install_component"



/datum/surgery/embedded_removal/silicon
	required_biotypes = MOB_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/remove_object,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery/cavity_implant/silicon
	required_biotypes = MOB_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/handle_cavity,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery/amputation/silicon
	name = "Limb removal"
	required_biotypes = MOB_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/disconnect_electronics,
		/datum/surgery_step/sever_limb/silicon,
		)

/datum/surgery_step/sever_limb/silicon
	name = "decouple limb"
	implements = list(TOOL_MULTITOOL = 100, TOOL_WELDER = 100)
	time = 64

/datum/surgery_step/sever_limb/silicon/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to decouple [target]'s [parse_zone(target_zone)]...</span>",
		"<span class='notice'>[user] begins to decouple [target]'s [parse_zone(target_zone)]!</span>",
		"<span class='notice'>[user] begins to decouple [target]'s [parse_zone(target_zone)]!</span>")

/datum/surgery_step/sever_limb/silicon/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/L = target
	display_results(user, target, "<span class='notice'>You decouple [L]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] decouples [L]'s [parse_zone(target_zone)]!</span>",
		"<span class='notice'>[user] decouples [L]'s [parse_zone(target_zone)]!</span>")
	if(surgery.operated_bodypart)
		var/obj/item/bodypart/target_limb = surgery.operated_bodypart
		target_limb.drop_limb()
	if(user.mind)
		user.mind.adjust_experience(/datum/skill/medical, experience_given)
	return TRUE

/datum/surgery/organ_manipulation/silicon
	name = "Internal component manipulation"
	possible_locs = list(BODY_ZONE_HEAD)
	requires_bodypart_type = BODYPART_ROBOTIC
	required_biotypes = MOB_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_components,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery/organ_manipulation/silicon/chest // this one will accept power cells and capacitors, and allows manipulation of the MMI if one is present
	name = "Internal component manipulation"
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = BODYPART_ROBOTIC
	required_biotypes = MOB_ROBOTIC
	var/mmi_exposed = FALSE
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_components/chest,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery/organ_manipulation/silicon/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	lying_required = FALSE
	self_operable = TRUE
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_components,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery_step/manipulate_components
	time = 64
	name = "manipulate components"
	repeatable = 1
	implements = list(/obj/item/organ = 100)
	var/implements_extract = list(TOOL_MULTITOOL = 100, TOOL_CROWBAR = 55)
	var/implements_mmi = list(TOOL_WIRECUTTER, TOOL_SCREWDRIVER)
	var/current_type
	var/obj/item/organ/I = null

/datum/surgery_step/manipulate_components/chest
	name = "manipulate components"
	implements = list(/obj/item/organ = 100, /obj/item/stock_parts/cell = 100, /obj/item/stock_parts/capacitor = 100)
	accept_hand = TRUE

/datum/surgery_step/manipulate_components/New()
	..()
	implements = implements + implements_extract + implements_mmi

/datum/surgery_step/manipulate_components/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	I = null
	if(surgery.mmi_exposed)
		return -1
		///current_type = "mmi"
		///if(handle_mmi(user, target, target_zone, obj/item/tool, datum/surgery/surgery, src))
			///return -1

	//if(!tool)
		//do stuff

	time = initial(time)
	var/obj/item/organ/silicon/battery/B = target.getorganslot(ORGAN_SLOT_BATTERY)
	if(!tool)
		if(!B)
			to_chat(user, "<span class='warning'>[target] is missing a battery assembly!</span>")
			return -1
		else if(!B.cell && !B.capacitor)
			to_chat(user, "<span class='warning'>There's no cell or capacitor in [B]!</span>")
			return -1
		else
			var/list/choices = list()
			var/selection
			if(B.cell)
				choices |= B.cell
			if(B.capacitor)
				choices |= B.capacitor
			if(choices.len > 1)
				selection = input("Remove which component from [B]?", "Battery Modification", null, null) as null|anything in selection
			else
				selection = choices[1]
			if(!selection)
				return -1
			if(istype(selection, /obj/item/stock_parts/cell))
				current_type = "remove_cell"
				time = 0
			else
				current_type = "remove_capacitor"
				time = 0
	else if(istype(tool, /obj/item/stock_parts/cell))
		if(!B)
			to_chat(user, "<span class='warning'>[target] is missing a battery assembly!</span>")
			return -1
		if(B.cell)
			to_chat(user, "<span class='warning'>There's already a [B.cell.name] installed in [B]!</span>")
			return -1
		current_type = "insert_cell"
		time = 0
	else if(istype(tool, /obj/item/stock_parts/capacitor))
		if(!B)
			to_chat(user, "<span class='warning'>[target] is missing a battery assembly!</span>")
			return -1
		if(B.capacitor)
			to_chat(user, "<span class='warning'>There's already a [B.cell.name] installed in [B]!</span>")
			return -1
		if(B.compact)
			to_chat(user, "<span class='warning'>[B] lacks a socket for a capacitor!</span>")
			return -1
		current_type = "insert_capacitor"
		time = 0
	else if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, "<span class='warning'>There is nothing inside [tool]!</span>")
			return -1
		I = tool.contents[1]
		if(!isorgan(I))
			to_chat(user, "<span class='warning'>You cannot put [I] into [target]'s [parse_zone(target_zone)]!</span>")
			return -1
		tool = I
	if(isorgan(tool))
		current_type = "insert_component"
		if(target_zone == BODY_ZONE_CHEST && B && B.cell)
			to_chat(user, "<span class='warning'>[B.cell] is blocking access to the internal wiring of [target]!</span>")
			return -1
		I = tool
		var/block_insert = TRUE
		if(I.organ_flags & ORGAN_SILICON)
			var/obj/item/organ/silicon/S = I
			if(ishuman(target))
				block_insert = S.compact
			else
				block_insert = TRUE
		else if(I.required_bodypart_status == BODYPART_ROBOTIC)
			block_insert = FALSE
		else if(istype(I, /obj/item/organ/external))
			var/obj/item/organ/external/OE = I
			if(OE.status == ORGAN_ROBOTIC)
				block_insert = FALSE

		if(block_insert)
			to_chat(user, "<span class='warning'>[I] isn't compatible with [target]'s systems!</span>")
			return -1
		if(target_zone != I.zone || target.getorganslot(I.slot))
			to_chat(user, "<span class='warning'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
			return -1
		if(istype(I, /obj/item/organ/silicon))
			var/obj/item/organ/silicon/S = I
			if(ishuman(target) && !S.compact)
				to_chat(user, "<span class='warning'>[I] can't be seated properly in [target]'s humanoid chassis!</span>")
				return -1

		//TODO: add a check for MMIs to see if they have a brain installed- InfinityArch

		display_results(user, target, "<span class='notice'>You begin to install [tool] into [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] begins to install [tool] into [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] begins to install something into [target]'s [parse_zone(target_zone)].</span>")

	else if(implement_type in implements_extract)
		current_type = "extract_component"
		if(target_zone == BODY_ZONE_CHEST && B && B.cell)
			to_chat(user, "<span class='warning'>[B.cell] is blocking access to the internal wiring of [target]!</span>")
			return -1
		var/list/organs = target.getorganszone(target_zone)
		if(!organs.len)
			to_chat(user, "<span class='warning'>There are no removable components in [target]'s [parse_zone(target_zone)]!</span>")
			return -1
		else
			for(var/obj/item/organ/O in organs)
				O.on_find(user)
				organs -= O
				if(!(O.organ_flags & ORGAN_ABSTRACT))
					organs[O.name] = O

			I = input("Remove which component?", "Surgery", null, null) as null|anything in sortList(organs)
			if(I && user && target && user.Adjacent(target) && user.get_active_held_item() == tool)
				I = organs[I]
				if(!I)
					return -1
				display_results(user, target, "<span class='notice'>You begin to remove [I] from [target]'s [parse_zone(target_zone)]...</span>",
					"<span class='notice'>[user] begins to remove [I] from [target]'s [parse_zone(target_zone)].</span>",
					"<span class='notice'>[user] begins to remove something from [target]'s [parse_zone(target_zone)].</span>")
			else
				return -1

/datum/surgery_step/manipulate_components/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	var/obj/item/organ/silicon/battery/B = target.getorganslot(ORGAN_SLOT_BATTERY)
	switch(current_type)
		if("insert_cell")
			if(B)
				B.insert_cell(tool, user, TRUE)
				display_results(user, target, "<span class='notice'>You insert [tool] into [target]'s [B].</span>",
				"<span class='notice'>[user] iserts [tool] into [target]'s [B]!</span>",
				"<span class='notice'>[user] inserts a power cell into [target]'s [parse_zone(target_zone)]!</span>")

		if("insert_capacitor")
			if(B)
				B.insert_capacitor(tool, user, TRUE)
				display_results(user, target, "<span class='notice'>You insert [tool] into [target]'s [B].</span>",
				"<span class='notice'>[user] inserts [tool] into [target]'s [B]!</span>",
				"<span class='notice'>[user] inserts a capacitor into [target]'s [parse_zone(target_zone)]!</span>")
		if("remove_cell")
			if(B)
				B.remove_cell(user, TRUE)
				display_results(user, target, "<span class='notice'>You remove [tool] from [target]'s [B].</span>",
				"<span class='notice'>[user] removes [tool] from [target]'s [B]!</span>",
				"<span class='notice'>[user] removes the power cell from [target]'s [parse_zone(target_zone)]!</span>")
		if("remove_capacitor")
			if(B)
				B.remove_capacitor(user, TRUE)
				display_results(user, target, "<span class='notice'>You remove [tool] from [target]'s [B].</span>",
				"<span class='notice'>[user] removes [tool] from [target]'s [B]!</span>",
				"<span class='notice'>[user] removes the capacitor from [target]'s [parse_zone(target_zone)]!</span>")

		if("insert_component")
			if(istype(tool, /obj/item/organ_storage))
				I = tool.contents[1]
				tool.icon_state = initial(tool.icon_state)
				tool.desc = initial(tool.desc)
				tool.cut_overlays()
				tool = I
			else
				I = tool
			user.temporarilyRemoveItemFromInventory(I, TRUE)
			I.Insert(target)
			display_results(user, target, "<span class='notice'>You install [tool] into [target]'s [parse_zone(target_zone)].</span>",
				"<span class='notice'>[user] installs [tool] into [target]'s [parse_zone(target_zone)]!</span>",
				"<span class='notice'>[user] installs something into [target]'s [parse_zone(target_zone)]!</span>")

		if("extract_component")
			if(I && I.owner == target)
				display_results(user, target, "<span class='notice'>You successfully removes [I] from [target]'s [parse_zone(target_zone)].</span>",
					"<span class='notice'>[user] successfully remove [I] from [target]'s [parse_zone(target_zone)]!</span>",
					"<span class='notice'>[user] successfully removes something from [target]'s [parse_zone(target_zone)]!</span>")
				log_combat(user, target, "surgically removed [I.name] from", addition="INTENT: [uppertext(user.a_intent)]")
				I.Remove(target)
				I.forceMove(get_turf(target))
			else
				display_results(user, target, "<span class='warning'>You can't remove anything from [target]'s [parse_zone(target_zone)]!</span>",
					"<span class='notice'>[user] can't seem to remove anything from [target]'s [parse_zone(target_zone)]!</span>",
					"<span class='notice'>[user] can't seem to remove anything from [target]'s [parse_zone(target_zone)]!</span>")
	return 0

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

/datum/surgery/brain_surgery/silicon/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B || !B.zone == BODY_ZONE_CHEST)
		return FALSE
	return TRUE

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
	target.setOrganLoss(ORGAN_SLOT_BRAIN, target.getOrganLoss(ORGAN_SLOT_BRAIN) - 60)
	var/cured_num = target.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	experience_given = 2*cured_num
	user?.mind.adjust_experience(/datum/skill/medical, round(experience_given))
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

/datum/surgery/eye_surgery/silicon
	name = "Optics repair"
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/fix_eyes/silicon,
		/datum/surgery_step/mechanic_close
		)
	target_mobtypes = list(/mob/living/carbon/human)
	lying_required = FALSE
	possible_locs = list(BODY_ZONE_PRECISE_EYES)
	required_biotypes = MOB_ROBOTIC

//fix eyes
/datum/surgery_step/fix_eyes/silicon
	name = "repair optics"
	implements = list(TOOL_MULTITOOL = 100)
	time = 64

/datum/surgery/eye_surgery/silicon/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/eyes/E = target.getorganslot(ORGAN_SLOT_EYES)
	if(!E)
		to_chat(user, "<span class='warning'>It's hard to perform repairs on a robot's optics when [target.p_they()] [target.p_do()]n't have any.</span>")
		return FALSE
	return TRUE

/datum/surgery_step/fix_eyes/silicon/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to perform repairs on [target]'s optics...</span>",
		"<span class='notice'>[user] begins to perform repairs [target]'s optics.</span>",
		"<span class='notice'>[user] begins to perform repairs on [target]'s optics.</span>")

/datum/surgery_step/fix_eyes/silicon/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/eyes/E = target.getorganslot(ORGAN_SLOT_EYES)
	user.visible_message("<span class='notice'>[user] successfully repairs [target]'s optics!</span>", "<span class='notice'>You succeed in fixing [target]'s eyes.</span>")
	display_results(user, target, "<span class='notice'>You succeed in repairing [target]'s optics.</span>",
		"<span class='notice'>[user] successfully repairs [target]'s optics!</span>",
		"<span class='notice'>[user] completes the repairs on [target]'s optics.</span>")
	target.cure_blind(list(EYE_DAMAGE))
	target.set_blindness(0)
	target.cure_nearsighted(list(EYE_DAMAGE))
	target.blur_eyes(35)	//this will fix itself slowly.
	E.setOrganDamage(0)
	return TRUE

/datum/surgery_step/fix_eyes/silicon/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>You accidentally misalign [target]'s optics.</span>",
		"<span class='warning'>[user] accidentally misaligns [target]'s optics.</span>",
		"<span class='warning'>[user] accidentally misaligns [target]'s optics.</span>")
	target.become_nearsighted(EYE_DAMAGE)
	target.blur_eyes(10)
	return FALSE
