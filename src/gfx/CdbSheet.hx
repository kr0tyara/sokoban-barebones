package gfx;

import h2d.Tile;

class CdbSheet
{
    public var tileSheets:Map<String, Tile>;
    public var objects:Map<Data.ObjectsKind, Tile>;
    public var floor:Map<Data.FloorKind, Tile>;

    public function new()
    {
        tileSheets = [];
        objects = [];
        floor = [];

        var tileRefs = [];
        tileRefs = tileRefs.concat(Data.floor.all.map(a -> a.tile.file));
        tileRefs = tileRefs.concat(Data.objects.all.map(a -> a.tile.file));

        for(tile in tileRefs)
        {
            if(tileSheets.exists(tile))
                continue;

            tileSheets.set(tile, hxd.Res.load(tile).toTile());
        }

        for(o in Data.objects.all)
        {
            var t = o.tile;
            var tile = tileSheets[t.file].sub(t.x * t.size, t.y * t.size, t.size, t.size);
            tile.setCenterRatio(.5, 1);
            objects[o.id] = tile;
        }

        for(f in Data.floor.all)
        {
            var t = f.tile;
            var tile = tileSheets[t.file].sub(t.x * t.size, t.y * t.size, t.size, t.size);
            tile.setCenterRatio(.5, 1);
            floor[f.id] = tile;
        }
    }
}