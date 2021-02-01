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

Scriptname DWUniversalImpulseEffect extends DWPropagatedEffectCleanUpMixin

import DWVectorUtil

float BASE_FORCE = 3.0
float BASE_MAGNITUDE = 192.0
float COOLDOWN = 1.0

GlobalVariable Property DWUniversalImpulseMultiplier Auto


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    Actor target = GetTargetActor()
    if target == None
        return
    endif

    ; Switch to a state where OnHit is an empty handler.
    ; This prevents the handler content from being executed multiple times in a short period of time
    GotoState("RagdollInEffect")

    ; Calculate the relative vector between the aggressor (attacker) and the target (actor being hit)
    float[] vectorSource = Transform(akAggressor)
    float[] vectorTarget = Transform(target)
    float[] direction = RelativeVector(vectorSource, vectorTarget)

    ; Set the motion type of target so that the physics engine is ready to simulate it
    ; target.SetMotionType(target.Motion_Dynamic)

    ; Calculate the final force level using various modifiers
    float force = BASE_FORCE
    if abPowerAttack
        force = force * 2
    endif
    if abBashAttack
        force = force * 1.5
    endif
    if abHitBlocked
        force = force * 0.8
    endif
    force = force * DWUniversalImpulseMultiplier.GetValue() / BASE_MAGNITUDE

    ; if target != PlayerRef
    ;     target.UnequipAll()
    ;     UnequipAccessories(target)
    ; else
    ;     return
    ; endif

    ; Push the target with a force of 0 so that the physics engine will start
    ; simulating their ragdoll
    akAggressor.PushActorAway(target, 0)
    ; Utility.Wait(0.05)

    if target.IsDead()
        force = WeightedForce(target, force, 2.0)
        target.ApplyHavokImpulse(direction[0], direction[1], direction[2], force)
    else
        force = WeightedForce(target, force, 0.1)
        akAggressor.PushActorAway(target, force)
    endif

    Utility.Wait(COOLDOWN)
    GotoState("")
EndEvent


Function UnequipAccessories(Actor target)
    Weapon w = target.GetEquippedWeapon()
    if w != None
        target.UnequipItem(w, False, True)
    endif
    w = target.GetEquippedWeapon(True)
    if w != None
        target.UnequipItem(w, False, True)
    endif
    Armor s = target.GetEquippedShield()
    if s != None
        target.UnequipItem(s, False, True)
    endif
EndFunction


State RagdollInEffect
    Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    EndEvent
EndState


float Function WeightedForce(ObjectReference obj, float baseForce, float mult = 1.0)
    float mass = obj.GetMass()
    if mass == 0
        return baseForce
    endif
    if mass < 1000
        return baseForce * mass * mult
    endif
    ; Refuse to apply a force > 0 for objects with a mass > 1000 since Skyrim
    ; seems to have significant issues ragdolling a very heavy object (such as mammoths and dragons)
    return 0
EndFunction
