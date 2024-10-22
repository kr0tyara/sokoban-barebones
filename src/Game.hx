import hxd.Key;
import history.History;

class Game extends h2d.Object
{
    public static var inst:Game;
    public static var nextLevelRequested:Bool = false;

    public static var level:Level;
    public static var history:History;
    private var currentLevel:Int = Main.save.lastLevel;

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
        if(Key.isPressed(Key.R))
        {
            SetLevel(currentLevel);
        }
        
        if(Key.isPressed(Key.N))
        {
            NextLevel(true);
        }
        if(Key.isPressed(Key.B))
        {
            PrevLevel(true);
        }

        level.update(dt);
    }

    public function OnResize()
    {
        level.OnResize();
    }

    public function NextLevel(immediate:Bool = false)
    {
        if(nextLevelRequested)
            return;

        InputManager.inst.inputBlocked = true;
        nextLevelRequested = true;

        currentLevel = Utils.LoopIndex(currentLevel, 1, Data.levels.all.length);
        
        var timer = new haxe.Timer(immediate ? 0 : 500);
        timer.run = () -> 
        {
            SetLevel(currentLevel);
            timer.stop();
        }
    }
    public function PrevLevel(immediate:Bool = false)
    {
        if(nextLevelRequested)
            return;

        InputManager.inst.inputBlocked = true;
        nextLevelRequested = true;

        currentLevel = Utils.LoopIndex(currentLevel, -1, Data.levels.all.length);
        
        var timer = new haxe.Timer(immediate ? 0 : 300);
        timer.run = () -> 
        {
            SetLevel(currentLevel);
            timer.stop();
        }
    }

    public function SetLevel(id:Int)
    {
        if(level != null)
        {
            removeChild(level);
            level = null;
        }
        
        Main.save.lastLevel = id;
        hxd.Save.save(Main.save, Main.saveSlot);

        level = new Level(id);
        addChild(level);

        InputManager.inst.inputBlocked = false;
        nextLevelRequested = false;
    }
}