package gfx;

typedef Rect =
{
    x:Int,
    y:Int,
    w:Int,
    h:Int
}
typedef SheetData =
{
    frames:Array<{
        filename:String,
        frame:Rect,
        rotated:Bool,
        trimmed:Bool,
        spriteSourceSize:Rect,
        sourceSize:{w:Int, h:Int},
    }>
};
typedef SpriteData =
{
    img:String,
    frames:Array<Rect>
}