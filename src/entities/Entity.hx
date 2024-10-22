package entities;

import avatars.Avatar;

enum EntityType
{
    Player;
    Block;
    Wall;
}
class Entity extends BaseEntity
{
    public var type:EntityType;

    public var movedThisFrame:Bool = false;
    public var pushedThisFrame:Bool = false;
    
    public function new(type:EntityType)
    {
        super();

        this.type = type;
    }

    public function CanPush(dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        return true;
    }
    public function OnPush(by:Entity, dirX:Int, dirY:Int, dirZ:Int)
    {

    }
    public override function OnCreate()
    {
        dirty = true;

        if(avatar == null && Level.avatar != null)
            Level.avatar.AddEntity(this);
    }
    public function OnMove(dirX:Int, dirY:Int, dirZ:Int)
    {
        dirty = true;
        
        if(avatar != null)
            avatar.SetPosition(x, y, z);
    }

    public static function GetDebugColor(type:EntityType):Int
    {
        switch(type)
        {
            case EntityType.Player:
                return 0xFF0000;
            case EntityType.Block:
                return 0x0000FF;
            case EntityType.Wall:
                return 0x666666;
            default:
                return 0xFFFFFF;
        }
    }
}