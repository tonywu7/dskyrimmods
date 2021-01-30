Scriptname DWUniversalImpulseEffect extends ActiveMagicEffect  

import DWVectorUtil
import DWUtil

float BASE_FORCE = 20.0
float BASE_MAGNITUDE = 192.0

GlobalVariable Property DWUniversalImpulseMultiplier Auto


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    Actor target = GetTargetActor()
    if target == None
        return
    endif

    GotoState("RagdollInEffect")

    float[] vectorSource = Transform(akAggressor)
    float[] vectorTarget = Transform(target)
    float[] direction = RelativeVector(vectorSource, vectorTarget)

    target.SetMotionType(target.Motion_SphereIntertia)

    float force = BASE_FORCE
    if abPowerAttack || abBashAttack
        force = force * 2
    endif
    if abHitBlocked
        force = force * 0.8
    endif
    force = force * DWUniversalImpulseMultiplier.GetValue() / BASE_MAGNITUDE

    if !target.IsDead()
        akAggressor.PushActorAway(target, force)
    else
        akAggressor.PushActorAway(target, 0)
        Utility.Wait(0.05)
        target.ApplyHavokImpulse(direction[0], direction[1], direction[2], AdjustedForce(target, force))
    endif

    Utility.Wait(1)
    GotoState("")
EndEvent


State RagdollInEffect
    Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    EndEvent
EndState


float Function AdjustedForce(ObjectReference obj, float baseForce)
    float mass = obj.GetMass()
    if mass == 0
        return baseForce
    endif
    if mass < 1000
        return baseForce * mass * 0.5
    endif
    return 0
EndFunction