package entities.objects;

class Wall extends ObjectEntity
{
    public function new(kind:Data.ObjectsKind)
    {
        super(kind);
    }
    
    public override function CanPush(dirX:Int, dirY:Int):Bool
    {
        return false;
    }
}