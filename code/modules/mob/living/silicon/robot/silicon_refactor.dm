//the innate traits that all "silicons" possess
#define SILICON_INNATE_TRAITS list(TRAIT_SLEEPIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_NOBREATH, TRAIT_NOMETABOLISM, TRAIT_NOHUNGER, TRAIT_TOXIMMUNE)
#define SILICON_BODYPLAN_SIMPLE "simple"

//power draw for different power consumption modules 
#define POWER_MODE_SLEEP  0
#define POWER_MODE_LOW	  0.5
#define POWER_MODE_NORMAL 1
#define POWER_MODE_VTEC	  2

// organ slots used by "silicons"
#define COMPONENT_SLOT_BATTERY 			 "battery"
#define COMPONENT_SLOT_COOLANT_PUMP 	 "coolant pump"
#define COMPONENT_SLOT_AUTHENTICATOR 	 "authenticator"
#define COMPONENT_SLOT_INTEGRATED_RADIO  "integrated radio"
#define COMPONENT_SLOT_CHASSIS_MODULE 	 "chassis module"
#define COMPONENT_SLOT_L_ARM_MODULE 	 "left arm module"
#define COMPONENT_SLOT_R_ARM_MODULE 	 "right arm module"
#define COMPONENT_SLOT_L_SHOULDER_MODULE "left shoulder module"
#define COMPONENT_SLOT_L_SHOULDER_MODULE "right shoulder module"
#define COMPONENT_SLOT_CHASSIS_UPGRADE   "chassis upgrade"

// maintainence status
#define MAINTENANCE_STATE_LOCKED	0
#define MAINTENANCE_STATE_UNLOCKED  1
#define MAINTENANCE_STATE_EMAGGED	2



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
	var/datum/chassis/chassis = new() //the specific type of silicon, analogous to species
	var/datum/physiology/physiology 
	
	var/safe_start // set to true for a newly built robot chassis, and for a bot whose MMI was properly ejected 
	var/maintainence_state = MAINTENANCE_STATE_LOCKED

/datum/chassis 
	var/id //the id used in code to denote this chassis
	var/name // in-game name of this chassis type
	var/list/chassis_traits = list() // equivelant to species traits
	var/list/inherent_traits = list() // mob traits associated with this chassis
	var/body_plan = SILICON_BODYPLAN_SIMPLE // determines component/bodypart compatibility
	
	// brain and laws
	var/obj/item/mmi = /obj/item/mmi/robobrain
	
	// charger and battery assembly
	var/obj/item/organ/silicon/apc_power_adaptor/charger
	var/obj/item/organ/silicon/battery_assembly/battery
	var/obj/item/organ/silicon/coolant_pump/cooler

	// communications
	var/obj/item/organ/silicon/integrated_radio/radio
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
	var/allow_genders = FALSE // whether this chassis type allows for gender selection


/mob/living/carbon/robot/is_literate()
	return TRUE

/mob/living/carbon/robot/IsAdvancedToolUser()
	return TRUE

/mob/living/carbon/robot/has_dna()
	return


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

/mob/living/carbon/robot/proc/diag_hud_set_borgcell()
	var/image/holder = hud_list[DIAG_BATT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	var/obj/organ/silicon/battery_assembly/battery = getorganslot(ORGAN_SLOT_BATTERY)
	if(battery && battery.cell)
		var/chargelvl = (battery.cell.charge/battery.cell.maxcharge)
		holder.icon_state = "hudbatt[RoundDiagBar(chargelvl)]"
	else
		holder.icon_state = "hudnobatt"

/mob/living/carbon/robot/Life()
	..()
	handle_robot_hud_updates()
	handle_robot_cell()

/mob/living/carbon/robot/proc/handle_robot_cell()
	if(stat != DEAD)
		var/obj/organ/silicon/battery_assembly/battery = getorganslot(ORGAN_SLOT_BATTERY)
		if(!battery || !battery.cell)
			if(power_mode != POWER_MODE_SLEEP)
				to_chat(src, "<span class='danger'>ERROR: lost connection to power cell, emergency power conservation engaged!</span>")
				power_mode = POWER_MODE_SLEEP
		else if(power_mode == POWER_MODE_SLEEP)
			if(battery.cell.charge > 10)
				to_chat(src, "<span class='notice'>Sufficient power detected, system switching to low power mode.</span>")
				power_mode = POWER_MODE_LOW
		else if(stat == CONSCIOUS)
			use_power()

/mob/living/silicon/robot/proc/use_power()
	var/obj/organ/silicon/battery_assembly/battery = getorganslot(ORGAN_SLOT_BATTERY)
	if(battery.cell.charge <= 0)
		if(power_mode != POWER_MODE_SLEEP)
			to_chat(src, "<span class='danger'>Warning: Power levels critical, sleep mode engaged!</span>")
			power_mode = POWER_MODE_SLEEP
	else if(chassis.battery.cell.charge <= 100)
			if(power_mode != POWER_MODE_LOW)
				to_chat(src, "<span class='warning'>Caution: Power levels are low, automatic power conservation engaged.</span>")
				power_mode = POWER_MODE_LOW
	battery.cell.use(power_draw * power_mode)
	diag_hud_set_borgcell()		

/mob/living/carbon/robot/med_hud_set_health()
	return //we use a different hud

/mob/living/carbon/robot/med_hud_set_status()
	return //we use a different hud

/datum/action/innate/change_power_mode
	name = "Change Power Mode"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_STUN
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "power_toggle"

/datum/action/innate/change_power_mode/Activate()
	var/mob/living/carbon/robot/R = owner
	if(!istype(R))
		return
	var/item/organ/item/battery_assembly = R.getorganslot(ORGAN_SLOT_BATTERY)
	if(battery)
		switch(R.power_mode)
			if(POWER_MODE_SLEEP)
				to_chat(R, "<span class='danger'>ERROR: internal cell charge level is critically low, power cycle aborted!</span>")
			if(POWER_MODE_LOW)
				if(battery.cell && battery.cell.charge <= 100)
					to_chat(R, "<span class='warning'>ERROR: power levels are too low to leave low power mode!</span>")
				if(battery.cell && battery.cell.charge > 100)
					to_chat(R, "<span class='notice'>Low power mode disabled, systems now operating at full power</span>")
					R.power_mode = POWER_MODE_NORMAL
			if(POWER_MODE_NORMAL)
				to_chat(R, "<span class='notice'>Power saver mode activated, systems running at reduced capacity</span>")
					R.power_mode = POWER_MODE_NORMAL
			if(POWER_MODE_VTEC)
				to_chat(R, "<span class='warning'>Caution: VTEC systems are currently running, unable to adjust power mode</span>")
	else
		to_chat(R, "<span class='danger'>ERROR: no power cell detected, power cycle aborted!</span>")
