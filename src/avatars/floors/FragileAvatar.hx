package avatars.floors;

import h2d.Tile;
import h2d.Bitmap;
import entities.floors.Fragile;

class FragileAvatar extends FloorAvatar
{
    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        var bitmap = new Bitmap(Tile.fromColor(0xA51900, LevelAvatar.PixelsPerTile, LevelAvatar.PixelsPerTile));
        spriteContainer.addChild(bitmap);
    }

    public override function Update()
    {
        spriteContainer.visible = cast(floor, Fragile).alive;
    }
}