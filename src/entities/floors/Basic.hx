package entities.floors;

import entities.floors.FloorEntity.FloorType;

class Basic extends FloorEntity
{
    public function new()
    {
        super(FloorType.Basic);
    }
}