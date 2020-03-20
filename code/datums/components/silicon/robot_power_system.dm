//robot power system

#define HEAT_HANDLING_MANUAL	0
#define HEAT_HANDLING_AUTOMATIC	1

/datum/component/robot_power_system // handles power for ipcs and borgs
	var/obj/item/organ/silicon/battery/B
	var/battery_rating // maximum power that can be drawn during one udate cycle
	var/obj/item/organ/silicon/coolant_pump/CP
	var/obj/screen/battery_indicator/screen_obj_battery
	var/obj/screen/overheat_indicator/screen_obj_cooling
	var/mob/living/carbon/owner
	var/list/static_power_consumers = list() // a list of components that draw power or produce heat on a tick by tick basis
	var/static_power_load = 0 // amount of power that's being drawn per update cycle, not including the coolant pump
	var/static_heat_load = 0 // amount of heat that's being produced per update cycle, not including the battery
	var/excess_heat = 0 // how much excess heat has built up in the system
	var/heat_handling_mode = HEAT_HANDLING_AUTOMATIC // whether the automatic overheat safeties are engaged, or heat is allowed to increase beyond safe limits
	var/datum/action/innate/toggle_sleep_mode/sleep_mode_toggle_action // the toggle action for sleep mode
	var/voluntary_sleepmode // whether sleep mode has been engaged voluntarily
	var/charging // whether we've received charging this tick
	var/should_process // the timer for static power updates

/datum/component/robot_power_system/proc/handle_power()
	if(!(B?.cell?.charge || !CP)
		return
	var/draw_capacity = min(B.cell.charge, battery_rating)
	var/coolant_pump_draw = SEND_SIGNAL(CP, COMSIG_SILICON_GET_POWER_DRAW)
	var/battery_heat_load = SEND_SIGNAL(B, COMSIG_SILICON_GET_HEAT_LOAD)
	if((coolant_pump_draw + static_power_load) >= draw_capacity)
		B.cell.use(coolant_pump_draw + static_power_load)
		excess_heat += static_heat_load + (B.base_heat_load * B.power_state)
		return TRUE

	// everything below only fires if the system is running out of power
	for(var/i, i <= 3, i++)
		if(coolant_pump_draw <= draw_capacity)
			break
		var/cp_power_state = SEND_SIGNAL(CP, COMSIG_SILICON_GET_POWER_STATE)
		if(cp_power_state == POWER_STATE_LOW)
			SEND_SIGNAL(CP, COMSIG_SILICON_SET_POWER_STATE, POWER_STATE_OFF)
			return
		SEND_SIGNAL(CP, COMSIG_SILICON_SET_POWER_STATE, cp_power_state * 0.5)
		coolant_pump_draw = SEND_SIGNAL(CP, COMSIG_SILICON_GET_POWER_DRAW)

	if((coolant_pump_draw + static_power_load) >= draw_capacity)
		B.cell.use(coolant_pump_draw + static_power_load)
		excess_heat += static_heat_load + battery_heat_load
		return TRUE

	for(var/i, i <= static_power_consumers.len, i++)
		var/consumer = static_power_consumers[i]
		SEND_SIGNAL(consumer, COMSIG_SILICON_SET_POWER_STATE, POWER_STATE_OFF)
		calculate_static_loads()
		if((static_power_load + coolant_pump_draw) <= draw_capacity)
			B.cell.use(coolant_pump_draw + static_power_load)
			to_chat(owner, "<span class='robot danger'>WARNING: System power demand exceeds capacity, \
			peripheral subsystems have been shut down to conserve power!</span>")
			excess_heat += static_heat_load + battery_heat_load
			return TRUE

/datum/component/robot_power_system/proc/calculate_static_loads()
	static_power_load = initial(static_power_load)
	static_heat_load = initial(static_heat_load)
	for(var/i, i <= static_power_consumers.len, i++)
		var/temp_power = SEND_SIGNAL(static_power_consumers[i], COMSIG_SILICON_GET_POWER_DRAW)
		var/temp_heat = SEND_SIGNAL(static_power_consumers[i], COMSIG_SILICON_GET_HEAT_LOAD)
		if(temp_power)
			static_power_load += temp_power
		if(temp_heat)
			static_heat_load += temp_heat

/datum/component/robot_power_system/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent
	B = owner.getorganslot(ORGAN_SLOT_BATTERY)
	CP = owner.getorganslot(ORAGN_SLOT_COOLANT_PUMP)
	update_static_power_consumers()

	START_PROCESSING(SSsilicon_power, src)

	RegisterSignal(parent, COMSIG_SILICON_COMPONENT_POWER_DRAW, .proc/draw_power)
	RegisterSignal(parent, COMSIG_SILICON_COMPONENT_BATTERY_UPDATED, .proc/update_battery)
	RegisterSignal(parent, COMSIG_CARBON_GAIN_ORGAN, .proc/install_organ)
	RegisterSignal(parent, COMSIG_CARBON_LOSE_ORGAN, .proc/remove_organ)
	RegisterSignal(parent, COMSIG_SILICON_SET_SLEEPMODE, .proc/set_sleepmode)
	RegisterSignal(parent, COMSIG_MOB_HUD_CREATED, .proc/modify_hud)

	if(owner.hud_used)
		modify_hud()
		var/datum/hud/hud = owner.hud_used
		hud.show_hud(hud.hud_version)

/datum/component/mood/Destroy()
	STOP_PROCESSING(SSsilicon_power, src)
	unmodify_hud()
	return ..()

