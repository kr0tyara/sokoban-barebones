package avatars;

import h2d.Bitmap;
import h2d.Graphics;
import entities.FloorEntity;

class FloorAvatar extends BaseAvatar
{
    private var floor:FloorEntity;

    public function new(prototype:FloorEntity)
    {
        floor = cast(prototype, FloorEntity);
        super(prototype);
    }

    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        var tile = Main.cdbSheet.floor[floor.kind];

        var bitmap = new Bitmap(tile);
        bitmap.x = LevelAvatar.PixelsPerTile / 2;
        bitmap.y = LevelAvatar.PixelsPerTile;
        spriteContainer.addChild(bitmap);

        Update();
    }
}