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

        var gfx = new Graphics();
        gfx.beginFill(FloorEntity.GetDebugColor(floor.type));
        gfx.drawRect(0, 0, LevelAvatar.PixelsPerTile, LevelAvatar.PixelsPerTile);

        spriteContainer.addChild(gfx);
    }
}