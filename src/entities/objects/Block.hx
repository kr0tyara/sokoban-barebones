package entities.objects;

import entities.objects.ObjectEntity.ObjectType;

class Block extends ObjectEntity
{
    public function new()
    {
        super(ObjectType.Block);
    }
}