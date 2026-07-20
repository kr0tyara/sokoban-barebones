package ui;

import h2d.Tile;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Text;
import h2d.Flow;
import h2d.Object;
import hxd.Event;

class LevelSelect extends Object
{
    private var b:InteractiveExtender;
    private var bg:Bitmap;
    private var flow:Flow;

    private var backButton:Button;

    public function new()
    {
        super();

        b = new InteractiveExtender(Main.inst.s2d.width, Main.inst.s2d.height, this);
        b.cursor = Default;
        b.clickSound = false;
        addChild(b);

        bg = new Bitmap(Tile.fromColor(0x000000, 1, 1, .5));
        addChild(bg);

        flow = new Flow(this);
        flow.layout = FlowLayout.Horizontal;
        flow.horizontalAlign = flow.verticalAlign = FlowAlign.Middle;
        flow.multiline = true;
        flow.verticalSpacing = 25;
        flow.padding = 25;
        flow.paddingTop = 150;
        flow.overflow = FlowOverflow.Scroll;
        
        for(i in Data.levels.all)
        {
            var button = new LevelIcon(i);
            flow.addChild(button);
        }

        backButton = new Button(100, 100, Main.sheet.Close.frames[0]);
        backButton.y = 25;
        backButton.trueClick = (e:Event) -> Game.inst.ToggleLevelSelect(false);
        backButton.ignoreInputBlock = true;
        addChild(backButton);
    }
    
    public function Refresh()
    {
        for(child in flow.children)
            if(child is LevelIcon)
                cast(child, LevelIcon).Refresh();
    }

    public function OnResize()
    {
        b.width  = Main.inst.s2d.width;
        b.height = Main.inst.s2d.height;

        bg.width  = Main.inst.s2d.width;
        bg.height = Main.inst.s2d.height;

        flow.maxWidth  = Main.inst.s2d.width;
        flow.maxHeight = Main.inst.s2d.height;

        backButton.x = Main.inst.s2d.width  - backButton.width - 25;
    }
}