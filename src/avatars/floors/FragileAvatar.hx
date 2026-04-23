package avatars.floors;

import h2d.Tile;
import h2d.Bitmap;
import entities.floors.Fragile;

class FragileAvatar extends BasicAvatar
{
    public override function GetColors()
    {
        return [0xA51900];
    }

    public override function Update()
    {
        spriteContainer.visible = cast(floor, Fragile).alive;
    }
}