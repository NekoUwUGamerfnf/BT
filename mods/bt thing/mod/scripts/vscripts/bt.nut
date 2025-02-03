global function bt_init


void function bt_init() {
#if SERVER
	RegisterSignal( "fastball_start_throw" )
	RegisterSignal( "fastball_release" )
            	PrecacheParticleSystem( $"P_BT_eye_SM" )
    	PrecacheModel( $"models/titans/buddy/titan_buddy.mdl" )
	AddSpawnCallback( "npc_titan", BT )
		AddCallback_OnPilotBecomesTitan( OnPilotBecomesTitan )
		AddCallback_OnTitanBecomesPilot( OnTitanBecomesPilot )
                AddClientCommandCallback( "fastball", playerfastball )
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

void function fixteamswapthing( entity player )
{
	while( true )
	{
                if( IsValid(player) && player.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" )
		fixifteamswap( player )
		WaitFrame()
	}
}

void function executionthing( entity player )
{
	while( true )
	{
                if( IsValid(player) && player.GetModelName() == $"models/titans/buddy/titan_buddy.mdl" )
		randomexecution( player )
		WaitFrame()
	}
}

void function randomexecution( entity player )
{
entity soul = player.GetTitanSoul()
if(IsValid(soul) && player.GetModelName() == $"models/titans/buddy/titan_buddy.mdl")
player.Signal( "OnSyncedMelee" )
int random_exec = 1
                        random_exec = RandomIntRange( 1, 4 )
			if ( random_exec == 1 )
                        {
                        if(IsValid(soul))
                        soul.soul.titanLoadout.titanExecution = "execution_bt_flip"
                        }
			if ( random_exec == 2 )
                        {
                        if(IsValid(soul))
                        soul.soul.titanLoadout.titanExecution = "execution_bt_pilotrip"
                        }
                        if ( random_exec == 3 )
                        {
                        if(IsValid(soul))
                        soul.soul.titanLoadout.titanExecution = "execution_bt_kickshoot"
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

void function fixifteamswap( entity player )
{
if( IsValid(player) && player.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" )
player.SetModel($"models/titans/buddy/titan_buddy.mdl")
player.SetTitle( "BT-7274" )
player.SetSkin(1)
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

bool function playerfastball( entity player, array<string> args )
{
#if SERVER
if( IsValid( player.GetPetTitan() ) )
{
entity titan = player.GetPetTitan()
if( titan.GetModelName() == $"models/titans/buddy/titan_buddy.mdl")
thread distancefastball( player, titan )
}
return true
#endif
}

void function distancefastball( entity player, entity titan )
{
if( IsValid( player ) && Distance( player.GetOrigin(), titan.GetOrigin() ) < 250 )
{
vector angles = player.EyeAngles()
angles.x = 0
titan.SetAngles( angles )
thread PlayAnim( titan, "bt_beacon_fastball_throw_end" )
thread fastballforplayertitan( player, titan )
}
}

void function fastballforplayertitan( entity player, entity titan ) // copyed from _gamemode_fastball_intro.gunt file in northstar.custom
{
    player.EndSignal( "OnDestroy" )
    titan.EndSignal( "OnDestroy" )
    
    if ( IsAlive( player ) )
        //player.Die() // kill player if they're alive so there's no issues with that
        

    player.EndSignal( "OnDeath" )
    titan.EndSignal( "OnDeath" )
        
    OnThreadEnd( function() : ( player )
    {
        if ( IsValid( player ) )
        {
            RemoveCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
            player.ClearParent()
            ClearPlayerAnimViewEntity( player )
            player.DeployWeapon()
            player.PlayerCone_Disable()
            player.ClearInvulnerable()
            player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE // restore visibility
        }
    })
    
    FirstPersonSequenceStruct throwSequence
    throwSequence.attachment = "REF"
    throwSequence.useAnimatedRefAttachment = true
    throwSequence.hideProxy = true
    throwSequence.viewConeFunction = ViewConeFastball // this seemingly does not trigger for some reason
    throwSequence.firstPersonAnim = "ptpov_beacon_fastball_throw_end"
    // mp models seemingly have no 3p animation for this
    //throwSequence.firstPersonBlendOutTime = 0.0
    //throwSequence.teleport = true
    //throwSequence.setInitialTime = Time()
    

    // respawn the player
        //player.SetOrigin( titan.GetOrigin() )
    player.kv.VisibilityFlags = 0 // better than .Hide(), hides weapons and such
    player.SetInvulnerable() // in deadly ground we die without this lol
    player.HolsterWeapon()
    
    // hide hud, fade screen out from black
    //AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
    //ScreenFadeFromBlack( player, 0.5, 0.5 )
    
    // start fp sequence
    thread FirstPersonSequence( throwSequence, player, titan )
    
    // manually do this because i can't get viewconefastball to work
    player.PlayerCone_FromAnim()
    player.PlayerCone_SetMinYaw( -50 )
    player.PlayerCone_SetMaxYaw( 25 )
    player.PlayerCone_SetMinPitch( -15 )
    player.PlayerCone_SetMaxPitch( 15 )
    
    titan.WaitSignal( "fastball_start_throw" )
    // lock in their final angles at this point
    vector throwVel = AnglesToForward( player.EyeAngles() ) * 950
    throwVel.z = 1575.0
    
    // wait for it to finish
    titan.WaitSignal( "fastball_release" )
    
    if ( player.IsInputCommandHeld( IN_JUMP ) )
        throwVel.z = 1750.0
    
    // have to correct this manually here since due to no 3p animation our position isn't set right during this sequence
    player.SetOrigin( titan.GetAttachmentOrigin( titan.LookupAttachment( "FASTBALL_R" ) ) )
    player.SetVelocity( throwVel )
    
    //TryGameModeAnnouncement( player )
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
        if( IsValid(soul))
                              TakePassive( soul, ePassives.PAS_VANGUARD_COREMETER )
                              titan.SetSkin(2)
                              if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_SHIELD ) )
				{
					//soul.soul.titanLoadout.titanExecution = "execution_bt"
					titan.SetSkin(1)
				}
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_DOOM) )
				{
					//soul.soul.titanLoadout.titanExecution = "execution_bt"
					titan.SetSkin(1)
				}
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_REARM) )
				{
					//soul.soul.titanLoadout.titanExecution = "execution_bt"
					titan.SetSkin(0)
				}
/*
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_COREMETER ) )
				{
					TakePassive( soul, ePassives.PAS_VANGUARD_COREMETER )
					//soul.soul.titanLoadout.titanExecution = "execution_bt"
					titan.SetSkin(2)
				}
*/

	#endif
}

void function bop( entity player )
{
	#if SERVER
	if( IsValid(player) && player.GetModelName() == $"models/titans/buddy/titan_buddy.mdl" )
		                player.SetTitle( "BT-7274" )
        thread executionthing( player )
        thread fixteamswapthing( player )
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
                              if( IsValid(soul))
 		              GivePassive( soul, ePassives.PAS_ENHANCED_TITAN_AI )
                              soul.soul.skipDoomState = false
                              GivePassive( soul, ePassives.PAS_AUTO_EJECT )
                              GivePassive( soul, ePassives.PAS_MOBILITY_DASH_CAPACITY )
                              TakePassive( soul, ePassives.PAS_VANGUARD_COREMETER )
                              titan.SetSkin(2)
                              if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_SHIELD ) )
				{
					//soul.soul.titanLoadout.titanExecution = "execution_bt"
					titan.SetSkin(1)
				}
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_DOOM) )
				{
					//soul.soul.titanLoadout.titanExecution = "execution_bt"
					titan.SetSkin(1)
				}
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_REARM) )
				{
					//soul.soul.titanLoadout.titanExecution = "execution_bt"
					titan.SetSkin(0)
				}
/*
				if( SoulHasPassive( soul, ePassives.PAS_VANGUARD_COREMETER ) )
				{
					TakePassive( soul, ePassives.PAS_VANGUARD_COREMETER )
					//soul.soul.titanLoadout.titanExecution = "execution_bt"
					titan.SetSkin(2)
				}
*/ 
                                
				if( TitanEjectIsDisabled() )
					soul.soul.skipDoomState = true
                              }
        }
}
#endif