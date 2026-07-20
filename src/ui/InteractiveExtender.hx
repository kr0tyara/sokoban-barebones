package ui;

import h2d.col.Point;
import h3d.Vector;
import AudioManager.Sfx;
import hxd.Event;
import h2d.Interactive;

class InteractiveExtender extends Interactive
{
    public static var All:Array<InteractiveExtender> = [];

    public var tOver:(e:hxd.Event)->Void;
    public var tOut:(e:hxd.Event)->Void;
    public var tPush:(e:hxd.Event)->Void;
    public var tClick:(e:hxd.Event)->Void;

    public var tEnableChange:(enabled:Bool)->Void;

    public var disabled(get, set):Bool;
    private var _disabled:Bool;

    public var clickSound:Bool = true;

    public function new(w:Float, h:Float, ?parent:h2d.Object, ?shape:h2d.col.Collider)
    {
        super(w, h, parent, shape);

        onOver = _over;
        onOut = _out;
        onPush = _push;
        onClick = _click;
    }

    public function IsOver(mouseX:Float, mouseY:Float)
    {
        var parentVisible = this.visible;

        if(parentVisible)
        {
            var parent = this.parent;
            while(parent != null)
            {
                if(!parent.visible)
                {
                    parentVisible = false;
                    break;
                }
                parent = parent.parent;
            }
        }

        var pos = parent.localToGlobal(new Point(x, y));
        return !disabled && parentVisible && (mouseX >= pos.x && mouseX <= pos.x + width && mouseY >= pos.y && mouseY <= pos.y + height);    
    }

    private function set_disabled(value:Bool):Bool
    {
        if(this._disabled != value)
            _out(null);

        this._disabled = value;
        cancelEvents = value;

        if(this.tEnableChange != null)
            this.tEnableChange(value);

        return this._disabled;
    }

	private function get_disabled():Bool
    {
        return this._disabled;
	}

    private function _over(e:Event)
    {
        if(disabled)
            return;

        if(this.tOver != null)
            this.tOver(e);
    }
    private function _out(e:Event)
    {
        if(disabled)
            return;
        
        if(this.tOut != null)
            this.tOut(e);
    }
    private function _push(e:Event)
    {
        if(disabled)
            return;
        
        if(this.tPush != null)
            this.tPush(e);
    }
    private function _click(e:Event)
    {
        _over(e);

        if(clickSound)
            AudioManager.inst.Play(Sfx.Click);

        if(this.tClick != null)
            this.tClick(e);
    }

    private override function onAdd()
    {
        super.onAdd();
        
        if(!All.contains(this))
            All.push(this);
    }
    private override function onRemove()
    {
        super.onRemove();
        
        if(All.contains(this))
            All.remove(this);
    }
}