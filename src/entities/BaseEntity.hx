package entities;

import avatars.objects.PlayerAvatar;
import avatars.BaseAvatar;
import haxe.Exception;

@:keepSub
// add this to every class that contains fields with @:history prefix
@:build(macros.HistoryMaker.load())
class BaseEntity
{
    public static inline var SIDE_BOTTOM = 0;
    public static inline var SIDE_LEFT   = 1;
    public static inline var SIDE_FRONT  = 2;
    public static inline var SIDE_RIGHT  = 3;
    public static inline var SIDE_BACK   = 4;
    public static inline var SIDE_UP     = 5;
    
    // use this prefix for every variable that can be undone
    @:history
    public var x:Int = 0;
    @:history
    public var y:Int = 0;
    @:history
    public var z:Int = 0;

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
            Level.avatar.AddAvatar(avatarClass, this);
    }
    public function OnDestroy()
    {
        if(avatar != null)
            avatar.OnDestroy();
    }

    public function OnTick()
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
            avatar.SetPosition(x, y, z);
            UpdateAvatar();
        }
    }

    private function UpdateAvatar()
    {
        if(avatar != null)
            avatar.Update();
    }
}