//-----------------------------------------------------------
// Used by the visualizer system to control a Visualization Actor
//-----------------------------------------------------------
class X2Action_LW_PsiPinion extends X2Action_BlazingPinionsStage2 config(IriPsiOverhaul);

var private int TimeDelayIndex;

//Cached info for the unit performing the action
//*************************************
/*
var private CustomAnimParams Params;
var private AnimNotify_FireWeaponVolley FireWeaponNotify;
var private int TimeDelayIndex;

var bool		ProjectileHit;
var XGWeapon	UseWeapon;
var XComWeapon	PreviousWeapon;
var XComUnitPawn FocusUnitPawn;
*/
//*************************************

//	This function fires a projectile between two points
function AddProjectiles(int ProjectileIndex)
{
	local TTile SourceTile;
	local XComWorldData World;
	local vector SourceLocation, ImpactLocation;
	local int ZValue;
	local StateObjectReference	TargetRef;
	local XComGameState_Unit	TargetState;

	World = `XWORLD;

	// Calculate the upper z position for the projectile
	// Move it above the top level of the world a bit with *2
	ZValue = World.WORLD_FloorHeightsPerLevel * World.WORLD_TotalLevels * 2;

	TargetRef = AbilityContext.InputContext.MultiTargets[ProjectileIndex];

	TargetState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID));

	if (TargetState != none)
	{
		//ImpactLocation = AbilityContext.InputContext.TargetLocations[ProjectileIndex];	//	this just returns zero vector??? why is this necessary?
																						//	there is only one Target Location, probably returns zero because of non-zero ProjectileIndex
		//SourceTile = World.GetTileCoordinatesFromPosition(ImpactLocation);

		SourceTile = TargetState.TileLocation;
		ImpactLocation = World.GetPositionFromTileCoordinates(SourceTile);
		SourceTile.Z = ZValue;
		SourceLocation = World.GetPositionFromTileCoordinates(SourceTile);
		
		//ImpactLocation = SourceLocation;
		//ImpactLocation.Z = 0;
		
		//World.GetFloorPositionForTile(SourceTile, ImpactLocation);
		
		//`LOG("SourceLocation: " @ SourceLocation,, 'IRIDAR');
		//`LOG("ImpactLocation: " @ ImpactLocation,, 'IRIDAR');

		AddPsiPinionProjectile(SourceLocation, ImpactLocation, AbilityContext, Unit);

	//		`SHAPEMGR.DrawSphere(SourceLocation, vect(15,15,15), MakeLinearColor(0,0,1,1), true);
	//		`SHAPEMGR.DrawSphere(ImpactLocation, vect(15,15,15), MakeLinearColor(0,0,1,1), true);
	}
}

function AddPsiPinionProjectile(vector SourceLocation, vector TargetLocation, XComGameStateContext_Ability AbilityContext, XGUnit XGUnitVar)
{
	local XComWeapon WeaponEntity;
	local XComUnitPawn UnitPawn;
	local X2UnifiedProjectile NewProjectile;
	local AnimNotify_FireWeaponVolley FireVolleyNotify;
	
	UnitPawn = XGUnitVar.GetPawn();

	//The archetypes for the projectiles come from the weapon entity archetype
	WeaponEntity = XComWeapon(UnitPawn.Weapon);

	if (WeaponEntity != none)
	{
		FireVolleyNotify = new class'AnimNotify_FireWeaponVolley';
		FireVolleyNotify.NumShots = 1;
		FireVolleyNotify.ShotInterval = 0.0f;
		FireVolleyNotify.bCosmeticVolley = true;
		FireVolleyNotify.bCustom = true;
		FireVolleyNotify.CustomID = 6547;

		NewProjectile = class'WorldInfo'.static.GetWorldInfo().Spawn(class'X2UnifiedProjectile', , , , , WeaponEntity.DefaultProjectileTemplate);
		NewProjectile.ConfigureNewProjectileCosmetic(FireVolleyNotify, AbilityContext, , , XGUnitVar.CurrentFireAction, SourceLocation, TargetLocation, true);
		NewProjectile.GotoState('Executing');
	}
}

simulated state Executing
{
Begin:
	PreviousWeapon = XComWeapon(UnitPawn.Weapon);
	UnitPawn.SetCurrentWeapon(XComWeapon(UseWeapon.m_kEntity));

	Unit.CurrentFireAction = self;

	for( TimeDelayIndex = 0; TimeDelayIndex < AbilityContext.InputContext.MultiTargets.Length; ++TimeDelayIndex )
	{
		Sleep(`SYNC_FRAND() * 0.3f * GetDelayModifier());
		AddProjectiles(TimeDelayIndex);
	}

	while (!ProjectileHit)
	{
		Sleep(0.01f);
	}

	UnitPawn.SetCurrentWeapon(PreviousWeapon);

	Sleep(0.5f * GetDelayModifier()); // Sleep to allow destruction to be seenw

	CompleteAction();
}