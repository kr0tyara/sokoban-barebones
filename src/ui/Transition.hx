package ui;

import motion.easing.Quad;
import motion.Actuate;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;

class Transition extends Object
{
    private var bg:Bitmap;

    public var onHalfway:()->Void;
    public var onComplete:()->Void;

    public function new()
    {
        super();

        bg = new Bitmap(Tile.fromColor(0x335555));
        addChild(bg);
    }

    private function MoveBackground(y:Float)
    {
        bg.y = y;
    }

    public function Start(delay:Float = 0)
    {
        this.visible = true;
        bg.y = -Main.inst.s2d.height;

        Actuate.update(MoveBackground, .25, [-Main.inst.s2d.height], [0]).onComplete(() ->
        {
            if(onHalfway != null)
                onHalfway();

            Actuate.update(MoveBackground, .25, [0], [Main.inst.s2d.height]).onComplete(() ->
            {
                if(onComplete != null)
                    onComplete();

                this.visible = false;
            }).ease(Quad.easeInOut);
        }).delay(delay).ease(Quad.easeInOut);
    }

    public function OnResize()
    {
        bg.width = Main.inst.s2d.width;
        bg.height = Main.inst.s2d.height;    
    }
}