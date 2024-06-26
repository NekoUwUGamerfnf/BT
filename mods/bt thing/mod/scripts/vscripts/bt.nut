global function bt_init


void function bt_init() {
#if SERVER
            	PrecacheParticleSystem( $"P_BT_eye_SM" )
    	PrecacheModel( $"models/titans/buddy/titan_buddy.mdl" )
	AddSpawnCallback( "npc_titan", BT )
		AddCallback_OnPilotBecomesTitan( OnPilotBecomesTitan )
		AddCallback_OnTitanBecomesPilot( OnTitanBecomesPilot )
#endif
}

void function um( entity titan )
{
	while( true )
	{
                if( IsValid(titan) && titan.GetModelName() == $"models/titans/buddy/titan_buddy.mdl" )
		loop( titan )
		WaitFrame()
	}
}

void function loop( entity titan )
{
                                titan.SetAISettings( "npc_titan_vanguard" )
                                titan.SetBehaviorSelector( "behavior_titan_long_range" )
                                titan.kv.alwaysalert = 0
                                titan.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
                                titan.EnableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
}

bool function CheckVoiceline( entity titan )
{
	#if SERVER
	if( IsValid(titan) )
	{
		entity soul = titan.GetTitanSoul()
		vector origin = titan.GetOrigin()
		//Voicelines
		if(IsValid(soul) && titan.GetModelName() == $"models/titans/buddy/titan_buddy.mdl")
		{
			if( soul.IsEjecting() )
			{
				EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "diag_sp_extra_GB101_99_01_mcor_bt" )
				return false
			}
			return true
		}	
	}
	#endif
	return false
}

void function EjectingVoiceline( entity titan )
{
	#if SERVER
	if( IsValid(titan) )
	{
		entity player = GetPetTitanOwner(titan)
		//Voicelines
		if( titan.GetModelName() == $"models/titans/buddy/titan_buddy.mdl")
		{
			entity soul = titan.GetTitanSoul()
			soul.EndSignal( "OnDestroy" )
			player.WaitSignal( "TitanEjectionStarted" )
			if( IsValid(player) )
			{
				vector origin = player.GetOrigin()
				EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "diag_sp_extra_GB101_99_01_mcor_bt" )
			}
		}
	}
	#endif
}


void function balls( entity titan )
{
	#if SERVER
	if( IsValid(titan) && titan.GetModelName() == $"models/titans/buddy/titan_buddy.mdl" )
        StartParticleEffectOnEntity( titan, GetParticleSystemIndex( $"P_BT_eye_SM" ), FX_PATTACH_POINT_FOLLOW, titan.LookupAttachment( "EYEGLOW" ) )
                                titan.SetAISettings( "npc_titan_vanguard" )
                                titan.SetBehaviorSelector( "behavior_titan_long_range" )
                                titan.kv.alwaysalert = 0
                                titan.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
                                titan.EnableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
                                titan.SetTitle( "BT-7274" )
                                thread um( titan )
                                //thread CheckVoiceline( titan )
                                //thread EjectingVoiceline( titan )
        entity soul = titan.GetTitanSoul()
                                if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_SHIELD ) )
				{
					soul.soul.titanLoadout.titanExecution = "execution_bt_flip"
					titan.SetSkin(1)
				}
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_DOOM) )
				{
					soul.soul.titanLoadout.titanExecution = "execution_bt_pilotrip"
					titan.SetSkin(1)
				}
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_REARM) )
				{
					soul.soul.titanLoadout.titanExecution = "execution_bt_kickshoot"
					titan.SetSkin(0)
				}
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_COREMETER ) )
				{
					TakePassive( soul, ePassives.PAS_VANGUARD_COREMETER )
					soul.soul.titanLoadout.titanExecution = "execution_bt_kickshoot"
					titan.SetSkin(2)
				}

	#endif
}

void function bop( entity player )
{
	#if SERVER
	if( IsValid(player) && player.GetModelName() == $"models/titans/buddy/titan_buddy.mdl" )
		                player.SetTitle( "BT-7274" )
	#endif
}

void function OnPilotBecomesTitan( entity player, entity titan )
{
        if( IsValid(player) && player.GetModelName() == $"models/titans/buddy/titan_buddy.mdl" )
	bop( player )
}

void function OnTitanBecomesPilot( entity player, entity titan )
{
        if( IsValid(titan) && titan.GetModelName() == $"models/titans/buddy/titan_buddy.mdl" )
	balls( titan )
}



#if SERVER
void function BT( entity titan )
{
        array<entity> weapons = titan.GetMainWeapons( )
	//entity weapon = titan.GetOffhandWeapon( OFFHAND_EQUIPMENT )
	if ( weapons[0] != null)
        { //titan.TakeWeaponNow( weapon.GetWeaponClassName() )
          //titan.TakeOffhandWeapon( OFFHAND_ANTIRODEO )
        }
	string attackerType = GetTitanCharacterName( titan )
	switch ( attackerType )
	    {
		case "vanguard": entity soul = titan.GetTitanSoul()
                              entity player = GetPetTitanOwner( titan )
                              if (IsValid( soul ) && IsValid( player )) // titan doesn't have a player and doesn't need execution refs
                              {
                               titan.SetModel($"models/titans/buddy/titan_buddy.mdl")
                                  StartParticleEffectOnEntity( titan, GetParticleSystemIndex( $"P_BT_eye_SM" ), FX_PATTACH_POINT_FOLLOW, titan.LookupAttachment( "EYEGLOW" ) )
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
                                titan.SetAISettings( "npc_titan_vanguard" )
                                titan.SetBehaviorSelector( "behavior_titan_long_range" )
                                titan.SetMaxHealth(12500)
                                titan.SetHealth(12500)
                                titan.kv.alwaysalert = 0
                                titan.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
                                titan.EnableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
                                titan.SetTitle( "BT-7274" )
                                thread um( titan )
                              entity soul = titan.GetTitanSoul()
                              entity player = GetPetTitanOwner( titan )
 		              GivePassive( soul, ePassives.PAS_ENHANCED_TITAN_AI )
                              soul.soul.skipDoomState = false
                              GivePassive( soul, ePassives.PAS_AUTO_EJECT )
                              GivePassive( soul, ePassives.PAS_MOBILITY_DASH_CAPACITY )
                              
                              if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_SHIELD ) )
				{
					soul.soul.titanLoadout.titanExecution = "execution_bt_flip"
					titan.SetSkin(1)
				}
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_DOOM) )
				{
					soul.soul.titanLoadout.titanExecution = "execution_bt_pilotrip"
					titan.SetSkin(1)
				}
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_REARM) )
				{
					soul.soul.titanLoadout.titanExecution = "execution_bt_kickshoot"
					titan.SetSkin(0)
				}
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_COREMETER ) )
				{
					TakePassive( soul, ePassives.PAS_VANGUARD_COREMETER )
					soul.soul.titanLoadout.titanExecution = "execution_bt_kickshoot"
					titan.SetSkin(2)
				}

                                
				if( TitanEjectIsDisabled() )
					soul.soul.skipDoomState = true
                              }
        }
}
#endif