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

Scriptname DWPropagatedEffectCleanUpMixin extends ActiveMagicEffect

Actor Property PlayerRef Auto
GlobalVariable Property DWPropagatedEffectTerminate Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
    ; Check every 6 in-game hours to see if the effect has been dispelled
    ; on the player
    akTarget.RegisterForUpdateGameTime(6)
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
    ; If the effect is dispelled on the player through any means
    ; set the global variable so that effects on NPCs will dispel as well.
    if akTarget == PlayerRef
        DWPropagatedEffectTerminate.SetValue(1.0)
    endif
EndEvent


Event OnUpdateGameTime()
    if DWPropagatedEffectTerminate.GetValue() == 1.0
        Dispel()
    endif
EndEvent