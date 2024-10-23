package entities.floors;

import entities.floors.FloorEntity.FloorType;

class Goal extends FloorEntity
{
    public function new()
    {
        super(FloorType.Goal);
    }
}