package avatars.objects;

import motion.Actuate;
import motion.easing.Linear;
import h2d.Bitmap;
import h3d.Vector;
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

    // If nothing overrides this method, uses the same placeholder tiles as in CastleDB editor
    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        var tile = Main.cdbSheet.objects[object.kind];

        var bitmap = new Bitmap(tile);
        bitmap.x = LevelAvatar.PixelsPerTile / 2;
        bitmap.y = LevelAvatar.PixelsPerTile;
        spriteContainer.addChild(bitmap);
    
        Update();
    }

    private function SnapPosition()
    {
        this.x = targetPosition.x;
        this.y = targetPosition.y;

        Actuate.stop(AnimateMove);
    }

    public override function SetInitialPosition(x:Int, y:Int)
    {
        super.SetInitialPosition(x, y);
        targetPosition = new Vector(x * LevelAvatar.PixelsPerTile,  y * LevelAvatar.PixelsPerTile);
    }

    public override function SetPosition(x:Int, y:Int)
    {
        SnapPosition();
        targetPosition = new Vector(x * LevelAvatar.PixelsPerTile,  y * LevelAvatar.PixelsPerTile);

        Actuate.update(AnimateMove, .075, [this.x, this.y], [targetPosition.x, targetPosition.y]).ease(Linear.easeNone);
    }

    public function MoveFail(dirX:Int, dirY:Int)
    {
        SnapPosition();
        
        this.x += dirX * LevelAvatar.PixelsPerTile / 10;
        this.y += dirY * LevelAvatar.PixelsPerTile / 10;

        Actuate.update(AnimateMove, .075, [this.x, this.y], [targetPosition.x, targetPosition.y]).ease(Linear.easeNone);
    }

    private function AnimateMove(x:Float, y:Float)
    {
        this.x = x;
        this.y = y;
    }
}