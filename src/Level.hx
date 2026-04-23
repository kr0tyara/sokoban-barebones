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

        var savedLevel = SaveManager.GetLevelInfo(kind);
        trace('level $id:\n${savedLevel.completed ? 'completed in ${savedLevel.steps} steps' : 'not completed yet'}');
    }

    public function Init()
    {
        grid.Init();
        
        avatar = new LevelAvatar(id, grid);
        addChild(avatar);
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
                AudioManager.inst.Click();
                Game.history.Restart();
                return;

            case InputKey.Z:
                if(Game.history.Undo())
                    AudioManager.inst.Click();
                return;

            case InputKey.Y:
                if(Game.history.Redo())
                    AudioManager.inst.Click();
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
            {
                AudioManager.inst.Move();
                grid.OnMovementEnd(false);
            }
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
        AudioManager.inst.Unlock();

        SaveManager.CompleteLevel(kind, Game.history.steps);

        var level = SaveManager.GetLevelInfo(kind);
        trace('completed in ${Game.history.steps} steps (best result: ${level.steps})');

        Game.inst.NextLevel();
    }
}