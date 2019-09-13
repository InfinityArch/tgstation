/proc/random_blood_type()
	return pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

/proc/random_eye_color()
	switch(pick(20;"brown",20;"hazel",20;"grey",15;"blue",15;"green",1;"amber",1;"albino"))
		if("brown")
			return "630"
		if("hazel")
			return "542"
		if("grey")
			return pick("666","777","888","999","aaa","bbb","ccc")
		if("blue")
			return "36c"
		if("green")
			return "060"
		if("amber")
			return "fc0"
		if("albino")
			return pick("c","d","e","f") + pick("0","1","2","3","4","5","6","7","8","9") + pick("0","1","2","3","4","5","6","7","8","9")
		else
			return "000"

/proc/random_underwear(gender)
	if(!GLOB.underwear_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	switch(gender)
		if(MALE)
			return pick(GLOB.underwear_m)
		if(FEMALE)
			return pick(GLOB.underwear_f)
		else
			return pick(GLOB.underwear_list)

/proc/random_undershirt(gender)
	if(!GLOB.undershirt_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f)
	switch(gender)
		if(MALE)
			return pick(GLOB.undershirt_m)
		if(FEMALE)
			return pick(GLOB.undershirt_f)
		else
			return pick(GLOB.undershirt_list)

/proc/random_socks()
	if(!GLOB.socks_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, GLOB.socks_list)
	return pick(GLOB.socks_list)


/proc/random_backpack()
	return pick(GLOB.backpacklist)

/*
# Ranom features

__description__
- this proc generates random features for use in dna, either de novo or from an input list.
- because its (allegedly) possible for this proc to be fired before datum/sprite_accessories has been loaded,
- this proc checks for initialization of the relevant global lists and runs their initializaiton proc as needed 

__Arguments__
*features*: typically a list of sprite features found in datum/dna, if not given one will be generated de novo
*species*: the species datum that should be used to deermine feature eligability, defaults to human (all features set to none) if not supplied
*features_to_randomize*: a list of features that should be sanitized, defaults to *features* if not given. See /proc/random_features in the mobs.dm helper for an example of what that full list entails

__Returns__: 
- if supplied with an input list, returns *features* with indices found in *features_to_randomize* randomized according to the species' permitted features
- returns a de novo list of features if not supplied with an input list, with inidices in *features_to_randomize* being randomized and all others benig left as defaults, typically "None"
*/

/proc/random_features(list/features, var/datum/species/S = new /datum/species/human, list/features_to_randomize)
	if(!GLOB.tails_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails, GLOB.tails_list, species_list = GLOB.tails_list_species)
	if(!GLOB.snouts_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, GLOB.snouts_list, species_list = GLOB.snouts_list_species)
	if(!GLOB.horns_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/horns, GLOB.horns_list, species_list = GLOB.horns_list_species)
	if(!GLOB.ears_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, GLOB.ears_list, species_list = GLOB.ears_list_species)
	if(!GLOB.frills_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, GLOB.frills_list, species_list = GLOB.frills_list_species)
	if(!GLOB.tail_accessory_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tail_accessory, GLOB.tail_accessory_list, species_list = GLOB.tail_accessory_list_species)
	if(!GLOB.legs_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, GLOB.legs_list, species_list = GLOB.legs_list_species)
	if(!GLOB.body_markings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.body_markings_list, species_list = GLOB.body_markings_list_species)
	if(!GLOB.wings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.wings_list, species_list = GLOB.wings_list_species)
	if(!GLOB.caps_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/caps, GLOB.caps_list)

	var/temp_index // this is used to store whether the current feature to randomize has a valid entry in its global species list under the species' features_id index
	if(!features || !features.len)
		features = DEFAULT_FEATURES_LIST
	if(!features_to_randomize || !features_to_randomize.len)
		features_to_randomize = features
	if("mcolor" in features_to_randomize)
		features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	if("tail" in features_to_randomize)
		temp_index = "tail" in S.mutant_bodyparts ? S.features_id : DEFAULT_SPECIES_INDEX
		features["tail"] = pick(GLOB.tails_list_species[temp_index])
	if("wings" in features_to_randomize)
		temp_index = "wings" in S.mutant_bodyparts ? S.features_id : DEFAULT_SPECIES_INDEX
		features["wings"] = pick(GLOB.wings_list_species[temp_index])
	if("snout" in features_to_randomize)
		temp_index = "tail" in S.mutant_bodyparts ? S.features_id : DEFAULT_SPECIES_INDEX
		features["snout"] = pick(GLOB.snouts_list_species[temp_index])
	if("horns" in features_to_randomize)
		temp_index = "horns" in S.mutant_bodyparts ? S.features_id : DEFAULT_SPECIES_INDEX
		features["horns"] = pick(GLOB.horns_list_species[temp_index] | GLOB.horns_list_species[DEFAULT_SPECIES_INDEX])
	if("ears" in features_to_randomize)
		temp_index = "ears" in S.mutant_bodyparts ? S.features_id : DEFAULT_SPECIES_INDEX
		features["ears"] = pick(GLOB.ears_list_species[temp_index])
	if("frills" in features_to_randomize)
		temp_index = "frills" in S.mutant_bodyparts ? S.features_id : DEFAULT_SPECIES_INDEX
		features["frills"] = pick(GLOB.frills_list_species[temp_index] | GLOB.frills_list_species[DEFAULT_SPECIES_INDEX])
	if("tail_accessory" in features_to_randomize)
		temp_index = "tail_accessory" in S.mutant_bodyparts ? S.features_id : DEFAULT_SPECIES_INDEX
		features["tail_accessory"] = pick(GLOB.tail_accessory_list_species[S.features_id] | GLOB.tail_accessory_list_species[DEFAULT_SPECIES_INDEX])
	if("body_markings" in features_to_randomize)
		temp_index = "body_markings" in S.mutant_bodyparts ? S.features_id : DEFAULT_SPECIES_INDEX
		features["body_markings"] = pick(GLOB.body_markings_list_species[S.features_id] | GLOB.body_markings_list_species[DEFAULT_SPECIES_INDEX])
	if("legs" in S.mutant_bodyparts)
		temp_index = "legs" in S.mutant_bodyparts ? S.features_id : DEFAULT_SPECIES_INDEX
		features["legs"] = pick(GLOB.legs_list | GLOB.legs_list_species[DEFAULT_SPECIES_INDEX])
	if("caps" in S.mutant_bodyparts)
		features["caps"] = pick(GLOB.caps_list)
	return features

/proc/random_hairstyle(gender, species_index = "default")
	var/list/species_list = GLOB.hairstyles_list_species[DEFAULT_SPECIES_INDEX]
	if(GLOB.hairstyles_list_species[species_index])
		species_list |= GLOB.hairstyles_list_species[species_index]
	switch(gender)
		if(MALE)
			return pick(GLOB.hairstyles_male_list & species_list)
		if(FEMALE)
			return pick(GLOB.hairstyles_female_list & species_list)
		else
			return pick(GLOB.hairstyles_list & species_list)

/proc/random_facial_hairstyle(gender, species_index = "default")
	var/list/species_list = GLOB.facial_hairstyles_list_species[DEFAULT_SPECIES_INDEX]
	if(GLOB.facial_hairstyles_list_species[species_index])
		species_list |= GLOB.facial_hairstyles_list_species[species_index]
	switch(gender)
		if(MALE)
			return pick(GLOB.facial_hairstyles_male_list & species_list)
		if(FEMALE)
			return pick(GLOB.facial_hairstyles_female_list & species_list)
		else
			return pick(GLOB.facial_hairstyles_list & species_list)

/proc/random_unique_name(gender, attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		if(gender==FEMALE)
			. = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else
			. = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

		if(!findname(.))
			break

/proc/random_unique_lizard_name(gender, attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(lizard_name(gender))

		if(!findname(.))
			break

/proc/random_unique_plasmaman_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(plasmaman_name())

		if(!findname(.))
			break

/proc/random_unique_ethereal_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(ethereal_name())

		if(!findname(.))
			break

/proc/random_unique_moth_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(pick(GLOB.moth_first)) + " " + capitalize(pick(GLOB.moth_last))

		if(!findname(.))
			break

/proc/random_skin_tone(species_index = DEFAULT_SPECIES_INDEX)
	if(species_index && GLOB.skin_tones_list_species[species_index])
		return pick(GLOB.skin_tones_list_species[species_index])
	else
		return pick(GLOB.skin_tones_list_species[DEFAULT_SPECIES_INDEX])

GLOBAL_LIST_EMPTY(species_list)

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)
			return "infant"
		if(1 to 3)
			return "toddler"
		if(3 to 13)
			return "child"
		if(13 to 19)
			return "teenager"
		if(19 to 30)
			return "young adult"
		if(30 to 45)
			return "adult"
		if(45 to 60)
			return "middle-aged"
		if(60 to 70)
			return "aging"
		if(70 to INFINITY)
			return "elderly"
		else
			return "unknown"

/proc/do_mob(mob/user , mob/target, time = 30, uninterruptible = 0, progress = 1, datum/callback/extra_checks = null)
	if(!user || !target)
		return 0
	var/user_loc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/target_loc = target.loc

	var/holding = user.get_active_held_item()
	var/datum/progressbar/progbar
	if (progress)
		progbar = new(user, time, target)

	var/endtime = world.time+time
	var/starttime = world.time
	. = 1
	while (world.time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime)
		if(QDELETED(user) || QDELETED(target))
			. = 0
			break
		if(uninterruptible)
			continue

		if(drifting && !user.inertia_dir)
			drifting = 0
			user_loc = user.loc

		if((!drifting && user.loc != user_loc) || target.loc != target_loc || user.get_active_held_item() != holding || user.incapacitated() || (extra_checks && !extra_checks.Invoke()))
			. = 0
			break
	if (progress)
		qdel(progbar)


//some additional checks as a callback for for do_afters that want to break on losing health or on the mob taking action
/mob/proc/break_do_after_checks(list/checked_health, check_clicks)
	if(check_clicks && next_move > world.time)
		return FALSE
	return TRUE

//pass a list in the format list("health" = mob's health var) to check health during this
/mob/living/break_do_after_checks(list/checked_health, check_clicks)
	if(islist(checked_health))
		if(health < checked_health["health"])
			return FALSE
		checked_health["health"] = health
	return ..()

/proc/do_after(mob/user, var/delay, needhand = 1, atom/target = null, progress = 1, datum/callback/extra_checks = null)
	if(!user)
		return 0
	var/atom/Tloc = null
	if(target && !isturf(target))
		Tloc = target.loc

	var/atom/Uloc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/holding = user.get_active_held_item()

	var/holdingnull = 1 //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = 0 //Users hand started holding something, check to see if it's still holding that

	delay *= user.do_after_coefficent()

	var/datum/progressbar/progbar
	if (progress)
		progbar = new(user, delay, target)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = 1
	while (world.time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime)

		if(drifting && !user.inertia_dir)
			drifting = 0
			Uloc = user.loc

		if(QDELETED(user) || user.stat || (!drifting && user.loc != Uloc) || (extra_checks && !extra_checks.Invoke()))
			. = 0
			break

		if(isliving(user))
			var/mob/living/L = user
			if(L.IsStun() || L.IsParalyzed())
				. = 0
				break

		if(!QDELETED(Tloc) && (QDELETED(target) || Tloc != target.loc))
			if((Uloc != Tloc || Tloc != user) && !drifting)
				. = 0
				break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull)
				if(!holding)
					. = 0
					break
			if(user.get_active_held_item() != holding)
				. = 0
				break
	if (progress)
		qdel(progbar)

/mob/proc/do_after_coefficent() // This gets added to the delay on a do_after, default 1
	. = 1
	return

/proc/do_after_mob(mob/user, list/targets, time = 30, uninterruptible = 0, progress = 1, datum/callback/extra_checks, required_mobility_flags = MOBILITY_STAND)
	if(!user || !targets)
		return 0
	if(!islist(targets))
		targets = list(targets)
	var/user_loc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/list/originalloc = list()
	for(var/atom/target in targets)
		originalloc[target] = target.loc

	var/holding = user.get_active_held_item()
	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, time, targets[1])

	var/endtime = world.time + time
	var/starttime = world.time
	var/mob/living/L
	if(isliving(user))
		L = user
	. = 1
	mainloop:
		while(world.time < endtime)
			stoplag(1)
			if(progress)
				progbar.update(world.time - starttime)
			if(QDELETED(user) || !targets)
				. = 0
				break
			if(uninterruptible)
				continue

			if(drifting && !user.inertia_dir)
				drifting = 0
				user_loc = user.loc

			if(L && !CHECK_MULTIPLE_BITFIELDS(L.mobility_flags, required_mobility_flags))
				. = 0
				break

			for(var/atom/target in targets)
				if((!drifting && user_loc != user.loc) || QDELETED(target) || originalloc[target] != target.loc || user.get_active_held_item() != holding || user.incapacitated() || (extra_checks && !extra_checks.Invoke()))
					. = 0
					break mainloop
	if(progbar)
		qdel(progbar)

/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.dna && istype(H.dna.species, species_datum))
			. = TRUE

/proc/spawn_atom_to_turf(spawn_type, target, amount, admin_spawn=FALSE, list/extra_args)
	var/turf/T = get_turf(target)
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	var/list/new_args = list(T)
	if(extra_args)
		new_args += extra_args
	var/atom/X
	for(var/j in 1 to amount)
		X = new spawn_type(arglist(new_args))
		if (admin_spawn)
			X.flags_1 |= ADMIN_SPAWNED_1
	return X //return the last mob spawned

/proc/spawn_and_random_walk(spawn_type, target, amount, walk_chance=100, max_walk=3, always_max_walk=FALSE, admin_spawn=FALSE)
	var/turf/T = get_turf(target)
	var/step_count = 0
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	var/list/spawned_mobs = new(amount)

	for(var/j in 1 to amount)
		var/atom/movable/X

		if (istype(spawn_type, /list))
			var/mob_type = pick(spawn_type)
			X = new mob_type(T)
		else
			X = new spawn_type(T)

		if (admin_spawn)
			X.flags_1 |= ADMIN_SPAWNED_1

		spawned_mobs[j] = X

		if(always_max_walk || prob(walk_chance))
			if(always_max_walk)
				step_count = max_walk
			else
				step_count = rand(1, max_walk)

			for(var/i in 1 to step_count)
				step(X, pick(NORTH, SOUTH, EAST, WEST))

	return spawned_mobs

// Displays a message in deadchat, sent by source. Source is not linkified, message is, to avoid stuff like character names to be linkified.
// Automatically gives the class deadsay to the whole message (message + source)
/proc/deadchat_broadcast(message, source=null, mob/follow_target=null, turf/turf_target=null, speaker_key=null, message_type=DEADCHAT_REGULAR)
	message = "<span class='deadsay'>[source]<span class='linkify'>[message]</span></span>"
	for(var/mob/M in GLOB.player_list)
		var/datum/preferences/prefs
		if(M.client && M.client.prefs)
			prefs = M.client.prefs
		else
			prefs = new

		var/override = FALSE
		if(M.client && M.client.holder && (prefs.chat_toggles & CHAT_DEAD))
			override = TRUE
		if(HAS_TRAIT(M, TRAIT_SIXTHSENSE))
			override = TRUE
		if(isnewplayer(M) && !override)
			continue
		if(M.stat != DEAD && !override)
			continue
		if(speaker_key && speaker_key in prefs.ignoring)
			continue

		switch(message_type)
			if(DEADCHAT_DEATHRATTLE)
				if(prefs.toggles & DISABLE_DEATHRATTLE)
					continue
			if(DEADCHAT_ARRIVALRATTLE)
				if(prefs.toggles & DISABLE_ARRIVALRATTLE)
					continue

		if(isobserver(M))
			var/rendered_message = message

			if(follow_target)
				var/F
				if(turf_target)
					F = FOLLOW_OR_TURF_LINK(M, follow_target, turf_target)
				else
					F = FOLLOW_LINK(M, follow_target)
				rendered_message = "[F] [message]"
			else if(turf_target)
				var/turf_link = TURF_LINK(M, turf_target)
				rendered_message = "[turf_link] [message]"

			to_chat(M, rendered_message)
		else
			to_chat(M, message)

//Used in chemical_mob_spawn. Generates a random mob based on a given gold_core_spawnable value.
/proc/create_random_mob(spawn_location, mob_class = HOSTILE_SPAWN)
	var/static/list/mob_spawn_meancritters = list() // list of possible hostile mobs
	var/static/list/mob_spawn_nicecritters = list() // and possible friendly mobs

	if(mob_spawn_meancritters.len <= 0 || mob_spawn_nicecritters.len <= 0)
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			switch(initial(SA.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += T
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += T

	var/chosen
	if(mob_class == FRIENDLY_SPAWN)
		chosen = pick(mob_spawn_nicecritters)
	else
		chosen = pick(mob_spawn_meancritters)
	var/mob/living/simple_animal/C = new chosen(spawn_location)
	return C

/proc/passtable_on(target, source)
	var/mob/living/L = target
	if (!HAS_TRAIT(L, TRAIT_PASSTABLE) && L.pass_flags & PASSTABLE)
		ADD_TRAIT(L, TRAIT_PASSTABLE, INNATE_TRAIT)
	ADD_TRAIT(L, TRAIT_PASSTABLE, source)
	L.pass_flags |= PASSTABLE

/proc/passtable_off(target, source)
	var/mob/living/L = target
	REMOVE_TRAIT(L, TRAIT_PASSTABLE, source)
	if(!HAS_TRAIT(L, TRAIT_PASSTABLE))
		L.pass_flags &= ~PASSTABLE
