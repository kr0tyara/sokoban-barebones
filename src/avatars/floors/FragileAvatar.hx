package avatars.floors;

import entities.floors.Fragile;

class FragileAvatar extends FloorAvatar
{
    public override function Update()
    {
        spriteContainer.visible = cast(floor, Fragile).alive;
    }
}