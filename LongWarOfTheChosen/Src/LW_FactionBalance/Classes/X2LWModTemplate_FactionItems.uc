//---------------------------------------------------------------------------------------
//  FILE:    X2LWModTemplate_FactionItems.uc
//  AUTHOR:  Peter Ledbrook
//  PURPOSE: Modifies existing item templates related to faction soldiers.
//---------------------------------------------------------------------------------------
class X2LWModTemplate_FactionItems extends X2LWTemplateModTemplate config(LW_FactionBalance);

var config array<WeaponDamageValue> WHIPLASH_CONVENTIONAL_DAMAGE;
var config array<WeaponDamageValue> WHIPLASH_MAGNETIC_DAMAGE;
var config array<WeaponDamageValue> WHIPLASH_BEAM_DAMAGE;

static function UpdateItems(X2ItemTemplate Template, int Difficulty)
{
	local X2WeaponTemplate WeaponTemplate;

	WeaponTemplate = X2WeaponTemplate(Template);
	if (WeaponTemplate != none)
	{
		UpdateWeapons(WeaponTemplate, Difficulty);
	}
}

static function UpdateWeapons(X2WeaponTemplate WeaponTemplate, int Difficulty)
{
	switch (WeaponTemplate.DataName)
	{
	case 'Reaper_Claymore':
		WeaponTemplate.iRange = `METERSTOTILES(class'X2Ability_ReaperAbilitySet'.default.ClaymoreRange);
		break;
	case 'VektorRifle_CV':
		// WOTC sets this to 2 for some reason, which is inconsistent with the
		// _MG and _BM variants.
		WeaponTemplate.iTypicalActionCost = 1;
		break;
	case 'ShardGauntlet_BM':
		WeaponTemplate.Abilities.AddItem('SupremeFocus');
	case 'ShardGauntlet_MG':
		WeaponTemplate.Abilities.AddItem('DeepFocus');
	case 'ShardGauntlet_CV':
		WeaponTemplate.Abilities.AddItem('TemplarFleche');
		break;
	case 'Wristblade_CV':
		WeaponTemplate.ExtraDamage = default.WHIPLASH_CONVENTIONAL_DAMAGE;
		break;
	case 'Wristblade_MG':
		WeaponTemplate.ExtraDamage = default.WHIPLASH_MAGNETIC_DAMAGE;
		break;
	case 'Wristblade_BM':
		WeaponTemplate.ExtraDamage = default.WHIPLASH_BEAM_DAMAGE;
		break;
	}
}

defaultproperties
{
	ItemTemplateModFn=UpdateItems
}
