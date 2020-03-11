// Note: tails only work in humans. They use human-specific parameters and rely on human code for displaying.

/obj/item/organ/tail
	name = "tail"
	desc = "A severed tail. What did you cut this off of?"
	icon_state = "severedtail"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TAIL
	var/color_src = MUTCOLORS
	var/tail_type = "None"
	var/tail_accessory = "None"


/obj/item/organ/tail/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		if(!("tail" in H.dna.species.mutant_bodyparts))
			H.dna.features["tail"] = tail_type
			H.dna.species.mutant_bodyparts |= "tail"
		if(!("tail_accessory" in H.dna.species.mutant_bodyparts))
			H.dna.features["tail_accessory"] = tail_accessory
			H.dna.species.mutant_bodyparts |= "tail_accessory"
		H.update_body()

/obj/item/organ/tail/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(H && H.dna && H.dna.species)
		H.dna.species.stop_wagging_tail(H)
	if(istype(H))
		H.dna.species.mutant_bodyparts -= "tail"
		H.dna.species.mutant_bodyparts -= "tail_accessory"
		switch(color_src)
			if(MUTCOLORS|| MUTCOLORS_PARTSONLY)
				color = "#" + H.dna.features["mcolor"]
			if(HAIR)
				color = H.hair_color
			if(SKIN_TONE)
				color = "#" + sprite_color2hex(H.skin_tone, GLOB.skin_tones_list)
		tail_type = H.dna.features["tail"]
		tail_accessory = H.dna.features["tail_accessory"]
		H.update_body()


/obj/item/organ/external/tail/cat
	name = "cat tail"
	desc = "A severed cat tail. Who's wagging now?"
	tail_type = "Cat"
	color_src = HAIR

/obj/item/organ/external/tail/lizard
	name = "lizard tail"
	desc = "A severed lizard tail. Somewhere, no doubt, a lizard hater is very pleased with themselves."
	color = "#116611"
	tail_type = "Smooth"
	var/spines = "None"

/obj/item/organ/external/tail/lizard/Initialize()
	..()
	color = "#"+ random_color()

/obj/item/organ/external/tail/lizard/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		// Checks here are necessary so it wouldn't overwrite the tail of a lizard it spawned in
		if(!("tail_lizard" in H.dna.species.mutant_bodyparts))
			H.dna.features["tail_lizard"] = tail_type
			H.dna.species.mutant_bodyparts |= "tail_lizard"

/obj/item/organ/tail/tajaran
	name = "tajaran tail"
	desc = "A severed tajaran tail. Somewhere, no doubt, a tajaran hater is very pleased with themselves."
	color = "#116611"
	tail_type = "Winger"
	color_src = SKIN_TONE
