//power draw for different power consumption modules 
#define STATIC_POWER_UPDATE_DELAY 8 // the frequency at which life() will update a battery's status
#define POWER_MODE_SLEEP   1
#define POWER_MODE_LOW	   2
#define POWER_MODE_NORMAL  3

/obj/item/organ/silicon
	name = "robot component"
	icon = 'icons/obj/robot_components.dmi'
	status = ORGAN_ROBOTIC
	oragn_flags = ORGAN_SYNTHETIC
	var/upgrade_slots = 2
	var/list/eligible_upgrades = list(/obj/item/borg/upgrade/battery/vtec,
									 /obj/item/borg/upgrade/emp_shield, 
									 /obj/item/borg/upgrade/battery/heating_coils,
									 /obj/item/borg/upgrade/battery/efficiency)
	var/list/installed_upgrades = list()


/obj/item/organ/silicon/prepare_eat()
	return null

obj/item/organ/silicon/battery
	name = "microcbattery assembly"
	icon_state = "battery_assembly"
	desc = "A robotic power control system capable of mounting a standard power cell."
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BATTERY
	var/power_mode = POWER_MODE_NORMAL
	var/power_draw = 10 
	var/obj/item/stock_parts/cell/cell_type = null
	var/last_updated = STATIC_POWER_UPDATE_DELAY 


/obj/item/organ/silicon/battery/update_icon()
	if(/obj/item/stock_parts/cell in contents)
		icon_state = "[icon_base]-cell"
	else
		icon_state = initial(icon_state)

/obj/item/organ/silicon/battery/Initialize()
	. = ..()
	if(cell_type)
		cell = new cell_type()


/obj/item/organ/silicon/battery/Destroy()
	. = ..()
	qdel(cell)

/obj/item/organ/silicon/battery/get_cell()
	return cell

/obj/item/organ/silicon/battery/on_life()
	if(last_updated)
		last_updated--
	else
		if(power_mode > POWER_MODE_LOW && power_draw)
			use_power()
		handle_power()
		last_updated = initial(last_updated)

/obj/item/organ/silicon/battery/handle_power()
	if(owner && owner.stat != DEAD)
		if((!cell || !cell.charge) && power_mode != POWER_MODE_SLEEP)
			if(cell)
				to_chat(owner, "<span class='danger'>Warning: Power levels critical, emergency power conservation engaged!</span>")
			else	
				to_chat(owner, "<span class='danger'>ERROR: Cannot connect to power cell, emergency power conservation engaged!</span>")
			power_mode = POWER_MODE_SLEEP
			SEND_SIGNAL(owner, COMSIG_UPDATE_POWER_DRAW, src.power_mode)
		else if(cell && cell.charge > 10 && power_mode == POWER_MODE_SLEEP)
				to_chat(owner, "<span class='notice'>Sufficient power detected to resume operation, system switching to low power mode.</span>")
				power_mode = POWER_MODE_NORMAL
				SEND_SIGNAL(owner, COMSIG_UPDATE_POWER_DRAW, src.power_mode)
		else if(cell.charge <= 100 && power_mode > POWER_MODE_LOW)
			to_chat(src, "<span class='warning'>Caution: Power levels are low, power saver mode has activated automatically.</span>")
			power_mode = POWER_MODE_LOW
			SEND_SIGNAL(owner, COMSIG_UPDATE_POWER_DRAW, src.power_mode)
	

/obj/item/organ/silicon/battery/proc/use_power()
	if(cell)
		return cell.use_power(power_draw)

/obj/item/organ/silicon/battery/proc/charge_cell(amount)
	if(cell)
		return cell.give = min(cell.charge + amount, cell.maxcharge)


//obj/item/organ/silicon/battery/ui_action_click()
	//SEND_SIGNAL(owner, COMSIG_CHANGE_BATTERY_POWER_MODE)

/obj/item/organ/silicon/battery/proc/toggle_power_mode()
	switch(new_power_mode)
		if(POWER_MODE_SLEEP)
			if(cell)
				to_chat(owner, "<span class='danger'>ERROR: internal power cell charge level is critically low, power cycle aborted!</span>")
			else
				to_chat(owner, "<span class='danger'>ERROR: cannot connect to internal power cell, power cycle aborted!</span>")
		if(POWER_MODE_LOW)
			if(cell && cell.charge <= 100)
				to_chat(owner, "<span class='warning'>ERROR: internal power cell charge level is dangerous low, cannot leave low power mode!</span>")
			else if(cell && cell.charge > 100)
				to_chat(owner, "<span class='notice'>Low power mode disabled, systems now operating at full power.</span>")
				power_mode = POWER_MODE_NORMAL
				SEND_SIGNAL(owner, COMSIG_UPDATE_POWER_DRAW, src)
		if(POWER_MODE_NORMAL)
			to_chat(R, "<span class='notice'>Low power mode enabled, systems running at reduced capacity.</span>")
			power_mode = POWER_MODE_LOW
			SEND_SIGNAL(owner, COMSIG_UPDATE_POWER_DRAW, src)

/obj/item/organ/silicon/battery/proc/insert_cell(obj/item/stock_parts/cell/new_cell, forced = FALSE)
	if(!new_cell)
		return



/datum/component/modular_power_system
	var/obj/item/stock_parts/cell/power_cell // the power cell associated with this object's modular power system, power is drawn from here
	var/list/idle_consumers = list() //the list of power conumers which attempt to draw power upon update
	var/list/movement_consumers = list() // power consumers that attempt to draw power upon movement
	var/base_load = 0 // the amount of power that's drawn from the cell on handle_power() in addition to idle consumers

/datum/component/modular_power_system/Initialize()
	if(iscarbon(parent)
		RegisterSignal(parent, COMSIG_CARBON_LIFE, .proc/carbon/handle_idle_power)
		RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/carbon/handle_death)
	else if(iscyborg(parent))
		RegisterSignal(parent, COMSIG_CYBORG_LIFE, .proc/cyborg/handle_idle_power)
		RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/cyborg/handle_death)
	else if(ismecha(parent))
		RegisterSignal(parent, COMSIG_MECHA_UPDATE, .proc/mecha/handle_idle_power)
		RegisterSignal(arent, COMSIG_MECHA_DESTROYED, .proc/mecha/handle_death)
	else
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MPS_DRAW_POWER, .proc/use_power)
	RegisterSignal(parent, COMSIG_MPS_INSERT_POWER_CELL, .proc/register_cell)
	RegisterSignal(parent, COMSIG_MPS_REMOVE_POWER_CELL, .proc/unregister_cell)
	RegisterSignal(parent, COMSIG_MPS_REGISTER_CONSUMER, .proc/register_consumer)
	RegisterSignal(parent, COMSIG_MPS_UNREGISTER_CONSUMER, .proc/unregister_consumer)
	RegisterSignal(parent, COMSIG_MPS_RECHARGE_BATTERY, .proc/charge_cell)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/use_movement_power)

/datum/component/modular_power_system/proc/register_cell(obj/item/stock_parts/cell/new_cell)
	power_cell = new_cell
	SEND_SIGNAL(parent, COMSIG_MPS_POWER_CELL_STATUS_UPDATE)

/datum/component/modular_power_system/proc/unregister_cell()
	power_cell = null
	SEND_SIGNAL(parent, COMSIG_MPS_POWER_CELL_STATUS_UPDATE)

/datum/component/modular_power_system/proc/charge_cell(source, amount = 0)
	var/charge_taken = 0
	if(power_cell)
		charge_taken = power_cell.give(amount)
	if(charge_taken)
		SEND_SIGNAL(parent, COMSIG_MPS_POWER_CELL_STATUS_UPDATE)
		if(source)
			SEND_SIGNAL(source, COMSIG_MPS_BATTERY_RECHARGED, charge_taken)
	

/datum/component/modular_power_system/proc/draw_power(source, amount = 0)
	if(power_cell && power_cell.use(amount))
		SEND_SIGNAL(source, COMSIG_MPS_POWER_DRAW_SUCCESS)
	else
		SEND_SIGNAL(source, COMSIG_MPS_INSUFFICIENT_POWER)

/datum/component/modular_power_system/proc/handle_idle_power()
	if(idle_consumers.len)
		for(consumer in idle_consumers)
			SEND_SIGNAL(consumer, COMSIG_MPS_IDLE_POWER_DRAW, parent)
	if(power_cell && base_load)
		power_cell.use(min(base_load, power_cell.charge))
	SEND_SIGNAL(parent, COMSIG_MPS_POWER_CELL_STATUS_UPDATE)

/datum/component/modular_power_system/proc/handle_movement_power(forced = FALSE)
	if(forced || !(movement_consumers.len))
		return
	for(consumer in movement_consumers)
		SEND_SIGNAL(consumer, COMSIG_MPS_MOVEMENT_POWER_DRAW, parent)

/datum/component/modular_power_system/proc/register_idle_consumer(consumer)
		idle_consumers += consumer

/datum/component/modular_power_system/proc/unregister_idle_consumer(consumer)
		static_consumers -= consumer

/datum/component/modular_power_system/proc/register_movement_consumer(consumer)
		movement_consumers += consumer

/datum/component/modular_power_system/proc/unregister_movement_consumer(consumer)
		movement_consumers -= consumer
