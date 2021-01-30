Scriptname DWCommonsPropagationDelegate extends ActiveMagicEffect  

import DWUtil

Spell Property PropagatorSpell Auto
Spell[] Property WorkingSpells Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
    Debug.Trace("Script propagation: " + NameOf(akCaster) + " -> " + NameOf(akTarget))
    int len = WorkingSpells.Length
    int i = 0
    while i < len
        akTarget.DispelSpell(WorkingSpells[i])
        WorkingSpells[i].Cast(akCaster, akTarget)
        i = i + 1
    endwhile
    PropagatorSpell.Cast(akCaster, akTarget)
EndEvent
