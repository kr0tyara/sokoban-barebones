package entities;

import entities.Entity.EntityType;

class Wall extends Entity
{
    public function new()
    {
        super(EntityType.Wall);
    }
    
    public override function CanPush(dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        return false;
    }
}