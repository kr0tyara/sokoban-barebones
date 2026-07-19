package entities.objects;

import avatars.objects.MultiblockAvatar;

class Multiblock extends Block
{
    public var id:Int;
    public var linked:Array<Multiblock> = [];

    public function new(kind:Data.ObjectsKind, id:Int)
    {
        super(kind);
        this.id = id;
        avatarClass = MultiblockAvatar;
    }

    public override function OnTick(initial:Bool)
    {
        if(initial)
            linked = Level.grid.objects.filter(a -> a is Multiblock && cast(a, Multiblock).id == id).map(a -> cast(a, Multiblock));
    }
    
    public override function GetPushGroup():Array<ObjectEntity>
    {
        return linked.map(m -> cast(m, ObjectEntity));
    }
}