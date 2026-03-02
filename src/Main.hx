import gfx.SpriteSheet;
import macros.ResTools;
import h2d.Font;
import hxd.Res;

#if js
import js.Browser;
import js.html.ProgressElement;
#end

class Main extends hxd.App 
{
    public static var inst:Main;

    private var saveManager:SaveManager;
    private var inputManager:InputManager;
    private var game:Game;

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

        saveManager = new SaveManager();
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
