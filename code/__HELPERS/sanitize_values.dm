//general stuff
/proc/sanitize_integer(number, min=0, max=1, default=0)
	if(isnum(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_text(text, default="")
	if(istext(text))
		return text
	return default

/proc/sanitize_islist(value, default)
	if(islist(value) && length(value))
		return value
	if(default)
		return default

/proc/sanitize_inlist(value, list/List, default)
	if(value in List)
		return value
	else if(List && List.len)
		return pick(List)
	else
		return default

/////////////////////////////////////////////
//sanitization procs for character features//
/////////////////////////////////////////////
/*
# sanitize_features

__description__: this proc checks whether a list of features are valid and permitted for a given species, and returns the input list with illegal values corrected to permitted values

__Arguments__
*features*: typically a list of sprite features found in datum/dna, but will work on any list of features
*species_index*: what index to search under in the global features lists for this species; this should normally be *features_id* from a mob's datum/species, but will accept any string
*features_to_sanitize*: a list of features that should be sanitized, defaults to *features* if not given. See /proc/random_features in the mobs.dm helper for an example of what that full list entails
__Returns__: returns the input list (features) with features found in *features_to_sanitize* corrected to permitted values for the given *species_index*, runtimes if no input list is given
*/

/proc/sanitize_features(list/features, species_index = DEFAULT_SPECIES_INDEX, list/features_to_sanitize = list())
	var/temp_index // this stores the species_index, and is checked for validity prior to sanitizing a feature, if there's nothing at species_index, then we use DEFAULT_SPECIES_INDEX instead
	if(!features_to_sanitize.len)
		features_to_sanitize = features
	if("mcolor" in features_to_sanitize)
		features["mcolor"] = sanitize_hexcolor(features["mcolor"], 3, 0)
	if("tail" in features_to_sanitize) //&& (!aug_exempt || !(features["tail"] in GLOB.tails_list_species["augment"])))
		temp_index = GLOB.tails_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["tail"] = sanitize_inlist(features["tail"], GLOB.tails_list & GLOB.tails_list_species[temp_index])
	if("snout" in features_to_sanitize) //&& (!aug_exempt || !(features["snout"] in GLOB.snouts_list_species["augment"])))
		temp_index = GLOB.snouts_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["snout"] = sanitize_inlist(features["snout"], GLOB.snouts_list & GLOB.snouts_list_species[temp_index])
	if("horns" in features_to_sanitize) //&& (!aug_exempt || !(features["horns"] in GLOB.horns_list_species["augment"])))
		temp_index = GLOB.horns_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["horns"] = sanitize_inlist(features["horns"], (GLOB.horns_list & GLOB.horns_list_species[temp_index]) | GLOB.horns_list_species[DEFAULT_SPECIES_INDEX])
	if("ears" in features_to_sanitize)
		temp_index = GLOB.ears_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["ears"] = sanitize_inlist(features["ears"], GLOB.ears_list & GLOB.ears_list_species[temp_index])
	if("frills" in features_to_sanitize)
		temp_index = GLOB.frills_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["frills"] = sanitize_inlist(features["frills"], (GLOB.frills_list & GLOB.frills_list_species[temp_index]) | GLOB.frills_list_species[DEFAULT_SPECIES_INDEX])
	if("tail_accessory" in features_to_sanitize)
		temp_index = GLOB.tail_accessory_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["tail_accessory"] = sanitize_inlist(features["tail_accessory"], (GLOB.tail_accessory_list & GLOB.tail_accessory_list_species[temp_index]) | GLOB.tail_accessory_list_species[DEFAULT_SPECIES_INDEX])
	if("face_markings" in features_to_sanitize)
		temp_index = GLOB.face_markings_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["face_markings"] = sanitize_inlist(features["face_markings"], (GLOB.face_markings_list & GLOB.face_markings_list_species[temp_index]) | GLOB.face_markings_list_species[DEFAULT_SPECIES_INDEX])
	if("body_markings" in features_to_sanitize)
		temp_index = GLOB.body_markings_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["body_markings"] = sanitize_inlist(features["body_markings"], (GLOB.body_markings_list & GLOB.body_markings_list_species[temp_index]) | GLOB.body_markings_list_species[DEFAULT_SPECIES_INDEX])
	if("legs" in features_to_sanitize)
		temp_index = GLOB.legs_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["legs"] = sanitize_inlist(features["legs"], GLOB.legs_list | GLOB.legs_list_species[DEFAULT_SPECIES_INDEX])
	if("wings" in features_to_sanitize)
		temp_index = GLOB.wings_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["wings"] = sanitize_inlist(features["wings"], GLOB.wings_list & GLOB.wings_list_species[temp_index])
	return features

/*
# check_feature_by_index

__description__: this proc checks whether a a given sprite accessory index is present in the global sprite accessory lists

__Arguments__
*feature*: the string associated with the sprite_accessory
*species index*: what index in the sprite accessory species list to search under
*feature_type*: a string the denotes the type of feature, see DEFAULT_FEATURES_LIST in mobs.dm
*draw_state*: the draw state of the host bodypart, used to evaluate the need to check for an augmented icon_state
*sanitize*: if true, the proc will sanitize the feature, use this to quickly get a valid state for a single feature
__Returns__:
*If sanitize is true, returns either the original feature or a valid entry within the target list.
* If sanitize is false, it will return false if the feature is not present in the target list, and true if it is
*/
proc/check_feature_by_index(feature, species_index, feature_type, draw_state = BODYPART_DRAW_ORGANIC, sanitize = TRUE)
	. = pick(get_feature_list(feature_type, DEFAULT_SPECIES_INDEX))
	var/datum/sprite_accessory/S = get_feature_list(feature_type)[feature]
	if(!S)
		return
	var/list/indicies_to_check = list()
	var/check_augment
	switch(draw_state)
		if(BODYPART_DRAW_ORGANIC to BODYPART_DRAW_ANDROID_SKELETAL)
			indicies_to_check |= species_index
		if(BODYPART_DRAW_ANDROID to BODYPART_DRAW_ANDROID_SKELETAL)
			check_augment = TRUE
		if(BODYPART_DRAW_ANDROID to BODYPART_DRAW_MONITOR)
			indicies_to_check |= FEATURE_ROBOTIC

	for(var/index in indicies_to_check)
		if((index == S.species) && (!check_augment || S.has_augmented_states))
			return feature
	if(sanitize)
		var/list/species_list = get_feature_list(feature, indicies_to_check[indicies_to_check.len])
		if(species_list.len)
			return sanitize_inlist(feature, species_list)

/*
# sanitize_bodyparts

__description__: this proc checks an input list of roundstart alternate bodyparts are valid for a given character

__Arguments__
*alternate_bodyparts*: association list with modification types indexed by bodyzone
*limb customization type*: which types of limbs customization is allowed for this species
__Returns__: returns the input list modified according to the limb customization type allowed
*/

/proc/sanitize_bodyparts(list/alternate_bodyparts, limb_customization_type = LIMB_CUSTOMIZATION_DEFAULT)
	if(!limb_customization_type || !alternate_bodyparts || !alternate_bodyparts.len)
		return list()
	if(limb_customization_type == LIMB_CUSTOMIZATION_DEFAULT)
		if(BODY_ZONE_CHEST in alternate_bodyparts)
			alternate_bodyparts -= BODY_ZONE_CHEST
		if(BODY_ZONE_HEAD in alternate_bodyparts)
			alternate_bodyparts -= BODY_ZONE_HEAD
	return alternate_bodyparts


/*
# sanitize_hairstyle

__description__: this proc checks whether a hair or facial hair style is valid and permitted for a given character

__Arguments__
*hairstyle*: the hair style or facial hair style to sanitize
*species_index*: what index to search under in the global features lists for this species; this should normally be *hair_id* from a mob's datum/species, but will accept any string
*gender*: the mob's gender, if applicable
*facial*: set to true to sanitize facial hair

__Returns__: returns the original style if its valid for the character, and the default of "bald" and "shaved" for hair and facial hair respectively if they're
*/

/proc/sanitize_hairstyle(hairstyle, species_index, gender = NEUTER, facial = FALSE)

	if(!facial)
		species_index = GLOB.hairstyles_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		if(gender == MALE)
			hairstyle = sanitize_inlist(hairstyle, GLOB.hairstyles_list_species[DEFAULT_SPECIES_INDEX] | (GLOB.hairstyles_male_list & GLOB.hairstyles_list_species[species_index]))
		else if(gender == FEMALE)
			hairstyle = sanitize_inlist(hairstyle, GLOB.hairstyles_list_species[DEFAULT_SPECIES_INDEX] | (GLOB.hairstyles_female_list & GLOB.hairstyles_list_species[species_index]))
		else
			hairstyle = sanitize_inlist(hairstyle, GLOB.hairstyles_list_species[DEFAULT_SPECIES_INDEX] | GLOB.hairstyles_list_species[species_index])

	else
		species_index = GLOB.facial_hairstyles_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		if(gender == MALE)
			hairstyle = sanitize_inlist(hairstyle, GLOB.facial_hairstyles_list_species[DEFAULT_SPECIES_INDEX] | (GLOB.facial_hairstyles_male_list & GLOB.facial_hairstyles_list_species[species_index]))
		else if(gender == FEMALE)
			hairstyle = sanitize_inlist(hairstyle, GLOB.facial_hairstyles_list_species[DEFAULT_SPECIES_INDEX] | (GLOB.facial_hairstyles_female_list & GLOB.facial_hairstyles_list_species[species_index]))
		else
			hairstyle = sanitize_inlist(hairstyle, GLOB.facial_hairstyles_list_species[DEFAULT_SPECIES_INDEX] | GLOB.facial_hairstyles_list_species[species_index])

	return hairstyle

/*
# sanitize_skin_tone

__description__: this proc checks whether a skin_tone is valid for a given character

__Arguments__
*skin_tone*: the skin_tone value to sanitize
*species_index*: what index to search under in the global features lists for this species; this should normally be *hair_id* from a mob's datum/species, but will accept any string

__Returns__: returns the original skin_tone if it's valid, or a random valid skintone otherwise
*/
/proc/sanitize_skin_tone(skin_tone, species_index = DEFAULT_SPECIES_INDEX)
	species_index = GLOB.skin_tones_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
	return sanitize_inlist(skin_tone, GLOB.skin_tones_list_species[species_index])


/proc/sanitize_gender(gender,neuter=0,plural=1, default="male")
	switch(gender)
		if(MALE, FEMALE)
			return gender
		if(NEUTER)
			if(neuter)
				return gender
			else
				return default
		if(PLURAL)
			if(plural)
				return gender
			else
				return default
	return default

/proc/sanitize_hexcolor(color, desired_format=3, include_crunch=0, default)
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

	var/start = 1 + (text2ascii(color, 1) == 35)
	var/len = length(color)
	var/char = ""
	// RRGGBB -> RGB but awful
	var/convert_to_shorthand = desired_format == 3 && length_char(color) > 3

	. = ""
	var/i = start
	while(i <= len)
		char = color[i]
		switch(text2ascii(char))
			if(48 to 57)		//numbers 0 to 9
				. += char
			if(97 to 102)		//letters a to f
				. += char
			if(65 to 70)		//letters A to F
				. += lowertext(char)
			else
				break
		i += length(char)
		if(convert_to_shorthand && i <= len) //skip next one
			i += length(color[i])

	if(length_char(.) != desired_format)
		if(default)
			return default
		return crunch + repeat_string(desired_format, "0")

	return crunch + .

/proc/sanitize_ooccolor(color)
	if(length(color) != length_char(color))
		CRASH("Invalid characters in color '[color]'")
	var/list/HSL = rgb2hsl(hex2num(copytext(color, 2, 4)), hex2num(copytext(color, 4, 6)), hex2num(copytext(color, 6, 8)))
	HSL[3] = min(HSL[3],0.4)
	var/list/RGB = hsl2rgb(arglist(HSL))
	return "#[num2hex(RGB[1],2)][num2hex(RGB[2],2)][num2hex(RGB[3],2)]"

