import gfx.SpriteSheet;
import macros.ResTools;
import h2d.Font;
import hxd.Res;

#if js
import js.Browser;
import js.html.ProgressElement;
#end

typedef GameSave =
{
    lastLevel:Data.LevelsKind,
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
    
    public static var sheet:SpriteSheet;

    private override function loadAssets(onLoaded:Void->Void)
    {
        macros.ResTools.initPakAuto(onLoaded, OnProgress);
    }

    private function OnProgress(p:Float)
    {
        #if js
        var percentage = cast(Browser.document.querySelector('#percentage'), ProgressElement);
        percentage.value = Math.floor(p * 100);
        #end

        trace('loading ${Math.floor(p * 100)}%');
    }

    private override function init() 
    {
        super.init();
        
        #if js
        var preloader = Browser.document.querySelector('#preloader');
        preloader.style.display = 'none';
        #end
    
        Data.load(Res.data.entry.getText());
        sheet = new SpriteSheet();

        var defaultSave:GameSave = {lastLevel: Data.LevelsKind.level00, levels: []};
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

            if(Data.levels.get(save.lastLevel) == null)
                save.lastLevel = Data.LevelsKind.level00;

            hxd.Save.save(save, saveSlot);
        }

        inputManager = new InputManager();

        game = new Game();
        s2d.addChild(game);
    }

    private override function onResize()
    {
        super.onResize();
        
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
