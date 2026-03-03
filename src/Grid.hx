import entities.floors.Goal;
import entities.floors.FloorEntity;
import entities.objects.ObjectEntity;
import entities.objects.Player;
import haxe.Exception;
import haxe.ds.Vector;
import entities.BaseEntity;

typedef Neighbour = {
    object:ObjectEntity,
    side:Int
};

class Grid
{
    public var allEntities:Array<BaseEntity>;
    
    public var players:Array<Player>;
    public var goals:Array<Goal>;

    private var floors:Array<FloorEntity>;
    private var objects:Array<ObjectEntity>;

    public var width:Int;
    public var length:Int;
    public var height:Int;

    private var levelData:Data.Levels;
    
    public function new(levelData:Data.Levels)
    {
        this.levelData = levelData;

        width = levelData.width;
        length = levelData.height;
        height = 1;

        objects = new Array();
        floors  = new Array();
    }

    public function Init()
    {
        DecodeLevel();

        Game.history.Initialize(this);
        Game.history.MakeState();
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
            
            var object = SpawnObjectTile(objects[i].id, x, y, 0);
            if(objects[i].id == Data.ObjectsKind.Player)
                players.push(cast(object, Player));
        }

        var floors = levelData.floor.decode(Data.floor.all);
        for(i in 0...floors.length)
        {
            var x = i % width;
            var y = Math.floor(i / width);
            
            var floor = SpawnFloorTile(floors[i].id, x, y, 0);
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

    public function SpawnObjectTile(kind:Data.ObjectsKind, x:Int, y:Int, z:Int)
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

        var object = Type.createInstance(objectClass, []);
        return AddObject(object, x, y, z);
    }
    public function AddObject(object:ObjectEntity, x:Int, y:Int, z:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return null;
        }

        object.x = x;
        object.y = y;
        object.z = z;

        objects.push(object);
        allEntities.push(object);

        object.OnCreate();
        return object;
    }

    public function SpawnFloorTile(kind:Data.FloorKind, x:Int, y:Int, z:Int)
    {
        var floor = Data.floor.get(kind);
        var floorClass = Type.resolveClass('entities.floors.${floor.className}');

        if(floorClass == null)
        {
            throw new Exception('No such class: entities.floors.${floor.className}');
            return null;
        }

        var floor = Type.createInstance(floorClass, []);
        return AddFloor(floor, x, y, z);
    }
    public function AddFloor(floor:FloorEntity, x:Int, y:Int, z:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return null;
        }

        floor.x = x;
        floor.y = y;
        floor.z = z;

        floors.push(floor);
        allEntities.push(floor);

        floor.OnCreate();
        return floor;
    }

    public function Push(object:ObjectEntity, dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        if(dirX != 0 && dirY != 0 && dirZ != 0)
        {
            throw Exception;
            return false;
        }

        if(object.x + dirX < 0 || object.x + dirX >= width || object.y + dirY < 0 || object.y + dirY >= length || object.z + dirZ < 0 || object.z + dirZ >= height)
        {
            return false;
        }

        if(!object.CanPush(dirX, dirY, dirZ))
        {
            return false;
        }

        var entityOnwards = GetObject(object.x + dirX, object.y + dirY, object.z + dirZ);
        if(entityOnwards == null)
        {
            return Move(object, dirX, dirY, dirZ);
        }
        else
        {
            if(Push(entityOnwards, dirX, dirY, dirZ))
                return Move(object, dirX, dirY, dirZ);
        }

        return false;
    }

    public function Destroy(x:Int, y:Int, z:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
        }

        var object = GetObject(x, y, z);
        if(object != null)
        {
            object.OnDestroy();
            objects.remove(object);
            allEntities.remove(object);
        }
    }

    public function Move(object:ObjectEntity, dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        if(dirX != 0 && dirY != 0 && dirZ != 0)
        {
            throw Exception;
            return false;
        }
        
        if(object.x + dirX < 0 || object.x + dirX >= width || object.y + dirY < 0 || object.y + dirY >= length || object.z + dirZ < 0 || object.z + dirZ >= height)
        {
            throw Exception;
            return false;
        }

        var toX = object.x + dirX;
        var toY = object.y + dirY;
        var toZ = object.z + dirZ;

        var floor = GetFloor(toX, toY, toZ);
        
        if(floor == null)
        {
            trace('WARNING: can\'t move to [$toX, $toY, $toZ]: no floor!');
            return false;
        }

        if(!floor.CanStepOn(object))
            return false;
        
        if(GetObject(toX, toY, toZ) != null)
        {
            trace('WARNING: can\'t move to [$toX, $toY, $toZ]: it\'s occupied!');
            return false;
        }

        var oldX = object.x;
        var oldY = object.y;
        var oldZ = object.z;

        object.x = toX;
        object.y = toY;
        object.z = toZ;

        object.OnMove(dirX, dirY, dirZ);

        floor.StashStepOn(object);

        var oldFloor = GetFloor(oldX, oldY, oldZ);
        if(oldFloor != null)
            oldFloor.StashStepOff(object);

        return true;
    }

    public function OnMovementEnd(madeAnything:Bool)
    {
        for(entity in allEntities)
        {
            entity.OnTick();
        }
        
        Game.history.MakeState();
        CheckLevelCompletion();
    }

    public function GetNeighbourEntities(x:Int, y:Int, z:Int):Array<Neighbour>
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return [];
        }

        var positions = [{x: x - 1, y: y, z: z, side: BaseEntity.SIDE_LEFT}, {x: x + 1, y: y, z: z, side: BaseEntity.SIDE_RIGHT}, {x: x, y: y + 1, z: z, side: BaseEntity.SIDE_FRONT}, {x: x, y: y - 1, z: z, side: BaseEntity.SIDE_BACK}, {x: x, y: y, z: z + 1, side: BaseEntity.SIDE_UP}, {x: x, y: y, z: z - 1, side: BaseEntity.SIDE_BOTTOM}];
        var neighbours = new Array<Neighbour>();
        
        for(position in positions)
        {
            if(position.x < 0 || position.x >= width || position.y < 0 || position.y >= length || position.z < 0 || position.z >= height)
                continue;

            var neighbour = GetObject(position.x, position.y, position.z);
            if(neighbour != null)
                neighbours.push({object: neighbour, side: position.side});
        }

        return neighbours;
    }

    public function CheckLevelCompletion()
    {
        var won = true;

        // to win, there should be a block on top of each goal 
        for(goal in goals)
        {
            var object = GetObject(goal.x, goal.y, goal.z);
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

    public function GetObjects(x:Int, y:Int, z:Int):Array<ObjectEntity>
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return [];
        }

        return objects.filter(a -> a.x == x && a.y == y && a.z == z);
    }
    public function GetObject(x:Int, y:Int, z:Int):ObjectEntity
    {
        var objects = GetObjects(x, y, z);
        if(objects.length == 0)
            return null;

        // here you can filter for certain object types you're looking for. 
        // this example code just grabs the first object under the specified coordinates, which is
        // not perfect if you want to use multiple objects per same tile
        // (like sugar cubes or rat carriers from desperatea)
        
        return objects[0];
    }

    public function GetFloor(x:Int, y:Int, z:Int):FloorEntity
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return null;
        }

        return floors.filter(a -> a.x == x && a.y == y && a.z == z)[0];
    }
}