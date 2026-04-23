package avatars.floors;

import h2d.Object;
import slide.Tween;
import h2d.Graphics;
import h2d.Anim;
import Utils.Dir;
import h2d.Tile;
import h2d.Bitmap;
import entities.floors.FloorEntity;
import entities.floors.Hole;

class BasicAvatar extends FloorAvatar
{
    public var gfx:GraphicsExtender;

    public function new(prototype:FloorEntity)
    {
        super(prototype);
    }

    public override function SpawnSprite()
    {
        gfx = new GraphicsExtender(spriteContainer);
        Redraw();
    }

    public function Neigh()
    {
        var grid = Level.grid;

        var neighbours = new Map<Dir, FloorEntity>();
        neighbours[Dir.Right] = grid.GetFloor(prototype.x + 1, prototype.y, prototype.z);
        neighbours[Dir.Left] = grid.GetFloor(prototype.x - 1, prototype.y, prototype.z);
        neighbours[Dir.Down] = grid.GetFloor(prototype.x, prototype.y + 1, prototype.z);
        neighbours[Dir.Up] = grid.GetFloor(prototype.x, prototype.y - 1, prototype.z);

        var dirs = new Map<Dir, Bool>();
        for(i => neigh in neighbours)
            dirs[i] = neigh != null && !(neigh is Hole);

        return dirs;
    }

    public function GetColors()
    {
        return [0xFFFFFF, 0xE7E7E7];
    }

    public function Redraw()
    {
        var dirs = Neigh();

        var radius = 25;

        gfx.clear();

        if(!dirs[Dir.Down])
        {
            var dirs = dirs.copy();
            dirs[Dir.Up] = true;

            gfx.beginFill(0x5A5A5A);
            gfx.drawRoundedRectCorners(0, LevelAvatar.PixelsPerTile - radius, LevelAvatar.PixelsPerTile, LevelAvatar.PixelsPerTile / 2 + radius, radius, dirs);
            gfx.endFill();
        }

        var colors = GetColors();
        gfx.beginFill(colors[(prototype.x + prototype.y) % colors.length]);
        gfx.drawRoundedRectCorners(0, 0, LevelAvatar.PixelsPerTile, LevelAvatar.PixelsPerTile, 25, dirs);
        gfx.endFill();
    }
}