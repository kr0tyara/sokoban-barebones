package avatars.objects;

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

    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();
    }

    private function SnapPosition()
    {
        this.x = targetPosition.x;
        this.y = targetPosition.y;

        if(moveTween != null && !moveTween.isComplete)
            moveTween.stop();
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

        moveTween = Main.tm.animateTo(this, {x: targetPosition.x, y: targetPosition.y}, .1, slide.easing.Linear.none);
        moveTween.start();
    }
}