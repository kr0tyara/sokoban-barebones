package entities.floors;

import avatars.floors.FragileAvatar;
import history.floors.FragileState;
import history.HistoryState;
import entities.objects.ObjectEntity;
import entities.floors.FloorEntity.FloorType;

class Fragile extends FloorEntity
{
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

    public override function MakeState():HistoryState
    {
        return new FragileState(this, x, y, z, alive);
    }

    public override function ApplyState(state:HistoryState):Bool
    {
        if(!super.ApplyState(state))
            return false;

        var fragileState = cast(state, FragileState);
        alive = fragileState.alive;
        UpdateAvatar();

        return true;
    }
}