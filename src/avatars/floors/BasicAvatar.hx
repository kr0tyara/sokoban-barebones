package avatars.floors;

import h2d.Tile;
import h2d.Bitmap;

class BasicAvatar extends FloorAvatar
{
    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        var bitmap = new Bitmap(Tile.fromColor(0xFFFFFF, LevelAvatar.PixelsPerTile, LevelAvatar.PixelsPerTile));
        spriteContainer.addChild(bitmap);
    }
}