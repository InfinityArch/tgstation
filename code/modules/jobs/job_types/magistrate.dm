/datum/job/magistrate
	title = "Magistrate"
	flag = MAGISTRATE
	department_head = list("CentCom") //SolGov
	department_flag = ENGSEC
	//head_announce = list(RADIO_CHANNEL_SECURITY)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Federation officials and colonial law"
	selection_color = "#ffdddd"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SECURITY


	outfit = /datum/outfit/job/magistrate

	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT,
			            ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_ALL_PERSONAL_LOCKERS,
			            ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
			            ACCESS_MAGISTRATE, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT,
			            ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_ALL_PERSONAL_LOCKERS,
			            ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
			           ACCESS_MAGISTRATE, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_MAGISTRATE

/datum/outfit/job/magistrate
	name = "Magistrate"
	jobtype = /datum/job/magistrate
	id = /obj/item/card/id/silver
	belt = /obj/item/pda/magistrate
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	ears = /obj/item/radio/headset/headset_sec
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/black
	suit = /obj/item/clothing/suit/magistrate
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/briefcase/lawyer
	l_pocket = /obj/item/laser_pointer
	implants = list(/obj/item/implant/mindshield)
	// chameleon_extras = /obj/item/stamp/magistrate
