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

Scriptname DWVectorUtil


float[] Function Transform(ObjectReference obj) global
    ; Return the object's world space position as a float array
    if obj == None
        return None
    endif
    float[] position = new float[3]
    position[0] = obj.GetPositionX()
    position[1] = obj.GetPositionY()
    position[2] = obj.GetPositionZ()
    return position
EndFunction


float[] Function EulerAngles(ObjectReference obj) global
    ; Return the object's world space euler angles in degrees
    if obj == None
        return None
    endif
    float[] rotation = new float[3]
    rotation[0] = obj.GetAngleX()
    rotation[1] = obj.GetAngleY()
    rotation[2] = obj.GetAngleZ()
    return rotation
EndFunction


float[] Function ProjectionWorldSpaceEulerXZ(float[] position, float[] rotation, float distance) global
    ; Translate a point `distance` unit away from world space `(x, y, z)` along the Y axis (true north);
    ; then rotate it around the same point for `angleX` degrees on the X axis and `angleZ` degrees on the Z axis.
    ;
    ; Equivalent to the combination of the following Unity operations
    ; Translate(Vector3.forward * distance)
    ; RotateAround(Vector3(x, y, z), Vector3.right, angleX)
    ; RotateAround(Vector3(x, y, z), Vector3.up, angleZ)
    float[] projected = new float[3]
    float angleZ = rotation[2]
    float angleX = rotation[0]
    projected[0] = position[0] + Math.sin(angleZ) * distance
    projected[1] = position[1] + Math.cos(angleZ) * distance
    projected[2] = position[2] + Math.sin(angleX) * distance
    return projected
EndFunction


float[] Function ProjectionWorldSpaceHeading(float[] position, float[] rotation, float distance) global
    float[] rotation_ = new float[3]
    rotation_[0] = 0
    rotation_[1] = 0
    rotation_[2] = rotation[2]
    return ProjectionWorldSpaceEulerXZ(position, rotation_, distance) ; No pitch angle (angleX)
EndFunction


float[] Function NormalizedVector3(float[] vector3) global
    ; Normalize a 3D vector so that its x, y, and z components are within the range [-1.0, 1.0]
    ; Return a 4-element array containing the normalized vector and the magnitude of the original vector
    float x = vector3[0]
    float y = vector3[1]
    float z = vector3[2]
    float mag = Math.sqrt(Math.pow(x, 2.0) + Math.pow(y, 2.0) + Math.pow(z, 2.0))
    float[] n = new float[4]
    n[0] = x / mag
    n[1] = y / mag
    n[2] = z / mag
    n[3] = mag
    return n
EndFunction


float[] Function RelativeVector(float[] vectorFrom, float[] vectorTo) global
    float[] v = new float[3]
    v[0] = vectorTo[0] - vectorFrom[0]
    v[1] = vectorTo[1] - vectorFrom[1]
    v[2] = vectorTo[2] - vectorFrom[2]
    return v
EndFunction