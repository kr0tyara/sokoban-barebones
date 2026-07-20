package ui;

import hxd.Event;
import h2d.Text;
import h2d.Graphics;
import avatars.LevelAvatar;
import h2d.TileGroup;
import h2d.Tile;
import h2d.Bitmap;

class LevelIcon extends InteractiveExtender
{
    private var level:Data.Levels;

    private var bg:Bitmap;
    private var preview:TileGroup;
    private var label:Text;
    private var current:GraphicsExtender;
    private var solved:GraphicsExtender;

    public function new(level:Data.Levels)
    {
        var w = 200;
        var h = 200;

        super(w, h + 50);

        this.level = level;

        // to fix scrollbar
        var overflow = new Bitmap(Tile.fromColor(0xFFFFFF, w + 25, h, 0));
        addChild(overflow);

        bg = new Bitmap(Tile.fromColor(0x000000, w, h, .6));
        addChild(bg);

        preview = new TileGroup(this);

        var floors = level.floor.decode(Data.floor.all);
        var objects = level.objects.decode(Data.objects.all);

        for(i => floor in floors)
        {
            if(floor.id == Data.FloorKind.Hole)
                continue;

            var x = i % level.width;
            var y = Math.floor(i / level.width);

            var tile = Main.cdbSheet.floor[floor.id];
            preview.add((x + 0.5) * LevelAvatar.PixelsPerTile, (y + 1) * LevelAvatar.PixelsPerTile, tile);
        }
        for(i => object in objects)
        {
            if(object.id == Data.ObjectsKind.Void)
                continue;

            var x = i % level.width;
            var y = Math.floor(i / level.width);

            var tile = Main.cdbSheet.objects[object.id];
            preview.add((x + 0.5) * LevelAvatar.PixelsPerTile, (y + 1) * LevelAvatar.PixelsPerTile, tile);
        }

        var tilesWidth = level.width * LevelAvatar.PixelsPerTile;
        var tilesHeight = level.height * LevelAvatar.PixelsPerTile;
        var scale = (Math.max(w, h) - 50) / Math.max(tilesWidth, tilesHeight);

        preview.scaleX = preview.scaleY = scale;
        preview.x = (w - tilesWidth * scale) / 2;
        preview.y = (h - tilesHeight * scale) / 2;

        solved = new GraphicsExtender(this);
        solved.lineStyle(10, 0x00FF00);
        solved.drawRect(5, 5, w - 10, h - 10);

        var b = w / 4;
        current = new GraphicsExtender(this);
        current.lineStyle(20, 0xFFFFFF);

        current.moveTo(5 + b, 5);
        current.lineTo(5, 5);
        current.lineTo(5, 5 + b);

        current.moveTo(w - 5 - b, 5);
        current.lineTo(w - 5, 5);
        current.lineTo(w - 5, 5 + b);

        current.moveTo(5 + b, h - 5);
        current.lineTo(5, h - 5);
        current.lineTo(5, h - b - 5);

        current.moveTo(w - 5 - b, h - 5);
        current.lineTo(w - 5, h - 5);
        current.lineTo(w - 5, h - b - 5);

        label = new Text(Main.font, this);
        label.text = level.id.toString();
        label.textAlign = Align.Center;
        label.x = w / 2;
        label.y = h;

        this.tClick = Click;
    }

    public function Refresh()
    {
        var save = SaveManager.GetLevelInfo(level.id);
        var selected = Game.level.kind == level.id;

        solved.visible = save.completed;
        label.textColor = save.completed ? 0x00FF00 : selected ? 0xFFFFFF : 0x999999;
        current.visible = Game.level.kind == level.id;
    }

    private function Click(e:Event)
    {
        Game.inst.LoadLevel(level.id, true);   
        Game.inst.ToggleLevelSelect(false); 
    }
}