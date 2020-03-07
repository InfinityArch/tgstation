
/datum/admins/proc/create_mob(mob/user)
	var/static/create_mob_html
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = file2text('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "Create Object", "Create Mob")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(create_panel_helper(create_mob_html), "window=create_mob;size=425x475")

/proc/randomize_human(mob/living/carbon/human/H)
	if(AGENDER in H.dna.species.species_traits)
		H.gender = PLURAL
	else
		H.gender = pick(MALE, FEMALE, PLURAL)
	H.real_name = H.dna.species.random_name(H.gender)
	H.name = H.real_name
	H.underwear = random_underwear(H.gender)
	H.underwear_color = random_short_color()
	H.skin_tone = random_skin_tone(H.dna.species.limbs_id)
	H.hairstyle = random_hairstyle(H.gender, H.dna.species.hair_id)
	H.facial_hairstyle = random_facial_hairstyle(H.gender, H.dna.species.hair_id)
	H.hair_color = random_short_color()
	H.facial_hair_color = H.hair_color
	H.eye_color = random_eye_color()
	H.dna.blood_type = random_blood_type()

	// Mutant randomizing, doesn't affect the mob appearance unless it's the specific mutant.
	H.dna.features = random_features(DEFAULT_FEATURES_LIST, H.dna.species)
	H.update_body()
	H.update_hair()
	H.update_body_parts()
