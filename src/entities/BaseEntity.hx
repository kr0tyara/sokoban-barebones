package entities;

import avatars.BaseAvatar;
import history.HistoryState;
import haxe.Exception;

class BaseEntity
{
    public static inline var SIDE_BOTTOM = 0;
    public static inline var SIDE_LEFT   = 1;
    public static inline var SIDE_FRONT  = 2;
    public static inline var SIDE_RIGHT  = 3;
    public static inline var SIDE_BACK   = 4;
    public static inline var SIDE_UP     = 5;
    
    public var x:Int = 0;
    public var y:Int = 0;
    public var z:Int = 0;

    public var dirty:Bool = true;

    public var avatar:BaseAvatar;
    
    public function new()
    {
    }

    public function OnCreate()
    {
    }
    public function OnDestroy()
    {
        if(avatar != null)
            avatar.OnDestroy();
    }

    public function MakeState():HistoryState
    {
        return new HistoryState(this, x, y, z);
    }
    public function ApplyState(state:HistoryState)
    {
        if(state.entity != this)
        {
            throw Exception;
            return;
        }

        x = state.x;
        y = state.y;
        z = state.z;

        if(avatar != null)
        {
            avatar.SetPosition(x, y, z);
            avatar.Update();
        }
    }
}