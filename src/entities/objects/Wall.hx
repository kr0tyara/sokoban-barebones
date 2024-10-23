package entities.objects;

import entities.objects.ObjectEntity.ObjectType;

class Wall extends ObjectEntity
{
    public function new()
    {
        super(ObjectType.Wall);
    }
    
    public override function CanPush(dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        return false;
    }
}