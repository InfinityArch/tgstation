/datum/species/ipc
	name = "Integrated Robotic Chassis"
	id = "ipc"
	say_mod = "states"
	naming_convention = NAME_NUM
	names_id = "human"
	species_traits = list(NOHEART,NOZOMBIE,NOTRANSSTING, NO_DNA_COPY, NOSTOMACH, TORSO_BRAIN, EYECOLOR, HAIR, FACEHAIR, MUTCOLORS, LIPS)
	inherent_traits = list(TRAIT_NOMETABOLISM,TRAIT_TOXIMMUNE,TRAIT_NOBREATH,
							TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,
							TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOHARDCRIT,
							TRAIT_SLEEPIMMUNE, TRAIT_EASYLIMBDISABLE, TRAIT_RESISTHEATHANDS,
							TRAIT_XENO_IMMUNE, TRAIT_NOPAIN, TRAIT_NOSOFTCRIT, TRAIT_RESISTLOWPRESSURE)
	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	meat = null
	//gib_type
	exotic_blood = /datum/reagent/fuel/oil
	damage_overlay_type = "robotic"
	mutanttongue = /obj/item/organ/tongue/robot/silicon
	mutanteyes = /obj/item/organ/eyes/silicon
	mutantears = /obj/item/organ/external/ears/silicon
	mutantbrain = /obj/item/organ/brain/silicon
	feature_names = list("horns" = "head accessory (top)", "frills" = "head accessory (sides)")
	mutant_bodyparts = list("horns")//,"frills")
	default_features = list("mcolor" = "FFF", "horns" = "None")//, "frills" = "None")
	species_hud = "ipc"
	speedmod = 2 // as slow as golems
	age_min = 1
	age_max = 394
	mutant_organs = list(/obj/item/organ/silicon/battery/ipc, /obj/item/organ/silicon/coolant_pump, /obj/item/organ/silicon/module/arm/apc_charger)
	quirk_budget = 0 //ipcs don't get quirk points
	limbs_id = "human" // ipcs with android parts will use human hair and limb styles
	features_id = "robotic" //but their roundstart mutant bodypart selection is limited to robotic features
	changesource_flags = MIRROR_BADMIN | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN
	species_language_holder = /datum/language_holder/ipc
	limb_customization_type = LIMB_CUSTOMIZATION_FULL
	var/power_load = 0
	var/heat_load = 0
	var/list/power_consumers = list()
	var/safe_start = FALSE // set to true when vital internal organs are removed; note that the posibrain/mmi is not actually vital.
	var/static_power_update_delay = 20
	var/datum/action/innate/toggle_sleep_mode/sleep_mode_toggle
	//var/obj/screen/battery_display/battery_hud
	var/voluntary_sleepmode // if they're in in sleep mode of its own volition, skips power handling procs
	var/charging // if we've recieved any recharging this update

/datum/species/ipc/on_species_gain(mob/living/carbon/C)
	RegisterSignal(C, COMSIG_SILICON_COMPONENT_ADDED, .proc/insert_component)
	RegisterSignal(C, COMSIG_SILICON_COMPONENT_REMOVED, .proc/remove_component)
	RegisterSignal(C, COMSIG_SILICON_COMPONENT_BATTERY_UPDATE, .proc/update_battery)
	RegisterSignal(C, COMSIG_SILICON_COMPONENT_POWER_UPDATE, .proc/update_power)
	RegisterSignal(C, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, .proc/charge)
	RegisterSignal(C, COMSIG_HANDLE_APC_RECHARGING, .proc/handle_apc_charging)
	RegisterSignal(C, COMSIG_SILICON_TOGGLE_SLEEP_MODE, .proc/toggle_sleep_mode)
	. = ..()

	//ipcs appear on diagnostic hud, not health hud
	var/image/stat_holder = C.hud_list[STATUS_HUD]
	var/image/health_holder = C.hud_list[HEALTH_HUD]
	stat_holder.icon_state = null
	health_holder.icon_state = null
	for(var/datum/atom_hud/data/diagnostic/D in GLOB.huds)
		D.add_to_hud(C)


	C.bubble_icon = "robot"
	sleep_mode_toggle = new
	//battery_hud = new
	//C.infodisplay += battery_hud
	sleep_mode_toggle.Grant(C)
	if(C.loc && ishuman(C))
		var/mob/living/carbon/human/H = C
		handle_heat_load(H.calculate_affecting_pressure(H.loc.return_air()), H, FALSE)
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.is_organic_limb())
			if(BP.body_zone == BODY_ZONE_HEAD)
				BP.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE, AUG_STYLE_DEFAULT, AUG_TYPE_MONITOR)
			else
				BP.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE, AUG_STYLE_DEFAULT)


/datum/species/ipc/on_species_loss(mob/living/carbon/C)
	UnregisterSignal(C, COMSIG_SILICON_COMPONENT_ADDED)
	UnregisterSignal(C, COMSIG_SILICON_COMPONENT_REMOVED)
	UnregisterSignal(C, COMSIG_SILICON_COMPONENT_POWER_UPDATE)
	UnregisterSignal(C, COMSIG_SILICON_COMPONENT_BATTERY_UPDATE)
	UnregisterSignal(C, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(C, COMSIG_HANDLE_APC_RECHARGING)
	UnregisterSignal(C, COMSIG_SILICON_TOGGLE_SLEEP_MODE)
	C.clear_alert("overheating")
	C.clear_alert("charge")
	C.bubble_icon = initial(C.bubble_icon)
	var/image/stat_holder = C.hud_list[DIAG_STAT_HUD]
	var/image/health_holder = C.hud_list[DIAG_HUD]
	var/image/battery_holder = C.hud_list[DIAG_BATT_HUD]
	stat_holder.icon_state = null
	health_holder.icon_state = null
	battery_holder.icon_state = null
	for(var/datum/atom_hud/data/diagnostic/D in GLOB.huds)
		D.remove_from_hud(C)

	sleep_mode_toggle.Remove(C)
	QDEL_NULL(sleep_mode_toggle)

	. = ..()
	var/datum/status_effect/incapacitating/sleep_mode/S = C.has_status_effect(STATUS_EFFECT_SLEEPMODE)
	if(S)
		qdel(S)
	var/datum/status_effect/cyborg_power_regen/RC = C.has_status_effect(STATUS_EFFECT_POWERREGEN)
	if(RC)
		qdel(RC)
	for(var/Y in C.internal_organs) // remove any aftermarket silicon components
		var/obj/item/organ/O = Y
		if(O.gc_destroyed)
			continue
		if(O.organ_flags & ORGAN_SILICON)
			O.Remove(C, TRUE)
			if(C.drop_location())
				O.forceMove(C.drop_location())
			else
				qdel(O)
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.no_update) // aftermarket parts won't be flipped back to organic
			continue
		BP.change_bodypart_status(BODYPART_ORGANIC, FALSE, TRUE)

/datum/species/ipc/spec_life(mob/living/carbon/human/H)
	if(H.stat != DEAD)
		if(static_power_update_delay > world.time || voluntary_sleepmode)
			return
		else
			static_power_update_delay = world.time + 20
			var/datum/status_effect/incapacitating/sleep_mode/S = H.has_status_effect(STATUS_EFFECT_SLEEPMODE)
			if(handle_power(H))
				update_power_icons(H)
				if(S)
					toggle_sleep_mode(H)
					H.update_mobility()
				return
			else if(!S)
				toggle_sleep_mode(H)
				H.update_mobility()
			update_power_icons(H)

/datum/species/ipc/spec_death(gibbed, mob/living/carbon/human/H)
	if(H.health > H.crit_threshold)
		safe_start = gibbed ? FALSE : TRUE
	H.clear_alert("charge")
	H.clear_alert("overheating")
	var/datum/status_effect/incapacitating/sleep_mode/S = H.has_status_effect(STATUS_EFFECT_SLEEPMODE)
	if(S && !S.gc_destroyed)
		qdel(S)

datum/species/ipc/handle_blood(mob/living/carbon/human/H)
	. = ..()
	if(H.stat != DEAD)
		if(H.blood_volume < BLOOD_VOLUME_SAFE)
			H.add_movespeed_modifier(MOVESPEED_ID_SILICON_LEAKING, override = TRUE, multiplicative_slowdown = 1 / max(0.2, H.blood_volume/BLOOD_VOLUME_NORMAL), blacklisted_movetypes = FLOATING)
		else
			H.remove_movespeed_modifier(MOVESPEED_ID_SILICON_LEAKING)

/datum/species/ipc/spec_updatehealth(mob/living/carbon/human/H)
	if(!(H.status_flags & GODMODE) && H.stat != DEAD)
		if(H.health <= H.crit_threshold)
			H.death() //ipcs die at 0 HP instead of going into crit
			H.cure_blind(UNCONSCIOUS_BLIND)

/datum/species/ipc/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, forced = FALSE, spread_damage = FALSE)
	. = ..()
	if(. && H.stat != DEAD && (H.health < 0.5 * H.getMaxHealth()) && damagetype == BRUTE)// && prob(CLAMP(damage, 10, 60)))
		do_sparks(5, FALSE, H)

/datum/species/ipc/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/H)
	bodytemp_normal = environment ? handle_heat_load(environment, H) : initial(bodytemp_normal)
	if(H.stat != DEAD)
		if(isspaceturf(H.loc))
			H.adjust_bodytemperature(natural_bodytemperature_stabilization(H))
			return handle_body_temperature(H)
	. = ..()

/datum/species/ipc/natural_bodytemperature_stabilization(mob/living/carbon/human/H, overheat = FALSE)
	if(bodytemp_normal > bodytemp_heat_damage_limit)
		var/body_temperature_difference = bodytemp_normal - H.bodytemperature
		return max((body_temperature_difference * H.metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR), \
			min(body_temperature_difference, bodytemp_autorecovery_min))
	. = ..()

/datum/species/ipc/handle_body_temperature(mob/living/carbon/human/H)
	bodytemp_normal = initial(bodytemp_normal)
	. = ..()



/datum/species/ipc/proc/handle_heat_load(datum/gas_mixture/environment, mob/living/carbon/human/H, send_notifications = TRUE)
	. = BODYTEMP_NORMAL
	if(!environment || !heat_load || H.stat == DEAD)
		return
	var/cooling_capacity = 0
	var/obj/item/organ/silicon/coolant_pump/CP = H.getorganslot(ORGAN_SLOT_COOLANT_PUMP)

	// calculate the initial cooling capacity based on the current situation
	if(CP)
		var/report
		cooling_capacity = CP.get_cooling_capacity(H.calculate_affecting_pressure(environment.return_pressure()))
		if(cooling_capacity || !(CP.power_state))
			while(heat_load > cooling_capacity && CP.power_state < POWER_STATE_OVERDRIVE)
				if(CP.adjust_power_state(clamp(CP.power_state * 2, POWER_STATE_LOW, POWER_STATE_OVERDRIVE)))
					report = " to compensate for excess heat accumulation.</span>"
					cooling_capacity = CP.get_cooling_capacity(H.calculate_affecting_pressure(environment.return_pressure()))
				else
					break
			while(heat_load * 2 <= cooling_capacity && CP.power_state > POWER_STATE_LOW)
				if(CP.adjust_power_state(clamp(CP.power_state * 0.5, POWER_STATE_LOW, POWER_STATE_OVERDRIVE)))
					report = " to reduce power consumption.</span>"
					cooling_capacity = CP.get_cooling_capacity(H.calculate_affecting_pressure(environment.return_pressure()))
				else
					break
			if(report && send_notifications)
				to_chat(H, "<span class='robot notice'>NOTICE: [CP.name] [CP.serial_number] has automatically switched to \
	[CP.get_power_state_string()]" + report)

	// calculate the amount of excess heat we're generating, and throw an alert if necessary
	. += clamp(SILICON_HEAT_LOAD_FACTOR * (heat_load - cooling_capacity), 0, 100)
	if(. > BODYTEMP_NORMAL)
		if(. > BODYTEMP_HEAT_DAMAGE_LIMIT)
			H.throw_alert("overheating", /obj/screen/alert/overheat, 2)
		else
			H.throw_alert("overheating", /obj/screen/alert/overheat, 1)
	else
		H.clear_alert("overheating")


// called when a component is inserted
/datum/species/ipc/proc/insert_component(mob/living/carbon/C, obj/item/organ/silicon/S)
	if(S.organ_flags & ORGAN_VITAL)
		var/obj/item/organ/silicon/battery/B = C.getorganslot(ORGAN_SLOT_BATTERY)
		var/obj/item/organ/silicon/coolant_pump/CP = C.getorganslot(ORGAN_SLOT_COOLANT_PUMP)
		if(C.stat == DEAD && safe_start && check_safe_start(C))
			safe_start = FALSE
			C.revive(full_heal = FALSE, admin_revive = FALSE)
		if(B && CP)
			if(C.stat != DEAD)
				if(B.cell && B.cell.charge)
					B.adjust_power_state(POWER_STATE_NORMAL)
				else if(!(C.has_status_effect(STATUS_EFFECT_SLEEPMODE)))
					toggle_sleep_mode(C)

	LAZYCLEARLIST(power_consumers)
	for(var/obj/item/organ/silicon/R in C.internal_organs)
		if(!istype(R))
			continue
		if(R.base_power_load || R.base_heat_load)
			power_consumers |= R
	update_power(C)
	if(C.loc)
		var/mob/living/carbon/human/H = C
		handle_heat_load(H.calculate_affecting_pressure(H.loc.return_air()), H, FALSE)

// called when a component is removed.
/datum/species/ipc/proc/remove_component(mob/living/carbon/C, obj/item/organ/silicon/S)
	var/update_vitals
	if(S.organ_flags & ORGAN_VITAL)
		voluntary_sleepmode = FALSE
		update_vitals = TRUE
	LAZYCLEARLIST(power_consumers)
	for(var/obj/item/organ/silicon/R in C.internal_organs)
		if(!istype(R))
			continue
		if(R.base_power_load || R.base_heat_load)
			power_consumers |= R
			if(update_vitals)
				R.adjust_power_state(POWER_STATE_OFF)

	update_power(C)
	if(C.loc)
		var/mob/living/carbon/human/H = C
		handle_heat_load(H.calculate_affecting_pressure(H.loc.return_air()), H, FALSE)

//called when battery rating is changed, for ipcs this will only occur if a cell or removed or via badminnery
/datum/species/ipc/proc/update_battery(mob/living/carbon/C)
	if(voluntary_sleepmode)
		return
	var/obj/item/organ/silicon/battery/B = C.getorganslot(ORGAN_SLOT_BATTERY)
	if(B.cell && B.cell.charge && C.getorganslot(ORGAN_SLOT_COOLANT_PUMP))
		var/datum/status_effect/incapacitating/sleep_mode/S = C.has_status_effect(STATUS_EFFECT_SLEEPMODE)
		if(S && S.duration > world.time)
			toggle_sleep_mode(C)
		else
			B.adjust_power_state(POWER_STATE_NORMAL)

	var/report

	for(var/obj/item/organ/silicon/S in power_consumers)
		if(S.organ_flags & ORGAN_VITAL)
			continue
		report = null
		while(S.power_state && (S.power_state * S.base_power_load > B.battery_rating * B.power_state))
			if(S.power_state > POWER_STATE_LOW && S.adjust_power_state(S.power_state * 0.5))
				report = TRUE
			else
				S.adjust_power_state(POWER_STATE_OFF)
				report = TRUE
				break
		if(report)
			to_chat(C, "<span class='robot danger'>WARNING: [S.name] [S.serial_number] has \
[S.power_state ? "switched to [S.get_power_state_string()]" : "shut down automatically"] due to a reduction in the capacity of [B.name] [B.serial_number]!</span>")

//called whenever an organ
/datum/species/ipc/proc/update_power(mob/living/carbon/C)
	power_load = 0
	heat_load = 0
	for(var/obj/item/organ/silicon/S in power_consumers)
		power_load += S.power_state * S.base_power_load
		heat_load += S.power_state * S.base_heat_load

/datum/species/ipc/proc/handle_power(mob/living/carbon/C)
	if(C.key && !C.client)
		return
	if(!C.getorganslot(ORGAN_SLOT_BRAIN)) //the brain isn't a vital organ for silicons, they just go into standby mode
		return
	var/obj/item/organ/silicon/battery/B = C.getorganslot(ORGAN_SLOT_BATTERY)
	var/obj/item/organ/silicon/coolant_pump/CP = C.getorganslot(ORGAN_SLOT_COOLANT_PUMP)
	if(!(B && B.cell && B.cell.charge && CP))
		return
	if(!B.power_state && !B.adjust_power_state(POWER_STATE_NORMAL))
		return
	if(((B.organ_flags|CP.organ_flags) & ORGAN_FAILING) || (min(CP.power_state, POWER_STATE_LOW) * CP.base_power_load > B.battery_rating * B.power_state))
		return
	if(B.cell.use(power_load))
		return TRUE
	for(var/obj/item/organ/silicon/S in power_consumers)
		if(S.organ_flags & ORGAN_VITAL)
			continue
		if(S.power_state)
			S.adjust_power_state(POWER_STATE_OFF)
			to_chat(C, "<span class='robot danger'>CAUTION: [S.name] [S.serial_number] has shut down automatically to conserve power!</span>")
			if(B.cell.use(power_load))
				return TRUE
	B.cell.use(B.cell.charge) //reduce the cell's charge to exactly zero

/datum/species/ipc/proc/update_power_icons(mob/living/carbon/human/H)
	diag_hud_set_borgcell(H)
	var/obj/item/organ/silicon/battery/B = H.getorganslot(ORGAN_SLOT_BATTERY)
	if(!B)
		H.clear_alert("charge")
		return
	if(B.cell)
		var/charge_value = 0
		if(B.cell.charge)
			switch(B.cell.charge/B.cell.maxcharge)
				if(0.875 to INFINITY)
					charge_value = 8
				if(0.75 to 0.875)
					charge_value = 7
				if(0.625 to 0.75)
					charge_value = 6
				if(0.5 to 0.625)
					charge_value = 5
				if(0.375 to 0.5)
					charge_value = 4
				if(0.25 to 0.375)
					charge_value = 3
				if(0.125 to 0.25)
					charge_value = 2
				else
					charge_value = 1
			if(charging > world.time)
				charge_value += 8
			H.throw_alert("charge", /obj/screen/alert/cell_status, charge_value)
		else
			H.throw_alert("charge", /obj/screen/alert/emptycell)
	else
		H.throw_alert("charge", /obj/screen/alert/nocell)


/datum/species/ipc/proc/toggle_sleep_mode(mob/living/carbon/human/H, voluntary = FALSE)
	var/datum/status_effect/incapacitating/sleep_mode/S = H.has_status_effect(STATUS_EFFECT_SLEEPMODE)
	var/obj/item/organ/silicon/battery/B = H.getorganslot(ORGAN_SLOT_BATTERY)
	var/obj/item/organ/silicon/coolant_pump/CP = H.getorganslot(ORGAN_SLOT_COOLANT_PUMP)
	if(S)
		if(B && B.cell && B.cell.charge && CP)
			if(voluntary)
				to_chat(H, "<span class='robot notice'>Boot sequence engaged, preparing to exit sleep mode.</span>")
				if(do_after(H, needhand = FALSE, delay = 30, target = H))
					voluntary_sleepmode = FALSE
					S.end_sleepmode(H, voluntary)
					update_battery(H)
				else
					to_chat(H, "<span class='robot notice'>Boot sequence aborted.</span>")
					return
			else
				voluntary_sleepmode = FALSE
				S.end_sleepmode(H)
				update_battery(H)
			if(H.loc)
				handle_heat_load(H.loc.return_air(), H, FALSE)

	else
		H.apply_status_effect(STATUS_EFFECT_SLEEPMODE)
		for(var/obj/item/organ/silicon/R in H.internal_organs)
			if(istype(R))
				R.adjust_power_state(POWER_STATE_OFF)
		voluntary_sleepmode = voluntary
		if(voluntary)
			to_chat(H, "<span class='robot notice'>Sleep Mode Engaged, systems running on reserve power.</span>")
		else if(B)
			if(!B.cell)
				to_chat(H, "<span class='robot danger'>WARNING: No power cell detected, systems running on emergency power!</span>")
				return
			if(!B.cell.charge)
				to_chat(H, "<span class='robot danger'>WARNING: [B.cell] mounted in [B.name] [B.serial_number] has insufficient charge to continue operating, systems now running on emergency power!</span>")
				return
			if(B.organ_flags & ORGAN_FAILING)
				to_chat(H, "<span class='robot danger'>WARNING: Microbattery assembly [B.name] [B.serial_number] has encountered an error, systems running on emergency power!</span>")
				return
			if(CP)
				if(CP.organ_flags & ORGAN_FAILING)
					to_chat(H, "<span class='robot danger'>WARNING: [CP.name] [CP.serial_number] has stopped responding, heat rejection capacity is compromised, systems running on emergency power!</span>")
					return
				if(CP.base_power_load * POWER_STATE_LOW > B.battery_rating)
					to_chat(H, "<span class='robot danger'>WARNING: [B.name] [B.serial_number] has insufficient capacity to operate [CP.name] [CP.serial_number], systems running on emergency power!</span>")

/datum/species/ipc/proc/charge(mob/living/carbon/human/H, amount, repairs) // check if we need to have the right number of arguments
	var/obj/item/organ/silicon/battery/B = H.getorganslot(ORGAN_SLOT_BATTERY)
	var/power_recieved

	if(B && B.cell && amount)
		power_recieved = B.cell.give(amount)
		diag_hud_set_borgcell(H)
		if(power_recieved)
			charging = world.time + 30
	return power_recieved

/datum/species/ipc/proc/handle_apc_charging(mob/living/carbon/C, charging_source, first_run = TRUE)
	var/obj/item/apc_charger/CR = C.is_holding_item_of_type(/obj/item/apc_charger)
	if(!CR)
		return
	var/obj/item/organ/silicon/battery/B = C.getorganslot(ORGAN_SLOT_BATTERY)
	if(!B || !B.get_cell())
		return

	if(istype(charging_source, /obj/machinery/power/smes))
		return

	var/obj/item/stock_parts/cell/source_cell
	if(istype(charging_source, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/AP = charging_source
		source_cell = AP.get_cell()
		if(!source_cell)
			to_chat(C, "<span class='robot danger'>ERROR: No cell detected in [charging_source]!</span>")
			return
	else if(istype(charging_source, /obj/item/stock_parts/cell))
		source_cell = charging_source
	else
		stack_trace("[C] attempted to charge with an invalid charing source [charging_source]!")
		return
	if(!source_cell)
		stack_trace("Non-SMES source [charging_source] attempted to recharge [src] without passing a power cell")
		return
	if(source_cell.charge < source_cell.chargerate)
		to_chat(C, "<span class='robot danger'>ERROR: [charging_source == source_cell ? "[source_cell]" : "[source_cell] mounted in [charging_source]"] has insufficient power to charge internal cell!</span>")
		return
	if((B.cell.charge / B.cell.maxcharge) >= 1)
		if(first_run)
			to_chat(C, "<span class='robot notice'>NOTICE: Internal power cell [B.cell.name] is at capacity, charging aborted!</span>")
		else
			to_chat(C, "<span class='robot notice'>Charge complete!</span>")
		return
	if(first_run)
		to_chat(C, "<span class='notice'>You begin connecting your [CR.name] to [charging_source]...</span>")
	if(do_after(C, 30, target = charging_source, needhand= TRUE))
		if(first_run)
			to_chat(C, "<span class='notice'>You connect your [CR.name] to [charging_source] and begin recharging your internal power cell...</span>")
		var/amount = min(B.cell.maxcharge - B.cell.charge, source_cell.chargerate * 0.1)
		if(source_cell.use(amount) && charge(C, amount))
			handle_apc_charging(C, charging_source, FALSE) // recursion!

/datum/species/ipc/proc/check_safe_start(mob/living/carbon/C) //whether the ipc will come back to life if critical components are replaced
	if(C.health <=  C.crit_threshold)
		safe_start = FALSE // if they go below the crit threshold they need a cyborg jump starter (and repairs) to be revived
	else
		return C.getorganslot(ORGAN_SLOT_BATTERY) && C.getorganslot(ORGAN_SLOT_COOLANT_PUMP)

//diagnostic HUD hooks
/datum/species/ipc/med_hud_set_health_spec(mob/living/carbon/human/H)
	. = TRUE
	var/image/holder = H.hud_list[DIAG_HUD]
	var/icon/I = icon(H.icon, H.icon_state, H.dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(H.stat == DEAD)
		holder.icon_state = "huddiagdead_h"
	else
		holder.icon_state = "huddiag[RoundDiagBar(H.health/H.maxHealth)]_h"

/datum/species/ipc/med_hud_set_status_spec(mob/living/carbon/human/H)
	. = TRUE
	var/image/holder = H.hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(H.icon, H.icon_state, H.dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(H.has_status_effect(STATUS_EFFECT_SLEEPMODE))
		holder.icon_state = "hudoffline_h"
		return
	switch(H.stat)
		if(CONSCIOUS)
			holder.icon_state = "hudstat_h"
		if(UNCONSCIOUS)
			holder.icon_state = "hudoffline_h"
		else
			holder.icon_state = "huddead2_h"


/datum/species/ipc/proc/diag_hud_set_borgcell(mob/living/carbon/C)
	var/image/holder = C.hud_list[DIAG_BATT_HUD]
	var/obj/item/organ/silicon/battery/B = C.getorganslot(ORGAN_SLOT_BATTERY)
	var/icon/I = icon(C.icon, C.icon_state, C.dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(B && B.cell)
		var/chargelvl = (B.cell.charge/B.cell.maxcharge)
		holder.icon_state = "hudbatt[RoundDiagBar(chargelvl)]_h"
	else
		holder.icon_state = "hudnobatt_h"


