package history;

import entities.BaseEntity;

// this class is used to store entity information for every player action so it can be undone

// you can define your own HistoryState extensions to store extra data
// just make sure to override MakeState and ApplyState with your custom class
//      (also don't forget to set dirty = true whenever you your change custom variables so they will actually be saved!)

class HistoryState
{
    public var entity:BaseEntity;
    public var x:Int;
    public var y:Int;
    public var z:Int;

    public function new(entity:BaseEntity, x:Int, y:Int, z:Int)
    {
        this.entity = entity;
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function CompareTo(state:HistoryState):Bool
    {
        return entity == state.entity && x == state.x && y == state.y && z == state.z;
    }

    public function Clone():HistoryState
    {
        return new HistoryState(entity, x, y, z);
    }
}
