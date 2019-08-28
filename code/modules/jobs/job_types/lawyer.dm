/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = LAWYER
	department_head = list("Head Security") //switch to magistrate
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the magistrate and the head of security"
	selection_color = "#dddddd"
	var/lawyers = 0 //Counts lawyer amount

	outfit = /datum/outfit/job/lawyer

	access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS)
	minimal_access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_LAWYER

/datum/outfit/job/lawyer
	name = "Internal Affairs Agent"
	jobtype = /datum/job/lawyer

	belt = /obj/item/pda/lawyer
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	ears = /obj/item/radio/headset/headset_sec
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	suit = /obj/item/clothing/suit/toggle/lawyer
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/briefcase/lawyer
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge
	implants = list(/obj/item/implant/mindshield)
	chameleon_extras = /obj/item/stamp/law


/datum/outfit/job/lawyer/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

	var/datum/job/lawyer/J = SSjob.GetJobType(jobtype)
	J.lawyers++
	if(J.lawyers>1)
		uniform = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit
		suit = /obj/item/clothing/suit/toggle/lawyer/purple
