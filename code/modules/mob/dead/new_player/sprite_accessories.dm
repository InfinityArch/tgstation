/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/
/proc/init_sprite_accessory_subtypes(prototype, list/L, list/male, list/female,var/roundstart = FALSE, list/species_list)//Roundstart argument builds a specific list for roundstart parts where some parts may be locked
	if(!istype(L))
		L = list()
	if(!istype(male))
		male = list()
	if(!istype(female))
		female = list()
	if(!istype(species_list))
		species_list = list()

	for(var/path in subtypesof(prototype))
		if(roundstart)
			var/datum/sprite_accessory/P = path
			if(initial(P.locked))
				continue
		var/datum/sprite_accessory/D = new path()
		if(D.icon_state)
			L[D.name] = D
		else
			L += D.name
		if(D.species && !D.locked)
			if(!species_list[D.species])
				species_list[D.species] = list()
			species_list[D.species] += D.name
		switch(D.gender)
			if(MALE)
				male += D.name
			if(FEMALE)
				female += D.name
			else
				male += D.name
				female += D.name
	return L

/datum/sprite_accessory
	var/icon			//the icon file the accessory is located in
	var/icon_state		//the icon_state of the accessory
	var/name			//the preview name of the accessory
	var/gender = NEUTER	//Determines if the accessory will be skipped or included in random hair generations
	var/gender_specific //Something that can be worn by either gender, but looks different on each
	var/use_static		//determines if the accessory will be skipped by color preferences
	var/color_src = MUTCOLORS	//Currently only used by mutantparts so don't worry about hair and stuff. This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
	var/hasinner		//Decides if this sprite has an "inner" part, such as the fleshy parts on ears.
	var/has_augmented_states = FALSE //whether this part has overlay icons for android bodypart states
	var/locked = FALSE		//Is this part locked from roundstart selection? Used for parts that apply effects
	var/dimension_x = 32
	var/dimension_y = 32
	var/center = FALSE	//Should we center the sprite?
	var/species			//What id value this should be indexed under in the id indexed list
	var/feature_name 	//The top level index that this feature can be found under


//////////////////////
// Hair Definitions //
//////////////////////

/datum/sprite_accessory/hair
	icon = 'icons/mob/hair/human.dmi'	  // default icon for all hairs
	species = "human"

	// please make sure they're sorted alphabetically and, where needed, categorized
	// try to capitalize the names please~
	// try to spell
	// you do not need to define _s or _l sub-states, game automatically does this for you

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = "bald"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "hair_afro2"

/datum/sprite_accessory/hair/afro_large
	name = "Afro (Large)"
	icon_state = "hair_bigafro"

/datum/sprite_accessory/hair/antenna
	name = "Ahoge"
	icon_state = "hair_antenna"

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/bedheadlong
	name = "Long Bedhead"
	icon_state = "hair_long_bedhead"

/datum/sprite_accessory/hair/bedheadfloorlength
	name = "Floorlength Bedhead"
	icon_state = "hair_floorlength_bedhead"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"

/datum/sprite_accessory/hair/beehive2
	name = "Beehive 2"
	icon_state = "hair_beehivev2"

/datum/sprite_accessory/hair/bob
	name = "Bob Hair"
	icon_state = "hair_bob"

/datum/sprite_accessory/hair/bob2
	name = "Bob Hair 2"
	icon_state = "hair_bob2"

/datum/sprite_accessory/hair/bob3
	name = "Bob Hair 3"
	icon_state = "hair_bobcut"

/datum/sprite_accessory/hair/bob4
	name = "Bob Hair 4"
	icon_state = "hair_bob4"

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"

/datum/sprite_accessory/hair/boddicker
	name = "Boddicker"
	icon_state = "hair_boddicker"

/datum/sprite_accessory/hair/bowlcut
	name = "Bowlcut"
	icon_state = "hair_bowlcut"

/datum/sprite_accessory/hair/bowlcut2
	name = "Bowlcut 2"
	icon_state = "hair_bowlcut2"

/datum/sprite_accessory/hair/braid
	name = "Braid (Floorlength)"
	icon_state = "hair_braid"

/datum/sprite_accessory/hair/braided
	name = "Braided"
	icon_state = "hair_braided"

/datum/sprite_accessory/hair/front_braid
	name = "Braided Front"
	icon_state = "hair_braidfront"

/datum/sprite_accessory/hair/not_floorlength_braid
	name = "Braid (High)"
	icon_state = "hair_braid2"

/datum/sprite_accessory/hair/lowbraid
	name = "Braid (Low)"
	icon_state = "hair_hbraid"

/datum/sprite_accessory/hair/shortbraid
	name = "Braid (Short)"
	icon_state = "hair_shortbraid"

/datum/sprite_accessory/hair/braidtail
	name = "Braided Tail"
	icon_state = "hair_braidtail"

/datum/sprite_accessory/hair/bun
	name = "Bun Head"
	icon_state = "hair_bun"

/datum/sprite_accessory/hair/bun2
	name = "Bun Head 2"
	icon_state = "hair_bunhead2"

/datum/sprite_accessory/hair/bun3
	name = "Bun Head 3"
	icon_state = "hair_bun3"

/datum/sprite_accessory/hair/largebun
	name = "Bun (Large)"
	icon_state = "hair_largebun"

/datum/sprite_accessory/hair/manbun
	name = "Bun (Manbun)"
	icon_state = "hair_manbun"

/datum/sprite_accessory/hair/tightbun
	name = "Bun (Tight)"
	icon_state = "hair_tightbun"

/datum/sprite_accessory/hair/business
	name = "Business Hair"
	icon_state = "hair_business"

/datum/sprite_accessory/hair/business2
	name = "Business Hair 2"
	icon_state = "hair_business2"

/datum/sprite_accessory/hair/business3
	name = "Business Hair 3"
	icon_state = "hair_business3"

/datum/sprite_accessory/hair/business4
	name = "Business Hair 4"
	icon_state = "hair_business4"

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "hair_buzzcut"

/datum/sprite_accessory/hair/cia
	name = "CIA"
	icon_state = "hair_cia"

/datum/sprite_accessory/hair/coffeehouse
	name = "Coffee House"
	icon_state = "hair_coffeehouse"

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"

/datum/sprite_accessory/hair/cornrows1
	name = "Cornrows"
	icon_state = "hair_cornrows"

/datum/sprite_accessory/hair/cornrows2
	name = "Cornrows 2"
	icon_state = "hair_cornrows2"

/datum/sprite_accessory/hair/cornrowbun
	name = "Cornrow Bun"
	icon_state = "hair_cornrowbun"

/datum/sprite_accessory/hair/cornrowbraid
	name = "Cornrow Braid"
	icon_state = "hair_cornrowbraid"

/datum/sprite_accessory/hair/cornrowdualtail
	name = "Cornrow Tail"
	icon_state = "hair_cornrowtail"

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_c"

/datum/sprite_accessory/hair/dandpompadour
	name = "Dandy Pompadour"
	icon_state = "hair_dandypompadour"

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/doublebun
	name = "Double Bun"
	icon_state = "hair_doublebun"

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/drillhair
	name = "Drill Hair"
	icon_state = "hair_drillhair"

/datum/sprite_accessory/hair/drillhair
	name = "Drillruru"
	icon_state = "hair_drillruru"

/datum/sprite_accessory/hair/drillhairextended
	name = "Drill Hair (Extended)"
	icon_state = "hair_drillhairextended"

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/emofrine
	name = "Emo Fringe"
	icon_state = "hair_emofringe"

/datum/sprite_accessory/hair/nofade
	name = "Fade (None)"
	icon_state = "hair_nofade"

/datum/sprite_accessory/hair/highfade
	name = "Fade (High)"
	icon_state = "hair_highfade"

/datum/sprite_accessory/hair/medfade
	name = "Fade (Medium)"
	icon_state = "hair_medfade"

/datum/sprite_accessory/hair/lowfade
	name = "Fade (Low)"
	icon_state = "hair_lowfade"

/datum/sprite_accessory/hair/baldfade
	name = "Fade (Bald)"
	icon_state = "hair_baldfade"

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/father
	name = "Father"
	icon_state = "hair_father"

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "hair_sargeant"

/datum/sprite_accessory/hair/flair
	name = "Flair"
	icon_state = "hair_flair"

/datum/sprite_accessory/hair/bigflattop
	name = "Flat Top (Big)"
	icon_state = "hair_bigflattop"

/datum/sprite_accessory/hair/fag
	name = "Flow Hair"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "hair_gelled"

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "hair_gentle"

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "hair_halfbang"

/datum/sprite_accessory/hair/halfbang2
	name = "Half-banged Hair 2"
	icon_state = "hair_halfbang2"

/datum/sprite_accessory/hair/halfshaved
	name = "Half-shaved"
	icon_state = "hair_halfshaved"

/datum/sprite_accessory/hair/hedgehog
	name = "Hedgehog Hair"
	icon_state = "hair_hedgehog"

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"

/datum/sprite_accessory/hair/himecut2
	name = "Hime Cut 2"
	icon_state = "hair_himecut2"

/datum/sprite_accessory/hair/shorthime
	name = "Hime Cut (Short)"
	icon_state = "hair_shorthime"

/datum/sprite_accessory/hair/himeup
	name = "Hime Updo"
	icon_state = "hair_himeup"

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"

/datum/sprite_accessory/hair/jade
	name = "Jade"
	icon_state = "hair_jade"

/datum/sprite_accessory/hair/jensen
	name = "Jensen Hair"
	icon_state = "hair_jensen"

/datum/sprite_accessory/hair/Joestar
	name = "Joestar"
	icon_state = "hair_joestar"

/datum/sprite_accessory/hair/keanu
	name = "Keanu Hair"
	icon_state = "hair_keanu"

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/long
	name = "Long Hair 1"
	icon_state = "hair_long"

/datum/sprite_accessory/hair/long2
	name = "Long Hair 2"
	icon_state = "hair_long2"

/datum/sprite_accessory/hair/long3
	name = "Long Hair 3"
	icon_state = "hair_long3"

/datum/sprite_accessory/hair/long_over_eye
	name = "Long Over Eye"
	icon_state = "hair_longovereye"

/datum/sprite_accessory/hair/longbangs
	name = "Long Bangs"
	icon_state = "hair_lbangs"

/datum/sprite_accessory/hair/longemo
	name = "Long Emo"
	icon_state = "hair_longemo"

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/sidepartlongalt
	name = "Long Side Part"
	icon_state = "hair_longsidepart"

/datum/sprite_accessory/hair/megaeyebrows
	name = "Mega Eyebrows"
	icon_state = "hair_megaeyebrows"

/datum/sprite_accessory/hair/messy
	name = "Messy"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/modern
	name = "Modern"
	icon_state = "hair_modern"

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "hair_d"

/datum/sprite_accessory/hair/nitori
	name = "Nitori"
	icon_state = "hair_nitori"

/datum/sprite_accessory/hair/reversemohawk
	name = "Mohawk (Reverse)"
	icon_state = "hair_reversemohawk"

/datum/sprite_accessory/hair/shavedmohawk
	name = "Mohawk (Shaved)"
	icon_state = "hair_shavedmohawk"

/datum/sprite_accessory/hair/shavedmohawk
	name = "Mohawk (Unshaven)"
	icon_state = "hair_unshaven_mohawk"

/datum/sprite_accessory/hair/mulder
	name = "Mulder"
	icon_state = "hair_mulder"

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "hair_odango"

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"

/datum/sprite_accessory/hair/oneshoulder
	name = "One Shoulder"
	icon_state = "hair_oneshoulder"

/datum/sprite_accessory/hair/over_eye
	name = "Over Eye"
	icon_state = "hair_shortovereye"

/datum/sprite_accessory/hair/oxton
	name = "Oxton"
	icon_state = "hair_oxton"

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/partedside
	name = "Parted (Side)"
	icon_state = "hair_part"

/datum/sprite_accessory/hair/kagami
	name = "Pigtails"
	icon_state = "hair_kagami"

/datum/sprite_accessory/hair/pigtail
	name = "Pigtails 2"
	icon_state = "hair_pigtails"

/datum/sprite_accessory/hair/pigtail2
	name = "Pigtails 3"
	icon_state = "hair_pigtails2"

/datum/sprite_accessory/hair/pixie
	name = "Pixie Cut"
	icon_state = "hair_pixie"

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"

/datum/sprite_accessory/hair/bigpompadour
	name = "Pompadour (Big)"
	icon_state = "hair_bigpompadour"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail"
	icon_state = "hair_ponytail"

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "hair_ponytail2"

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"

/datum/sprite_accessory/hair/ponytail4
	name = "Ponytail 4"
	icon_state = "hair_ponytail4"

/datum/sprite_accessory/hair/ponytail5
	name = "Ponytail 5"
	icon_state = "hair_ponytail5"

/datum/sprite_accessory/hair/ponytail6
	name = "Ponytail 6"
	icon_state = "hair_ponytail6"

/datum/sprite_accessory/hair/ponytail7
	name = "Ponytail 7"
	icon_state = "hair_ponytail7"

/datum/sprite_accessory/hair/highponytail
	name = "Ponytail (High)"
	icon_state = "hair_highponytail"

/datum/sprite_accessory/hair/stail
	name = "Ponytail (Short)"
	icon_state = "hair_stail"

/datum/sprite_accessory/hair/longponytail
	name = "Ponytail (Long)"
	icon_state = "hair_longstraightponytail"

/datum/sprite_accessory/hair/countryponytail
	name = "Ponytail (Country)"
	icon_state = "hair_country"

/datum/sprite_accessory/hair/fringetail
	name = "Ponytail (Fringe)"
	icon_state = "hair_fringetail"

/datum/sprite_accessory/hair/sidetail
	name = "Ponytail (Side)"
	icon_state = "hair_sidetail"

/datum/sprite_accessory/hair/sidetail2
	name = "Ponytail (Side) 2"
	icon_state = "hair_sidetail2"

/datum/sprite_accessory/hair/sidetail3
	name = "Ponytail (Side) 3"
	icon_state = "hair_sidetail3"

/datum/sprite_accessory/hair/sidetail4
	name = "Ponytail (Side) 4"
	icon_state = "hair_sidetail4"

/datum/sprite_accessory/hair/spikyponytail
	name = "Ponytail (Spiky)"
	icon_state = "hair_spikyponytail"

/datum/sprite_accessory/hair/poofy
	name = "Poofy"
	icon_state = "hair_poofy"

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"

/datum/sprite_accessory/hair/ronin
	name = "Ronin"
	icon_state = "hair_ronin"

/datum/sprite_accessory/hair/shaved
	name = "Shaved"
	icon_state = "hair_shaved"

/datum/sprite_accessory/hair/shavedpart
	name = "Shaved Part"
	icon_state = "hair_shavedpart"

/datum/sprite_accessory/hair/shortbangs
	name = "Short Bangs"
	icon_state = "hair_shortbangs"

/datum/sprite_accessory/hair/short
	name = "Short Hair"
	icon_state = "hair_a"

/datum/sprite_accessory/hair/shorthair2
	name = "Short Hair 2"
	icon_state = "hair_shorthair2"

/datum/sprite_accessory/hair/shorthair3
	name = "Short Hair 3"
	icon_state = "hair_shorthair3"

/datum/sprite_accessory/hair/shorthair4
	name = "Short Hair 4"
	icon_state = "hair_d"

/datum/sprite_accessory/hair/shorthair5
	name = "Short Hair 5"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/shorthair6
	name = "Short Hair 6"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/shorthair7
	name = "Short Hair 7"
	icon_state = "hair_shorthairg"

/datum/sprite_accessory/hair/shorthaireighties
	name = "Short Hair 80s"
	icon_state = "hair_80s"

/datum/sprite_accessory/hair/rosa
	name = "Short Hair Rosa"
	icon_state = "hair_rosa"

/datum/sprite_accessory/hair/shoulderlength
	name = "Shoulder-length Hair"
	icon_state = "hair_b"

/datum/sprite_accessory/hair/sidecut
	name = "Sidecut"
	icon_state = "hair_sidecut"

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"

/datum/sprite_accessory/hair/protagonist
	name = "Slightly Long Hair"
	icon_state = "hair_protagonist"

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spikey"

/datum/sprite_accessory/hair/spiky2
	name = "Spiky 2"
	icon_state = "hair_spiky"

/datum/sprite_accessory/hair/spiky3
	name = "Spiky 3"
	icon_state = "hair_spiky2"

/datum/sprite_accessory/hair/swept
	name = "Swept Back Hair"
	icon_state = "hair_swept"

/datum/sprite_accessory/hair/swept2
	name = "Swept Back Hair 2"
	icon_state = "hair_swept2"

/datum/sprite_accessory/hair/thinning
	name = "Thinning"
	icon_state = "hair_thinning"

/datum/sprite_accessory/hair/thinningfront
	name = "Thinning (Front)"
	icon_state = "hair_thinningfront"

/datum/sprite_accessory/hair/thinningrear
	name = "Thinning (Rear)"
	icon_state = "hair_thinningrear"

/datum/sprite_accessory/hair/topknot
	name = "Topknot"
	icon_state = "hair_topknot"

/datum/sprite_accessory/hair/tressshoulder
	name = "Tress Shoulder"
	icon_state = "hair_tressshoulder"

/datum/sprite_accessory/hair/trimmed
	name = "Trimmed"
	icon_state = "hair_trimmed"

/datum/sprite_accessory/hair/trimflat
	name = "Trim Flat"
	icon_state = "hair_trimflat"

/datum/sprite_accessory/hair/twintails
	name = "Twintails"
	icon_state = "hair_twintail"

/datum/sprite_accessory/hair/undercut
	name = "Undercut"
	icon_state = "hair_undercut"

/datum/sprite_accessory/hair/undercutleft
	name = "Undercut Left"
	icon_state = "hair_undercutleft"

/datum/sprite_accessory/hair/undercutright
	name = "Undercut Right"
	icon_state = "hair_undercutright"

/datum/sprite_accessory/hair/unkept
	name = "Unkept"
	icon_state = "hair_unkept"

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"

/datum/sprite_accessory/hair/longer
	name = "Very Long Hair"
	icon_state = "hair_vlong"

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair 2"
	icon_state = "hair_longest"

/datum/sprite_accessory/hair/longest2
	name = "Very Long Over Eye"
	icon_state = "hair_longest2"

/datum/sprite_accessory/hair/veryshortovereye
	name = "Very Short Over Eye"
	icon_state = "hair_veryshortovereyealternate"

/datum/sprite_accessory/hair/longestalt
	name = "Very Long with Fringe"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/volaju
	name = "Volaju"
	icon_state = "hair_volaju"

/datum/sprite_accessory/hair/wisp
	name = "Wisp"
	icon_state = "hair_wisp"

/datum/sprite_accessory/hair/tajaran
	name = "Braid (Tajaran)"
	species = "tajaran"
	icon_state= "braid"
	icon = 'icons/mob/hair/tajaran.dmi'

/datum/sprite_accessory/hair/tajaran/beaded
	name = "Beaded Braid (Tajaran)"
	icon_state= "braid_beaded"

/datum/sprite_accessory/hair/tajaran/clean
	name = "Clean (Tajaran)"
	icon_state= "clean"

/datum/sprite_accessory/hair/tajaran/clean
	name = "Bangs (Tajaran)"
	icon_state= "bangs"

/datum/sprite_accessory/hair/tajaran/shaggy
	name = "Shaggy (Tajaran)"
	icon_state= "shaggy"

/datum/sprite_accessory/hair/tajaran/mohawk
	name = "Mohawk (Tajaran)"
	icon_state= "mohawk"

/datum/sprite_accessory/hair/tajaran/plait
	name = "Plait (Tajaran)"
	icon_state= "plait"

/datum/sprite_accessory/hair/tajaran/straight
	name = "Straight (Tajaran)"
	icon_state= "straight"

/datum/sprite_accessory/hair/tajaran/long
	name = "Long (Tajaran)"
	icon_state= "long"

/datum/sprite_accessory/hair/tajaran/rattail
	name = "Rattail (Tajaran)"
	icon_state= "rattail"

/datum/sprite_accessory/hair/tajaran/spikey
	name = "Spikey (Tajaran)"
	icon_state= "spikey"

/datum/sprite_accessory/hair/tajaran/messy
	name = "Messy (Tajaran)"
	icon_state= "messy"

/datum/sprite_accessory/hair/tajaran/curly
	name = "Curly (Tajaran)"
	icon_state= "curly"

/datum/sprite_accessory/hair/tajaran/ladies_retro
	name = "Retro (Tajaran)"
	icon_state= "ladiesretro"

/datum/sprite_accessory/hair/tajaran/victory
	name = "Victory (Tajaran)"
	icon_state= "victory"

/datum/sprite_accessory/hair/tajaran/bob
	name = "Bob (Tajaran)"
	icon_state= "bob"

/datum/sprite_accessory/hair/tajaran/fingerwave
	name = "Fingerwave (Tajaran)"
	icon_state= "fingerwave"

/datum/sprite_accessory/hair/tajaran/bedhead
	name = "Bedhead (Tajaran)"
	icon_state= "bedhead"

/////////////////////////////
// Facial Hair Definitions //
/////////////////////////////

/datum/sprite_accessory/facial_hair
	icon = 'icons/mob/facial_hair/human.dmi'
	gender = MALE // barf (unless you're a dorf, dorfs dig chix w/ beards :P)
	species = "human"

/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = "shaved"
	species = DEFAULT_SPECIES_INDEX
	gender = NEUTER

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/facial_hair/abe
	name = "Beard (Abraham Lincoln)"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/brokenman
	name = "Beard (Broken Man)"
	icon_state = "facial_brokenman"

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Beard (Chinstrap)"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Beard (Dwarf)"
	icon_state = "facial_dwarf"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Beard (Full)"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/croppedfullbeard
	name = "Beard (Cropped Fullbeard)"
	icon_state = "facial_croppedfullbeard"

/datum/sprite_accessory/facial_hair/gt
	name = "Beard (Goatee)"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/hip
	name = "Beard (Hipster)"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/jensen
	name = "Beard (Jensen)"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Beard (Neckbeard)"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Beard (Very Long)"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/muttonmus
	name = "Beard (Muttonmus)"
	icon_state = "facial_muttonmus"

/datum/sprite_accessory/facial_hair/martialartist
	name = "Beard (Martial Artist)"
	icon_state = "facial_martialartist"

/datum/sprite_accessory/facial_hair/chinlessbeard
	name = "Beard (Chinless Beard)"
	icon_state = "facial_chinlessbeard"

/datum/sprite_accessory/facial_hair/moonshiner
	name = "Beard (Moonshiner)"
	icon_state = "facial_moonshiner"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Beard (Long)"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/volaju
	name = "Beard (Volaju)"
	icon_state = "facial_volaju"

/datum/sprite_accessory/facial_hair/threeoclock
	name = "Beard (Three o Clock Shadow)"
	icon_state = "facial_3oclock"

/datum/sprite_accessory/facial_hair/fiveoclock
	name = "Beard (Five o Clock Shadow)"
	icon_state = "facial_fiveoclock"

/datum/sprite_accessory/facial_hair/fiveoclockm
	name = "Beard (Five o Clock Moustache)"
	icon_state = "facial_5oclockmoustache"

/datum/sprite_accessory/facial_hair/sevenoclock
	name = "Beard (Seven o Clock Shadow)"
	icon_state = "facial_7oclock"

/datum/sprite_accessory/facial_hair/sevenoclockm
	name = "Beard (Seven o Clock Moustache)"
	icon_state = "facial_7oclockmoustache"

/datum/sprite_accessory/facial_hair/moustache
	name = "Moustache"
	icon_state = "facial_moustache"

/datum/sprite_accessory/facial_hair/pencilstache
	name = "Moustache (Pencilstache)"
	icon_state = "facial_pencilstache"

/datum/sprite_accessory/facial_hair/smallstache
	name = "Moustache (Smallstache)"
	icon_state = "facial_smallstache"

/datum/sprite_accessory/facial_hair/walrus
	name = "Moustache (Walrus)"
	icon_state = "facial_walrus"

/datum/sprite_accessory/facial_hair/fu
	name = "Moustache (Fu Manchu)"
	icon_state = "facial_fumanchu"

/datum/sprite_accessory/facial_hair/hogan
	name = "Moustache (Hulk Hogan)"
	icon_state = "facial_hogan" //-Neek

/datum/sprite_accessory/facial_hair/selleck
	name = "Moustache (Selleck)"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Moustache (Square)"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/vandyke
	name = "Moustache (Van Dyke)"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/watson
	name = "Moustache (Watson)"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/elvis
	name = "Sideburns (Elvis)"
	icon_state = "facial_elvis"

/datum/sprite_accessory/facial_hair/mutton
	name = "Sideburns (Mutton Chops)"
	icon_state = "facial_mutton"

/datum/sprite_accessory/facial_hair/sideburn
	name = "Sideburns"
	icon_state = "facial_sideburn"


/datum/sprite_accessory/facial_hair/tajaran
	name = "Goatee (tajaran)"
	icon_state = "facial_goatee"
	species = "tajaran"
	icon = 'icons/mob/facial_hair/tajaran.dmi'

/datum/sprite_accessory/facial_hair/tajaran/faded
	name = "Goatee Faded (tajaran)"
	icon_state = "facial_goatee_faded"

/datum/sprite_accessory/facial_hair/tajaran
	name = "Goatee (tajaran)"
	icon_state = "facial_goatee"
	species = "tajaran"
	icon = 'icons/mob/facial_hair/tajaran.dmi'

/datum/sprite_accessory/facial_hair/tajaran/faded
	name = "Goatee Faded (tajaran)"
	icon_state = "facial_goatee_faded"

/datum/sprite_accessory/facial_hair/tajaran/moustache
	name = "Moustache (tajaran)"
	icon_state = "facial_moustache"

/datum/sprite_accessory/facial_hair/tajaran/mutton
	name = "Mutton (tajaran)"
	icon_state = "facial_mutton"

/datum/sprite_accessory/facial_hair/tajaran/pencil
	name = "Pencilstache (tajaran)"
	icon_state = "facial_pencilstache"

/datum/sprite_accessory/facial_hair/tajaran/sideburns
	name = "Sideburns (tajaran)"
	icon_state = "facial_sideburns"

/datum/sprite_accessory/facial_hair/tajaran/smallstache
	name = "Small moustache (tajaran)"
	icon_state = "facial_smallstache"

///////////////////////////
// Underwear Definitions //
///////////////////////////

/datum/sprite_accessory/underwear
	icon = 'icons/mob/clothing/underwear.dmi'
	use_static = FALSE


//MALE UNDERWEAR
/datum/sprite_accessory/underwear/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/underwear/male_briefs
	name = "Men's Briefs"
	icon_state = "male_briefs"
	gender = MALE

/datum/sprite_accessory/underwear/male_boxers
	name = "Men's Boxer"
	icon_state = "male_boxers"
	gender = MALE

/datum/sprite_accessory/underwear/male_stripe
	name = "Men's Striped Boxer"
	icon_state = "male_stripe"
	gender = MALE

/datum/sprite_accessory/underwear/male_midway
	name = "Men's Midway Boxer"
	icon_state = "male_midway"
	gender = MALE

/datum/sprite_accessory/underwear/male_longjohns
	name = "Men's Long Johns"
	icon_state = "male_longjohns"
	gender = MALE

/datum/sprite_accessory/underwear/male_kinky
	name = "Men's Kinky"
	icon_state = "male_kinky"
	gender = MALE

/datum/sprite_accessory/underwear/male_mankini
	name = "Mankini"
	icon_state = "male_mankini"
	gender = MALE

/datum/sprite_accessory/underwear/male_hearts
	name = "Men's Hearts Boxer"
	icon_state = "male_hearts"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_commie
	name = "Men's Striped Commie Boxer"
	icon_state = "male_commie"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_usastripe
	name = "Men's Striped Freedom Boxer"
	icon_state = "male_assblastusa"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_uk
	name = "Men's Striped UK Boxer"
	icon_state = "male_uk"
	gender = MALE
	use_static = TRUE


//FEMALE UNDERWEAR
/datum/sprite_accessory/underwear/female_bikini
	name = "Ladies' Bikini"
	icon_state = "female_bikini"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_lace
	name = "Ladies' Lace"
	icon_state = "female_lace"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_bralette
	name = "Ladies' Bralette"
	icon_state = "female_bralette"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_sport
	name = "Ladies' Sport"
	icon_state = "female_sport"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_thong
	name = "Ladies' Thong"
	icon_state = "female_thong"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_strapless
	name = "Ladies' Strapless"
	icon_state = "female_strapless"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_babydoll
	name = "Babydoll"
	icon_state = "female_babydoll"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_onepiece
	name = "Ladies' One Piece Swimsuit"
	icon_state = "swim_onepiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_strapless_onepiece
	name = "Ladies' Strapless One Piece Swimsuit"
	icon_state = "swim_strapless_onepiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_twopiece
	name = "Ladies' Two Piece Swimsuit"
	icon_state = "swim_twopiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_strapless_twopiece
	name = "Ladies' Strapless Two Piece Swimsuit"
	icon_state = "swim_strapless_twopiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_stripe
	name = "Ladies' Stripe Swimsuit"
	icon_state = "swim_stripe"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_halter
	name = "Ladies' Halter Swimsuit"
	icon_state = "swim_halter"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_white_neko
	name = "Ladies' White Neko"
	icon_state = "female_neko_white"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_black_neko
	name = "Ladies' Black Neko"
	icon_state = "female_neko_black"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_commie
	name = "Ladies' Commie"
	icon_state = "female_commie"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_usastripe
	name = "Ladies' Freedom"
	icon_state = "female_assblastusa"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_uk
	name = "Ladies' UK"
	icon_state = "female_uk"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_kinky
	name = "Ladies' Kinky"
	icon_state = "female_kinky"
	gender = FEMALE
	use_static = TRUE

////////////////////////////
// Undershirt Definitions //
////////////////////////////

/datum/sprite_accessory/undershirt
	icon = 'icons/mob/clothing/underwear.dmi'

/datum/sprite_accessory/undershirt/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/undershirt/bluejersey
	name = "Jersey (Blue)"
	icon_state = "shirt_bluejersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redjersey
	name = "Jersey (Red)"
	icon_state = "shirt_redjersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/bluepolo
	name = "Polo Shirt (Blue)"
	icon_state = "bluepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/grayyellowpolo
	name = "Polo Shirt (Gray-Yellow)"
	icon_state = "grayyellowpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redpolo
	name = "Polo Shirt (Red)"
	icon_state = "redpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whitepolo
	name = "Polo Shirt (White)"
	icon_state = "whitepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/alienshirt
	name = "Shirt (Alien)"
	icon_state = "shirt_alien"
	gender = NEUTER

/datum/sprite_accessory/undershirt/mondmondjaja
	name = "Shirt (Band)"
	icon_state = "band"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_black
	name = "Shirt (Black)"
	icon_state = "shirt_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirt
	name = "Shirt (Blue)"
	icon_state = "shirt_blue"
	gender = NEUTER

/datum/sprite_accessory/undershirt/clownshirt
	name = "Shirt (Clown)"
	icon_state = "shirt_clown"
	gender = NEUTER

/datum/sprite_accessory/undershirt/commie
	name = "Shirt (Commie)"
	icon_state = "shirt_commie"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirt
	name = "Shirt (Green)"
	icon_state = "shirt_green"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_grey
	name = "Shirt (Grey)"
	icon_state = "shirt_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ian
	name = "Shirt (Ian)"
	icon_state = "ian"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ilovent
	name = "Shirt (I Love NT)"
	icon_state = "ilovent"
	gender = NEUTER

/datum/sprite_accessory/undershirt/lover
	name = "Shirt (Lover)"
	icon_state = "lover"
	gender = NEUTER

/datum/sprite_accessory/undershirt/matroska
	name = "Shirt (Matroska)"
	icon_state = "matroska"
	gender = NEUTER

/datum/sprite_accessory/undershirt/meat
	name = "Shirt (Meat)"
	icon_state = "shirt_meat"
	gender = NEUTER

/datum/sprite_accessory/undershirt/nano
	name = "Shirt (Nanotrasen)"
	icon_state = "shirt_nano"
	gender = NEUTER

/datum/sprite_accessory/undershirt/peace
	name = "Shirt (Peace)"
	icon_state = "peace"
	gender = NEUTER

/datum/sprite_accessory/undershirt/pacman
	name = "Shirt (Pogoman)"
	icon_state = "pogoman"
	gender = NEUTER

/datum/sprite_accessory/undershirt/question
	name = "Shirt (Question)"
	icon_state = "shirt_question"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirt
	name = "Shirt (Red)"
	icon_state = "shirt_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/skull
	name = "Shirt (Skull)"
	icon_state = "shirt_skull"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ss13
	name = "Shirt (SS13)"
	icon_state = "shirt_ss13"
	gender = NEUTER

/datum/sprite_accessory/undershirt/stripe
	name = "Shirt (Striped)"
	icon_state = "shirt_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tiedye
	name = "Shirt (Tie-dye)"
	icon_state = "shirt_tiedye"
	gender = NEUTER

/datum/sprite_accessory/undershirt/uk
	name = "Shirt (UK)"
	icon_state = "uk"
	gender = NEUTER

/datum/sprite_accessory/undershirt/usa
	name = "Shirt (USA)"
	icon_state = "shirt_assblastusa"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_white
	name = "Shirt (White)"
	icon_state = "shirt_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blackshortsleeve
	name = "Short-sleeved Shirt (Black)"
	icon_state = "blackshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshortsleeve
	name = "Short-sleeved Shirt (Blue)"
	icon_state = "blueshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshortsleeve
	name = "Short-sleeved Shirt (Green)"
	icon_state = "greenshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/purpleshortsleeve
	name = "Short-sleeved Shirt (Purple)"
	icon_state = "purpleshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whiteshortsleeve
	name = "Short-sleeved Shirt (White)"
	icon_state = "whiteshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sports_bra
	name = "Sports Bra"
	icon_state = "sports_bra"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sports_bra2
	name = "Sports Bra (Alt)"
	icon_state = "sports_bra_alt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirtsport
	name = "Sports Shirt (Blue)"
	icon_state = "blueshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirtsport
	name = "Sports Shirt (Green)"
	icon_state = "greenshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirtsport
	name = "Sports Shirt (Red)"
	icon_state = "redshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_black
	name = "Tank Top (Black)"
	icon_state = "tank_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankfire
	name = "Tank Top (Fire)"
	icon_state = "tank_fire"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_grey
	name = "Tank Top (Grey)"
	icon_state = "tank_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/female_midriff
	name = "Tank Top (Midriff)"
	icon_state = "tank_midriff"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tank_red
	name = "Tank Top (Red)"
	icon_state = "tank_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankstripe
	name = "Tank Top (Striped)"
	icon_state = "tank_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_white
	name = "Tank Top (White)"
	icon_state = "tank_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redtop
	name = "Top (Red)"
	icon_state = "redtop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/whitetop
	name = "Top (White)"
	icon_state = "whitetop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tshirt_blue
	name = "T-Shirt (Blue)"
	icon_state = "blueshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tshirt_green
	name = "T-Shirt (Green)"
	icon_state = "greenshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tshirt_red
	name = "T-Shirt (Red)"
	icon_state = "redshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/yellowshirt
	name = "T-Shirt (Yellow)"
	icon_state = "yellowshirt"
	gender = NEUTER

///////////////////////
// Socks Definitions //
///////////////////////

/datum/sprite_accessory/socks
	icon = 'icons/mob/clothing/underwear.dmi'

/datum/sprite_accessory/socks/nude
	name = "Nude"
	icon_state = null

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/socks/black_knee
	name = "Knee-high (Black)"
	icon_state = "black_knee"

/datum/sprite_accessory/socks/commie_knee
	name = "Knee-High (Commie)"
	icon_state = "commie_knee"

/datum/sprite_accessory/socks/usa_knee
	name = "Knee-High (Freedom)"
	icon_state = "assblastusa_knee"

/datum/sprite_accessory/socks/rainbow_knee
	name = "Knee-high (Rainbow)"
	icon_state = "rainbow_knee"

/datum/sprite_accessory/socks/striped_knee
	name = "Knee-high (Striped)"
	icon_state = "striped_knee"

/datum/sprite_accessory/socks/thin_knee
	name = "Knee-high (Thin)"
	icon_state = "thin_knee"

/datum/sprite_accessory/socks/uk_knee
	name = "Knee-High (UK)"
	icon_state = "uk_knee"

/datum/sprite_accessory/socks/white_knee
	name = "Knee-high (White)"
	icon_state = "white_knee"

/datum/sprite_accessory/socks/bee_knee
	name = "Knee-high (Bee)"
	icon_state = "bee_knee"

/datum/sprite_accessory/socks/black_norm
	name = "Normal (Black)"
	icon_state = "black_norm"

/datum/sprite_accessory/socks/white_norm
	name = "Normal (White)"
	icon_state = "white_norm"

/datum/sprite_accessory/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"

/datum/sprite_accessory/socks/black_short
	name = "Short (Black)"
	icon_state = "black_short"

/datum/sprite_accessory/socks/white_short
	name = "Short (White)"
	icon_state = "white_short"

/datum/sprite_accessory/socks/stockings_blue
	name = "Stockings (Blue)"
	icon_state = "stockings_blue"

/datum/sprite_accessory/socks/stockings_cyan
	name = "Stockings (Cyan)"
	icon_state = "stockings_cyan"

/datum/sprite_accessory/socks/stockings_dpink
	name = "Stockings (Dark Pink)"
	icon_state = "stockings_dpink"

/datum/sprite_accessory/socks/stockings_green
	name = "Stockings (Green)"
	icon_state = "stockings_black"

/datum/sprite_accessory/socks/stockings_orange
	name = "Stockings (Orange)"
	icon_state = "stockings_orange"

/datum/sprite_accessory/socks/stockings_programmer
	name = "Stockings (Programmer)"
	icon_state = "stockings_lpink"

/datum/sprite_accessory/socks/stockings_purple
	name = "Stockings (Purple)"
	icon_state = "stockings_purple"

/datum/sprite_accessory/socks/stockings_yellow
	name = "Stockings (Yellow)"
	icon_state = "stockings_yellow"

/datum/sprite_accessory/socks/black_thigh
	name = "Thigh-high (Black)"
	icon_state = "black_thigh"

/datum/sprite_accessory/socks/commie_thigh
	name = "Thigh-high (Commie)"
	icon_state = "commie_thigh"

/datum/sprite_accessory/socks/usa_thigh
	name = "Thigh-high (Freedom)"
	icon_state = "assblastusa_thigh"

/datum/sprite_accessory/socks/rainbow_thigh
	name = "Thigh-high (Rainbow)"
	icon_state = "rainbow_thigh"

/datum/sprite_accessory/socks/striped_thigh
	name = "Thigh-high (Striped)"
	icon_state = "striped_thigh"

/datum/sprite_accessory/socks/thin_thigh
	name = "Thigh-high (Thin)"
	icon_state = "thin_thigh"

/datum/sprite_accessory/socks/uk_thigh
	name = "Thigh-high (UK)"
	icon_state = "uk_thigh"

/datum/sprite_accessory/socks/white_thigh
	name = "Thigh-high (White)"
	icon_state = "white_thigh"

/datum/sprite_accessory/socks/bee_thigh
	name = "Thigh-high (Bee)"
	icon_state = "bee_thigh"

/datum/sprite_accessory/socks/thocks
	name = "Thocks"
	icon_state = "thocks"

///////////
// Tails //
///////////

/datum/sprite_accessory/tails
	icon = 'icons/mob/sprite_accessories/tails.dmi'
	species = "lizard"

/datum/sprite_accessory/tails_animated
	icon = 'icons/mob/sprite_accessories/tails.dmi'

/datum/sprite_accessory/tails/none
	name = "None"
	icon_state = "none"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/tails_animated/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/tails/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails_animated/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails_animated/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails_animated/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails_animated/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails/cat
	name = "Cat"
	icon_state = "cat"
	color_src = HAIR
	species = "felinid"

/datum/sprite_accessory/tails_animated/cat
	name = "Cat"
	icon_state = "cat"
	color_src = HAIR

/datum/sprite_accessory/tails/tajaran
	name = "Wingler"
	icon_state = "wingler"
	species = "tajaran"
	color_src = SKIN_TONE

/datum/sprite_accessory/tails_animated/tajaran
	name = "Wingler"
	icon_state = "wingler"
	color_src = SKIN_TONE


///////////
// Snouts//
///////////

/datum/sprite_accessory/snouts
	icon = 'icons/mob/sprite_accessories/snout.dmi'
	species = "lizard"

/datum/sprite_accessory/snouts/none
	name = "None"
	icon_state = "none"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/snouts/sharp
	name = "Sharp"
	icon_state = "sharp"

/datum/sprite_accessory/snouts/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/snouts/sharplight
	name = "Sharp + Light"
	icon_state = "sharplight"

/datum/sprite_accessory/snouts/roundlight
	name = "Round + Light"
	icon_state = "roundlight"

/datum/sprite_accessory/snouts/tajaran
	name = "Light (Tajaran)"
	icon_state = "tajaran_light"
	species = "tajaran"
	hasinner = TRUE
	color_src = SKIN_TONE
	gender_specific = TRUE

///////////
// Horns //
///////////

/datum/sprite_accessory/horns
	icon = 'icons/mob/sprite_accessories/horns.dmi'
	species = "lizard"

/datum/sprite_accessory/horns/none
	name = "None"
	icon_state = "none"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/horns/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/horns/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/horns/curled
	name = "Curled"
	icon_state = "curled"

/datum/sprite_accessory/horns/ram
	name = "Ram"
	icon_state = "ram"

/datum/sprite_accessory/horns/angler
	name = "Angeler"
	icon_state = "angler"

datum/sprite_accessory/horns/antennae
	name = "Antennae"
	icon_state = "antennae"
	color_src = AUG_COLOR
	species = "robotic"

datum/sprite_accessory/horns/antlers
	name = "Antlers"
	icon_state = "antlers"
	color_src = AUG_COLOR
	species = "robotic"

datum/sprite_accessory/horns/tvantennae
	name = "TV Antennae"
	icon_state = "tvantennae"
	color_src = AUG_COLOR
	species = "robotic"

datum/sprite_accessory/horns/crowned
	name = "Crowned"
	icon_state = "crowned"
	color_src = AUG_COLOR
	species = "robotic"

////////////
// Frills //
////////////

/datum/sprite_accessory/frills
	icon = 'icons/mob/sprite_accessories/frills.dmi'
	species = "lizard"

/datum/sprite_accessory/frills/none
	name = "None"
	icon_state = "none"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/frills/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/frills/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/frills/aquatic
	name = "Aquatic"
	icon_state = "aqua"

//////////////////////
// Tail Accessories //
//////////////////////

/datum/sprite_accessory/tail_accessory
	icon = 'icons/mob/sprite_accessories/tail_accessories.dmi'
	species = "lizard"

/datum/sprite_accessory/tail_accessory_animated
	icon = 'icons/mob/sprite_accessories/tail_accessories.dmi'

/datum/sprite_accessory/tail_accessory/none
	name = "None"
	icon_state = "none"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/tail_accessory_animated/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/tail_accessory/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/tail_accessory_animated/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/tail_accessory/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/tail_accessory_animated/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/tail_accessory/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/tail_accessory_animated/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/tail_accessory/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/tail_accessory_animated/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/tail_accessory/aqautic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/tail_accessory_animated/aqautic
	name = "Aquatic"
	icon_state = "aqua"

////////////
// Ears ///
//////////

/datum/sprite_accessory/ears
	icon = 'icons/mob/sprite_accessories/ears.dmi'

/datum/sprite_accessory/ears/none
	name = "None"
	icon_state = "none"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/ears/cat
	name = "Cat"
	icon_state = "cat"
	species = "felinid"
	hasinner = TRUE
	color_src = HAIR

/datum/sprite_accessory/ears/tajaran
	name = "Pointed"
	icon_state = "tajaran_pointed"
	species = "tajaran"
	color_src = SKIN_TONE

////////////
// Wings //
//////////

/datum/sprite_accessory/wings
	icon = 'icons/mob/clothing/wings.dmi'

/datum/sprite_accessory/wings_open
	icon = 'icons/mob/clothing/wings.dmi'

/datum/sprite_accessory/wings/none
	name = "None"
	icon_state = "none"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/wings/angel
	name = "Angel"
	icon_state = "angel"
	species = "angel"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34

/datum/sprite_accessory/wings_open/angel
	name = "Angel"
	icon_state = "angel"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34

/datum/sprite_accessory/wings/dragon
	name = "Dragon"
	icon_state = "dragon"
	species = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings_open/dragon
	name = "Dragon"
	icon_state = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/moth
	icon = 'icons/mob/sprite_accessories/wings.dmi'
	name = "Plain"
	icon_state = "plain"
	color_src = null
	species = "moth"
	dimension_x = 45
	dimension_y = 34

/datum/sprite_accessory/wings/moth/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/sprite_accessory/wings/moth/luna
	name = "Luna"
	icon_state = "luna"

/datum/sprite_accessory/wings/moth/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/sprite_accessory/wings/moth/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/sprite_accessory/wings/moth/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/wings/moth/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/wings/moth/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/wings/moth/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/wings/moth/punished
	name = "Burnt Off"
	icon_state = "punished"
	locked = TRUE

/datum/sprite_accessory/wings/moth/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/wings/moth/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/wings/moth/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/wings/moth/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/wings/moth/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/wings/moth/snow
	name = "Snow"
	icon_state = "snow"

////////////////////
// Face Markings  //
///////////////////

////////////////////
// Body Markings //
///////////////////
/datum/sprite_accessory/face_markings
	icon = 'icons/mob/sprite_accessories/face_markings.dmi'
	species = "tajaran"

/datum/sprite_accessory/face_markings/none
	name = "None"
	icon_state = "none"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/body_markings
	icon = 'icons/mob/sprite_accessories/body_markings.dmi'
	species = "lizard"
	gender_specific = TRUE

/datum/sprite_accessory/body_markings/none
	name = "None"
	icon_state = "none"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/body_markings/dark_tiger
	name = "Dark Tiger Body"
	icon_state = "dtiger"

/datum/sprite_accessory/body_markings/light_tiger
	name = "Light Tiger Body"
	icon_state = "dtiger"

/datum/sprite_accessory/body_markings/light_belly
	name = "Light Belly"
	icon_state = "lbelly"


/datum/sprite_accessory/body_markings/moth // the markings that moths can have. finally something other than the boring tan
	name = "Reddish"
	icon_state = "reddish"
	icon = 'icons/mob/sprite_accessories/moth_markings.dmi'
	gender_specific = FALSE
	color_src = null
	species = "moth"
	dimension_x = 45
	dimension_y = 34

/datum/sprite_accessory/body_markings/moth/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/body_markings/moth/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/body_markings/moth/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/body_markings/moth/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/body_markings/moth/punished
	name = "Punished"
	icon_state = "punished"
	locked = TRUE

/datum/sprite_accessory/body_markings/moth/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/body_markings/moth/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/body_markings/moth/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/body_markings/moth/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/body_markings/moth/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

//////////
// Misc //
/////////

/datum/sprite_accessory/legs 	//legs are a special case, they aren't actually sprite_accessories but are updated with them.
	icon = null					//These datums exist for selecting legs on preference, and little else

/datum/sprite_accessory/legs/none
	name = "None"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/legs/digitigrade_lizard
	name = "Digitigrade Legs"
	species = "lizard"

/datum/sprite_accessory/caps
	icon = 'icons/mob/sprite_accessories/misc.dmi'
	color_src = HAIR

/datum/sprite_accessory/caps/none
	name = "None"
	icon_state = "none"
	species = DEFAULT_SPECIES_INDEX

/datum/sprite_accessory/caps/round
	name = "Round"
	icon_state = "round"
	species = "mush"

//////////////////
// Augmentation //
//////////////////

//augmented limb sets

/datum/sprite_accessory/augmentation
	var/list/eligible_bodyparts = list()
	var/list/optics_types = list()
	icon_state = TRUE // a bit of a hack, this makes sure the datums are indexed properly in the global list

/datum/sprite_accessory/augmentation/nanotrasen
	name = "Nanotrasen Robotics Division"
	species = "nanotrasen"
	eligible_bodyparts = list(BODY_ZONE_HEAD = list(AUG_TYPE_ROBOTIC, AUG_TYPE_MONITOR),
								BODY_ZONE_CHEST = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_L_ARM = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_R_ARM = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_L_LEG = list(AUG_TYPE_ROBOTIC, AUG_TYPE_DIGITIGRADE),
								BODY_ZONE_R_LEG = list(AUG_TYPE_ROBOTIC, AUG_TYPE_DIGITIGRADE))
	optics_types = list(AUG_TYPE_ROBOTIC, AUG_TYPE_MONITOR)

/datum/sprite_accessory/augmentation/bishop
	name = "Bishop Cybernetics"
	species = "bishop"
	eligible_bodyparts = list(BODY_ZONE_HEAD = list(AUG_TYPE_ROBOTIC, AUG_TYPE_MONITOR, AUG_TYPE_ANDROID),
								BODY_ZONE_CHEST = list(AUG_TYPE_ROBOTIC, AUG_TYPE_ANDROID),
								BODY_ZONE_L_ARM = list(AUG_TYPE_ROBOTIC, AUG_TYPE_ANDROID),
								BODY_ZONE_R_ARM = list(AUG_TYPE_ROBOTIC, AUG_TYPE_ANDROID),
								BODY_ZONE_L_LEG = list(AUG_TYPE_ROBOTIC, AUG_TYPE_ANDROID, AUG_TYPE_DIGITIGRADE),
								BODY_ZONE_R_LEG = list(AUG_TYPE_ROBOTIC, AUG_TYPE_ANDROID, AUG_TYPE_DIGITIGRADE))
	optics_types = list(AUG_TYPE_ROBOTIC_ALT, AUG_TYPE_MONITOR)

/datum/sprite_accessory/augmentation/medical
	name = "Ward-Takahashi Robotics Medical Line"
	species = "wt-medical"
	eligible_bodyparts = list(BODY_ZONE_HEAD = list(AUG_TYPE_ROBOTIC, AUG_TYPE_ANDROID, AUG_TYPE_MONITOR),
								BODY_ZONE_CHEST = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_L_ARM = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_R_ARM = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_L_LEG = list(AUG_TYPE_ROBOTIC, AUG_TYPE_DIGITIGRADE),
								BODY_ZONE_R_LEG = list(AUG_TYPE_ROBOTIC, AUG_TYPE_DIGITIGRADE))
	optics_types = list(AUG_TYPE_ROBOTIC_ALT, AUG_TYPE_MONITOR)

/datum/sprite_accessory/augmentation/industrial
	name = "Ward-Takahashi Robotics Industrial Line"
	species = "wt-industrial"
	eligible_bodyparts = list(BODY_ZONE_HEAD = list(AUG_TYPE_ROBOTIC, AUG_TYPE_MONITOR),
								BODY_ZONE_CHEST = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_L_ARM = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_R_ARM = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_L_LEG = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_R_LEG = list(AUG_TYPE_ROBOTIC))
	optics_types = list(AUG_TYPE_ROBOTIC, AUG_TYPE_MONITOR)

/datum/sprite_accessory/augmentation/shellguard
	name = "Ward-Takahashi Robotics Shellguard Line"
	species = "wt-shellguard"
	eligible_bodyparts = list(BODY_ZONE_HEAD = list(AUG_TYPE_ROBOTIC, AUG_TYPE_MONITOR),
								BODY_ZONE_CHEST = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_L_ARM = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_R_ARM = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_L_LEG = list(AUG_TYPE_ROBOTIC),
								BODY_ZONE_R_LEG = list(AUG_TYPE_ROBOTIC))
	optics_types = list(AUG_TYPE_ROBOTIC, AUG_TYPE_MONITOR)

/datum/sprite_accessory/augmentation/prosthetic
	name = "Ward-Takahashi Robotics Prosthetics Line"
	species = "wt-prosthetic"
	eligible_bodyparts = list(BODY_ZONE_HEAD = list(AUG_TYPE_ANDROID),
								BODY_ZONE_CHEST = list(AUG_TYPE_ANDROID),
								BODY_ZONE_L_ARM = list(AUG_TYPE_ANDROID),
								BODY_ZONE_R_ARM = list(AUG_TYPE_ANDROID),
								BODY_ZONE_L_LEG = list(AUG_TYPE_ANDROID),
								BODY_ZONE_R_LEG = list(AUG_TYPE_ANDROID))
//optics
/datum/sprite_accessory/optics
	name = "Standard Optics"
	icon = 'icons/mob/augmentation/aug_optics.dmi'
	color_src = EYECOLOR
	var/augtype

/datum/sprite_accessory/optics/visor
	name = "Visor Optics"
	icon_state = "visor"

/datum/sprite_accessory/optics/goggles
	name = "Goggle Optics"
	icon_state = "goggles"

/datum/sprite_accessory/optics/nanotrasen
	name = "Nanotrasen Optics"
	species = "nanotrasen"
	augtype = AUG_TYPE_ROBOTIC

/datum/sprite_accessory/optics/bishop
	name = "Bishop Cybernetics Optics"
	species = "bishop"
	augtype = AUG_TYPE_ROBOTIC_ALT

/datum/sprite_accessory/optics/medical
	name = "Ward-Takahashi Medical Optics"
	species = "wt-medical"
	augtype = AUG_TYPE_ROBOTIC_ALT

/datum/sprite_accessory/optics/industrial
	name = "Ward-Takahashi Industrial Optics"
	species = "wt-industrial"
	augtype = AUG_TYPE_ROBOTIC


//augmented legs

/datum/sprite_accessory/legs/augmentations
	name = "Nanotrasen Robotic Legs (Digitigrade)"
	species = "nanotrasen"

/datum/sprite_accessory/legs/augmentations/bishop
	name = "Bishop Cybernetics Legs (Digitigrade)"
	species = "bishop"

/datum/sprite_accessory/legs/augmentations/medical
	name = "Ward-Takahashi Medical Legs (Digitigrade)"
	species = "wt-medical"


/datum/sprite_accessory/legs/augmentations/industrial
	name = "Ward-Takahashi Industrial Legs (Digitigrade)"
	species = "wt-industrial"

/datum/sprite_accessory/legs/augmentations/shellguard
	name = "Ward-Takahashi Shellguard Legs (Digitigrade)"
	species = "wt-shellguard"


//monitors
/datum/sprite_accessory/monitor_state/off
	name = "Off"
	icon_state = ""
	icon = 'icons/mob/augmentation/aug_monitor_faces.dmi'

/datum/sprite_accessory/monitor_state/lumi_eyes
	name = "Luminescent eyes"
	icon_state = "lumi_eyes"

/datum/sprite_accessory/monitor_state/lumi_waiting
	name = "Waiting"
	icon_state = "lumi_waiting"

/datum/sprite_accessory/monitor_state/eight
	name = "Eight"
	icon_state = "eight"

/datum/sprite_accessory/monitor_state/red_eyes
	name = "Red Eyes"
	icon_state = "eyes_red"

/datum/sprite_accessory/monitor_state/alert
	name = "Alert"
	icon_state = "alert"

/datum/sprite_accessory/monitor_state/heart
	name = "Heart"
	icon_state = "heart"

/datum/sprite_accessory/monitor_state/monoeye
	name = "Mono Eye"
	icon_state = "monoeye"

/datum/sprite_accessory/monitor_state/nature
	name = "Nature"
	icon_state = "nature"

/datum/sprite_accessory/monitor_state/orange
	name = "Orange"
	icon_state = "orange"

/datum/sprite_accessory/monitor_state/skull
	name = "Skull"
	icon_state = "skull"
