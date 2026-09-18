package ui;

import h2d.filter.Outline;
import motion.easing.Sine;
import motion.Actuate;
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
    private var out:Graphics;
    private var bitmap:Bitmap;
    private var bigText:Bool;
    private var left:Bool;
    public var label:Text;
    public var label2:Text;
    
    private var arrow:Bitmap;

    public var trueClick:(e:hxd.Event)->Void;

    public function new(w:Int, h:Int, icon:Tile = null, txt = '', bigText:Bool = false, left:Bool = false, txt2 = '')
    {
        super(w, h);

        this.bigText = bigText;
        this.left = left;

        out = new Graphics(this);
        out.beginFill(0xFFFF00);
        out.drawRoundedRect(-5, -5, w + 10, h + 10, 20);
        out.endFill();
        out.alpha = 0;

        gfx = new Graphics(this);
        gfx.alpha = .7;
        gfx.beginFill(0x000000);
        gfx.drawRoundedRect(0, 0, w, h, 15);
        gfx.endFill();

        if(icon != null)
        {
            bitmap = new Bitmap(icon);
            bitmap.x = w / 2;
            bitmap.y = h / 2;
            bitmap.scale(!bigText ? .75 : .5);
            addChild(bitmap);

            SetIcon(icon);
            
            if(bigText || left)
            {
                bitmap.x = 30;
                bitmap.y = h / 2;
            }
        }

        if(txt != '')
        {
            label = new Text(bigText ? Main.fontBig : Main.font);
            label.smooth = true;
            label.text = txt;
            label.textAlign = Align.Right;
            label.x = w - 5;
            label.y = h - 50;
            addChild(label);

            if(bigText)
            {
                label.textAlign = Align.Left;
                label.y = h / 2 - 45;
                label.x = 110;
            }
        }

        if(txt2 != '')
        {
            label2 = new Text(bigText ? Main.fontBig : Main.font);
            label2.smooth = true;
            label2.text = txt2;
            label2.textAlign = Align.Center;
            label2.x = w / 2;
            label2.y = h - 5;
            label2.filter = new Outline(2);
            addChild(label2);
        }

        tOver = Over;
        tOut = Out;
        tPush = Push;
        tClick = Click;
    }

    public function SetIcon(icon:Tile)
    {
        if(bitmap == null)
            return;

        icon = icon.clone();
        bitmap.tile = icon;
        icon.setCenterRatio(.5, .5);
        if(label != null && label.text != '')
            icon.setCenterRatio(.5, .55);

        if(bigText || left)
            icon.setCenterRatio(0, .5);
    }

    public function Over(e:Event)
    {
        gfx.alpha = 1;

        if(bitmap != null)
            bitmap.y = height / 2 - 2;
        if(bigText && label != null)
            label.y = height / 2 - 45 - 2;
    }
    public function Out(e:Event)
    {
        gfx.alpha = .7;

        if(bitmap != null)
            bitmap.y = height / 2;
        if(bigText && label != null)
            label.y = height / 2 - 45;
    }
    public function Push(e:Event)
    {
        gfx.alpha = .6;

        if(bitmap != null)
            bitmap.y = height / 2 + 2;
        if(bigText && label != null)
            label.y = height / 2 - 45 + 2;
    }
    public function Click(e:Event)
    {
        if(trueClick != null)
            trueClick(e);
    }

    public function Flash(lock:Bool, delay:Float = 0)
    {
        out.alpha = 0;

        if(label2 != null)
            label2.textColor = lock ? 0xFFFF00 : 0xFFFFFF;
        if(label != null)
            label.textColor = lock ? 0xFFFF00 : 0xFFFFFF;

        if(bitmap != null)
            bitmap.color = lock ? new h3d.Vector4(1, 1, 0, 1) : new h3d.Vector4(1, 1, 1, 1);

        if(lock)
            Actuate.tween(out, 1, {alpha: 1}).delay(delay).ease(Sine.easeOut).reflect().repeat();
        else
            Actuate.stop(out);
    }
}