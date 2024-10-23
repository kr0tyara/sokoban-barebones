package entities.floors;

import entities.objects.ObjectEntity;

enum FloorType
{
    Hole;
    Basic;
    Goal;
}
class FloorEntity extends BaseEntity
{
    public var type:FloorType;
    
    public function new(type:FloorType)
    {
        super();

        this.type = type;
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

    public override function OnCreate()
    {
        dirty = true;

        if(avatar == null && Level.avatar != null)
            Level.avatar.AddFloor(this);
    }

    public static function GetDebugColor(type:FloorType):Int
    {
        switch(type)
        {
            case FloorType.Hole:
                return 0x000000;
            case FloorType.Goal:
                return 0x15FF00;
            default:
                return 0xFFFFFF;
        }
    }
}