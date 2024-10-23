package avatars;

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

        for(z in 0...grid.height)
        {
            for(y in 0...grid.length)
            {
                for(x in 0...grid.width)
                {
                    var floor = grid.GetFloor(x, y, z);
                    if(floor != null)
                        AddFloor(floor);
                }
            }
        }

        objectsContainer = new Object();
        addChild(objectsContainer);

        for(z in 0...grid.height)
        {
            for(y in 0...grid.length)
            {
                for(x in 0...grid.width)
                {
                    var object = grid.GetObject(x, y, z);
                    if(object != null)
                        AddObject(object);
                }
            }
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

    public function AddObject(object:ObjectEntity)
    {
        var avatar:ObjectAvatar;

        if(object is Player)
            avatar = new PlayerAvatar(object);
        else
            avatar = new ObjectAvatar(object);
        
        if(avatar != null)
        {
            objectsContainer.addChild(avatar);
            avatars.push(avatar);

            avatar.Initialize();
        }
    }
    public function AddFloor(floor:FloorEntity)
    {
        var avatar:FloorAvatar;
        
        avatar = new FloorAvatar(floor);
        
        if(avatar != null)
        {
            floorContainer.addChild(avatar);
            avatars.push(avatar);

            avatar.Initialize();
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