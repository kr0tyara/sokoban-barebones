package avatars.objects;

import h2d.Graphics;
import entities.objects.ObjectEntity;

class PlayerAvatar extends ObjectAvatar
{
    public function new(prototype:ObjectEntity)
    {
        super(prototype);
    }

    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        var gfx = new Graphics();
        gfx.beginFill(ObjectEntity.GetDebugColor(object.type));
        gfx.drawRect(LevelAvatar.PixelsPerTile / 4, LevelAvatar.PixelsPerTile / 4, LevelAvatar.PixelsPerTile / 2, LevelAvatar.PixelsPerTile / 2);

        spriteContainer.addChild(gfx);
    }
}