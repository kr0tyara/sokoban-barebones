import entities.floors.FloorEntity;
import entities.objects.ObjectEntity;
import avatars.LevelAvatar;
import InputManager.InputKey;
import haxe.Exception;
import h2d.Graphics;

@:keepSub
class Level extends h2d.Object
{
    public var id:Int;
    public var kind:Data.LevelsKind;
    private var data:Data.Levels;

    public static var grid:Grid;
    private var gfx:Graphics;

    public static var avatar:LevelAvatar;

    public function new(kind:Data.LevelsKind)
    {
        super();

        this.kind = kind;
        data = Data.levels.get(kind);

        for(i in 0...Data.levels.all.length)
        {
            var room = Data.levels.all[i];
            if(room.id == kind)
            {
                id = i;
                break;
            }
        }
        
        grid = new Grid(data);
        
        avatar = new LevelAvatar(id, grid);
        addChild(avatar);

        gfx = new Graphics();
        addChild(gfx);

        var savedLevel = SaveManager.GetLevelInfo(kind);
        trace('level $id:\n${savedLevel.completed ? 'completed in ${savedLevel.steps} steps' : 'not completed yet'}');
    }

    public function Init()
    {

    }

    public override function onRemove()
    {
        avatar.remove();
    }

    public function OnResize()
    {
        avatar.OnResize();
    }

    public function HandleInput()
    {
        if(Game.inst.InputBlocked())
            return;

        var key = InputManager.inst.currentKey;

        var dirX = 0;
        var dirY = 0;

        switch(key)
        {
            case InputKey.R:
                Game.history.Restart();
                return;

            case InputKey.Z:
                Game.history.Undo();
                return;

            case InputKey.Y:
                Game.history.Redo();
                return;
            
            case InputKey.Left:
                dirX = -1;
            case InputKey.Right:
                dirX = 1;
            case InputKey.Up:
                dirY = -1;
            case InputKey.Down:
                dirY = 1;

            default:
        }

        if(dirX != 0 || dirY != 0)
        { 
            var madeAnything = false;

            var sortedPlayers = grid.SortByDirection(dirX, dirY);
            for(player in sortedPlayers)
            {
                var push = grid.Push(player, dirX, dirY, 0);
                if(push)
                    madeAnything = true;
            }

            if(madeAnything)
                grid.OnMovementEnd(madeAnything);
        }
    }

    public function update(dt:Float)
    {
        HandleInput();
        //DrawGrid(grid, 25);
        avatar.update(dt);
    }

    public function Complete()
    {
        SaveManager.CompleteLevel(kind, Game.history.steps);

        var level = SaveManager.GetLevelInfo(kind);
        trace('completed in ${Game.history.steps} steps (best result: ${level.steps})');

        Game.inst.NextLevel();
    }

    // this function is for debugging only!
    // use LevelAvatar to render the game in its full glory!
    public function DrawGrid(grid:Grid, size:Int = 100)
    {
        gfx.clear();

        for(y in 0...grid.length)
        {
            for(x in 0...grid.width)
            {
                var floor = grid.GetFloor(x, y, 0);
                if(floor != null)
                {
                    gfx.beginFill(FloorEntity.GetDebugColor(floor.type));
                    gfx.drawRect(x * size, y * size, size, size);
                }
            }
        }

        for(y in 0...grid.length)
        {
            for(x in 0...grid.width)
            {
                var object = grid.GetObject(x, y, 0);
                if(object != null)
                {
                    gfx.beginFill(ObjectEntity.GetDebugColor(object.type));
                    gfx.drawRect(x * size, y * size, size, size);
                }
            }
        }

        gfx.lineStyle(2, 0x666666, 1);
        for(x in 0...grid.width)
        {
            gfx.moveTo(x * size, 0);
            gfx.lineTo(x * size, grid.length * size);
        }
        for(y in 0...grid.length)
        {
            gfx.moveTo(0, y * size);
            gfx.lineTo(grid.width * size, y * size);
        }
    }
}