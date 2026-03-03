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

    private var id:Int;
    private var grid:Grid;

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
        
        var scaleX = Main.inst.s2d.width / (w + PixelsPerTile * 2);
        var scaleY = Main.inst.s2d.height / (h + PixelsPerTile * 2);
        
        var scale = Math.min(scaleX, scaleY);
        
        this.scaleX = scale;
        this.scaleY = scale;

        this.x = (Main.inst.s2d.width - w * scale) / 2;
        this.y = (Main.inst.s2d.height - h * scale) / 2;
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