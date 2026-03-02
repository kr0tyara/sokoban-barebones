package avatars.floors;

import h2d.Graphics;
import entities.floors.FloorEntity;

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
    }
}