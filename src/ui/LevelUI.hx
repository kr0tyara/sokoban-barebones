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
    private var next:Button;
    private var status:Text;
    private var completion:Text;

    public function new()
    {
        super();
        
        flow = new Flow();
        flow.x = 25;
        flow.y = Main.inst.s2d.height - 100;
        flow.maxWidth = Main.inst.s2d.width - 50;
        flow.layout = FlowLayout.Horizontal;
        flow.horizontalSpacing = 10;
        flow.fillWidth = true;
        flow.verticalAlign = FlowAlign.Top;
        addChild(flow);

        undo = new Button(75, 75, Main.sheet.Undo.frames[0]);
        flow.addChild(undo);
        undo.onPush = (e:Event) -> Game.history.Undo();

        redo = new Button(75, 75, Main.sheet.Redo.frames[0]);
        flow.addChild(redo);
        redo.onPush = (e:Event) -> Game.history.Redo();

        restart = new Button(75, 75, Main.sheet.Restart.frames[0]);
        flow.addChild(restart);
        restart.onPush = (e:Event) -> Game.history.Restart();

        flow.addSpacing(150 + 10);

        back = new Button(75, 75, Main.sheet.Skip.frames[1]);
        flow.addChild(back);
        back.onPush = (e:Event) -> Game.inst.PrevLevel(true);

        var t = new Interactive(200, 75);
        t.cancelEvents = true;

        status = new Text(Main.font);
        status.text = '0/34';
        status.textAlign = Align.Center;
        status.x = t.width / 2;

        t.addChild(status);

        flow.addChild(t);

        next = new Button(75, 75, Main.sheet.Skip.frames[0]);
        flow.addChild(next);
        next.onPush = (e:Event) -> Game.inst.NextLevel(true);
    }

    public function Refresh()
    {
        undo.cancelEvents = Game.history.currentState <= 0;
        undo.alpha = undo.cancelEvents ? 0.5 : 1;

        redo.cancelEvents = Game.history.undoneCount == 0;
        redo.alpha = redo.cancelEvents ? 0.5 : 1;

        status.text = '${Game.level.id + 1}/${Data.levels.all.length}';
        status.textColor = SaveManager.GetLevelInfo(Game.level.kind).completed ? 0x00FF00 : 0xFFFFFF;
    }

    public function OnResize()
    {
        flow.y = Main.inst.s2d.height - 100;
        flow.maxWidth = Main.inst.s2d.width - 50;
    }
}