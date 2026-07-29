package entities.objects;

@:build(macros.HistoryMaker.load())
class StickyPlayer extends Player
{
    @:history
    public var linked:Array<ObjectEntity> = [];

    public function new(kind:Data.ObjectsKind)
    {
        super(kind, true);
    }

    public override function OnTick(initial:Bool)
    {
        var neighbours = GetNeighbourObjects();
        for(n in neighbours)
            if(!linked.contains(n) && !(n is Player))
                linked.push(n);
    }

    public override function GetPushGroup():Array<ObjectEntity>
    {
        var t:Array<ObjectEntity> = [this];
        return t.concat(linked);
    }
}