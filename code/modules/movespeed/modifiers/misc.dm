/datum/movespeed_modifier/admin_varedit
	variable = TRUE

/datum/movespeed_modifier/yellow_orb
	multiplicative_slowdown = -0.65
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/vtec
	id = MOVESPEED_ID_SILICON_VTEC
	conflicts_with = MOVE_CONFLICT_VTEC
	multiplicative_slowdown = -1
	movetypes = ~FLYING

/datum/movespeed_modifier/vtec/full
	multiplicative_slowdown = -2

/datum/movespeed_modifier/vtec/overdrive
	multiplicative_slowdown = -2.5

