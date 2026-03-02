package avatars.floors;

import h2d.Tile;
import h2d.Bitmap;

class GoalAvatar extends FloorAvatar
{
    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        var bitmap = new Bitmap(Tile.fromColor(0x15FF00, LevelAvatar.PixelsPerTile, LevelAvatar.PixelsPerTile));
        spriteContainer.addChild(bitmap);
    }
}