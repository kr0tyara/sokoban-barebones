package avatars.objects;

import h2d.Graphics;
import entities.objects.ObjectEntity;

class ObjectAvatar extends BaseAvatar
{
    private var object:ObjectEntity;

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
}