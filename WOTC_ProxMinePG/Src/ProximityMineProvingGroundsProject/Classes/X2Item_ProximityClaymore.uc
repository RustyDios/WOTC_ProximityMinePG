//*******************************************************************************************
//  FILE:   X2Item_ProximityClaymore                                   
//  
//	File created by RustyDios	06/09/19	00:45	
//	LAST UPDATED				16/11/20	02:00
//
//	Contains the information for the Proximity Claymore Item
//	Some stuff copied from Claus' Pathfinder Mod
//	Cost code from Iridar		Puma gave help on importing my own images
//
//*******************************************************************************************
class X2Item_ProximityClaymore extends X2Item config(ProxMinePGConfig);

//Grab variables from the config
//some values here overwritten in X2 DLC Info, for 'consistency'
var config WeaponDamageValue dXCOMPROXIMITYCLAYMORE_BASEDAMAGE;

var config int iXCOMPROXIMITYCLAYMORE_RANGE, iXCOMPROXIMITYCLAYMORE_RADIUS, iXCOMPROXIMITYCLAYMORE_AMMO;

var config array<name>	strRESOURCE_COST_TYPE;
var config array<int>	iRESOURCE_COST_AMOUNT;

//add the weapon to the weapon templates
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;

	Weapons.AddItem(Create_XcomProximityCLAYMORE());

	return Weapons;
}

//create the weapon
static function X2DataTemplate Create_XcomProximityCLAYMORE()
{
	local X2WeaponTemplate				Template;
	local ArtifactCost					Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'XcomProximityCLAYMORE');

	//control weapon UI
	Template.strImage = "img:///UILibrary_ProxMinesPGImages.Inv_Proximity_Claymore";
	Template.WeaponPanelImage = "img:///UILibrary_ProxMinesPGImages.Inv_Proximity_Claymore";
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'claymore';
	Template.WeaponTech = 'conventional';
	Template.Tier = 2;
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.EquipSound = "StrategyUI_Grenade_Equip";

	//weapon stats
	Template.iRange = default.iXCOMPROXIMITYCLAYMORE_RANGE;		// 12
	Template.iRadius = default.iXCOMPROXIMITYCLAYMORE_RADIUS;	// 4
	Template.iClipSize = default.iXCOMPROXIMITYCLAYMORE_AMMO;	// 1
	Template.iSoundRange = 5;
	Template.iEnvironmentDamage = 10;
	Template.DamageTypeTemplateName = 'Explosion';
	Template.BaseDamage = default.dXCOMPROXIMITYCLAYMORE_BASEDAMAGE;
		//=(Damage=8, Spread = 1, PlusOne = 1, Crit = 0, Pierce = 0, Shred=1, Tag = "MineDamage", DamageType="Explosion")

	//add these abilities on weapon equip, control the actual usage of the weapon
	Template.Abilities.AddItem('ThrowProximityCLAYMORE');
	Template.Abilities.AddItem('FuseProximityCLAYMORE');
	Template.Abilities.AddItem(class'X2Ability_ProximityClaymores'.default.XcomProximityCLAYMOREDetonationAbilityName);

	//overwritten by X2 DLC Info OPTC
	Template.bOverrideConcealmentRule = true;               //  override the normal behavior for the throw or launch grenade ability
	Template.OverrideConcealmentRule = eConceal_Always;     //  always stay concealed when throwing or launching a proximity mine
	
	//this is all the visual sounds, appearance etc
	Template.GameArchetype = "WP_Proximity_Mine.WP_Proximity_Mine";

	//pretty sure this controls 'throw bounce'
	Template.iPhysicsImpulse = 10;

	//overwritten by X2 DLC Info OPTC
	Template.CanBeBuilt = true;	
	Template.TradingPostValue = 200;
	
	// Requirements
	Template.Requirements.RequiredTechs.AddItem('AutopsyAndromedon');

	// Cost
	for (i = 0; i < default.strRESOURCE_COST_TYPE.Length; i++)
	{
		if (default.iRESOURCE_COST_AMOUNT[i] > 0)
		{
			Resources.ItemTemplateName = default.strRESOURCE_COST_TYPE[i];
			Resources.Quantity = default.iRESOURCE_COST_AMOUNT[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}

	//used for the UI stats display
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , default.iXCOMPROXIMITYCLAYMORE_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , default.iXCOMPROXIMITYCLAYMORE_RADIUS);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ShredLabel, , default.dXCOMPROXIMITYCLAYMORE_BASEDAMAGE.Shred);
	
	return Template;
}

defaultproperties
{
	bShouldCreateDifficultyVariants = true
}
