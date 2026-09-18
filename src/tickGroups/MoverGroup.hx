package tickGroups;

class MoverGroup extends TickGroup
{
    public function new()
    {
        super();    
    }

    public override function Tick(initial:Bool)
    {
        super.Tick(initial);
        if(initial)
            return;

        var objects = Level.grid.GetAllObjects();
        for(object in objects)
        {
            var floor = Level.grid.GetFloor(object.x, object.y);
            if(floor is entities.floors.Mover)
            {
                var mover = cast(floor, entities.floors.Mover);
                Level.grid.Push(object, mover.direction.x, mover.direction.y, false);
            }
        }        
    }
}