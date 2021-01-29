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

Scriptname DWSpawningEffect extends ActiveMagicEffect  

Quest Property DWController Auto
Actor Property PlayerRef Auto

; Add items to spawn using Creation Kit
FormList Property DWSpawnTargets Auto

int SPAWN_COUNT = 10
int SPAWN_DISTANCE = 320
int Z_AXIS_DELTA = 30

float[] Function ProjectionWorldSpaceEulerXZ(float x, float y, float z, float angleX, float angleZ, float distance)
    ; Translate a point `distance` unit away from world space `(x, y, z)` along the Y axis (true north);
    ; then rotate it around the same point for `angleX` degrees on the X axis and `angleZ` degrees on the Z axis.
    ;
    ; Equivalent to the combination of the following Unity operations
    ; Translate(Vector3.forward * distance)
    ; RotateAround(Vector3(x, y, z), Vector3.right, angleX)
    ; RotateAround(Vector3(x, y, z), Vector3.up, angleZ)
    float[] position = new float[3]
    position[0] = x + Math.sin(angleZ) * distance
    position[1] = y + Math.cos(angleZ) * distance
    position[2] = z + Math.sin(angleX) * distance
    return position
EndFunction

float[] Function ProjectionWorldSpaceHeading(float x, float y, float z, float angleZ, float distance)
    return ProjectionWorldSpaceEulerXZ(x, y, z, 0, angleZ, distance) ; No pitch angle (angleX)
EndFunction

float[] Function ProjectionViewportForward(float distance)
    ; Return the world space coordinates `distance` unit away in front of the player.
    ;
    ; Terrains and other bounding boxes are not accounted for.
    float x = PlayerRef.GetPositionX()
    float y = PlayerRef.GetPositionY()
    float z = PlayerRef.GetPositionZ()
    float t = PlayerRef.GetAngleZ()
    return ProjectionWorldSpaceHeading(x, y, z, t, distance)
EndFunction

Function SpawnItemLivePosition(ObjectReference item, float count)
    ; PROBLEM: recalculating the position for each object is very taxing and will delay update events.
    int i = 0
    while i < count
        ; Update target position for the next object using current player position and view angle
        float[] position = ProjectionViewportForward(SPAWN_DISTANCE)
        ; Place the object at player but set it to disabled
        ObjectReference spawned = PlayerRef.PlaceAtMe(item.GetBaseObject(), 1, False, True)
        ; Translate the spawned object away from player
        spawned.SetPosition(position[0], position[1], position[2] + Z_AXIS_DELTA)
        ; Enable the object, allowing it to appear.
        spawned.Enable()
        i = i + 1
    endwhile
EndFunction

ObjectReference Function RandomObjectFromList(FormList list)
    int i = Utility.RandomInt(0, list.GetSize())
    return list.GetAt(i) as ObjectReference
EndFunction

Event OnEffectStart(Actor akTarget, Actor akCaster)
    ; Invoke the spawn function every second.
    RegisterForSingleUpdate(1)
EndEvent

Event OnUpdate()
    ObjectReference item = RandomObjectFromList(DWSpawnTargets)
    SpawnItemLivePosition(item, SPAWN_COUNT)
    RegisterForSingleUpdate(1)
EndEvent
