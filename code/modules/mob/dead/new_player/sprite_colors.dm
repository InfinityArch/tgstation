/*

	Hello and welcome to sprite_colors: this is used for situations where you want to give players 
	access to a limited range of customization colors. This is currently used for skin tones and
	ethereal colors

	Notice: This all gets automatically compiled in a list in dna.dm, so you do not
	have to define any UI values manually for new skin tones, just add them in and
	the game will adapt

	!!WARNING!!: changing existing preferences information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/


proc/init_sprite_colors_subtypes(prototype, list/L, list/S, var/roundstart = FALSE) //roundstart argument builds a list of colors with some potentially being locked
	if(!istype(L))
		L = list()

	if(!istype(S))
		S = list()

	for(var/path in subtypesof(prototype))
		if(roundstart)
			var/datum/sprite_accessory/P = path
			if(initial(P.locked))
				continue
		var/datum/sprite_accessory/D = new path()
		if(D.species && (!S[D.species]))
			S[D.species] = list()
		if(D.color_hex)
			L[D.name] = D
			if(D.species)
				S[D.species][D.name] = D
		else
			L += D.name 

	return L

/datum/sprite_color
	var/name // the preview name of the sprite color
	var/locked // if the sprite color is locked at roundstart
	var/color_hex // the hex value of this sprite color
	var/species //what species id this should be indexed under

/proc/sprite_color2hex(color_state, list/L)
	if(!istype(L))
		return
	else
		return L[color_state].color_hex




////////////////
// Skin Tone //
///////////////

/datum/sprite_color/skin_tone

//////////////////////
// Human skin_tones //
/////////////////////

/datum/sprite_color/skin_tone/human
	species = "human"

/datum/sprite_color/skin_tone/human/african1
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

/datum/sprite_color/ethereal
	species = "ethereal"
	name = "F Class (Green)"
	color_hex = "97ee63"

/datum/sprite_color/ethereal/light_green
	name = "F2 Class (Light Green)"
	color_hex = "00fa9a"

/datum/sprite_color/ethereal/dark_green
	name = "F3 Class (Dark Green)"
	color_hex = "37835b"

/datum/sprite_color/ethereal/red
	name = "M Class (Red)"
	color_hex = "9c3030"

/datum/sprite_color/ethereal/purple
	name = "M1 Class (Purple)"
	color_hex = "ee82ee"

/datum/sprite_color/ethereal/yellow
	name = "G Class (Yellow)"
	color_hex = "fbdf56"

/datum/sprite_color/ethereal/blue
	name = "O Class (Blue)"
	color_hex = "3399ff"

/datum/sprite_color/ethereal/cyan
	name = "A Class (Cyan)"
	color_hex = "00ffff"

/datum/sprite_color/ethereal/orange //WOMP WOMP
	name = "Orange"
	color_hex = "ffc905"
	locked = TRUE
