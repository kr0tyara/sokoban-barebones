package avatars;

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
    }
}