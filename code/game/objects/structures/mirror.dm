//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = FALSE
	anchored = TRUE
	max_integrity = 200
	integrity_failure = 0.5

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	if(icon_state == "mirror_broke" && !broken)
		obj_break(null, mapload)

/obj/structure/mirror/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(broken || !Adjacent(user))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!(FACEHAIR in H.dna.species.species_traits) && !(HAIR in H.dna.species.species_traits))
			return

		//see code/modules/mob/dead/new_player/preferences.dm at approx line 545 for comments!
		//this is largely copypasted from there.

		//handle facial hair
		if(FACEHAIR in H.dna.species.species_traits)
			var/new_facial_hairstyle
			switch(gender)
				if(FEMALE)
					if(length(GLOB.facial_hairstyles_list_species[H.dna.species.hair_id] & GLOB.facial_hairstyles_female_list))
						new_facial_hairstyle = input(user, "Select a facial hairstyle", "Grooming")  as null|anything in GLOB.facial_hairstyles_list_species[DEFAULT_SPECIES_INDEX] | (GLOB.facial_hairstyles_female_list & GLOB.facial_hairstyles_list_species[H.dna.species.hair_id])
						if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
							return	//no tele-grooming
				if(MALE)
					if(length(GLOB.facial_hairstyles_list_species[H.dna.species.hair_id] & GLOB.facial_hairstyles_male_list))
						new_facial_hairstyle = input(user, "Select a facial hairstyle", "Grooming")  as null|anything in GLOB.facial_hairstyles_list_species[DEFAULT_SPECIES_INDEX] | (GLOB.facial_hairstyles_male_list & GLOB.facial_hairstyles_list_species[H.dna.species.hair_id])
						if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
							return
				else
					if(length(GLOB.facial_hairstyles_list_species[H.dna.species.hair_id]))
						new_facial_hairstyle = input(user, "Select a facial hairstyle", "Grooming")  as null|anything in GLOB.facial_hairstyles_list_species[DEFAULT_SPECIES_INDEX] | (GLOB.facial_hairstyles_list_species[H.dna.species.hair_id])
			if(new_facial_hairstyle)
				H.facial_hairstyle = new_facial_hairstyle
				H.regenerate_icons()

		//handle normal hair
		if(HAIR in H.dna.species.species_traits)
			var/new_hairstyle
			switch(gender)
				if(FEMALE)
					if(length(GLOB.hairstyles_list_species[H.dna.species.hair_id] & GLOB.hairstyles_female_list))
						new_hairstyle = input(user, "Select a hairstyle", "Grooming")  as null|anything in GLOB.hairstyles_list_species[DEFAULT_SPECIES_INDEX] | (GLOB.hairstyles_female_list & GLOB.hairstyles_list_species[H.dna.species.hair_id])
						if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
							return
				if(MALE)
					if(length(GLOB.hairstyles_list_species[H.dna.species.hair_id] & GLOB.hairstyles_male_list))
						new_hairstyle = input(user, "Select a hairstyle", "Grooming")  as null|anything in GLOB.hairstyles_list_species[DEFAULT_SPECIES_INDEX] | (GLOB.hairstyles_male_list & GLOB.hairstyles_list_species[H.dna.species.hair_id])
						if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
							return
				else
					if(length(GLOB.hairstyles_list_species[H.dna.species.hair_id]))
						new_hairstyle = input(user, "Select a hairstyle", "Grooming")  as null|anything in GLOB.hairstyles_list_species[DEFAULT_SPECIES_INDEX] | (GLOB.hairstyles_list_species[H.dna.species.hair_id])
			if(new_hairstyle)
				if(HAS_TRAIT(H, TRAIT_BALD))
					to_chat(H, "<span class='notice'>If only growing back hair were that easy for you...</span>")
				else
					H.hairstyle = new_hairstyle
					H.regenerate_icons()


/obj/structure/mirror/examine_status(mob/user)
	if(broken)
		return list()// no message spam
	return ..()

/obj/structure/mirror/obj_break(damage_flag, mapload)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		icon_state = "mirror_broke"
		if(!mapload)
			playsound(src, "shatter", 70, TRUE)
		if(desc == initial(desc))
			desc = "Oh no, seven years of bad luck!"
		broken = TRUE

/obj/structure/mirror/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			new /obj/item/shard( src.loc )
	qdel(src)

/obj/structure/mirror/welder_act(mob/living/user, obj/item/I)
	..()
	if(user.a_intent == INTENT_HARM)
		return FALSE

	if(!broken)
		return TRUE

	if(!I.tool_start_check(user, amount=0))
		return TRUE

	to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
	if(I.use_tool(src, user, 10, volume=50))
		to_chat(user, "<span class='notice'>You repair [src].</span>")
		broken = 0
		icon_state = initial(icon_state)
		desc = initial(desc)

	return TRUE

/obj/structure/mirror/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
		if(BURN)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)


/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Turn and face the strange... face."
	icon_state = "magic_mirror"
	var/list/choosable_races = list()

/obj/structure/mirror/magic/New()
	if(!choosable_races.len)
		for(var/speciestype in subtypesof(/datum/species))
			var/datum/species/S = speciestype
			if(initial(S.changesource_flags) & MIRROR_MAGIC)
				choosable_races += initial(S.id)
		choosable_races = sortList(choosable_races)
	..()

/obj/structure/mirror/magic/lesser/New()
	choosable_races = GLOB.roundstart_races.Copy()
	..()

/obj/structure/mirror/magic/badmin/New()
	for(var/speciestype in subtypesof(/datum/species))
		var/datum/species/S = speciestype
		if(initial(S.changesource_flags) & MIRROR_BADMIN)
			choosable_races += initial(S.id)
	..()

/obj/structure/mirror/magic/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/list/choose_from = list("name", "species")
	if(!(AGENDER in H.dna.species.species_traits))
		choose_from += "gender"
	if(HAIR in H.dna.species.species_traits)
		choose_from += "hair"
	if(FACEHAIR in H.dna.species.species_traits)
		choose_from += "facial hair"
	if(MUTCOLORS in H.dna.species.species_traits)
		choose_from += "body color"
	if((SKIN_TONE in H.dna.species.species_traits) || (DYNCOLORS in H.dna.species.species_traits))
		choose_from += "skin tone"
	if(!(NOEYESPRITES in H.dna.species.species_traits))
		choose_from += "eye color"

	for(var/feature in H.dna.features)
		if(feature in H.dna.species.mutant_bodyparts)
			choose_from += feature

	var/choice = input(user, "Something to change?", "Magical Grooming") as null|anything in choose_from

	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	switch(choice)
		if("name")
			var/newname = sanitize_name(reject_bad_text(stripped_input(H, "Who are we again?", "Name change", H.name, MAX_NAME_LEN)))
			if(!newname)
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			H.real_name = newname
			H.name = newname
			if(H.dna)
				H.dna.real_name = newname
			if(H.mind)
				H.mind.name = newname

		if("species")
			var/newrace
			var/racechoice = input(H, "What are we again?", "Species change") as null|anything in choosable_races
			newrace = GLOB.species_list[racechoice]

			if(!newrace)
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			H.set_species(newrace)

		if("skin tone")
			var/new_s_tone = input(user, "Choose your [H.dna.species.feature_names["skin_tone"]]", "Skin tone change")  as null|anything in GLOB.skin_tones_list_species[H.dna.species.limbs_id]
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return

			if(new_s_tone)
				H.skin_tone = new_s_tone
				H.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)

		if("body color")
			var/new_mutantcolor = input(user, "Choose your body color:", "Body color change","#"+H.dna.features["mcolor"]) as color|null
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_mutantcolor)
				var/temp_hsv = RGBtoHSV(new_mutantcolor)

				if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright
					H.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)

				else
					to_chat(H, "<span class='notice'>Invalid color. Your color is not bright enough.</span>")

		if("gender")
			var/list/friendlyGenders = list("Male" = "male", "Female" = "female", "Other" = "plural")
			var/pickedGender = input(user, "Choose your gender.", "gender change", gender) as null|anything in friendlyGenders
			if(pickedGender && friendlyGenders[pickedGender] != H.gender)
				H.gender = friendlyGenders[pickedGender]
				if(H.gender == "male")
					to_chat(H, "<span class='notice'>Whoa man, you feel like a man!</span>")
					H.underwear = sanitize_inlist(H.underwear, GLOB.underwear_m)
					H.undershirt = sanitize_inlist(H.undershirt, GLOB.undershirt_m)
				else if(H.gender == "female")
					to_chat(H, "<span class='notice'>Man, you feel like a woman!</span>")
					H.underwear = sanitize_inlist(H.underwear, GLOB.underwear_f)
					H.undershirt = sanitize_inlist(H.undershirt, GLOB.undershirt_f)
				else
					to_chat(H, "<span class='notice'>You feel liberated from traditional gender norms!</span>")
				if(HAIR in H.dna.species.species_traits)
					H.hairstyle = sanitize_hairstyle(H.hairstyle, H.dna.species.hair_id, H.gender)
					H.dna.update_ui_block(DNA_HAIRSTYLE_BLOCK)
				if(FACEHAIR in H.dna.species.species_traits)
					H.facial_hairstyle = sanitize_hairstyle(H.facial_hairstyle, H.dna.species.hair_id, H.gender, TRUE)
					H.dna.update_ui_block(DNA_FACIAL_HAIRSTYLE_BLOCK)
				H.dna.update_ui_block(DNA_GENDER_BLOCK)


				H.update_body()
				H.update_mutations_overlay() //(hulk male/female)

		if("hair")
			var/hairchoice = alert(H, "Hairstyle or hair color?", "Change Hair", "Style", "Color")
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(hairchoice == "Style") //So you just want to use a mirror then?
				..()
				H.dna.update_ui_block(DNA_HAIRSTYLE_BLOCK)
				H.dna.update_ui_block(DNA_FACIAL_HAIRSTYLE_BLOCK)
			else
				var/new_hair_color = input(H, "Choose your hair color", "Hair Color","#"+H.hair_color) as color|null
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_hair_color)
					H.hair_color = sanitize_hexcolor(new_hair_color)
					H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
				if(H.gender == "male")
					var/new_face_color = input(H, "Choose your facial hair color", "Hair Color","#"+H.facial_hair_color) as color|null
					if(new_face_color)
						H.facial_hair_color = sanitize_hexcolor(new_face_color)
						H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
				H.update_hair()

		if("eye color")
			var/new_eye_color = input(H, "Choose your eye color", "Eye Color","#"+H.eye_color) as color|null
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_eye_color)
				H.eye_color = sanitize_hexcolor(new_eye_color)
				H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
				H.update_body()

		if("tail")
			var/new_tail
			new_tail = input(user, "Choose your tail:", "Tail style") as null|anything in GLOB.tails_list_species[H.dna.species.features_id]
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_tail)
				H.dna.features["tail"] = new_tail
				H.update_body()

		if("snout")
			var/new_snout
			new_snout = input(user, "Choose your snout:", "Snout style") as null|anything in GLOB.snouts_list_species[H.dna.species.features_id]
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_snout)
				H.dna.features["snout"] = new_snout
				H.update_body()

		if("horns")
			var/new_horns
			new_horns = input(user, "Choose your horns:", "Horns Preference") as null|anything in GLOB.horns_list_species[H.dna.species.features_id] | GLOB.horns_list_species[DEFAULT_SPECIES_INDEX]
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_horns)
				H.dna.features["horns"] = new_horns
				H.update_body()

		if("frills")
			var/new_frills
			new_frills = input(user, "Choose your frills:", "Character Preference") as null|anything in GLOB.frills_list_species[H.dna.species.features_id] | GLOB.frills_list_species[DEFAULT_SPECIES_INDEX]
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_frills)
				H.dna.features["frills"] = new_frills
				H.update_body()

		if("tail_accessory")
			var/new_tail_accessory
			new_tail_accessory = input(user, "Choose your tail accessory:", "Character Preference") as null|anything in GLOB.tail_accessory_list_species[H.dna.species.features_id] | GLOB.tail_accessory_list_species[DEFAULT_SPECIES_INDEX]
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_tail_accessory)
				H.dna.features["tail_accessory"] = new_tail_accessory
				H.update_body()

		if("body_markings")
			var/new_body_markings
			new_body_markings = input(user, "Choose your body markings:", "Character Preference") as null|anything in GLOB.body_markings_list_species[H.dna.species.features_id] | GLOB.body_markings_list_species[DEFAULT_SPECIES_INDEX]
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_body_markings)
				H.dna.features["body_markings"] = new_body_markings
				H.update_body()

		if("ears")
			var/new_ears
			new_ears = input(user, "Choose your ears:", "Character Preference") as null|anything in GLOB.ears_list_species[H.dna.species.features_id]
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_ears)
				H.dna.features["ears"] = new_ears
				H.update_body()

		if("wings")
			var/new_wings
			new_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.wings_list_species[H.dna.species.features_id]
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_wings)
				H.dna.features["wings"] = new_wings
				H.update_body()


	if(choice)
		curse(user)

/obj/structure/mirror/magic/proc/curse(mob/living/user)
	return
