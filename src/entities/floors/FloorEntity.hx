package entities.floors;

import avatars.floors.FloorAvatar;
import entities.objects.ObjectEntity;

class FloorEntity extends BaseEntity
{
    public var kind:Data.FloorKind;
    
    private var steppedOn:ObjectEntity;
    private var steppedOff:ObjectEntity;

    public function new(kind:Data.FloorKind)
    {
        super();

        this.kind = kind;

        // By default all you will see is a colored square.
        // That's why you need to implement custom avatar classes! It's not that hard, just override the FloorAvatar class and set the variable avatarClass of the entity.
        // Use avatars.floors.FragileAvatar as an example.
        avatarClass = FloorAvatar;
    }

    public function CanStepOn(by:ObjectEntity):Bool
    {
        return true;
    }
    
    public function OnStepOn(by:ObjectEntity)
    {
    }
    public function OnStepOff(by:ObjectEntity)
    {
    }

    public function StashStepOn(by:ObjectEntity)
    {
        steppedOn = by;
    }
    public function StashStepOff(by:ObjectEntity)
    {
        steppedOff = by;
    }
    public override function OnTick(initial:Bool)
    {
        if(steppedOn != null)
        {
            OnStepOn(steppedOn);
            steppedOn = null;
            steppedOff = null; // ignore stepped off as something else took its place
        }
        else if(steppedOff != null)
        {
            OnStepOff(steppedOff);
            steppedOff = null;
        }
    }
}