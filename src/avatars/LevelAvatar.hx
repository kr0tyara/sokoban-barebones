package avatars;

import entities.BaseEntity;
import entities.objects.*;
import avatars.objects.*;

import entities.floors.*;
import avatars.floors.*;

import h2d.Object;

class LevelAvatar extends Object
{
    public static inline var PixelsPerTile:Int = 100;

    private var avatars:Array<BaseAvatar>;
    
    private var objectsContainer:Object;
    private var floorContainer:Object;

    private var grid:Grid;

    public function new(grid:Grid)
    {
        super();
        
        this.grid = grid;

        avatars = new Array<BaseAvatar>();

        floorContainer = new Object();
        addChild(floorContainer);

        objectsContainer = new Object();
        addChild(objectsContainer);

        for(entity in grid.allEntities)
        {
            AddAvatar(entity.avatarClass, entity);
        }

        OnResize();
    }

    public function OnResize()
    {
        var w = grid.width * PixelsPerTile;
        var h = grid.length * PixelsPerTile;

        var scaleX = Main.inst.s2d.width  / w;
        var scaleY = Main.inst.s2d.height / h;
        
        var scale = Math.min(scaleX, scaleY);
        
        Main.inst.s2d.camera.scaleX = scale;
        Main.inst.s2d.camera.scaleY = scale;

        Main.inst.s2d.camera.x = (w - Main.inst.s2d.width / scale) / 2;
        Main.inst.s2d.camera.y = (h - Main.inst.s2d.height / scale) / 2;
    }

    public function AddAvatar(avatarClass:Class<BaseAvatar>, entity:BaseEntity)
    {
        var avatar = Type.createInstance(avatarClass, [entity]);
        
        if(avatar != null)
        {
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
    }
}