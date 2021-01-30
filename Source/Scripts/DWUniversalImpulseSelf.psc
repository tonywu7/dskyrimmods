Scriptname DWUniversalImpulseSelf extends ActiveMagicEffect  

Spell Property DWUniversalImpulseSpell Auto

Actor Property PlayerRef Auto
GlobalVariable Property DWUniversalImpulseMultiplier Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
    if akTarget == PlayerRef
        DWUniversalImpulseMultiplier.SetValue(GetMagnitude())   
        DWUniversalImpulseSpell.Cast(akCaster, akTarget) 
    endif
EndEvent