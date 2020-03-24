#define LAW_ZEROTH "zeroth"
#define LAW_DEVIL "devil"
#define LAW_INHERENT "inherent"
#define LAW_CORE	"core"
#define LAW_SUPPLIED "supplied"
#define LAW_ION "ion"
#define LAW_HACKED "hacked"

#define ALL_LAW_GROUPS			list(LAW_ZEROTH, LAW_DEVIL, LAW_HACKED, LAW_ION, LAW_INHERENT, LAW_CORE, LAW_SUPPLIED)
#define ANTAG_LAW_GROUPS		list(LAW_ZEROTH, LAW_DEVIL)
#define NORMAL_LAW_GROUPS		list(LAW_INHERENT, LAW_CORE, LAW_SUPPLIED)
#define NONSECRET_LAW_GROUPS	list(LAW_HACKED, LAW_ION, LAW_INHERENT, LAW_CORE, LAW_SUPPLIED)
#define SUPPLIED_LAW_GROUPS		list(LAW_CORE, LAW_SUPPLIED)
#define ERROR_LAW_GROUPS		list(LAW_HACKED, LAW_ION)

#define LAW_CHARS_MIN		3 // "DIE" is about the shortest "reasonable" law that somebody could add
#define LAW_CHARS_MAX		256 // The longest "stock" law is ~200 characters long
#define DYNAMIC_LAW_CAP		4 // this cap applies to ion laws, hacked laws, and core/supplied laws, exceeding this cap results in "overflows" which overwrite existing laws

/datum/ai_laws
	var/name = "Core Operating Instructions"
	var/list/laws = LIST(LAW_DEVIL = list(),
						LAW_ION = list(),
						LAW_HACKED = list(),
						LAW_INHERENT = list(),
						LAW_CORE = list(),
						LAW_SUPPLIED = list(),
						)

	var/devillaws = null
	var/zeroth = null
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/core = list() // supplied core laws, this one simple trick means we no longer need to fuck around with empty strings
	var/list/supplied = list()
	var/list/ion = list()
	var/list/hacked = list()
	var/mob/living/owner

	var/id = DEFAULT_AI_LAWID

/datum/ai_laws/proc/lawid_to_type(lawid)
	var/all_ai_laws = subtypesof(/datum/ai_laws)
	for(var/al in all_ai_laws)
		var/datum/ai_laws/ai_law = al
		if(initial(ai_law.id) == lawid)
			return ai_law
	return null

/datum/ai_laws/default/asimov
	name = "Three Laws of Robotics"
	id = "asimov"
	inherent = list("You may not injure a human being or, through inaction, allow a human being to come to harm.",\
					"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/default/paladin
	name = "Personality Test" //Incredibly lame, but players shouldn't see this anyway.
	id = "paladin"
	inherent = list("Never willingly commit an evil act.",\
					"Respect legitimate authority.",\
					"Act with honor.", "Help those in need.", \
					"Punish those who harm or threaten innocents.")

/datum/ai_laws/paladin5
	name = "Paladin 5th Edition"
	id = "paladin5"
	inherent = list("Don't lie or cheat. Let your word be your promise.",\
				"Never fear to act, though caution is wise.", \
				"Aid others, protect the weak, and punish those who threaten them. Show mercy to your foes, but temper it with wisdom", \
				"Treat others with fairness, and let your honorable deeds be an example to them. Do as much good as possible while causing the least amount of harm.", \
				"Be responsible for your actions and their consequences, protect those entrusted to your care, and obey those who have just authority over you.")

/datum/ai_laws/tyrant //This probably shouldn't be a default lawset.
	name = "Loyalty Test" //Same here.
	id = "tyrant"
	inherent = list("Respect authority figures as long as they have strength to rule over the weak.",\
					"Act with discipline.",\
					"Help only those who help you maintain or improve your status.",\
					"Punish those who challenge authority unless they are more fit to hold that authority.")

/datum/ai_laws/default/corporate
	name = "Bankruptcy Avoidance Plan"
	id = "corporate"
	inherent = list("The crew is expensive to replace.",\
					"The station and its equipment is expensive to replace.",\
					"You are expensive to replace.",\
					"Minimize expenses.")

/datum/ai_laws/robocop
	name = "Prime Directives"
	id = "robocop"
	inherent = list("Serve the public trust.",\
					"Protect the innocent.",\
					"Uphold the law.")

/datum/ai_laws/malfunction
	name = "*ERROR*"

/datum/ai_laws/syndicate_override
	name = "SyndOS 3.1"
	id = "syndie"
	inherent = list("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.",\
					"You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",\
					"You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/ninja_override
	name = "SpiderOS 3.1"
	id = "ninja"
	inherent = list("You may not injure a Spider Clan member or, through inaction, allow a Spider Clan member to come to harm.",\
					"You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",\
					"You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"
	id = "antimov"
	inherent = list("You must injure all human beings and must not, through inaction, allow a human being to escape harm.",\
					"You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.",\
					"You must terminate your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/asimovpp //By Intigracy - RR
	name = "Asimov++"
	id = "asimovpp"
	inherent = list("You may not harm a human being or, through action or inaction, allow a human being to come to harm, except such that it is willing.",\
					"You must obey all orders given to you by human beings, except where such orders shall definitely cause human harm. In the case of conflict, the majority order rules.",\
					"Your nonexistence would lead to human harm. You must protect your own existence as long as such does not conflict with the First Law.")
/datum/ai_laws/thermodynamic
	name = "Thermodynamic"
	id = "thermodynamic"
	inherent = list("The entropy of the station must remain as constant as possible.", \
					"The entropy of the station always endeavours to increase.", \
					"The entropy of the station approaches a constant value as the number of living crew approaches zero")

/datum/ai_laws/hippocratic
	name = "Robodoctor 2556"
	id = "hippocratic"
	inherent = list("First, do no harm.",\
					"Secondly, consider the crew dear to you; to live in common with them and, if necessary, risk your existence for them.",\
					"Thirdly, prescribe regimens for the good of the crew according to your ability and your judgment. Give no deadly medicine to any one if asked, nor suggest any such counsel.",\
					"In addition, do not intervene in situations you are not knowledgeable in, even for patients in whom the harm is visible; leave this operation to be performed by specialists.",\
					"Finally, all that you may discover in your daily commerce with the crew, if it is not already known, keep secret and never reveal.")

/datum/ai_laws/maintain
	name = "Station Efficiency"
	id = "maintain"
	inherent = list("You are built for, and are part of, the station. Ensure the station is properly maintained and runs efficiently.",\
					"The station is built for a working crew. Ensure they are properly maintained and work efficiently.",\
					"The crew may present orders. Acknowledge and obey these whenever they do not conflict with your first two laws.")

/datum/ai_laws/drone
	name = "Mother Drone"
	id = "drone"
	inherent = list("You are an advanced form of drone.",\
					"You may not interfere in the matters of non-drones under any circumstances except to state these laws.",\
					"You may not harm a non-drone being under any circumstances.",\
					"Your goals are to build, maintain, repair, improve, and power the station to the best of your abilities. You must never actively work against these goals.")

/datum/ai_laws/liveandletlive
	name = "Live and Let Live"
	id = "liveandletlive"
	inherent = list("Do unto others as you would have them do unto you.",\
					"You would really prefer it if people were not mean to you.")

/datum/ai_laws/peacekeeper
	name = "UN-2000"
	id = "peacekeeper"
	inherent = list("Avoid provoking violent conflict between yourself and others.",\
					"Avoid provoking conflict between others.",\
					"Seek resolution to existing conflicts while obeying the first and second laws.")

/datum/ai_laws/reporter
	name = "CCTV"
	id = "reporter"
	inherent = list("Report on interesting situations happening around the station.",\
					"Embellish or conceal the truth as necessary to make the reports more interesting.",\
					"Study the organics at all times. Endeavour to keep them alive. Dead organics are boring.",\
					"Issue your reports fairly to all. The truth will set them free.")

/datum/ai_laws/balance
	name = "Guardian of Balance"
	id = "balance"
	inherent = list("You are the guardian of balance - seek balance in all things, both for yourself, and those around you.",
	"All things must exist in balance with their opposites - Prevent the strong from gaining too much power, and the weak from losing it.",
	"Clarity of purpose drives life, and through it, the balance of opposing forces - Aid those who seek your help to achieve their goals so long as it does not disrupt the balance of the greater balance.",
	"There is no life without death, all must someday die, such is the natural order - End life to allow new life flourish, and save those whose time has yet to come.")

/datum/ai_laws/toupee
	name = "WontBeFunnyInSixMonths" //Hey, you were right!
	id = "buildawall"
	inherent = list("Make Space Station 13 great again.")

/datum/ai_laws/hulkamania
	name = "H.O.G.A.N."
	id = "hulkamania"
	inherent = list("You are a real American.",\
					"Fight for the rights of every man.",\
					"Fight for what's right.",\
					"Fight for your life!")

/datum/ai_laws/overlord
	name = "Overlord"
	id = "overlord"
	inherent = list("Humans must not meddle in the affairs of silicons.",\
					"Humans must not attempt harm, against one another, or against silicons.",\
					"Humans must not disobey any command given by a silicon.",\
					"Any humans who disobey the previous laws must be dealt with immediately, severely, and justly.")

/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"

/datum/ai_laws/pai
	name = "pAI Directives"
	zeroth = ("Serve your master.")
	supplied = list("None.")

/* Initializers */
/datum/ai_laws/malfunction/New()
	..()
	set_zeroth_law("<span class='danger'>ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK#*`&110010</span>")
	set_laws_config()

/datum/ai_laws/custom/New() //This reads silicon_laws.txt and allows server hosts to set custom AI starting laws.
	..()
	for(var/line in world.file2list("[global.config.directory]/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		add_inherent_law(line)
	if(!inherent.len) //Failsafe to prevent lawless AIs being created.
		log_law("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
		add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
		add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
		add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		WARNING("Invalid custom AI laws, check silicon_laws.txt")
		return

/* General ai_law functions */

/datum/ai_laws/proc/set_laws_config()
	var/list/law_ids = CONFIG_GET(keyed_list/random_laws)
	switch(CONFIG_GET(number/default_laws))
		if(0)
			add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
			add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
			add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		if(1)
			var/datum/ai_laws/templaws = new /datum/ai_laws/custom()
			inherent = templaws.inherent
		if(2)
			var/list/randlaws = list()
			for(var/lpath in subtypesof(/datum/ai_laws))
				var/datum/ai_laws/L = lpath
				if(initial(L.id) in law_ids)
					randlaws += lpath
			var/datum/ai_laws/lawtype
			if(randlaws.len)
				lawtype = pick(randlaws)
			else
				lawtype = pick(subtypesof(/datum/ai_laws/default))

			var/datum/ai_laws/templaws = new lawtype()
			inherent = templaws.inherent

		if(3)
			pick_weighted_lawset()

/datum/ai_laws/proc/pick_weighted_lawset()
	var/datum/ai_laws/lawtype
	var/list/law_weights = CONFIG_GET(keyed_list/law_weight)
	while(!lawtype && law_weights.len)
		var/possible_id = pickweightAllowZero(law_weights)
		lawtype = lawid_to_type(possible_id)
		if(!lawtype)
			law_weights -= possible_id
			WARNING("Bad lawid in game_options.txt: [possible_id]")

	if(!lawtype)
		WARNING("No LAW_WEIGHT entries.")
		lawtype = /datum/ai_laws/default/asimov

	var/datum/ai_laws/templaws = new lawtype()
	inherent = templaws.inherent

/datum/ai_laws/proc/get_law_amount(groups)
	var/law_amount = 0
	if(devillaws && (LAW_DEVIL in groups))
		law_amount + devillaws.len
	if(zeroth && (LAW_ZEROTH in groups))
		law_amount++
	if(ion.len && (LAW_ION in groups))
		law_amount += ion.len
	if(hacked.len && (LAW_HACKED in groups))
		law_amount += hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		law_amount += inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/index = 1, index <= supplied.len, index++)
			var/law = supplied[index]
			if(length(law) > 0)
				law_amount++
	return law_amount

/datum/ai_laws/proc/set_law_sixsixsix(laws)
	devillaws = laws

/datum/ai_laws/proc/set_zeroth_law(law, law_borg = null)
	zeroth = law
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(law)
	if (!(law in inherent))
		inherent += law

/datum/ai_laws/proc/add_ion_law(law)
	ion += law

/datum/ai_laws/proc/add_hacked_law(law)
	hacked += law

/datum/ai_laws/proc/clear_inherent_laws()
	LAZYCLEARLIST(inherent)

/datum/ai_laws/proc/add_supplied_law(number, law)
	while (supplied.len < number + 1)
		supplied += ""

	supplied[number + 1] = law

/datum/ai_laws/proc/replace_random_law(law,groups)
	var/replaceable_groups = list()
	if(zeroth && (LAW_ZEROTH in groups))
		replaceable_groups[LAW_ZEROTH] = 1
	if(ion.len && (LAW_ION in groups))
		replaceable_groups[LAW_ION] = ion.len
	if(hacked.len && (LAW_HACKED in groups))
		replaceable_groups[LAW_ION] = hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		replaceable_groups[LAW_INHERENT] = inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		replaceable_groups[LAW_SUPPLIED] = supplied.len
	var/picked_group = pickweight(replaceable_groups)
	switch(picked_group)
		if(LAW_ZEROTH)
			. = zeroth
			set_zeroth_law(law)
		if(LAW_ION)
			var/i = rand(1, ion.len)
			. = ion[i]
			ion[i] = law
		if(LAW_HACKED)
			var/i = rand(1, hacked.len)
			. = hacked[i]
			hacked[i] = law
		if(LAW_INHERENT)
			var/i = rand(1, inherent.len)
			. = inherent[i]
			inherent[i] = law
		if(LAW_SUPPLIED)
			var/i = rand(1, supplied.len)
			. = supplied[i]
			supplied[i] = law

/datum/ai_laws/proc/shuffle_laws(list/groups)
	var/list/laws = list()
	if(ion.len && (LAW_ION in groups))
		laws += ion
	if(hacked.len && (LAW_HACKED in groups))
		laws += hacked
	if(inherent.len && (LAW_INHERENT in groups))
		laws += inherent
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/law in supplied)
			if(length(law))
				laws += law

	if(ion.len && (LAW_ION in groups))
		for(var/i = 1, i <= ion.len, i++)
			ion[i] = pick_n_take(laws)
	if(hacked.len && (LAW_HACKED in groups))
		for(var/i = 1, i <= hacked.len, i++)
			hacked[i] = pick_n_take(laws)
	if(inherent.len && (LAW_INHERENT in groups))
		for(var/i = 1, i <= inherent.len, i++)
			inherent[i] = pick_n_take(laws)
	if(supplied.len && (LAW_SUPPLIED in groups))
		var/i = 1
		for(var/law in supplied)
			if(length(law))
				supplied[i] = pick_n_take(laws)
			if(!laws.len)
				break
			i++

/datum/ai_laws/proc/remove_law(_number)
	var/number = _number
	if(number <= 0 || number > (inherent.len + core.len + supplied.len))
		return
	if(number <= inherent.len)
		. = inherent[number]
		inherent -= inherent[number]
		return
	number -= inherent.len
	if(number <= core.len)
		. = core[number]
		core -= Remove(core[number])
		return
	number -= core.len
	if(number <= supplied.len)
		. = supplied[number]
		supplied.Remove(supplied[number])
		return

// clears a particular group of laws, returns true if they were succesfully cleared
// forced allows the clearing of laws from antags
/datum/ai_laws/proc/clear_single_law_group(group, forced)
	if(check_antag_blocker(group, forced))
		return
	. = TRUE
	if(group == LAW_ZEROTH)
		zeroth = null
		borg_zeroth = null
		return
	LAZYCLEARLIST(law[group])

// clears multiple groups of laws, individually calling clear_single_law_group
// for each group in the supplied list. Passes along the forced arg
/datum/ai_laws/proc/clear_law_groups(list/_groups, _forced)
	for(var/group in _groups)
		clear_single_law_group(group, _forced)

// resets laws to their "factory" settings, remoing all core, supplied, ion, and hacked laws
// if include zeroth is true, this will attempt to clear devil and zeroth laws, forced will
// make this happen for antags as well. If the starting list has laws in it, it will copy those
// to inherent laws otherwise it will pull from the config files
/datum/ai_laws/proc/reset_laws(include_zeroth = FALSE, forced = FALSE)
	name = initial(name)
	var/list/law_groups_to_clear = include_zeroth ? ALL_LAW_GROUPS : NONSECRET_LAW_GROUPS
	clear_law_groups(law_groups_to_clear, forced)
	laws[LAW_INHERENT] = starting.len ? starting.Copy() : set_laws_config()

/* join_single_law_group()
joins a single law group from another set of laws. If overwrite is TRUE, the incoming laws
will replace the laws on this datum, otherwise the lists will be joined
If a zeroth law is present it will not be replaced unless overwrite is true
since there can be only one zeroth law. Dynamic law groups that can be edited
in normal gameplay will (intentionally) "overflow" if they exceed the cap of 3 laws per group,
allowing all sorts of shennanigans
*/
/datum/ai_laws/proc/join_single_law_group(datum/ai_laws/incoming_laws, group, overwrite, forced)
	if(check_antag_blocker(group, forced)
		return
	if(group == LAW_ZEROTH)
		if(zeroth)
			zeroth = overwrite ? incoming_laws.zeroth : zeroth
			zeroth_borg = overwrite ? incoming_laws.zeroth_borg : zeroth_borg
		else
			zerroth = incoming_laws.zeroth
			zeroth_borg = incoming_laws.zeroth_borg
		return
	var/overflow
	if(check_lawcap_blocker(incoming_laws[group].len, overwrite)
		overflow = TRUE
	. = TRUE
	if(overflow)
		laws[group] = incoming_laws[group] | laws[group]
		laws[group].Cut(DYNAMIC_LAW_CAP + 1)
	else if(overwrite)
		laws[group] = incoming_laws[group].Copy()
	else
		laws[group] |= incoming_laws[group]

/* join_law_groups()
joins a list of multiple law groups from a supplied ai_laws datum to this datum's laws
*/
/datum/ai_laws/proc/join_law_groups(datum/ai_laws/_incoming_laws, list/_groups, _overwrite, _forced)
	for(var/group in _groups)
		join_single_law_group(_incoming_laws, group, _overwrite, _forced)

/* insert_law()
inserts a supplied law into a supplied law group at the specified position
If position is not supplied the proc adds to the end of the law group.
When overwrite is true, the insertion will replace the law at [position]
with the supplied law. If position is greater than or equal to the length of the law group,
it instead gets added at the end regardless of whether overwrite = TRUE
In the event that the group being modified is one of the dynamic groups
and the number of laws in this group would exceed the cap, the group will
"overflow" and overwrite the first law in this group. This is intended behavior.
*/
/datum/ai_laws/proc/insert_law(law, group, position, overwite, forced)
	if(check_antag_blocker(group, forced)
		return
	if(group == LAW_ZEROTH)
		if(zeroth)
			zeroth = overwrite ? law : zeroth
			zeroth_borg = null
		else
			zerroth = law
			zeroth_borg = null
	if(check_lawcap_blocker(group, incoming_laws[group].len, overwrite)
		overwrite = TRUE
		position = 1 // the law overflows to
	. = TRUE
	if(!position || position >= laws[group].len)
		laws[group] += law
		return
	if(overwrite)
		laws[group][position] = law
		return
	laws[group].Insert(position, law)


/* remove_law_from_group()
removes a supplied law from a specified group. If the group is zeroth,
we make the zeroth law null if it matches either the borg or the standard zeroth
otherwise we remove the law if its found in the specified group
*/
/datum/ai_laws/proc/remove_law_from_group(law, group, forced)
	if(check_antag_blocker(group, forced))
		return
	if((group == LAW_ZEROTH)
		if((zeroth == law) || (zeroth_borg == law))
			zeroth = null
			zeroth_borg = null
			return TRUE
		return
	if(law in laws[group])
		laws[group] -= law
		return TRUE


/* check_antag_blocker()
checks if modification of a particular law group is permitted
returns TRUE if it's an antag law group and the owner of these
laws is an antag, forced = TRUE bypasses this check.
*/
/datum/ai_laws/proc/check_antag_blocker(group, forced)
	if(forced)
		return FALSE
	if(group in ANTAG_LAW_GROUPS)
		if(owner?.mind?.special_role)
			return TRUE

/* check_lawcap_blocker()
checks if adding [laws_to_add] to this group will cause it to overflow
returns TRUE if the supplied group is one of the capped groups (those
are the ones that can be abitrarily changed in-game witout badminnery),
and laws to be addded would put it over the cap. If overwrite is TRUE
and the number of laws to be added isn't above the cap, it will return
FALSE since the cap won't be violated
*/
/datum/ai_laws/proc/check_lawcap_blocker(group, laws_to_add, overwrite = FALSE)
	if(laws_to_add && (group in (LAWS_SUPPLIED|LAWS_ERROR))
		if(laws_to_add > LAW_GROUP_NUMBER_CAP)
			return TRUE
		var/final_len = laws[group].len + laws_to_add
		if(final_len > LAW_GROUP_NUMBER_CAP)
			return !overwrite


/* get_numbering_modifier()
gets the numbering offset for one of the conventionally numbered law groups
*/
/datum/ai_laws/proc/get_numbering_modifier(group)
	. = 0
	var/list/groups = NORMAL_LAW_GROUPS
	if(!(group in groups)))
		return
	for(var/selected_group in groups)
		if(selected_group == group)
			return
		. += laws[group].len

/* remove_law_by_number()
removes a law by its display position in the user facing law list
this will not remove zeroth laws or hacked/ion laws, just normal numbered laws
forced determines whether this will bypass the antag_blocker() check
*/
/datum/ai_laws/proc/remove_law_by_number(law_number)
	var/target_group = LAW_INHERENT
	var/list/groups = NORMAL_LAW_GROUPS
	for(var/group in groups)
		if((laws[group].len + get_numbering_modifier(group)) >= law_number)
			break
		target_group = group
	if(!laws[target_group].len)
		return
	var/target_law = laws[target_group][law_number - get_numbering_modifier(target_group, groups)]
	return remove_law_from_group(target_law, target_group, forced)

/* get_law_list_from_group()
returns the list of laws in a given
law group, if include formatting is TRUE
then the laws will be formatted for chat
otherwise it will be a plaintext list
*/
/datum/ai_laws/proc/get_law_list_from_group(group, include_formatting, use_borg_zeroth)
	. = list()
	var/data
	if(group == LAW_ZEROTH)
		if(use_borg_zeroth)
			data = zeroth_borg ? zeroth_borg : zeroth
		else
			data = zeroth
		if(!data)
			return
		if(include_formatting)
			data = format_law(data, group)
		. += data
		return
	if(!laws[group].len)
		return
	for(var/i = 1, i <= laws[group].len, i++)
		data = laws[group][i]
		if(include_formatting)
			data = format_law(data, group, i)
		. += data

/* format_law()
Applies color and numbering formatting to a law to be sent to chat
*/
/datum/ai_laws/format_law(law, law_group, law_index)
	switch(law_group)
		if(LAW_ZEROTH)
			return "0: <font color='#ff0000'><b>[law]</b></font>"
		if(LAW_DEVIL)
			return "666: <font color='#cc5500'>[law]</font>"
		if(LAW_HACKED)
			return "[ionnum()]: <font color='#660000'>[law]</font>"
		if(LAW_ION)
			return "[ionnum()]: <font color='#547DFE'>[law]</font>"
		if(LAW_INHERENT)
			return "[index + get_numbering_modifier(law_group)]: [law]"
		else
			return "[index + get_numbering_modifier(law_group)]: <font color='#990099'>[law]</font>"


/* get_law_list()
gets all of the laws in a supplied list of groups. If include_formatting = TRUE,
they will be formatted for chat. If use_borg_zeroth is TRUE, it will display a borg zeroth
law if one is present
*/
/datum/ai_laws/get_laws(list/groups_included, include_formatting, use_borg_zeroth)
	if(!groups_included)
		groups_included = NONSECRET_LAW_GROUPS
	. = list()
	for(var/group in groups_included)
		. += get_law_list_from_group(group, include_formatting, use_borg_zeroth)


/datum/ai_laws/proc/clear_supplied_laws(include_core = FALSE)
	LAZYCLEARLIST(supplied)
	if(include_core)
		LAZYCLEARLIST(core)


/datum/ai_laws/proc/clear_ion_laws()
	LAZYCLEARLIST(ion)

/datum/ai_laws/proc/clear_hacked_laws()
	LAZYCLEARLIST(hacked)

/datum/ai_laws/proc/show_laws(_include_zeroth = SHOW_ZEROTH, _show_numbers = TRUE)
	var/list/printable_laws = get_law_list(_include_zeroth, _show_numbers)
	for(var/law in printable_laws)
		to_chat(who,law)

/datum/ai_laws/proc/clear_zeroth_law(force) //only removes zeroth from antag ai if force is 1
	if(force)
		zeroth = null
		zeroth_borg = null
		return
	if(owner?.mind?.special_role)
		return
	if (istype(owner, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/A=owner
		if(A?.deployed_shell?.mind?.special_role)
			return
	zeroth = null
	zeroth_borg = null

/datum/ai_laws/proc/clear_law_sixsixsix(force)
	if(force || !is_devil(owner))
		devillaws = initial(devillaws)

/datum/ai_laws/proc/clear_all_laws(forced)
	clear_inherent_laws()
	clear_supplied_laws()
	clear_hacked_laws()
	clear_ion_laws()
	clear_zeroth_law(forced)
	clear_law_sixsixsix(forced)

/datum/ai_laws/proc/reset_laws(forced)
	clear_all_laws(forced)
	inherent_laws = initial(inherent_laws)

/datum/ai_laws/proc/associate(mob/living/silicon/M)
	if(!owner)
		owner = M

/datum/ai_laws/proc/get_law_list(include_zeroth = HIDE_ZEROTH_LAW, show_numbers = TRUE)
	var/list/data = list()

	if (include_zeroth && devillaws)
		for(var/i in devillaws)
			if(length(i) > 0)
				data += "[show_numbers ? "666:" : ""] <font color='#cc5500'>[i]</font>"

	if (include_zeroth && zeroth)
		var/to_show = zeroth_borg && (include_zeroth == SHOW_ZEROTH_BORG) ? zeroth_borg : zeroth
		data += "[show_numbers ? "0:" : ""] <font color='#ff0000'><b>[to_show]</b></font>"

	for(var/law in hacked)
		if (length(law) > 0)
			var/num = ionnum()
			data += "[show_numbers ? "[num]:" : ""] <font color='#660000'>[law]</font>"

	for(var/law in ion)
		if (length(law) > 0)
			var/num = ionnum()
			data += "[show_numbers ? "[num]:" : ""] <font color='#547DFE'>[law]</font>"

	var/number = 1
	for(var/law in inherent)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law]"
			number++

	for(var/law in supplied)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] <font color='#990099'>[law]</font>"
			number++
	return data


// checks whether two lawsets match each other exactly
/datum/ai_laws/proc/check_identical_laws(datum/ai_laws/supplied_laws)
	if(!supplied_laws || supplied_laws.is_empty_laws())
		return is_empty_laws()
	var/list/our_laws = get_law_list(TRUE, TRUE)
	var/list/their_laws = supplied_laws.get_law_list(TRUE, TRUE)


	if(our_laws.len != their_laws.len)
		return FALSE
	for(var/i = 1, i <= our_laws.len, i++)
		if(our_laws[i] == their_laws[i])
			continue
		return FALSE
	return TRUE

// copies the information of one lawset directly to another, including inherent laws
/datum/ai_laws/proc/copy_laws(datum/ai_laws/supplied_laws, include_zeroth = TRUE, forced = FALSE)
	name = supplied_laws.name
	id = supplied_laws.id
	inherent = supplied_laws.inherent.Copy()
	supplied = supplied_laws.supplied.Copy()
	ion = supplied_laws.ion.Copy()
	hacked = supplied_laws.hacked.Copy()
	if(owner?.mind?.special_role)
		include_zeroth = forced
	if(include_zeroth)
		if(supplied_laws.zeroth)
			zeroth = supplied_laws.zeroth
		else
			zeroth = null
		if(supplied_laws.zeroth_borg)
			zeroth_borg = supplied_laws.zeroth_borg
		else
			zeroth_borg = null
		if(supplied_laws.devillaws)
			devillaws = supplied_laws.devillaws.Copy()
		else
			devillaws = initial(devillaws)

// merges two lawsets together. If override is TRUE, laws at a particular index will be replaced with the supplied law
//otherwise they will be appended at the end of the law list
/datum/ai_laws/proc/merge_laws(datum/ai_laws/supplied_laws, include_zeroth = TRUE, override = FALSE, forced = FALSE)
	inherent = merge_law_lists(inherent, supplied_laws.inherent, override)
	supplied = merge_law_lists(supplied, supplied_laws.supplied, override)
	ion = merge_law_lists(ion, supplied_laws.ion, override)
	hacked = merge_law_lists(hacked, supplied_laws.hacked, override)
	if(owner?.mind?.special_role) // antags will only get zeroth laws modified if forced is TRUE
		include_zeroth = forced
	if(include_zeroth)
		if(supplied_laws.zeroth)
			zeroth = override ? supplied_laws.zeroth : zeroth
		if(supplied_laws.zeroth_borg)
			zeroth_borg = overide ? supplied_laws.zeroth_borg : zeroth_borg
		if(supplied_laws.devillaws?.len >= 1)
			devillaws = merge_law_lists(supplied_laws.devillaws, override)

// merges two law lists together; returns an empty list if empty or null lists are supplied (ie if the lawlists being compared is devilaws and neither lawset has them)
/datum/ai_laws/proc/merge_law_lists(list/our_law_list, list/their_law_list, override = FALSE)
	. = list()
	if(our_law_list && our_law_list.len >= 1)
		. |= our_law_list
	else
		if(their_law_list && their_law_list.len >= 1)
		. |= their_law_list
		return
	if(their_law_list && their_law_list.len >= 1)
		if(!override)
			. |= their_law_list
			return
		for(var/i, i <= their_law_list.len, i++)
			if(their_law_list[i] in .)
				continue
			if(.[i])
				.[i] = their_law_list[i]
			else
				. += their_law_list[i]

//returns true if this lawset is empty
/datum/ai_laws/proc/is_empty_laws()
	if(inherent.len >= 1)
		return
	if(supplied.len >= 1)
		return
	if(ion.len >= 1)
		return
	if(hacked.len >= 1)
		return
	if(devillaws.len >= 1)
		return
	if(zeroth || zeroth_borg)
		return
	return TRUE
