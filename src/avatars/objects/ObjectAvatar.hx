package avatars.objects;

import h2d.Bitmap;
import h2d.Anim;
import slide.Tween;
import h3d.Vector;
import h2d.Graphics;
import entities.objects.ObjectEntity;

class ObjectAvatar extends BaseAvatar
{
    public static inline var animationSpeed:Float = 35;

    private var object:ObjectEntity;
    private var targetPosition:Vector;

    private var moveTween:Tween;

    public function new(prototype:ObjectEntity)
    {
        object = cast(prototype, ObjectEntity);
        super(prototype);
    }

    // If nothing overrides this method, uses the same placeholder tiles as in CastleDB editor
    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        var sprite = Data.objects.get(object.kind).tile;
        var tile = hxd.Res.load(sprite.file).toTile().sub(sprite.x * sprite.size, sprite.y * sprite.size, sprite.size, sprite.size);
        tile.setCenterRatio(.5, 1);

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

        if(moveTween != null && !moveTween.isComplete)
            moveTween.reset();
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

        moveTween = Main.tm.animateTo(this, {x: targetPosition.x, y: targetPosition.y}, .075, slide.easing.Linear.none);
        moveTween.start();
    }

    public function MoveFail(dirX:Int, dirY:Int)
    {
        SnapPosition();
        
        this.x += dirX * LevelAvatar.PixelsPerTile / 10;
        this.y += dirY * LevelAvatar.PixelsPerTile / 10;

        moveTween = Main.tm.animateTo(this, {x: targetPosition.x, y: targetPosition.y}, .075, slide.easing.Linear.none);
        moveTween.start();
    }
}