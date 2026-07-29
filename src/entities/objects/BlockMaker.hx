package entities.objects;

class BlockMaker extends ObjectEntity
{
    private var direction:Dir = Dir.Left;

    public function new(kind:Data.ObjectsKind)
    {
        super(kind);
    }

    public override function OnTick(initial:Bool)
    {
        if(initial)
            return;

        var dir = Utils.DirToVector(direction);
        var ahead = Level.grid.GetObject(this.x + dir.x, this.y + dir.y);

        if(ahead != null)
        {
            var pushed = Level.grid.Push(ahead, dir.x, dir.y, false);
            if(!pushed)
                return;
        }

        Level.grid.SpawnObjectTile(Data.ObjectsKind.Block, this.x + dir.x, this.y + dir.y);
    }
}