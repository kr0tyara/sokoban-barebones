package avatars.decorations;

import motion.Actuate;
import shaders.Vignette;
import h2d.col.Point;
import h2d.Object;
import hxd.Res;
import h2d.Bitmap;
import h2d.Tile;
import h2d.TileGroup;

class Background extends Object
{
    private var tileGroup:TileGroup;
    private var tileGroupAlt:TileGroup;
    private var tile:Tile;

    private var shader:Vignette;
    private var showVignette:Bool;

    public function new(tile:Tile, showVignette:Bool = true)
    {
        super();

        this.tile = tile;
        this.showVignette = showVignette;

        tileGroup = new TileGroup(tile);
        tileGroup.y = -LevelAvatar.PixelsPerTile / 2;
        addChild(tileGroup);
        
        tileGroupAlt = new TileGroup(tile);
        tileGroupAlt.y = -LevelAvatar.PixelsPerTile / 2;
        addChildAt(tileGroupAlt, 0);
        tileGroupAlt.visible = false;
        
        if(showVignette)
        {
            shader = new Vignette();

            shader.gradColor.set(0, 0, 0, .25);
            shader.softness = 0.2;

            tileGroup.addShader(shader);
            tileGroupAlt.addShader(shader);
        }
    }

    public function SetTile(tile:Tile, transition:Bool = false, transitionDelay:Float = 0, transitionTime:Float = 1, transitionCallback:()->Void = null)
    {
        this.tile = tile;

        if(transition)
        {
            tileGroupAlt.visible = true;
            Rebuild(true);

            Actuate.tween(tileGroup, transitionTime, {alpha: 0}).onComplete(() ->
            {
                tileGroupAlt.clear();
                tileGroupAlt.visible = false;

                tileGroup.alpha = 1;
                Rebuild();

                if(transitionCallback != null)
                    transitionCallback();
            }).delay(transitionDelay);
        }
        else
            Rebuild();
    }

    private function PopulateDimensions(tile:Tile)
    {
        var stepX = tile.width  * this.parent.scaleX;
        var stepY = tile.height * this.parent.scaleY;

        var offX = this.parent.x % stepX;
        var offY = this.parent.y % stepY;

        if(offX > 0)
            offX -= stepX;
        if(offY > 0)
            offY -= stepY;

        var pos = this.parent.globalToLocal(new Point(offX, offY));

        var screenW = Math.ceil((Main.inst.s2d.width - offX) / stepX) + 1;
        var screenH = Math.ceil((Main.inst.s2d.height - offY) / stepY) + 1;

        return {offX: pos.x, offY: pos.y, screenW: screenW, screenH: screenH};
    }

    public function Rebuild(alt:Bool = false)
    {
        var group = alt ? tileGroupAlt : tileGroup;
        group.clear();

        var dim = PopulateDimensions(tile);

        this.x = dim.offX;
        this.y = dim.offY;

        for(i in 0...(dim.screenW * dim.screenH))
        {
            var x = i % dim.screenW;
            var y = Math.floor(i / dim.screenW);
            group.add(x * tile.width, y * tile.height, tile);
        }

        if(showVignette)
        {
            var grid = Level.grid;
            shader.screenSize.set(Main.inst.s2d.width, Main.inst.s2d.height);
            shader.rect.set(this.parent.x - LevelAvatar.PixelsPerTile * 2 * this.parent.scaleX, this.parent.y - LevelAvatar.PixelsPerTile * 2 * this.parent.scaleY, (grid.width + 4) * LevelAvatar.PixelsPerTile * this.parent.scaleX, (grid.height + 4) * LevelAvatar.PixelsPerTile * this.parent.scaleY);
        }
    }
    
    public function OnResize()
    {
        Rebuild();
    }
}