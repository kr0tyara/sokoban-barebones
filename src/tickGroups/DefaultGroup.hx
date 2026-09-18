package tickGroups;

class DefaultGroup extends TickGroup
{
    public function new()
    {
        super();
    }

    public override function Tick(initial:Bool)
    {
        var objects = Level.grid.GetAllObjects();
        var object = Utils.Find(objects, Level.grid.NeedsToDie);
        while(object != null)
        {
            object.Deactivate();
            object = Utils.Find(objects, Level.grid.NeedsToDie);
        }    
    }
}