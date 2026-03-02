package entities.objects;

class Wall extends ObjectEntity
{
    public function new()
    {
        super(Data.ObjectsKind.Wall);
    }
    
    public override function CanPush(dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        return false;
    }
}