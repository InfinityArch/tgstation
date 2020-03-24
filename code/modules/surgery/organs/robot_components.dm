/obj/item/organ/silicon
	name = "robot component"
	icon = 'icons/obj/silicon_components.dmi'
	icon_state = "cyborg_upgrade"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC | ORGAN_SILICON
	var/power_state = POWER_STATE_OFF //power draw and heat production are multiplied by this
	var/serial_number = "" // the module code and serial number, used in various interfaces
	var/compact = TRUE // if false, this can only be installed into borgs
	var/base_power_load = 0 // how much power the component draws on life
	var/base_heat_load = 0 // how much heat the component generates on handle_environment (if it's powered)
	var/damage_failure_probability //when the component's damage is above this threshold, it will randomly shut off at this probability level

/obj/item/organ/silicon/proc/generate_serial_number(length = 8)
	serial_number += "-"
	for(var/i = 0, i < length, i++)
		serial_number += "[pick(0,1,2,3,4,5,6,7,8,9)]"

/obj/item/organ/silicon/Initialize()
	. = ..()
	generate_serial_number()

/obj/item/organ/silicon/on_life()
	if(organ_flags & ORGAN_FAILING)
		if(power_state)
			adjust_power_state(POWER_STATE_OFF)
			if(owner)
				to_chat(owner, "<span class='robot danger'>ALERT: Fatal error in [name] [serial_number], module is nonresponsive!")
		return ..()
	if(damage > low_threshold && damage_failure_probability && prob(damage_failure_probability * (damage > high_threshold ? 5 : 0)))
		adjust_power_state(POWER_STATE_OFF)
		if(owner)
			to_chat(owner, "<span class='robot danger'>ALERT: [name] [serial_number] has shut down after encountering an error!")
	. = ..()

/obj/item/organ/silicon/on_death()
	if(power_state)
		adjust_power_state(POWER_STATE_OFF)
	. = ..()

/obj/item/organ/silicon/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	SEND_SIGNAL(M, COMSIG_SILICON_COMPONENT_ADDED, src)

obj/item/organ/silicon/remove/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	SEND_SIGNAL(M, COMSIG_SILICON_COMPONENT_REMOVED, src)

obj/item/organ/silicon/proc/adjust_power_state(new_power_state = POWER_STATE_OFF)
	if(!owner)
		power_state = POWER_STATE_OFF
		return
	var/effective_battery_rating = 0
	var/obj/item/organ/silicon/battery/B = owner.getorganslot(ORGAN_SLOT_BATTERY)
	if(B)
		effective_battery_rating = B.battery_rating * B.power_state

	if((new_power_state == POWER_STATE_OFF) || new_power_state * base_power_load <= effective_battery_rating)
		power_state = new_power_state
		SEND_SIGNAL(owner, COMSIG_SILICON_COMPONENT_POWER_UPDATE)
		return TRUE

obj/item/organ/silicon/proc/get_power_state_string()
	switch(power_state)
		if(POWER_STATE_OFF)
			return "component offline"
		if(POWER_STATE_LOW)
			return "battery saver mode"
		if(POWER_STATE_NORMAL)
			return "normal mode"
		if(POWER_STATE_OVERDRIVE)
			return "performance mode"
	return "sys.power error: abnormal electrical activity detected!"


/obj/item/organ/silicon/battery
	name = "compact microbattery assembly"
	icon_state = "battery_assembly"
	var/icon_base = "battery_assembly"
	serial_number = "MB-C"
	organ_flags = ORGAN_SYNTHETIC | ORGAN_VITAL | ORGAN_SILICON
	desc = "A compact microbattery assembly capable of mounting a standard power cell."
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BATTERY
	base_heat_load = 10
	var/battery_rating
	var/update_timer = 0
	var/obj/item/stock_parts/cell/starting_cell
	var/obj/item/stock_parts/capacitor/starting_capacitor

	var/obj/item/stock_parts/cell/cell
	var/obj/item/stock_parts/capacitor/capacitor


/obj/item/organ/silicon/battery/Initialize()
	. = ..()
	if(starting_cell)
		insert_cell(new starting_cell)
	if(starting_capacitor)
		insert_capacitor(new starting_capacitor)
	low_threshold_passed = "<span class='robot danger'>SYSTEM ALERT: [src] reports reduced heat exchange with coolant system, unit may accumulate dangerous amounts of heat.</span>"
	low_threshold_cleared = "<span class='robot notice'>NOTICE: coolant circulation within [src] has been restored.</span>"

/obj/item/organ/silicon/battery/adjust_power_state(new_power_state = POWER_STATE_OFF)
	if(!owner)
		power_state = POWER_STATE_OFF
		return
	if((new_power_state == POWER_STATE_OFF) || cell && cell.charge)
		power_state = new_power_state
		SEND_SIGNAL(owner, COMSIG_SILICON_COMPONENT_POWER_UPDATE)
		return TRUE

/obj/item/organ/silicon/battery/on_life()
	if(update_timer < world.time)
		update_timer = world.time + 200
		update_icon()
	. = ..()

obj/item/organ/silicon/battery/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	update_icon()


obj/item/organ/silicon/battery/update_icon()
	icon_state = "[icon_base]"
	if(cell)
		icon_state += "-cell"
		if(cell.charge && cell.maxcharge)
			switch(cell.charge/cell.maxcharge)
				if(0.95 to INFINITY)
					icon_state  += "_100"
				if(0.75 to 0.95)
					icon_state += "_75"
				if(0.5 to 0.75)
					icon_state += "_50"
				if(0.25 to 0.5)
					icon_state += "_25"
				else
					icon_state += "_0"
		else
			icon_state += "_depleted"
	else
		icon_state = icon_base

/obj/item/organ/silicon/battery/proc/insert_cell(obj/item/stock_parts/cell/C, mob/living/user, silent = FALSE)
	if(user)
		user.temporarilyRemoveItemFromInventory(C, TRUE)
		playsound(user, 'sound/items/deconstruct.ogg', 50, TRUE)
	C.forceMove(src)
	cell = C
	if(user && !silent)
		to_chat(user, "<span class='notice'>You insert the [C] into the [src].</span>")
	update_icon()
	update_battery_rating()

/obj/item/organ/silicon/battery/proc/remove_cell(mob/living/user, silent = FALSE)
	var/obj/item/stock_parts/cell/C = cell
	if(user)
		user.put_in_hands(C)
		playsound(user, 'sound/items/crowbar.ogg', 50, TRUE)
		if(!silent)
			to_chat(user, "<span class='notice'>You remove [C] from [src].</span>")
	else if(owner)
		C.forceMove(owner.drop_location())
	else
		C.forceMove(drop_location())
	cell = null
	update_icon()
	update_battery_rating()

/obj/item/organ/silicon/battery/proc/insert_capacitor(obj/item/stock_parts/capacitor/C, mob/living/carbon/user, silent = FALSE)
	if(compact)
		if(user && !silent)
			to_chat(user, "<span class='caution'>[C] won't fit into [src]!</span>")
		return
	if(user)
		user.temporarilyRemoveItemFromInventory(C, TRUE)
		playsound(user, 'sound/items/deconstruct.ogg', 50, TRUE)
	C.forceMove(src)
	capacitor = C
	if(user && !silent)
		to_chat(user, "<span class='notice'>You insert [C] into [src].</span>")
	update_icon()
	update_battery_rating()

/obj/item/organ/silicon/battery/proc/remove_capacitor(mob/living/carbon/user, silent = FALSE)
	var/obj/item/stock_parts/capacitor/C = capacitor
	if(user)
		user.put_in_hands(C)
		playsound(user, 'sound/items/crowbar.ogg', 50, TRUE)
		if(!silent)
			to_chat(user, "<span class='notice'>You remove [C] from [src].</span>")
	else if(owner)
		C.forceMove(owner.drop_location())
	else
		C.forceMove(drop_location())
	cell = null
	update_icon()
	update_battery_rating()


/obj/item/organ/silicon/battery/proc/update_battery_rating()
	. = 0
	var/capacitor_rating = 1
	if(capacitor)
		capacitor_rating += capacitor.rating
	if(!cell || !cell.maxcharge)
		battery_rating = 0
		return
	switch(round(cell.maxcharge))
		if(1 to 5000)
			battery_rating = 10 * capacitor_rating
		if(5001 to 10000)
			battery_rating = 15 * capacitor_rating
		if(10001 to 20000)
			battery_rating = 20 * capacitor_rating
		if(20001 to INFINITY)
			battery_rating = 25 * capacitor_rating
	if(owner)
		SEND_SIGNAL(owner, COMSIG_SILICON_COMPONENT_BATTERY_UPDATE)
	return battery_rating

/obj/item/organ/silicon/battery/Destroy()
	if(cell)
		qdel(cell)
	if(capacitor)
		qdel(capacitor)
	. = ..()

/obj/item/organ/silicon/battery/get_cell()
	return cell

/obj/item/organ/silicon/battery/ipc //so ipcs spawn with a power cell
	starting_cell = /obj/item/stock_parts/cell/upgraded


/obj/item/organ/silicon/coolant_pump
	name = "compact cooling system"
	icon_state = "coolant_pump"
	serial_number = "CV-C"
	var/icon_base = "coolant_pump"
	organ_flags = ORGAN_SYNTHETIC | ORGAN_VITAL | ORGAN_SILICON
	desc = "A compact cooling system used by a robot to maintain a stable internal temperature.\
This cooler depends on convection for heat rejection, and won't work in a vacuum."
	base_power_load = 5
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_COOLANT_PUMP
	var/heat_rejection_capacity = 15

/obj/item/organ/silicon/coolant_pump/Initialize()
	. = ..()
	low_threshold_passed = "<span class='robot danger'>SYSTEM ALERT: Coolant flow through [src] is no longer stable, cooling performance may suffer.</span>"
	low_threshold_cleared = "<span class='robot notice'>NOTICE: Coolant flow through [src] is now stable, cooling performance is within tolernace.</span>"


obj/item/organ/silicon/coolant_pump/update_icon()
	if((power_state == POWER_STATE_OFF) || (organ_flags & ORGAN_FAILING))
		icon_state = "[icon_base]"
	else
		icon_state = "[icon_base]-on"


/obj/item/organ/silicon/coolant_pump/proc/get_cooling_capacity(pressure)
	var/cooling_efficiency = 0
	if(!power_state || (organ_flags & ORGAN_FAILING))
		return 0
	if(pressure)
		cooling_efficiency += min(pressure/ONE_ATMOSPHERE, 1)
	else
		return 0
	if(damage > low_threshold)
		cooling_efficiency *= 1 - (damage/maxHealth)
	if(owner && owner.blood_volume < BLOOD_VOLUME_SAFE)
		cooling_efficiency *= owner.blood_volume / BLOOD_VOLUME_NORMAL
	return round(cooling_efficiency * power_state * heat_rejection_capacity, DAMAGE_PRECISION)


/obj/item/organ/silicon/coolant_pump/radiator
	name = "compact radiative cooling system"
	icon_state = "coolant_pump_radiative"
	serial_number = "CRAD-C"
	desc = "A compact space rated cooling system used by a robot to maintain a stable internal temperature.\
This radiative cooler is inefficient and consumes a lot of power but will continue to function in a vacuum."
	base_power_load = 10
	heat_rejection_capacity = 10

/obj/item/organ/silicon/coolant_pump/radiator/get_cooling_capacity(pressure)
	var/cooling_efficiency = 0.5
	if(!power_state || (organ_flags & ORGAN_FAILING))
		return 0
	if(pressure)
		cooling_efficiency += min(pressure/ONE_ATMOSPHERE, 0.5)
	else
		return round(cooling_efficiency * power_state * heat_rejection_capacity, DAMAGE_PRECISION)
	if(damage > low_threshold)
		cooling_efficiency *= 1 - (damage/maxHealth)
	if(owner && owner.blood_volume < BLOOD_VOLUME_SAFE)
		cooling_efficiency *= owner.blood_volume / BLOOD_VOLUME_NORMAL
	return round(cooling_efficiency * power_state * heat_rejection_capacity, DAMAGE_PRECISION)


/obj/item/organ/silicon/upgrade
	name = "cyborg upgrade"
	icon_state = "module"
	serial_number = "G"
	compact = FALSE
	slot = ORGAN_SLOT_TORSO_UPGRADE
	desc = "a cyborg upgrade"

/obj/item/organ/silicon/upgrade/emp
	name = "EMP shielding"
	icon_state = "emp_shielding"
	serial_number = "EM"
	compact = TRUE
	desc = "A hardened conductive mesh that can protect the vital internal components of a robot from even the most intense electromagnetic pulses"

/obj/item/organ/silicon/upgrade/emp/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, .proc/add_organ_emp_protection)
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, .proc/remove_organ_emp_protection)
	for(var/obj/item/organ/O in owner.internal_organs)
		add_organ_emp_protection(O)

/obj/item/organ/silicon/upgrade/emp/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	UnregisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN)
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN)
	for(var/obj/item/organ/O in M.internal_organs)
		remove_organ_emp_protection(O)



/obj/item/organ/silicon/upgrade/emp/proc/add_organ_emp_protection(obj/item/organ/O)
	if((O.status != ORGAN_ROBOTIC) || (O.zone != BODY_ZONE_CHEST))
		return
	O.AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)


/obj/item/organ/silicon/upgrade/emp/proc/remove_organ_emp_protection(obj/item/organ/O)
	if((O.status != ORGAN_ROBOTIC) || (O.zone != BODY_ZONE_CHEST))
		return
	var/datum/component/empprotect = O.GetComponent(/datum/component/empprotection)
	if(empprotect)
		empprotect.RemoveComponent()

/obj/item/organ/silicon/upgrade/vtec
	name = "VTEC system"
	icon_state = "vtec"
	serial_number = "VT"
	compact = TRUE
	desc = "A set of advanced variable capacitors and servo motors. While very resource intensive, this module greatly enhances a robot's mobility."
	base_heat_load = 15
	base_power_load = 15
	damage_failure_probability = 0.01 // mean time to failure of 100 ticks, or 20 ticks if heavily damaged
	actions_types = list(/datum/action/item_action/organ_action/silicon/toggle)

/obj/item/organ/silicon/upgrade/vtec/adjust_power_state(new_power_state = POWER_STATE_OFF)
	. = ..()
	if(!owner)
		return
	switch(power_state)
		if(POWER_STATE_OFF)
			owner.remove_movespeed_modifier(MOVESPEED_ID_SILICON_VTEC)
			owner.clear_alert("vtec")
		if(POWER_STATE_LOW)
			owner.add_movespeed_modifier(/datum/movespeed_modifier/vtec)
			owner.throw_alert("vtec", /obj/screen/alert/vtec, 1)
		if(POWER_STATE_NORMAL)
			owner.add_movespeed_modifier(/datum/movespeed_modifier/vtec/full)
			owner.throw_alert("vtec", /obj/screen/alert/vtec, 2)
		else
			owner.add_movespeed_modifier(/datum/movespeed_modifier/vtec/overdrive)
			owner.throw_alert("vtec", /obj/screen/alert/vtec, 3)

/obj/item/organ/silicon/upgrade/vtec/ui_action_click()
	toggle()


obj/item/organ/silicon/upgrade/vtec/proc/toggle(silent = FALSE)
	// shutting off is simple
	if(power_state)
		adjust_power_state(POWER_STATE_OFF)
		if(!silent)
			to_chat(owner, "<span class='robot notice'>Shutting down [name] [serial_number]...</span>")
		return

	//turning it on is somewhat complicated...
	var/obj/item/organ/silicon/battery/B = owner.getorganslot(ORGAN_SLOT_BATTERY)
	var/effective_battery_rating = B.battery_rating * B.power_state
	if(!(B && B.cell && B.cell.charge > 500) || !effective_battery_rating)
		if(!silent)
			to_chat(owner, "<span class='robot danger'>ERROR: Unable to activate VTEC system, check status of on board electrical systems!</span>")
		return
	if(!silent)
		to_chat(owner, "<span class='robot notice'>Stand by, [name] [serial_number] warming up...</span>")
	if(do_after(owner, 50, target = owner, needhand= FALSE))
		if(power_state)
			return // prevents spamming of the button having consequences
		if(B.cell.use(500))
			switch(effective_battery_rating / base_power_load)
				if(POWER_STATE_NORMAL to INFINITY)
					adjust_power_state(POWER_STATE_NORMAL)
				else
					adjust_power_state(POWER_STATE_LOW)
			if(!silent)
				to_chat(owner, "<span class='robot notice'>[name] [serial_number] is now online and operating in [get_power_state_string()]!</span>")
		else
			if(!silent)
				to_chat(owner, "<span class='robot danger'>ERROR: charge in [B.cell.name] mounted in [B.name] [B.serial_number] is insufficient to complete operation, VTEC boot sequence aborted!</span>")
	else
		if(!silent)
			to_chat(owner, "<span class='robot notice'>VTEC boot sequence aborted.</span>")


/obj/item/organ/silicon/upgrade/vtec/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(power_state)
		adjust_power_state(power_state) // precaution against badminnery, this should never happen otherwise

/obj/item/organ/silicon/upgrade/vtec/Remove(mob/living/carbon/M, special = FALSE)
	if(power_state)
		adjust_power_state(POWER_STATE_OFF)
	. = ..()

/obj/item/organ/silicon/module
	name = "cyborg module"
	icon_state = "module"
	serial_number = "M"
	compact = FALSE
	slot = ORGAN_SLOT_TORSO_MODULE
	desc = "A cyborg module."

/obj/item/organ/silicon/module/arm
	name = "cyborg arm module"
	icon_state = "module_arm"
	serial_number = "MR"
	zone = BODY_ZONE_R_ARM
	name = "cyborg arm module"
	desc = "A cyborg arm module."
	var/obj/item/holder = null
	actions_types = list(/datum/action/item_action/organ_action/silicon/toggle)
	var/list/items_list = list()

/obj/item/organ/silicon/module/arm/Initialize()
	. = ..()
	if(ispath(holder))
		holder = new holder(src)

	update_icon()
	SetSlotFromZone()
	items_list = contents.Copy()

/obj/item/organ/silicon/module/arm/update_icon()
	if(zone == BODY_ZONE_R_ARM)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/silicon/module/arm/examine(mob/user)
	. = ..()
	. += "<span class='info'>[src] is assembled in the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.</span>"

/obj/item/organ/silicon/module/arm/Initialize()
	. = ..()

/obj/item/organ/silicon/module/arm/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	I.play_tool_sound(src)
	if(zone == BODY_ZONE_R_ARM)
		zone = BODY_ZONE_L_ARM
	else
		zone = BODY_ZONE_R_ARM
	SetSlotFromZone()
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>")
	update_icon()

/obj/item/organ/silicon/module/arm/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_ARM)
			slot = ORGAN_SLOT_LEFT_ARM_AUG
		if(BODY_ZONE_R_ARM)
			slot = ORGAN_SLOT_RIGHT_ARM_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/silicon/module/arm/proc/Extend(var/obj/item/item)
	if(!(item in src))
		return

	holder = item

	ADD_TRAIT(holder, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	holder.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	holder.slot_flags = null
	holder.set_custom_materials(null)

	if(istype(holder, /obj/item/assembly/flash))
		var/obj/item/assembly/flash/F = holder
		F.set_light(7)

	var/side = zone == BODY_ZONE_R_ARM? RIGHT_HANDS : LEFT_HANDS
	var/hand = owner.get_empty_held_index_for_side(side)
	if(hand)
		owner.put_in_hand(holder, hand)
	else
		var/list/hand_items = owner.get_held_items_for_side(side, all = TRUE)
		var/success = FALSE
		var/list/failure_message = list()
		for(var/i in 1 to hand_items.len) //Can't just use *in* here.
			var/I = hand_items[i]
			if(!owner.dropItemToGround(I))
				failure_message += "<span class='warning'>Your [I] interferes with [src]!</span>"
				continue
			to_chat(owner, "<span class='notice'>You drop [I] to activate [src]!</span>")
			success = owner.put_in_hand(holder, owner.get_empty_held_index_for_side(side))
			break
		if(!success)
			for(var/i in failure_message)
				to_chat(owner, i)
			return
	owner.visible_message("<span class='notice'>[owner] extends [holder] from [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='notice'>You extend [holder] from your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='hear'>You hear a short mechanical noise.</span>")
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/organ/silicon/module/arm/proc/Retract()
	if(!holder || (holder in src))
		return

	owner.visible_message("<span class='notice'>[owner] retracts [holder] back into [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='notice'>[holder] snaps back into your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='hear'>You hear a short mechanical noise.</span>")

	if(istype(holder, /obj/item/assembly/flash))
		var/obj/item/assembly/flash/F = holder
		F.set_light(0)

	owner.transferItemToLoc(holder, src, TRUE)
	holder = null
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/organ/silicon/module/arm/ui_action_click()
	if((organ_flags & ORGAN_FAILING) || (!holder && !contents.len))
		to_chat(owner, "<span class='robot danger'>ERROR: [name] [serial_number] is not responding!</span>")
		return

	if(!holder || (holder in src))
		holder = null
		if(contents.len == 1)
			Extend(contents[1])
		else
			var/list/choice_list = list()
			for(var/obj/item/I in items_list)
				choice_list[I] = image(I)
			var/obj/item/choice = show_radial_menu(owner, owner, choice_list)
			if(owner && owner == usr && owner.stat != DEAD && (src in owner.internal_organs) && !holder && (choice in contents))
				// This monster sanity check is a nice example of how bad input is.
				Extend(choice)
	else
		Retract()

/obj/item/organ/silicon/module/arm/Remove(mob/living/carbon/M, special = 0)
	Retract()
	. = ..()

/obj/item/organ/silicon/module/arm/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, "<span class='robot danger'>ERROR: Abnormal electrical activity detected in [name] [serial_number]!</span>")
		// give the owner an idea about why their module arm is bugging out
		Retract()

/obj/item/organ/silicon/module/arm/apc_charger
	name = "APC-compliant recharge port"
	icon_state = "resupply_port"
	serial_number = "MR-C-APC"
	desc = "An arm mounted port with a retractable cable for recharges on the go"
	compact = TRUE
	w_class = WEIGHT_CLASS_SMALL
	contents = newlist(/obj/item/apc_charger/cyborg)

/obj/item/apc_charger/cyborg
	name = "APC-compliant recharge cable"
	desc = "a retractible charging cable with a standard power connector compatible with APCs, PSUs, and power cells"
	icon = 'icons/obj/silicon_components.dmi'
	icon_state = "umbilical_line"
	item_state = "umbilical_line"
	lefthand_file = 'icons/mob/inhands/misc/cyborg_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/cyborg_righthand.dmi'
