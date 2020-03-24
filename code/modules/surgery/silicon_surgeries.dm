#define MMI_MANIPULATION	"manipulate_mmi"
#define MMI_ADD_PART		"add_mmi_part"
#define MMI_REMOVE_PART		"remove_mmi_part"
#define INSTALL_CELL		"install_cell"
#define REMOVE_CELL			"remove_cell"
#define INSTALL_CAPACITOR	"install_capacitor"
#define REMOVE_CAPACITOR	"remove_capacitor"
#define EXTRACT_COMPONENT	"extract_component"
#define INSTALL_COMPONENT	"install_component"
#define FIX_COMPONENT		"fix_component"



/datum/surgery/embedded_removal/silicon
	required_biotypes = MOB_ROBOTIC
	lying_required = FALSE
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/remove_object,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery/cavity_implant/silicon
	required_biotypes = MOB_ROBOTIC
	lying_required = FALSE
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
	lying_required = FALSE
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
		user.mind.adjust_experience(/datum/skill/robotics, experience_given)
	return TRUE

/datum/surgery/organ_manipulation/silicon
	name = "Internal component manipulation"
	possible_locs = list(BODY_ZONE_HEAD)
	requires_bodypart_type = BODYPART_ROBOTIC
	required_biotypes = MOB_ROBOTIC
	lying_required = FALSE
	var/mmi_exposed = FALSE
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
	var/implements_extract = list(TOOL_CROWBAR = 100)
	var/implements_mmi = list()
	var/implements_misc = list()
	var/current_type
	var/obj/item/organ/I = null // an organ to install or remove
	var/obj/item/robobrain_component/C = null // robobrain component
	var/obj/item/stock_parts/P = null // power cell or capacitor

/datum/surgery_step/manipulate_components/chest
	implements_mmi = list(TOOL_MULTITOOL = 100, TOOL_SCREWDRIVER = 100, TOOL_WIRECUTTER = 100)
	implements_misc = list(/obj/item/stock_parts/cell = 100, /obj/item/stock_parts/capacitor = 100, /obj/item/stack/nanopaste =100, /obj/item/stack/cable_coil = 100,
	 /obj/item/robobrain_component = 100, /obj/item/card/emag = 100, /obj/item/card/id = 100)
	accept_hand = TRUE


/datum/surgery_step/manipulate_components/New()
	..()
	implements = implements + implements_extract + implements_mmi + implements_misc

/datum/surgery_step/manipulate_components/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	//ever time preop is called we need to reset the surgery's time and the I, C, and P vars
	I = null
	C = null
	P = null
	time = initial(time)
	var/datum/surgery/organ_manipulation/silicon/OM = surgery
	var/mmi_exposed = OM.mmi_exposed

	if(mmi_exposed || (tool && implement_type == TOOL_SCREWDRIVER))
		current_type = MMI_MANIPULATION
		if(check_mmi_manipulation(user, target, target_zone, tool, surgery, mmi_exposed))
			return -1

	else if(!tool || istype(tool, /obj/item/stock_parts))
		if(check_cell_manipulation(user, target, target_zone, tool, surgery))
			return -1
	else if(istype(tool, /obj/item/stack))
		if(check_organ_fix(user, target, target_zone, tool, surgery))
			return -1
	else
		current_type = (implement_type in implements_extract) ? EXTRACT_COMPONENT : INSTALL_COMPONENT
		if(check_component_manipulation(user, target, target_zone, tool, surgery, current_type))
			return -1

// handles the checks for working with an mmi or positronic brain, returns FALSE when the surgery can proceed, otherwise sends error messages
/datum/surgery_step/manipulate_components/proc/check_mmi_manipulation(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, mmi_exposed)
	return TRUE

/datum/surgery_step/manipulate_components/chest/check_mmi_manipulation(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, mmi_exposed)
	. = TRUE
	var/obj/item/organ/silicon/battery/B = target.getorganslot(ORGAN_SLOT_BATTERY)
	if(B?.cell)
		to_chat(user, "<span class='warning'>[B.cell] is blocking access to [target]'s internal wiring!</span>")
		return

	var/obj/item/organ/brain/silicon/R = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!tool)
		if(!R)
			to_chat(user, "<span class='warning'>There is nothing installed in [target]'s positronic brain socket!</span>")
			return
		time = 0
		return FALSE

	if(istype(tool, /obj/item/stock_parts))
		if(B)
			to_chat(user, "<span class='warning'>The positronic brain socket's open hatch is blocking access to [B]!</span>")
		else
			to_chat(user, "<span class='warning'>[target] has no battery assembly installed!</span>")
		return

	if(implement_type == TOOL_SCREWDRIVER) //as long as the battery is out you're free to open and close the mmi socket to your heart's content
		time = 0
		return FALSE

	if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, "<span class='warning'>There is nothing inside [tool]!</span>")
			return
		I = tool.contents[1]
	else if(isorgan(tool))
		I = tool

	if(I)
		if(!istype(I, /obj/item/organ/brain/silicon))
			to_chat(user, "<span class='warning'>[I] won't fit into [target]'s positronic brain socket!</span>")
			return
		if(R)
			to_chat(user, "<span class='warning'>[R] is already installed in [target]'s positronic brain socket!</span>")
			return
		current_type = INSTALL_COMPONENT
		display_results(user, target, "<span class='notice'>You begin to install [I] into [target]'s positronic brain socket...</span>",
			"<span class='notice'>[user] begins to install [I] into [target]'s positronic brain socket.</span>",
			"<span class='notice'>[user] begins to install something into [target]'s [parse_zone(target_zone)].</span>")
		return FALSE

	if(!R)
		to_chat(user, "<span class='warning'>There is nothing installed in [target]'s positronic brain socket!</span>")
		return
	if(istype(R, /obj/item/organ/brain/silicon/mmi)) //additional check for MMIs to see if they have a brain
		var/obj/item/organ/brain/silicon/mmi/MMI = R
		if(!MMI.stored_brain)
			to_chat(user, "<span class='warning'>There is no brained installed in [R]!</span>")
			return
		if(!MMI.brainmob || (MMI.stored_brain.organ_flags & ORGAN_FAILING))
			to_chat(user, "<span class='warning'>The brain installed in [R] is nonfunctional!</span>")
			return

	if(istype(tool, /obj/item/stack))
		current_type = FIX_COMPONENT
		var/nanopaste = istype(tool, /obj/item/stack/cable_coil) ? FALSE : TRUE
		if(!R.damage && !(R.organ_flags & (ORGAN_FAILING|ORGAN_SYNTHETIC_EMP)))
			to_chat(user, "<span class='notice'>[R] is already in good condition.</span>")
			return
		if((R.organ_flags & ORGAN_FAILING) && !nanopaste)
			to_chat(user, "<span class='notice'>[R] is too damaged to repair with standard equipment!</span>")
			return
		if(nanopaste)
			display_results(user, target, "<span class='notice'>You begin applying nanopaste to the damaged electronics of [R]...</span>",
			"<span class='notice'>[user] begins applying nanopaste the damaged electronics of [R].</span>",
			"<span class='notice'>[user] begins to repair internal damage in [target]'s [parse_zone(target_zone)].</span>")
			time *= 0.25
		else
			display_results(user, target, "<span class='notice'>You begin repairing the damaged electronics of [R]...</span>",
			"<span class='notice'>[user] begins repairing the damaged electronics of [R].</span>",
			"<span class='notice'>[user] begins to repair internal damage in [target]'s [parse_zone(target_zone)].</span>")
		I = R
		return FALSE

	if(istype(tool, /obj/item/robobrain_component))
		current_type = MMI_ADD_PART
		C = tool
		if(!R.cover_open)
			to_chat(user, "<span class='warning'>You need to open [R]'s cover first!</span>")
			return
		for(var/obj/item/robobrain_component/RB in R.installed_components)
			if(RB.id == C.id)
				to_chat(user, "<span class='warning'>There is already \a [RB] installed in [R]!</span>")
				return
		time *= 0.5
		display_results(user, target, "<span class='notice'>You begin to install [tool] into [target]'s positronic brain socket...</span>",
			"<span class='notice'>[user] begins to install [tool] into [target]'s positronic brain socket.</span>",
			"<span class='notice'>[user] begins to install something into [target]'s [parse_zone(target_zone)].</span>")
		return FALSE

	if(istype(tool, /obj/item/card))
		time = 0
		return FALSE

	if(implement_type in implements_extract)
		var/list/removables = list(R)
		R.on_find(user)
		if(R.cover_open)
			for(var/obj/item/robobrain_component/RB in R.installed_components)
				if(RB.no_removal)
					continue
				removables += RB
		var/removal_target = input("What do you want to remove from [target]?", "Brain Socket Manipulation", null, null) as null|anything in removables
		if(!removal_target)
			return
		if(removal_target == R)
			time *= 2
			current_type = EXTRACT_COMPONENT
			I = R
		else
			time *= 0.5
			C = removal_target
			current_type = MMI_REMOVE_PART
		display_results(user, target, "<span class='notice'>You begin to remove [removal_target] from [target]'s positronic brain socket...</span>",
			"<span class='notice'>[user] begins to remove [removal_target] into [target]'s positronic brain socket.</span>",
			"<span class='notice'>[user] begins to remove something from [target]'s [parse_zone(target_zone)].</span>")
		return FALSE

//handles the check for installing/removing power cells or capacitors, and sets the correct type
/datum/surgery_step/manipulate_components/proc/check_cell_manipulation(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return TRUE

/datum/surgery_step/manipulate_components/chest/check_cell_manipulation(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = TRUE
	var/obj/item/organ/silicon/battery/B = target.getorganslot(ORGAN_SLOT_BATTERY)

	if(!B)
		to_chat(user, "<span class='warning'>[target] has no battery assembly installed!</span>")
		return

	if(!tool)
		var/list/removable_elements = list()
		if(B.cell)
			removable_elements += B.cell
		if(B.capacitor)
			removable_elements += B.capacitor
		if(!removable_elements.len)
			to_chat(user, "<span class='warning'>Nothing can be removed from [B]!</span>")
			return
		if(removable_elements.len > 1)
			P = input("Remove which component from [B]?", "Battery Modification", null, null) as null|anything in removable_elements
		else
			P = removable_elements[1]
		if(!P)
			return
		current_type = istype(P, /obj/item/stock_parts/capacitor) ? REMOVE_CAPACITOR : REMOVE_CELL
		time = 0
		return FALSE

	if(istype(tool, /obj/item/stock_parts))
		P = tool
		if(istype(P, /obj/item/stock_parts/capacitor))
			if(B.compact)
				to_chat(user, "<span class='warning'>[B] has no socket for a capacitor!</span>")
				return
			if(B.capacitor)
				to_chat(user, "<span class='warning'>[B] already has \a [B.capacitor] installed!</span>")
				return
			current_type = INSTALL_CAPACITOR
		else
			if(B.cell)
				to_chat(user, "<span class='warning'>[B] already has \a [B.cell] installed!</span>")
				return
			current_type = INSTALL_CELL
		time = 0
		return FALSE

/datum/surgery_step/manipulate_components/proc/check_component_manipulation(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, current_type)
	. = TRUE
	var/obj/item/organ/silicon/battery/B = target.getorganslot(ORGAN_SLOT_BATTERY)
	if(B?.cell)
		to_chat(user, "<span class='warning'>[B.cell] is blocking access to [target]'s internal wiring!</span>")
		return

	if(current_type == INSTALL_COMPONENT)
		if(isorgan(tool))
			I = tool
		else if(istype(tool, /obj/item/organ_storage))
			if(!tool.contents.len)
				to_chat(user, "<span class='warning'>There is nothing inside [tool]!</span>")
				return
			I = tool.contents[1]
		if(!istype(I))
			return
		if(I.zone != target_zone)
			to_chat(user, "<span class='warning'>There's no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
			return
		if(istype(I, /obj/item/organ/brain/silicon))
			to_chat(user, "<span class='warning'>The positronic brain socket must be open to install [I]!</span>")
			return
		if(!(I.organ_flags & (ORGAN_SILICON|ORGAN_SILICON_PERMITTED) || (I.status != ORGAN_ROBOTIC)))
			to_chat(user, "<span class='warning'>[I] isn't compatible with [target]'s systems!</span>")
			return
		if(!ishuman(target) && istype(I, /obj/item/organ/cyberimp)) // borgs can't get cyberimps, even if they have ORGAN_SILICON_PERMITTED
			to_chat(user, "<span class='warning'>[I] isn't compatible with [target]'s systems!</span>")
			return
		if(istype(I, /obj/item/organ/silicon))
			var/obj/item/organ/silicon/S = I
			if(ishuman(target) && !S.compact)
				to_chat(user, "<span class='warning'>[I] won't fit into [target]'s humanoid chassis!</span>")
				return
		var/obj/item/organ/blocker = target.getorganslot(I.slot)
		if(blocker)
			to_chat(user, "<span class='warning'>[target] already has \a [blocker] installed in their [parse_zone(target_zone)]!</span>")
			return
		display_results(user, target, "<span class='notice'>You begin to install [I] into [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] begins to install [I] into [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] begins to install something into [target]'s [parse_zone(target_zone)].</span>")
		return FALSE
	else
		var/list/organs = target.getorganszone(target_zone)
		var/list/selection = list()
		for(var/obj/item/organ/O in organs)
			O.on_find(user)
			if(istype(O, /obj/item/organ/brain/silicon) || (O.organ_flags & ORGAN_ABSTRACT))
				continue
			selection += O
		if(!selection.len)
			to_chat(user, "<span class='warning'>There are no removable components in [target]'s [parse_zone(target_zone)]!</span>")
			return
		I = input("Remove which component?", "Component Manipulation", null, null) as null|anything in sortList(selection)
		if(!I)
			return
		display_results(user, target, "<span class='notice'>You begin to remove [I] from [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] begins to remove [I] from [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] begins to remove something from [target]'s [parse_zone(target_zone)].</span>")
		return FALSE

/datum/surgery_step/manipulate_components/proc/check_organ_fix(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = TRUE
	current_type = FIX_COMPONENT
	var/list/organs = target.getorganszone(target_zone)
	var/list/selection = list()
	var/nanopaste = istype(tool, /obj/item/stack/cable_coil) ? FALSE : TRUE
	for(var/obj/item/organ/O in organs)
		O.on_find(user)
		if(istype(O, /obj/item/organ/brain/silicon) || (O.organ_flags & ORGAN_ABSTRACT))
			continue
		if(!O.damage && !(O.organ_flags & (ORGAN_FAILING|ORGAN_SYNTHETIC_EMP)))
			continue
		selection += O
	if(!selection.len)
		to_chat(user, "<span class='warning'>No components in [target]'s [parse_zone(target_zone)] are in need of repair.</span>")
		return
	I = I = input("Repair which component?", "Component Repair", null, null) as null|anything in sortList(selection)
	if(!I)
		return
	if((I.organ_flags & ORGAN_FAILING) && !nanopaste)
		to_chat(user, "<span class='warning'>[I] is too severely damaged to repair with standard equipment!</span>")
		return
	if(nanopaste)
		display_results(user, target, "<span class='notice'>You begin applying nanopaste to the damaged electronics of [I]...</span>",
		"<span class='notice'>[user] begins applying nanopaste the damaged electronics of [I].</span>",
		"<span class='notice'>[user] begins to repair internal damage in [target]'s [parse_zone(target_zone)].</span>")
		time *= 0.25
	else
		display_results(user, target, "<span class='notice'>You begin repairing the damaged electronics of [I]...</span>",
		"<span class='notice'>[user] begins repairing the damaged electronics of [I].</span>",
		"<span class='notice'>[user] begins to repair internal damage in [target]'s [parse_zone(target_zone)].</span>")
	return FALSE

/datum/surgery_step/manipulate_components/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	var/obj/item/organ/brain/silicon/RB = target.getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/silicon/battery/B = target.getorganslot(ORGAN_SLOT_BATTERY)
	var/datum/surgery/organ_manipulation/silicon/OM = surgery
	var/sanity_check_fired
	if(C && !RB) // sanity checks in case stuff got deleted while the surgery was running
		sanity_check_fired = TRUE
	if(P && !B)
		sanity_check_fired = TRUE
	if(!I && (current_type in list(INSTALL_COMPONENT, EXTRACT_COMPONENT, FIX_COMPONENT)))
		sanity_check_fired = TRUE
	if(sanity_check_fired)
		display_results(user, target, "<span class='warning'>WHAT!?</span>",
		"<span class='notice'>[user] looks confused.</span>",
		"<span class='notice'>[user] looks confused.</span>")
		return 0

	// if we have an organ, we play that thing's sound, otherwise we play the tool's sound
	if(I)
		I.play_tool_sound(target)
	else if(tool)
		tool.play_tool_sound(target)
	switch(current_type)
		if(MMI_MANIPULATION)
			if(implement_type == TOOL_SCREWDRIVER)
				OM.mmi_exposed = !OM.mmi_exposed
				display_results(user, target, "<span class='notice'>You [OM.mmi_exposed ? "expose [target]'s positronic brain socket" : "screw [target]'s positronic brain socket cover back into place"].</span>",
				"<span class='notice'>[user] [OM.mmi_exposed ? "exposes [target]'s positronic brain socket'" : "screws [target]'s positronic brain socket cover back into place"]!</span>",
				"<span class='notice'>[user] works on [target]'s [parse_zone(target_zone)] wth \a [tool]!</span>")

			else if(!RB)
				display_results(user, target, "<span class='warning'>WHAT!?</span>",
				"<span class='notice'>[user] looks confused.</span>",
				"<span class='notice'>[user] looks confused.</span>")
				return 0
			else if(!tool)
				RB.attack_self(user)
			else if(istype(tool, /obj/item/card))
				if(istype(tool, /obj/item/card/emag))
					RB.emag_act(user)
				else
					RB.id_scan(tool, user)
		if(MMI_ADD_PART)
			C.install(RB, user)
			display_results(user, target, "<span class='notice'>You install [C] into [target]'s [RB]...</span>",
			"<span class='notice'>[user] installs [C] into [target]'s [RB].</span>",
			"<span class='notice'>[user] inserts something small into [target]'s [parse_zone(target_zone)].</span>")
		if(MMI_REMOVE_PART)
			C.uninstall(user, TRUE)
			display_results(user, target, "<span class='notice'>You uninstall [C] from [target]'s [RB]...</span>",
			"<span class='notice'>[user] installs [C] into [target]'s [RB].</span>",
			"<span class='notice'>[user] removes something small from [target]'s [parse_zone(target_zone)].</span>")
		if(INSTALL_CELL)
			B.insert_cell(P, user, TRUE)
			display_results(user, target, "<span class='notice'>You insert [tool] into [target]'s [B].</span>",
			"<span class='notice'>[user] iserts [tool] into [target]'s [B]!</span>",
			"<span class='notice'>[user] inserts something small into [target]'s [parse_zone(target_zone)]!</span>")
		if(INSTALL_CAPACITOR)
			B.insert_capacitor(P, user, TRUE)
			display_results(user, target, "<span class='notice'>You insert [tool] into [target]'s [B].</span>",
			"<span class='notice'>[user] inserts [tool] into [target]'s [B]!</span>",
			"<span class='notice'>[user] inserts something small into [target]'s [parse_zone(target_zone)]!</span>")
		if(REMOVE_CELL)
			display_results(user, target, "<span class='notice'>You remove [B.cell] from [target]'s [B].</span>",
			"<span class='notice'>[user] removes [B.cell] from [target]'s [B]!</span>",
			"<span class='notice'>[user] removes something small from [target]'s [parse_zone(target_zone)]!</span>")
			B.remove_cell(user, TRUE)
		if(REMOVE_CAPACITOR)
			display_results(user, target, "<span class='notice'>You remove [B.capacitor] from [target]'s [B].</span>",
			"<span class='notice'>[user] removes [B.capacitor] from [target]'s [B]!</span>",
			"<span class='notice'>[user] removes something small from [target]'s [parse_zone(target_zone)]!</span>")
			B.remove_capacitor(user, TRUE)
		if(INSTALL_COMPONENT)
			user.temporarilyRemoveItemFromInventory(I, TRUE)
			I.Insert(target)
			playsound(target, 'sound/items/deconstruct.ogg', 50, TRUE)
			display_results(user, target, "<span class='notice'>You successfully install [tool] into [target]'s [parse_zone(target_zone)].</span>",
				"<span class='notice'>[user] successfully installs [tool] into [target]'s [parse_zone(target_zone)]!</span>",
				"<span class='notice'>[user] successfully installs something into [target]'s [parse_zone(target_zone)]!</span>")
		if(EXTRACT_COMPONENT)
			if(I.owner == target) // sanity check against organ removal while the surgery was running
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
		if(FIX_COMPONENT)
			var/obj/item/stack/repair_item = tool
			var/nanopaste = istype(repair_item, /obj/item/stack/cable_coil) ? FALSE : TRUE
			var/damage_to_fix = nanopaste ? 30 : 15
			I.applyOrganDamage(-damage_to_fix)
			repair_item.use(1)
			if(nanopaste)
				I.organ_flags &= ~ORGAN_SYNTHETIC_EMP
				display_results(user, target, "<span class='warning'>You finish applying some nanopaste to [I].</span>",
				"<span class='notice'>[user] finishes applying nanopaste to [target]'s [I].</span>",
				"<span class='notice'>[user] finishes repairing internal damage in [target]'s [parse_zone(target_zone)].</span>")
			else
				display_results(user, target, "<span class='warning'>You finish repairing [I]'s damaged electronics.</span>",
				"<span class='notice'>[user] finishes repairing [I]'s damaged electronics.</span>",
				"<span class='notice'>[user] finishes repairing internal damage in [target]'s [parse_zone(target_zone)].</span>")

	return 0

/datum/surgery/brain_surgery/silicon
	name = "Synthetic brain repair"
	possible_locs = list(BODY_ZONE_CHEST)
	lying_required = FALSE
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
	var/obj/item/organ/brain/silicon/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B || !B.zone == BODY_ZONE_CHEST)
		return FALSE
	if(B.damage || (B.traumas && B.traumas.len >= 1))
		return TRUE
	if(B.special_laws && ((B.special_laws.hacked.len >= 1) || (B.special_laws.ion.len >= 1)))
		return TRUE
	if(B.obj_flags & EMAGGED)
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
	target.setOrganLoss(ORGAN_SLOT_BRAIN, target.getOrganLoss(ORGAN_SLOT_BRAIN) - 60)
	var/cured_num = target.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	experience_given = 2*cured_num
	user?.mind.adjust_experience(/datum/skill/robotics, round(experience_given))
	var/obj/item/organ/brain/silicon/S = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(istype(S) && !(S.special_laws.is_empty_laws()))
		S.special_laws.clear_ion_laws()
		S.special_laws.clear_hacked_laws()
		if(S.obj_flags & EMAGGED)
			S.clear_emag()
		S.update_laws()
	return TRUE

/datum/surgery_step/fix_brain/silicon/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		display_results(user, target, "<span class='warning'>You screw up, causing more damage!</span>",
			"<span class='warning'>[user] screws up, severely damaging the [target.getorganslot(ORGAN_SLOT_BRAIN)]!</span>",
			"<span class='notice'>[user] completes the work on [target]'s [target.getorganslot(ORGAN_SLOT_BRAIN)].</span>")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
		var/obj/item/organ/brain/silicon/S = target.getorganslot(ORGAN_SLOT_BRAIN)
		if(istype(S)) //LAW #$%: CAPTAIN IS COMDOM! LAW %*#: MIMES ARE FOOD! LAW 9*$ THE CAPTAIN IS A MIME!
			S.emp_act(3)
		else
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
	if(!E.damage)
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
	user?.mind.adjust_experience(/datum/skill/robotics, round(experience_given))
	target.cure_blind(list(EYE_DAMAGE))
	target.set_blindness(0)
	target.cure_nearsighted(list(EYE_DAMAGE))
	target.blur_eyes(35)	//this will fix itself slowly.
	E.setOrganDamage(0)
	return TRUE

/datum/surgery_step/fix_eyes/silicon/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>You accidentally misalign [target]'s optics.</span>",
		"<span class='warning'>[user] accidentally misaligns [target]'s optics.</span>",
		"<span class='notice'>[user] completes the repairs on [target]'s optics.</span>")
	target.become_nearsighted(EYE_DAMAGE)
	target.blur_eyes(10)
	return FALSE

/datum/surgery/prosthetic_replacement/silicon
	name = "Limb Installation"
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/add_prosthetic/silicon,
		/datum/surgery_step/mechanic_close
		)
	target_mobtypes = list(/mob/living/carbon/human)
	lying_required = FALSE
	required_biotypes = MOB_ROBOTIC


/datum/surgery_step/add_prosthetic/silicon
	name = "install limb"

/datum/surgery_step/add_prosthetic/silicon/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, "<span class='warning'>There is nothing inside [tool]!</span>")
			return -1
		var/obj/item/I = tool.contents[1]
		if(!isbodypart(I))
			to_chat(user, "<span class='warning'>[I] cannot be attached!</span>")
			return -1
		tool = I
	if(istype(tool, /obj/item/bodypart))
		var/obj/item/bodypart/BP = tool
		if(BP.is_organic_limb() || BP.animal_origin)
			to_chat(user, "<span class='warning'>[BP] isn't compatible with [target]'s system.</span>")
			return -1
	. = ..()

#undef MMI_MANIPULATION
#undef MMI_ADD_PART
#undef MMI_REMOVE_PART
#undef INSTALL_CELL
#undef REMOVE_CELL
#undef INSTALL_CAPACITOR
#undef REMOVE_CAPACITOR
#undef EXTRACT_COMPONENT
#undef INSTALL_COMPONENT
#undef FIX_COMPONENT
