package history.floors;

import entities.BaseEntity;

class FragileState extends HistoryState
{
    public var alive:Bool;

    public function new(entity:BaseEntity, x:Int, y:Int, z:Int, alive:Bool)
    {
        super(entity, x, y, z);
        
        this.alive = alive;
    }

    public override function CompareTo(state:HistoryState):Bool
    {
        if(!(state is FragileState))
            return false;
        
        return super.CompareTo(state) && alive == cast(state, FragileState).alive;
    }

    public override function Clone():HistoryState
    {
        return new FragileState(entity, x, y, z, alive);
    }
}