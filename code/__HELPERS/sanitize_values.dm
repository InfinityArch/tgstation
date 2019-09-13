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
*features*: typically a list of sprite features found in datum/dna, but should work on any list
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
	if("tail" in features_to_sanitize)
		temp_index = GLOB.tails_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["tail"] = sanitize_inlist(features["tail"], GLOB.tails_list & GLOB.tails_list_species[temp_index])
	if("snout" in features_to_sanitize)
		temp_index = GLOB.snouts_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["snout"] = sanitize_inlist(features["snout"], GLOB.snouts_list & GLOB.snouts_list_species[temp_index])
	if("horns" in features_to_sanitize)
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
	if("body_markings" in features_to_sanitize)
		temp_index = GLOB.body_markings_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["body_markings"] = sanitize_inlist(features["body_markings"], (GLOB.body_markings_list & GLOB.body_markings_list_species[temp_index]) | GLOB.body_markings_list_species[DEFAULT_SPECIES_INDEX])
	if("legs" in features_to_sanitize)
		temp_index = GLOB.body_markings_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["feature_legs"] = sanitize_inlist(features["legs"], (GLOB.legs_list && GLOB.legs_list_species[temp_index]) | GLOB.legs_list_species[DEFAULT_SPECIES_INDEX])	
	if("wings" in features_to_sanitize)
		temp_index = GLOB.wings_list_species[species_index] ? species_index : DEFAULT_SPECIES_INDEX
		features["wings"] = sanitize_inlist(features["wings"], GLOB.wings_list & GLOB.wings_list[species_index])
	return features

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

/proc/sanitize_hairstyle(hairstyle, species_index, gender = PLURAL, facial = FALSE)
	var/list/intersection
	if(facial)
		intersection = GLOB.facial_hairstyles_list_species["default"]
		switch(gender)
			if(MALE)
				intersection |= (GLOB.facial_hairstyles_male_list & GLOB.facial_hairstyles_list_species[species_index])
				hairstyle = sanitize_inlist(hairstyle, intersection)
			if(FEMALE)
				intersection |= (GLOB.facial_hairstyles_female_list & GLOB.facial_hairstyles_list_species[species_index])
				hairstyle = sanitize_inlist(hairstyle, intersection)
			else
				intersection |= (GLOB.facial_hairstyles_list & GLOB.facial_hairstyles_list_species[species_index])
				hairstyle = sanitize_inlist(hairstyle, intersection)
	else
		intersection = GLOB.hairstyles_list_species["default"]
		switch(gender)
			if(MALE)
				intersection |= (GLOB.hairstyles_male_list & GLOB.hairstyles_list_species[species_index])
				hairstyle = sanitize_inlist(hairstyle, intersection)
			if(FEMALE)
				intersection |= (GLOB.hairstyles_female_list & GLOB.hairstyles_list_species[species_index])
				hairstyle = sanitize_inlist(hairstyle, intersection)
			else
				intersection |= (GLOB.hairstyles_list & GLOB.hairstyles_list_species[species_index])
				hairstyle = sanitize_inlist(hairstyle, intersection)

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

	var/start = 1 + (text2ascii(color,1)==35)
	var/len = length(color)
	var/step_size = 1 + ((len+1)-start != desired_format)

	. = ""
	for(var/i=start, i<=len, i+=step_size)
		var/ascii = text2ascii(color,i)
		switch(ascii)
			if(48 to 57)
				. += ascii2text(ascii)		//numbers 0 to 9
			if(97 to 102)
				. += ascii2text(ascii)		//letters a to f
			if(65 to 70)
				. += ascii2text(ascii+32)	//letters A to F - translates to lowercase
			else
				break

	if(length(.) != desired_format)
		if(default)
			return default
		return crunch + repeat_string(desired_format, "0")

	return crunch + .

/proc/sanitize_ooccolor(color)
	var/list/HSL = rgb2hsl(hex2num(copytext(color,2,4)),hex2num(copytext(color,4,6)),hex2num(copytext(color,6,8)))
	HSL[3] = min(HSL[3],0.4)
	var/list/RGB = hsl2rgb(arglist(HSL))
	return "#[num2hex(RGB[1],2)][num2hex(RGB[2],2)][num2hex(RGB[3],2)]"
