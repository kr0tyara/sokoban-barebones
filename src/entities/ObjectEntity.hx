package entities;

import avatars.BaseAvatar;
import avatars.ObjectAvatar;

@:build(macros.HistoryMaker.load())
class ObjectEntity extends BaseEntity
{
    public var kind:Data.ObjectsKind;
    public var tag:String = '';

    @:history
    public var invisible:Bool = false;
    
    @:history
    public var linked:Array<ObjectEntity> = [];

    public function new(kind:Data.ObjectsKind)
    {
        super();

        this.kind = kind;

        // By default all you will see is a placeholder sprite.
        // That's why you need to implement custom avatar classes! It's not that hard, just override the ObjectAvatar class and set the variable avatarClass of the entity.
        // Use avatars.objects.PlayerAvatar as an example. 
        avatarClass = ObjectAvatar;
    }

    public function Attach(other:ObjectEntity, recur:Bool = false):Void
    {
        var pushGroup = other.GetPushGroup().filter(a -> a != this && !linked.contains(a));
        linked = linked.concat(pushGroup);
        
        if(!recur)
            for(l in pushGroup)
                l.Attach(this, true);
    }

    public function GetPushGroup():Array<ObjectEntity>
    {
        return [this].concat(linked);
    }
    public function CanPush(dirX:Int, dirY:Int, isPlayerMove:Bool):Bool
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