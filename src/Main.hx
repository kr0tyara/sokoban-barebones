import slide.TweenManager;
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
    public static var tm:TweenManager;

    private var saveManager:SaveManager;
    private var audioManager:AudioManager;
    private var inputManager:InputManager;
    private var game:Game;

    public static var sheet:SpriteSheet;
    public static var font:Font;
    public static var fontBig:Font;

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

        font = hxd.Res.fonts.font.toFont().clone();
        font.resizeTo(35);

        fontBig = hxd.Res.fonts.font.toFont().clone();
        fontBig.resizeTo(50);

        saveManager = new SaveManager();
        audioManager = new AudioManager();
        inputManager = new InputManager();

        engine.backgroundColor = 0x787878;
        
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

        tm.update(dt);

        inputManager.update(dt);
        game.update(dt);
    }

    public static function main()
    {
        inst = new Main();
        tm = new TweenManager();
    }
}
