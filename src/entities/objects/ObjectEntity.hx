package entities.objects;

import avatars.BaseAvatar;
import avatars.objects.ObjectAvatar;

class ObjectEntity extends BaseEntity
{
    public var kind:Data.ObjectsKind;

    public function new(kind:Data.ObjectsKind)
    {
        super();

        this.kind = kind;

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
}