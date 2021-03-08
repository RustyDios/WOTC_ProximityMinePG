//*******************************************************************************************
//  FILE:   X2StrategyElement_ProxMineProvingGroundTech                                    
//  
//	File created by RustyDios	02/09/19	13:42	
//	LAST UPDATED				10/06/20	19:00
//
//	Copied and adapted from Useful Autopsies:Purifier UATechs (Flamethrower)
//		Additional config code and help provided by Iridar via XCOM2 Modding discord
//		and Puma for using my own images.
//
//*******************************************************************************************

class X2StrategyElement_ProxMinePGTech extends X2StrategyElement_DefaultTechs config (ProxMinePGConfig);

//grab values from the config file, in this case the created arrays and boolean
var config bool			bPROXMINE_ISREPEATABLE;
var config array<name>	strRESOURCE_COST_TYPE;
var config array<int>	iRESOURCE_COST_AMOUNT;

// Tell the game to add a new tech item
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;

	Techs.AddItem(CreateProxMineTechTemplate());

	return Techs;
}

// Create the new Tech item
static function X2DataTemplate CreateProxMineTechTemplate()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'ProxMinePGTech');
	Template.PointsToComplete = StafferXDays(1, 6);
	Template.strImage = "img:///UILibrary_ProxMinesPGImages.Tech_ProximityMinesPG2";
	Template.SortingTier = 1;
	
	// A non-repeatable one time build item in the proving grounds
	Template.bProvingGround = true;
	Template.bRepeatable = default.bPROXMINE_ISREPEATABLE;	//false;
	Template.ResearchCompletedFn = GiveItems;

	// Item Rewards Old Prox Mine, New Prox Claymore, (Pathfinder Prox Stun Mine)
	Template.ItemRewards.AddItem('ProximityMine');
	Template.ItemRewards.AddItem('XcomProximityCLAYMORE');
	Template.ItemRewards.AddItem('XcomProximityStunMine');

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('AutopsyAndromedon');

	// Costs	Code forloop taken from Iridar, looks for arrays in the config file and cycles through them adding the costs
	// default costs are 300 Supplies, 1 Elerium Core

	for (i = 0; i < default.strRESOURCE_COST_TYPE.Length; i++)
	{
		if (default.iRESOURCE_COST_AMOUNT[i] > 0)
		{
			Resources.ItemTemplateName = default.strRESOURCE_COST_TYPE[i];
			Resources.Quantity = default.iRESOURCE_COST_AMOUNT[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}
	return Template;
}
