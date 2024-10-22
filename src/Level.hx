import avatars.LevelAvatar;
import entities.Entity;
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

        Game.inst.NextLevel();    
    }

    public function DrawGrid(grid:Grid, size:Int = 100)
    {
        gfx.clear();

        gfx.lineStyle(2, 0x666666, 1);

        for(y in 0...grid.length)
        {
            for(x in 0...grid.width)
            {
                var entity = grid.GetEntity(x, y, 0);
                if(entity != null)
                {
                    gfx.beginFill(Entity.GetDebugColor(entity.type));
                    gfx.drawRect(x * size, y * size, size, size);
                }
            }
        }

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