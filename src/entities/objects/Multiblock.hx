package entities.objects;

import avatars.objects.MultiblockAvatar;

@:build(macros.HistoryMaker.load())
class Multiblock extends Block
{
    public var id:Int;

    public function new(kind:Data.ObjectsKind, id:Int)
    {
        super(kind);
        this.id = id;
        avatarClass = MultiblockAvatar;
    }

    public override function OnTick(initial:Bool)
    {
        if(initial)
            linked = Level.grid.objects.filter(a -> a is Multiblock && cast(a, Multiblock).id == id);
    }
    
    public override function GetPushGroup():Array<ObjectEntity>
    {
        return linked.map(m -> cast(m, ObjectEntity));
    }
}