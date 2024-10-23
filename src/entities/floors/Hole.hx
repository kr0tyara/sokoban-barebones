package entities.floors;

import entities.objects.ObjectEntity;
import entities.floors.FloorEntity.FloorType;

class Hole extends FloorEntity
{
    public function new()
    {
        super(FloorType.Hole);
    }

    public override function CanStepOn(by:ObjectEntity):Bool
    {
        return false;
    }
}