package macros;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

class HistoryMaker
{
    macro public static function load():Array<Field>
    {
        var synced:Array<String> = [];

        var fields = Context.getBuildFields();

        for(field in fields)
        {
            if(field.meta.filter(a -> a.name == ':history').length > 0)
                synced.push(field.name);
        }

        var expr = macro historyFields = historyFields.concat($v{synced});

        for(field in fields)
        {
            if(field.name != 'new')
                continue;

            switch(field.kind)
            {
                case FieldType.FFun(f):
                    switch(f.expr.expr)
                    {
                        case EBlock(exprs):
                            exprs.push(expr);

                        default:
                            f.expr = macro {
                                ${f.expr};
                                $expr;
                            }
                    }

                default:
            }
        }

        return fields;
    }
}
