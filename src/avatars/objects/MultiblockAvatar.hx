package avatars.objects;

import entities.objects.Multiblock;
import h2d.Anim;

class MultiblockAvatar extends ObjectAvatar
{
    private var gfx:GraphicsExtender;
    private var multiblock:Multiblock;
    
    public function new(prototype:Multiblock)
    {
        super(prototype);
        multiblock = prototype;
    }

    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        gfx = new GraphicsExtender(spriteContainer);
        Redraw();
    }

    public function Redraw()
    {
        var dirs = Neigh();

        gfx.clear();

        gfx.beginFill([0xff6a00, 0x0094ff, 0xffd800][multiblock.id - 1]);
        gfx.drawRoundedRectCorners(0, 0, LevelAvatar.PixelsPerTile, LevelAvatar.PixelsPerTile, 25, dirs);
        gfx.endFill();
    }

    public function Neigh()
    {
        var grid = Level.grid;

        var neighbours = object.GetNeighbourObjects();

        var dirs = new Map<Dir, Bool>();
        for(i => neigh in neighbours)
            dirs[i] = neigh != null && neigh is Multiblock && multiblock.linked.contains(cast neigh);

        return dirs;
    }
}