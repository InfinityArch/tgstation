/datum/species/ipc
	name = "Integrated Robotic Chassis"
	id = "ipc"
	say_mod = "states"
	naming_convention = NAME_NUM
	names_id = "human"	
	species_traits = list(NOHEART,NOZOMBIE,NOTRANSSTING, NO_DNA_COPY, NOSTOMACH, TORSO_BRAIN, EYECOLOR, HAIR, FACEHAIR, MUTCOLORS, LIPS)
	inherent_traits = list(TRAIT_VIRUSIMMUNE, TRAIT_NOMETABOLISM,TRAIT_TOXIMMUNE,TRAIT_NOBREATH,
							TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE, 
							TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOHARDCRIT,
							TRAIT_SLEEPIMMUNE, TRAIT_EASYLIMBDISABLE, TRAIT_RESISTHEATHANDS,
							TRAIT_XENO_IMMUNE, TRAIT_NOPAIN, TRAIT_NOSOFTCRIT, TRAIT_RESISTCOLD)
	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	meat = null
	exotic_blood = /datum/reagent/fuel/oil
	damage_overlay_type = "robotic"
	mutanttongue = /obj/item/organ/tongue/robot/silicon
	mutanteyes = /obj/item/organ/eyes/silicon
	mutantears = /obj/item/organ/ears/silicon
	mutant_brain = /obj/item/organ/brain/mmi
	species_hud = "ipc"
	armor = 20 //ipcs don't have crit, and go straight to dead, so they have 120 effective HP
	speedmod = 2 // as slow as golems
	mutant_organs = list(/obj/item/organ/silicon/battery/ipc, /obj/item/organ/silicon/coolant_pump, /obj/item/organ/silicon/module/arm/apc_charger)
	quirk_budget = 0 //ipcs don't get quirk points
	limbs_id = "human" // ipcs with android parts will use human cosmetics
	changesource_flags = MIRROR_BADMIN | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN
	var/power_load = 0 
	var/heat_load = 0
	var/list/power_consumers = list()
	var/safe_start = FALSE // set to true when vital internal organs are removed; note that the posibrain/mmi is not actually vital.
	var/static_power_update_delay = 20
	var/voluntary_sleepmode // if they're in in sleep mode of its own volition, skips power handling procs
	var/charging // if we've recieved any recharging this update

/datum/species/ipc/on_species_gain(mob/living/carbon/C)
	RegisterSignal(C, COMSIG_SILICON_COMPONENT_ADDED, .proc/insert_component)
	RegisterSignal(C, COMSIG_SILICON_COMPONENT_REMOVED, .proc/remove_component)
	RegisterSignal(C, COMSIG_SILICON_COMPONENT_BATTERY_UPDATE, .proc/update_battery)
	RegisterSignal(C, COMSIG_SILICON_COMPONENT_POWER_UPDATE, .proc/update_power)
	RegisterSignal(C, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, .proc/charge)
	RegisterSignal(C, COMSIG_HANDLE_APC_RECHARGING, .proc/handle_apc_charging)
	. = ..()
	if(C.loc && ishuman(C))
		var/mob/living/carbon/human/H = C
		handle_heat_load(H.calculate_affecting_pressure(H.loc.return_air()), H, FALSE)
	C.grant_language(/datum/language/machine)
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
	UnregisterSignal(C, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	C.clear_alert("overheating")
	C.clear_alert("charge")
	. = ..()
	var/datum/status_effect/incapacitating/sleep_mode/S = C.has_status_effect(STATUS_EFFECT_SLEEPMODE)
	if(S)
		qdel(S)
	var/datum/status_effect/cyborg_power_regen/RC = C.has_status_effect(STATUS_EFFECT_POWERREGEN)
	if(RC)
		qdel(RC)
	C.remove_language(/datum/language/machine)
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/BP = X
		BP.change_bodypart_status(BODYPART_ORGANIC, FALSE, TRUE)
	for(var/Y in C.internal_organs) // remove any aftermarket silicon components
		var/obj/item/organ/O = Y
		if(O.gc_destroyed)
			continue
		if(O.organ_flags & ORGAN_SILICON)
			O.Remove(C, TRUE)
			qdel(O)

/datum/species/ipc/spec_life(mob/living/carbon/human/H)
	if(H.stat != DEAD)
		if(static_power_update_delay > world.time || voluntary_sleepmode)
			return
		else
			static_power_update_delay = world.time + 20
			var/datum/status_effect/incapacitating/sleep_mode/S = H.has_status_effect(STATUS_EFFECT_SLEEPMODE)
			if(handle_power(H))
				message_admins("handle_power has passed")
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
		safe_start = TRUE
	H.clear_alert("charge")
	H.clear_alert("overheating")
	var/datum/status_effect/incapacitating/sleep_mode/S = H.has_status_effect(STATUS_EFFECT_SLEEPMODE)
	if(S)
		S.end_sleepmode(H)

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
	if(. && H.stat != DEAD && && damagetype == BRUTE && prob(damage))
		do_sparks(5, FALSE, H)

/datum/species/ipc/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/H)
	if(!environment)
		return
	if(istype(H.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return

	var/loc_temp = H.get_temperature(environment)
	var/target_temp = handle_heat_load(environment, H)

	//Body temperature is adjusted in two parts: first there your body tries to naturally preserve homeostasis (shivering/sweating), then it reacts to the surrounding environment
	//Thermal protection (insulation) has mixed benefits in two situations (hot in hot places, cold in hot places)
	if(!H.on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		var/natural = 0
		if(H.stat != DEAD)
			natural = H.natural_bodytemperature_stabilization()
		var/thermal_protection = 1
		if(loc_temp < H.bodytemperature) //Place is colder than we are
			thermal_protection -= H.get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(target_temp > BODYTEMP_NORMAL)
				if(H.bodytemperature < target_temp)
					var/heating_factor = CLAMP((target_temp - H.bodytemperature)/target_temp, BODYTEMP_OVERHEAT_MIN, BODYTEMP_OVERHEAT_MAX)
					H.adjust_bodytemperature(min(target_temp - H.bodytemperature, BODYTEMP_HEATING_MAX * heating_factor))
			else if(H.bodytemperature < BODYTEMP_NORMAL) //we're cold, insulation helps us retain body heat and will reduce the heat we lose to the environment
				H.adjust_bodytemperature((thermal_protection+1)*natural + max(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_COLD_DIVISOR, BODYTEMP_COOLING_MAX))
			else //we're sweating, insulation hinders our ability to reduce heat - and it will reduce the amount of cooling you get from the environment
				H.adjust_bodytemperature(natural*(1/(thermal_protection+1)) + max((thermal_protection * (loc_temp - H.bodytemperature) + BODYTEMP_NORMAL - H.bodytemperature) / BODYTEMP_COLD_DIVISOR , BODYTEMP_COOLING_MAX)) //Extra calculation for hardsuits to bleed off heat
	if (loc_temp > H.bodytemperature) //Place is hotter than we are
		var/natural = 0
		if(H.stat != DEAD)
			natural = H.natural_bodytemperature_stabilization()
		var/thermal_protection = 1
		thermal_protection -= H.get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
		if(H.bodytemperature < target_temp) //and we're cold, insulation enhances our ability to retain body heat but reduces the heat we get from the environment
			H.adjust_bodytemperature((thermal_protection+1)*natural + min(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))
		else if(H.bodytemperature < BODYTEMP_NORMAL) //we're cold, insulation helps us retain body heat and will reduce the heat we lose to the environment
			H.adjust_bodytemperature((thermal_protection+1)*natural + max(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_COLD_DIVISOR, BODYTEMP_COOLING_MAX))
		else //we're sweating, insulation hinders out ability to reduce heat - but will reduce the amount of heat we get from the environment
			H.adjust_bodytemperature(natural*(1/(thermal_protection+1)) + min(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))
	
	// +/- 50 degrees from 310K is the 'safe' zone, where no damage is dealt.
	if(H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT && !HAS_TRAIT(H, TRAIT_RESISTHEAT))
		//Body temperature is too hot.

		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "hot", /datum/mood_event/hot)

		H.remove_movespeed_modifier(MOVESPEED_ID_COLD)

		var/burn_damage
		var/firemodifier = H.fire_stacks / 50
		if (H.on_fire)
			burn_damage = max(log(2-firemodifier,(H.bodytemperature-BODYTEMP_NORMAL))-5,0)
		else
			firemodifier = min(firemodifier, 0)
			burn_damage = max(log(2-firemodifier,(H.bodytemperature-BODYTEMP_NORMAL))-5,0) // this can go below 5 at log 2.5
		if (burn_damage)
			switch(burn_damage)
				if(0 to 2)
					H.throw_alert("temp", /obj/screen/alert/hot, 1)
				if(2 to 4)
					H.throw_alert("temp", /obj/screen/alert/hot, 2)
				else
					H.throw_alert("temp", /obj/screen/alert/hot, 3)
		burn_damage = burn_damage * heatmod * H.physiology.heat_mod
		H.apply_damage(burn_damage, BURN, spread_damage = TRUE)

	else if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !HAS_TRAIT(H, TRAIT_RESISTCOLD))
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "hot")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "cold", /datum/mood_event/cold)
		//Sorry for the nasty oneline but I don't want to assign a variable on something run pretty frequently
		H.add_movespeed_modifier(MOVESPEED_ID_COLD, override = TRUE, multiplicative_slowdown = ((BODYTEMP_COLD_DAMAGE_LIMIT - H.bodytemperature) / COLD_SLOWDOWN_FACTOR), blacklisted_movetypes = FLOATING)
		switch(H.bodytemperature)
			if(200 to BODYTEMP_COLD_DAMAGE_LIMIT)
				H.throw_alert("temp", /obj/screen/alert/cold, 1)
				H.apply_damage(COLD_DAMAGE_LEVEL_1*coldmod*H.physiology.cold_mod, BURN)
			if(120 to 200)
				H.throw_alert("temp", /obj/screen/alert/cold, 2)
				H.apply_damage(COLD_DAMAGE_LEVEL_2*coldmod*H.physiology.cold_mod, BURN)
			else
				H.throw_alert("temp", /obj/screen/alert/cold, 3)
				H.apply_damage(COLD_DAMAGE_LEVEL_3*coldmod*H.physiology.cold_mod, BURN)

	else
		H.clear_alert("temp")
		H.remove_movespeed_modifier(MOVESPEED_ID_COLD)
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "hot")

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
				if(CP.adjust_power_state(CLAMP(CP.power_state * 2, POWER_STATE_LOW, POWER_STATE_OVERDRIVE)))
					report = " to compensate for excess heat accumulation.</span>"
					cooling_capacity = CP.get_cooling_capacity(H.calculate_affecting_pressure(environment.return_pressure()))
				else
					break
			while(heat_load * 2 <= cooling_capacity && CP.power_state > POWER_STATE_LOW)
				if(CP.adjust_power_state(CLAMP(CP.power_state * 0.5, POWER_STATE_LOW, POWER_STATE_OVERDRIVE)))
					report = " to reduce power consumption.</span>"
					cooling_capacity = CP.get_cooling_capacity(H.calculate_affecting_pressure(environment.return_pressure()))
				else
					break
			if(report && send_notifications)
				to_chat(H, "<span class='robot notice'>NOTICE: [CP.name] [CP.serial_number] has automatically switched to \
	[CP.get_power_state_string()]" + report)



	// calculate the amount of excess heat we're generating, and throw an alert if necessary
	. += CLAMP(SILICON_HEAT_LOAD_FACTOR * (heat_load - cooling_capacity), 0, 100)
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

	clearlist(power_consumers)
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
	clearlist(power_consumers)
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
	
	var/obj/item/organ/silicon/battery/B = C.getorganslot(ORGAN_SLOT_BATTERY)

	if(B.cell && B.cell.charge && !voluntary_sleepmode)
		if(C.has_status_effect(STATUS_EFFECT_SLEEPMODE))
			toggle_sleep_mode(C)
		else
			B.adjust_power_state(POWER_STATE_NORMAL)

	var/report

	for(var/obj/item/organ/silicon/S in power_consumers)
		if(S.organ_flags & ORGAN_VITAL)
			continue
		report = null
		while(S.power_state && S.power_state * S.base_power_load > B.battery_rating * B.power_state)
			if(S.power_state > POWER_STATE_LOW && S.adjust_power_state(S.power_state * 0.5))
				report = TRUE
			else
				S.adjust_power_state(POWER_STATE_OFF)
				report = TRUE
				break
		if(report && B.cell)
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
	var/obj/item/organ/silicon/battery/B = C.getorganslot(ORGAN_SLOT_BATTERY)
	var/obj/item/organ/silicon/coolant_pump/CP = C.getorganslot(ORGAN_SLOT_COOLANT_PUMP)

	if(!(B && B.cell && B.cell.charge && CP) || ((B.organ_flags|CP.organ_flags) & ORGAN_FAILING) || (min(CP.power_state, POWER_STATE_LOW) * CP.base_power_load > B.battery_rating * B.power_state))
		return
	if(!B.power_state && !B.adjust_power_state(POWER_STATE_NORMAL))
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
	if(charging)
		charging = FALSE
		return
	var/obj/item/organ/silicon/battery/B = H.getorganslot(ORGAN_SLOT_BATTERY)

	if(H.has_status_effect(STATUS_EFFECT_POWERREGEN))
		return
	if(B && B.cell)
		if(B.cell.charge)
			switch((B.cell.charge/B.cell.maxcharge))
				if(0.875 to INFINITY)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 8)
				if(0.75 to 0.875)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 7)
				if(0.625 to 0.75)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 6)
				if(0.5 to 0.625)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 5)
				if(0.375 to 0.5)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 4)
				if(0.25 to 0.375)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 3)
				if(0.125 to 0.25)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 2)
				else
					H.throw_alert("charge", /obj/screen/alert/cell_status, 1)
		else
			H.throw_alert("charge", /obj/screen/alert/emptycell)
	else if(B)
		H.throw_alert("charge", /obj/screen/alert/nocell)

/datum/species/ipc/proc/toggle_sleep_mode(mob/living/carbon/human/H, voluntary = FALSE)
	var/datum/status_effect/incapacitating/sleep_mode/S = H.has_status_effect(STATUS_EFFECT_SLEEPMODE)
	var/obj/item/organ/silicon/battery/B = H.getorganslot(ORGAN_SLOT_BATTERY)
	var/obj/item/organ/silicon/coolant_pump/CP = H.getorganslot(ORGAN_SLOT_COOLANT_PUMP)
	
	if(S)
		if(B && B.cell && B.cell.charge && CP)
			B.adjust_power_state(POWER_STATE_NORMAL)
			if(H.loc)
				handle_heat_load(H.loc.return_air(), H, FALSE)
			if(voluntary)
				to_chat(H, "<span class='robot notice'>Boot sequence engaged, preparing to exit sleep mode.</span>")
				if(do_after(H, 30, target = H, FALSE))
					S.end_sleepmode(H, voluntary)
				else
					to_chat(H, "<span class='robot notice'>Boot sequence aborted.</span>")
					return
			else
				S.end_sleepmode(H)
				
			voluntary_sleepmode = FALSE
			
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
	
	if(B && B.cell && amount)
		charging = B.cell.give(amount) // causes update power_icons to use recharge icon_states
		if(B.cell.charge)
			switch((B.cell.charge/B.cell.maxcharge))
				if(0.875 to INFINITY)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 16)
				if(0.75 to 0.875)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 15)
				if(0.625 to 0.75)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 14)
				if(0.5 to 0.625)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 13)
				if(0.375 to 0.5)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 12)
				if(0.25 to 0.375)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 11)
				if(0.125 to 0.25)
					H.throw_alert("charge", /obj/screen/alert/cell_status, 10)
				else
					H.throw_alert("charge", /obj/screen/alert/cell_status, 9)
		else
			H.throw_alert("charge", /obj/screen/alert/emptycell)
	else if(B)
		H.throw_alert("charge", /obj/screen/alert/nocell)
	return charging

/datum/species/ipc/proc/handle_apc_charging(mob/living/carbon/C, charging_source)
	if(istype(charging_source, /obj/machinery/power/smes))
		var/obj/machinery/power/smes/S = charging_source
		message_admins("[S] is source")
		return

	var/obj/item/stock_parts/cell/cell
	if(istype(charging_source, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/AP = charging_source
		cell = AP.get_cell()
	else if(istype(charging_source, /obj/item/stock_parts/cell))
		cell = charging_source
	else
		CRASH("[C] attempted to charge with an invalid charing source [charging_source]!")
		return
	if(!cell)
		CRASH("Non-SMES source [charging_source] attempted to recharge [src] without passing a power cell")
		return
	if(cell.charge < 100)
		to_chat(C, "<span class='robot danger'>ERROR: [charging_source == cell ? "[cell]" : "[cell] mounted in [charging_source]"] has insufficient power, unable to draw power!</span>")
		return

/datum/species/ipc/proc/check_safe_start(mob/living/carbon/C) //whether the ipc will come back to life if critical components are replaced
	if(C.health <=  C.crit_threshold)
		safe_start = FALSE // if they go below the crit threshold they need a cyborg jump starter (and repairs) to be revived
	else
		return C.getorganslot(ORGAN_SLOT_BATTERY) && C.getorganslot(ORGAN_SLOT_COOLANT_PUMP)
