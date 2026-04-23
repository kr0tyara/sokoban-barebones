package ui;

import h2d.Interactive;
import h2d.Text;
import h2d.Flow;
import h2d.Object;
import hxd.Event;

class LevelUI extends Object
{
    private var flow:Flow;

    private var undo:Button;
    private var redo:Button;
    private var restart:Button;
    private var back:Button;
    
    private var settings:Button;
    private var bgm:Button;
    private var sfx:Button;
    private var next:Button;
    private var next2:Button;

    private var status:Text;

    private var flow2:Flow;

    public function new()
    {
        super();

        this.y = Main.inst.s2d.height - 125;
        
        flow = new Flow();
        flow.x = 25;
        flow.layout = FlowLayout.Horizontal;
        flow.horizontalSpacing = 10;
        addChild(flow);

        restart = new Button(100, 100, Main.sheet.Restart.frames[0], 'R');
        flow.addChild(restart);
        restart.trueClick = (e:Event) -> Game.history.Restart();
        
        undo = new Button(100, 100, Main.sheet.Undo.frames[0], 'Z');
        flow.addChild(undo);
        undo.trueClick = (e:Event) -> Game.history.Undo();

        redo = new Button(100, 100, Main.sheet.Redo.frames[0], 'Y');
        flow.addChild(redo);
        redo.trueClick = (e:Event) -> Game.history.Redo();

        #if debug
            back = new Button(100, 100, Main.sheet.Skip.frames[1], 'B');
            flow.addChild(back);
            back.onPush = (e:Event) -> Game.inst.PrevLevel(true);

            var t = new Interactive(200, 100);
            t.cancelEvents = true;

            status = new Text(Main.fontBig);
            status.text = '0/34';
            status.textAlign = Align.Center;
            status.x = t.width / 2;
            status.y = 10;

            t.addChild(status);

            flow.addChild(t);

            next2 = new Button(100, 100, Main.sheet.Skip.frames[0], 'N');
            flow.addChild(next2);
            next2.onPush = (e:Event) -> Game.inst.NextLevel(true);
        #end
        
        flow2 = new Flow();
        flow2.x = Main.inst.s2d.width - 125;
        flow2.layout = FlowLayout.Vertical;
        flow2.verticalSpacing = 10;
        addChild(flow2);

        next = new Button(100, 100, Main.sheet.Skip.frames[0], 'skip?');
        next.label.visible = false;
        flow2.addChild(next);
        next.trueClick = (e:Event) -> {
            if(!next.label.visible)
                next.label.visible = true;
            else
            {
                next.label.visible = false;
                Game.inst.NextLevel(true);
                Settings(false);
            }
        }
        
        bgm = new Button(100, 100, Main.sheet.Music.frames[0], 'off');
        bgm.label.visible = AudioManager.inst.bgmMuted;
        flow2.addChild(bgm);

        bgm.trueClick = (e:Event) -> {
            AudioManager.inst.Mute(!AudioManager.inst.bgmMuted, true);
            bgm.label.visible = AudioManager.inst.bgmMuted;
        }

        sfx = new Button(100, 100, Main.sheet.Sfx.frames[0], 'off');
        sfx.label.visible = AudioManager.inst.sfxMuted;
        flow2.addChild(sfx);
        sfx.trueClick = (e:Event) -> {
            AudioManager.inst.Mute(!AudioManager.inst.sfxMuted, false);
            sfx.label.visible = AudioManager.inst.sfxMuted;
        }

        settings = new Button(100, 100, Main.sheet.Settings.frames[0]);
        flow2.addChild(settings);
        settings.trueClick = (e:Event) -> {
            Settings(!bgm.visible);

            flow2.y = -(flow2.innerHeight - 100);
        }
        
        Settings(false);
    }

    public function Settings(show:Bool)
    {
        next.visible = show;

        bgm.visible = show;
        sfx.visible = show;
        next.label.visible = false;

        flow2.y = -(flow2.innerHeight - 100);
    }

    public function Refresh()
    {
        var was = undo.cancelEvents;
        undo.cancelEvents = Game.history.currentState <= 0;
        undo.alpha = undo.cancelEvents ? 0.5 : 1;
        if(was != undo.cancelEvents)
            undo.Out(null);

        was = redo.cancelEvents;
        redo.cancelEvents = Game.history.undoneCount == 0;
        redo.visible = !redo.cancelEvents;
        if(was != redo.cancelEvents)
            redo.Out(null);

        if(status != null)
        {
            status.text = '${Game.level.id + 1}/${Data.levels.all.length}';
            status.textColor = SaveManager.GetLevelInfo(Game.level.kind).completed ? 0x00FF00 : 0xFFFFFF;
        }
    }

    public function OnResize()
    {
        var scale = Utils.Clamp(Math.min(Main.inst.s2d.width, Main.inst.s2d.height) / 800, 0.5, 1);

        flow2.x = Main.inst.s2d.width / scale - 125;
        flow2.y = -(flow2.innerHeight - 100);

        this.scaleX = this.scaleY = scale;
        this.y = Main.inst.s2d.height - 125 * scale;
    }
}