Scriptname DWUtil


string Function NameOf(ObjectReference obj) global
    if obj == None
        return "None"
    endif
    string name = obj.GetName()
    if name == ""
        name = obj.GetBaseObject().GetName()
    endif
    return name
EndFunction
