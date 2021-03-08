//*******************************************************************************************
//  FILE:   X2Effect_XcomProximityCLAYMORE
//  
//	File created by RustyDios	06/09/19	00:45	
//	LAST UPDATED				07/09/19	04:45
//
//	Contains the information for the Proximity Claymore Effect
//	Copied (and adjusted) from the Pathfinders Proximity Stun Mine scripts
//	Many thanks to RoboJumper and Claus for allowing their MOD to be copied as per the steam d/l page
//
//*******************************************************************************************
class X2Effect_XcomProximityCLAYMORE extends X2Effect_Persistent config(ProxMinePGConfig);
 
var config string XcomProximityCLAYMOREPersistentParticles;
 
function RegisterForEvents(XComGameState_Effect EffectGameState)
{
    local X2EventManager EventMgr;
    local Object EffectObj;
 
    EventMgr = `XEVENTMGR;
 
    EffectObj = EffectGameState;
    EventMgr.RegisterForEvent(EffectObj, 'ObjectMoved', XcomProximityCLAYMORE_ObjectMoved, ELD_OnStateSubmitted, , , , EffectObj);
    EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', XcomProximityCLAYMORE_AbilityActivated, ELD_OnStateSubmitted, , , , EffectObj);
}
 
simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult)
{
    local XComGameState_Effect		MineEffect, EffectState;
    local X2Action_PlayEffect		EffectAction;
    local X2Action_StartStopSound	SoundAction;
 
    if (EffectApplyResult != 'AA_Success' || ActionMetadata.VisualizeActor == none)
        return;
 
    foreach VisualizeGameState.IterateByClassType(class'XComGameState_Effect', EffectState)
    {
        if (EffectState.GetX2Effect() == self)
        {
            MineEffect = EffectState;
            break;
        }
    }
    `assert(MineEffect != none);
 
    //For multiplayer: don't visualize mines on the enemy team.
    if (MineEffect.GetSourceUnitAtTimeOfApplication().ControllingPlayer.ObjectID != `TACTICALRULES.GetLocalClientPlayerObjectID())
        return;
 
    EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
    EffectAction.EffectName = default.XcomProximityCLAYMOREPersistentParticles;
    EffectAction.EffectLocation = MineEffect.ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
 
    SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
    SoundAction.Sound = new class'SoundCue';
    SoundAction.Sound.AkEventOverride = AkEvent'SoundX2CharacterFX.Item_Proximity_Mine_Active_Ping';
    SoundAction.iAssociatedGameStateObjectId = MineEffect.ObjectID;
    SoundAction.bStartPersistentSound = true;
    SoundAction.bIsPositional = true;
    SoundAction.vWorldPosition = MineEffect.ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
}
 
simulated function AddX2ActionsForVisualization_Sync(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata)
{
    //We assume 'AA_Success', because otherwise the effect wouldn't be here (on load) to get sync'd
    AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');
}
 
simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
    local XComGameState_Effect		MineEffect, EffectState;
    local X2Action_PlayEffect		EffectAction;
    local X2Action_StartStopSound	SoundAction;
 
    if (EffectApplyResult != 'AA_Success' || ActionMetadata.VisualizeActor == none)
        return;
 
    foreach VisualizeGameState.IterateByClassType(class'XComGameState_Effect', EffectState)
    {
        if (EffectState.GetX2Effect() == self)
        {
            MineEffect = EffectState;
            break;
        }
    }
    `assert(MineEffect != none);
 
    //For multiplayer: don't visualize mines on the enemy team.
    if (MineEffect.GetSourceUnitAtTimeOfApplication().ControllingPlayer.ObjectID != `TACTICALRULES.GetLocalClientPlayerObjectID())
        return;
 
    EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
    EffectAction.EffectName = default.XcomProximityCLAYMOREPersistentParticles;
    EffectAction.EffectLocation = MineEffect.ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
    EffectAction.bStopEffect = true;
 
    SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
    SoundAction.Sound = new class'SoundCue';
    SoundAction.Sound.AkEventOverride = AkEvent'SoundX2CharacterFX.Stop_Proximity_Mine_Active_Ping';
    SoundAction.iAssociatedGameStateObjectId = MineEffect.ObjectID;
    SoundAction.bIsPositional = true;
    SoundAction.bStopPersistentSound = true;
}
 
// Copied from XComGameState_Effect to trigger our custom explosion ability
static function EventListenerReturn XcomProximityCLAYMORE_AbilityActivated(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComGameState_Ability         AbilityState;
    local XComGameState_Unit            AbilityUnit, SourceUnit, SourceUnitAtTimeOfLaunch;
    local XComGameStateHistory          History;
    local XComGameStateContext_Ability  AbilityContext;
    local TTile                         CheckTile, AffectedTile;
    local bool                          bLocationMatch;
    local int                           LocationIdx;
    local vector                        TargetLoc;
    local bool                          bAbilityUnitCaughtInDetonation;
   
    local XComGameState_Effect          EffectState;
   
    EffectState = XComGameState_Effect(CallbackData);
   
    if (EffectState.bRemoved)
        return ELR_NoInterrupt;
 
    AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
    //  Proximity mine should not blow up as a pre-emptive strike; only blow up after the ability has successfully executed
    if (AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt)
        return ELR_NoInterrupt;
 
    History = `XCOMHISTORY;
    SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
    AbilityUnit = XComGameState_Unit(EventSource);
    AbilityState = XComGameState_Ability(EventData);
 
    if (SourceUnit != none && AbilityUnit != none && AbilityState != none && AbilityContext != none)
    {
        SourceUnitAtTimeOfLaunch = EffectState.GetSourceUnitAtTimeOfApplication();
 
        if (SourceUnitAtTimeOfLaunch.IsEnemyUnit(AbilityUnit) && AbilityState.IsAbilityInputTriggered() && AbilityState.GetMyTemplate().Hostility == eHostility_Offensive)
        {
            foreach EffectState.ApplyEffectParameters.AbilityResultContext.RelevantEffectTiles(CheckTile)
            {
                if (CheckTile == AbilityUnit.TileLocation)
                {
                    bLocationMatch = true;
                    bAbilityUnitCaughtInDetonation = true; //The unit itself tripped the mine; it must be caught in the explosion
                    break;
                }
            }
            if (!bLocationMatch)
            {
                for (LocationIdx = 0; LocationIdx < AbilityContext.InputContext.TargetLocations.Length; ++LocationIdx)
                {
                    TargetLoc = AbilityContext.InputContext.TargetLocations[LocationIdx];
                    AffectedTile = `XWORLD.GetTileCoordinatesFromPosition(TargetLoc);
                    foreach EffectState.ApplyEffectParameters.AbilityResultContext.RelevantEffectTiles(CheckTile)
                    {
                        if (CheckTile == AffectedTile)
                        {
                            bLocationMatch = true;
                            bAbilityUnitCaughtInDetonation = false;
                            break;
                        }
                    }
                }
            }
            if (bLocationMatch)
            {
                DetonateProximityMine(SourceUnit, bAbilityUnitCaughtInDetonation?AbilityUnit:None, GameState, EffectState);
            }
        }
    }
 
    return ELR_NoInterrupt;
}
 
static function EventListenerReturn XcomProximityCLAYMORE_ObjectMoved(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComGameStateHistory  History;
    local XComGameState_Unit    MovedUnit, SourceUnit, SourceUnitAtTimeOfLaunch;   
    local TTile                 AffectedTile;
    local bool                  bTileMatches;
   
    local XComGameState_Effect          EffectState;
   
    EffectState = XComGameState_Effect(CallbackData);
   
    if (EffectState.bRemoved)
        return ELR_NoInterrupt;
 
    History = `XCOMHISTORY;
    SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
    MovedUnit = XComGameState_Unit(EventData);
    if (MovedUnit != none && SourceUnit != none)
    {
        foreach EffectState.ApplyEffectParameters.AbilityResultContext.RelevantEffectTiles(AffectedTile)
        {
            if (AffectedTile == MovedUnit.TileLocation)
            {
                bTileMatches = true;
                break;
            }
        }
        if (bTileMatches)
        {
            SourceUnitAtTimeOfLaunch = EffectState.GetSourceUnitAtTimeOfApplication();
 
            if (MovedUnit.IsEnemyUnit(SourceUnitAtTimeOfLaunch) && MovedUnit.IsAlive())          //  friendlies will not trigger the proximity mine
            {
                DetonateProximityMine(SourceUnit, MovedUnit, GameState, EffectState);
            }
        }
    }
 
    return ELR_NoInterrupt;
}
 
protected static function DetonateProximityMine(XComGameState_Unit SourceUnit, XComGameState_Unit TriggeringUnit, XComGameState RespondingToGameState, XComGameState_Effect EffectState)
{
    local XComGameState_Ability					AbilityState;
    local AvailableAction						Action;
    local AvailableTarget						Target;
    local XComGameStateContext_EffectRemoved	EffectRemovedState;
    local XComGameState							NewGameState;
    local XComGameStateHistory					History;
    local TTile									AffectedTile;
    local XComGameState_Unit					UnitState;
 
    History = `XCOMHISTORY;
    Action.AbilityObjectRef = SourceUnit.FindAbility(class'X2Ability_ProximityClaymores'.default.XcomProximityCLAYMOREDetonationAbilityName);
    if (Action.AbilityObjectRef.ObjectID != 0)
    {
        AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(Action.AbilityObjectRef.ObjectID));
        if (AbilityState != none)
        {
            //  manually check the unit states being modified by the event as they may not be properly updated in the world data until the event is complete
            foreach RespondingToGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
            {
                foreach EffectState.ApplyEffectParameters.AbilityResultContext.RelevantEffectTiles(AffectedTile)
                {
                    if (UnitState.TileLocation == AffectedTile)
                    {
                        if (Target.AdditionalTargets.Find('ObjectID', UnitState.ObjectID) == INDEX_NONE)
                            Target.AdditionalTargets.AddItem(UnitState.GetReference());
 
                        break;      //  no need to keep checking tiles for this unit
                    }
                }
            }
 
            Action.AvailableCode = 'AA_Success';
            AbilityState.GatherAdditionalAbilityTargetsForLocation(EffectState.ApplyEffectParameters.AbilityInputContext.TargetLocations[0], Target);
 
            //Ensure that the triggering unit is caught in the blast.
            if (TriggeringUnit != None && Target.AdditionalTargets.Find('ObjectID', TriggeringUnit.ObjectID) == INDEX_NONE)
                Target.AdditionalTargets.AddItem(TriggeringUnit.GetReference());
 
            Action.AvailableTargets.AddItem(Target);
 
            if (class'XComGameStateContext_Ability'.static.ActivateAbility(Action, 0, EffectState.ApplyEffectParameters.AbilityInputContext.TargetLocations))
            {
                EffectRemovedState = class'XComGameStateContext_EffectRemoved'.static.CreateEffectRemovedContext(EffectState);
                NewGameState = History.CreateNewGameState(true, EffectRemovedState);
                EffectState.RemoveEffect(NewGameState, RespondingToGameState);
                SubmitNewGameState(NewGameState);
            }
        }
    }
}
 
protected static function SubmitNewGameState(out XComGameState NewGameState)
{
    local X2TacticalGameRuleset		TacticalRules;
    local XComGameStateHistory		History;
 
    if (NewGameState.GetNumGameStateObjects() > 0)
    {
        TacticalRules = `TACTICALRULES;
        TacticalRules.SubmitGameState(NewGameState);
    }
    else
    {
        History = `XCOMHISTORY;
        History.CleanupPendingGameState(NewGameState);
    }
}
 
DefaultProperties
{
    EffectName="XcomProximityCLAYMORE"
    DuplicateResponse = eDupe_Allow;
    bCanBeRedirected = false;
}