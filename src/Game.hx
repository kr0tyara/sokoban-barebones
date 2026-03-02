import haxe.Exception;
import hxd.Key;

class Game extends h2d.Object
{
    public static var inst:Game;
    public static var nextLevelRequested:Bool = false;

    public static var level:Level;
    public static var history:History;
    private var currentLevel:Data.LevelsKind = SaveManager.save.lastLevel;

    public function new()
    {
        super();

        if(inst != null)
        {
            this.remove();
            return;
        }

        inst = this;
        history = new History();
        SetLevel(currentLevel);
    }

    public function update(dt:Float)
    {
        // debug keys
        if(Key.isPressed(Key.N))
            NextLevel(true);
        if(Key.isPressed(Key.B))
            PrevLevel(true);

        level.update(dt);
    }

    public function OnResize()
    {
        level.OnResize();
    }

    public function InputBlocked()
    {
        if(nextLevelRequested)
            return true;

        return false;
    }

    public function NextLevel(immediate:Bool = false)
    {
        LoadLevel(Data.levels.all[Utils.LoopIndex(level.id, 1, Data.levels.all.length)].id, immediate);
    }
    public function PrevLevel(immediate:Bool = false)
    {
        LoadLevel(Data.levels.all[Utils.LoopIndex(level.id, -1, Data.levels.all.length)].id, immediate);
    }
    public function LoadLevel(kind:Data.LevelsKind, immediate:Bool = false, warpedBack:Bool = false)
    {
        if(nextLevelRequested)
            return;

        nextLevelRequested = true;
        currentLevel = kind;
        
        var timer = new haxe.Timer(immediate ? 0 : 500);
        timer.run = () -> 
        {
            SetLevel(currentLevel);
            timer.stop();
        }
    }

    public function SetLevel(id:Data.LevelsKind)
    {
        if(level != null)
        {
            removeChild(level);
            level = null;
        }
        
        SaveManager.SetLastLevel(id);

        var levelClass = Type.resolveClass('levels.Level_${id}');
        if(levelClass != null)
            level = Type.createInstance(levelClass, []);
        else
            throw new Exception('No such class: levels.Level_${id}');
        
        addChild(level);
        level.Init();

        nextLevelRequested = false;
    }
}