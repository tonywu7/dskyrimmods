Scriptname DWUniversalImpulseTeachModifiers extends ObjectReference

FormList Property DWUniversalImpulseModifierSpellList Auto

Actor Property PlayerRef Auto


Event OnEquipped(Actor akActor)
    int i = 0
    int len = DWUniversalImpulseModifierSpellList.GetSize()
    while i < len
        Spell modifierSpell = DWUniversalImpulseModifierSpellList.GetAt(i) as Spell
        akActor.AddSpell(modifierSpell)
        i += 1
    endwhile
EndEvent