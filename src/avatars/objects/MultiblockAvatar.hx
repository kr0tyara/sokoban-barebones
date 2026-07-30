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
        var map = (neigh) -> neigh != null && neigh is Multiblock && multiblock.linked.contains(cast neigh);

        var neighbours = [for(k => v in object.GetNeighbourObjects()) k => map(v)];
        var diagonals = [for(k => v in object.GetDiagonalNeighbourObjects()) k => map(v)];

        gfx.clear();
        gfx.beginFill([0xff6a00, 0x0094ff, 0xffd800][multiblock.id - 1]);

        var cornerOffset = LevelAvatar.PixelsPerTile / 9;
        
        gfx.drawRoundedRectCorners(
            !neighbours[Dir.Left] ? cornerOffset : 0,
            !neighbours[Dir.Up] ? cornerOffset : 0,
            !neighbours[Dir.Right] && !neighbours[Dir.Left] ? LevelAvatar.PixelsPerTile - cornerOffset * 2
                : !neighbours[Dir.Right] || !neighbours[Dir.Left] ? LevelAvatar.PixelsPerTile - cornerOffset : LevelAvatar.PixelsPerTile,

            !neighbours[Dir.Up] && !neighbours[Dir.Down] ? LevelAvatar.PixelsPerTile - cornerOffset * 2
                : !neighbours[Dir.Up] || !neighbours[Dir.Down] ? LevelAvatar.PixelsPerTile - cornerOffset : LevelAvatar.PixelsPerTile,
            
            25, neighbours, diagonals
        );
        gfx.endFill();
    }
}