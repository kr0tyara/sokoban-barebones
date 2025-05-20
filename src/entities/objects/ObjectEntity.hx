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

        // By default all you will see is a colored square.
        // That's why you need to implement custom avatar classes! It's not that hard, just override the ObjectAvatar class and set the variable avatarClass of the entity.
        // Use avatars.objects.PlayerAvatar as an example. 
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