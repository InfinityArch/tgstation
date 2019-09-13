//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/make_datum_references_lists()
	//hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, GLOB.hair_styles_list, GLOB.hair_styles_male_list, GLOB.hair_styles_female_list, species_list = GLOB.hair_styles_list_species)
	//facial hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hair_styles_list, GLOB.facial_hair_styles_male_list, GLOB.facial_hair_styles_female_list, species_list = GLOB.facial_hair_styles_list_species)
	//skin tone
	init_sprite_color_subtypes(/datum/sprite_color/skin_tone, GLOB.skin_tones_list, GLOB.skin_tones_list_species)
	//underwear
	init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	//undershirt
	init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f)
	//socks
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, GLOB.socks_list)
	//head features
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, GLOB.ears_list, species_list = GLOB.ears_list_species)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, GLOB.snouts_list, species_list = GLOB.snouts_list_species)
	//tails
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails, GLOB.tails_list, species_list = GLOB.tails_list_species)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails_animated, GLOB.animated_tails_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tail_accessory, GLOB.tail_accessory_list, species_list = GLOB.tail_accessory_list_species)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tail_accessory_animated, GLOB.animated_tail_accessory_list)
	//wings
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.wings_list, species_list = GLOB.wings_list_species)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings_open, GLOB.wings_open_list)

	init_sprite_accessory_subtypes(/datum/sprite_accessory/horns,GLOB.horns_list, species_list = GLOB.horns_list_species)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, GLOB.frills_list, species_list = GLOB.frills_list_species)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, GLOB.legs_list, species_list = GLOB.legs_list_species)

	
	init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.body_markings_list, species_list = GLOB.body_markings_list_species)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/caps, GLOB.caps_list)
	//Species
	for(var/spath in subtypesof(/datum/species))
		var/datum/species/S = new spath()
		GLOB.species_list[S.id] = spath

	//Surgeries
	for(var/path in subtypesof(/datum/surgery))
		GLOB.surgeries_list += new path()

	//Materials
	for(var/path in subtypesof(/datum/material))
		var/datum/material/D = new path()
		GLOB.materials_list[D.id] = D

	GLOB.emote_list = init_emote_list()

	init_subtypes(/datum/crafting_recipe, GLOB.crafting_recipes)

//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L

//returns a list of paths to every subtype of prototype (excluding prototype)
//if no list/L is provided, one is created.
/proc/init_paths(prototype, list/L)
	if(!istype(L))
		L = list()
		for(var/path in subtypesof(prototype))
			L+= path
		return L
