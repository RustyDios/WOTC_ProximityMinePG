//*******************************************************************************************
//  FILE:   X2Ability_ProximityClaymores
//  
//	File created by RustyDios	06/09/19	00:45	
//	LAST UPDATED				07/09/19	04:00
//
//	Contains the information for the Proximity Claymore Item
//	Copied and adjusted from the Pathfinders Proximity Stun Mine scripts and base game grenades scripts
//	Many thanks to RoboJumper and Claus for allowing free copy for the project as per the steam d/l page
//
//*******************************************************************************************
class X2Ability_ProximityClaymores extends X2Ability config(ProxMinePGConfig);

var name XcomProximityCLAYMOREDetonationAbilityName;

var config string XcomProximityCLAYMOREExplosion;       //  Particle effect for explosion
var config int iPROXIMITYCLAYMORE_APCOST_COST;
var config bool bPROXIMITYCLAYMORE_APCOST_CONSUME;
var config bool bPROXIMITYCLAYMORE_APCOST_FREEBUTREQUIRESREMAINING;

//add the proximity claymore abilities to the abilities list
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(ThrowProximityCLAYMORE());
	Templates.AddItem(FuseProximityCLAYMORE());
	Templates.AddItem(XcomProximityCLAYMOREDetonation());

	return Templates;
}

//create the throw ability
static function X2AbilityTemplate ThrowProximityCLAYMORE()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;

	local X2Effect_XcomProximityCLAYMORE	XcomProximityCLAYMOREEffect;
	local X2Condition_AbilitySourceWeapon	XcomProximityCLAYMORECondition;	//, GrenadeCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ThrowProximityCLAYMORE');	
	
	//ammo is used as charges
	Template.bDontDisplayInAbilitySummary = true;
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	//action points 
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.iPROXIMITYCLAYMORE_APCOST_COST;			//1
	ActionPointCost.bConsumeAllPoints = default.bPROXIMITYCLAYMORE_APCOST_CONSUME;	//false
	ActionPointCost.bFreeCost = default.bPROXIMITYCLAYMORE_APCOST_FREEBUTREQUIRESREMAINING;	//false
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	//aim, throw, bounce, cursor, targets
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bIndirectFire = true;
	StandardAim.bAllowCrit = false;
	Template.AbilityToHitCalc = StandardAim;
	
	Template.bUseThrownGrenadeEffects = true;
	Template.bHideWeaponDuringFire = true;
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.bUseWeaponRadius = true;
	RadiusMultiTarget.bUseWeaponBlockingCoverFlag = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.FailOnNonUnits = true; //The grenade can affect interactive objects, others
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	//standard shooter exclusions
	Template.AddShooterEffectExclusions();

	Template.bRecordValidTiles = true;

	//add custom non-grenade based proximity mines effect
	XcomProximityCLAYMOREEffect = new class'X2Effect_XcomProximityCLAYMORE';
	XcomProximityCLAYMOREEffect.BuildPersistentEffect(1, true, false, false);
		XcomProximityCLAYMORECondition = new class'X2Condition_AbilitySourceWeapon';
		XcomProximityCLAYMORECondition.MatchWeaponTemplate = 'XcomProximityCLAYMORE';
	XcomProximityCLAYMOREEffect.TargetConditions.AddItem(XcomProximityCLAYMORECondition);
	Template.AddShooterEffect(XcomProximityCLAYMOREEffect);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	//ability UI
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_CannotAfford_AmmoCost');
	Template.IconImage = "img:///UILibrary_ProxMinesPGImages.UIPerk_grenade_proximityclaymore";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_GRENADE_PRIORITY;
	Template.bUseAmmoAsChargesForHUD = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	//visualize the throw
	Template.bShowActivation = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.DamagePreviewFn = ProximityClaymoreDamagePreview;
	Template.TargetingMethod = class'X2TargetingMethod_Grenade';
	Template.CinescriptCameraType = "StandardGrenadeFiring";

	// This action is considered 'neutral' but can be interrupted!
	Template.Hostility = eHostility_Neutral;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.GrenadeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;	
}

//create the ability to use fuse on units carrying a prox claymore... largely untested !!
static function X2AbilityTemplate FuseProximityCLAYMORE()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2AbilityTrigger_EventListener    EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FuseProximityCLAYMORE');
	
	Template.bDontDisplayInAbilitySummary = true;

	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bIndirectFire = true;
	StandardAim.bAllowCrit = false;
	Template.AbilityToHitCalc = StandardAim;
	
	Template.bUseThrownGrenadeEffects = true;
	Template.bHideWeaponDuringFire = true;
	
	Template.AbilityTargetStyle = default.SelfTarget;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.FuseListener;
	EventListener.ListenerData.EventID = class'X2Ability_PsiOperativeAbilitySet'.default.FuseEventName;
	EventListener.ListenerData.Filter = eFilter_None;
	Template.AbilityTriggers.AddItem(EventListener);

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.bAddPrimaryTargetAsMultiTarget = true;
	RadiusMultiTarget.bUseWeaponRadius = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.FailOnNonUnits = false; //The grenade can affect interactive objects, others
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	Template.bRecordValidTiles = true;

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_ProxMinesPGImages.UIPerk_grenade_proximityclaymore";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_GRENADE_PRIORITY;
	Template.bUseAmmoAsChargesForHUD = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.bShowActivation = true;
	Template.bSkipExitCoverWhenFiring = true;
	Template.ActionFireClass = class'X2Action_Fire_IgniteFuse';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = XcomProximityCLAYMOREDetonation_BuildVisualization;
	Template.MergeVisualizationFn = FuseMergeVisualization;
	Template.DamagePreviewFn = ProximityClaymoreDamagePreview;	

	Template.Hostility = eHostility_Offensive;
	
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.GrenadeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;	
}

//create the detonation ability
static function X2AbilityTemplate XcomProximityCLAYMOREDetonation()
{
	local X2AbilityTemplate							Template;
	local X2AbilityToHitCalc_StandardAim			ToHit;
	local X2Condition_UnitProperty					UnitPropertyCondition;
	local X2AbilityTarget_Cursor					CursorTarget;
	local X2AbilityMultiTarget_Radius               RadiusMultiTarget;
	local X2Effect_ApplyWeaponDamage				WeaponDamage;
	local X2Effect_HomingMineDamage					MineDamage;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.XcomProximityCLAYMOREDetonationAbilityName);

	ToHit = new class'X2AbilityToHitCalc_StandardAim';
	ToHit.bIndirectFire = true;
	Template.AbilityToHitCalc = ToHit;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.IncreaseWeaponRange = 2;
	Template.AbilityTargetStyle = CursorTarget;

	//overwritten in X2 DLC Info
	Template.AddShooterEffect(new class'X2Effect_BreakUnitConcealment');

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.bUseWeaponRadius = true;
	RadiusMultiTarget.bAddPrimaryTargetAsMultiTarget = true;
	RadiusMultiTarget.fTargetRadius = 2; //in meters?
	RadiusMultiTarget.AddAbilityBonusRadius('Shrapnel', class'X2Ability_ReaperAbilitySet'.default.HomingShrapnelBonusRadius);//add bonus radius if shooter had shrapnel
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.FailOnNonUnits = false; //The grenade can affect interactive objects, others
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	//	special damage effect handles shrapnel vs regular damage
	MineDamage = new class'X2Effect_HomingMineDamage';
	MineDamage.EnvironmentalDamageAmount = 10;
	Template.AddMultiTargetEffect(MineDamage);

	WeaponDamage = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamage.bExplosiveDamage = true;
	WeaponDamage.bIgnoreBaseDamage = false;
	WeaponDamage.DamageTag = 'MineDamage';
	Template.AddMultiTargetEffect(WeaponDamage);
	
	//  ability is activated by effect detecting movement in range of mine
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');      

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_ProxMinesPGImages.UIPerk_grenade_proximityclaymore";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_GRENADE_PRIORITY;
	Template.bUseAmmoAsChargesForHUD = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.FrameAbilityCameraType = eCameraFraming_Never;

	Template.ActivationSpeech = 'Explosion';
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = XcomProximityCLAYMOREDetonation_BuildVisualization;
	//  cannot interrupt this explosion

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.GrenadeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}

//create the in-game effect of a placed prox mine
function XcomProximityCLAYMOREDetonation_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateContext_Ability		AbilityContext;
	local VisualizationActionMetadata		VisTrack;
	local X2Action_PlayEffect				EffectAction;	
	local X2Action_CameraLookAt				LookAtAction;
	local X2Action_Delay					DelayAction;
	local X2Action_StartStopSound			SoundAction;
	local int ShooterTrackIdx;

	ShooterTrackIdx = INDEX_NONE;
	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	VisTrack.StateObjectRef = AbilityContext.InputContext.SourceObject;

	TypicalAbility_BuildVisualization(VisualizeGameState);
		
	`assert(ShooterTrackIdx != INDEX_NONE);

	//Camera comes first
	LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.CreateVisualizationAction(AbilityContext));
	LookAtAction.LookAtLocation = AbilityContext.InputContext.TargetLocations[0];
	LookAtAction.BlockUntilFinished = true;
	LookAtAction.LookAtDuration = 2.0f;
	
	//Do the visual detonation
	EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(VisTrack, AbilityContext, false));
	EffectAction.EffectName = default.XcomProximityCLAYMOREExplosion;
	EffectAction.EffectLocation = AbilityContext.InputContext.TargetLocations[0];
	EffectAction.EffectRotation = Rotator(vect(0, 0, 1));
	EffectAction.bWaitForCompletion = false;
	EffectAction.bWaitForCameraCompletion = false;

	//Do the Audible Detonation
	SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(VisTrack, AbilityContext, false));
	SoundAction.Sound = new class'SoundCue';
	SoundAction.Sound.AkEventOverride = AkEvent'SoundX2CharacterFX.Proximity_Mine_Explosion';
	SoundAction.Sound.AkEventOverride = AkEvent'SoundMagneticWeapons.Turret_TakeDamage';
	SoundAction.bIsPositional = true;
	SoundAction.vWorldPosition = AbilityContext.InputContext.TargetLocations[0];
	
	//Keep the camera there after things blow up
	DelayAction = X2Action_Delay(class'X2Action_Delay'.static.CreateVisualizationAction(AbilityContext));
	DelayAction.Duration = 0.7;	

}

//create the damage preview, grenade radius etc
function bool ProximityClaymoreDamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	local XComGameState_Item	ItemState;
	local X2WeaponTemplate		WeaponTemplate;
	local XComGameState_Ability DetonationAbility;
	local XComGameState_Unit	SourceUnit;
	local XComGameStateHistory	History;
	local StateObjectReference	AbilityRef;

	ItemState = AbilityState.GetSourceAmmo();
	if (ItemState == none)
		ItemState = AbilityState.GetSourceWeapon();

	if (ItemState == none)
		return false;

	//GrenadeTemplate = X2GrenadeTemplate(ItemState.GetMyTemplate());
	WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
	if (WeaponTemplate == none)
		return false;

	if (WeaponTemplate.DataName != 'XcomProximityCLAYMORE')
		return false;

	History = `XCOMHISTORY;
	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
	AbilityRef = SourceUnit.FindAbility(default.XcomProximityCLAYMOREDetonationAbilityName);
	DetonationAbility = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
	if (DetonationAbility == none)
		return false;

	DetonationAbility.GetDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);
	return true;
}

//set defaults here instead of the config?
DefaultProperties
{
	XcomProximityCLAYMOREDetonationAbilityName = "XcomProximityCLAYMOREDetonation"
}