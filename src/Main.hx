import cherry.tools.ResTools;
import h2d.Font;
import hxd.Res;

typedef GameSave =
{
    lastLevel:Int,
    levels:Array<LevelSave>
}
typedef LevelSave = 
{
    id:Data.LevelsKind,
    steps:Int,
    completed:Bool
}

class Main extends hxd.App 
{
    public static var inst:Main;

    private var inputManager:InputManager;
    private var game:Game;

    public static var save:GameSave;

    // name of the save file, make it unique!
    public static var saveSlot:String = 'sokoban';

    private override function loadAssets(onLoaded:Void->Void)
    {
        ResTools.initPakAuto(onLoaded, (p) -> trace('loading', p));
    }

    private override function init() 
    {
        super.init();
    
        Data.load(Res.data.entry.getText());

        var defaultSave:GameSave = {lastLevel: 0, levels: []};
        for(i in 0...Data.levels.all.length)
        {
            defaultSave.levels.push({id: Data.levels.all[i].id, steps: -1, completed: false});
        }
        save = hxd.Save.load(defaultSave, saveSlot);

        // new levels compatibility
        if(save.levels.length != defaultSave.levels.length)
        {
            for(i in defaultSave.levels)
            {
                if(save.levels.filter(a -> a.id == i.id).length == 0)
                    save.levels.push(i);
            }

            for(i in save.levels)
            {
                if(defaultSave.levels.filter(a -> a.id == i.id).length == 0)
                    save.levels.remove(i);
            }

            if(save.lastLevel >= Data.levels.all.length)
                save.lastLevel = 0;

            hxd.Save.save(save, saveSlot);
        }

        inputManager = new InputManager();

        game = new Game();
        s2d.addChild(game);

        engine.onResized = OnResize;
    }

    private function OnResize()
    {
        game.OnResize();
    }

    private override function update(dt:Float) 
    {
        super.update(dt);

        inputManager.update(dt);
        game.update(dt);
    }

    public static function main()
    {
        inst = new Main();
    }
}
