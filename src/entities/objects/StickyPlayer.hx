package entities.objects;

@:build(macros.HistoryMaker.load())
class StickyPlayer extends Player
{
    public function new(kind:Data.ObjectsKind)
    {
        super(kind, true);
    }

    public override function OnPostTick(initial:Bool)
    {
        var neighbours = GetNeighbourObjects();
        
        for(n in neighbours)
            if(!linked.contains(n) && !(n is Player))
                Attach(n);
    }
}