/datum/job/nanotrasen_rep
	title = "Nanotrasen Representitive"
	flag = NT_REP
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("CentCom") //switch to nanotrasen
	department_flag = ENGSEC
    //head_announce = list(RADIO_CHANNEL_NANOTRASEN)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen corporate leadership"
	selection_color = "#ccccff"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_COMMAND

	outfit = /datum/outfit/job/nanotrasen_rep

	access = list() 			//switch this to Nanotrasen access
	minimal_access = list() 	//switch this to Nanotrasen access
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DISK_VERIFIER)

	display_order = JOB_DISPLAY_ORDER_NT_REP

/datum/job/nanotrasen_rep/get_access()
	return get_all_accesses()


/datum/outfit/job/nanotrasen_rep
	name = "Nanotrasen Representitive"
	jobtype = /datum/job/nanotrasen_rep

	id = /obj/item/card/id/nanotrasen //uhhhh MAYBE
	belt = /obj/item/pda/captain/nanotrasen_rep //done
	glasses = /obj/item/clothing/glasses/sunglasses //in game already
	ears = /obj/item/radio/headset/heads/nanotrasen_rep //TODO configure encryption key
	gloves = /obj/item/clothing/gloves/color/captain/nanotrasen_rep //done
	uniform =  /obj/item/clothing/under/rank/nanotrasen_rep // done
	suit = /obj/item/clothing/suit/toggle/nanotrasen_rep // done
	shoes = /obj/item/clothing/shoes/laceup //in game already
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1)

	backpack = /obj/item/storage/backpack/nanotrasen_rep //done
	satchel = /obj/item/storage/backpack/satchel/nanotrasen_rep //done
	duffelbag = /obj/item/storage/backpack/duffelbag/nanotrasen_rep //done

	implants = list(/obj/item/implant/mindshield)//loyalty

	chameleon_extras = list(/obj/item/gun/energy/e_gun, /obj/item/stamp/nt_admin)//TODO add a stamp icon

//datum/outfit/job/captain/hardsuit
	//name = "Captain (Hardsuit)"

	//mask = /obj/item/clothing/mask/gas/sechailer
	//suit = /obj/item/clothing/suit/space/hardsuit/swat/captain
	//suit_store = /obj/item/tank/internals/oxygen
