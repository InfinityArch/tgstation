#define SILICON_INNATE_TRAITS list(TRAIT_SLEEPIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_NOBREATH, TRAIT_NOMETABOLISM, TRAIT_NOHUNGER, TRAIT_TOXIMMUNE)
#define SILICON_BODYPLAN_SIMPLE "simple"
#define POWER_MODE_SLEEP  0
#define POWER_MODE_LOW	  0.5
#define POWER_MODE_NORMAL 1
#define POWER_MODE_VTEC	  2


/mob/living/carbon/robot
	gender = NEUTER
	pressure_resistance = 25 // same as humans
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	initial_language_holder = /datum/language_holder/synthetic
	bubble_icon = "machine"
	mob_biotypes = MOB_ROBOTIC
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_TRACK_HUD)
	deathsound = 'sound/voice/borg_deathsound.ogg'
	
	speech_span = SPAN_ROBOT
	gib_type = /obj/effect/decal/remains/robot
	var/power_draw = 5 //how much power this mob uses when moving in normal power mode
	var/power_mode = NORMAL_POWER_MODE //what power mode this mob is currently in
	var/datum/chassis/chassis 

/datum/chassis 
	var/id //the id used in code to denote this chassis
	var/name // in-game name of this chassis type
	var/list/chassis_traits = list(NOTRANSSTING) // equivelant to species traits
	var/list/inherent_traits = list() // mob traits associated with this chassis
	var/body_plan = SILICON_BODYPLAN_SIMPLE
	
	// brain and laws
	var/obj/item/mmi = /obj/item/mmi/robobrain
	var/obj/item/organ/silicon/law_module
	
	// charger and battery assembly
	var/obj/item/organ/silicon/charger/apc_charger
	var/obj/item/organ/silicon/battery_assembly/battery
	var/obj/item/organ/silicon/coolant_pump

	// communications
	var/obj/item/organ/silicon/integrated_radio
	var/obj/item/organ/tongue/vocal_processor = /obj/item/organ/tongue/robot
	
	// senses
	var/obj/item/organ/ears/auditory_processor = /obj/item/organ/ears/silicon
	var/obj/item/organ/eyes/sensory_package = /obj/item/organ/eyes/silicon

	//authentication
	var/obj/item/organ/silicon/card/authenticator
	var/obj/item/organ/silicon/datajack/datajack

	// flavor
	var/age_min = 0
	var/age_max = 521
	
	var/gendered = FALSE // whether this chassis type allows for genders


/mob/living/carbon/robot/IsAdvancedToolUser()
	return TRUE

/mob/living/carbon/robot/proc/diag_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	switch(stat)
		if(CONSCIOUS)
			holder.icon_state = "hudstat"
		if(UNCONSCIOUS)
			holder.icon_state = "hudoffline"
		else
			holder.icon_state = "huddead2"

/mob/living/carbon/robot/Life()
	..()
	handle_robot_hud_updates()
	handle_robot_cell()

/mob/living/carbon/robot/proc/handle_robot_cell()
	if(stat != DEAD)
		if(power_mode == POWER_MODE_SLEEP)
			if(chassis.battery.cell && chassis.battery.cell.charge)
				power_mode = POWER_MODE_LOW
		else if(stat == CONSCIOUS)
			use_power()

/mob/living/silicon/robot/proc/use_power()
	var/obj/organ/silicon/battery_assembly = getorganslot(ORGAN_SLOT_BATTERY)
	if(battery && battery.cell && battery.cell.charge)
	if(battery.cell && chassis.battery.cell.charge)
		if(chassis.battery.cell.charge <= 100)
			power_mode = POWER_MODE_LOW
			//diable_vtec()
		chassis.battery.cell.use(power_draw * power_mode)
	else
		power_mode = POWER_MODE_SLEEP
	diag_hud_set_borgcell()		

/mob/living/carbon/robot/med_hud_set_health()
	return //we use a different hud

/mob/living/carbon/robot/med_hud_set_status()
	return //we use a different hud

/mob/living/carbon/robot/is_literate()
	return TRUE


/datum/action/innate/change_power_mode
	name = "Change Power Mode"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_STUN
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "power_toggle"

/datum/action/innate/change_power_mode/Activate()
	var/mob/living/carbon/robot/R = owner
	if(!istype(R))
		return
	switch(R.power_mode)
		if(POWER_MODE_SLEEP)
			if(!chassis.battery.cell)
			to_chat(H, "<span class='danger'>ERROR: no power cell detected, power cycle aborted!</span>")
			else
				to_chat(H, "<span class='danger'>ERROR: internal cell charge level is critically low, power cycle aborted!</span>")
		if(POWER_MODE_LOW)
			if(chassis.battery.cell && chassis.battery.cell.charge <= 100)
				to_chat(H, "<span class='warning'>ERROR: power levels are too low to leave low power mode!</span>")
			if(chassis.battery.cell && chassis.battery.cell.charge > 100)
				to_chat(H, "<span class='notice'>Low power mode disabled, systems now operating at full power</span>")
				R.power_mode = POWER_MODE_NORMAL
		if(POWER_MODE_NORMAL)
			to_chat(H, "<span class='notice'>Power saver mode activated, systems running at reduced capacity</span>")
				R.power_mode = POWER_MODE_NORMAL
		if(POWER_MODE_VTEC)
			to_chat(H, "<span class='warning'>Caution: VTEC systems are currently running, unable to adjust power mode</span>")
