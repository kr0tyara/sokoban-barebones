package gfx;

import h2d.Tile;
import hxd.Res;
import gfx.SheetData.SpriteData;

class Sprite
{
    public var frames:Array<Tile>;
    private var data:SpriteData;

    public function new(data:SpriteData)
    {
        this.data = data;

        frames = new Array();
        var img = Res.load(data.img).toTile();
        for(frame in data.frames)
        {
            var tile = img.sub(frame.x, frame.y, frame.w, frame.h);
            frames.push(tile);
        }
    }
}