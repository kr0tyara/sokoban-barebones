package ui;

import h2d.Interactive;
import h2d.Bitmap;
import h2d.Tile;

class Button extends Interactive
{
    public function new(w:Int, h:Int, icon:Tile = null)
    {
        super(w, h);

        backgroundColor = 0xAA000000;

        if(icon != null)
        {
            var bitmap = new Bitmap(icon);
            icon.setCenterRatio(.5, .5);
            bitmap.x = w / 2;
            bitmap.y = h / 2;
            bitmap.scale(.5);
            addChild(bitmap);
        }
    }
}