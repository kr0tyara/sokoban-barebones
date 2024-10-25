package entities.objects;

import avatars.BaseAvatar;
import avatars.objects.ObjectAvatar;

enum ObjectType
{
    Player;
    Block;
    Wall;
}
class ObjectEntity extends BaseEntity
{
    public var type:ObjectType;

    public function new(type:ObjectType)
    {
        super();

        this.type = type;
        avatarClass = ObjectAvatar;
    }

    public function CanPush(dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        return true;
    }
    
    public function OnMove(dirX:Int, dirY:Int, dirZ:Int)
    {
        dirty = true;
        
        if(avatar != null)
            avatar.SetPosition(x, y, z);
    }

    public static function GetDebugColor(type:ObjectType):Int
    {
        switch(type)
        {
            case ObjectType.Player:
                return 0xFF0000;
            case ObjectType.Block:
                return 0x0000FF;
            case ObjectType.Wall:
                return 0x666666;
            default:
                return 0xFFFFFF;
        }
    }
}