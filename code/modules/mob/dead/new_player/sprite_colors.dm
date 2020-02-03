/*

	Hello and welcome to sprite_colors: this is used for situations where you want to give players
	access to a limited range of customization colors. This is currently used for skin tones and
	ethereal colors (which are now depreciated and handled as skin tones),
	but could essentially be adapted to any situation where

	As with sprite_accessories this all gets automatically compiled in a list in dna.dm, so you do not
	have to define any UI values manually for new skin tones. You will have to do some more work
	if you want to use this for hair color or something.

	!!WARNING!!: changing existing preferences information can be VERY hazardous to savefiles.

How it works
	the proc init_sprite_color_subtypes accepts a prototype path and two lists as an argument.
	The first list (L) is the overall list of all subtypes of prototype, indexed by name.
	the second list (S) is a 2D array, indexed first by species.id and secondly by the name
	Both lists contain the actual datums, which are necessary for sprite_color2hex to
	retrieve the corresponding hex values. The point of having two lists is so one (S) can
	be used for changing skintones at round start and when evaluating whether skin_tone
	should be changed upon species gain/loss/other events that modify skin_tone dna. The
	other list (L) is used for procs that need to then go and render the skintone


Key procs
* [init_sprite_color_subtypes()](sprite_colors.html#proc/init_sprite_color_subtypes)
* [sprite_color2hex](sprite_colors.html#proc/sprite_color2hex)
Major variables that were changed
* skin_type: found in datum/species, this tells us what string to use for the species' "skin" in character customization
* use_skintones: this variable has been depreciated, and replaced by the species trait SKINTONE
Key variables from this file
* name: The name of a sprite color datum
* locked: this won't appear in the species indexed list, but can be manually added by for example spray tanning shennanigans
* color_hex: the hex value of the color this datum corresponds to
* species: what species this datum belongs to, this can remain null if you don't want to use speices indexing
*/


proc/init_sprite_color_subtypes(prototype, list/full_list, list/species_list)
	if(!istype(full_list))
		full_list = list()

	if(!istype(species_list))
		species_list = list()

	for(var/path in subtypesof(prototype))
		var/datum/sprite_color/D = new path()
		if(D.species && (!species_list[D.species]))
			species_list[D.species] = list()
		if(D.color_hex)
			full_list[D.name] = D
			if(D.species && !D.locked)
				species_list[D.species][D.name] = D.name
		else
			full_list += D.name

	return full_list

/datum/sprite_color
	var/name // the preview name of the sprite color
	var/locked // if the sprite color is locked at roundstart
	var/color_hex // the hex value of this sprite color
	var/species //what species id this should be indexed under?

/proc/sprite_color2hex(color_state, list/L)
	if(istype(L))
		var/datum/sprite_color/S = L[color_state]
		if(istype(S))
			return S.color_hex
	return color_state

////////////////
// Skin Tone //
///////////////

/datum/sprite_color/skin_tone
	species = DEFAULT_SPECIES_INDEX
	name = "greyscale"
	color_hex = "808080"

//////////////////////
// Human skin_tones //
/////////////////////

/datum/sprite_color/skin_tone/human
	species = "human"
	name = "African 1"
	color_hex = "754523"

/datum/sprite_color/skin_tone/human/african2
	name = "African 2"
	color_hex = "471c18"

/datum/sprite_color/skin_tone/human/albino
	name = "Albino"
	color_hex = "fff4e6"

/datum/sprite_color/skin_tone/human/arab
	name = "Arab"
	color_hex = "c4915e"

/datum/sprite_color/skin_tone/human/asian1
	name = "Asian 1"
	color_hex = "ffdeb3"

/datum/sprite_color/skin_tone/human/asian2
	name = "Asian 2"
	color_hex = "e3ba84"

/datum/sprite_color/skin_tone/human/caucasian1
	name = "Caucasian 1"
	color_hex = "ffe0d1"

/datum/sprite_color/skin_tone/human/caucasian2
	name = "Caucasian 2"
	color_hex = "fcccb3"

/datum/sprite_color/skin_tone/human/caucasian3
	name = "Caucasian 3"
	color_hex = "e8b59b"

/datum/sprite_color/skin_tone/human/indian
	name = "Indian"
	color_hex = "b87840"

/datum/sprite_color/skin_tone/human/latino
	name = "Latino"
	color_hex = "d9ae96"

/datum/sprite_color/skin_tone/human/mediterranean
	name = "Mediterranean"
	color_hex = "c79b8b"

/datum/sprite_color/skin_tone/human/orange
	name = "Orange"
	color_hex = "ffc905"
	locked = TRUE

/////////////////////
// Ethereal Colors //
/////////////////////
/datum/sprite_color/skin_tone/ethereal
	species = "ethereal"
	name = "F Class (Green)"
	color_hex = "97ee63"

/datum/sprite_color/skin_tone/ethereal/light_green
	name = "F2 Class (Light Green)"
	color_hex = "00fa9a"

/datum/sprite_color/skin_tone/ethereal/dark_green
	name = "F3 Class (Dark Green)"
	color_hex = "37835b"

/datum/sprite_color/skin_tone/ethereal/red
	name = "M Class (Red)"
	color_hex = "9c3030"

/datum/sprite_color/skin_tone/ethereal/purple
	name = "M1 Class (Purple)"
	color_hex = "ee82ee"

/datum/sprite_color/skin_tone/ethereal/yellow
	name = "G Class (Yellow)"
	color_hex = "fbdf56"

/datum/sprite_color/skin_tone/ethereal/blue
	name = "O Class (Blue)"
	color_hex = "3399ff"

/datum/sprite_color/skin_tone/ethereal/cyan
	name = "A Class (Cyan)"
	color_hex = "00ffff"


////////////////////////
// Tajaran fur colors//
///////////////////////

/datum/sprite_color/skin_tone/tajaran
	species = "tajaran"
	name = "Silver"
	color_hex = "c6c6c6"

/datum/sprite_color/skin_tone/tajaran/taupe
	name = "Taupe"
	color_hex = "af8d73"

/datum/sprite_color/skin_tone/tajaran/chocolate
	name = "Chocolate"
	color_hex = "7c5a40"

/datum/sprite_color/skin_tone/tajaran/sand
	name = "Sand"
	color_hex = "dbc991"

/datum/sprite_color/skin_tone/tajaran/black
	name = "Black"
	color_hex = "2d2d2d"

///////////////
// Lipstick //
/////////////

/datum/sprite_color/lip_color

//////////////////////////
// Augmentation Colors //
/////////////////////////

/datum/sprite_color/aug_color

/datum/sprite_color/aug_color/steel
	name = "Steel"
	color_hex = "c6c8c9"

/datum/sprite_color/aug_color/matte
	name = "Matte"
	color_hex = "252a2f"

/datum/sprite_color/aug_color/gunmetal
	name = "Gunmetal"
	color_hex = "4d5461"

/datum/sprite_color/aug_color/rust
	name = "Rust"
	color_hex = "b7410e"

/datum/sprite_color/aug_color/chromium
	name = "Chromium"
	color_hex = "fffafa"

/datum/sprite_color/aug_color/brass
	name = "Brass"
	color_hex = "ffdead"

/datum/sprite_color/aug_color/cobalt
	name = "Cobalt"
	color_hex = "0047ab"

/datum/sprite_color/aug_color/ruby
	name = "Ruby"
	color_hex = "9b111e"

/datum/sprite_color/aug_color/malachite
	name = "Malachite"
	color_hex = "0bda51"
