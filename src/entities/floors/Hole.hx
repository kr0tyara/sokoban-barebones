package entities.floors;

import entities.ObjectEntity;

class Hole extends FloorEntity
{
    public function new(kind:Data.FloorKind)
    {
        super(kind);
    }

    public override function CanStepOn(by:ObjectEntity):Bool
    {
        return false;
    }
}