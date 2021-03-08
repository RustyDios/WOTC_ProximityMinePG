//*******************************************************************************************
//  FILE:   XComDownloadableContentInfo_ProximityMineProvingGroundsProject.uc                                    
//  
//	File created by RustyDios	06/09/19	01:30	
//	LAST UPDATED				16/11/20	01:30
//
//	OVERHAULED PROXIMITY MINES, GAVE THEM A PROVING GROUNDS PROJECT
//		HELP RECIEVED FROM Iridar TO GET IT WORKING CORRECTLY IN GAME
//
//*******************************************************************************************

class X2DownloadableContentInfo_ProximityMineProvingGroundsProject extends X2DownloadableContentInfo config (ProxMinePGConfig);

// Grab variables from the config file
var config bool bPROXMINE_RETAINS_CONCEALMENT_ON_EXPLOSION;	//true
var config bool bPROXMINE_RETAINS_CONCEALMENT_ON_THROW;		//true
var config bool bPROXMINE_THROW_DOESNOTATTRACT_LOST;		//true
var config bool bPROXMINE_EXPLOSION_DOESNOTATTRACT_LOST;	//false

var config bool bPROXIMITYMINE_INFINITE;					//false
var config bool bPROXIMITYMINE_CANBEBUILT;					//false
var config bool bPROXIMITYMINE_ONETIME;						//true
var config bool bPROXIMITYMINE_STARTINGITEM;				//false
var config int	iTRADINGPOST_VALUE_XCOMPROXIMITYMINE;		//100

var config bool bPROXIMITYCLAYMORE_INFINITE;				//false
var config bool bPROXIMITYCLAYMORE_CANBEBUILT;				//false
var config bool bPROXIMITYCLAYMORE_ONETIME;					//true
var config bool bPROXIMITYCLAYMORE_STARTINGITEM;			//false
var config int	iTRADINGPOST_VALUE_XCOMPROXIMITYCLAYMORE;	//100

//these variables are just here to try and keep everything in one place
//these affect the (seperate) MOD; Pathfinders Proximity Stun Mines
var config bool bPROXIMITYSTUNMINE_INFINITE;				//false
var config bool bPROXIMITYSTUNMINE_CANBEBUILT;				//false
var config bool bPROXIMITYSTUNMINE_ONETIME;					//true
var config bool bPROXIMITYSTUNMINE_STARTINGITEM;			//false
var config int	iTRADINGPOST_VALUE_XCOMPROXIMITYSTUNMINE;	//100

/// Called on first time load game if not already installed, adds the tech for Proximity Mines to the proving grounds
static event OnLoadedSavedGame()
{
	AddTechGameStates();
}

static event OnLoadedSavedGameToStrategy()
{
	AddTechGameStates();
}

/// Called on new campaign while this DLC / Mod is installed
static event InstallNewCampaign(XComGameState StartState){}		//empty_func

//*******************************************************************************************
// ADD/CHANGES AFTER TEMPLATES LOAD ~ OPTC ~
//*******************************************************************************************
static event OnPostTemplatesCreated()
{
	AdjustProximityMines();
	PatchBuildableTier2Grenades();
}

static function AdjustProximityMines()
{
	local X2AbilityTemplateManager		AllAbilities;		//holder for all abilities
	local X2ItemTemplateManager			AllItems;			//holder for all items

	local X2AbilityTemplate				CurrentDetonationAbility;		//current thing to focus on
	local X2AbilityTemplate				CurrentThrowAbility;			//current thing to focus on

	local X2GrenadeTemplate				CurrentGrenade;		//current thing to focus on
	local X2WeaponTemplate				CurrentWeapon;		//current thing to focus on

	//Grab the distinct template managers(lists) to search through
	AllAbilities     = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AllItems         = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	//////////////////////////////////////////////////////////////////////////////////////////
	// PROX MINE:		NO LONGER BREAKS CONCEALMENT
	//	NOW A UNIQUE SINGULAR ITEM (LIKE FROSTBOMB) 
	//	CUSTOM PROVING GROUND PROJECT CREATED TO GRANT ITEM ON ANDROMEDON AUTOPSY
	//	CONFIG FILE AVAILABLE FOR COSTS OF PROVING GROUND PROJECT
	//////////////////////////////////////////////////////////////////////////////////////////
	
	CurrentDetonationAbility = AllAbilities.FindAbilityTemplate('ProximityMineDetonation');
	CurrentThrowAbility = AllAbilities.FindAbilityTemplate('ThrowProximityMine');
	CurrentGrenade = X2GrenadeTemplate(AllItems.FindItemTemplate('ProximityMine'));

	if (CurrentDetonationAbility !=none)
	{
		if (default.bPROXMINE_RETAINS_CONCEALMENT_ON_EXPLOSION) //true
		{
			CurrentDetonationAbility.ConcealmentRule = eConceal_Always;
			CurrentDetonationAbility.AbilityShooterEffects.Length = 0;
		}

		if (default.bPROXMINE_EXPLOSION_DOESNOTATTRACT_LOST) //true
		{
			CurrentDetonationAbility.LostSpawnIncreasePerUse = 0;
		}
	}

	if (CurrentThrowAbility != none)
	{
		if (default.bPROXMINE_THROW_DOESNOTATTRACT_LOST) //true
		{
			CurrentThrowAbility.LostSpawnIncreasePerUse = 0;
		}
	}

	if (CurrentGrenade != none)
	{
		if (default.bPROXMINE_RETAINS_CONCEALMENT_ON_THROW) //true
		{
			CurrentGrenade.bOverrideConcealmentRule = true;
			CurrentGrenade.OverrideConcealmentRule = eConceal_Always;
		}

		CurrentGrenade.bInfiniteItem = default.bPROXIMITYMINE_INFINITE; //false
		CurrentGrenade.CanBeBuilt = default.bPROXIMITYMINE_CANBEBUILT; //false
		CurrentGrenade.bOneTimeBuild = default.bPROXIMITYMINE_ONETIME; //true
		CurrentGrenade.StartingItem = default.bPROXIMITYMINE_STARTINGITEM; //false
		CurrentGrenade.TradingPostValue = default.iTRADINGPOST_VALUE_XCOMPROXIMITYMINE; //200
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	// PROX CLAYMORE:		NO LONGER BREAKS CONCEALMENT
	//	NOW A UNIQUE SINGULAR ITEM (LIKE FROSTBOMB) 
	//	CUSTOM PROVING GROUND PROJECT CREATED TO GRANT ITEM ON ANDROMEDON AUTOPSY
	//	CONFIG FILE AVAILABLE FOR COSTS OF PROVING GROUND PROJECT
	//////////////////////////////////////////////////////////////////////////////////////////
	
	CurrentDetonationAbility = AllAbilities.FindAbilityTemplate('XcomProximityCLAYMOREDetonation');
	CurrentThrowAbility = AllAbilities.FindAbilityTemplate('ThrowProximityCLAYMORE');
	CurrentWeapon = X2WeaponTemplate(AllItems.FindItemTemplate('XcomProximityCLAYMORE'));

	if (CurrentDetonationAbility !=none)
	{
		if (default.bPROXMINE_RETAINS_CONCEALMENT_ON_EXPLOSION) //true
		{
			CurrentDetonationAbility.ConcealmentRule = eConceal_Always;
			CurrentDetonationAbility.AbilityShooterEffects.Length = 0;
		}

		if (default.bPROXMINE_EXPLOSION_DOESNOTATTRACT_LOST) //true
		{
			CurrentDetonationAbility.LostSpawnIncreasePerUse = 0;
		}
	}

	if (CurrentThrowAbility != none)
	{
		if (default.bPROXMINE_THROW_DOESNOTATTRACT_LOST) //true
		{
			CurrentThrowAbility.LostSpawnIncreasePerUse = 0;
		}
	}

	if (CurrentWeapon != none)
	{
		if (default.bPROXMINE_RETAINS_CONCEALMENT_ON_THROW) //true
		{
			CurrentWeapon.bOverrideConcealmentRule = true;
			CurrentWeapon.OverrideConcealmentRule = eConceal_Always;
		}

		CurrentWeapon.bInfiniteItem = default.bPROXIMITYCLAYMORE_INFINITE; //false
		CurrentWeapon.CanBeBuilt = default.bPROXIMITYCLAYMORE_CANBEBUILT; //false
		CurrentWeapon.bOneTimeBuild = default.bPROXIMITYCLAYMORE_ONETIME; //true
		CurrentWeapon.StartingItem = default.bPROXIMITYCLAYMORE_STARTINGITEM; //false
		CurrentWeapon.TradingPostValue = default.iTRADINGPOST_VALUE_XCOMPROXIMITYCLAYMORE; //200
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	// PROX STUN MINE:		NO LONGER BREAKS CONCEALMENT
	//	NOW A UNIQUE SINGULAR ITEM (LIKE FROSTBOMB) 
	//	CUSTOM PROVING GROUND PROJECT CREATED TO GRANT ITEM ON ANDROMEDON AUTOPSY
	//	(( MOD ADDED PROXIMITY MINE FROM PATHFINDERS MODS ))
	//////////////////////////////////////////////////////////////////////////////////////////

	CurrentDetonationAbility = AllAbilities.FindAbilityTemplate('XcomProximityStunMineDetonation');
	CurrentThrowAbility = AllAbilities.FindAbilityTemplate('ThrowProximityStunMine');
	CurrentGrenade = X2GrenadeTemplate(AllItems.FindItemTemplate('XcomProximityStunMine'));

	if (CurrentDetonationAbility !=none)
	{
		if (default.bPROXMINE_RETAINS_CONCEALMENT_ON_EXPLOSION) //true
		{
			CurrentDetonationAbility.ConcealmentRule = eConceal_Always;
			CurrentDetonationAbility.AbilityShooterEffects.Length = 0;
		}

		if (default.bPROXMINE_EXPLOSION_DOESNOTATTRACT_LOST) //true
		{
			CurrentDetonationAbility.LostSpawnIncreasePerUse = 0;
		}
	}

	if (CurrentThrowAbility != none)
	{
		if (default.bPROXMINE_THROW_DOESNOTATTRACT_LOST) //true
		{
			CurrentThrowAbility.LostSpawnIncreasePerUse = 0;
		}
	}

	if (CurrentGrenade != none)
	{
		if (default.bPROXMINE_RETAINS_CONCEALMENT_ON_THROW) //true
		{
			CurrentGrenade.bOverrideConcealmentRule = true;
			CurrentGrenade.OverrideConcealmentRule = eConceal_Always;
		}

		CurrentGrenade.bInfiniteItem = default.bPROXIMITYSTUNMINE_INFINITE; //false
		CurrentGrenade.CanBeBuilt = default.bPROXIMITYSTUNMINE_CANBEBUILT; //false
		CurrentGrenade.bOneTimeBuild = default.bPROXIMITYSTUNMINE_ONETIME; //true
		CurrentGrenade.StartingItem = default.bPROXIMITYSTUNMINE_STARTINGITEM; //false
		CurrentGrenade.TradingPostValue = default.iTRADINGPOST_VALUE_XCOMPROXIMITYSTUNMINE; //200
	}
}

static function PatchBuildableTier2Grenades()
{
    local X2ItemTemplateManager        ItemMgr;
    local array<name>                arrName;
    local array<X2DataTemplate>        arrTemplate;
    local X2GrenadeTemplate            Template;
    local int                        i, j;

    // Access Item Template Manager
    ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
    
    // List Templates by names
    arrName.AddItem('ProximityMineMk2');
    arrName.AddItem('ProximityMineMk3');

    for (i = 0; i < arrName.Length; i++)
    {
        // Reset Templates for all difficulties
        arrTemplate.Length = 0;

        // Access Templates for all difficulties
        ItemMgr.FindDataTemplateAllDifficulties(arrName[i], arrTemplate);
        for (j = 0; j < arrTemplate.Length; j++)
        {
            // Access Template for specific difficulty
            Template = X2GrenadeTemplate(arrTemplate[j]);
            if (Template != none)
            {
                // Hide when Tier 3 becomes available
				Template.bInfiniteItem = default.bPROXIMITYMINE_INFINITE; //false
				Template.CanBeBuilt = default.bPROXIMITYMINE_CANBEBUILT; //false
				Template.bOneTimeBuild = default.bPROXIMITYMINE_ONETIME; //true
            }
        }
    }
}


//////////////////////////////////////////////////////////////////////////////////////////
// ADD TECHS DURING CAMPAIGN LOAD GAME/NEW GAME
//////////////////////////////////////////////////////////////////////////////////////////

static function AddTechGameStates()
{
	local XComGameState NewGameState;

	//Create a pending game state change
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Experimental Chemthrowers");

	AddToHistoryIfMissing('ProxMinePGTech', NewGameState);

	//Commit the state change into the history.
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

// Add tech template if not injected
static function AddToHistoryIfMissing(name ResearchName, XComGameState NewGameState) 
{
	local X2StrategyElementTemplateManager StrategyElementTemplateManager;
	local X2TechTemplate TechTemplate;

	if ( !IsResearchInHistory(ResearchName) )
	{
		StrategyElementTemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
		TechTemplate = X2TechTemplate(StrategyElementTemplateManager.FindStrategyElementTemplate(ResearchName));
		NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}
}

static function bool IsResearchInHistory(name ResearchName)
{
	local XComGameState_Tech TechState;
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Tech', TechState)
	{
		if ( TechState.GetMyTemplateName() == ResearchName )
		{
			return true;
		}
	}
	return false;
}

//*******************************************************************************************
//*******************************************************************************************
