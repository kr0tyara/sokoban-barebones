package macros;

import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Context;
import gfx.SheetData;
import sys.io.File;

typedef RoomData = 
{
    id:String,
    className:String
};

class LevelsMacro
{
    macro public static function build()
    {
        var cdb = haxe.Json.parse(File.getContent(FileSystem.fullPath('res/data.cdb')));
        var levels:Array<RoomData> = cdb.sheets.filter((a) -> a.name == 'levels')[0].lines;

        var path = FileSystem.fullPath('src/levels');

        var countedFiles = [];
        for(level in levels)
        {
            if(level.className == '')
                continue;

            var className = level.className;
            var name = path + '\\' + className + '.hx';
            countedFiles.push(className + '.hx');

            if(!FileSystem.exists(name))
            {
                var data =
'package levels;

class ${className} extends Level
{
    public function new()
    {
        super(Data.LevelsKind.${level.id});
    }
        
    public override function Init()
    {
        super.Init();
    }
}';

                File.saveContent(name, data);
            }
        }

        return null;
    }
}