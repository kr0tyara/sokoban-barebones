package entities.floors;

import entities.objects.ObjectEntity;

class Hole extends FloorEntity
{
    public function new()
    {
        super(Data.FloorKind.Hole);
    }

    public override function CanStepOn(by:ObjectEntity):Bool
    {
        return false;
    }
}