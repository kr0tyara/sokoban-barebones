import entities.floors.Goal;
import entities.floors.FloorEntity;
import entities.objects.ObjectEntity;
import entities.objects.Player;
import haxe.Exception;
import haxe.ds.Vector;
import entities.BaseEntity;

class Grid
{
    public var allEntities:Array<BaseEntity>;
    
    public var players:Array<Player>;
    public var goals:Array<Goal>;

    private var floors:Array<FloorEntity>;
    private var objects:Array<ObjectEntity>;

    public var width:Int;
    public var height:Int;

    private var levelData:Data.Levels;
    
    public function new(levelData:Data.Levels)
    {
        this.levelData = levelData;

        width = levelData.width;
        height = levelData.height;

        objects = new Array();
        floors  = new Array();
    }

    public function Init()
    {
        DecodeLevel();

        Game.history.Initialize(this);
        OnMovementEnd(true);
    }
    
    private function DecodeLevel()
    {
        allEntities = new Array<BaseEntity>();

        players = new Array<Player>();
        goals = new Array<Goal>();

        var objects = levelData.objects.decode(Data.objects.all);
        for(i in 0...objects.length)
        {
            var x = i % width;
            var y = Math.floor(i / width);
            
            var object = SpawnObjectTile(objects[i].id, x, y);
            if(object is Player)
                players.push(cast(object, Player));
        }

        var floors = levelData.floor.decode(Data.floor.all);
        for(i in 0...floors.length)
        {
            var x = i % width;
            var y = Math.floor(i / width);
            
            var floor = SpawnFloorTile(floors[i].id, x, y);
            if(floors[i].id == Data.FloorKind.Goal)
                goals.push(cast(floor, Goal));
        }
    }

    public function SortByDirection(dirX:Int, dirY:Int)
    {
        var list = players.copy();
            
        if(dirX == -1)
            list.sort((a, b) -> a.x - b.x);
        else if(dirX == 1)
            list.sort((a, b) -> b.x - a.x);
        else if(dirY == -1)
            list.sort((a, b) -> a.y - b.y);
        else if(dirY == 1)
            list.sort((a, b) -> b.y - a.y);

        return list;
    }

    public function SpawnObjectTile(kind:Data.ObjectsKind, x:Int, y:Int)
    {
        if(kind == Data.ObjectsKind.Void)
            return null;

        var object = Data.objects.get(kind);
        var objectClass = Type.resolveClass('entities.objects.${object.className}');

        if(objectClass == null)
        {
            throw new Exception('No such class: entities.objects.${object.className}');
            return null;
        }

        var object = Type.createInstance(objectClass, [kind]);
        return AddObject(object, x, y);
    }
    public function AddObject(object:ObjectEntity, x:Int, y:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= height)
        {
            throw new Exception('AddObject $object out of bounds: {$x, $y}');
            return null;
        }

        object.x = x;
        object.y = y;

        objects.push(object);
        allEntities.push(object);

        object.OnCreate();
        return object;
    }

    public function SpawnFloorTile(kind:Data.FloorKind, x:Int, y:Int)
    {
        var floor = Data.floor.get(kind);
        var floorClass = Type.resolveClass('entities.floors.${floor.className}');

        if(floorClass == null)
        {
            throw new Exception('No such class: entities.floors.${floor.className}');
            return null;
        }

        var floor = Type.createInstance(floorClass, [kind]);
        return AddFloor(floor, x, y);
    }
    public function AddFloor(floor:FloorEntity, x:Int, y:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= height)
        {
            throw new Exception('AddFloor $floor out of bounds: {$x, $y}');
            return null;
        }

        floor.x = x;
        floor.y = y;

        floors.push(floor);
        allEntities.push(floor);

        floor.OnCreate();
        return floor;
    }

    public function Push(object:ObjectEntity, dirX:Int, dirY:Int, isPlayerMove:Bool):Bool
    {
        if(dirX != 0 && dirY != 0)
        {
            throw new Exception('Push $object invalid: {$dirX, $dirY}');
            return false;
        }

        if(object.x + dirX < 0 || object.x + dirX >= width || object.y + dirY < 0 || object.y + dirY >= height)
        {
            return false;
        }

        if(!object.CanPush(dirX, dirY))
        {
            return false;
        }

        var entityOnwards = GetObject(object.x + dirX, object.y + dirY);
        if(entityOnwards == null)
        {
            return Move(object, dirX, dirY, isPlayerMove);
        }
        else
        {
            if(Push(entityOnwards, dirX, dirY, false))
                return Move(object, dirX, dirY, isPlayerMove);
        }

        return false;
    }

    public function Destroy(x:Int, y:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= height)
        {
            throw new Exception('Destroy out of bounds: {$x, $y}');
            return;
        }

        var object = GetObject(x, y);
        if(object != null)
        {
            object.OnDestroy();
            objects.remove(object);
            allEntities.remove(object);
        }
    }

    public function Move(object:ObjectEntity, dirX:Int, dirY:Int, isPlayerMove:Bool):Bool
    {
        if(dirX != 0 && dirY != 0)
        {
            throw new Exception('Move invalid: {$dirX, $dirY}');
            return false;
        }
        
        if(object.x + dirX < 0 || object.x + dirX >= width || object.y + dirY < 0 || object.y + dirY >= height)
        {
            throw new Exception('Move out of bounds: {${object.x} + $dirX, ${object.y} + $dirY');
            return false;
        }

        var toX = object.x + dirX;
        var toY = object.y + dirY;

        var floor = GetFloor(toX, toY);
        
        if(floor == null)
        {
            trace('WARNING: can\'t move to [$toX, $toY]: no floor!');
            return false;
        }

        if(!floor.CanStepOn(object))
            return false;
        
        if(GetObject(toX, toY) != null)
        {
            trace('WARNING: can\'t move to [$toX, $toY]: it\'s occupied!');
            return false;
        }

        var oldX = object.x;
        var oldY = object.y;

        object.x = toX;
        object.y = toY;

        object.OnMove(dirX, dirY);

        floor.StashStepOn(object);

        var oldFloor = GetFloor(oldX, oldY);
        if(oldFloor != null)
            oldFloor.StashStepOff(object);

        return true;
    }

    public function OnMovementEnd(initial:Bool)
    {
        for(entity in allEntities)
            entity.OnTick(initial);
        
        Game.history.MakeState();
        CheckLevelCompletion();
    }

    public function CheckLevelCompletion()
    {
        var won = true;

        if(goals.length == 0)
            return;

        // to win, there should be a block on top of each goal 
        for(goal in goals)
        {
            var object = GetObject(goal.x, goal.y);
            if(object == null || object.kind != Data.ObjectsKind.Block)
            {
                won = false;
                break;
            }
        }

        if(won)
        {
            Game.level.Complete();
        }
    }

    public function GetObjects(x:Int, y:Int):Array<ObjectEntity>
    {
        if(x < 0 || x >= width || y < 0 || y >= height)
            return [];

        return objects.filter(a -> a.x == x && a.y == y);
    }
    public function GetObject(x:Int, y:Int):ObjectEntity
    {
        var objects = GetObjects(x, y);
        if(objects.length == 0)
            return null;

        // here you can filter for certain object types you're looking for. 
        // this example code just grabs the first object under the specified coordinates, which is
        // not perfect if you want to use multiple objects per same tile
        // (like sugar cubes or rat carriers from desperatea)
        
        return objects[0];
    }

    public function GetFloor(x:Int, y:Int):FloorEntity
    {
        if(x < 0 || x >= width || y < 0 || y >= height)
            return null;

        return floors.filter(a -> a.x == x && a.y == y)[0];
    }
}