/obj/item/organ/external/ears
	name = "ears"
	icon_state = "ears"
	desc = "There are three parts to the ear. Inner, middle and outer. Only one of these parts should be normally visible."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	gender = PLURAL
	mutant_bodyparts = list("ears" = "None")
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = "<span class='info'>Your ears begin to resonate with an internal ring sometimes.</span>"
	now_failing = "<span class='warning'>You are unable to hear at all!</span>"
	now_fixed = "<span class='info'>Noise slowly begins filling your ears once more.</span>"
	low_threshold_cleared = "<span class='info'>The ringing in your ears has died down.</span>"

	// `deaf` measures "ticks" of deafness. While > 0, the person is unable
	// to hear anything.
	var/deaf = 0

	// `damage` in this case measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)

	//Resistance against loud noises
	var/bang_protect = 0
	// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1

/obj/item/organ/external/ears/on_life()
	if(!iscarbon(owner))
		return
	..()
	var/mob/living/carbon/C = owner
	if((damage < maxHealth) && (organ_flags & ORGAN_FAILING))	//ear damage can be repaired from the failing condition
		organ_flags &= ~ORGAN_FAILING
	// genetic deafness prevents the body from using the ears, even if healthy
	if(HAS_TRAIT(C, TRAIT_DEAF))
		deaf = max(deaf, 1)
	else if(!(organ_flags & ORGAN_FAILING)) // if this organ is failing, do not clear deaf stacks.
		deaf = max(deaf - 1, 0)
		if(prob(damage / 30) && (damage > low_threshold))
			adjustEarDamage(0, 4)
			SEND_SOUND(C, sound('sound/weapons/flash_ring.ogg'))
			to_chat(C, "<span class='warning'>The ringing in your ears grows louder, blocking out any external noises for a moment.</span>")
	else if((organ_flags & ORGAN_FAILING) && (deaf == 0))
		deaf = 1	//stop being not deaf you deaf idiot

/obj/item/organ/external/ears/proc/restoreEars()
	deaf = 0
	damage = 0
	organ_flags &= ~ORGAN_FAILING

	var/mob/living/carbon/C = owner

	if(iscarbon(owner) && HAS_TRAIT(C, TRAIT_DEAF))
		deaf = 1

/obj/item/organ/external/ears/proc/adjustEarDamage(ddmg, ddeaf)
	damage = max(damage + (ddmg*damage_multiplier), 0)
	deaf = max(deaf + (ddeaf*damage_multiplier), 0)

/obj/item/organ/external/ears/proc/minimumDeafTicks(value)
	deaf = max(deaf, value)

/obj/item/organ/external/ears/invincible
	damage_multiplier = 0


/mob/proc/restoreEars()

/mob/living/carbon/restoreEars()
	var/obj/item/organ/external/ears/ears = getorgan(/obj/item/organ/external/ears)
	if(ears)
		ears.restoreEars()

/mob/proc/adjustEarDamage()

/mob/living/carbon/adjustEarDamage(ddmg, ddeaf)
	var/obj/item/organ/external/ears/ears = getorgan(/obj/item/organ/external/ears)
	if(ears)
		ears.adjustEarDamage(ddmg, ddeaf)

/mob/proc/minimumDeafTicks()

/mob/living/carbon/minimumDeafTicks(value)
	var/obj/item/organ/external/ears/ears = getorgan(/obj/item/organ/external/ears)
	if(ears)
		ears.minimumDeafTicks(value)


/obj/item/organ/external/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "kitty"
	mutant_bodyparts = list("ears" = "Cat")
	no_update = TRUE // The memelords caused this.
	required_bodypart_status = BODYPART_ORGANIC
	damage_multiplier = 2

/obj/item/organ/external/ears/tajaran
	damage_multiplier = 2


//obj/item/organ/external/ears/cat/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	//..()
	//if(istype(H))
		//if(!color || owner == original_owner)
			//switch(color_src)
				//if(MUTCOLORS)
					//color = "#" + H.dna.features["mcolor"]
				//if(SKIN_TONE)
					//color = "#" + sprite_color2hex(H.skin_tone, GLOB.skin_tones_list)
				//if(HAIR)
					//color = H.hair_color
		//H.dna.species.mutant_bodyparts |= "ears"
		//H.dna.features["ears"] = feature_name
		//H.update_body()

//obj/item/organ/external/ears/cat/Remove(mob/living/carbon/human/H,  special = 0)
	//..()
	//if(istype(H))
		//if(!color || owner == original_owner)
			//switch(color_src)
				//if(MUTCOLORS)
					//color = H.dna.features["mcolor"]
				//if(SKIN_TONE)
					//color = "#" + sprite_color2hex(H.skin_tone, GLOB.skin_tones_list)
				//if(HAIR)
					//color = H.hair_color
		//H.dna.features["ears"] = "None"
		//H.dna.species.mutant_bodyparts -= "ears"
		//H.update_body()

/obj/item/organ/external/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."
	no_update = TRUE

/obj/item/organ/external/ears/penguin/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(istype(H))
		to_chat(H, "<span class='notice'>You suddenly feel like you've lost your balance.</span>")
		H.AddElement(/datum/element/waddling)

/obj/item/organ/external/ears/penguin/Remove(mob/living/carbon/human/H,  special = 0)
	. = ..()
	if(istype(H))
		to_chat(H, "<span class='notice'>Your sense of balance comes back to you.</span>")
		H.RemoveElement(/datum/element/waddling)

/obj/item/organ/external/ears/bronze
	name = "tin ears"
	desc = "The robust ears of a bronze golem. "
	damage_multiplier = 0.1 //STRONK
	bang_protect = 1 //Fear me weaklings.
	no_update = TRUE

/obj/item/organ/external/ears/cybernetic
	name = "cybernetic ears"
	icon_state = "ears-c"
	desc = "a basic cybernetic designed to mimic the operation of ears."
	damage_multiplier = 0.9
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/external/ears/cybernetic/upgraded
	name = "upgraded cybernetic ears"
	icon_state = "ears-c-u"
	desc = "an advanced cybernetic ear, surpassing the performance of organic ears"
	damage_multiplier = 0.5

/obj/item/organ/external/ears/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	damage += 40/severity

/obj/item/organ/external/ears/silicon
	name = "auditory receiver module"
	icon_state = "auditory-receiver-module"
	icon = 'icons/obj/silicon_components.dmi'
	desc = "An audio receiver module used in machines and androids"
	status = ORGAN_ROBOTIC
	required_bodypart_status = BODYPART_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/external/ears/silicon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	damage += 40/severity
