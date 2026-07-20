package entities.objects;

import avatars.BaseAvatar;
import avatars.objects.ObjectAvatar;

@:build(macros.HistoryMaker.load())
class ObjectEntity extends BaseEntity
{
    public var kind:Data.ObjectsKind;
    public var tag:String = '';

    @:history
    public var invisible:Bool = false;

    public function new(kind:Data.ObjectsKind)
    {
        super();

        this.kind = kind;

        // By default all you will see is a placeholder sprite.
        // That's why you need to implement custom avatar classes! It's not that hard, just override the ObjectAvatar class and set the variable avatarClass of the entity.
        // Use avatars.objects.PlayerAvatar as an example. 
        avatarClass = ObjectAvatar;
    }

    public function GetPushGroup():Array<ObjectEntity>
    {
        return [this];
    }
    public function CanPush(dirX:Int, dirY:Int):Bool
    {
        return true;
    }
    
    public function OnMove(dirX:Int, dirY:Int)
    {
        dirty = true;
        
        if(avatar != null)
            avatar.SetPosition(x, y);
    }

    public function MoveFail(dirX:Int, dirY:Int)
    {
        if(avatar != null)
            cast(avatar, ObjectAvatar).MoveFail(dirX, dirY);
    }
}