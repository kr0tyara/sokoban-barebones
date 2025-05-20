package avatars;

import entities.BaseEntity;
import h2d.Object;

class BaseAvatar extends Object
{
    private var prototype:BaseEntity;
    private var spriteContainer:Object;

    public function new(prototype:BaseEntity)
    {
        super();

        if(prototype != null)
        {
            this.prototype = prototype;
            prototype.avatar = this;
            
            SetInitialPosition(prototype.x, prototype.y, prototype.z);
        }

        spriteContainer = new Object();
        addChild(spriteContainer);

        SpawnSprite();
    }

    public function Initialize()
    {
        Update();
    }

    public function SpawnSprite()
    {
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
        this.y = y * LevelAvatar.PixelsPerTile - z * LevelAvatar.PixelsPerTile / 2;
    }

    public function SetPosition(x:Int, y:Int, z:Int)
    {
        this.x = x * LevelAvatar.PixelsPerTile;
        this.y = y * LevelAvatar.PixelsPerTile - z * LevelAvatar.PixelsPerTile / 2;
    }
}