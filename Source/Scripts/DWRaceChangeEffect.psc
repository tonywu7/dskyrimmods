; MIT License
;
; Copyright (c) 2021 @flugzbf
; Credit of originality: @DougDougFood
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

Scriptname DWRaceChangeEffect extends DWPropagatedEffectCleanUpMixin

FormList Property DWRaceList Auto

float COOLDOWN = 1.0


Race Function SelectRandomRace(FormList list)
    return list.GetAt(Utility.RandomInt(0, list.GetSize() - 1)) as Race
EndFunction


string[] Function ACTOR_VALUE_ATTRS() global
    string[] arr = new string[6]
    arr[0] = "Health"
    arr[1] = "Magicka"
    arr[2] = "Stamina"
    arr[3] = "HealRate"
    arr[4] = "MagickaRate"
    arr[5] = "StaminaRate"
    return arr
EndFunction


float[] Function NewAttributeArray() global
    return new float[6]
EndFunction


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    Actor target = GetTargetActor()
    if target == None
        return
    endif
    if target.IsDead()
        return
    endif

    ; Switch to a state where OnHit is an empty handler.
    ; This prevents the handler content from being executed multiple times in a short period of time
    GotoState("RaceChangeInEffect")

    ChangeRaceMaintainStats(target, SelectRandomRace(DWRaceList))

    Utility.Wait(COOLDOWN)
    GotoState("")
EndEvent


State RaceChangeInEffect
    Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    EndEvent
EndState


float[] Function SaveActorValues(Actor subject, string[] keys)
    float[] values = NewAttributeArray()
    int i = 0
    while i < keys.Length
        values[i] = subject.GetActorValue(keys[i])
        i += 1
    endwhile
    return values
EndFunction


float[] Function SaveActorValuePercentages(Actor subject, string[] keys)
    float[] values = NewAttributeArray()
    int i = 0
    while i < keys.Length
        values[i] = subject.GetActorValuePercentage(keys[i])
        i += 1
    endwhile
    return values
EndFunction


Function RestoreActorValues(Actor raceChanged, string[] keys, float[] values)
    int i = 0
    while i < keys.Length
        string attr = keys[i]
        float val = values[i]
        float current = raceChanged.GetActorValue(attr)
        float diff = val - current
        if diff > 0
            raceChanged.RestoreActorValue(attr, diff)
        else
            raceChanged.DamageActorValue(attr, diff)
        endif
        i += 1
    endwhile
EndFunction


Function RestoreActorValuePercentages(Actor raceChanged, string[] keys, float[] values)
    ; Restore actor values (health, etc.) so that their percentages to their max values
    ; remain constant.
    ; For example, if a Whiterun Guard had 150/300 HP before race change, and was changed
    ; to a Giant which would have 900 HP at max, then set the Giant's HP to 450.
    int i = 0
    while i < keys.Length
        string attr = keys[i]
        float percent = values[i]
        float adjusted = raceChanged.GetActorValueMax(attr) * percent
        float current = raceChanged.GetActorValue(attr)
        float diff = adjusted - current
        if diff > 0
            raceChanged.RestoreActorValue(attr, diff)
        else
            raceChanged.DamageActorValue(attr, diff)
        endif
        i += 1
    endwhile
EndFunction


Faction[] Function SaveActorFactions(Actor subject, int[] ranks)
    Faction[] factions = subject.GetFactions(-128, 127)
    int i = 0
    while i < factions.Length && i < ranks.Length
        ranks[i] = subject.GetFactionRank(factions[i])
        i += 1
    endwhile
    return factions
EndFunction


Function RestoreActorFactions(Actor raceChanged, Faction[] factions, int[] ranks)
    raceChanged.RemoveFromAllFactions()
    int i = 0
    while i < factions.Length && i < ranks.Length
        int r = ranks[i]
        if r >= -1
            Faction f = factions[i]
            raceChanged.AddToFaction(f)
            raceChanged.SetFactionRank(f, r)
        endif
        i += 1
    endwhile
EndFunction


Function ChangeRaceMaintainStats(Actor subject, Race target)
    string[] attrs = ACTOR_VALUE_ATTRS()
    float[] avs = SaveActorValuePercentages(subject, attrs)

    subject.GetCombatState()
    int combatState = subject.GetCombatState()
    Actor combatTarget = subject.GetCombatTarget()

    ; int[] factionRanks = new int[100]
    ; Faction[] factions = SaveActorFactions(subject, factionRanks)

    subject.SetRace(target)

    RestoreActorValuePercentages(subject, attrs, avs)
    ; RestoreActorFactions(subject, factions, factionRanks)

    if subject.IsDead()
        return
    endif

    if combatState > 0 && combatTarget != None
        subject.StartCombat(combatTarget)
    endif

    subject.EvaluatePackage()
EndFunction