package avatars;

import h3d.col.Bounds;
import entities.*;
import avatars.*;
import h2d.Object;

class LevelAvatar extends Object
{
    public static inline var PixelsPerTile:Int = 100;

    private var avatars:Array<Avatar>;
    
    private var avatarsContainer:Object;

    private var grid:Grid;
    private var bounds:Bounds;

    public function new(grid:Grid)
    {
        super();
        
        this.grid = grid;

        avatars = new Array<Avatar>();

        avatarsContainer = new Object();
        addChild(avatarsContainer);

        for(z in 0...grid.height)
        {
            for(y in 0...grid.length)
            {
                for(x in 0...grid.width)
                {
                    var entity = grid.GetEntity(x, y, z);
                    if(entity != null)
                        AddEntity(entity);
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

    public function AddEntity(entity:Entity)
    {
        var avatar:Avatar;
        
        if(entity is Player)
            avatar = new PlayerAvatar(entity);
        else
            avatar = new Avatar(entity);
        
        if(avatar != null)
        {
            avatar.SetInitialPosition(entity.x, entity.y, entity.z);
            avatarsContainer.addChild(avatar);
            avatars.push(avatar);

            avatar.Initialize();
        }
    }

    public function RemoveAvatar(avatar:Avatar)
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