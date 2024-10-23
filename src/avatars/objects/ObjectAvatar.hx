package avatars.objects;

import h3d.Vector;
import h2d.Graphics;
import entities.objects.ObjectEntity;

class ObjectAvatar extends BaseAvatar
{
    public static inline var animationSpeed:Float = 35;

    private var object:ObjectEntity;
    private var targetPosition:Vector;

    public function new(prototype:ObjectEntity)
    {
        object = cast(prototype, ObjectEntity);
        super(prototype);
    }

    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        var gfx = new Graphics();
        gfx.beginFill(ObjectEntity.GetDebugColor(object.type));
        gfx.drawRect(0, 0, LevelAvatar.PixelsPerTile, LevelAvatar.PixelsPerTile);

        spriteContainer.addChild(gfx);
    }

    private function SnapPosition()
    {
        this.x = targetPosition.x;
        this.y = targetPosition.y;
    }

    public override function SetInitialPosition(x:Int, y:Int, z:Int)
    {
        super.SetInitialPosition(x, y, z);
        targetPosition = new Vector(x * LevelAvatar.PixelsPerTile,  y * LevelAvatar.PixelsPerTile - z * LevelAvatar.PixelsPerTile / 2);
    }

    public override function SetPosition(x:Int, y:Int, z:Int)
    {
        SnapPosition();
        targetPosition = new Vector(x * LevelAvatar.PixelsPerTile,  y * LevelAvatar.PixelsPerTile - z * LevelAvatar.PixelsPerTile / 2);
    }

    public override function update(dt:Float)
    {
        var speed = dt * animationSpeed;
        
        var movement = new Vector();
        movement.lerp(new Vector(this.x, this.y), targetPosition, speed);

        this.x = movement.x;
        this.y = movement.y;
    }
}