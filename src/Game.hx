import ui.LevelSelect;
import motion.Actuate;
import ui.LevelUI;
import haxe.Exception;
import hxd.Key;

class Game extends h2d.Object
{
    public static var inst:Game;
    public static var nextLevelRequested:Bool = false;

    public static var level:Level;
    public static var ui:LevelUI;
    public static var select:LevelSelect;
    
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

        ui = new LevelUI();
        addChild(ui);

        select = new LevelSelect();
        addChild(select);
        select.visible = false;

        //AudioManager.inst.Play(Sfx.Bgm);

        SetLevel(currentLevel);
        OnResize();
    }

    public function ToggleLevelSelect(visible:Bool)
    {
        select.visible = visible;
        if(visible)
            select.Refresh();
    }

    public function update(dt:Float)
    {
        #if debug
            if(Key.isPressed(Key.N))
                NextLevel(0);
            if(Key.isPressed(Key.B))
                PrevLevel(0);
        #end

        level.update(dt);
    }

    public function OnResize()
    {
        level.OnResize();
        ui.OnResize();
        select.OnResize();
    }

    public function InputBlocked()
    {
        if(nextLevelRequested)
            return true;

        if(select.visible)
            return true;

        return false;
    }

    public function NextLevel(delay:Float = 0)
    {
        LoadLevel(Data.levels.all[Utils.LoopIndex(level.id, 1, Data.levels.all.length)].id, delay);
    }
    public function PrevLevel(delay:Float = 0)
    {
        LoadLevel(Data.levels.all[Utils.LoopIndex(level.id, -1, Data.levels.all.length)].id, delay);
    }
    public function LoadLevel(kind:Data.LevelsKind, delay:Float = 0)
    {
        if(nextLevelRequested)
            return;

        nextLevelRequested = true;
        currentLevel = kind;
        
        Actuate.timer(delay).onComplete(() ->
        {
            SetLevel(currentLevel);
        });
    }

    public function SetLevel(id:Data.LevelsKind)
    {
        ToggleLevelSelect(false);

        if(level != null)
        {
            removeChild(level);
            level = null;
        }
        
        SaveManager.SetLastLevel(id);

        var levelData = Data.levels.get(id);
        if(levelData.className != '')
        {
            var levelClass = Type.resolveClass('levels.${levelData.className}');
            if(levelClass != null)
            {
                var args:Array<Dynamic> = [];
                if(levelData.customArguments.length > 0)
                    args = args.concat(levelData.customArguments.map(a -> a.argument));

                level = Type.createInstance(levelClass, args);
            }
            else
                throw new Exception('No such class: levels.Level_${levelData.className}');
        }
        else
            level = new Level(id);
        
        addChildAt(level, 0);
        level.Init();
        
        ui.Refresh();
        ui.Settings(false);

        nextLevelRequested = false;
    }
}