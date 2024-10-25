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

    private var floors:Vector<Vector<Vector<FloorEntity>>>;
    private var objects:Vector<Vector<Vector<ObjectEntity>>>;

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

        objects = new Vector(height);
        floors  = new Vector(height);

        for(i in 0...height)
        {
            objects[i] = new Vector(length);
            floors[i]  = new Vector(length);

            for(j in 0...length)
            {
                objects[i][j] = new Vector(width, null);
                floors[i][j]  = new Vector(width, null);
            }
        }
        
        DecodeLevel();
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
            SpawnObjectTile(objects[i].id, x, y, 0);
        }

        var floors = levelData.floor.decode(Data.floor.all);
        for(i in 0...floors.length)
        {
            var x = i % width;
            var y = Math.floor(i / width);
            SpawnFloorTile(floors[i].id, x, y, 0);
        }

        Game.history.Initialize(this);
        Game.history.MakeState();
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
        var object:ObjectEntity;
        switch(kind)
        {
            case Data.ObjectsKind.Player:
                object = new entities.objects.Player();
                players.push(cast(object, Player));

            case Data.ObjectsKind.Block:
                object = new entities.objects.Block();

            case Data.ObjectsKind.Wall:
                object = new entities.objects.Wall();

            default:
                object = null;
        }

        if(object != null)
            AddObject(object, x, y, z);
    }
    public function AddObject(object:ObjectEntity, x:Int, y:Int, z:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return;
        }

        objects[z][y][x] = object;
        object.x = x;
        object.y = y;
        object.z = z;
        object.OnCreate();

        allEntities.push(object);
    }

    public function SpawnFloorTile(kind:Data.FloorKind, x:Int, y:Int, z:Int)
    {
        var floor:FloorEntity;
        switch(kind)
        {
            case Data.FloorKind.Hole:
                floor = new entities.floors.Hole();

            case Data.FloorKind.Basic:
                floor = new entities.floors.Basic();

            case Data.FloorKind.Goal:
                floor = new entities.floors.Goal();
                goals.push(cast(floor, Goal));

            case Data.FloorKind.Fragile:
                floor = new entities.floors.Fragile();

            default:
                floor = null;
        }

        if(floor != null)
            AddFloor(floor, x, y, z);
    }
    public function AddFloor(floor:FloorEntity, x:Int, y:Int, z:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return;
        }

        floors[z][y][x] = floor;
        floor.x = x;
        floor.y = y;
        floor.z = z;
        floor.OnCreate();

        allEntities.push(floor);
    }

    public function Push(fromX:Int, fromY:Int, fromZ:Int, dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        if(dirX != 0 && dirY != 0 && dirZ != 0)
        {
            throw Exception;
            return false;
        }

        if(fromX < 0 || fromX >= width || fromY < 0 || fromY >= length || fromZ < 0 || fromZ >= height)
        {
            throw Exception;
            return false;
        }

        var object = objects[fromZ][fromY][fromX];
        if(object == null)
        {
            trace('WARNING: nothing to push from [$fromX, $fromY]');
            return true;
        }

        if(fromX + dirX < 0 || fromX + dirX >= width || fromY + dirY < 0 || fromY + dirY >= length || fromZ + dirZ < 0 || fromZ + dirZ >= height)
        {
            return false;
        }

        if(!object.CanPush(dirX, dirY, dirZ))
        {
            return false;
        }

        var entityOnwards = objects[fromZ + dirZ][fromY + dirY][fromX + dirX];
        if(entityOnwards == null)
        {
            return Move(fromX, fromY, fromZ, dirX, dirY, dirZ);
        }
        else
        {
            if(Push(fromX + dirX, fromY + dirY, fromZ, dirX, dirY, dirZ))
                return Move(fromX, fromY, fromZ, dirX, dirY, dirZ);
        }

        return false;
    }

    public function Destroy(x:Int, y:Int, z:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
        }

        if(objects[z][y][x] != null)
        {
            objects[z][y][x].OnDestroy();
            allEntities.remove(objects[z][y][x]);
        }

        objects[z][y][x] = null;
    }

    public function RebuildGrid()
    {
        objects = new Vector(height);
        floors  = new Vector(height);

        for(i in 0...height)
        {
            objects[i] = new Vector(length);
            floors[i]  = new Vector(length);

            for(j in 0...length)
            {
                objects[i][j] = new Vector(width, null);
                floors[i][j]  = new Vector(width, null);
            }
        }

        for(entity in allEntities)
        {
            if(entity is ObjectEntity)
                objects[entity.z][entity.y][entity.x] = cast(entity, ObjectEntity);
            else if(entity is FloorEntity)
                floors[entity.z][entity.y][entity.x] = cast(entity, FloorEntity);
        }
    }

    public function Move(fromX:Int, fromY:Int, fromZ:Int, dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        if(dirX != 0 && dirY != 0 && dirZ != 0)
        {
            throw Exception;
            return false;
        }
        
        if(fromX < 0 || fromX >= width || fromY < 0 || fromY >= length || fromZ < 0 || fromZ >= height)
        {
            throw Exception;
            return false;
        }

        if(fromX + dirX < 0 || fromX + dirX >= width || fromY + dirY < 0 || fromY + dirY >= length || fromZ + dirZ < 0 || fromZ + dirZ >= height)
        {
            throw Exception;
            return false;
        }

        var toX = fromX + dirX;
        var toY = fromY + dirY;
        var toZ = fromZ + dirZ;

        var object = GetObject(fromX, fromY, fromZ);
        if(object == null)
        {
            trace('WARNING: nothing to move from [$fromX, $fromY, $fromZ]');
            return false;
        }

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

        objects[fromZ][fromY][fromX] = null;
        objects[toZ][toY][toX] = object;
        object.x = toX;
        object.y = toY;
        object.z = toZ;

        object.OnMove(dirX, dirY, dirZ);

        floor.StashStepOn(object);

        var oldFloor = GetFloor(fromX, fromY, fromZ);
        if(oldFloor != null)
            oldFloor.StashStepOff(object);

        return true;
    }

    public function OnMovementEnd(madeAnything:Bool)
    {
        for(z in 0...height)
        {
            for(y in 0...length)
            {
                for(x in 0...width)
                {
                    var floor = GetFloor(x, y, z);
                    if(floor != null)
                        floor.OnMovementEnd();
                }
            }
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
            if(object == null || object.type != Block)
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

    public function GetObject(x:Int, y:Int, z:Int):ObjectEntity
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return null;
        }

        return objects[z][y][x];
    }

    public function GetFloor(x:Int, y:Int, z:Int):FloorEntity
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return null;
        }

        return floors[z][y][x];
    }
}