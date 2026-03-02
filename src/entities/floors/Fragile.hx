package entities.floors;

import avatars.floors.FragileAvatar;
import entities.objects.ObjectEntity;
import entities.floors.FloorEntity.FloorType;

@:build(macros.HistoryMaker.load())
class Fragile extends FloorEntity
{
    @:history
    public var alive:Bool = true;

    public function new()
    {
        super(FloorType.Fragile);
        avatarClass = FragileAvatar;
    }

    public override function CanStepOn(by:ObjectEntity):Bool
    {
        if(!super.CanStepOn(by))
            return false;
        
        return alive;
    }

    public override function OnStepOff(by:ObjectEntity)
    {
        dirty = true;
        alive = false;
        UpdateAvatar();
    }
}