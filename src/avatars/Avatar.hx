package avatars;

import h2d.Graphics;
import entities.Entity;
import h2d.Object;

class Avatar extends Object
{
    private var prototype:Entity;
    private var spriteContainer:Object;

    public function new(prototype:Entity)
    {
        super();

        if(prototype != null)
        {
            this.prototype = prototype;
            prototype.avatar = this;
        }

        spriteContainer = new Object();
        addChild(spriteContainer);

        SpawnSprite();
    }

    public function Initialize()
    {
    }

    public function SpawnSprite()
    {
        spriteContainer.removeChildren();

        var gfx = new Graphics();
        gfx.beginFill(Entity.GetDebugColor(prototype.type));
        gfx.drawRect(0, 0, 100, 100);

        spriteContainer.addChild(gfx);
    }
    
    public function Update()
    {
    }

    public function update(dt:Float)
    {
        
    }

    public function OnDestroy()
    {
        Level.avatar.RemoveAvatar(this);
    }

    public function SetInitialPosition(x:Int, y:Int, z:Int)
    {
        this.x = x * LevelAvatar.PixelsPerTile;
        this.y = y * LevelAvatar.PixelsPerTile + z * LevelAvatar.PixelsPerTile / 2;
    }

    public function SetPosition(x:Int, y:Int, z:Int)
    {
        this.x = x * LevelAvatar.PixelsPerTile;
        this.y = y * LevelAvatar.PixelsPerTile + z * LevelAvatar.PixelsPerTile / 2;
    }
}