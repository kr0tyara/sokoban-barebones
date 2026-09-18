package entities.floors;

import tickGroups.MoverGroup;
import tickGroups.DefaultGroup;
import Utils.IntVector;

@:build(macros.HistoryMaker.load())
class Mover extends FloorEntity
{
    @:history
    public var direction:IntVector;

    public function new(kind:Data.FloorKind, dir:Int)
    {
        super(kind);
        this.direction = [{x: 0, y: -1}, {x: 0, y: 1}, {x: -1, y: 0}, {x: 1, y: 0}][dir];
        this.followingTickGroups = [DefaultGroup, MoverGroup];
    }
}