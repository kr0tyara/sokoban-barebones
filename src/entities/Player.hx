package entities;

import entities.Entity.EntityType;

class Player extends Entity
{
    public function new()
    {
        super(EntityType.Player);
    }
}