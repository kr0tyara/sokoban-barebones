import entities.floors.FloorEntity;
import entities.objects.ObjectEntity;
import avatars.LevelAvatar;
import InputManager.InputKey;
import haxe.Exception;
import h2d.Graphics;

class Level extends h2d.Object
{
    private var id:Int;
    private var kind:Data.LevelsKind;

    public static var grid:Grid;
    private var gfx:Graphics;

    public static var avatar:LevelAvatar;

    public function new(id:Int)
    {
        super();

        this.id = id;
        var level = Data.levels.all[id];
        kind = level.id;
        
        grid = new Grid(level);
        
        avatar = new LevelAvatar(grid);
        addChild(avatar);

        gfx = new Graphics();
        addChild(gfx);

        var savedLevel = Main.save.levels.filter(a -> a.id == kind)[0];
        trace('level $id:\n${savedLevel.completed ? 'completed in ${savedLevel.steps} steps' : 'not completed yet'}');
    }
    public override function onRemove()
    {
        removeChild(avatar);
    }

    public function OnResize()
    {
        avatar.OnResize();
    }

    public function HandleInput()
    {
        if(InputManager.inst.inputBlocked)
            return;

        var key = InputManager.inst.currentKey;

        var dirX = 0;
        var dirY = 0;

        switch(key)
        {
            case InputKey.Z:
                Game.history.Undo();
                return;

            case InputKey.Y:
                Game.history.Redo();
                return;
            
            case InputKey.LEFT:
                dirX = -1;
            case InputKey.RIGHT:
                dirX = 1;
            case InputKey.UP:
                dirY = -1;
            case InputKey.DOWN:
                dirY = 1;

            default:
        }

        if(dirX != 0 || dirY != 0)
        { 
            var madeAnything = false;

            var sortedPlayers = grid.SortByDirection(dirX, dirY);
            for(player in sortedPlayers)
            {
                var push = grid.Push(player.x, player.y, player.z, dirX, dirY, 0);
                if(push)
                    madeAnything = true;
            }

            if(madeAnything)
            {
                grid.OnMovementEnd(madeAnything);
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
        var level = Main.save.levels.filter(a -> a.id == kind)[0];
        if(level == null)
        {
            throw Exception;
            return;
        }
        level.completed = true;

        if(level.steps == -1)
            level.steps = Game.history.steps;
        else if(Game.history.steps < level.steps)
            level.steps = Game.history.steps;

        hxd.Save.save(Main.save, Main.saveSlot);
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