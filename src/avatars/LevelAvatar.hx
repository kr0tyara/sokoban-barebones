package avatars;

import motion.Actuate;
import entities.BaseEntity;
import entities.objects.*;
import avatars.objects.*;

import entities.floors.*;
import avatars.floors.*;

import h2d.Object;

typedef Focus = {
    x:Float,
    y:Float,
    w:Float,
    h:Float
}

class LevelAvatar extends Object
{
    public static inline var PixelsPerTile:Int = 100;

    private var avatars:Array<BaseAvatar>;
    
    public var objectsContainer:Object;
    public var floorContainer:Object;
    public var extraContainer:Object;

    private var id:Int;
    private var grid:Grid;

    private var focus:Focus;
    private var cameraTransition:Bool = false;

    public function new(id:Int, grid:Grid)
    {
        super();
        
        this.id = id;
        this.grid = grid;

        avatars = new Array<BaseAvatar>();

        floorContainer = new Object();
        addChild(floorContainer);

        objectsContainer = new Object();
        addChild(objectsContainer);

        extraContainer = new Object();
        addChild(extraContainer);

        for(entity in grid.allEntities)
            AddAvatar(entity.avatarClass, entity, true);

        for(avatar in avatars)
            avatar.Initialize();

        Focus(null, false);
        OnResize();
    }

    public function OnResize()
    {
        if(cameraTransition)
            return;

        MoveCamera(this.focus.x * PixelsPerTile, this.focus.y * PixelsPerTile, this.focus.w * PixelsPerTile, this.focus.h * PixelsPerTile);
    }
    private function MoveCamera(x:Float, y:Float, w:Float, h:Float)
    {
        var s = FocusScale({x: x, y: y, w: w, h: h});
        this.scaleX = this.scaleY = s.scale;
        this.x = s.x;
        this.y = s.y;
    }

    public function FocusScale(focus:Focus)
    {
        var x = focus.x;
        var y = focus.y;
        var w = focus.w;
        var h = focus.h;
        
        var scaleX = Main.inst.s2d.width / (w + PixelsPerTile * 2);
        var scaleY = Main.inst.s2d.height / (h + PixelsPerTile * 2);
        
        var scale = Math.min(scaleX, scaleY);
        
        return {
            scale: scale,
            x: (Main.inst.s2d.width - w * scale) / 2 - (x * scale),
            y: (Main.inst.s2d.height - h * scale) / 2 - (y * scale)
        };
    }

    public function Focus(focus:Focus, transition:Bool = false, transitionTime:Float = 1, transitionCallback:()->Void = null)
    {
        var oldFocus = null;
        if(this.focus != null)
            oldFocus = {x: this.focus.x, y: this.focus.y, w: this.focus.w, h: this.focus.h};

        if(focus == null)
            this.focus = {x: 0, y: 0, w: grid.width, h: grid.height + 1};
        else
            this.focus = {x: focus.x, y: focus.y, w: focus.w, h: focus.h};

        Actuate.stop(MoveCamera);
        if(cameraTransition)
            cameraTransition = false;

        if(transition && oldFocus != null)
        {
            cameraTransition = true;

            Actuate.update(MoveCamera, transitionTime,
                [oldFocus.x * PixelsPerTile, oldFocus.y * PixelsPerTile, oldFocus.w * PixelsPerTile, oldFocus.h * PixelsPerTile],
                [this.focus.x * PixelsPerTile, this.focus.y * PixelsPerTile, this.focus.w * PixelsPerTile, this.focus.h * PixelsPerTile]
            ).ease(motion.easing.Quad.easeInOut).onComplete(() -> {
                cameraTransition = false;

                if(transitionCallback != null)
                    transitionCallback();
            });
        }
        else
            OnResize();
    }

    public function AddAvatar(avatarClass:Class<BaseAvatar>, entity:BaseEntity, initial:Bool)
    {
        var avatar = Type.createInstance(avatarClass, [entity]);
        
        if(avatar != null)
        {
            if(!initial)
                avatar.Initialize();
            
            avatars.push(avatar);

            if(entity is ObjectEntity)
                objectsContainer.addChild(avatar);
            else if(entity is FloorEntity)
                floorContainer.addChild(avatar);
        }
    }

    public function RemoveAvatar(avatar:BaseAvatar)
    {
        avatars.remove(avatar);
        avatar.remove();
    }
    
    public function update(dt:Float)
    {
        for(avatar in avatars)
            avatar.update(dt);
        
        objectsContainer.children.sort((a, b) -> Math.round(a.y - b.y));
    }
}