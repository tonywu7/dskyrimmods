; MIT License
;
; Copyright (c) 2021 @tonyzbf
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

Scriptname DWCommonsPropagationDelegate extends ActiveMagicEffect

Actor Property PlayerRef Auto
GlobalVariable Property DWPropagatedEffectTerminate Auto

Spell Property PropagatorSpell Auto
Spell[] Property WorkingSpells Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
    if akTarget == PlayerRef && akCaster != PlayerRef
        return
    endif
    if DWPropagatedEffectTerminate.GetValue() == 0.0
        Apply(akTarget, akCaster)
    else
        ; If the main effect has been dispelled on the player,
        ; help dispel it from other NPCs
        Cancel(akTarget, akCaster)
    endif
EndEvent


Function Cancel(Actor akTarget, Actor akCaster)
    int len = WorkingSpells.Length
    int i = 0
    while i < len
        Spell s = WorkingSpells[i]
        akTarget.DispelSpell(s)
        i += 1
    endwhile
    akTarget.DispelSpell(PropagatorSpell)
    akCaster.DispelSpell(PropagatorSpell)
EndFunction


Function Apply(Actor akTarget, Actor akCaster)
    int len = WorkingSpells.Length
    int i = 0
    while i < len
        Spell s = WorkingSpells[i]
        akTarget.DispelSpell(s)
        Utility.Wait(0.1)
        s.Cast(akTarget, akTarget)
        i += 1
    endwhile
    akTarget.DispelSpell(PropagatorSpell)
    PropagatorSpell.Cast(akTarget, akTarget)
EndFunction