package entities;

import entities.floors.FloorEntity;
import entities.objects.ObjectEntity;
import avatars.objects.PlayerAvatar;
import avatars.BaseAvatar;
import haxe.Exception;

@:keepSub
// add this to every class that contains fields with @:history prefix
@:build(macros.HistoryMaker.load())
class BaseEntity
{
    // use this prefix for every variable that can be undone
    @:history
    public var x:Int = 0;
    @:history
    public var y:Int = 0;

    public var dirty:Bool = true;

    public var avatar:BaseAvatar;
    public var avatarClass:Class<BaseAvatar>;

    public var historyFields:Array<String> = [];

    public function new()
    {
    }

    public function OnCreate()
    {
        dirty = true;
        
        if(avatarClass != null && Level.avatar != null)
            Level.avatar.AddAvatar(avatarClass, this, false);
    }
    public function OnDestroy()
    {
        if(avatar != null)
            avatar.OnDestroy();
    }

    public function OnTick(initial:Bool)
    {
        
    }

    public function MakeState()
    {
        var state = {};

        for(field in historyFields)
        {
            var f = Reflect.field(this, field);
            Reflect.setField(state, field, f);
        }

        dirty = false;

        return state;
    }

    public function ApplyState(state:Dynamic)
    {
        var changes = [];

        for(field in Reflect.fields(state))
        {
            if(Reflect.hasField(this, field) && Reflect.field(this, field) != Reflect.field(state, field))
            {
                Reflect.setField(this, field, Reflect.field(state, field));
                changes.push(field);
            }
        }

        if(changes.length > 0)
            OnNewState(changes);
    }

    public function OnNewState(changes:Array<String>)
    {
        if(avatar != null)
        {
            avatar.SetPosition(x, y);
            UpdateAvatar();
        }
    }

    private function UpdateAvatar()
    {
        if(avatar != null)
            avatar.Update();
    }

    public function GetNeighbourObjects():Map<Dir, ObjectEntity>
    {
        var positions = [{x: x - 1, y: y, dir: Dir.Left}, {x: x + 1, y: y, dir: Dir.Right}, {x: x, y: y + 1, dir: Dir.Down}, {x: x, y: y - 1, dir: Dir.Up}];
        var neighbours = new Map<Dir, ObjectEntity>();
        
        for(position in positions)
        {
            var neighbour = Level.grid.GetObject(position.x, position.y);

            if(neighbour != null)
                neighbours.set(position.dir, neighbour);
        }

        return neighbours;
    }
    public function GetNeighbourFloors():Map<Dir, FloorEntity>
    {
        var positions = [{x: x - 1, y: y, dir: Dir.Left}, {x: x + 1, y: y, dir: Dir.Right}, {x: x, y: y + 1, dir: Dir.Down}, {x: x, y: y - 1, dir: Dir.Up}];
        var neighbours = new Map<Dir, FloorEntity>();
        
        for(position in positions)
        {
            var neighbour = Level.grid.GetFloor(position.x, position.y);

            if(neighbour != null)
                neighbours.set(position.dir, neighbour);
        }

        return neighbours;
    }
}