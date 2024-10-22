package history;

import h3d.Quat;
import entities.BaseEntity;
import haxe.ds.Vector;

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
