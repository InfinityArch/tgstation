obj/item/borg/upgrade_component
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/locked = FALSE
	var/installed = 0
	var/require_module = 0
	var/list/module_type = null
	// if true, is not stored in the robot to be ejected
	// if module is reset
	var/one_use = FALSE

obj/item/upgrade/upgrade/battery
	name = "robotic battery upgrade"
	icon_state = "battery_upgrade"
	var/power_draw
	var/

/obj/item/borg/upgrade/battery/vtec
	name = "robotic VTEC module"
	desc = "Variable Tuned Energetic Capacitor. When installed and active, this system provides a temporary burst of speed"
	power_draw = 5
	