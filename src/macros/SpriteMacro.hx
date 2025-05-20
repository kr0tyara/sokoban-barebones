package macros;

import haxe.macro.Expr;
import haxe.macro.Context;
import gfx.SheetData;

// This macro handles spritesheets exported with Adobe Animate (using the JSON-Array method).
// It does not support rotated sprites.

class SpriteMacro
{
    macro public static function load(path:Array<String>):Array<Field>
    {
        var sprites:Map<String, SpriteData> = new Map();

        for(p in path)
        {
            var json = sys.FileSystem.fullPath('res/sheets/') + p + '.json';
            var png = sys.FileSystem.fullPath('res/sheets/') + p + '.png';

            haxe.macro.Context.registerModuleDependency(haxe.macro.Context.getLocalModule(), json);
            haxe.macro.Context.registerModuleDependency(haxe.macro.Context.getLocalModule(), png);

            try {
                var text = sys.io.File.getContent(json);
                if(text.indexOf("\ufeff") == 0)
                    text = text.substr(1);

                var sheetData:SheetData = haxe.Json.parse(text);
                
                for(f in sheetData.frames)
                {
                    var name = f.filename.substr(0, -4);
                    var index = Std.parseInt(f.filename.substr(-4));
                    if(!sprites.exists(name))
                        sprites.set(name, {img: 'sheets/' + p + '.png', frames: []});

                    sprites[name].frames.push({x: f.frame.x, y: f.frame.y, w: f.frame.w, h: f.frame.h});
                }
            } catch (e) {
                haxe.macro.Context.error('Failed to load sprite: $e', haxe.macro.Context.currentPos());
            }
        }

        var fields = Context.getBuildFields();

        for(t => sprite in sprites)
        {
            fields.push({
                name: t,
                access:  [Access.APublic],
                kind: FieldType.FVar(macro:Sprite, macro new Sprite($v{sprite})), 
                pos: Context.currentPos(),
            });
        }

        return fields;
    }
}