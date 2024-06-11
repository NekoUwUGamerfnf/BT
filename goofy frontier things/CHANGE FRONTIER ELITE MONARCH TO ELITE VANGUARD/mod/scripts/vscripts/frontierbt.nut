global function frontierbt_init


void function frontierbt_init() {
#if SERVER
    	PrecacheModel( $"models/titans/buddy/titan_buddy.mdl" )
	AddSpawnCallback( "npc_titan", BTT )
#endif
}

void function BTT( entity titan )
{
thread B( titan )
}

#if SERVER
void function B( entity titan )
{
	string attackerType = GetTitanCharacterName( titan )
	switch ( attackerType )
	    {
		case "vanguard": foreach (entity titan in GetTitanArrayOfTeam( TEAM_IMC ))
                              if( IsValid(titan) && titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == 32 && titan.GetSkin() == 2  ) // elite vanguard
                              {
                                entity soul = titan.GetTitanSoul()
                                wait 6.1
                               titan.SetModel($"models/titans/buddy/titan_buddy_skyway.mdl") // FS-1041
				titan.TakeOffhandWeapon( OFFHAND_INVENTORY )
                                titan.TakeOffhandWeapon( OFFHAND_ANTIRODEO )
                                titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_ANTIRODEO )
				titan.TakeOffhandWeapon(OFFHAND_EQUIPMENT)
				titan.GiveOffhandWeapon( "mp_titancore_amp_core", OFFHAND_EQUIPMENT )
           			titan.TakeOffhandWeapon(OFFHAND_ORDNANCE)	
	     			titan.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", OFFHAND_ORDNANCE )
				titan.TakeOffhandWeapon(OFFHAND_SPECIAL)
				titan.GiveOffhandWeapon("mp_titanweapon_vortex_shield", OFFHAND_SPECIAL )
				titan.GetOffhandWeapons()[OFFHAND_SPECIAL].SetMods(["slow_recovery_vortex", "sp_wider_return_spread"])
                                titan.SetTitle( "Elite Vanguard" )
                                titan.kv.alwaysalert = 1
                                        soul.soul.skipDoomState = true
					soul.soul.titanLoadout.titanExecution = "execution_bt_pilotrip"
                              }
        }
}
#endif