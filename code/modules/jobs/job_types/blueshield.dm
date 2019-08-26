/datum/job/blueshield
	title = "Blueshield"
	flag = BLUESHIELD
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Head of Security", "Captain")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security and the captain"
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/blueshield

	access = list(ACCESS_ARMORY, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT,
				 ACCESS_MAINT_TUNNELS, ACCESS_MECH_SECURITY, ACCESS_MORGUE, ACCESS_WEAPONS, 
				 ACCESS_FORENSICS_LOCKERS, ACCESS_MINERAL_STOREROOM, ACCESS_HEADS, ACCESS_BLUESHIELD)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS,  ACCESS_COURT, ACCESS_MAINT_TUNNELS, 
						ACCESS_MECH_SECURITY, ACCESS_WEAPONS, ACCESS_ARMORY, ACCESS_HEADS, 
						ACCESS_BLUESHIELD)
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_BLUESHIELD

/datum/job/officer/get_access()
	var/list/L = list()
	L |= ..() | check_config_for_sec_maint()
	return L

/datum/outfit/job/blueshield
	name = "Blueshield"
	jobtype = /datum/job/blueshield

	id = /obj/item/card/id/nanotrasen
	belt = /obj/item/pda/blueshield //TODO make a bespoke cart
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses //should work
	ears = /obj/item/radio/headset/headset_sec/alt/blueshield //done
	//mask = /obj/item/clothing/mask/gas/sechailer/blueshield
	uniform = /obj/item/clothing/under/rank/security/blueshield //done
	gloves = /obj/item/clothing/gloves/color/black //done
	head = /obj/item/clothing/head/beret/sec/blueshield //done
	suit = /obj/item/clothing/suit/armor/vest/blueshield //done
	shoes = /obj/item/clothing/shoes/jackboots //done
	l_pocket = /obj/item/restraints/handcuffs //done
	r_pocket = /obj/item/assembly/flash/handheld //done
	suit_store = /obj/item/gun/energy/e_gun //done
	backpack_contents = list(/obj/item/melee/baton/loaded=1) //done

	backpack = /obj/item/storage/backpack/security //done
	satchel = /obj/item/storage/backpack/satchel/sec //done
	duffelbag = /obj/item/storage/backpack/duffelbag/sec //done
	box = /obj/item/storage/box/security //done

	implants = list(/obj/item/implant/mindshield) //done

	chameleon_extras = list(/obj/item/gun/energy/e_gun, /obj/item/clothing/glasses/hud/security/sunglasses)




