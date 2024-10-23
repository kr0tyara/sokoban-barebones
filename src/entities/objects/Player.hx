package entities.objects;

import entities.objects.ObjectEntity.ObjectType;

class Player extends ObjectEntity
{
    public function new()
    {
        super(ObjectType.Player);
    }
}