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

Scriptname DWAutoSpawnEffect extends ActiveMagicEffect  

Quest Property DWController Auto
Actor Property PlayerRef Auto
Form Property DWAutoSpawnTarget Auto

; How much to spawn (base count, will scale with Illusion)
int SPAWN_COUNT = 10

; How far away to spawn the object, in Skyrim unit
int SPAWN_DISTANCE = 240

; Rotation of the spawning position around the player, in degrees clockwise
; 0 means to spawn the objects directly in front of the player
; 90 means to spawn the objects to the right
float HEADING_OFFSET = 0.0

; How high to spawn the objects, in Skyrim unit
; 0 to spawn on the ground (on a flat terrain)
; For reference, a humanoid in Skyrim is approx. 128 units tall (1.828m, 6ft)
; See https://www.creationkit.com/index.php?title=Unit
float HEIGHT_OFFSET = 100.0

; How frequently to spawn the objects, in seconds
float FREQ = 1.0

float pulse = 0.0


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


float[] Function ProjectionViewportForward(float distance, float headingOffset = 0.0)
    ; Return the world space coordinates `distance` unit away in front of the player.
    ;
    ; Terrains and other bounding boxes are not accounted for.
    float x = PlayerRef.GetPositionX()
    float y = PlayerRef.GetPositionY()
    float z = PlayerRef.GetPositionZ()
    float t = PlayerRef.GetAngleZ()
    return ProjectionWorldSpaceHeading(x, y, z, t + headingOffset, distance)
EndFunction


Function SpawnItemLivePosition(Form item, int count)
    ; https://youtu.be/DjSu5UHOj8M?t=461 Line 93
    ObjectReference anchor = PlayerRef.PlaceAtMe(item, 1, False, True)
    float[] position = ProjectionViewportForward(SPAWN_DISTANCE, HEADING_OFFSET)
    anchor.SetPosition(position[0], position[1], position[2] + HEIGHT_OFFSET)
    anchor.PlaceAtMe(item, count, False, False)
    anchor.Delete()
EndFunction


Function Spawn()
    if DWAutoSpawnTarget == None
        return
    endif
    SpawnItemLivePosition(DWAutoSpawnTarget, GetSpawnCount())
EndFunction


int Function GetSpawnCount()
    return (SPAWN_COUNT * self.GetMagnitude()) as int
EndFunction


bool Function pulsed(float frequency)
    float time = GetTimeElapsed()
    if time - pulse >= frequency
        pulse = time
        return True
    endif
    return False
EndFunction


bool Function SelectObject()
    ObjectReference target = Game.GetCurrentCrosshairRef()
    if target == None
        Debug.Notification("No object selected")
        return False
    endif
    DWAutoSpawnTarget = target.GetBaseObject()
    Debug.Notification("Spawning " + DWAutoSpawnTarget.GetName() + " at a rate of " + GetSpawnCount() + " per second")
    return True
EndFunction


Event OnEffectStart(Actor akTarget, Actor akCaster)
    if !SelectObject()
        Dispel()
        return
    endif
    Spawn()
    RegisterForSingleUpdate(0.1)
EndEvent


Event OnUpdate()
    if pulsed(FREQ)
        Spawn()
    endif
    RegisterForSingleUpdate(0.1)
EndEvent
