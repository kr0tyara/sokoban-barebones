package ui;

import hxd.Event;
import h2d.Graphics;
import h2d.Text;
import h2d.Interactive;
import h2d.Bitmap;
import h2d.Tile;
import AudioManager.Sfx;

class Button extends InteractiveExtender
{
    private var gfx:Graphics;
    private var bitmap:Bitmap;
    public var label:Text;

    public var trueClick:(e:hxd.Event)->Void;

    public function new(w:Int, h:Int, icon:Tile = null, txt = '')
    {
        super(w, h);

        gfx = new Graphics(this);
        gfx.alpha = .7;
        gfx.beginFill(0x000000);
        gfx.drawRoundedRect(0, 0, w, h, 15);
        gfx.endFill();

        if(icon != null)
        {
            bitmap = new Bitmap(icon);
            icon.setCenterRatio(.5, .5);
            if(txt != '')
                icon.setCenterRatio(.5, .55);
            bitmap.x = w / 2;
            bitmap.y = h / 2;
            bitmap.scale(.5);
            addChild(bitmap);
        }

        if(txt != '')
        {
            label = new Text(Main.font);
            label.text = txt;
            label.textAlign = Align.Right;
            label.x = w - 5;
            label.y = h - 50;
            addChild(label);
        }

        tOver = Over;
        tOut = Out;
        tPush = Push;
        tClick = Click;
    }

    public function Over(e:Event)
    {
        gfx.alpha = 1;

        if(bitmap != null)
            bitmap.y = height / 2 - 2;
    }
    public function Out(e:Event)
    {
        gfx.alpha = .7;

        if(bitmap != null)
            bitmap.y = height / 2;
    }
    public function Push(e:Event)
    {
        gfx.alpha = .6;

        if(bitmap != null)
            bitmap.y = height / 2 + 2;
    }
    public function Click(e:Event)
    {
        if(trueClick != null)
            trueClick(e);
    }
}